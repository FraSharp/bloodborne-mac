# Architecture

[← Documentation](README.md)

How the app is put together. Each part has its own docs; this page says which part does what.

## Four repositories

| Repository | Here as | What it does |
|---|---|---|
| **bloodborne-mac** (this one) | | Packages the macOS app and its DMG, publishes releases, holds the player guides and the roadmap |
| [bloodborne-launcher](https://github.com/bloodborne-native/bloodborne-launcher) | `launcher/` | The launcher (Tauri: React and Rust): profiles, saves, settings, mods, patches, starting the game and tracking trophies |
| [bloodborne-runtime](https://github.com/bloodborne-native/bloodborne-runtime) | `runtime/` | Runs the game: loads its executable, provides the PS4 system libraries, draws its graphics (Vulkan on MoltenVK, or Metal directly) |
| [bloodborne-recomp](https://github.com/bloodborne-native/bloodborne-recomp) | `runtime/recomp/` | bbcpu, which runs the game's x86-64 code on arm64, and the recompiler that turns it into native code ahead of time |

The runtime is built on [bbport](https://github.com/deadinside28/bloodborne_pc), the native Linux
port this project started from, and on [shadPS4](https://github.com/shadps4-emu/shadPS4).

## The app

`packaging/macos.sh` builds `Bloodborne.app` from the runtime's build and the launcher:

| In the bundle | |
|---|---|
| `Contents/MacOS/` | the launcher, `bb-probe` (the game), `bb-gpu-capabilities`, bash |
| `Contents/Frameworks/` | the runtime's GPU library, MoltenVK, the Vulkan loader, SDL3, FFmpeg |
| `Contents/Resources/game/` | `run.sh`, the runtime's scripts and patches, the Vulkan driver manifest |
| `Contents/Resources/python/` | a standalone Python 3 |

Library references are rewritten to `@rpath` and the bundle is signed ad hoc (no Developer ID, so
macOS asks the player to allow it once). Nothing else needs installing.

## A launch

1. The launcher checks the game folder (the runtime's `game_check.py`: the 1.09 executable), and
   makes a backup of the active profile's saves.
2. It writes `bbport.ini` from its settings database, sets the environment (the profile's folder,
   the renderer, the frame-rate mode, ...) and starts `run.sh` with the app's bash.
3. `run.sh` links the game's modules into one image, applies the patches and mods (a merged view;
   the game folder is never changed), sizes memory for the output, and starts `bb-probe`.
4. The game runs through bbcpu (or the recompiled library), on the runtime's PS4 libraries and
   renderer. While it runs, the launcher and the in-game menu exchange setting changes over the
   game's standard streams. The game shows trophy notices in its overlay; the launcher imports
   recorded unlocks.
5. The launcher hides to the menu bar during the game and comes back when it exits.

Details: the runtime's [architecture](https://github.com/bloodborne-native/bloodborne-runtime/blob/main/docs/ARCHITECTURE.md);
the launcher's [settings](https://github.com/bloodborne-native/bloodborne-launcher/blob/main/docs/SETTINGS.md)
and [profiles and saves](https://github.com/bloodborne-native/bloodborne-launcher/blob/main/docs/SAVE_MANAGER.md).

## Where it is going: native code

Translating the game's code works but costs CPU time, and every frame still goes through the
PS4's command format and MoltenVK. Two milestones replace that:

- **The recompiler** turns the game's functions, from the player's own executable, into C
  compiled into a native library, checked against calls recorded from the original. Every
  function is generated and the game runs on them; making that code cheaper than the translator
  is next ([Recompilation](https://github.com/bloodborne-native/bloodborne-recomp/blob/main/docs/RECOMPILATION.md)).
- **The native renderer** draws with each platform's own GPU API: a shared core with Vulkan and
  Metal backends. The frame already draws through Metal behind an option; resources in Metal are
  next ([Native renderer](https://github.com/bloodborne-native/bloodborne-runtime/blob/main/docs/NATIVE_RENDERER.md)).

Only the tools are published, never the game's code.
