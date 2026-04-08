# Squad Decisions

## Active Decisions

### 2026-04-04: Default agent model
**By:** Lee Buxton
**Decision:** Default model for all agents is `claude-opus-4.6`. Fall back to `claude-opus-4.5` if a specific capability is unavailable in 4.6. Only recommend a different model family when a required feature (e.g. vision) is unsupported by any opus model. Scribe is exempt — remains on `claude-haiku-4.5`.

---

## 2026-04-05: Docker/Podman Compatibility & Prompt Split Design

**By:** Holden (Lead)  
**Decision:** Two-phase prompt split approved. Pre-container setup (host) separates from in-container setup (Copilot Chat). Docker and Podman both fully supported—no devcontainer.json changes needed. `--security-opt=label=disable` beneficial for Podman on SELinux systems.

**Implementation:** Naomi completed. Drummer approved (security). Holden approved (spec).

---

## 2026-04-05: Prompt Split Implementation

**By:** Naomi (Template Engineer)  
**Status:** Completed

**Changes:**
- Created `base/.github/prompts/pre-container-setup.prompt.md` (8 steps, `mode: text`, 71 lines)
- Revised `base/.github/prompts/first-time-setup.prompt.md` (removed old Step 1 verification, trimmed old Step 9, renumbered 1–10, 120 lines)
- Updated `base/README.md` Getting Started section to reference pre-container prompt

**Quality:** Matches spec, no unintended changes, Docker/Podman neutral, sequential numbering, security-positive.

---

## 2026-04-05: Security Review — Prompt Split

**By:** Drummer (Security Reviewer)  
**Verdict:** ✅ APPROVED

**Scope:** `base/.github/prompts/pre-container-setup.prompt.md` and `base/.github/prompts/first-time-setup.prompt.md`

**Findings:**
- GitHub auth: Safe (OAuth + Dev Containers spec, no manual token handling)
- Git identity: Safe (placeholders, `--global` standard for developer workstations)
- Clone/template: Safe (HTTPS default, placeholder URLs)
- Container security: Safe (post-create.sh installs, no arbitrary scripts)
- Security setup: Security-positive (secret management, branch protection)
- No insecure patterns: Verified (no `curl | bash`, no hardcoded secrets)

**Outcome:** No changes required. Approved as submitted.

---

## 2026-04-06: CSS Design System for Blazor Template

**By:** Naomi (Template Engineer)  
**Status:** Completed

**Recommendation:** Design Tokens + CUBE CSS + Blazor CSS Isolation

**Architecture:**
1. **Design Tokens** — All design values as CSS custom properties in `_tokens.css` (colours, spacing, typography, radii, shadows)
2. **CUBE CSS** — Global CSS in `@layer`-ordered files (compositions, utilities)
3. **Blazor CSS Isolation** — Every component has a `.razor.css` file referencing tokens

**Rationale:** Prevents inconsistent-panel problem. Zero-dependency approach. Uses native CSS features (custom properties, `@layer`, `color-mix()`, `oklch()`). Works naturally with Blazor's `.razor.css` scoping.

**Design Decisions (Autonomously Applied):**
- **Dark theme:** `[data-theme="dark"]` with `prefers-color-scheme` fallback. Uses `oklch()` + `color-mix()`
- **Colour palette:** Neutral defaults in token registry; projects customize
- **Accessibility:** WCAG 2.1 AA baseline with contrast ratio guidance
- **Animations:** `prefers-reduced-motion` included in accessibility section

**Rejected:**
- BEM (redundant with Blazor CSS isolation)
- Tailwind/Bootstrap (too heavy; hand-rolled utilities only)
- CSS `@scope` (Firefox support too recent)
- Anchor positioning (no Firefox support)

**Deliverables:**
- New skill: `overlays/blazor/.copilot/skills/css-design-system/SKILL.md` (644 lines, 14 sections)
- Updated skill: `overlays/blazor/.copilot/skills/blazor-architecture/SKILL.md` (added CSS Architecture section)
- Commit: `bb62a6f` to dev branch

