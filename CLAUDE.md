# bloodborne-mac

The macOS app of Bloodborne (PS4, CUSA03173 1.09) on Apple Silicon: the launcher, the packaging,
the releases and the player guides. The game itself is the `runtime/` submodule
(bloodborne-runtime), with the CPU layer and recompiler in `runtime/recomp/` (bloodborne-recomp).
Clone with `--recursive`.

## Layout

- `launcher/app/`: the launcher (Tauri: React + Rust, `src-tauri/src/main.rs`); its own README has
  the stack and conventions. 20 languages; settings in `bbport.ini` and `launcher.json` in
  `~/Library/Application Support/bloodborne_mac/` (the app's names stay `bloodborne_mac` so
  players' saves and settings never move).
- `packaging/macos.sh`: `Bloodborne.app` and its DMG in `dist/`, from `runtime/`'s build.
- `.github/workflows/macos.yml`: builds and packages on every push; a `v*` tag publishes a release.
- `docs/guide/`: player guides; `docs/screenshots/` (README pictures).

## Build

```sh
bash runtime/build.sh            # the game (runtime/deps/ the first time: ~1 h)
bash packaging/macos.sh          # the app and the DMG
cd launcher/app && npm run tauri dev   # the launcher against runtime/ (npm run dev: browser preview)
```

## Releases

1. Bump the version in `launcher/app/package.json`, `package-lock.json` (two places),
   `src-tauri/Cargo.toml`, `src-tauri/Cargo.lock`, `src-tauri/tauri.conf.json`.
2. Run the game from this build at least once (`runtime/tools/test_run.sh`), and the user approves.
3. Commit, `git tag -a vX.Y.Z -m "..."`, push `main` and the tag; the workflow builds the DMG and
   publishes the release. Check the run (`gh run list`) and the release's asset.

Release notes say what changed for players. The README's screenshots come from the game
(`runtime/tools/grab.sh`), in English, never from the user's screen.

## Where things stand

- Releases: up to v0.5.0 (bbport 0.5). bbport has released 0.51 since (not merged yet).
- Known issue: an occasional GPU assertion while loading (`Unimplemented PM4 type 0`), also in the
  released build.
- The recompiler: every function generated and running; it still uses more CPU than the
  translator (R3, speed). Status: bloodborne-recomp's wiki, Recompilation-status.

## Working rules (all three repositories)

- **The project is three repositories**, nested as submodules:
  [bloodborne-mac](https://github.com/PabloVSouza/bloodborne-mac) (the app) ⊃ `runtime/` =
  [bloodborne-runtime](https://github.com/PabloVSouza/bloodborne-runtime) ⊃ `recomp/` =
  [bloodborne-recomp](https://github.com/PabloVSouza/bloodborne-recomp). Commit in the repository
  that owns the file, push it, then bump the submodule pointer in the parent (runtime → recomp,
  mac → runtime) and push that too.
- **Before any push, check `git remote get-url origin`** (a clone once still pointed at a local
  repository and a force-push landed there). Push to `main`; ask before force-pushing anything
  that existed before this session.
- **Commits:** a short subject, a body that says what changed and why (numbers when measured), and
  the trailer the session asks for (`Co-Authored-By: ...`).
- **Credits:** this work is built on [bbport](https://github.com/deadinside28/bloodborne_pc) by
  deadinside28 and on [shadPS4](https://github.com/shadps4-emu/shadPS4); keep them credited where
  they are (README, docs/CREDITS.md, the wikis). Code taken from another project or fork is
  credited in the same commit: CREDITS.md, the wiki's credits page, the commit message and a short
  code comment.
- **No game code, ever:** no decompiled or generated game code, no game files, no records of game
  memory in any repository. Docs and wikis talk about the recompiler only (not about decompiled
  code or private folders).
- **Testing the game:** run it in the background with `runtime/tools/test_run.sh NAME [VAR=...]`
  (bloodborne-runtime's `tools/test_run.sh`): it copies the player's save first and never touches
  the real one. Check `pgrep -x bb-probe` first; one game at a time. Test windows open on the
  user's screen: say so before long batches of runs (bisections), and stop when asked.
- **Never capture the user's screen.** Pictures come from the game itself: `tools/grab.sh NAME`
  (its frame) or `tools/grab.sh --screen NAME` (with the in-game menu). Screenshots in English
  (`BB_LANGUAGE=1 BB_UI_LANGUAGE=en`).
- **Shell:** no `rm -rf` on variable paths (literal paths only); no `xargs ... sh -c '...'` (write
  a script file instead).
- **Docs:** plain, precise English; numbers measured, not guessed. When a milestone or a measured
  number changes, update the docs and the wiki status pages (progress bars: 20 blocks, one per 5%).
