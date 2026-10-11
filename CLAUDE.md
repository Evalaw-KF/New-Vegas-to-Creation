# CLAUDE.md — New Vegas → Fallout 4 (personal, local-only project)

This session should run **on the user's Windows PC**, where both games, the Creation Kit and the mod tools live.
Read this file, then `docs/STATE.md`, `docs/ENVIRONMENT.md`, `docs/DECISIONS.md`, `docs/COMPATIBILITY.md`,
`docs/TASK_CONTRACT.md`. If `docs/NEW_VEGAS_FO4_PLAN.md` or `docs/Implementation Plan.md` exist, read them first.
Do not assume the OS, game versions, language or paths: inspect them.

## Required outcome
New Vegas playable inside `Fallout4.exe`: world, dialogue, quests, choices, combat, progression, save/load.
Personal mod, never distributed. Base game first; NV DLC later. FO4 character models/animations/weapons/combat are
acceptable; keep every substitution explicit in `docs/DECISIONS.md`.

## Hard limits (never cross without the user asking)
- Use the user's existing Claude Pro subscription only. No paid overflow, no credits, no subscription changes.
  An `ANTHROPIC_API_KEY` in the environment is **not** authorisation for paid use; report it, don't use it. Never print credentials.
- No publishing or uploading game content. No silently changing the target engine. No pivot to ByroRedux/OpenNV/OpenMW.
- Preserve originals, existing mods and saves. Never run the converter against the real FO4 install or real `Data\`
  (see COMPATIBILITY W1–W3: it overwrites/deletes plugins in FO4 `Data`). Use a throwaway FO4 copy, an isolated mod-manager
  profile and separate test saves; prove isolation with `tools\Snapshot-Tree.ps1` before/after.
- Ordinary reversible development, local builds and tests inside the isolated project are pre-authorised. Ask only for missing
  information or actions outside that scope.

## Role and delegation
You are the single lead reviewer/orchestrator in the main session: own architecture, priorities, acceptance, integration.
Delegate bounded implementation to subagents, then inspect the real diff and evidence yourself. Workers cannot approve their
own work or spawn workers. Normally 1 worker, max 2 concurrent on independent tasks. Serialise plugin integration, FormID
allocation, Creation Kit editing and game control. Give each worker exact file/record ownership and acceptance criteria.
After two failed attempts at one hypothesis, capture a minimal reproduction and change approach.
Model guidance (verify what the account actually offers with `/model`; don't guess IDs): Opus 5.5 high for lead; Sonnet medium
for narrow implementation; Sonnet high for quest semantics/persistence; Haiku low/medium for inventory/log processing; a bounded Opus
specialist for genuinely unresolved problems. Create only project-local worker definitions the current work needs.

## Technical rules
- Base: `terry-haire/fnv-to-fo4` pinned at `5740cc9` (+ submodules, see ENVIRONMENT). A published feature list proves nothing; verify.
- Keep a stable source→target record map with plugin-aware identities and provenance. Distinguish source NV masters from generated
  FO4-format output. Track unsupported records, failed assets, missing references, substitutions. Never erase required content
  silently or treat an unresolved condition as success. "Conversion complete" messages are not a pass.
- Use FO4-native systems plus small explicit adaptations. First one faithful quest interaction, then generalise. No universal ObScript VM,
  full transpiler, RPG overhaul or perfect animation as prerequisite. Quest-specific adapters allowed when evidenced; **no fake stage changes**.
- Verify Papyrus API against installed definitions and compiler behaviour; never invent functions.
- Do not let regeneration overwrite unrecorded Creation Kit work. One controlled owner integrates.

## Milestones / acceptance
- **M0** reproducible converter baseline + semantic output manifest (`docs/TASK_CONTRACT.md`).
- **M1** Goodsprings loads; collision and interior/exterior transition work; one FO4 actor navigates the needed area; save, exit process, reload (`docs/M1_HUMAN_TEST.md`). Inspect navmesh/door connectivity before expanding actor conversion.
- **M2** Sunny Smiles / *Back in the Saddle*: trace actual records first (`docs/M2_TRACE_PLAN.md`). Pass only when activating the adapted Sunny
  shows the dialogue, the player's choice starts/advances the quest, the objective appears, and state + later dialogue survive save → full
  process exit → reload. No production-path console stage-setting, injection or fabricated success.
- Static plugin inspection never proves a gameplay milestone. If you cannot drive/observe the game, hand the user the smallest
  human-run test, label the gate **unverified**, and continue independent work.
- Record: build revision, input/tool manifests, plugin hashes/load order, save identity, steps/results, evidence paths. Version test saves with the build.

## Continuity
Conserve context: targeted reads, logs on disk, cache unchanged assets, no repeated whole-repo analysis, no empty polling.
After each accepted change update `docs/STATE.md` (HEAD, milestone, last passing build, last test, blocker, next exact action).
Before limits are hit, checkpoint and write a resumption note. Do not activate paid continuation. Estimate from observed costs; no whole-game forecast.
Report: what works in FO4, what evidence proves it, what is unverified, next smallest blocker, model/effort for next task.

## First actions on the PC
1. `powershell -ExecutionPolicy Bypass -File tools\Probe-Environment.ps1` → `docs\ENVIRONMENT.probe.json`; fold stable facts into ENVIRONMENT.md.
2. Check Claude CLI model/effort/auth (`claude auth status`; never expose tokens) and record in ENVIRONMENT.md (E5).
3. Resolve D3 with the user (prebuilt upstream converter releases for baseline?), then start T1.
