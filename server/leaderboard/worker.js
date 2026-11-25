// Cırtdan's online leaderboard: a Cloudflare Worker over a D1 database (binding name: DB).
// Kid-safe by design: no names, no free text, nothing personal. A player is a random id made on the
// device; a nickname is a number into the fixed list below (adjective + hero); a score comes with its
// distance and city, and implausible ones are refused. Table: see schema.sql.
//
//   GET  /top?scope=all|week&limit=20&player=<id>  -> { week, rows: [{rank, nick, score, metres, city}], me }
//   POST /score  {player, nick, score, metres, city} -> { ok, rank, best }

const ADJ = ['Cəld', 'Qoçaq', 'Bic', 'Şən', 'Ağıllı', 'Sürətli', 'Cəsur', 'Zirək'];
const HERO = ['Cırtdan', 'Simurq', 'Kəndirbaz', 'Pəri', 'Keçəl', 'Tıq-Tıq', 'Məlik', 'Kosa', 'Dəvə', 'Buta'];
const CITIES = ['baku', 'sheki', 'qebele', 'naxcivan', 'lenkeran', 'quba', 'qobustan'];
const MAX_SCORE_PER_METRE = 40; // score grows at most speed × multiplier × 2 (double): far below this
const MIN_SECONDS_BETWEEN = 10; // one score per player per 10 s
const CORS = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
  'Access-Control-Allow-Headers': 'Content-Type',
};

export const nickName = (n) => `${ADJ[Math.floor(n / HERO.length)]} ${HERO[n % HERO.length]}`;
export const NICKS = ADJ.length * HERO.length;
export const weekOf = (ms) => Math.floor((ms / 86400000 + 3) / 7); // weeks start on Monday

const json = (body, status = 200) =>
  new Response(JSON.stringify(body), { status, headers: { 'Content-Type': 'application/json; charset=utf-8', ...CORS } });

/** Checks a submitted score; returns an error text or "" when it is fine. */
export function invalid(b) {
  if (typeof b !== 'object' || b === null) return 'body';
  if (typeof b.player !== 'string' || !/^[a-f0-9]{32}$/.test(b.player)) return 'player';
  if (!Number.isInteger(b.nick) || b.nick < 0 || b.nick >= NICKS) return 'nick';
  if (!Number.isInteger(b.metres) || b.metres < 0 || b.metres > 300000) return 'metres';
  if (!Number.isInteger(b.score) || b.score < 0 || b.score > b.metres * MAX_SCORE_PER_METRE + 100) return 'score';
  if (!CITIES.includes(b.city)) return 'city';
  return '';
}

async function top(url, env) {
  const week = weekOf(Date.now());
  const scope = url.searchParams.get('scope') === 'week' ? 'week' : 'all';
  const limit = Math.min(50, Math.max(1, parseInt(url.searchParams.get('limit') || '20', 10) || 20));
  const col = scope === 'week' ? 'week_score' : 'score';
  const where = scope === 'week' ? 'WHERE week = ?1' : 'WHERE ?1 = ?1';
  const { results } = await env.DB.prepare(
    `SELECT player, nick, ${col} AS score, metres, city FROM scores ${where} ORDER BY ${col} DESC, updated ASC LIMIT ?2`
  ).bind(week, limit).all();
  const player = url.searchParams.get('player') || '';
  let me = null;
  const rows = results.map((r, i) => {
    if (r.player === player) me = { rank: i + 1, score: r.score };
    return { rank: i + 1, nick: nickName(r.nick), score: r.score, metres: r.metres, city: r.city, you: r.player === player };
  });
  if (!me && /^[a-f0-9]{32}$/.test(player)) {
    const mine = await env.DB.prepare(`SELECT ${col} AS score FROM scores ${where} AND player = ?2`).bind(week, player).first();
    if (mine) {
      const above = await env.DB.prepare(`SELECT COUNT(*) AS n FROM scores ${where} AND ${col} > ?2`).bind(week, mine.score).first();
      me = { rank: above.n + 1, score: mine.score };
    }
  }
  return json({ scope, week, rows, me });
}

async function submit(request, env) {
  let b;
  try { b = await request.json(); } catch { return json({ ok: false, error: 'json' }, 400); }
  const bad = invalid(b);
  if (bad) return json({ ok: false, error: bad }, 400);
  const now = Date.now();
  const week = weekOf(now);
  const old = await env.DB.prepare('SELECT score, week, week_score, updated FROM scores WHERE player = ?1').bind(b.player).first();
  if (old && now - old.updated < MIN_SECONDS_BETWEEN * 1000) return json({ ok: false, error: 'too_soon' }, 429);
  const best = old ? Math.max(old.score, b.score) : b.score;
  const weekBest = old && old.week === week ? Math.max(old.week_score, b.score) : b.score;
  const metres = !old || b.score >= old.score ? b.metres : undefined;
  await env.DB.prepare(
    `INSERT INTO scores (player, nick, score, metres, city, week, week_score, updated)
     VALUES (?1, ?2, ?3, ?4, ?5, ?6, ?7, ?8)
     ON CONFLICT(player) DO UPDATE SET nick = ?2, score = ?3,
       metres = CASE WHEN ?3 > scores.score THEN ?4 ELSE scores.metres END,
       city = CASE WHEN ?3 > scores.score THEN ?5 ELSE scores.city END,
       week = ?6, week_score = ?7, updated = ?8`
  ).bind(b.player, b.nick, best, metres ?? b.metres, b.city, week, weekBest, now).run();
  const above = await env.DB.prepare('SELECT COUNT(*) AS n FROM scores WHERE score > ?1').bind(best).first();
  return json({ ok: true, rank: above.n + 1, best });
}

export default {
  async fetch(request, env) {
    const url = new URL(request.url);
    if (request.method === 'OPTIONS') return new Response(null, { status: 204, headers: CORS });
    try {
      if (request.method === 'GET' && url.pathname === '/top') return await top(url, env);
      if (request.method === 'POST' && url.pathname === '/score') return await submit(request, env);
      if (request.method === 'GET' && url.pathname === '/') return json({ ok: true, game: 'Cırtdan', nicks: NICKS });
      return json({ ok: false, error: 'not_found' }, 404);
    } catch (e) {
      return json({ ok: false, error: 'server' }, 500);
    }
  },
};
