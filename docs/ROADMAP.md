# Roadmap

[← Documentation](README.md)

What we plan to implement next, in order. Where things stand: [Status](STATUS.md). Ticked items say where they landed. Sources: bbport
0.6 ([deadinside28/bloodborne_pc](https://github.com/deadinside28/bloodborne_pc) `8185b88`,
reviewed 2026-10-19) and the Windows fork
([Supermedo/bloodborne_pc](https://github.com/Supermedo/bloodborne_pc) `de2e38a` 1.9.2, reviewed
2026-10-19 from `e5d04e2`), and the macOS fork
([Wooloomooloo2/bloodborne_mac_port](https://github.com/Wooloomooloo2/bloodborne_mac_port)
`308992e` / `metal-native` `ff830e6`, reviewed 2026-10-19). **Performance changes from any of them
are adopted only after an A/B on our own build** (same backup, route and settings, alternating
runs); their numbers come from other machines and architectures. Code taken from them is credited in the same commit (CREDITS, the
wiki, the commit message, a code comment) and recorded in the runtime's
`docs/UPSTREAM.md`.

## Save editor (launcher)

- [x] Preview readable characters in each profile's save set: name, level, attributes, Blood
  Echoes, Insight, playtime and journey (launcher `6f6f64a`).
- [x] Edit offensive attributes, Blood Echoes and Insight with a full pre-edit backup, staged save swap, stale-preview
  check and edited-save trophy marker (launcher `6f6f64a`).
- [x] Add Vitality and Endurance with coherent saved HP and stamina values, and a level 544
  Max all action (launcher `1697795`; see `launcher/docs/SAVE_MANAGER.md`).
- [ ] Verify other character fields and inventory one at a time.
- [ ] Import/export complete save sets and manage backup history.

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
- [x] Trophy notifications draw in the game's ImGui overlay after a persisted unlock; the
  launcher only records and lists trophies (runtime and launcher main, 2026-10-22).

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
- [x] 0.8.0 release notes recommend motion vectors again for the sharper moving image at a small
  frame-rate cost.
- [x] In-game menu values out of sync with the actual settings: the launcher keeps the settings
  in its database and the game and launcher exchange changes while it runs (runtime `8cbcf64`,
  launcher `1dc03d8`, 2026-10-20). The menu shows every launcher graphics setting under the same
  tabs (runtime `511b7ac`).

## 3. bbport 0.6 (before the next release)

Every item of bbport 0.6's change list ([CHANGES_0.6.md](https://github.com/deadinside28/bloodborne_pc/blob/master/docs/CHANGES_0.6.md),
`8185b88`, with 0.6-pre1 `72e5c8c`), sorted for our build. 0.6 replaced bbport's renderer with
its own code, and its hook and overlay code calls that renderer, so a merge does not fit (86
conflicts in a trial merge): each feature is ported by hand onto our renderer and bbcpu.

**The hook base.** bbport 0.6 hooks the game's code with x86 stubs and trampolines that save
every register. On macOS bbcpu runs such stubs like the game's code (their pages are guest code
ranges; a call to a host function is a bridged host call). Runtime `Core::InstallGuestCodeHook`
(bbport's interface) is a jump to a stub `int3; the replaced instructions; jmp back`, whose int3
reaches a host handler with every register (bbcpu `bbcpu_trap_state`: flags, MXCSR, YMM).
Functions rewritten while the game runs stay with the translator (`bbcpu_recomp_exclude`).

Renderer and small fixes:

- [x] Push constants after the pass begins (the half-screen/corner frames); a draw without a pixel
  shader no longer takes the previous draw's fragment settings (runtime `8b2aaac`).
- [x] The present waits for its frame at every stage (single black or grey frames; runtime
  `2bdc2f7`).
- [x] Already here: blur-kernel assertion `0xa0020007`, the larger GX command heap, crash 139
  (null resource tables), 40-bit thread handles, command buffers copied at submit
  (`BB_COPY_GPU_BUFFERS`), the save-load `Bad PM4 packet` (command-buffer guard).
- [x] Empty character-creator preview (#178): GPU-written images keep their mip hashes from the
  first upload; a new save's character creator draws the character. Decoder and format asserts
  (#144, #165, #166): already handled (stale formats logged and skipped).
- [x] ~~Draw preparation on a quarter of the hardware threads~~: ours already uses half.

Features:

- [x] **Frame rate through hooks** (`bbport_frame_rate.cpp`): the pacer, the main loop's step and
  48 per-frame values follow the frame's time; the community patches remain with
  `BB_FRAME_HOOKS=0`. The frame rate limit applies live; **F3** toggles a 30 FPS limit
  (runtime `2bdc2f7`). Hooks 66.6/67.8/68.0 FPS at 473/462/480% CPU against the patches'
  65.0/67.3 FPS at 471/455% (60 s holds, Hunter's Dream): no measurable cost.
- [ ] Physics check in play: running speed above 90 FPS, cloth, corpses, Laurence above 30 FPS.
- [x] **Laurence's cinematic above 30 FPS:** failed render jobs give their pool slot back; the
  render resource cache gets 512 MiB of port memory past the game's (`BB_DMEM_EXTRA_MB`,
  runtime `2bdc2f7`).
  [ ] Checked at the cinematic (needs a save there).
- [x] **Effects switched live:** chromatic aberration, depth of field, motion blur, SSAO, the
  game's anti-aliasing, dynamic-light shadows; SSAO only where the game has its target (the
  crash after selecting an item); SSR stays a patch at start (it sizes a target).
  Bloom is a new live setting in the launcher and the menu (20 languages).
- [x] **Aspect ratios** 4:3, 16:10, 21:9, 32:9 and Auto (camera, HUD at the edges, full-screen
  fills, markers), separate from the resolution, in the launcher and the menu; 16:9 by default.
  Checked at 16:10, 21:9 (with the game's menu) and 16:9 (no cost). The blur-kernel clamp too.
- [x] **Keyboard and mouse:** mouse camera without the stick's limits, a menu pointer, a Dark Souls
  III layout with chords, the movement-key ramp, the port's cursor; the mouse-capture jump and the
  Escape double toggle fixed. The launcher's Controls page shows the new defaults (Run, Dodge).
  [x] Button prompts for the device in use, on Metal and MoltenVK (runtime `bcf71cc`); [x] chords
  with Shift, Ctrl or Alt in the input capture (runtime `bcf71cc`); [x] keyboard hints and the
  mouse in the in-game menu and its on-screen keyboard (runtime `6dc0320`).
- [ ] **Online (for 0.9.0 final; not in the release candidate):** Seamless Hunt and The Hunter's Dream on shadPS4 0.20's network code
  (`libbbnet20`; The Hunter's Dream part is GPL-3.0-or-later, so the module is too). Dependencies
  in `runtime/deps/packages.cmake` (Protobuf with Abseil, nlohmann_json, OpenSSL, miniupnpc,
  epoll-shim), for Linux from shell.nix; the
  launcher's Online page. Decided (maintainer, 2026-10-26): a save marked as edited plays offline
  only; trophies stay local either way. The password is saved only after the player accepts a
  warning that it is stored unencrypted; otherwise the launcher asks for it at each launch.
  Tests with real accounts on both pools.
- [ ] **Seamless co-op (BBSC):** not supported for now (maintainer, 2026-10-26). BBSC's code is
  built on the game's internals (addresses, structures, decompiled behaviour), which no repository
  here may carry. The launcher's Online page says so. Planned depending on further development and
  talks with BBSC's developer: for example a separately built and hosted module that the runtime
  loads through a plugin interface, accepting only tested versions, on Seamless Hunt only.
- [ ] Real occlusion queries counted at the game's resolution (part of their new memory model:
  check against ours).

Not for our build: the new memory model and its NVIDIA/Intel/VRAM fixes (we use the unified
pool), NVIDIA startup and RIP 0, Debian/Steam Deck/AppImage, FSR 4.1.1 assets and its white
picture after loading, RX 580 labels, light-shaft tiling over the bus (discrete GPUs), the GPU
choice for laptops with two GPUs, the old shadNet module (shadPS4's server refuses other builds).

## 4. Other forks' fixes (medium)

- [ ] **Mods:** more folder layouts load, and folders that do not are named (fork `dd2314e`).
- [ ] **An external FPS patch** replaces the built-in preset (fork `8042500`).
- [ ] **Field of view; mute in the background** (fork `b75e811`).

## 5. From the Huax-1839 and Wooloomooloo2 macOS ports (each measured on our build first)

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
- [ ] **Native renderer (R5):** Huax-1839's direct Metal renderer, further developed in
  Wooloomooloo2's 0.5.x Metal port (GPL-2.0-or-later), is adapted into our backend where it fits the
  multiplatform design (an adapter per graphics API): the SPIR-V to MSL compiler and its rect-list,
  tessellation and geometry rewrites, the pipeline cache with a binary archive, the format and
  state tables, FidelityFX on Metal. Credited in the commits that bring the code.
  - [x] Every pipeline builds in Metal too (`BB_METAL_SHADOW=1`, runtime `dfb01fd`): 550
    pipelines, 0 failed.
  - [x] The frame drawn through Metal behind `BB_METAL_FRAME=1` (runtime `1992ecf`): 65.5/61.7 FPS
    against 58.0/58.1 on MoltenVK in two alternating pairs; MoltenVK stays the default.
  - [x] A renderer choice in the launcher and the in-game menu (MoltenVK / Metal, experimental).
  - [x] MetalFX as a macOS upscaler choice with either renderer (runtime PR #2, launcher PR #1;
    1080p Balanced on an M3 Pro: 23.9 ms median against FSR 3.1's 21.3 ms in one copied-save
    scene). Its name and render resolution appear in the big FPS overlay.
  - [x] The [render adapter](https://github.com/bloodborne-native/bloodborne-runtime/blob/main/docs/RENDER_ADAPTER.md)
    specified and approved: the project's own GPU interface, with Vulkan and Metal backends,
    replacing the Metal interception layer.
  - [x] Adapter A0–A6: the renderer moved onto it with the Vulkan backend, each step measured
    (runtime `d6e8199`).
  - [ ] Adapter M1–M4: Metal resources, commands, native startup and synchronization are
    implemented; the native path needs no Vulkan loader or MoltenVK. MoltenVK stays selectable
    as a fallback until M4 is accepted. On an M3 Pro, one base-first A/B pair measured 34.4
    against 33.2 FPS (median 28.2 ms both; p90 32.1 against 35.4 ms). M1/M2 capability
    comparisons and the maintainer's release-candidate play session remain. The Linux Vulkan
    backend built and passed its workflow tests (runtime `8982059`, workflow `40314805527`).
    An explicit native 1080p override no longer enters the scaled UI path (runtime `8982059`);
    copied-save frames were clean with the override on Metal and MoltenVK and at normal native
    1440p on Metal.
  - [x] Pipelines created in Metal own their shaders (runtime `8c7fa5b`, `8f6e731`): with the
    Metal frame the device builds Metal pipelines only, holding their shaders, without MoltenVK
    modules or pipelines. The compiled forms stay for the session (the session's Metal
    pipelines point into them, and the pipeline cache keeps every program anyway).
- [ ] Later: review other ideas from DiAvisoo/bbport-mac-optimized separately.
- [x] MetalFX encodes on the native Metal frame's command buffer and textures without the
  older export bridge. One M3 Pro copied-save pair measured 34.5 FPS against 30.8 through the
  bridge; scene drift limits precision. MetalFX Balanced also passed a validated gameplay run
  with a correct frame grab.

## 6. Visual bugs

- [ ] **Blood on already killed enemies after a save reload** can be pale with bright edges
  instead of dark red. The cause has not been isolated.
- [ ] **The camera after in-game cutscenes** sometimes starts in front of the character instead of
  behind (e.g. waking at the table in the clinic after the character creation). It happens on
  builds before the render adapter's M2 too; the cause has not been isolated.

## 7. Launcher and tooling

- [x] **Outputs above 1080p start again** (runtime `74c556e`): the pool is imported in
  overlapping windows and direct memory follows the scene size; the Graphics page and the menu
  estimate memory against the Mac's.
- [x] **Character lighting above about 3.5 million scene pixels:** the texture collector kept
  GPU-written images whose contents could not safely be downloaded. Native 1440p clothing
  highlights returned on Metal and MoltenVK with normal collection active (runtime `b2ff9cd`).
  Over the critical memory mark they are freed again, so memory stays bounded (runtime `ab31a4c`).
- [x] **Trophy notices only over the game** (launcher `6f626d7`), sent without waiting for SDL's
  focus (runtime `77bcc30`), activation handed back to the game (launcher `4b9a90e`).

- [x] **Keep test progress between test runs:** `KEEP_SAVE=1` (`test_run.sh`).
- [x] **Tests for the in-game trophy notices** (queue, and only new eligible unlocks; runtime
  `2425cff`) and **CPU tests in bloodborne-recomp's CI** on Apple Silicon.
- [x] **Native 1080p GX worker crash:** live dynamic shadows keep the game's disabled state in a
  secondary render context without a shadow target (runtime `e8e14a3`). Copied-save tests passed
  on both renderers, including a five-minute Metal run with left turns.
- [x] **Recurring shader-cache rebuild:** save only successful pipeline keys (runtime `e8e14a3`),
  emit each tessellation output location once (runtime PR #3), and rebuild older shader binaries
  once (`0e940e9`). A warm launch reused the cache without the damaged-entry warning.
- [ ] **Background shader compilation:** a missing pipeline compiles on a worker and its draw is
  skipped until ready (no hitches the first time an area is seen), behind a setting.

## 8. After 0.9.0 final

Decided 2026-10-27, in this order.

- [ ] **The recompiled library from the launcher.** A "CPU: Translated / Recompiled" choice;
  Translated (bbcpu's JIT) stays the default, and Recompiled can be chosen once the library is
  built. The launcher explains it plainly: the game's code compiled for this Mac once, from the
  player's own copy, instead of translated while playing; less CPU time (about 14% at the 1st
  Floor Sickroom) at about the same frame rate, since frames on the Mac are bound by rendering.
  It does not call it native: the compiled code still keeps x86 behaviour (memory ordering, flags,
  registers in memory).
  - The build: prepare (extract the executable, scan, generate the C; seconds), compile (383
    files, about 12 minutes on an M3 Pro), link, verify. A progress bar counts the files compiled;
    an interrupted build resumes with the files left.
  - The compiler: the launcher downloads a trimmed LLVM toolchain (clang, `ld64.lld`, clang's
    headers; from an official LLVM release, Apache-2.0 with LLVM exception), hosted as a release
    asset and checked against a SHA-256 pinned in the launcher, and deletes it after the build.
    The library is built freestanding (`-ffreestanding -fno-stack-protector`, `-undefined
    dynamic_lookup`): it needs no macOS SDK, since its few unresolved helpers come from the game
    process. First step: a prototype build with only that toolchain, run in the game, to measure
    the download and build time.
  - The library and generated C stay in the player's data folder and are never uploaded (they
    are game code). The launcher records the recompiler version and the executable's hash; a
    stale or missing library falls back to Translated with the reason shown.
- [ ] **R4 for the render boundary, then N6.** Names, objects and call sites for the engine's
  render functions first (not every function), so the native renderer can take the engine's
  draws instead of decoding PS4 command buffers: what limits the frame rate on the Mac.
  Synchronization primitives next, signatures for the hottest functions after.
- [ ] **The generator's CPU work, alongside:** flags only where they are read; a function's own
  stack frame as host locals when its address never escapes; memory ordering kept only for the
  engine's synchronization (from R4's names). These matter most on CPUs weaker than the Mac's.
- N5's acceptance (M1/M2 capability comparisons, the maintainer's release-candidate session)
  stays open alongside, as in section 5.

## 9. Other platforms: iOS

The proof of concept (2026-10-26/27, iPhone 17 Pro Max, free Apple ID): the game plays at 23 FPS at
960×540 with all effects on, bound by the CPU (no JIT on iOS: what the recompiled library does not
cover is interpreted). Branches `ios-poc` in bloodborne-runtime and bloodborne-recomp, write-up in
the runtime's [`docs/IOS_POC.md`](https://github.com/bloodborne-native/bloodborne-runtime/blob/ios-poc/docs/IOS_POC.md).
Organized as [Architecture](ARCHITECTURE.md) says ("Where code lives"):

- [ ] **The general fixes to `main`, each measured on the Mac:** the game's mutex as host code,
  natives called without the translator (recomp), the jump-table recognition once its generator
  bug is fixed, bbcpu's no-JIT build option, the UI scale.
- [ ] **The iOS platform code into the runtime's platform layer,** behind an `ios-arm64` CMake
  preset (after the CMake build, runtime PR #4) and a compile-only CI job: the compact memory layout
  as a named mode (Android will need it too), the system call and Metal format differences.
- [ ] **The runtime as a library** with a small C API, `bb-probe` a thin program around it, and
  what `run.sh` and the Python scripts do moved into the runtime or the launcher. The Mac gains
  too (no bundled bash or Python).
- [ ] **bloodborne-ios:** the app shell, the build, signing and install scripts, touch controls;
  private while it is a proof of concept (sideloading only). Created 2026-10-27 with the PoC's
  shell and scripts (runtime `ios-poc` keeps the iOS builds of its own parts; no FSR on iOS,
  runtime `BB_FSR`). Next: the launcher as its interface (Tauri on iOS, the game started in the
  same process), game files and saves on the phone, touch controls (after Bloodborne-Android's
  on-screen controller, GPL-2.0).
- [ ] **Toward 30 FPS on the phone:** thread QoS (the game's main and render threads on the fast
  cores), the PS4's own libraries through the recompiler, other spinning waits, MetalFX at a lower
  render resolution.

## Not taken

- Online for shadPS4's public server (0.51's module): the server accepts only shadPS4's own
  builds since 2026-10-12.
- NVIDIA, Intel, Polaris, Steam Deck, AppImage and Windows fixes; DLSS, frame generation,
  FSR 4.1.1; `VK_EXT_device_fault` (MoltenVK lacks it).
- bbport's new memory model and the fork's VRAM budget fixes: we use the unified pool.
- Fork `9566a1d` and `5012c6f` (stretched polygons): bugs of their newer shadPS4 base; our push
  block and index binding do not have them. The fork's barrier memo (`08cd804`): we have it.
