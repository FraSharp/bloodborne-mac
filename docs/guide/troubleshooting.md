# Troubleshooting

[← Documentation](../README.md)

## "Bloodborne can't be opened"

The app is not signed with an Apple Developer ID. Right-click it in Applications and choose
**Open**, or allow it in **System Settings → Privacy & Security**. See
[Installation](installation.md#the-first-time-you-open-it).

## The launcher says the game folder has a problem

The message says what is wrong. The common cases (update not merged, old `eboot.bin`, another
edition) are explained in [Game files](game-files.md#when-the-launcher-reports-a-problem).

## The first start takes a long time

The first start compiles the game's shaders, which takes a few minutes. It happens again after an
update that changes the shader cache format.

## The game stops or crashes

1. Open the launcher's **Log** tab, or `~/Library/Application Support/bloodborne_mac/logs/last.log`.
2. Start the game again. Some known crashes are intermittent (below).
3. If it keeps happening, [open an issue](https://github.com/bloodborne-native/bloodborne-mac/issues)
   with the log, your Mac model and macOS version.

Please do not report problems with this port to shadPS4 or to the upstream project.

## Known issues

- **Opening video:** 0.6.0 and later include repairs for the identified shared-state, clock and video
  queue races. Seven accepted pre-release opening trials completed and were observed as
  successful. Rare sampler/GPU assertions and movie shutdown faults seen in earlier development
  runs remain on the watch list; the short checks do not prove they are eliminated. See
  [Stability](https://github.com/bloodborne-native/bloodborne-runtime/wiki/Stability).

- **Yharnam:** the sky behind some gates can be black, with streaks, and some objects pop in.
  Being looked into.
- **Switching FSR on and off while playing with character motion vectors on** can crash the GPU
  ("Invalid Resource"). It does not happen with them off, the default.
- Two of the game's pipelines fail to compile in MoltenVK; their draws are skipped.
- *The Old Hunters*: the Game of the Year editions include it. Since 0.5, add-on packages can be
  loaded from `user/addcont/` (as in bbport); this is not tested on macOS yet.
- FSR 4 / 4.1.1 and upstream's experimental PC memory model are not available on macOS, nor is
  bbport's online play (shadNet) yet: the game plays offline.

## Starting fresh

To reset the settings, quit the launcher and delete `bbport.ini` and `launcher.json` in
`~/Library/Application Support/bloodborne_mac`. Your saves in `user/` are kept.

## Stretched geometry after visiting several areas

Fixed in 0.7.0. Before it, stretched scenery (vertex explosion) and missing walls or objects
appeared after visiting a few areas, until the game was restarted. MoltenVK drew game data
stored past 4 GB in the GPU's view of the game's memory wrongly; that part of memory is now
given to the GPU as a separate buffer. If you still see it on 0.7.0 or later, please report
it with the area and what you did before. `BB_POOL_SPLIT=0` (Advanced → extra environment
variables) turns the fix off, for comparisons only.

The investigation is recorded in the runtime
[stability notes](https://github.com/bloodborne-native/bloodborne-runtime/wiki/Stability).
