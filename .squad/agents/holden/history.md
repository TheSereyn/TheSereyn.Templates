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

## Learnings

- Session 1 (2026-04-04): Team initialized. Holden is Lead. Universe: The Expanse.
