#!/usr/bin/env bash
# Exports the game for browsers and commits the build to the "site" branch (Render deploys it from there).
# Usage: tools/publish_web.sh /path/to/godot   (from inside the repository; it pushes the branch)
# COMMIT_TRAILERS (optional) is added to the build commit's message.
set -euo pipefail
GODOT="${1:?path to the Godot 4.7.2 binary}"
ROOT="$(git rev-parse --show-toplevel)"
SRC="$(git -C "$ROOT" rev-parse --short HEAD)"
OUT="$ROOT/build/web"
mkdir -p "$OUT"
touch "$ROOT/build/.gdignore" # Godot must not import the build's own files
"$GODOT" --headless --path "$ROOT" --export-release "Web" "$OUT/index.html"
WT="$(mktemp -d)"
git -C "$ROOT" fetch -q origin site
git -C "$ROOT" worktree add -q "$WT" origin/site
trap 'git -C "$ROOT" worktree remove --force "$WT"' EXIT
find "$WT" -maxdepth 1 -name 'index*' -type f -delete
cp "$OUT"/index* "$WT"/
git -C "$WT" add -A
if git -C "$WT" diff --cached --quiet; then
  echo "site already up to date"
  exit 0
fi
git -C "$WT" commit -q -m "build: browser build of main@$SRC" ${COMMIT_TRAILERS:+-m "$COMMIT_TRAILERS"}
git -C "$WT" push -q origin HEAD:site
echo "site updated to main@$SRC"
