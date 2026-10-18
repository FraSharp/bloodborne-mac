# Documentation

[← Back to the project](../README.md)

> [!IMPORTANT]
> **Experimental project: expect bugs and regressions.** Our CPU recompiler and native renderer
> development diverges from bbport and can reduce stability. Loading hangs, crashes and graphical
> corruption are known risks. Read the [project notice](../README.md) before choosing a build.
> For the dedicated macOS port of bbport, see [bmy/bbport-mac](https://github.com/bmy/bbport-mac).

## Playing

1. [Installation](guide/installation.md): download, the first start, where your data lives.
2. [Game files](guide/game-files.md): preparing your dump, supported editions, The Old Hunters.
3. [Settings](guide/settings.md): the launcher, the in-game menu, languages, controllers.
4. [Mods and patches](guide/mods-and-patches.md): installing mods, load order, third-party
   patches.
5. [Performance](guide/performance.md): what to expect, and the settings that matter.
6. [Troubleshooting](guide/troubleshooting.md): common problems and known issues.

- [Launcher during gameplay](guide/launcher-lifecycle.md): menu-bar/tray behaviour and restoring the window.
- [Profiles and saves](guide/saves.md): first-profile setup, identities, backups and restore in the development launcher.

## Developing

- [Building from source](guide/building.md): the app and its DMG.
- [How it works](guide/how-it-works.md): the four repositories this app is made of.
- [Launcher wiki](https://github.com/bloodborne-native/bloodborne-launcher/wiki): player guides and the save-manager roadmap.
- [Launcher](../launcher/app/README.md): the launcher's stack and code conventions.
- The game itself: [bloodborne-runtime](https://github.com/bloodborne-native/bloodborne-runtime/tree/main/docs)
  (runtime, renderer, macOS performance); the translator and the recompiler:
  [bloodborne-recomp](https://github.com/bloodborne-native/bloodborne-recomp).

- [Save manager roadmap](SAVE_MANAGER.md): storage contract and planned previews/editor.

## Project

- [Credits and licenses](CREDITS.md)
