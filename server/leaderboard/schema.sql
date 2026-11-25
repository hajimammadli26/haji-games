-- The leaderboard table (already created in the D1 database "cirtdan-leaders").
CREATE TABLE IF NOT EXISTS scores (
  player TEXT PRIMARY KEY,      -- a random id made on the device (32 hex), nothing personal
  nick INTEGER NOT NULL,        -- index into the fixed nickname list in worker.js
  score INTEGER NOT NULL,       -- best score ever
  metres INTEGER NOT NULL,      -- distance of that best run
  city TEXT NOT NULL,           -- city of that best run
  week INTEGER NOT NULL,        -- the week of week_score (weeks start on Monday)
  week_score INTEGER NOT NULL,  -- best score this week
  updated INTEGER NOT NULL      -- last submission, ms since 1970 (rate limit)
);
CREATE INDEX IF NOT EXISTS scores_score ON scores(score DESC);
CREATE INDEX IF NOT EXISTS scores_week ON scores(week, week_score DESC);
