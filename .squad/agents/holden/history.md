# Holden — History

## Core Context

**Project:** TheSereyn.Templates — composition workspace for .NET project templates.
**User:** Lee Buxton
**Team:** Holden (Lead), Naomi (Template Engineer), Amos (Platform Engineer), Drummer (Security Reviewer), Scribe, Ralph

**Key files:**
- `base/` — shared files for ALL templates
- `overlays/<name>/` — per-template additions and overrides
- `compose.sh` — merges base + overlay → `output/<template>/`
- `.github/workflows/compose-and-publish.yml` — tag-triggered publish to downstream repos
- `output/` — gitignored build artifacts; never edit directly

**Overlay semantics:**
- Same path as base → replaces base version
- New path → added
- `*.append.md` → content appended to matching base file

**Downstream templates:**
- TheSereyn.Templates.MinimalApi (`overlays/minimalapi/`)
- TheSereyn.Templates.Blazor (`overlays/blazor/`)

**Release process:** dev → PR → main → `v*` tag → compose-and-publish workflow fires

**Key decisions archive (Sessions 1-10, 2026-04-04 to 2026-04-08):**
- **Session 1-2:** Team initialized. Comprehensive template review (62 recommendations, 6 critical blockers). Most critical: MCP packages non-existent `@anthropic/*` names, devcontainer Podman-only, GitHub Actions mutable tags.
- **Session 3-4:** Prompt split implementation approved (3 files match spec). Pre-container-setup.md needs `git add`. Lesson: splitting composite steps improves scannability.
- **Session 5-6:** Pre-container variable split for `devcontainer.json` and `{{PROJECT_NAME}}` rationalized. Amos PR #26 merge; `.yml.disabled` pattern approved.
- **Sessions 7-10:** Spec Kit integration (github/spec-kit). Installed via `uv tool install`, scaffolds `.specify/` dir. Spec Kit owns spec→planning→breakdown; Squad owns implementation. Base files only. Two revision iterations (version pinning, fallback security). Drummer security review: main-branch 4 HIGH, 4 MEDIUM, 4 LOW findings.
- **Sessions 11-12:** Podman compatibility restoration approved. Docker features (DooD/DinD) removed — incompatible with Podman. Trade-off: users add Docker feature themselves if needed.

## Learnings

- Session 13 (2026-04-12T21:59:52Z): CLI template planning preference refinement
    - Orchestration logs created: 2026-04-12T21:59:52Z-holden.md (plan refinement), 2026-04-12T21:59:52Z-naomi.md (research update)
    - Session log created: 2026-04-12T21:59:52Z-cli-template-planning-preferences.md
    - Decision inbox merged: Two directives consolidated into decisions.md (maintained packages preference, Spectre.Console primary default, MIT licensing)
    - Inbox files deleted: copilot-directive-2026-04-12T21:54:08Z.md, copilot-directive-2026-04-12T21:55:56Z.md
    - CLI template planning refined per user directive (Lee Buxton):
      * Prefer maintained CLI packages (no abandoned/deprecated tooling)
      * Make Spectre.Console the primary default
      * Keep Spectre.Console.Cli, CliFx, Terminal.Gui as alternatives
      * Demote Cocona due to maintenance concerns
      * Record MIT as licensing preference
    - Decisions.md now ~29.5KB; archive will trigger at next ~10KB growth
    - Status: CLI template planning preferences documented and ready for downstream composition

- Session 14 (2026-04-12T22:13:20Z): CLI planning artifacts relocation
    - Coordinator completed artifact move to `.tmp/` — finalized CLI planning files now centrally located
    - Scribe merging decision inbox and creating orchestration artifacts
