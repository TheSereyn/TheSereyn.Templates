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

## Governance

- All meaningful changes require team consensus
- Document architectural decisions here
- Keep history focused on work, decisions focused on direction
