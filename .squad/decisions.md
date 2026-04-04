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

## Governance

- All meaningful changes require team consensus
- Document architectural decisions here
- Keep history focused on work, decisions focused on direction
