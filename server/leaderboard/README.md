# Cırtdan online leaderboard (Cloudflare Worker + D1)

Kid-safe: no names or free text, nothing personal. A player is a random id made on the device; the
nickname is a number into a fixed list (adjective + hero, e.g. "Cəld Simurq"); scores come with their
distance and city, and implausible ones are refused. Free on Cloudflare's free plan, never sleeps.

- `worker.js` — the Worker (`GET /top`, `POST /score`), binding `DB` to the D1 database.
- `schema.sql` — the table (already created in D1 database `cirtdan-leaders`).
- `worker.test.mjs` — tests against SQLite: `node --test server/leaderboard/worker.test.mjs`.

## Deploy (Cloudflare dashboard, no command line)
1. Workers & Pages → Create → Create Worker → name `cirtdan-leaders` → Deploy.
2. Edit code → replace everything with `worker.js` → Deploy.
3. Worker → Settings → Bindings → Add → D1 database → variable name `DB`, database `cirtdan-leaders` → Deploy.
4. Open `https://cirtdan-leaders.<your-subdomain>.workers.dev/` — it answers `{"ok":true,...}`.
