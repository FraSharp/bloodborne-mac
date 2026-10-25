# Performance

[← Documentation](../README.md)

Measured on an Apple M3 Pro (18-core GPU, 18 GB) with a 1080p output, on the current code
(2026-10-24 and 25):

| Where | Renderer | Setting | FPS |
|---|---|---|---|
| Cathedral Ward, standing (about 1,660 draws a frame) | MoltenVK | Native 1080p, no upscaler | 30.6 |
| The same | MoltenVK | FSR 3.1 *Balanced* | 27.6 |
| The same | Metal | Native 1080p, no upscaler | 38.2–39.6 |
| The same | Metal | FSR 3.1 *Balanced* | 36.2 |
| A new game, 3 h 26 min of play | Metal | Native 1080p, no upscaler | median 42.2 (37 or more 90% of the time) |

- The upscalers do not make the game faster at 1080p any more: native rendering got faster with
  the renderer and memory work, and FSR 3.1 now costs more than it saves. Use them above 1080p
  output, where native resolution would need too much memory
  ([recommended settings](settings.md#recommended-settings)).
- The Metal renderer is about 25–30% faster than MoltenVK at native 1080p.
- Character motion vectors cost a few FPS with an upscaler.
- The frame rate is uncapped by default; set a limit on the Graphics tab, or press **F3** for 30
  FPS while playing.
- Only one Mac has been measured; results on other Macs are welcome in the
  [issues](https://github.com/bloodborne-native/bloodborne-mac/issues).

Where a frame's time goes and what has been tried: the runtime's
[performance notes](https://github.com/bloodborne-native/bloodborne-runtime/blob/main/docs/PERFORMANCE.md).
