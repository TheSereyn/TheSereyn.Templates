# Naomi — History

## Core Context

**Project:** TheSereyn.Templates — composition workspace for .NET project templates.
**User:** Lee Buxton
**Team:** Holden (Lead), Naomi (Template Engineer), Amos (Platform Engineer), Drummer (Security Reviewer), Scribe, Ralph

**My domain — template content:**
- `base/.github/copilot-instructions.md` — .NET coding standards for all templates
- `base/.github/copilot/skills/` — TUnit, StyleCop, compliance (GDPR, HIPAA, PCI DSS, SOC2, ISO27001), security-review, security-register, RFC compliance, code-analyzers, project-conventions, requirements-gathering, squad-setup
- `base/.github/prompts/` — first-time-setup, requirements-interview
- `base/Directory.Build.props` — .NET 10, TreatWarningsAsErrors, StyleCop, AnalysisLevel=latest-all
- `base/stylecop.json` — StyleCop config
- `base/README.md` — template README (uses {{PROJECT_NAME}} and {{DESCRIPTION}} placeholders)
- `overlays/blazor/` — Blazor-specific additions: devcontainer, mcp-config, copilot-instructions append, blazor-architecture skill, README
- `overlays/minimalapi/` — Minimal API README

**Key standards:**
- TUnit (not xUnit/NUnit/MSTest), async assertions
- StyleCop + Roslyn analyzers, TreatWarningsAsErrors
- Nullable enabled, file-scoped namespaces, implicit usings
- OpenTelemetry for observability
- IETF RFC 9205/9110/3986/9457 for HTTP/REST

## Learnings

- Session 1 (2026-04-04): Team initialized. I am the template content specialist.

- Session 2 (2026-04-04): Conducted content review with Microsoft Learn MCP validation.
  - Found 18 content findings, 3 Critical
  - Critical issue 1: MCP config references non-existent `@anthropic/*` packages (shared with Amos)
  - Critical issue 2: README lists "Azure" MCP server not actually configured in base
  - Critical issue 3: ISO 27001 skill cites superseded 2013 control numbers (shared with Drummer)
  - Blazor overlay README contains inaccurate claims about features
  - MinimalApi README inherits incorrect Azure reference
  - MCP package issue is highest priority — all MCP tooling broken on day one
  - Used Microsoft Learn documentation to validate .NET standards and compliance references
  - Overlay full-file replacements create drift risk between base and template versions

- Session 3 (2026-04-05): Implemented prompt split per Holden's design.
  - Created `base/.github/prompts/pre-container-setup.prompt.md` (71 lines) — host-level prerequisites checklist
  - Revised `base/.github/prompts/first-time-setup.prompt.md` (120 lines) — removed redundant Step 1 (environment verification), trimmed Step 8 (Squad install), renumbered 11 steps → 10 steps
  - Updated `base/README.md` Getting Started section to reference pre-container prompt first
  - Docker/Podman neutrality maintained — both presented as fully supported options (Step 1 of pre-container prompt)
  - `mode: text` used for pre-container prompt (manual checklist), `mode: agent` for first-time-setup (Copilot automation)
  - Self-cleanup now includes both prompts in deletion instructions
  - Learned: Post-create redundancy analysis prevents duplicate work — `post-create.sh` already handles env verification and Squad installation, so prompts should focus only on in-container configuration tasks

- Session 4 (2026-04-04T17:49:01Z): Scribe closed prompt-split phase.
   - Drummer approved security review — no changes required
   - Holden approved spec compliance — minor improvements noted (8 vs 7 steps, "Podman Desktop" naming, 4-step README)
   - Orchestration log created and archived
   - Inbox decisions merged to decisions.md
   - Session log recorded

