# bloodborne-mac

The macOS app of Bloodborne (PS4, CUSA03173 1.09) on Apple Silicon: the launcher, the packaging,
the releases and the player guides. The game itself is the `runtime/` submodule
(bloodborne-runtime), with the CPU layer and recompiler in `runtime/recomp/` (bloodborne-recomp).
Clone with `--recursive`.

## Layout

- `launcher/app/`: the bloodborne-launcher submodule (Tauri: React + Rust,
  `src-tauri/src/main.rs`); its own README has the stack and conventions. 20 languages; settings in `bbport.ini` and `launcher.json` in
  `~/Library/Application Support/bloodborne_mac/` (the app's names stay `bloodborne_mac` so
  players' saves and settings never move).
- `packaging/macos.sh`: `Bloodborne.app` and its DMG in `dist/`, from `runtime/`'s build.
- `.github/workflows/macos.yml`: builds and packages on every push; a `v*` tag publishes a release.
- `docs/guide/`: player guides; `docs/screenshots/` (README pictures).

## Build

```sh
bash runtime/build.sh            # the game (runtime/deps/ the first time: ~1 h)
bash packaging/macos.sh          # the app and the DMG
cd launcher/app && npm run tauri dev   # the launcher against runtime/ (npm run dev: browser preview)
```

## Releases

App versions follow this project's own release scope and compatibility, independently of
bbport's version. bbport numbers record imported compatibility and merge history. Major
versions may be chosen for our own compatibility changes or substantial product milestones;
the maintainer chooses the release number. The app and bundled launcher version stay aligned
so GitHub release notifications compare against the installed app correctly.

1. Bump the version in `launcher/app/package.json`, `package-lock.json` (two places),
   `src-tauri/Cargo.toml`, `src-tauri/Cargo.lock`, `src-tauri/tauri.conf.json`.
2. Run copied-save gameplay (`runtime/tools/test_run.sh`) and the isolated new-save opening
   (`runtime/tools/test_opening_video.sh`) from this build, and the user approves.
3. Commit, `git tag -a vX.Y.Z -m "..."`, push `main` and the tag; the workflow builds the DMG and
   publishes the release. Check the run (`gh run list`) and the release's asset.

Release notes say what changed for players. The README's screenshots come from the game
(`runtime/tools/grab.sh`), in English, never from the user's screen.

## This machine (the user's Mac)

- The game dump: `~/Downloads/PS4/Bloodborne/CUSA03173` (1.09 merged). The player's data:
  `~/Library/Application Support/bloodborne_mac/` (never written by tests: `tools/test_run.sh`).
- The clone is `~/projects/bloodborne/bloodborne-mac` (VS Code workspace:
  `~/projects/bloodborne/bloodborne.code-workspace`). `runtime/deps/` is built there (about an
  hour); its libraries record absolute paths, so a moved or copied `deps/` must be rebuilt
  (`BB_ARCH=arm64 bash runtime/scripts/macos/build-deps.sh` after removing `deps/macos-arm64`).
- Metal System Traces need `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer`.
- **REA** (https://github.com/morluto/rea) is registered as an MCP server for Claude Code, with
  the Ghidra provider (Ghidra 12.1.4, Java 21; `JAVA_HOME` and `GHIDRA_INSTALL_DIR` in
  `~/.zshrc`): decompiling, cross-references and call graphs of the game's code
  (`runtime/recomp/out/eboot.elf`, or `out/eboot.elf` after `runtime/run.sh`). The first
  analysis of the 93 MB executable takes a long time. Its output is decompiled game code: use it
  to understand, never commit it or paste it into docs, issues or wikis.
- An Apple M3 Pro (18 GB): a healthy run in the Hunter's Dream is ~58–62 FPS.

## Where things stand (2026-10-13)

- Releases: v0.7.0 (the stretched-geometry fix and local trophies) follows v0.6.0.
  The imported bbport compatibility level remains 0.51.
- Fixed in 0.5.1: the GPU assertion while loading (`Unimplemented PM4 type 0`; most loads in
  Brazilian Portuguese): the main thread and GXRenderThread wrote one command buffer at once
  (bloodborne-runtime CLAUDE.md, "Command buffers").
- Next priority (2026-10-18): GPU device loss with character motion vectors (object motion) on.
  MoltenVK reports `kIOGPUCommandBufferCallbackErrorInvalidResource` as
  `VK_ERROR_OUT_OF_DEVICE_MEMORY`, then `GpuSignalLoop`/`vk_semaphore.cpp:42` assertions. Seen
  in a boss fight with no setting change (motion on, 31 FPS, 1.6 GB Vulkan memory) and on
  2026-10-15; FSR toggling with motion on is a known trigger. The maintainer wants it fixed:
  motion vectors make the image much better for little frame-rate cost. First step: reproduce
  with Metal API validation to name the invalid resource.
- Known issue: in Yharnam, a black sky with streaks behind some gates and objects popping in (the
  user's report, not investigated): bisect bbport's optimizations with the user watching.
- Fixed (2026-10-18, released in 0.7.0): stretched scenery/vertex explosion and missing walls
  after visiting several areas. MoltenVK drew data from past 4 GiB in the imported 6,080 MiB
  guest pool wrongly; bindings from 3 GiB use a second import of the pool's upper part
  (runtime `BufferCache::pool_upper`, `BB_POOL_SPLIT=0`: off). Found with a bbport-mac branch
  on the same memory model (KosmicKrisp clean, MoltenVK stretched) and draw fingerprints at
  Iosefka's Clinic (data intact, broken draws reading past 4 GiB). Runtime STABILITY has the
  evidence; the earlier FaceGen/synchronization/draw-trace notes there are history.
- bbport 0.51's online module (gpu/bbnet) is not built on macOS (deps/ lacks Protobuf,
  nlohmann_json, OpenSSL): offline play.
- The recompiler (bloodborne-recomp): every function generated and the game runs on them, at the
  translator's frame rate but with 20–30% more CPU time (R3, speed, is next). Status and numbers:
  bloodborne-recomp's wiki, Recompilation-status.
- The native renderer (R5, in bloodborne-runtime `docs/NATIVE_RENDERER.md`): the engine's graphics
  on each platform's own GPU API, multiplatform (Vulkan and Metal backends, never Metal-only).
  N1 is closed: deferred clears are on by default; fixed-quad triangles remain opt-in and native
  tessellation is planned for N5. N4's backend interface is approved; Linux CI passes and the
  Vulkan baseline is measured. The first buffer-resource slice is opt-in; uncapped and capped
  game gates pass in Central Yharnam. N4 is paused after this slice for opening-video stability.
- The opening-video shared-state race is fixed on main: movie frames and render task lists now
  hold one buffer lock across state updates and draws. Ten guarded openings completed (five
  portable, five translated), versus three faults in five alternating controls. The guard is
  on by default; capped gameplay CPU cost was about 0.5%, with no throughput loss in one uncapped
  pair. Released v0.5.1 still has the bug (2/5 faults in the exact-release comparison); the fix
  is included in 0.6.0. Runtime `docs/STABILITY.md` has the evidence and assertion watch list.
- Development opening-video visual issue: four of seven observed openings had one white flash;
  stuttering was also reported. All seven completed without faults/assertions. The cause is not
  established. A playback-clock data race is repaired and passes standalone ThreadSanitizer
  checks. Five subsequent MipFilter assertions include a translated-SRT run; sampler
  provenance and resource lifetime remain under investigation before release. Runtime
  stability docs record the runs and diagnostic limits. Two further pipeline-off openings were
  observed as perfect and completed; their pipeline-on pairs later faulted on the movie audio
  thread with an invalid-mutex panic, including one with the command-buffer probe disabled.
  The second looked perfect before shutdown failed. Thread stop/completion/destruction ordering
  is the next stability target; this is separate from sampler provenance. A further control
  captured main destroying the mutex slot 13.374 ms before the movie audio thread used it;
  playback had looked perfect, with only 36 ms maximum periodic lag. There are three such
  shutdown panics. The fifth sampler assertion was already present at draw enqueue.
  An AV queue data race is repaired and has a normal-flow test that passes ThreadSanitizer;
  the original queue reproduced a race. Both repaired openings completed (2/2); the repeat was
  reported as perfect playback and had clean audio-thread shutdown. The first was not observed.
  Linux and macOS CI passed for the repair; broader video acceptance remains open.
  Strict GPU locking still flashed,
  so the submission-lock default was not changed.
- Pre-release QA on 2026-10-13: five further default-renderer isolated openings and two
  self-contained downloaded-package openings all completed and were observed as successful.
  One package opening used an empty project cache; OS/Metal caches were retained. No new
  faults, GPU assertions or audio-thread invalid-mutex panics appeared. A 90-second packaged
  copied-save hold passed at 47.3 FPS, p90 22.9 ms and sampled CPU 511%. One extra package
  opening inherited the development driver and is excluded from self-contained acceptance.
  Runtime tests and current app CI passed. These checks cover the isolated packaged game
  entry point; packaged first-profile/Home QA subsequently passed with synthetic data on this Mac;
  clean-machine Gatekeeper/upgrade UI remains untested. Historical fault counts remain on the watch list; no version bump/tag occurred.
- GPU assertion watch list: three `ExecuteCopyShaderHLE` assertions (one while loading, two
  during the video), one `Unknown data_format=6 and num_format=1`, and one
  `Unknown data_format=15 and num_format=4`. Runtime `docs/STABILITY.md` lists the build/mode
  and run for each. None appeared in the video-fix acceptance or gameplay batches; their cause
  has not been established.
- The independent development launcher (`launcher/app/`, bloodborne-launcher) has Profiles with
  nested Saves/Backups and Trophies sections backed by SQLite, Drizzle and the Tauri SQL plugin. First-profile setup adopts
  existing saves in place. Native transactions own writes and file-operation recovery; shader
  caches remain shared. Development main now records local trophy unlocks per profile and displays counts and
  id/timestamp details on Home, Profiles and Saves. Marked edited saves cannot record new
  trophies; earned history survives restores. Online restrictions for edited saves are undecided.
  A separate React/Tauri overlay helper prototype passed windowed/fullscreen visual checks
  on this Mac. Runtime spawning and SDL geometry are now implemented. Notifications are on by default since 0.7.0
  (the maintainer's choice; Advanced → Launcher turns them off): one valid matched game pair
  lost 1.9 FPS (44.7 to 42.8) and added 1.3 ms to p90. The launcher re-imports trophies on
  the runtime's "trophy N unlocked" output line, so the list updates while it is hidden. The public
  catalog has 40 stable trophy IDs, verified names in 15 locales and original summaries in
  English, pt-BR and fr, with English fallback. Bloodborne and The Old Hunters are separate;
  local platinum requires only the 33 other base-game trophies. Grade cards use metallic cup
  styling. No game trophy files, keys or artwork are extracted or shipped.
  Character previews and editing remain future work; Saves shows an editor
  development badge. The launcher hides to the menu bar/tray during its game process by default
  and returns on exit; Advanced can keep it visible for logs. Design: launcher's
  `docs/SAVE_MANAGER.md` and `docs/LAUNCHER_LIFECYCLE.md`.
  The development launcher also checks stable app releases on GitHub, shows a dismissible
  update banner and changelog modal with a release-page button, and provides automatic/manual
  checks in Advanced. Downloads remain manual.
  Launcher features other than the new trophy tracking are included in the 0.6.0 release.
- Wikis: all four repositories have wikis; keep them in step with their docs. Launcher player
  guides also have mirrors in the app docs and wiki.
- The old `PabloVSouza/bloodborne_mac` repository (a fork of bbport) only points to these three.

## Working rules (all four repositories)

- **The project is four repositories**, nested as submodules:
  [bloodborne-mac](https://github.com/bloodborne-native/bloodborne-mac) (the app) ⊃ `runtime/` =
  [bloodborne-runtime](https://github.com/bloodborne-native/bloodborne-runtime) ⊃ `recomp/` =
  [bloodborne-recomp](https://github.com/bloodborne-native/bloodborne-recomp). Commit in the repository
  that owns the file, push it, then bump the submodule pointer in the parent (runtime → recomp,
  mac → runtime) and push that too. Submodules are checked out at a commit (detached HEAD):
  before editing inside `runtime/` or `runtime/recomp/`, run `git checkout main` (and
  `git pull`) there. The app also includes `launcher/app/` =
  [bloodborne-launcher](https://github.com/bloodborne-native/bloodborne-launcher); commit/push
  launcher changes there, then bump its pointer in this app. Separate clones work the same way.
- **Before any push, check `git remote get-url origin`** (a clone once still pointed at a local
  repository and a force-push landed there). Push to `main`; ask before force-pushing anything
  that existed before this session.
- **Commits:** a short subject, a body that says what changed and why (numbers when measured), and
  the trailer the session asks for (`Co-Authored-By: ...`).
- **Credits:** this work is built on [bbport](https://github.com/deadinside28/bloodborne_pc) by
  deadinside28 and on [shadPS4](https://github.com/shadps4-emu/shadPS4); keep them credited where
  they are (README, docs/CREDITS.md, the wikis). Code taken from another project or fork is
  credited in the same commit: CREDITS.md, the wiki's credits page, the commit message and a short
  code comment.
- **No game code, ever:** no decompiled or generated game code, no game files, no records of game
  memory in any repository. Docs and wikis talk about the recompiler only (not about decompiled
  code or private folders).
- **Test language:** use English for all game, launcher and overlay tests
  (`BB_LANGUAGE=1 BB_UI_LANGUAGE=en` and English UI), unless the maintainer requests a
  language-specific investigation.
- **Testing the game:** run it in the background with `runtime/tools/test_run.sh NAME [VAR=...]`
  (bloodborne-runtime's `tools/test_run.sh`): it copies the player's save first and never touches
  the real one. Check `pgrep -x bb-probe` first; one game at a time. Test windows open on the
  user's screen: say so before long batches of runs (bisections), and stop when asked.
- **Never capture the user's screen.** Pictures come from the game itself: `tools/grab.sh NAME`
  (its frame) or `tools/grab.sh --screen NAME` (with the in-game menu). Screenshots in English
  (`BB_LANGUAGE=1 BB_UI_LANGUAGE=en`).
- **Shell:** no `rm -rf` on variable paths (literal paths only); no `xargs ... sh -c '...'` (write
  a script file instead).
- **Docs:** plain, precise English; numbers measured, not guessed. When a milestone or a measured
  number changes, update the docs and the wiki status pages (progress bars: 20 blocks, one per 5%).
