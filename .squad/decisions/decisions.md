# Decisions

---

## Security Review — Spec Kit Integration

**By:** Drummer (Security Reviewer)  
**Date:** 2026-04-08  
**Verdict:** ✅ APPROVED (with non-blocking recommendations)

### Scope

All artifacts introduced or modified by the Spec Kit integration on `dev`:

- `base/.devcontainer/devcontainer.json` — Python 3.12 feature added
- `base/.devcontainer/post-create.sh` — uv + Spec Kit CLI install (pinned v0.5.0)
- `overlays/blazor/.devcontainer/devcontainer.json` — Python 3.12 feature added
- `overlays/blazor/.devcontainer/post-create.sh` — uv + Spec Kit CLI install (pinned v0.5.0)
- `base/.github/copilot-instructions.md` — SDD workflow section, updated skills list
- `base/.github/prompts/first-time-setup.prompt.md` — Step 10 (Spec Kit init), renumbered steps
- `base/.github/prompts/requirements-interview.prompt.md` — Spec Kit relationship context
- `base/README.md` — Spec Kit + Squad workflow documentation
- `base/.copilot/skills/spec-driven-development/SKILL.md` — New skill (233 lines)
- `base/.copilot/skills/requirements-gathering/SKILL.md` — Spec Kit relationship added
- `base/.copilot/skills/squad-setup/SKILL.md` — Spec Kit handoff context added

### Security Positives

1. **Spec Kit CLI is version-pinned (`v0.5.0`)** in both post-create.sh scripts — reproducible builds
2. **Source is GitHub-owned** (`github/spec-kit`) — trusted origin
3. **`set -euo pipefail`** in both scripts — fail-fast on errors
4. **No secrets, credentials, or PII introduced** anywhere in the changeset
5. **No insecure auth patterns** — no token handling, no credential storage
6. **Security Setup step preserved** (renumbered to Step 11) — `.gitignore` review, user-secrets, secret scanning, branch protection all intact
7. **Constitution patterns include compliance references** — enterprise projects guided to reference compliance skills
8. **`uv tool install` uses `--from` with explicit Git URL** — no ambiguous package name resolution

### Non-Blocking Findings

- **F1 — Version inconsistency:** `@latest` in init vs `v0.5.0` in install (fixed by Amos)
- **F2 — `curl | sh` fallback:** Anti-pattern documented as fallback (fixed by Amos)
- **F3 — `uv` unpinned:** Recommend future hardening
- **F4 — Git tag mutable:** Consider commit SHA pin in future

### Verdict

**✅ APPROVED.** No revision required. Security posture reasonable for enterprise templates.

---

## Decision: Spec Kit Integration Review — Holden's Verdict

**By:** Holden (Lead)  
**Date:** 2026-04-08  
**Status:** APPROVED with two required revisions before merging to main

### Scope

Reviewed combined Spec Kit integration change set on `dev` (commits `57e32b9`, `026d625`, `39911d8`, `50ce019`) against approved integration shape. 16 files changed, 466 insertions, 15 deletions.

### Verdict: ✅ APPROVED (with conditions)

The architecture is correct. Spec Kit is properly placed in `base/`, overlay duplicates devcontainer changes correctly, Spec Kit + Squad pairing is coherent, workspace conventions preserved.

### Required Revisions (blocking merge to main)

#### Issue 1 — Version pinning contradiction (Naomi → reassigned to Amos)

**Artifacts:**
- `base/.github/prompts/first-time-setup.prompt.md` (line 119)
- `base/.copilot/skills/spec-driven-development/SKILL.md` (line 39)

**Problem:** Both use `uvx --from git+https://github.com/github/spec-kit.git@latest` to initialise Spec Kit. Post-create.sh correctly installs `specify-cli` pinned to `@v0.5.0`. Using `@latest` undermines reproducibility.

**Fix:** Replace `uvx` command with direct call to pre-installed binary: `specify init --here --ai copilot`. This is simpler, faster, and uses pinned version from post-create.sh.

**Status:** ✅ RESOLVED by Amos

#### Issue 2 — `curl | sh` in fallback contradicts security choice (Naomi → reassigned to Amos)

**Artifact:** `base/.github/prompts/first-time-setup.prompt.md` (line 129)

**Problem:** Step 10 fallback recommends `curl -LsSf https://astral.sh/uv/install.sh | sh`. Amos deliberately chose `pip install uv` to avoid curl-pipe-sh pattern. Fallback must not contradict.

**Fix:** Replace with `python3 -m pip install --user uv` and `export PATH="$HOME/.local/bin:$PATH"`.

**Status:** ✅ RESOLVED by Amos

### What's Correct (no changes needed)

