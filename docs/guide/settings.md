# Settings

[← Documentation](../README.md)

Renderer and game-patch options can be changed in the launcher before starting, or in the
in-game menu while playing. These options share `bbport.ini`, so a change in one shows up in
the other. Launcher startup options use `launcher.json`; profile ownership uses SQLite.

## The launcher

![The launcher's controls tab](../screenshots/launcher-controls.png)

| Tab | What it has |
|---|---|
| **Home** | The active profile and recorded trophies, shortcuts to Profiles/Saves, game folder, edition/readiness and a summary of the main settings |
| **Graphics** | Output resolution, monitor, fullscreen, frame presentation (V-Sync), frame-rate mode/limit, FPS counter, upscaling and sharpening, motion vectors, model detail and visual effects |
| **Controls** | Which controller to use, and button mapping for controller and keyboard |
| **Game** | Game language, skipping intro videos and the active profile’s save-folder location |
| **Profiles** | First-profile setup, fresh profile creation, rename, active selection and confirmed deletion; each profile’s Saves · Backups and Trophies. See [Profiles and saves](saves.md) |
| **Mods** | Mods and their load order. See [Mods and patches](mods-and-patches.md) |
| **Patches** | Third-party game patches. See [Mods and patches](mods-and-patches.md) |
| **Advanced** | Launcher language and hiding during gameplay, new-version checks, experimental performance options, free camera/debug menu, diagnostics, extra environment variables and the data folder |
| **Log** | The game's output while it runs |

The Home frame-rate shortcut opens Graphics. The Game save-folder row shows the active
profile's location; use Profiles to change the active identity. Saves keeps backup/restore. Backup-folder access is under Advanced → Data. Low-level and experimental renderer options remain in Advanced.
This layout is the one in 0.7.0.

## The in-game menu

![The in-game settings menu](../screenshots/game-menu.jpg)

Press **F1** on the keyboard, or **L3 + R3** on a controller, to open the settings menu over the
game. Most graphics settings apply right away. Settings that need a restart say so, and the menu
has a button to restart the game.

## Coming in the next release

On development main, not yet in a release:

- **One set of settings.** The launcher keeps the settings in its database, shared by all profiles.
  While the game runs, the launcher and the in-game menu send each other their changes, so each
  shows the other's. `bbport.ini` and `launcher.json` are still written for the scripts.
- **The in-game menu** has the launcher's look and tabs (Graphics, Game, Advanced) and every
  graphics setting the launcher has, including the launcher's own: fullscreen, monitor, frame
  presentation, frame-rate mode and limit, the Metal HUD and the performance options. Fullscreen
  switches at once; the others say they need a restart, and **Restart** applies them.
- **On-screen keyboard** for the character name and other text with a controller.
- **FPS counter:** small (frame rate and frame time) or big (also the upscaler, the resolutions, a
  frame-time graph and the renderer), in any corner or edge center (Graphics → Frame rate).
- **Memory estimate** on the Graphics page and in the menu: what the game will use with these
  settings, against the Mac's memory, in amber above three quarters of it.
- **Outputs above 1080p start again** (they lost the GPU at boot on an 18 GB Mac). Known issue:
  characters are drawn black when the game renders more than about 3.5 million pixels (1440p
  native, 4K with the Quality preset or none); a preset that renders less avoids it.
- **Renderer (experimental):** Advanced → Performance → **Renderer**: MoltenVK (the default) or
  **Metal**, the new native Metal renderer. Two alternating pairs on an M3 Pro measured 65.5 and
  61.7 FPS on Metal against 58.0 and 58.1 on MoltenVK.
- **Metal performance HUD** (Graphics → Frame rate, macOS): Apple's statistics overlay.
- **Trophy notifications** show only while the game's window is in front.

## Languages

The launcher and the in-game menu are available in the 20 languages of the PS4 game:

English, Português (Brasil), Português (Portugal), Español (España), Español (Latinoamérica),
Français, Deutsch, Italiano, Nederlands, Polski, Русский, Türkçe, Suomi, Svenska, Dansk, Norsk,
日本語, 한국어, 简体中文 and 繁體中文.

- **Hide launcher during gameplay:** Advanced → Launcher. Enabled by default; turn off to keep the Log tab visible. Changes apply during gameplay.
- **Launcher language:** Advanced → Launcher language. By default it follows macOS.
- **In-game menu:** follows the launcher's language.
- **Game language** (the game's own text and voices): Game → Language. Every language the PS4
  version offers can be chosen, Portuguese included.

## Recommended settings

On Apple Silicon the game is limited by the GPU, so upscaling gives the largest gain:

- **Upscaler:** FSR 3.1 with the *Balanced* or *Performance* preset.
- **Character motion vectors:** off (the default on macOS). They improve FSR on moving characters
  but cost about 5 ms per frame on Apple GPUs.

With a 1080p output, the upscaler preset sets the resolution the whole game renders at from the
start, so changing the preset needs a restart.

See [Performance](performance.md) for measurements.

## Controllers

Controllers work through SDL3: PlayStation, Xbox and other common controllers are recognized.
Without a controller, the keyboard can be used; its keys can be remapped on the **Controls** tab.

## New-version notifications

The launcher checks stable app releases on GitHub and shows a dismissible banner
when a newer version is available. Advanced includes automatic checks and **Check now**;
downloads and installation remain manual. See [Updates](updates.md).

**Advanced → Launcher → Trophy notifications** shows the macOS trophy overlay. It is on by
default; turning it off saves about 2 FPS (one measured pair).

Since 0.7.0, Saves is a profile detail section rather than a sidebar tab. Open
Profiles and click a name for Saves · Backups, or the trophy icon/count for the full trophy
list. Opening details does not change the active profile.
