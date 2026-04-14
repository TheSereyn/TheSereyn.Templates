# Decision: CLI Template Repo Wiring

**By:** Amos (Platform Engineer)
**Date:** 2026-04-14
**Status:** Implemented on `dev`

## Changes

| File | Change |
|------|--------|
| `templates.json` | Added `cli` overlay → `TheSereyn/TheSereyn.Templates.CLI` entry |
| `README.md` (workspace root) | Added CLI to downstream table, workspace structure tree, and local development examples |
| `overlays/cli/` | Created empty directory (required for compose.sh overlay resolution) |

## No Workflow or Script Changes Required

The infrastructure is fully data-driven:
- `compose.sh` reads `templates.json` dynamically — no TEMPLATES array to update
- `compose-and-publish.yml` builds its strategy matrix from `templates.json` — no hardcoded matrix entries
- `pr-validate.yml` iterates `templates.json` — CLI validation is automatic

**Zero gaps found.** The existing data-driven design handles CLI onboarding without any pipeline modifications.

## Validation

- `jq` parsed `templates.json` successfully (valid JSON)
- `compose.sh --dry-run` recognized all three templates
- `compose.sh` full run composed CLI output (46 files from base, 0 overlay files pending Naomi's content)
- `output/TheSereyn.Templates.CLI/README.md` present, file count ≥ 5 — passes PR validation threshold

## Remaining Work (Not in This Change)

- **Naomi:** CLI overlay content (skills, source files, append files) in `overlays/cli/`
- **Downstream repo:** `TheSereyn/TheSereyn.Templates.CLI` must be created on GitHub as a template repo
- **Secret:** `TEMPLATE_PUSH_TOKEN` must have push access to the new downstream repo