**Research Brief:** `/home/vscode/.copilot/session-state/858e847b-5317-4be8-9fbf-0b9a9a7ae0d8/files/css-design-system-research.md` (comprehensive survey of 7 methodologies and 14 modern CSS features)

---

## 2026-04-04: Security Design Decisions

**By:** Holden & Drummer  
**Status:** Pending implementation

**Decisions:**
- Skills path migration: `.github/copilot/skills/` → `.copilot/skills/`
- Security skills distribution: 11 base + 2–3 Blazor overlay
- Replace `security-review` with `security-review-core`
- Security architect prompt: Opt-in (not baked)
- First-time setup gap: Step 6 must append compliance skill names
- Squad setup in base `copilot-instructions`
- Browser security headers: Base + Blazor overlay append pattern

**Compliance findings unaddressed:** #3, #17, #21, #22 (unchanged)

---

## 2026-04-06: Pre-Container vs In-Container Template Variable Split

**By:** Holden (Lead)  
**Status:** Approved & Merged

**Decision:** Template variables split into two resolution phases:

**Pre-container (host, before first build):**
- `devcontainer.json` → `{{PROJECT_NAME}}` — Must be set on host before opening container. Docker/VS Code read at build time; changing after has no effect until full rebuild.

**In-container (first-time-setup, after ready):**
- `.github/copilot-instructions.md` → `{{PROJECT_NAME}}`, `{{NAMESPACE}}`, `{{DESCRIPTION}}`
- `README.md` → `{{PROJECT_NAME}}`, `{{DESCRIPTION}}`
- `LICENSE` → `{{YEAR}}`, `{{AUTHOR}}`
- `.github/CODEOWNERS` → `{{GITHUB_ORG}}`, `{{TEAM_NAME}}` (deferred)

**Rationale:** Mixing build-time and runtime configuration creates silent failure mode (no error, no effect). Separation makes constraint explicit and actionable at correct time.

**Implementation:**
- `base/.github/prompts/pre-container-setup.prompt.md` — New Step 5 "Set Container Name"
- `base/.github/prompts/first-time-setup.prompt.md` — Removed `devcontainer.json` from Step 5

---

## 2026-04-08: User Directives (Lee Buxton)

### Directive 1 (09:09:09Z): Keep Squad, disable active workflows

**What:** Keep Squad installed, but disable the active Squad GitHub workflows for now.  
**Why:** User request — captured for team memory

### Directive 2 (09:53:24Z): Adopt Spec Kit as primary SDD workflow

**What:** Adopt Spec Kit as the template SDD workflow in place of OpenSpec-style lightweight guidance; prefer the heavier formal structure and constitution-style governance for enterprise-oriented development.  
**Why:** User request — captured for team memory

---

## 2026-04-08: Spec Kit Integration into TheSereyn.Templates

**By:** Holden (Lead)  
**Date:** 2026-04-08  
**Status:** Approved — Ready for implementation

### Context

