# COMPATIBILITY / CONVERTER WRITE AUDIT

Audit of `terry-haire/fnv-to-fo4` @ `5740cc9` (static source read, Windows-only code; **nothing was executed**).
Line numbers refer to that revision. Staging is isolated by default; the plugin stage is the exception.

## Write / delete map

| # | Action | Where | Risk | Mitigation |
|---|---|---|---|---|
| W1 | **xConvert saves the converted plugin straight into `<FO4 Data>\<name>`** with `fmCreate` (truncates any same-named file) and `DeleteFile`s it on any exception | `xEdit/Convert/__FNVImportFuctionsTextv2.pas:2035-2057` (`SaveConvertedFile`); Data path from registry or `-D` (`xConvert.dpr:247`) | Overwrites/deletes a real `FalloutNV.esm` (or any same-named plugin) in the real FO4 Data | Run only against a **throwaway copy of the FO4 install** (own registry-independent path via `-D`, or a copy whose Data is junction-free). Never the real install. Prove with before/after hash tree |
| W2 | Worker then **moves** the plugin out of `<FO4 Data>` into `output\` | `WorkerThread.py:824-830` | Move of a stale same-named file; fails if present in output | Pre-flight: assert `<FO4 Data>\<plugin>` absent before run; assert after run it is gone |
| W3 | Plugin is **skipped silently** if `<FO4 Data>\<plugin>` already exists | `WorkerThread.py:85-86` | A stale/previous conversion is mistaken for a fresh one → "success" with old data | Pre-flight asserts absence; the manifest records the plugin SHA-256 + mtime per run |
| W4 | Mesh retry loop (up to 100×) **deletes failed input meshes** from the temp dir, then retries, and never reports a final failed list as an error | `WorkerThread.py:590-657`; fixed skip of `nvdlc03bigmt.16.-32.-32.BTR` at ~596 | Silent loss of required content; "DONE" printed regardless | Capture full log; build manifest = (input meshes) − (output meshes); any required NIF in the diff is a failure, not a warning |
| W5 | After BA2 creation, wipes `output\{textures,Materials,meshes,Music,Sound}` and `temp`, `extracted` | `WorkerThread.py:284-303` | Loose output intentionally replaced by BA2; deletion scope is under cwd/output only | Keep output dir dedicated; record BA2 hashes + file lists *before* the wipe |
| W6 | xEdit tools write `__ReferenceList.csv`, `__FailedList.csv`, `__Loadorders.csv`, `__FailedReferences.csv` under `build\xedit_converter\data\` and **`rmtree` that dir** before each extract | `__FNVImportFuctionsTextv2.pas:386-388,3112-3120`; `WorkerThread.py:721-754` | These CSVs are the best source-of-truth for failures and get erased next run | Copy `data\*.csv` to `artifacts/<build-id>/` immediately after each stage |
| W7 | `takeown /f` on `output\textures` (needs admin; ignores failure) | `WorkerThread.py:475` | Changes ACLs on staging dir only | Acceptable; record admin state |
| W8 | `extracted\`, `temp\`, `output\` default to **current working directory** (`output` is user-selectable in GUI) | `app.py:352,658-666` | Runs from the wrong cwd pollute the wrong tree | Always launch from a dedicated staging dir on a data disk |
| W9 | Reads FO4 `Tools\Archive2` and `Tools\Elric`, BSAs from FNV `Data`; xEdit loads from FO4 Data | `WorkerThread.py:208,592` | Read-only on originals | OK |
| W10 | `convert.ps1` (legacy path) uses `Move-Item "$fo4Path\Data\FalloutNV.esm"`, `Copy-Item ... -Force`, `Remove-Item` | `convert.ps1:155-260` | Same as W1/W2 and relies on Fallout 4 registry path | **Do not use `convert.bat`**; GUI/worker path only |

## Isolation rules for this project

1. Never run the converter against the user's real FO4 install or real `Data\`. Use a **copy** of FO4 (exe, `Data` incl. DLC, `Tools`, Creation Kit) under the staging disk, with registry-free paths (`-D`) where supported, and verify by tree-hash before and after.
2. Original FNV install is read-only input; never run xEdit in FNV mode with write access to the real Data (`-dontBackup` is passed upstream).
3. Mod manager: dedicated MO2 instance/profile + separate `Documents\My Games\Fallout4` (or a profile with local saves/INI) so test saves cannot touch real saves.
4. Output isolation proof (gate **G0**): SHA-256 + mtime listing of FO4 real `Data`, FNV `Data`, and `My Games\Fallout4\Saves` identical before and after a conversion run. Store the listing under `artifacts/<build-id>/isolation/`.

## Source/target record identity (design, not yet implemented)

- Source identity = `(source_plugin_name, source_FormID_local_24bit, signature)` where the plugin name is the **FNV master as read**, not generated.
- Target identity = `(generated_plugin_name, target_FormID, signature)`; records `source→target` map written as CSV/JSON beside the plugin.
- Generated plugin is FO4-format (`FalloutNV.esm` *name* reused by upstream, **FO4-format content**) — always labelled "generated", never mixed with real source masters in docs or tooling.
- Per-run ledger: unsupported record types, failed assets (W4), unresolved references (W6 CSVs), and intentional substitutions (see `DECISIONS.md`).

## Known unknowns (do not assume)

- Whether `5740cc9` + latest TES5Edit/nifskope releases still build/run on current FO4 (NG update) and the user's FNV edition.
- What fraction of Goodsprings NavMesh/doors/collision survive. Upstream README only claims "partially convert plugin files".
- Whether quests, dialogue (INFO/DIAL), scripts (SCPT), NPC AI packages are converted at all, or dropped. To be answered by the **semantic output manifest** from the first real run, not by README.
