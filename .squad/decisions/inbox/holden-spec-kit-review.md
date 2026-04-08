# Decision: Spec Kit Integration Review — Holden's Verdict

**By:** Holden (Lead)  
**Date:** 2026-04-08  
**Status:** APPROVED with two required revisions before merging to main

---

## Scope

Reviewed the combined Spec Kit integration change set on `dev` (commits `57e32b9`, `026d625`, `39911d8`, `50ce019`) against the approved integration shape in `holden-spec-kit-integration.md`. 16 files changed, 466 insertions, 15 deletions.

## Verdict: ✅ APPROVED (with conditions)

The architecture is correct. Spec Kit is properly placed in `base/`, the Blazor overlay correctly duplicates the devcontainer changes (because overlay replaces base), the Spec Kit + Squad pairing is coherent across all artifacts, and the workspace conventions are preserved. Two localised issues must be fixed before this lands on `main`.

---

## Required Revisions (blocking merge to main)

### Issue 1 — Version pinning contradiction (Naomi)

**Artifacts:**
- `base/.github/prompts/first-time-setup.prompt.md` (line 119)
- `base/.copilot/skills/spec-driven-development/SKILL.md` (line 39)

**Problem:** Both use `uvx --from git+https://github.com/github/spec-kit.git@latest` to initialise Spec Kit. The approved decision mandates pinning to a specific release tag (`@v0.5.0`). Meanwhile, `post-create.sh` correctly installs `specify-cli` pinned to `@v0.5.0`. Using `@latest` in user-facing prompts undermines the reproducibility guarantee.

**Fix:** In Step 10 of first-time-setup, replace the `uvx` command with a direct call to the pre-installed binary:

```bash
specify init --here --ai copilot
```

This is simpler, faster (no download), and uses the pinned version from post-create.sh. The SKILL.md installation section should also use the pre-installed binary as the primary path, with `uvx --from ...@v0.5.0` as an alternative for manual installs (pinned, not `@latest`).

**Owner:** Naomi

### Issue 2 — `curl | sh` in fallback contradicts security choice (Naomi + Drummer)

**Artifact:** `base/.github/prompts/first-time-setup.prompt.md` (line 129)

**Problem:** The Step 10 fallback note recommends `curl -LsSf https://astral.sh/uv/install.sh | sh` for uv installation. Amos deliberately chose `python3 -m pip install --user uv` to avoid the curl-pipe-sh pattern per security guidance. The fallback shouldn't contradict that choice.

**Fix:** Replace the fallback with:

```bash
python3 -m pip install --user uv
export PATH="$HOME/.local/bin:$PATH"
```

Or Drummer formally approves the curl | sh pattern for the fallback path.

**Owner:** Naomi (fix), Drummer (if keeping curl | sh, approve explicitly)

---

## What's Correct (no changes needed)

| Aspect | Assessment |
|--------|-----------|
| **Placement** | ✅ 100% base/ + overlay duplication where overlay replaces base. No unnecessary overlay-only content |
| **devcontainer.json** | ✅ Python 3.12 feature added to both base and Blazor overlay |
| **post-create.sh** | ✅ `pip install uv` (not curl), pinned `@v0.5.0`, `|| true` guards, PATH export in .bashrc |
| **copilot-instructions.md** | ✅ Development Workflow section, When-to-Use table, Skills list updated |
| **first-time-setup.prompt.md** | ✅ Step 10 placement, renumbered 11/12, next steps rewritten for SDD flow |
| **requirements-interview.prompt.md** | ✅ Repositioned as complementary, Spec Kit bridge in next steps |
| **README.md** | ✅ What's Included updated, Development Workflow section added |
| **requirements-gathering SKILL.md** | ✅ Description updated, Spec Kit relationship section added |
| **squad-setup SKILL.md** | ✅ Orchestrator positioning, handoff diagram |
| **spec-driven-development SKILL.md** | ✅ Comprehensive 233-line skill, high quality (except @latest — see Issue 1) |
| **Overlay semantics** | ✅ Blazor overlay changes mirror base changes (correct — overlay replaces base) |
| **Spec Kit + Squad pairing** | ✅ Coherent workflow across all 10 artifacts. Clean separation of concerns |

---

## Non-Blocking Improvements (can land later)

1. **`/speckit.implement` ambiguity in SDD SKILL.md:** Phase 5 shows both `/speckit.implement` and `@squad` as implementation options. The decision says Squad supersedes `/speckit.implement` in this workflow. Consider adding a note to the command table (line 73) like "Execute the implementation (or hand off to Squad)" and stronger guidance in Phase 5 that Squad is the preferred path.

2. **Blazor overlay sync discipline:** When base devcontainer files change, overlay copies must be manually updated. Consider documenting this in the compose workflow or adding a CI check that flags drift between base and overlay copies of shared sections.

---

## Process Notes

- Amos (Platform Engineer) delivered clean devcontainer changes with correct security posture (`pip install uv`, not `curl | sh`)
- Naomi (Template Engineer) delivered comprehensive content changes across 7 files with consistent messaging
- The only issues are localised to one prompt and one skill — the architecture is sound
- Drummer review of the curl | sh fallback path is still pending
