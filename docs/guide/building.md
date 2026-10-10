# Building from source

[← Documentation](../README.md)

## Requirements

- A Mac with Apple Silicon. macOS 15 or newer is recommended.
- Xcode Command Line Tools and [Homebrew](https://brew.sh):

  ```bash
  brew install bash pkgconf glslang nasm cmake ninja
  ```

- Node 22+ and Rust (the launcher is a [Tauri](https://tauri.app) app).
- A game folder prepared as in [Game files](game-files.md).

## Build

```bash
git clone --recursive https://github.com/PabloVSouza/bloodborne-mac.git
cd bloodborne-mac
bash runtime/build.sh                          # the game; the first run also builds runtime/deps/
bash packaging/macos.sh                        # Bloodborne.app and its DMG in dist/
```

`runtime/` is [bloodborne-runtime](https://github.com/PabloVSouza/bloodborne-runtime), with
[bloodborne-recomp](https://github.com/PabloVSouza/bloodborne-recomp) inside it as `runtime/recomp/`.
To run the game without the app: `BB_GAME_DIR=/path/to/your/game bash runtime/run.sh` (its
[building guide](https://github.com/PabloVSouza/bloodborne-runtime/blob/main/docs/guide/building.md)
lists the environment variables and developer tools).

The launcher lives in [`launcher/app`](../../launcher/app). Its
[README](../../launcher/app/README.md) covers development (`npm run dev` previews it in a browser
with sample data; `npm run tauri dev` runs it against `runtime/`) and its code conventions.

Releases are built by GitHub Actions (`.github/workflows/macos.yml`): pushing a `v*` tag builds the
DMG and publishes a release. To update the game: `git -C runtime pull` (or a newer runtime
commit), then commit the submodule.
