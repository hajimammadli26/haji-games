# Cırtdan: Köhnə Bakıda Qaçış — browser build

This branch holds only the game exported for browsers by Godot 4.7.2 (Web preset, single-threaded,
installable web app), ready for a static host. The source is on `main`.

- Play: open the site; on iPhone use Safari's Share > "Add to Home Screen" to run it full screen.
- Rebuild (from `main`): `godot --headless --path . --export-release "Web" build/web/index.html`,
  then copy `build/web/*` here.
- Host: `render.yaml` is a Render Blueprint (static site from this branch).
