# Decision: Spec Kit as Primary SDD Workflow

**By:** Naomi (Template Engineer)  
**Date:** 2026-04-08  
**Status:** Implemented on `dev`

## Decision

Spec Kit (github/spec-kit) is the primary spec-driven development workflow for all templates. Squad is positioned as the implementation orchestrator after Spec Kit's planning phases.

## Workflow

```
Spec Kit (specify → plan → tasks)  →  Squad (implement with specialist agents)
```

- **Spec Kit owns:** requirements capture, specification refinement, constitution governance, technical planning, task decomposition
- **Squad owns:** implementation orchestration, code generation, testing, code review, security review
- **Requirements Interview:** retained as complementary discovery tool for early-stage/vague projects; its output feeds into Spec Kit's `/speckit.specify` phase

## Changes

| File | Change |
|------|--------|
| `base/.copilot/skills/spec-driven-development/SKILL.md` | New skill — full SDD integration guide |
| `base/.github/copilot-instructions.md` | Added Development Workflow section; updated Skills list |
| `base/.github/prompts/first-time-setup.prompt.md` | Added Step 10 (Spec Kit init); renumbered; rewrote next-steps |
| `base/.github/prompts/requirements-interview.prompt.md` | Repositioned as complementary; added Spec Kit bridge |
| `base/.copilot/skills/requirements-gathering/SKILL.md` | Updated description for Spec Kit relationship |
| `base/.copilot/skills/squad-setup/SKILL.md` | Added orchestrator positioning |
| `base/README.md` | Spec Kit in What's Included; SDD workflow summary |

## Rationale

- Lee explicitly chose Spec Kit as the SDD workflow tool, paired with Squad as implementation orchestrator
- Clean separation: Spec Kit is unopinionated about implementation tooling; Squad fills that gap
- Constitution concept maps naturally to existing `.github/copilot-instructions.md` — reference, don't duplicate
- Requirements interview adds value for early-stage discovery; not redundant with Spec Kit

## Installation Note

Spec Kit is initialised at runtime via `specify init --here --ai copilot`, not vendored into templates. The `.specify/` directory is project-specific and generated per-project.

## Commit

`026d625` on `dev` branch
