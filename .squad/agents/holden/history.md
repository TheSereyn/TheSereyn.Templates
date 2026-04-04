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

- Session 2 (2026-04-04): Led comprehensive template review with all team members.
  - Identified 62 consolidated recommendations across architecture, content, platform, security
  - 6 Critical blockers must be fixed before templates are production-ready
  - Key finding: MCP packages, devcontainer (Podman-only), postCreateCommand chain all broken
  - Most critical: All MCP tooling fails day one due to non-existent `@anthropic/*` package names
  - Devcontainer hard-fails on Docker Desktop (majority of target users)
  - GitHub Actions pinned to mutable tags (supply chain risk)
  - Assembled individual findings into consolidated 341-line review with full remediation guidance
  - Cross-cutting findings indicate high confidence in critical issues
