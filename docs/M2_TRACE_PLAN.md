# M2 dependency trace — Sunny Smiles / *Back in the Saddle*

Status: **NOT TRACED.** No New Vegas data is reachable from this session, and no record IDs are asserted here
(they must come from the installed `FalloutNV.esm`, not memory). This file is the procedure plus the output template.

## Method (run on the PC in xEdit, FNV mode, read-only; save findings to `docs/M2_TRACE.md`)
1. Find NPC `Sunny Smiles` (NPC_). Record: editor ID, FormID (plugin-local + load-order), template, class, factions, `SCRI` (attached script), AI packages, voice type, race, inventory, ACBS flags, home cell + REFR.
2. List every DIAL whose `QSTI`/quest belongs to Sunny's quests or whose INFOs have `CTDA` on Sunny / her voice type / her faction. Find the INFO that offers the quest and the one that starts it.
3. For the quest-start INFO record: prompt/response text, `CTDA` (function, operator, value, run-on, reference), Result Script (begin/end), "choices" (TCLT), flags (goodbye, say once, etc.), topic type.
4. For the QUST record: editor ID, flags (start game enabled? run once?), priority, `SCRI`, every stage (INDX), stage log text, stage result scripts, objectives (QOBJ/NNAM) and targets (QSTA + conditions).
5. Trace every script actually invoked (quest script, object script on Sunny, result scripts): list each command and variable. Classify each command: FO4 Papyrus equivalent / needs adapter / unsupported.
6. List AI dependencies: packages on Sunny that gate dialogue availability (e.g. "must be in the saloon / sandbox / follow") and the cells/furniture/markers they reference. Confirm they exist in the generated plugin.
7. Compare with observable original-game behaviour (play or video of the unmodified FNV start): note first-line, choices, whether the quest starts on selection vs. on completing dialogue, and objective text.

## Output template (`docs/M2_TRACE.md`)
- Records table: `signature | EDID | source FormID | generated FormID | present in generated plugin? | notes`
- Conditions table (function, value, FO4 equivalent or adapter)
- Script command table with classification (above)
- **Behaviour contract:** ordered list "player does X → engine shows Y → state Z set (stage/objective/global)".
- Gaps and proposed adapter(s): each justified with a record/line reference; no fabricated stage changes.

## Likely FO4-native mapping (hypotheses to confirm, not facts)
QUST→QUST (stages/objectives native); DIAL/INFO→DIAL/INFO with FO4 conditions; Result Script → Papyrus *INFO fragments* or quest-stage fragments; NV conditions without FO4 equivalent → small Papyrus-guarded adapter.

## M2 pass (unchanged)
Activate adapted Sunny in FO4 → relevant dialogue shows → player's choice starts/advances the quest → objective appears → state and subsequent dialogue stay correct after save, **full process exit**, reload. No production-path console stage-setting or injected success.
