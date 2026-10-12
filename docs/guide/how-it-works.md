# How it works

[← Documentation](../README.md)

The project has four repositories:

- **The app** (this repository): macOS packaging, releases and player guides. It puts the
  launcher and runtime into `Bloodborne.app` with its own bash, Python and libraries.
- **The launcher** ([bloodborne-launcher](https://github.com/bloodborne-native/bloodborne-launcher),
  in `launcher/app/`): Tauri and React; settings, saves, mods and patches, and starting the game.
  It is an independent submodule. macOS integration works today; Windows and Linux are planned.
- **The runtime** ([bloodborne-runtime](https://github.com/bloodborne-native/bloodborne-runtime), in
  `runtime/`): loads the game's executable, provides the PS4 system libraries it calls, and draws
  its graphics through Vulkan (MoltenVK on macOS) with a renderer derived from shadPS4. Built on
  [bbport](https://github.com/deadinside28/bloodborne_pc).
- **The CPU layer** ([bloodborne-recomp](https://github.com/bloodborne-native/bloodborne-recomp), in
  `runtime/recomp/`): runs the game's x86-64 code on Apple Silicon, translated to arm64 as it runs,
  and the recompiler that turns it into native code ahead of time from your own copy.

Their own docs go into each one:
[runtime](https://github.com/bloodborne-native/bloodborne-runtime/blob/main/docs/guide/how-it-works.md),
[translator](https://github.com/bloodborne-native/bloodborne-recomp/blob/main/docs/ARM64_NATIVE.md),
[recompilation](https://github.com/bloodborne-native/bloodborne-recomp/blob/main/docs/RECOMPILATION.md).
