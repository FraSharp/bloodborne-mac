# Status and where to continue

[← Documentation](README.md)

What development main has, what is open, and how to pick each thread up. Updated 2026-10-20.
The plan as a checklist is the [roadmap](ROADMAP.md).

## Releases

| Version | Highlights |
|---|---|
| 0.8.0 (prepared, not tagged) | Motion-vector crash fixed; settings shared with the in-game menu; outputs above 1080p; the experimental Metal renderer; FPS counter sizes; memory estimate; trophy notices only over the game |
| 0.7.0 | Stretched geometry fixed; local trophies |
| 0.6.0 | Profiles and saves; the opening-video crash fixed |

Imported bbport compatibility: 0.51, plus parts of 0.6 (below).

## On main, not released

| Area | State |
|---|---|
| bbport 0.6 | Ported: renderer fixes, the present's wait, frame rate through hooks (no measurable cost; F3 for 30 FPS), Laurence's cinematic fixes, live effects with a new Bloom switch. Next: aspect ratios, keyboard and mouse, online ([roadmap](ROADMAP.md#3-bbport-06-before-the-next-release)) |
| Hooks in the game's code | bbport's `InstallGuestCodeHook` interface on bbcpu: a stub `int3; replaced instructions; jmp back`, every register available to the hook |
| Metal renderer | The frame draws through Metal behind Advanced → Renderer (65.5/61.7 against 58.0/58.1 FPS on MoltenVK); a full play session was stable; with the recompiled library it runs too |
| Docs | One English set per repository; wikis mirror them |

## Open threads

**Before 0.8.0.** Physics check of the frame-rate hooks in play (running above 90 FPS, cloth,
Laurence's cinematic; needs a save near it); then the rest of the 0.6 port as the maintainer
decides; update the release notes, rerun the release tests, tag.

**Characters drawn black above about 3.5 million scene pixels.** Bisected between 3.45 and 3.67
million pixels; the same with or without FSR, at 1440p or 4K, with more memory, and on the Metal
renderer. Left: a buffer the game sizes for 1080p, or MoltenVK's resources. Creating resources in
Metal decides it; a PC report at 1440p native would too.

**Metal renderer, next.** Resources created in Metal (images, views, samplers, buffers, the
guest pool), each behind a switch and measured; then MoltenVK can be left out. MetalFX as an
upscaler. Shaders ahead of time. The fork we adapt from is
[Wooloomooloo2/bloodborne_mac_port](https://github.com/Wooloomooloo2/bloodborne_mac_port)
(we took `0b50589` and `78b59f5`; its "M2" `3ee456f` creates resources in Metal).

**Recompiled code speed (R3).** The library runs the whole game but takes 20–30% more CPU than
the translator. Candidates are listed in bloodborne-recomp's CLAUDE.md. The launcher does not
offer it yet (a "CPU: Translator / Recompiled" option is a candidate).

**Opening video.** A short white flash in about half the openings; cause unknown. Watch list of
rare assertions: the runtime's [stability notes](https://github.com/bloodborne-native/bloodborne-runtime/blob/main/docs/STABILITY.md).

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
- The notification helper's debug build loads its page from the launcher's dev server (port
  5173).
- The runtime's Linux and macOS CI run on every push and cancel older runs; wait for a run whose
  result matters before pushing again.
