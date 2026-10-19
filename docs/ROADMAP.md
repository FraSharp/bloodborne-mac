# Roadmap

[← Documentation](README.md)

What we plan to implement next, in order. Ticked items say where they landed. Sources: bbport
0.6 ([deadinside28/bloodborne_pc](https://github.com/deadinside28/bloodborne_pc) `8185b88`,
reviewed 2026-10-19) and the Windows fork
([Supermedo/bloodborne_pc](https://github.com/Supermedo/bloodborne_pc) `de2e38a` 1.9.2, reviewed
2026-10-19 from `e5d04e2`), and the macOS fork
([Wooloomooloo2/bloodborne_mac_port](https://github.com/Wooloomooloo2/bloodborne_mac_port)
`308992e` / `metal-native` `ff830e6`, reviewed 2026-10-19). **Performance changes from any of them
are adopted only after an A/B on our own build** (same backup, route and settings, alternating
runs); their numbers come from other machines and architectures. Code taken from them is credited in the same commit (CREDITS, the
wiki, the commit message, a code comment) and recorded in the runtime's
`docs/upstream/RENDERER_PORTS.md`.

## 1. Small fixes (runtime)

Landed in runtime `63f043a` (2026-10-19); each fix logs when it acts.

- [x] ~~Thread records below 40 bits~~ (bbport 0.6): already handled here, the runtime's
  allocations come from its own heap below 1 TiB (`runtime_heap.h`).
- [x] **Blur-kernel assertion `0xa0020007`** logged and ignored at its two known sites (bbport 0.6).
- [x] **Larger GX per-frame command heap** patch, against the crash at `0x2199310` (bbport 0.6);
  on by default, `BB_GX_HEAP=0` turns it off.
- [x] **A stale texture format** no longer stops the game (fork `3e3b760`, parsifal295): also our
  watch-list assertions `data_format=6/num_format=1` and `15/4`.
- [x] **A garbage PM4 header** drops the rest of that command buffer instead of aborting (fork
  `c07f0ff`).
- [x] **A null vertex-buffer table** skips the draw (fork `2c4ddeb`; bbport 0.6 "crash 139").
- [x] **A flip IRQ ahead of its label** waits briefly instead of stopping (fork `76f5b5f`, from Awaken).
- [x] Two copied-save playtests with lamp travel and fights: no fault, none of the fallbacks fired.
- [ ] Release notes (next release).

## 2. GPU crash with character motion vectors

- [x] Reproduced with Metal API validation from the pre-boss backup: Metal names objects
  "destroyed while still required to be alive by the command buffer" (a 64 MiB detiler staging
  buffer, texture-cache images and views).
- [x] **Fixed** in runtime `57fba4f` (2026-10-19): removed residency-set objects retained until
  the submission open at their removal completes; texture-cache deletions one submission later
  (draw pipeline); large staging buffers kept (MoltenVK's argument buffers referenced a trimmed
  one; turning argument buffers off cost ~85% FPS). The pre-boss backup's boss was won; a
  20-minute launcher session had no crash at 50–65 FPS.
- [ ] Frame-rate A/B of the three changes (expected nil).
- [ ] Next release: notes, and motion vectors recommended again (the image gets much better for
  a small frame-rate cost).
- [ ] In-game menu values out of sync with the actual settings (reported 2026-10-19; which
  values to be confirmed).

## 3. Online (bbport 0.6's module)

- [ ] Dependencies in `build-deps.sh` (arm64, self-contained in the app): Protobuf with Abseil,
  nlohmann_json, OpenSSL, miniupnpc, epoll-shim.
- [ ] Port 0.6's `libbbnet20` (shadPS4 0.20 network, NP and shadNet code) as a `.dylib`.
- [ ] Seamless Hunt pool and BBSC seamless co-op; its game hooks as bbcpu trap handlers.
- [ ] The Hunter's Dream pool with Discord sign-in.
- [ ] Launcher Online page: on/off, pool, Seamless Hunt account, Discord sign-in.
- [ ] Decision (maintainer): may a save marked as edited go online? Trophies stay local either way.
- [ ] Tests with real accounts (messages, bloodstains, bells solo; co-op with a second player).

## 4. Renderer and game fixes (medium)

- [ ] **Laurence's cinematic above 30 FPS** (bbport 0.6): 512 MiB of extra direct memory for the
  render resource cache, and the job-slot and cache hooks as trap handlers. Needs a save near
  the cutscene.
- [ ] **Draws without a pixel shader** no longer take the previous draw's fragment settings from
  the pipeline cache (bbport 0.6).
- [ ] **Push constants after the pass begins** (bbport 0.6 flicker fix; no effect on MoltenVK,
  correct for the Vulkan backend on Linux).
- [ ] **Mods:** more folder layouts load, and folders that do not are named (fork `dd2314e`).
- [ ] **An external FPS patch** replaces the built-in preset (fork `8042500`).

## 5. Gameplay and input features (each its own decision)

- [ ] **Frame rate through hooks** (bbport 0.6): physics timers ran 6–7× fast at high frame
  rates and running fell to walking above ~90 FPS. 48 hook sites, traps under bbcpu: measure
  their CPU cost first.
- [ ] **Keyboard and mouse:** Dark Souls III layout, smooth stick ramp, mouse camera, menu
  pointer, key chords (bbport 0.6; the fork's emurphy04 PR #79).
- [ ] **Button prompts** for keyboard and Xbox pads (both).
- [ ] **Live effect switching:** SSAO, motion blur, depth of field, chromatic aberration (bbport 0.6).
- [ ] **Aspect ratios** 21:9 and 32:9 through hooks (bbport 0.6; the fork's PR #70).
- [ ] **Field of view; mute in the background** (fork `b75e811`).

## 6. From the Wooloomooloo2 macOS fork (each measured on our build first)

- [ ] **MoltenVK without Metal argument buffers** (`MVK_CONFIG_USE_METAL_ARGUMENT_BUFFERS=0`):
  +13–16% FPS there. A/B uncapped and capped.
- [ ] **MoltenVK prefilled command buffers** (`MVK_CONFIG_PREFILL_METAL_COMMAND_BUFFERS=2`):
  about 6× fewer late frames there. A/B frame pacing (p90, late frames); check MetalFX and FSR.
- [ ] **DingDong order:** queue the game's compute work before waiting for the previous
  submission (black loading screen there). Correctness: loads with the copied save.
- [ ] **Texture budget without the game's memory pool** (their #19): our collector counts the
  6 GB pool as texture use and never evicts. Check Metal's working-set limit on 16–18 GB Macs.
- [ ] **Draw-list task lock** (stuck loading screen): check whether our command-buffer guard
  covers the render thread's draw-list task as a whole.
- [ ] **Character-name entry in fullscreen** (IME text box, Noel Miller): check ours first.
- [ ] Reference for the native renderer (R5): their Metal renderer's untracked buffers, pipeline
  archive, MetalFX/FSR on Metal. Ideas and measurements, not a merge (ours stays multiplatform).
- [ ] Later: DiAvisoo/bbport-mac-optimized and Huax-1839/bloodborne-macos, which they cite.

## 7. Visual bugs (older, reported 2026-10-19)

- [ ] **Blood decals** on floors and walls are drawn as pale speckles with bright rims instead of
  dark red pools. Also the stains the game restores from the save on reload: the problem is in
  drawing the stains (texture or blend), not in the hit effect.
- [ ] **An enemy's body drawn as colour noise** (a dog, after it attacked the player): probably
  the same blood/wet effect on characters.

## 8. Launcher and tooling

- [ ] **Keep test progress between test runs** (`test_run.sh`): an option to reuse the scratch
  save copy instead of copying the player's save again.
- [ ] **Background shader compilation:** a missing pipeline compiles on a worker and its draw is
  skipped until ready (no hitches the first time an area is seen), behind a setting.

## Not taken

- Online for shadPS4's public server (0.51's module): the server accepts only shadPS4's own
  builds since 2026-10-12.
- NVIDIA, Intel, Polaris, Steam Deck, AppImage and Windows fixes; DLSS, frame generation,
  FSR 4.1.1; `VK_EXT_device_fault` (MoltenVK lacks it).
- bbport's new memory model and the fork's VRAM budget fixes: we use the unified pool.
- Fork `9566a1d` and `5012c6f` (stretched polygons): bugs of their newer shadPS4 base; our push
  block and index binding do not have them. The fork's barrier memo (`08cd804`): we have it.
