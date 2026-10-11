# ENVIRONMENT

Last updated: 2026-10-11. Source of truth for what is *known* vs *unresolved*.

## Where this session runs (verified)

| Item | Value |
|---|---|
| Host | Anthropic cloud container, Linux 6.18 x86_64, **not the user's PC** |
| Repo | `Evalaw-KF/New-Vegas-to-Creation`, branch `claude/jolly-bell-yxmvm2`, started with **zero commits** |
| Session model | `claude-sonnet-5-5` (configured). Opus 5.5 was **not** the lead model for this run |
| Claude CLI in container | 2.1.296; `claude auth status` exists (not run against the user's account) |
| Game files / Windows paths | **None reachable.** No `FalloutNV.*`, `Fallout4.*`, `*.esm`, `C:\...` or Obsidian vault |
| Tools present | git, cmake, python3. No dotnet, wine, Delphi, Qt, Creation Kit |

Consequence: everything that needs the games, Windows, Creation Kit or a playtest is **unverified** and
must run on the user's PC. `tools/Probe-Environment.ps1` produces the missing inventory.

## Inputs the task named but this session could not read

- `C:\Users\evanp\Documents\Obsidian Vault\Implementation Plan.md` — path does not exist here.
- `NEW_VEGAS_FO4_PLAN.md` — not in the repo (repo was empty). Acceptance wording (M0/M1/M2) is taken from the
  task message only. **Action for user:** copy both files into `docs/` or paste them, then reconcile with `DECISIONS.md`.
- No existing `CLAUDE.md` / `AGENTS.md` / prior project work found (repo empty), so nothing was overwritten.

## Upstream pinned (verified by clone)

| Component | URL | Revision |
|---|---|---|
| fnv-to-fo4 | https://github.com/terry-haire/fnv-to-fo4 | `5740cc90419bf629582f5119f30e9d06faabf110` (2024-06-20, "Use new plugin conversion method") |
| xEdit-fork (TES5Edit) | submodule `git@github.com:terry-haire/TES5Edit.git` | `5020f09c0b89ea0b53401fe9ab492b405247a8d1` |
| nifskope_converter | submodule `git@github.com:terry-haire/nifskope.git` | `a80c609eab131935b72cdc917eff58959b7c7b26` (v7) |
| xEdit-fork nested | jcl `339c1fef…`, jedi `d39349d0…`, jvcl `16808338…`, lz4 `d27022ff…`, vcl-styles-utils `a4d240bd…` | as checked out by `--recurse-submodules` |

Caveats: `.gitmodules` uses SSH URLs (need rewriting to https on a machine without SSH keys). CI does **not** build
the Delphi/Qt converters; it downloads prebuilt `latest` releases of `terry-haire/nifskope` and `terry-haire/TES5Edit`.
That "latest" is not reproducible — the release asset hash must be recorded at download time. Last upstream commit is
~2 years old as of this run (2024-06-20); any "works" claim in its README is unproven on this installation.

## Unresolved prerequisites (need the PC)

| # | Item | How resolved |
|---|---|---|
| E1 | OS/build, admin rights (`takeown` is used by the converter) | probe script |
| E2 | FNV edition (Steam / GOG / Enhanced), version, language, DLC present, hashes of `FalloutNV.esm` etc. | probe script |
| E3 | FO4 version (NG vs OG, 1.10.163 vs 1.10.984 vs later), DLC, Creation Kit installed, F4SE | probe script |
| E4 | Free disk (converter extracts + BA2s; expect tens of GB) | probe script |
| E5 | Claude CLI: effective model/effort, auth method, whether `ANTHROPIC_API_KEY` is set | probe script (redacted) |
| E6 | MO2 profiles, existing FO4 mods/saves to protect | probe script + user |
| E7 | Delphi / Qt toolchain, or acceptance of prebuilt release binaries | **user decision** (see DECISIONS D3) |

Input hashes are recorded by the probe into `docs/ENVIRONMENT.probe.json`; promote the stable subset here once it exists.
