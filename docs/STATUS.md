# Status and where to continue

[← Documentation](README.md)

What development main has, what is open, and how to pick each thread up. Updated 2026-10-26.
The plan as a checklist is the [roadmap](ROADMAP.md).

## Releases

| Version | Highlights |
|---|---|
| 0.8.3 | Mods and Patches pages fixed; character editing in every language; optional FSR 4.1.1 on Metal; trophy notices drawn by the game; instanced tessellated draws on Metal |
| 0.8.2 | High-resolution character lighting fixed after texture collection |
| 0.8.1 | GX worker crash fixed; MetalFX option; tessellation shader and recurring shader-cache rebuild fixed |
| 0.8.0 | Motion-vector crash fixed; settings shared with the in-game menu; outputs above 1080p; the experimental Metal renderer; FPS counter sizes; memory estimate; trophy notices only over the game |
| 0.7.0 | Stretched geometry fixed; local trophies |
| 0.6.0 | Profiles and saves; the opening-video crash fixed |

Imported bbport compatibility: 0.51, plus parts of 0.6 (below).

## On main

| Area | State |
|---|---|
| bbport 0.6 | Ported: renderer fixes, the present's wait, frame rate through hooks (no measurable cost; F3 for 30 FPS), Laurence's cinematic fixes, live effects, aspect ratios, keyboard and mouse, button prompts for the device in use. Next: online for 0.9.0 final, without seamless co-op (BBSC) ([roadmap](ROADMAP.md#3-bbport-06-before-the-next-release)) |
| Hooks in the game's code | bbport's `InstallGuestCodeHook` interface on bbcpu: a stub `int3; replaced instructions; jmp back`, every register available to the hook |
| Metal renderer | Native Metal is the default on Apple Silicon; MoltenVK remains selectable until M4 acceptance. The native path links or maps neither Vulkan nor MoltenVK. In one copied-save A/B pair it measured 34.4 FPS versus 33.2 on main, with the same 28.2 ms median and 32.1 versus 35.4 ms p90. The maintainer's play sessions passed (2026-10-26); acceptance waits for players' reports on the 0.9.0 release candidate, including M1/M2 capability comparisons |
| FSR 4.1.1 on Metal | AMD's neural upscaler in Metal on Apple Silicon (runtime #1, from fsr4-native-macos), offered when the Mac can run it and the player has added AMD's model files from their own DLL. M3 Pro, 1080p Balanced: 4.2–4.8 ms of GPU time a frame, a few FPS below FSR 3.1 |
| High-resolution character lighting | 0.8.2 keeps GPU-written images whose contents cannot safely be downloaded. Native 1440p clothing highlights returned on Metal and MoltenVK in copied-save runs. On main they are freed again over the critical memory mark (memory before lighting); native 1440p on the 18 GB M3 Pro stays about 2.4 GB below it |
| Trophy notifications | The game draws notices in its ImGui overlay after a persisted unlock; the launcher imports and lists unlocked trophies |
| Save editor | The launcher previews characters and edits all six attributes, Blood Echoes and Insight in a backed-up, staged save set; level and saved HP or stamina follow attribute changes. Max all reaches level 544. Edited saves cannot earn new trophies |
| Launcher | Platform-neutral: system differences in `platform.rs` (macOS, Linux, Windows; CI on all three), texts that never name a system, a layout from phone width up. The Online page is in, hidden until the online module ships |
| Docs | One English set per repository; wikis mirror them |

## Open threads

**After 0.8.2.** The repeatable GX worker crash on Metal and MoltenVK was the live dynamic-shadow
setting re-enabling shadows in a secondary context without a shadow target. A separate null guest
virtual call seen once on Metal has not recurred. A
[GXRenderThread null read in Cathedral Ward](https://github.com/bloodborne-native/bloodborne-mac/issues/3)
has a different signature and is not confirmed fixed; a nearby save is needed to reproduce it.
The [FSR 3.1 dark picture on an M5](https://github.com/bloodborne-native/bloodborne-mac/issues/2)
is also unconfirmed: the reported resolution and upscaler settings rendered normally on this M3
Pro in both 0.8.0 and current main. The reporter's check on 0.8.2 is needed.
Check the frame-rate hooks in play (running above 90 FPS, cloth, Laurence's cinematic; needs a
save near it).

**Metal renderer, M4 pending acceptance.** The
[render adapter](https://github.com/bloodborne-native/bloodborne-runtime/blob/main/docs/RENDER_ADAPTER.md)
runs Metal natively on macOS without linking or mapping the Vulkan loader or MoltenVK. The
Metal backend now owns the device, queue, resources, synchronization, submissions and MetalFX.
The MoltenVK renderer remains in the app as a fallback and loads the Vulkan driver only when
selected. Linux keeps its Vulkan backend. In one copied-save A/B pair (native 1080p, upscaler
off), the new path measured 34.4 FPS versus 33.2 on main; median 28.2 ms both, p90 32.1 versus
35.4 ms. A separate save and a MetalFX Balanced run reached gameplay without faults. The
manual Linux workflow [run 40314805527](https://github.com/bloodborne-native/bloodborne-runtime/actions/runs/40314805527)
built the Vulkan backend and passed its tests. An explicit native 1080p test override had
selected the scaled UI path and exposed the item atlas; the renderer now treats that value as
native. Copied-save frames were clean with the override on Metal and MoltenVK, and at normal
native 1440p on Metal. The
capability comparisons on M1 and M2 Macs and the maintainer's release-candidate play session
are still required to accept M4.
Shaders ahead of time follow (N2). The shader compiler, rewrites, pipeline cache and format/state
tables came from [Huax-1839/bloodborne-macos](https://github.com/Huax-1839/bloodborne-macos/commit/0f0cf54),
through [Wooloomooloo2/bloodborne_mac_port](https://github.com/Wooloomooloo2/bloodborne_mac_port)
(we took `0b50589` and `78b59f5`; its "M2" `3ee456f` creates resources in Metal).

**Recompiled code speed (R3, done).** The library runs the whole game with less CPU time than
the translator: 344% of one core against 402% at the 1st Floor Sickroom lamp, 357% against 392%
at the test save's place in Cathedral Ward (bloodborne-recomp #9–#12, 2026-10-25), at the same
frame rate. R3's follow-ups (plain accesses to a function's own frame, the calls still going into
the translator, a 0.5 FPS gap at the Sickroom) are in bloodborne-recomp's docs. The launcher does
not offer the library yet (a "CPU: Translator / Recompiled" option is a candidate).

**Watch list.** A short white flash in the opening video and an enemy's body drawn as colour
noise have not recurred in recent play. Neither has a confirmed fix. Older rare assertions are in
the runtime's [stability notes](https://github.com/bloodborne-native/bloodborne-runtime/blob/main/docs/STABILITY.md).

**Online.** bbport 0.6's module (Seamless Hunt with BBSC co-op, The Hunter's Dream) needs its
dependencies in `deps/`, its hooks on our base, and the maintainer's decision on edited saves.

## Keep in step

- Memory: `run.sh` sizes the game's memory; the launcher (`src/lib/data/memory.ts`) and the
  in-game menu (`MemoryEstimate` in `bbport_overlay.cpp`) estimate it the same way.
- Settings the menu shows: the runtime's `bbport_settings.cpp` and the launcher's
  `settings_store.rs` (`GAME_SYNCED`).
- Versions: the app and the launcher, and the tag of a release. `bash packaging/version.sh X.Y.Z`
  writes the number everywhere and `--check` compares the files (and the tag, in the workflow).

## Test notes

- The build is `bash runtime/build.sh`, and `--test` runs the tests through `ctest`
  (`docs/BUILDING.md`). Five GPU tests (motion-shader, scene-resolution, taa-shader,
  camera-motion, translation-memory) stopped compiling when the code moved under them and are
  listed in `runtime/gpu/CMakeLists.txt` rather than run: repairing them is open work.

- Test games are background-only apps (`SDL_MAC_BACKGROUND_APP=1`): they never become the active
  app, so focus and Cmd+Q behave unlike a launcher game. `BB_BENCH_FOREGROUND=1` for a test the
  maintainer plays in.
- The runtime's macOS CI runs on every push and cancels older runs; wait for a run whose result
  matters before pushing again. Linux CI is started by hand for now, while the work is on macOS.
