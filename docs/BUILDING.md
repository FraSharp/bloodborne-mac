# Building and releasing

[← Documentation](README.md)

## Requirements

- A Mac with Apple Silicon (macOS 15 or newer: the minimum the app declares and is built for).
- Xcode Command Line Tools and [Homebrew](https://brew.sh):

  ```bash
  brew install bash pkgconf glslang nasm cmake ninja
  ```

- Node 22+ and Rust (for the launcher).
- A game folder prepared as in [Game files](guide/game-files.md).

## Build

```bash
git clone --recursive https://github.com/bloodborne-native/bloodborne-mac.git
cd bloodborne-mac
bash runtime/build.sh                 # the game; the first run builds runtime/deps/ (about an hour)
bash packaging/macos.sh               # Bloodborne.app and its DMG in dist/
cd launcher && npm run tauri dev      # the launcher against runtime/ (npm run dev: browser preview)
```

- Run the game without the app, after building: `BB_GAME_DIR=/path/to/game bash runtime/run.sh`. The runtime's
  [building guide](https://github.com/bloodborne-native/bloodborne-runtime/blob/main/docs/BUILDING.md)
  has the environment, the test runners and how to measure.
- The launcher's [README](../launcher/README.md) has its stack, conventions and checks.
- The libraries in `runtime/deps/macos-arm64` are `@rpath` ones: moving the checkout needs no
  rebuild of them, only `bash runtime/build.sh` again for the game's own binaries. Never move or
  reset the player's data folder to fix a build. Packaged apps do not depend on the checkout's
  location.

## Working across the repositories

`launcher/`, `runtime/` and `runtime/recomp/` are submodules, checked out at a commit. Before
editing one, `git checkout main && git pull` inside it. Commit and push there first, then commit
the new pointer in its parent (recomp → runtime → app; launcher → app) and push that.

## Releasing

App versions are this project's own; bbport's version only records imported compatibility. The
maintainer chooses the number. The app and the bundled launcher always have the same version, so
update checks compare correctly.

1. Bump the version: `bash packaging/version.sh X.Y.Z` writes it to the launcher's
   `package.json`, `package-lock.json` (two places), `src-tauri/Cargo.toml`, `src-tauri/Cargo.lock`
   and `src-tauri/tauri.conf.json`; `bash packaging/version.sh --check` reports whether they agree
   (the workflow does it against the tag).
2. Write `docs/releases/vX.Y.Z.md`: what changed for players, known issues, how to install.
3. Test this build: copied-save gameplay (`runtime/tools/test_run.sh`) and a new save through the
   opening video (`runtime/tools/test_opening_video.sh`); the maintainer approves.
4. Commit and push `main`, run the workflow on it (`gh workflow run macos.yml --ref main`; pushes do
   not build) and check that it passes.
5. `git tag -a vX.Y.Z -m "..."` (a release candidate: `vX.Y.Z-rc.N`, published as a GitHub
   pre-release that the launcher's update check skips; its notes say it is a candidate and what
   feedback is wanted) and push the tag: `.github/workflows/macos.yml` builds the DMG and
   publishes the release with the notes, then posts it to the Discord server's `#releases`
   (`packaging/discord_release.py`: the notes' heading, their "What's new" list and known issues;
   the `DISCORD_RELEASES_WEBHOOK` secret). Check the run (`gh run list`), the release's asset and
   the post. `DRY_RUN=1 python3 packaging/discord_release.py vX.Y.Z` shows the post beforehand.

README screenshots come from the game (`runtime/tools/grab.sh`, in English), never from the
screen; launcher screenshots from its browser preview with mock data.