- Session 5 (2026-04-06): CSS Design System research brief for Blazor template.
   - Researched 7 CSS methodologies: CUBE CSS, ITCSS, BEM, utility-first, Design Tokens, CSS Cascade Layers, CSS @scope
   - Recommended architecture: Design Tokens + CUBE CSS + Blazor CSS Isolation
   - CUBE CSS chosen as primary methodology — cascade-friendly, lightweight, natural fit for Blazor's component model
   - Design tokens (CSS custom properties) are the non-negotiable foundation — every design value must be a token
   - CSS `@layer` replaces ITCSS's layered specificity model natively
   - BEM rejected — redundant with Blazor CSS isolation
   - Full Tailwind/Bootstrap rejected — lightweight hand-rolled utilities only
   - Evaluated 14 modern CSS features for browser support baseline
   - Broadly supported and recommended: custom properties, `@layer`, `:has()`, container queries, Grid/Flexbox, nesting, logical properties, `oklch()`, `color-mix()`
   - Not yet recommended: `@scope` (Firefox too recent), anchor positioning (no Firefox), scroll-driven animations (partial support)
   - Proposed file structure: `wwwroot/css/` with `_tokens.css`, `_base.css`, `_compositions.css`, `_utilities.css`
   - Recommended 2 skills: new `css-design-system` skill + update to existing `blazor-architecture` skill
   - Research brief written to session artifact for Lee's review before skill authoring begins
   - Key learning: Blazor CSS isolation + CSS custom properties together solve Lee's "inconsistent panel" problem — scoped styles reference global tokens, making inconsistency structurally impossible

- Session 6 (2026-04-06): Built CSS Design System skill for Blazor template.
   - Created `overlays/blazor/.copilot/skills/css-design-system/SKILL.md` — comprehensive AI guidance skill (~22KB, 14 sections)
   - Architecture: Design Tokens + CUBE CSS + Blazor CSS Isolation — three pillars enforced via hard rules and anti-patterns
   - Included full reference token set: colour (oklch), spacing scale, typography, borders/radii, shadows, transitions
   - CUBE CSS compositions: `.stack`, `.cluster`, `.with-sidebar`, `.center`, `.auto-grid` — all using CSS custom property overrides for flexibility
   - Dark theme pattern: `[data-theme="dark"]` token overrides + `prefers-color-scheme` media query as initial default
   - Accessibility: WCAG 2.1 AA contrast ratios, `prefers-reduced-motion` global override, `:focus-visible` over `:focus`
   - Modern CSS features reference: nesting, container queries, `:has()`, logical properties, `oklch()`/`color-mix()`, `@property`
   - 10 hard rules, 9 anti-patterns, 12-point code review checklist
   - Excluded `@scope` (Baseline 2025 too new) and anchor positioning (no Firefox) per research recommendations
   - Updated `blazor-architecture` skill with CSS Architecture section and cross-reference
   - Key learning: The skill is AI guidance, not a deployable framework — same pattern as tunit-testing and stylecop-compliance skills. Prescribes principles and patterns, not boilerplate imports.

- Session 7 (2026-04-08): Integrated Spec Kit as primary spec-driven development workflow.
  - Created `base/.copilot/skills/spec-driven-development/SKILL.md` — comprehensive SDD integration skill (~233 lines, 13 sections)
  - Architecture: Spec Kit owns planning (specify → plan → tasks); Squad owns implementation orchestration
  - Updated `base/.github/copilot-instructions.md` with Development Workflow section and refreshed Skills list
  - Updated `base/.github/prompts/first-time-setup.prompt.md` — added Step 10 (Initialise Spec Kit), renumbered to 12 steps, rewrote next-steps to lead with SDD flow
  - Repositioned `requirements-interview.prompt.md` as complementary discovery tool with bridge to Spec Kit after completion
  - Updated `requirements-gathering` skill description to clarify Spec Kit relationship
  - Updated `squad-setup` skill with implementation orchestrator positioning and handoff diagram
  - Updated `base/README.md` with Spec Kit in What's Included and SDD workflow summary
  - Compose verified — both MinimalApi and Blazor templates compose cleanly with all changes
  - Key learning: The handoff model (planning tool → implementation orchestrator) is a clean separation of concerns. Spec Kit is unopinionated about implementation tooling, which makes it a natural fit as the front half of the pipeline. Squad's multi-agent model fills the back half. The constitution concept maps well to `.github/copilot-instructions.md` — reference it, don't duplicate it.
  - Key learning: `requirements-interview` still has value as a structured discovery tool for vague ideas or stakeholder interviews. It's not obsolete — it feeds *into* Spec Kit rather than competing with it.
