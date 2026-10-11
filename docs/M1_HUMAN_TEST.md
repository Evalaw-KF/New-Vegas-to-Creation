# M1 — Goodsprings playable test (human-run; no game-control tooling available to the assistant)

Status: **UNVERIFIED**. Do not mark M1 passed without filling the Results table and attaching evidence paths.
Run only in the isolated FO4 copy + dedicated MO2 profile + separate test saves (D4).

## Setup
- Load order: `Fallout4.esm`, DLC masters (if the converter requires them), converted `FalloutNV.esm` (+ its BA2s).
- `CreationKit.ini`: `bAllowMultipleMasterFiles=1`, `bAllowMultipleMasterLoads=1` (CK only).
- Enable loose files / archive invalidation per upstream README. Launch via F4SE only if tested that way; record which.
- Record: build-id, plugin SHA-256s, load order, save name.

## Steps and expected outcomes
| # | Step | Expected | Result | Evidence |
|---|---|---|---|---|
| 1 | Main menu → new game or load a clean save, console `coc Goodsprings` | Exterior Goodsprings loads, no CTD | | |
| 2 | Walk the town; jump, walk into a building wall, a fence, a car | Collision stops the player; no falling through terrain | | |
| 3 | Enter a Goodsprings interior via its door (e.g. Prospector Saloon) and exit | Loads interior, return to the same exterior position, both directions | | |
| 4 | Spawn one vanilla FO4 NPC near the saloon (`player.placeatme <FO4 NPC base ID>`; pick an ID valid on your FO4 version) and give it a wander/travel behaviour (e.g. a settler-style wander, or recruit it as a follower and walk through the town and a doorway) | The actor follows or wanders through the town without getting stuck on first obstacles. If it cannot path, record where | | |
| 5 | `Save` (named `M1_<build-id>`), quit to desktop, **fully exit the process**, relaunch, load `M1_<build-id>` | Same location, no missing-master prompt, world intact | | |

Notes for the executor: the pass criterion for step 4 is observed navigation, not a particular console command; record the method you used. Navmesh/door connectivity can also be checked statically in the Creation Kit (Render Window → navmesh view) *before* playing; record screenshots. Console use to *reach* the test location (`coc`) is fine; console use to *produce* a pass at M2 is not.

## Pass criteria
Steps 1, 2, 3, 5 pass, step 4 either passes or the exact failure location and cause (missing navmesh, unlinked door, collision) is recorded. Any crash is an exact blocker with the crash log (Buffout 4 if installed).

## Evidence folder
`artifacts/<build-id>/m1/` — screenshots, `Fallout4\*.log`, crash logs, the save file (versioned with the build; never overwritten).
