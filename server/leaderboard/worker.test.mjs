// Tests for the leaderboard Worker against a real SQLite database standing in for D1.
// Run: node --test server/leaderboard/worker.test.mjs   (Node 22+)
import { test } from 'node:test';
import assert from 'node:assert/strict';
import { DatabaseSync } from 'node:sqlite';
import { readFileSync } from 'node:fs';
import worker, { nickName, NICKS, invalid } from './worker.js';

function d1() { // the parts of the D1 API the Worker uses
  const db = new DatabaseSync(':memory:');
  db.exec(readFileSync(new URL('./schema.sql', import.meta.url), 'utf8'));
  return {
    prepare(sql) {
      return {
        bind(...args) {
          const st = db.prepare(sql);
          return {
            all: async () => ({ results: st.all(...args) }),
            first: async () => st.get(...args) ?? null,
            run: async () => st.run(...args),
          };
        },
      };
    },
    raw: db,
  };
}
const id = (n) => n.toString(16).padStart(32, '0');
const post = (env, body) => worker.fetch(new Request('https://x/score', { method: 'POST', body: JSON.stringify(body) }), env);
const get = (env, q) => worker.fetch(new Request('https://x/top' + q), env);

test('nicknames come from the fixed list', () => {
  assert.equal(NICKS, 80);
  assert.equal(nickName(0), 'Cəld Cırtdan');
  assert.equal(nickName(11), 'Qoçaq Simurq');
});

test('a score is stored and ranked', async () => {
  const env = { DB: d1() };
  const r = await (await post(env, { player: id(1), nick: 3, score: 900, metres: 400, city: 'baku' })).json();
  assert.deepEqual([r.ok, r.rank, r.best], [true, 1, 900]);
  const t = await (await get(env, '?player=' + id(1))).json();
  assert.equal(t.rows[0].nick, nickName(3));
  assert.equal(t.rows[0].you, true);
  assert.equal(t.me.rank, 1);
});

test('a lower score keeps the best one', async () => {
  const env = { DB: d1() };
  await post(env, { player: id(1), nick: 0, score: 900, metres: 400, city: 'baku' });
  env.DB.raw.exec('UPDATE scores SET updated = 0'); // past the rate limit
  const r = await (await post(env, { player: id(1), nick: 0, score: 100, metres: 50, city: 'quba' })).json();
  assert.equal(r.best, 900);
  const row = env.DB.raw.prepare('SELECT * FROM scores').get();
  assert.deepEqual([row.score, row.metres, row.city], [900, 400, 'baku']);
});

test('ranks order players by score', async () => {
  const env = { DB: d1() };
  for (const [n, s] of [[1, 500], [2, 1500], [3, 1000]]) await post(env, { player: id(n), nick: n, score: s, metres: 900, city: 'sheki' });
  const t = await (await get(env, '?player=' + id(3))).json();
  assert.deepEqual(t.rows.map((r) => r.score), [1500, 1000, 500]);
  assert.equal(t.me.rank, 2);
});

test('implausible or malformed scores are refused', async () => {
  const env = { DB: d1() };
  for (const b of [
    { player: 'me', nick: 0, score: 1, metres: 1, city: 'baku' },
    { player: id(1), nick: 80, score: 1, metres: 1, city: 'baku' },
    { player: id(1), nick: 0, score: 100000, metres: 10, city: 'baku' },
    { player: id(1), nick: 0, score: 10, metres: 10, city: 'paris' },
  ]) {
    const res = await post(env, b);
    assert.equal(res.status, 400, JSON.stringify(b));
  }
  assert.equal(invalid({ player: id(1), nick: 79, score: 400, metres: 10, city: 'qobustan' }), '');
});

test('one score per player per ten seconds', async () => {
  const env = { DB: d1() };
  await post(env, { player: id(1), nick: 0, score: 10, metres: 10, city: 'baku' });
  const res = await post(env, { player: id(1), nick: 0, score: 20, metres: 10, city: 'baku' });
  assert.equal(res.status, 429);
});

test('the week board starts afresh each week', async () => {
  const env = { DB: d1() };
  await post(env, { player: id(1), nick: 0, score: 800, metres: 500, city: 'baku' });
  env.DB.raw.exec('UPDATE scores SET week = week - 1, updated = 0'); // that was last week
  await post(env, { player: id(1), nick: 0, score: 300, metres: 200, city: 'baku' });
  const w = await (await get(env, '?scope=week')).json();
  const a = await (await get(env, '?scope=all')).json();
  assert.equal(w.rows[0].score, 300);
  assert.equal(a.rows[0].score, 800);
});

test('answers carry CORS headers for the browser game', async () => {
  const res = await worker.fetch(new Request('https://x/top', { method: 'OPTIONS' }), { DB: d1() });
  assert.equal(res.headers.get('Access-Control-Allow-Origin'), '*');
});
