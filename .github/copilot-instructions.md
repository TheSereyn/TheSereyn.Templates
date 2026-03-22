# TheSereyn.Templates — Copilot Instructions

## Project Identity

**TheSereyn.Templates** is a composition workspace that maintains shared base files and per-template overlays for .NET project templates. It composes and publishes to downstream GitHub template repositories.

## Workspace Structure

- `base/` — Shared files included in ALL templates
- `overlays/<template>/` — Per-template additions and overrides
- `compose.sh` — Merges base + overlay into `output/<template>/`
- `output/` — Composed template repos (`.gitignored` build artifacts — never edit directly)
- `_reference/` — Source materials from existing projects (`.gitignored` — delete after Phase 2)

## Key Rules

1. **Never edit `output/` directly.** Always edit files in `base/` or `overlays/`. Run `./compose.sh` to regenerate output.
2. **Overlay semantics:**
   - Same path as base → **replaces** the base version
   - New path not in base → **added**
   - `*.append.md` → content **appended** to the matching base file (strip the `.append` from the name)
3. **Branching:** Work on `dev`, PR to `main`, tag on `main` to publish. Never push directly to `main`.
4. **Publishing:** Tag push (`v*`) on `main` triggers the compose-and-publish workflow.

## Skills

See the `template-management` skill for detailed conventions on overlays, compose process, adding new templates, and publishing.

## Downstream Templates

| Template | Repo | Composition |
|----------|------|-------------|
| TheSereyn.Templates.MinimalApi | [GitHub](https://github.com/TheSereyn/TheSereyn.Templates.MinimalApi) | `base/` + `overlays/minimalapi/` |
| TheSereyn.Templates.Blazor | [GitHub](https://github.com/TheSereyn/TheSereyn.Templates.Blazor) | `base/` + `overlays/blazor/` |
