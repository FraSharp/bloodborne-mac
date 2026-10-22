# Status and where to continue

[← Documentation](README.md)

What development main has, what is open, and how to pick each thread up. Updated 2026-10-22.
The plan as a checklist is the [roadmap](ROADMAP.md).

## Releases

| Version | Highlights |
|---|---|
| 0.8.2 | High-resolution character lighting fixed after texture collection |
| 0.8.1 | GX worker crash fixed; MetalFX option; tessellation shader and recurring shader-cache rebuild fixed |
| 0.8.0 | Motion-vector crash fixed; settings shared with the in-game menu; outputs above 1080p; the experimental Metal renderer; FPS counter sizes; memory estimate; trophy notices only over the game |
| 0.7.0 | Stretched geometry fixed; local trophies |
| 0.6.0 | Profiles and saves; the opening-video crash fixed |

Imported bbport compatibility: 0.51, plus parts of 0.6 (below).

## On main

| Area | State |
|---|---|
| bbport 0.6 | Ported: renderer fixes, the present's wait, frame rate through hooks (no measurable cost; F3 for 30 FPS), Laurence's cinematic fixes, live effects, aspect ratios, keyboard and mouse. Next: online ([roadmap](ROADMAP.md#3-bbport-06-before-the-next-release)) |
| Hooks in the game's code | bbport's `InstallGuestCodeHook` interface on bbcpu: a stub `int3; replaced instructions; jmp back`, every register available to the hook |
| Metal renderer | The frame draws through Metal behind Advanced → Renderer (65.5/61.7 against 58.0/58.1 FPS on MoltenVK); it runs with the recompiled library. The repeatable native-1080p GX worker crash is fixed. MetalFX is an optional upscaler on either renderer |
| High-resolution character lighting | 0.8.2 keeps GPU-written images whose contents cannot safely be downloaded. Native 1440p clothing highlights returned on Metal and MoltenVK in copied-save runs. On main they are freed again over the critical memory mark (memory before lighting); native 1440p on the 18 GB M3 Pro stays about 2.4 GB below it |
| Trophy notifications | The game draws notices in its ImGui overlay after a persisted unlock; the launcher imports and lists unlocked trophies |
| Save editor | The launcher previews characters and edits offensive attributes, Blood Echoes and Insight in a backed-up, staged save set; level follows the attributes and edited saves cannot earn new trophies. Vitality and Endurance remain read-only pending derived-value handling |
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

**Metal renderer, next.** The
[render adapter](https://github.com/bloodborne-native/bloodborne-runtime/blob/main/docs/RENDER_ADAPTER.md)
is approved: the renderer moves onto the project's own GPU interface (steps A0–A6, Vulkan
backend), then a Metal backend creates every resource in Metal and MoltenVK leaves the macOS
build (M1–M4). A0 (the adapter's device) and A1 (its own formats and pipeline state) are done; next: A2,
resources through the adapter. Shaders ahead of time follow (N2). The fork we adapt from is
[Wooloomooloo2/bloodborne_mac_port](https://github.com/Wooloomooloo2/bloodborne_mac_port)
(we took `0b50589` and `78b59f5`; its "M2" `3ee456f` creates resources in Metal).

**Recompiled code speed (R3).** The library runs the whole game but takes 20–30% more CPU than
the translator. Candidates are listed in bloodborne-recomp's CLAUDE.md. The launcher does not
offer it yet (a "CPU: Translator / Recompiled" option is a candidate).

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
- Versions: the app and the launcher.

## Test notes

- Test games are background-only apps (`SDL_MAC_BACKGROUND_APP=1`): they never become the active
  app, so focus and Cmd+Q behave unlike a launcher game. `BB_BENCH_FOREGROUND=1` for a test the
  maintainer plays in.
- The runtime's macOS CI runs on every push and cancels older runs; wait for a run whose result
  matters before pushing again. Linux CI is started by hand for now, while the work is on macOS.
