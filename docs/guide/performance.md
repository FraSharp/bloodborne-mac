# Performance

[← Documentation](../README.md)

Measured on an Apple M3 Pro (18-core GPU, 18 GB) with a 1080p output:

| Where | Setting | FPS |
|---|---|---|
| Hunter's Dream | FSR 3.1 *Balanced* | 58–68 |
| Hunter's Dream | FSR 3.1 *Balanced*, Metal renderer | 62–66 (MoltenVK 58 in the same test) |
| Central Yharnam | FSR 3.1 *Balanced* | 44–49 |
| The clinic at the start | Native 1080p, no upscaler | ~31 |
| The clinic at the start | FSR 3.1 *Balanced* (renders 1130×636) | ~44 |

- The game is limited by the GPU, so the upscaler preset matters most
  ([recommended settings](settings.md#recommended-settings)).
- Character motion vectors cost about 6 FPS with FSR.
- The frame rate is uncapped by default; set a limit on the Graphics tab, or press **F3** for 30
  FPS while playing.
- Only one Mac has been measured; results on other Macs are welcome in the
  [issues](https://github.com/bloodborne-native/bloodborne-mac/issues).

Where a frame's time goes and what has been tried: the runtime's
[performance notes](https://github.com/bloodborne-native/bloodborne-runtime/blob/main/docs/PERFORMANCE.md).