- ✅ Placement (100% base/ + overlay duplication)
- ✅ devcontainer.json (Python 3.12 feature)
- ✅ post-create.sh (pip install uv, pinned @v0.5.0, || guards, PATH export)
- ✅ copilot-instructions.md (SDD workflow, when-to-use table, skills list)
- ✅ first-time-setup.prompt.md (Step 10 placement, renumbered steps)
- ✅ requirements-interview.prompt.md (complementary positioning, Spec Kit bridge)
- ✅ README.md (What's Included, Development Workflow section)
- ✅ Skill documentation (requirements-gathering, squad-setup, spec-driven-development)
- ✅ Overlay semantics (Blazor overlay mirrors base correctly)
- ✅ Spec Kit + Squad pairing (coherent workflow, clean separation)

### Non-Blocking Improvements (can land later)

1. **`/speckit.implement` ambiguity:** Phase 5 shows both options; add note that Squad is preferred path
2. **Blazor overlay sync discipline:** Document manual update requirement when base devcontainer changes

---

## Decision: Spec Kit Revision Reassignment — Lockout Compliance

**By:** Holden (Lead)  
**Date:** 2026-04-08  
**Status:** Reassigned to Amos (Platform Engineer)

### Context

Holden's review approved Spec Kit integration with two required revisions, both assigned to Naomi. Under reviewer lockout, Naomi — as the original author of rejected artifacts — is forbidden from producing the next revision. A different agent must make the fixes.

### Reassignment

**Revising agent:** Amos (Platform Engineer)

**Rationale:** Both issues are about aligning user-facing content with platform decisions Amos already made. He authored `post-create.sh` with the pinned `@v0.5.0` install and deliberate `pip install uv` security choice. He understands technical constraints better than anyone and is not the original author of either artifact.

### Required Changes (restated for Amos)

#### Fix 1 — Remove `@latest` version pinning contradiction

**Files:**
- `base/.github/prompts/first-time-setup.prompt.md` (line 119)
- `base/.copilot/skills/spec-driven-development/SKILL.md` (line 39)

**What to change:** Replace `uvx` command with `specify init --here --ai copilot` (pre-installed, pinned). Update SKILL.md primary path same way; keep `uvx` alternative pinned to `@v0.5.0`, not `@latest`. Fix Prerequisites note to use `pip install uv` instead of `curl | sh`.

**Status:** ✅ COMPLETED by Amos

#### Fix 2 — Remove `curl | sh` fallback

**File:** `base/.github/prompts/first-time-setup.prompt.md` (lines 127–131)

**What to change:** Replace fallback with `python3 -m pip install --user uv` and `export PATH="$HOME/.local/bin:$PATH"`.

**Status:** ✅ COMPLETED by Amos

### Review Gate

After Amos completes revision, Holden will re-review the two files. Naomi is eligible to review since she is no longer the author.

---

## Security Re-Review — Spec Kit Revised Artifacts

**By:** Drummer (Security Reviewer)  
**Date:** 2026-04-08  
**Verdict:** ✅ APPROVED

### Scope

Re-review of two artifacts revised by Amos per lockout-compliant reassignment:

1. `base/.github/prompts/first-time-setup.prompt.md`
2. `base/.copilot/skills/spec-driven-development/SKILL.md`

### Previous Findings (Status)

| Issue | Description | Status |
|-------|-------------|--------|
| **Issue 1** — `@latest` contradiction | `uvx --from ...@latest` contradicted pinned `@v0.5.0` install in post-create.sh | **RESOLVED** |
| **Issue 2** — `curl \| sh` fallback | Fallback used `curl -LsSf ...` despite deliberate `pip install` choice | **RESOLVED** |

### Verification

#### Issue 1 — Version pinning: RESOLVED ✅

- **first-time-setup.prompt.md** Step 10 (line 119): Uses `specify init --here --ai copilot` — pre-installed binary, no `@latest`
- **SKILL.md** primary path (line 41): Uses `specify init --here --ai copilot` — pre-installed binary
- **SKILL.md** standalone alternative (line 47): Uses `uvx --from "git+https://github.com/github/spec-kit.git@v0.5.0"` — correctly pinned
- **Consistency confirmed:** All three artifacts reference same `v0.5.0` version. No `@latest` appears.

#### Issue 2 — `curl | sh` removal: RESOLVED ✅

- **first-time-setup.prompt.md** fallback (lines 131–135): Now `python3 -m pip install --user uv` with `export PATH`. No `curl | sh`.
- **SKILL.md** Prerequisites (line 32): Fallback reads "install via `python3 -m pip install --user uv`". No `curl | sh`.
- **Full base/ sweep:** `grep -rn 'curl.*|.*sh' base/` returns zero results. Pattern eliminated project-wide.

### Security Posture

- No new concerns introduced by revision
- Install/runtime version consistency airtight across post-create.sh ↔ first-time-setup ↔ SKILL.md
- All fallback paths use package registry (pip) rather than arbitrary shell script
- Pre-existing non-blocking findings (F3, F4) remain tracked and unchanged

### Verdict

**✅ APPROVED.** Both required revisions correctly implemented. Version inconsistency and curl|sh fallback fully eliminated. No further revision required.

---

## Decision Summary

**Project:** TheSereyn.Templates  
**Batch:** Spec Kit Integration (Batch 2)  
**Final Status:** ✅ APPROVED FOR MERGE TO MAIN  

**Review Cycle:**
1. Drummer initial review → ✅ Approved (non-blocking recommendations)
2. Holden lead review → ✅ Approved with 2 required revisions
3. Lockout reassignment to Amos → ✅ Completed
4. Drummer re-review → ✅ Approved (all issues resolved)
5. Holden re-review → ✅ Approved for merge

**Key Achievements:**
- Version consistency: All artifacts pinned to `v0.5.0` (no `@latest` drift)
- Security posture: Curl-pipe-sh pattern eliminated; pip install used consistently
- Architecture: Sound placement (base/ + overlay duplication), Spec Kit + Squad pairing coherent
- Reviewer workflow: Lockout applied and resolved correctly; team dynamics preserved

**Ready State:** Merge to main; tag v* for compose-and-publish workflow.
