# Findings and where to continue

[← Documentation](README.md)

What the work of 2026-10-19/20 established, what is still open, and how to pick each thread up.
Measurements are on the maintainer's M3 Pro (18 GB), copied saves (`runtime/tools/test_run.sh`),
the Hunter's Dream, English. Commit hashes name the repository they belong to. The plan as a
checklist is the [roadmap](ROADMAP.md); the native renderer's own record is the runtime's
[NATIVE_RENDERER.md](https://github.com/bloodborne-native/bloodborne-runtime/blob/main/docs/NATIVE_RENDERER.md).

Nothing below is released: development main carries it; 0.7.0 is the current release.

## State of development main

| Area | State | Where |
|---|---|---|
| GPU crash with motion vectors | Fixed (Metal object lifetimes) | runtime `57fba4f` |
| Settings | In the launcher's database, synced both ways with the in-game menu while the game runs | runtime `8cbcf64`, launcher `1dc03d8` |
| In-game menu | The launcher's look, tabs and every graphics setting; on-screen keyboard; memory estimate | runtime `511b7ac` |
| Outputs above 1080p | Start again (pool imported in windows; memory from the scene) | runtime `74c556e` |
| FPS counter | Small/big, six positions; big names the GPU and CPU path | runtime `511b7ac`, `77bcc30` |
| Trophy notices | Shown only while the game's window is in front; sent at once (observed); activation handed back to the game | launcher `6f626d7`, `4b9a90e`; runtime `77bcc30` |
| Metal renderer (R5 N5) | Every pipeline builds in Metal; the frame draws through Metal behind Advanced → Renderer (experimental); a full play session on it was stable | runtime `dfb01fd`, `1992ecf`, `fd60bb9`; launcher `1f1c146` |
| Recompiled CPU code with Metal | Runs, correct picture | recomp `5bb8499` |

## The Metal renderer (R5)

**Route.** Adapted from [Wooloomooloo2/bloodborne_mac_port](https://github.com/Wooloomooloo2/bloodborne_mac_port)
(GPL-2.0-or-later; partly from Huax-1839/bloodborne-macos), not merged: their renderer is Metal
only, ours stays multiplatform. A layer under vulkan.hpp's dispatcher (`renderer_metal/mtl_vk_layer`)
encodes the command buffers the Metal path owns in Metal (`mtl_frame`) and sends the rest to
MoltenVK, so the renderer is unchanged and Linux keeps real Vulkan. Pipelines come from
`PipelineFactory` (SPIR-V to MSL with SPIRV-Cross; rect lists, tessellation and geometry
rewrites; a binary archive). The route change against N4's command stream is recorded in
NATIVE_RENDERER.md. MoltenVK stays the default.

**Switches.** `BB_METAL_SHADOW=1` (build every pipeline in Metal too, count failures),
`BB_METAL_PRESENT=1` (present pass only), `BB_METAL_FRAME=1` (every command buffer; the launcher's
Renderer → Metal sets it), `BB_METAL_TRACE=1` (the layer's command counts).

**Measured.**

| | FPS | p90 |
|---|---|---|
| MoltenVK, translator (two runs) | 58.0, 58.1 | 20.4, 18.9 ms |
| Metal, translator (two runs, alternating with the above) | 65.5, 61.7 | 16.3, 17.6 ms |
| Metal, recompiled code (one run, frame-stat windows) | 51.7–57.3 | |

Shadow check: 550 pipelines (510 graphics with 15 rect lists and 19 tessellated, 40 compute),
0 failed. Frame path: 0 draws without a Metal pipeline, 0 unsupported commands. Stage-B cost per
draw rose a little on Metal (5.27–5.59 against 5.06–5.18 µs). Game CPU % was not measured (the
bench summary has no CPU sum).

**Next.**

1. A long play session on Metal (fights, loading, other areas): only 60-second holds so far.
2. Resources created in Metal (images, views, samplers, buffers, the guest pool): the fork did it
   in its "M2" (`3ee456f`, "images, views and samplers are Metal textures..."); then MoltenVK can be
   left out on macOS. In slices, each behind a switch and measured against MoltenVK.
3. MetalFX from the fork, as an upscaler option, measured first.
4. Shaders ahead of time (N2): MSL is still converted while the game runs.

**How to continue.** The fork's clone: `git clone https://github.com/Wooloomooloo2/bloodborne_mac_port`
(we took `0b50589` for the backend pieces and `78b59f5`, the last commit with the layer, for
`mtl_vk_layer`, `mtl_frame`, `mtl_shadow`). Each copied file names its source commit in its
header. Credit what is taken in the same commit (CREDITS, the wiki, the commit message).

## Above 1080p

**Fixed: the GPU device lost at boot.** `run.sh` gave every output above 1080p 9152 MiB of game
memory (a 10,176 MiB pool), imported twice (whole, and from 3 GiB): 17.3 GB in Metal's residency
set. Now the pool is imported in overlapping windows (one every 3 GiB, 3.5 GiB long), and the
memory follows the scene: 5056 MiB plus 448 bytes per scene pixel above 1080p, in 64 MiB steps
(a 2258x1270 scene failed at 5184 MiB and ran at 5376; the formula gives 5440). Every output
with an upscaler preset stays under 8 GB.

**Open: characters drawn black above about 3.5 million scene pixels.** Bisected with explicit
`BB_RENDER_RES` (MoltenVK, translator):

| Scene | Pixels | Characters |
|---|---|---|
| 2258x1270 (4K Balanced) | 2.87 M | lit |
| 2400x1350 | 3.24 M | lit |
| 2556x1350 / 2400x1438 | 3.45 M | lit |
| 2552x1438 / 2556x1438 | 3.67–3.68 M | black |
| 2560x1440 (1440p native, 4K Quality) | 3.69 M | black |

The same with FSR on or off, at 1440p or 4K output, with more memory (6656 MiB), with the
1440p light-grid patch, and with the scene nudged away from the output size. A fixed buffer of
14 MiB at 4 bytes per pixel (or about 14,000 lighting tiles of 16x16) fits the boundary once
targets are padded. No such cap was found in the port's code. **Not MoltenVK's encoding:** 1440p
native with `BB_METAL_FRAME=1` (our own Metal encoding, 2026-10-20) draws the characters black too.
Left: the game (a buffer sized for 1080p) or MoltenVK's resources, which the Metal path still uses.
Creating resources in Metal (R5's next step) decides it; a PC report at 1440p native would too.

## Memory estimate

Launcher (`src/lib/data/memory.ts`) and menu (`MemoryEstimate` in `bbport_overlay.cpp`) compute
the same: the game's memory as `run.sh` sizes it, plus 1024 MiB the runtime adds, plus the
renderer's about 1000 MiB + 360 MiB per million scene pixels (1465 MiB at 1506x848, 1655 at
1920x1080, 2051 at 2258x1270, 2200 at 2400x1350, ~2330 at 2560x1440; the output size made no
difference). Amber above 75% of the Mac's memory. It leaves out the runtime's CPU-side memory.
Keep the three (run.sh, launcher, menu) in step.

## Trophy notices

The helper (`bloodborne-overlay`, launcher) is a separate window on every Space. SDL kept
reporting input focus for a fullscreen game while another app was in front, and macOS never
reported the game (a process without an app bundle) as the frontmost application. The helper now
checks the window order: the front layer-0 window on screen must belong to its parent (the game),
every 250 ms while a notice is up; it logs the decision when it changes. The runtime no longer
waits for SDL focus on macOS: in a fullscreen run on the second display the first preview went out
right after the pad opened (before the title), shown with the game's window in front. The helper's
debug build loads its page from the launcher's dev server (port 5173); without it the helper never
becomes ready ("helper did not become ready"). The card keeps its original transparency (a CSS backdrop filter cannot blur another
window; macOS's window material showed opaque over the game: both removed).

A real trophy in a fullscreen launcher session on Metal took the keyboard and controller from the
game while its window stayed in front: the helper had become the active app. The helper now gives
activation back (`NSApp.deactivate`) whenever it is active while a notice is up, and logs it. Still
to confirm in a launcher session (test games are background-only, see Test helpers).

## Settings sync

Lines on the game's standard streams: `BBSET key=value` (game settings) and
`BBSET launcher:key=value` (the launcher's own options the menu shows: fullscreen, display,
present_mode, fps_mode, fps_limit, metal_hud, draw_pipe, readbacks, preupload, renderer). The game
reads them with `read(2)` on fd 0 (a thread blocked in `fgets` held stdin's lock and froze the
in-game restart's `fflush(NULL)`). Launcher options reach the game as environment variables and
are exported again before an in-game restart. Fullscreen applies at once.

## Recompiled CPU code

Built locally from the maintainer's dump (`runtime/recomp/README.md`: the scan, then
`tools/recomp/recomp.sh --file out/recomp/all.txt`, 11.6 minutes on 12 threads, a 392 MB
library). It stays in the recompiler's ignored `out/`: no generated game code in Git. Loaded with
`BB_RECOMP_LIB=$PWD/recomp/out/recomp/librecomp.dylib`; the launcher does not offer it yet (a
"CPU: Translator / Recompiled" option is a candidate). Its speed (R3) is the CPU side's open item.

## Test helpers

- `runtime/tools/test_run.sh NAME [VAR=...]`: copied save; the test copy of the settings is
  `runtime/out/test-user/bbport.ini` (keep `fps_size=big`, `show_fps=1` there for tests).
- Test games run as background-only apps (`mac_bench.sh` sets `SDL_MAC_BACKGROUND_APP=1`): they
  never become the active app, so Cmd+Q and focus behave unlike a launcher game. For a test the
  maintainer plays in, pass `BB_BENCH_FOREGROUND=1`.
- `runtime/tools/grab.sh [--screen] NAME`: the game's frame (or the window with the menu and
  counter). The frame dump path swaps red and blue; compare like with like.
- Scripted menu keys: `BB_MENU_KEYS_FILE=$PWD/out/menu.keys`, tokens like `r1 r1 down enter`;
  `touch out/menu.trigger` opens or closes the menu.
- `BB_RENDER_RES=WxH` forces a scene size (set `BB_DMEM_MB` with it: the formula runs only for
  presets).
- Swap filled to 5–7 GB during long sessions of test runs; slow boots and CoreAudio failures
  followed. Restart the Mac before a batch of measurements.

## Other open items

From the [roadmap](ROADMAP.md): the frame-rate A/B of the crash fixes, pale blood decals and the
noisy dog, the DingDong order, the texture budget, the draw-list lock check, Laurence's cinematic,
online, frame-rate hooks, background shader compilation, and release notes for the next release.
CI: the runtime's Linux and macOS workflows run on every push and cancel older runs; wait for one
before pushing again when its result matters.
