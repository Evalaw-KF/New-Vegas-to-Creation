# CURRENT TASK CONTRACT — T1: M0 baseline + isolation proof

Owner: lead (integration). Worker: none yet (needs PC access). Status: **blocked on PC-side inputs** (see STATE.md).

## Goal
Run upstream converter @ `5740cc9` once, in isolation, and produce a semantic output manifest. A completion message is not a pass.

## Inputs
- `docs/ENVIRONMENT.probe.json` (from `tools/Probe-Environment.ps1`) — gives paths, versions, hashes, free space.
- Throwaway FO4 copy (exe + Data incl. DLC + Tools + CK) on the staging disk. FNV install read-only.
- Upstream release assets for xEdit-fork and nifskope converter (record URL + SHA-256) — decision D3.

## Steps
1. `Snapshot-Tree.ps1` before: real FO4 Data, FNV Data, real Saves, throwaway FO4 copy.
2. Pre-flight asserts: `<throwaway FO4>\Data\FalloutNV.esm` absent; `output\`, `temp\`, `extracted\` empty; converter launched from staging dir.
3. Run converter GUI on `FalloutNV.esm` only (no DLC). Save full console log to `artifacts/<build-id>/convert.log`.
4. Copy `build\xedit_converter\data\__*.csv` to `artifacts/<build-id>/` **immediately**.
5. `Snapshot-Tree.ps1` after; diff must be empty for everything except the throwaway copy and `output\`.
6. Build the manifest (see Acceptance).

## Acceptance (all required)
- A1 Isolation: before/after diff clean for real FO4 Data, FNV Data, real Saves.
- A2 Manifest `artifacts/<build-id>/manifest.json` with: tool revisions + asset hashes; input hashes; output file list with SHA-256; plugin header (masters, record counts by signature); counts of input vs output NIF/DDS/BGSM; list of meshes dropped by the retry loop (W4); parsed `__FailedList/__FailedReferences`; record-type coverage table (which of QUST, DIAL, INFO, NPC_, SCPT, NAVM, CELL, WRLD, REFR, DOOR … survive and how many).
- A3 Every "failed" or "dropped" item is in the ledger; none are silently treated as success.
- A4 STATE.md updated with HEAD, build-id, result.

## Out of scope
DLC, other quests, ObScript translation, animation fidelity.

## Next contract
T2 (M1): see `docs/M1_HUMAN_TEST.md`.
