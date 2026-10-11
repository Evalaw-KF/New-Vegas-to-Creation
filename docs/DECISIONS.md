# DECISIONS

Format: ID — decision — reason — status. Substitutions are explicit and numbered S#.

| ID | Decision | Reason | Status |
|---|---|---|---|
| D1 | Target engine is `Fallout4.exe` (Creation Engine). No ByroRedux / OpenNV / OpenMW / new engine | User requirement | Fixed |
| D2 | Start from `terry-haire/fnv-to-fo4` pinned at `5740cc9`; reuse, don't rewrite | User requirement; see ENVIRONMENT | Fixed |
| D3 | Prefer upstream **prebuilt release binaries** for the first baseline (record asset hashes), building Delphi/Qt from source only if a defect needs a patch | Delphi + Qt5 toolchain is heavy; CI itself downloads prebuilt releases | Proposed — confirm after probe (E7) |
| D4 | Converter never runs against the real FO4 install; use throwaway FO4 copy + isolated MO2 profile + separate saves | Audit W1–W3: converter overwrites/deletes plugins in FO4 `Data` | Fixed |
| D5 | Use FO4-native systems; per-quest adapters allowed when evidenced; no universal ObScript VM, no full transpiler | User requirement | Fixed |
| D6 | M2 target: Sunny Smiles / *Back in the Saddle*, IDs discovered from installed data (never from memory) | User requirement | Fixed |
| D7 | Lead role stays in main session. Workers: ≤1 normal, ≤2 independent; plugin integration, FormID allocation, CK edits and game control are serial | User requirement | Fixed |
| D8 | No paid overflow, no credits, no API-key billing. `ANTHROPIC_API_KEY` presence is *reported*, never treated as authorisation | User requirement | Fixed |
| D9 | Game gates (M1, M2) are **unverified** until a real FO4 run produces evidence on disk. Static plugin inspection never counts | User requirement | Fixed |

## Explicit substitutions (accepted by user)

| ID | Substitution | Scope |
|---|---|---|
| S1 | FO4 character models, animations, weapons and combat used in place of NV equivalents | Whole project |
| S2 | New Vegas DLC deferred | Post-M2 |

(Add new substitutions here before relying on them. An undocumented substitution is a bug.)