Lee has adopted Spec Kit (GitHub's Spec-Driven Development toolkit) as the SDD workflow tool for all TheSereyn templates. Spec Kit produces specification, plan, and task artifacts via slash commands (`/speckit.constitution`, `/speckit.specify`, `/speckit.plan`, `/speckit.tasks`, `/speckit.implement`). Squad remains the implementation orchestrator.

### Key Decisions

**1. Runtime init — do NOT pre-commit Spec Kit artifacts**

Install the `specify` CLI in the dev container. Guide users to run `specify init --here --ai copilot` during first-time setup. Do not commit any `.specify/` directory or Spec Kit output files into the template.

*Rationale:* Consistency with Squad pattern (install tool at container creation, verify, guide user). Spec Kit command templates evolve across releases; pre-committing locks to point-in-time snapshot. User agency: `--ai` flag lets users choose their AI agent. Templates default to `--ai copilot` but users can re-init with different agent. Template purity: `.specify/` directory is project-specific output, like `.squad/`. Air-gap compatible: Spec Kit bundles core assets in the wheel.

**2. Spec Kit owns specification → planning → task breakdown. Squad owns implementation**

```
Spec Kit                          Squad
────────                          ─────
/speckit.constitution  ──────►  (governs all phases)
/speckit.specify       ──────►  (what to build)
/speckit.plan          ──────►  (how to build it)
/speckit.tasks         ──────►  (actionable breakdown)
                                  ▼
                               squad start / squad assign
                               (agents implement from task list)
```

`/speckit.implement` is superseded by Squad in this workflow. Rather than Spec Kit's generic implement command, Squad's specialized agents pick up the task breakdown and execute with domain expertise. Spec Kit produces the specification artifacts that Squad agents consume. Constitution feeds both tools. The workflow is sequential, not parallel.

**3. 100% base/, 0% overlays**

All Spec Kit integration goes into shared `base/` files. No template-specific overlays needed. Spec Kit is template-agnostic — it doesn't know or care whether you're building a Minimal API or Blazor app. The installation mechanism (uv + specify CLI) is identical for all templates. If a template-specific Spec Kit concern ever arises (e.g., a Blazor-specific constitution preset), that's an overlay addition — but none exist today.

### Implementation

Completed across Phases 1–5:

1. **Dev container (Amos):** `base/.devcontainer/post-create.sh` — Python 3.12 feature + uv + specify-cli@v0.5.0
2. **First-time-setup (Naomi):** `base/.github/prompts/first-time-setup.prompt.md` — New Step 10 (Spec Kit init)
3. **Copilot instructions (Naomi):** `base/.github/copilot-instructions.md` — Development Workflow section + Skills list
4. **README (Naomi):** `base/README.md` — Spec Kit in What's Included + SDD workflow summary
5. **Skill (Naomi):** `base/.copilot/skills/spec-driven-development/SKILL.md` — Full SDD integration guide

### Security Notes

- `curl | sh` for `uv` is the official Astral installer and is SHA-verifiable
- Pinning to release tag (`@v0.5.0`) is mandatory — never install from `main`
- Spec Kit is MIT-licensed (GitHub official project) — no license conflict
- `.specify/` directory should be committed to user's project repo (project's specification source of truth), unlike `output/` which is gitignored

---

## 2026-04-08: Spec Kit as Primary SDD Workflow

**By:** Naomi (Template Engineer)  
**Date:** 2026-04-08  
**Status:** Implemented on `dev`

### Decision

Spec Kit (github/spec-kit) is the primary spec-driven development workflow for all templates. Squad is positioned as the implementation orchestrator after Spec Kit's planning phases.

**Workflow:**
```
Spec Kit (specify → plan → tasks)  →  Squad (implement with specialist agents)
```

- **Spec Kit owns:** requirements capture, specification refinement, constitution governance, technical planning, task decomposition
- **Squad owns:** implementation orchestration, code generation, testing, code review, security review
- **Requirements Interview:** retained as complementary discovery tool for early-stage/vague projects; output feeds into Spec Kit's `/speckit.specify` phase

### Changes

| File | Change |
|------|--------|
| `base/.copilot/skills/spec-driven-development/SKILL.md` | New skill — full SDD integration guide |
| `base/.github/copilot-instructions.md` | Added Development Workflow section; updated Skills list |
| `base/.github/prompts/first-time-setup.prompt.md` | Added Step 10 (Spec Kit init); renumbered; rewrote next-steps |
| `base/.github/prompts/requirements-interview.prompt.md` | Repositioned as complementary; added Spec Kit bridge |
| `base/.copilot/skills/requirements-gathering/SKILL.md` | Updated description for Spec Kit relationship |
| `base/.copilot/skills/squad-setup/SKILL.md` | Added orchestrator positioning |
| `base/README.md` | Spec Kit in What's Included; SDD workflow summary |

### Rationale

- Lee explicitly chose Spec Kit as the SDD workflow tool, paired with Squad as implementation orchestrator
- Clean separation: Spec Kit is unopinionated about implementation tooling; Squad fills that gap
- Constitution concept maps naturally to existing `.github/copilot-instructions.md` — reference, don't duplicate
- Requirements interview adds value for early-stage discovery; not redundant with Spec Kit
- Spec Kit initialization at runtime via `specify init --here --ai copilot`; `.specify/` directory is project-specific

