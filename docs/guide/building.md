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
git clone --recursive https://github.com/bloodborne-native/bloodborne-mac.git
cd bloodborne-mac
bash runtime/build.sh                          # the game; the first run also builds runtime/deps/
bash packaging/macos.sh                        # Bloodborne.app and its DMG in dist/
```

`runtime/` is [bloodborne-runtime](https://github.com/bloodborne-native/bloodborne-runtime), with
[bloodborne-recomp](https://github.com/bloodborne-native/bloodborne-recomp) inside it as `runtime/recomp/`.
To run the game without the app: `BB_GAME_DIR=/path/to/your/game bash runtime/run.sh` (its
[building guide](https://github.com/bloodborne-native/bloodborne-runtime/blob/main/docs/guide/building.md)
lists the environment variables and developer tools).

The launcher lives in [`launcher/`](../../launcher). Its
[README](../../launcher/README.md) covers development (`npm run dev` previews it in a browser
with sample data; `npm run tauri dev` runs it against `runtime/`) and its code conventions.

Releases are built by GitHub Actions (`.github/workflows/macos.yml`): pushing a `v*` tag builds the
DMG and publishes a release. To update the game: `git -C runtime pull` (or a newer runtime
commit), then commit the submodule.

## Moving a development checkout

macOS dependencies contain absolute installation paths, and CMake caches record the original
source/build directories. A moved checkout can fail before the game starts with a missing
`@rpath/libbbgpu.dylib`, even when the library exists in the new directory.

Preserve or remove the old `runtime/deps/macos-arm64` prefix and generated CMake build directories
under `runtime/deps/build-arm64`, retaining downloaded archives. Preserve or remove
`runtime/out/gpu-arm64` as well. Rebuild dependencies at the new path, then rebuild the runtime:

```sh
BB_ARCH=arm64 bash runtime/scripts/macos/build-deps.sh
bash runtime/build.sh --test
```

Do not move or reset the player's data directory to fix this build error. Packaged applications
use rebased library paths and do not depend on the development checkout's location.

## Versioning

bloodborne-native uses its own app versions, chosen for this project's release scope and
compatibility. bbport's version describes the upstream compatibility level and merge history.
Our major, minor and patch releases are independent of that number; a major release may mark
our own compatibility changes or a substantial product milestone. The maintainer chooses the
release number. Keep the bundled launcher version aligned with the app for update checks.
