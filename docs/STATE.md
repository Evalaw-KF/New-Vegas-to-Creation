# STATE

Updated: 2026-10-11 (run 1).

| Field | Value |
|---|---|
| Repo HEAD | see `git log -1` on `claude/jolly-bell-yxmvm2` (first commit = this scaffold) |
| Upstream pinned | `terry-haire/fnv-to-fo4@5740cc9`, xEdit-fork `5020f09`, nifskope `a80c609` (see ENVIRONMENT) |
| Milestone | **M0 not started** (no PC access in this session) |
| Last passing build | none |
| Last test | none run. No code executed beyond static source reading |
| Blocker | This run executed in a Linux cloud container with no game files, no Windows, no Creation Kit. M0/M1/M2-trace need the PC |
| Missing inputs | `Implementation Plan.md` (Obsidian) and `NEW_VEGAS_FO4_PLAN.md` — not reachable/not in repo |

## What is verified
- Upstream converter source cloned and pinned; its plugin stage writes into the FO4 `Data` folder and can overwrite/delete (COMPATIBILITY W1–W3); mesh retry loop silently deletes failed inputs (W4).
- Repo scaffold: docs + `tools/Probe-Environment.ps1`, `tools/Snapshot-Tree.ps1`.

## What is NOT verified
Everything about actual conversion, Goodsprings, collision, navigation, save/load, Sunny's records, and any gameplay.

## Next exact action (user, on the PC, ~10 min)
1. Clone this branch on the PC; run `powershell -ExecutionPolicy Bypass -File tools\Probe-Environment.ps1`; commit/paste `docs\ENVIRONMENT.probe.json`.
2. Put the two plan files into `docs/` (or paste them).
3. Answer D3 (prebuilt upstream binaries OK for baseline?) and E7.
Then lead resumes with T1 (`docs/TASK_CONTRACT.md`).

## Model/effort for the next task
T1 review and manifest design: Opus 5.5 high (lead). Manifest/log parsing script: Haiku medium. M2 trace analysis: Sonnet high. Confirm availability with `claude` `/model` on the PC; not verified from here.

## Cost observations
Run 1 (no game work): ~130k tokens (session counter), mostly source reading. Not predictive for conversion work.