**Commit:** `026d625` on `dev` branch

---

## 2026-04-08: Spec Kit CLI Installation in Dev Container

**By:** Amos (Platform Engineer)  
**Date:** 2026-04-08  
**Status:** Implemented on dev

### Decision

Install Spec Kit CLI (`specify-cli`) in the shared dev container via `uv tool install`, pinned to v0.5.0. Python 3.12 added as a devcontainer feature to provide the required runtime.

### Implementation

- **Python feature:** `ghcr.io/devcontainers/features/python:1` with `version: "3.12"` added to devcontainer.json
- **uv install:** `python3 -m pip install --user --quiet uv` in post-create.sh
- **Spec Kit install:** `uv tool install specify-cli --from "git+https://github.com/github/spec-kit.git@v0.5.0"` — pinned to release tag
- **PATH:** `~/.local/bin` added to .bashrc for uv tools to be available in subsequent shells

### Rationale

- `uv` is Spec Kit's officially recommended package manager
- Pinned to v0.5.0 (latest stable release) for reproducibility
- Used `pip install` for uv (not `curl | sh`) per security review guidance
- Applied to both base and Blazor overlay since overlay replaces base
- Idempotent: `|| true` guards and `uv tool install` is safe to re-run

### Versioning

When Spec Kit releases a new version, update the `@v0.5.0` tag in both `base/.devcontainer/post-create.sh` and `overlays/blazor/.devcontainer/post-create.sh`. The `uv` package manager itself is left unpinned (backward-compatible tool).

---

## 2026-04-08: Disable Squad Workflows via File Rename

**By:** Amos (Platform Engineer)  
**Date:** 2026-04-08  
**Status:** Implemented

### Context

Lee requested Squad workflows be disabled — they're not in active use. The Squad update introduced 7 new and modified 4 existing workflow files in `.github/workflows/`.

### Decision

Disable by renaming `.yml` → `.yml.disabled`. GitHub Actions only processes files with `.yml` or `.yaml` extensions, so renamed files are completely inert.

### Affected Workflows (11)

`squad-ci`, `squad-docs`, `squad-heartbeat`, `squad-insider-release`, `squad-issue-assign`, `squad-label-enforce`, `squad-preview`, `squad-promote`, `squad-release`, `squad-triage`, `sync-squad-labels`

### Unaffected Workflows (2)

`compose-and-publish.yml`, `pr-validate.yml` — confirmed active and unchanged.

### Re-enabling

Rename any `.yml.disabled` file back to `.yml`. No content changes needed.

### Why This Approach

- **Simplest:** One rename per file, no content edits
- **Reversible:** Rename back to restore, full workflow content preserved
- **Clear intent:** `.disabled` suffix is self-documenting
- **Safe:** No risk of partial edits breaking YAML syntax

---

## 2026-04-08: Land Follow-Up Documentation (PR #26)

**By:** Holden (Lead)  
**Date:** 2026-04-08  
**Status:** Completed

### Context

After PR #25 merged (Squad update + workflow disable), Amos committed a follow-up on dev (`a2c894e`) adding his session history and the decision record for the workflow disable approach. This commit was not included in PR #25.

### Review

- **Files changed:** `.squad/agents/amos/history.md`, `.squad/decisions/inbox/amos-disable-squad-workflows.md`
- **Risk:** Zero — docs-only, no code, no config, no security surface
- **Accuracy:** Verified against PR #25 content — history and decision record are factually correct
- **Pattern compliance:** Follows project conventions for agent history and decision recording

### Decision

Approved and shipped via PR #26 (dev → main, merge commit). Main now fully catches up to dev.

### Rationale

Documentation trail for team decisions should not lag behind the implementation. Landing promptly keeps the project's decision record authoritative and current.

---

## Governance

- All meaningful changes require team consensus
- Document architectural decisions here
- Keep history focused on work, decisions focused on direction
