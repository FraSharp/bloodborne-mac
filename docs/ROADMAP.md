# Roadmap

[← Documentation](README.md)

What we plan to implement next, in order. Ticked items say where they landed. Sources: bbport
0.6 ([deadinside28/bloodborne_pc](https://github.com/deadinside28/bloodborne_pc) `8185b88`,
reviewed 2026-10-19) and the Windows fork
([Supermedo/bloodborne_pc](https://github.com/Supermedo/bloodborne_pc) `de2e38a` 1.9.2, reviewed
2026-10-19 from `e5d04e2`). Code taken from them is credited in the same commit (CREDITS, the
wiki, the commit message, a code comment) and recorded in the runtime's
`docs/upstream/RENDERER_PORTS.md`.

## 1. Small fixes (runtime)

- [ ] **Thread records below 40 bits** (bbport 0.6). The game packs thread handles into 40-bit
  fields; ours come from `calloc` (about `0x6000_0000_0000` on macOS), so the game's lock never
  matches its owner: a possible hang at lamp travel.
- [ ] **Blur-kernel assertion `0xa0020007`** logged and ignored at its two known sites (bbport 0.6).
- [ ] **Larger GX per-frame command heap** patch, against the crash at `0x2199310` (bbport 0.6).
- [ ] **A stale texture format** no longer stops the game (fork `3e3b760`, parsifal295): our
  watch-list assertions `data_format=6/num_format=1` and `15/4`.
- [ ] **A garbage PM4 header** drops the rest of that command buffer instead of aborting (fork
  `c07f0ff`).
- [ ] **A null vertex-buffer table** skips the draw (fork `2c4ddeb`; bbport 0.6 "crash 139").
- [ ] **A flip IRQ ahead of its label** waits briefly instead of stopping (fork `76f5b5f`, from Awaken).
- [ ] Copied-save run with lamp travel; release notes.

## 2. GPU crash with character motion vectors

- [ ] Reproduce at the boss fight with Metal API validation and enhanced command-buffer errors
  to name the invalid resource.
- [ ] Fix; turn motion vectors back on in the recommendation. The image gets much better for a
  small frame-rate cost.

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

## 6. Launcher and tooling

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
