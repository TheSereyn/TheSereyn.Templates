# Decisions

---

## Decision: Full Setup Shape — Compliance UX Proposal

**By:** Naomi (Template Engineer)  
**Date:** 2026-04-14  
**Status:** Approved — implementation pending  

## Summary

Proposed 10-step project-setup with security at Step 2 (non-negotiable), compliance at Step 8 (skippable with "Skip for now"), and a dedicated `/compliance-setup` prompt for first-time or revision use.

## Key Design Points

- **Lean compliance in setup:** 2 questions only (framework checklist + known constraints)
- **Dedicated `/compliance-setup`:** Idempotent, per-framework deep questions capped at 3 per framework
- **"Too much" thresholds:** >10 min total, >15 questions, >80% skip rate triggers fallback to compliance-only-via-prompt
- **Estimated timing:** ~4 min (skip) / ~6 min (answer)

## Recommendation

Ship full version. Fallback is removing compliance from setup entirely and relying on `/compliance-setup` — clean cut, no lost capability.

---

## Decision: Compliance Scope — Full Setup + Skip-Later Model

**By:** Drummer (Security Reviewer)  
**Date:** 2026-04-14  
**Status:** Approved — implementation pending  

## Context

Defines minimum safe scope for initial setup when supporting skip-later compliance via `/compliance-setup`.

## Non-Negotiable in Initial Setup (3 items — ~2 minutes)

| Item | Why | Skip Risk |
|------|-----|-----------|
| `.gitignore` verification | Committed secrets are permanent in git history | **Irrecoverable** — secret rotation, history rewrite, credential compromise |
| `dotnet user-secrets init` | Developers need secret store before writing config code | Without it, `appsettings.json` becomes the path of least resistance |
| Branch protection on `main` | First PR can merge unreviewed without this | Unreviewed code in main during formative period |

### The Compliance Question (1 item — ~30 seconds)

The question "Does this project need to comply with any frameworks?" **must be asked**, but "Skip / Not sure yet" is a valid answer.

- **Why the question stays:** Answering "GDPR" before writing code means Copilot suggests compliance from start (data protection by design, not retrofit)
- **What happens on answer:** Lightweight wiring only — write frameworks to `copilot-instructions.md`, append skills. Done.
- **What happens on skip:** Note "Compliance: not yet configured" in `copilot-instructions.md`. Print nudge: "Run `/compliance-setup` before your first feature." Move on.

## Moves to `/compliance-setup`

- Framework explanations (educational content)
- `docs/planning/compliance-notes.md` creation (stub has no value until populated)
- Detailed compliance skill walkthrough
- Multi-framework interaction guidance
- GitHub Secret Scanning enablement (retroactive scanning works)
- Compliance audit checklist generation (future capability)

## Proposed `/compliance-setup` Structure

- **Step 1:** Current State Assessment (detect existing compliance declarations)
- **Step 2:** Framework Selection (with context and trigger guidance)
- **Step 3:** Wiring (update copilot-instructions.md, create compliance-notes.md, enable Secret Scanning)
- **Step 4:** Framework-Specific Guidance (per-framework design implications)
- **Step 5:** Verify & Summary (confirm skills registered, print changes, suggest next steps)

### Key Design Principles

- **Idempotent:** Safe to run multiple times. Detects existing state and offers update/add/remove.
- **Standalone:** Works whether or not initial setup was completed. No dependency on setup having run first (beyond project existing).
- **Additive:** Adding PCI DSS six months in doesn't break existing GDPR configuration.
- **Skip-friendly:** "None needed" is always valid. No guilt-tripping — just clear consequences.

## The "Too Detailed" Line

The initial setup becomes too detailed when it crosses these thresholds:

| Signal | Threshold | Current State |
|--------|-----------|---------------|
| Total steps | > 13 | 13 (at limit) ✅ |
| Compliance section asks more than one question | > 1 question | 1 question ✅ |
| Any step requires domain expertise to answer | User needs to research | Framework list is recognisable ✅ |
| Any step takes > 3 minutes | > 3 min per step | All steps < 3 min ✅ |
| Compliance explanation exceeds "pick from list" | Paragraphs of framework description | Currently just a list ✅ |

**The Rule:** Initial setup asks "which?" — `/compliance-setup` explains "what and how." If the initial setup ever starts explaining what GDPR *requires*, or what PCI DSS controls *mean*, it has crossed the line.

## Recommendation

The hybrid model — full setup with lightweight compliance question + dedicated `/compliance-setup` prompt — gives the best of both worlds:

1. **Security hardening stays non-negotiable** (3 items, ~2 minutes, no skip option)
2. **Compliance question stays early** (1 question, ~30 seconds, skip allowed)
3. **Compliance depth moves to dedicated prompt** (run anytime, idempotent, framework-aware)
4. **Skip path is clean** — "Not sure yet" writes a marker, nudges toward `/compliance-setup`, moves on
5. **Update path exists** — project pivots to handle payments? Run `/compliance-setup`, add PCI DSS, done

The skip allowance is acceptable because `/compliance-setup` is a proper prompt (not just documentation), it's idempotent, and setup can add a soft reminder ("Compliance: not yet configured — run `/compliance-setup`").

---

## Decision: User Directive — Full Setup with Skip-Later Compliance

**By:** Lee Buxton  
**Date:** 2026-04-14  
**Status:** Captured for team memory  

## Request

Prefer a full setup flow for compliance and security if it stays sensible, but support skipping unknown compliance answers during initial setup and add a dedicated compliance prompt so projects can complete or revise compliance configuration later.

## Rationale

User preference to keep initial experience efficient while preserving ability to configure compliance thoroughly when ready or when requirements become clearer.

---

## Decision: First-Time Setup Collects Project Context and Rewrites README

**By:** Naomi (Template Engineer)
**Date:** 2026-04-14
**Status:** Implemented on `dev`

## Decision

The first-time-setup prompt now collects richer project context (problem/purpose, key capabilities, target users) and uses it to fully rewrite `README.md` as a project README — not just replace placeholders.

## Changes

| File | Change |
|------|--------|
| `base/.github/prompts/first-time-setup.prompt.md` | Step 4 expanded (3 new questions); Step 5 narrowed (excludes README); new Step 6 (Rewrite README with structure, removal, and credit-line guidance); Steps 6–12 renumbered to 7–13 |
| `base/.github/prompts/requirements-interview.prompt.md` | Added "Update README" as step 4 in Next Steps — ties interview output back to README refinement |
| `base/README.md` | Template note reframed: explains README will be rewritten during setup |
| `overlays/minimalapi/README.md` | Added setup-rewrite note below template heading |
| `overlays/blazor/README.md` | Added setup-rewrite note below template heading |
| `overlays/cli/README.md` | Added setup-rewrite note below template heading |

## Rationale

- Template READMEs previously survived setup mostly intact — they still read like template instructions after placeholder replacement
- New repos should have a README that describes the actual project: what it does, why it exists, who it's for
- Collecting problem/purpose, capabilities, and target users gives Copilot enough context to write a real project README
- Template-origin references reduced to a single credit line at the bottom
- All three templates (MinimalApi, Blazor, CLI) benefit equally since the prompt is in base/

## Impact

Applies to all downstream templates. No overlay-specific prompt changes needed — the rewrite step reads the current README (which varies by template) and adapts accordingly.

---

## Decision: Prompt Guidance Review — README Rewrite Flow

**By:** Holden (Lead)  
**Date:** 2026-04-14  
**Commit reviewed:** `2f86516`  
**Verdict:** ✅ APPROVED

## What Changed

Naomi expanded first-time-setup to collect project context (problem/purpose, capabilities, target users) in Step 4, then added Step 6 (Rewrite README) with explicit structure, removal list, and a single credit line. All three overlay READMEs and the base README now set expectations that the file will be rewritten during setup. Requirements interview ties back to README update as a next step.

## Review Criteria

| Criterion | Assessment |
|-----------|------------|
| Meets user goal across all three templates | ✅ Single shared prompt serves MinimalApi, Blazor, CLI identically |
| README-rewrite guidance prevents template-sounding repos | ✅ Explicit removal list (template headings, AI-first notes, What's Included table, setup instructions) + tone instruction |
| Properly centralised, no unnecessary duplication | ✅ Core logic in base prompt; overlay READMEs only add a 2-line note (necessary since they replace base) |
| Composition verified | ✅ All three templates compose successfully |

## Notes

- Step 5 correctly excludes README.md from placeholder resolution — avoids wasted work before full rewrite.
- Architecture sections in overlay READMEs say "This template is designed for..." — the rewrite guidance explicitly handles this with reframing instruction.
- Credit line is minimal: one blockquote at EOF. Satisfies "only minimal references to the starter template."
- Requirements interview next-step (item 4) is appropriately soft ("consider updating") since it's post-setup context enrichment, not mandatory.

---

## User Directive: Setup Prompt Guidance for All Templates

**By:** Lee Buxton (via Copilot)  
**Date:** 2026-04-14T18:39:36Z  

**What:** Update the initial prompt guidance for all three templates so setup collects project-specific information and rewrites the README to fit the actual project, leaving only minimal references to the starter template.

**Why:** User request — captured for team memory

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

---

## Security Review — Main Branch (Comprehensive)

**By:** Drummer (Security Reviewer)  
**Date:** 2026-04-08  
**Scope:** Full main branch — all input artifacts plus workflows, compose script, MCP configs  
**Verdict:** CONDITIONAL — No critical blockers, but 4 HIGH findings require remediation before next release tag

### HIGH Findings

#### H1: Unpinned npm packages in post-create.sh — supply chain risk

**Files:** `base/.devcontainer/post-create.sh:31`, `overlays/blazor/.devcontainer/post-create.sh:31,86`  
**CWE:** CWE-829 (Inclusion of Functionality from Untrusted Control Sphere)

- `npm install -g @bradygaster/squad-cli` — no version pinned. Installs whatever is currently latest on npm.
- `npm install -g @playwright/cli@latest` (Blazor overlay) — explicitly requests mutable latest tag.

**Risk:** A compromised or malicious npm publish replaces the package. Every new dev container silently installs the compromised version. This is the most common supply chain attack vector in the npm ecosystem.

**Fix:** Pin to specific semver versions: `npm install -g @bradygaster/squad-cli@<version>`. When updating, change the version explicitly and review the changelog.

**Assign to:** Amos (Platform Engineer)

#### H2: MCP server configs use `npx -y` with unpinned packages

**Files:** `base/.copilot/mcp-config.json:11-13`, `overlays/blazor/.copilot/mcp-config.json:11-13,18-20`

- `@anthropic/github-mcp-server` — launched via `npx -y` without version pinning (both base and Blazor)
- `@playwright/mcp` — launched via `npx -y` without version pinning (Blazor only)

**Risk:** `npx -y` auto-installs the latest version from npm without user confirmation. A typosquat or compromised package version executes arbitrary code in the developer's environment with full file system and network access. MCP servers have elevated privilege — they're invoked by Copilot with tool access.

**Fix:** Pin versions: `"args": ["-y", "@anthropic/github-mcp-server@<version>"]`. Alternatively, pre-install in post-create.sh and use `"command": "node"` with a direct path.

**Assign to:** Amos (Platform Engineer)

#### H3: MSDOCS skill files fetched from mutable `main` branch without integrity verification

**Files:** `base/.devcontainer/post-create.sh:41-50`, `overlays/blazor/.devcontainer/post-create.sh:41-50`

```bash
MSDOCS_RAW="https://raw.githubusercontent.com/microsoftdocs/mcp/main"
curl -sL "$MSDOCS_RAW/skills/$skill/SKILL.md" -o "$SKILLS_DIR/$skill/SKILL.md" || true
```

- Fetches from `main` branch — content can change at any time
- No checksum, no signature verification
- `|| true` silently swallows download failures (could mask MITM or DNS hijack)
- Downloads Markdown files that become Copilot skill instructions — injected content could influence all AI-generated code

**Risk:** Compromise of microsoftdocs/mcp main branch (or a force-push) injects adversarial instructions into developer skill files. This is a prompt injection via supply chain.

**Fix:** Pin to a specific commit SHA: `https://raw.githubusercontent.com/microsoftdocs/mcp/<SHA>/skills/...`. Add a SHA256 checksum verification step after download.

**Assign to:** Amos (Platform Engineer)

#### H4: `.gitignore` missing certificate and private key patterns

**File:** `base/.gitignore`

The first-time-setup prompt Step 11 instructs: *"confirm `*.pfx`, `*.key`, and `.env` files are excluded"* — but the `.gitignore` does **not** include `*.pfx`, `*.key`, or `*.pem` patterns. `.env` is covered. Certificate/key patterns are not.

**Risk:** A developer follows Step 11, sees no error (the instruction says "confirm"), and assumes keys are protected. A `*.pfx` or `*.key` file committed to the repo exposes private keys to anyone with repo access.

**Fix:** Add to `base/.gitignore`:
```
# Certificates and private keys
*.pfx
*.key
*.pem
```

**Assign to:** Naomi (Template Engineer)

### MEDIUM Findings

#### M1: TEMPLATE_PUSH_TOKEN is a PAT with cross-repo write access

**File:** `.github/workflows/compose-and-publish.yml:60`

A personal access token (PAT) grants write access to all downstream template repos. PATs are user-scoped, creating a bus-factor risk and a lateral movement vector if the account is compromised.

Additionally, `git config --global credential.helper store` persists the token to disk during the workflow run (line 63). While ephemeral (runner is destroyed after the job), it's not the cleanest pattern.

**Recommendation:** Replace with a GitHub App installation token scoped to specific repositories. This also enables audit logging per-app rather than per-user.

**Pre-existing:** Tracked since Session 2.

#### M2: Blazor post-create.sh has redundant Playwright MCP injection

**File:** `overlays/blazor/.devcontainer/post-create.sh:68-83`

Inline Python code modifies `mcp.json` to add a Playwright MCP entry using `npx -y @playwright/mcp`. This is redundant with the static entry in `overlays/blazor/.copilot/mcp-config.json:18-20`. The inline code path is an unnecessary second attack surface with the same unpinned `npx -y` risk as H2.

**Recommendation:** Remove the inline Python MCP injection. The static `mcp-config.json` already configures Playwright MCP.

#### M3: Dependabot PR for actions/checkout pending

**Branch:** `dependabot/github_actions/actions/checkout-6.0.2`

The current SHA `11bd71901bbe5b1630ceea73d27597364c9af683` (v4.2.2) has a pending Dependabot update to 6.0.2. The SHA-pinning practice is excellent, but the update should be reviewed and merged.

**Recommendation:** Review and merge the Dependabot PR.

#### M4: Devcontainer features pinned to major version only

**Files:** Both `devcontainer.json` files

All features use `:1` tag (e.g., `ghcr.io/devcontainers/features/node:1`). Minor/patch updates auto-apply. For enterprise environments requiring reproducible builds, consider SHA pinning.

**Recommendation:** Document the trade-off. For enterprise deployments, consider pinning to minor versions at minimum.

### LOW Findings

#### L1: `uv` pip install not version-pinned

**Pre-existing (Session 2).** `python3 -m pip install --user --quiet uv` — no version. Low risk: build tool, not runtime.

#### L2: `|| true` patterns suppress failure signals

Multiple `|| true` guards in post-create.sh mask installation failures. A failed install is indistinguishable from a successful one until the developer tries to use the tool.

#### L3: squad-setup SKILL.md recommends `@latest` for upgrades

`base/.copilot/skills/squad-setup/SKILL.md:82` — `npm install -g @bradygaster/squad-cli@latest`. Documentation, not automation, but sets a precedent. Should recommend specific version.

#### L4: First-time-setup Step 11 wording misleads on `.gitignore` coverage

Step 11 says *"confirm `appsettings.*.json`, `*.pfx`, `*.key`..."* but the gitignore only covers `appsettings.Local.json` and `appsettings.*.Local.json` (which is correct — `appsettings.Development.json` should be tracked). The step text should clarify that *`*.Local.json`* patterns are what's excluded, and that `*.pfx`/`*.key` must be added (see H4).

### Positive Observations (Security Wins)

1. ✅ GitHub Actions pinned to full commit SHAs in both active workflows
2. ✅ Spec Kit CLI pinned to release tag v0.5.0 via `uv tool install`
3. ✅ `curl | sh` pattern eliminated project-wide (confirmed: `grep -rn 'curl.*|.*sh'` returns zero)
4. ✅ `set -euo pipefail` in all shell scripts
5. ✅ Workflow permissions minimized (`contents: read`)
6. ✅ Guard job verifies tag is on `main` before publishing
7. ✅ ISO 27001 skill updated to 2022 framework with correct control numbering
8. ✅ Comprehensive security skill tree (20+ domain-specific skills)
9. ✅ Security Principles section covers OWASP Top 10, CSRF, CORS, CSP, PKCE, DPoP
10. ✅ `remoteUser: vscode` — not running as root in dev containers
11. ✅ No prompt injection risks in any prompt files
12. ✅ All prompts properly scoped (`mode: agent` / `mode: text`)
13. ✅ No credentials stored in project files
14. ✅ Spec Kit integration follows secure patterns (pinned, GitHub-owned source, local-only init)

### Prompt Safety Assessment

- **pre-container-setup.prompt.md** — Clean. Uses `gh auth login` (browser OAuth), no PAT handling, HTTPS clone URLs.
- **first-time-setup.prompt.md** — Clean. No credential instructions. Security setup step is a net positive.
- **requirements-interview.prompt.md** — Clean. Correctly scoped to interview only ("don't write code").
- **spec-driven-development/SKILL.md** — Clean. No executable patterns that bypass security controls.
- **requirements-gathering/SKILL.md** — Clean. Discovery methodology, no code generation.

### Summary

The security posture on `main` is solid for a template project. The Spec Kit integration landed cleanly with good supply chain practices (v0.5.0 pinning, no `curl | sh`). The 4 HIGH findings are all supply chain / install-safety issues in the dev container setup that pre-date or are adjacent to the Spec Kit work. H4 (missing gitignore patterns) is a gap between what the setup prompt promises and what the template delivers. None are critical/exploitable today, but all should be addressed before the next version tag ships templates to downstream consumers.

---

## Decision: Solution Scaffolding Out of Scope

**By:** Coordinator (via user directive from Lee Buxton)  
**Date:** 2026-04-08T10:44:38Z  
**Status:** DECISION CAPTURED

### Directive

Solution scaffolding remains intentionally out of scope for now. These templates are **environment templates** that provide:
- The development environment (dev containers, tools, language runtime)
- Workflow scaffolding (prompts, skills, Spec Kit integration, Squad workspace)

They do **not** provide:
- Solution/project scaffolding (project structure, sample code, starter files)

### Rationale

Templates are environment-first. Solution scaffolding would diverge across team preferences and project types. The environment + workflow provide the foundation; users bring their own solution shape.

### Implications

- Squad prompts guide users toward Spec Kit for solution definition
- `requirements-gathering` and `spec-driven-development` skills bridge environment → solution
- Architecture templates (MinimalApi, Blazor) are environment templates, not solution generators

---

## Decision: Remediation Batch Approved for Merge to Main

**By:** Holden (Lead) + Drummer (Security Reviewer)  
**Date:** 2026-04-08  
**Status:** APPROVED

### Summary

All HIGH findings (H1–H4) from main-branch security review are resolved on `dev`. Spec Kit integration architecture is sound. All reviews passed. Merge to main approved; ready for v* tag.

### Resolved Findings

- **H1:** Unpinned npm packages → Centralised version pinning (post-create-shared.sh)
- **H2:** MCP npx with unpinned versions → All packages version-pinned (@modelcontextprotocol/server-github@2025.4.8, @playwright/mcp@0.0.70)
- **H3:** MSDOCS mutable main branch → Pinned to commit SHA 933e0c5044b938cbeb23709e1cb125c8d93395c0 with fatal error handling
- **H4:** Missing certificate patterns in gitignore → Added *.pfx, *.key, *.pem, *.p12, *.cer

### Key Artifacts

- `post-create-shared.sh` — Centralised devcontainer setup (new)
- `verify-setup.prompt.md` — Environment health check (new)
- `pr-validate.yml` — Devcontainer drift detection (enhanced)
- `compose-and-publish.yml` — Pre-flight token validation (enhanced)

### Next Steps

1. Merge dev to main
2. Tag with v* (e.g., v1.0.0-spec-kit-hardening)
3. Trigger compose-and-publish workflow
4. Publish to downstream templates (MinimalApi, Blazor)


---

## Decision: Replace docker-outside-of-docker with docker-in-docker

**By:** Amos (Platform Engineer)
**Date:** 2026-04-09
**Status:** Superseded (see Naomi's final decision below)

### Context

The `docker-outside-of-docker` devcontainer feature bind-mounts the host's `/var/run/docker.sock` into the container. On Podman hosts, this file does not exist — causing container creation to fail entirely. This broke Podman support, which was previously working.

### Initial Decision

Replace `ghcr.io/devcontainers/features/docker-outside-of-docker:1` with `ghcr.io/devcontainers/features/docker-in-docker:2` in both the base and Blazor overlay devcontainer.json files.

### Rationale (Initial)

- Runs its own Docker daemon (Moby engine) inside the container
- Zero dependency on the host's container runtime or socket
- Works identically on Docker, Podman, and GitHub Codespaces hosts

### Known Limitation

On rootless Podman hosts (the default), `dockerd` inside the container fails to start if the host doesn't grant sufficient privileges. The container itself builds and runs fine — only Docker commands inside would be unavailable.

### Files Changed

- `base/.devcontainer/devcontainer.json` — feature swap
- `overlays/blazor/.devcontainer/devcontainer.json` — feature swap

### Outcome

Interim fix identified a blocker: `docker-in-docker:2` requires `"privileged": true`, which breaks rootless Podman (the default Podman configuration). See Naomi's final decision for the complete fix.

---

## Decision: Remove Docker Feature from Dev Containers

**By:** Naomi (Template Engineer)
**Date:** 2026-04-09
**Status:** ✅ APPROVED (Final)

### Context

The `docker-outside-of-docker` feature broke Podman support by bind-mounting `/var/run/docker.sock` (which doesn't exist on Podman hosts). Amos's interim fix (`docker-in-docker:2`) requires `"privileged": true` in the feature spec, which fails for rootless Podman — the default Podman mode.

### Final Decision

Remove the Docker devcontainer feature entirely from both base and Blazor overlay `devcontainer.json` files.

### Rationale

1. **No runtime dependency:** No post-create scripts, workflows, or template files reference the Docker CLI inside the container.
2. **Speculative feature:** Templates ship no Dockerfiles or docker-compose files. Docker CLI access was added for future convenience, not immediate need.
3. **Both Docker features break Podman:** `docker-outside-of-docker` requires host socket; `docker-in-docker` requires privileged mode. Neither is runtime-neutral.
4. **User agency:** Projects that need Docker CLI access can add the appropriate feature to their own `devcontainer.json` when they need it. The template shouldn't impose a runtime-specific dependency.
5. **Lean dependency philosophy:** Aligns with project standards — don't ship what isn't needed.

### Changes

| File | Change |
|------|--------|
| `base/.devcontainer/devcontainer.json` | Removed `docker-in-docker:2` feature |
| `overlays/blazor/.devcontainer/devcontainer.json` | Removed `docker-in-docker:2` feature |
| `base/.github/prompts/pre-container-setup.prompt.md` | Runtime-neutral language, Podman Desktop recommendation |
| `base/README.md` | Docker Desktop / Podman Desktop in Prerequisites, removed DinD from table |
| `overlays/blazor/README.md` | Same |
| `overlays/minimalapi/README.md` | Same |

### Impact

- Docker Desktop users: no change to core workflow (dotnet build/test/run unchanged)
- Podman Desktop users: container now builds and opens successfully
- Podman CLI (Linux): works with `podman-docker` package or `podman.socket` enabled
- Users who need Docker CLI inside the container: add `docker-in-docker` or `docker-outside-of-docker` feature to their project's `devcontainer.json`

---

## Decision: Approve Podman Compatibility Restoration

**By:** Holden (Lead)
**Date:** 2026-04-09
**Status:** ✅ APPROVED

### Scope

Quality gate review of commits `2ccef32`, `4e839ba`, `0a2d769` on `dev` — restoring Podman compatibility that was broken by Docker-specific devcontainer features.

### Verdict: APPROVED

### What was broken

The `docker-outside-of-docker` devcontainer feature hardcodes a bind mount of `/var/run/docker.sock → /var/run/docker-host.sock`. On Podman hosts, `/var/run/docker.sock` does not exist, causing container creation to fail entirely.

### Fix path (two iterations, correct final state)

1. **Amos (2ccef32):** Swapped to `docker-in-docker:2` — removes host socket dependency but requires privileged mode, which fails on rootless Podman (the default Podman configuration). Partial fix.
2. **Naomi (4e839ba):** Removed Docker feature entirely — no scripts, workflows, or template files need Docker CLI inside the dev container. The feature was speculative. Complete fix.

### Why the trade-off is acceptable

- **No capability loss:** Templates ship no Dockerfiles, docker-compose files, or CI workflows that invoke `docker` inside the dev container. The Docker feature was prospective convenience, not a dependency.
- **User agency preserved:** Projects that later need Docker CLI access can add `docker-in-docker` or `docker-outside-of-docker` to their own `devcontainer.json`. One line of JSON.
- **Lean dependency principle upheld:** Don't ship what isn't needed. This is core template philosophy.
- **Both runtimes now work:** Docker Desktop users lose nothing from the core workflow (dotnet build/test/run). Podman users can now build and open the container successfully.

### Documentation accuracy verified

- `pre-container-setup.prompt.md`: Runtime-neutral language ("container runtime" not "Docker and VS Code"), Podman Desktop recommendation with Linux CLI fallback guidance
- All 3 READMEs: Prerequisites link "Docker Desktop" / "Podman Desktop", no "Docker-in-Docker" in What's Included tables
- Composition verified: both MinimalApi and Blazor templates compose cleanly

### No Docker regression

Confirmed: zero references to `docker.sock`, `docker-in-docker`, `docker-outside-of-docker`, or `privileged` mode in any devcontainer.json (base or overlay). `--security-opt=label=disable` correctly retained for SELinux compatibility.

### Next Steps

- Merge dev → main when ready
- No further revision needed

---

## CLI Template Planning Preferences

**By:** Lee Buxton (via Copilot)  
**Date:** 2026-04-12T21:54:08Z  
**Decision:** Prefer maintained CLI packages and make Spectre.Console the primary default

### Scope

- CLI template design and package selection
- Alternative frameworks documentation
- Maintenance and licensing considerations

### Decision

1. **Maintained packages only:** CLI templates prioritize actively maintained packages (no deprecated or abandoned tooling)
2. **Primary default:** Spectre.Console as the go-to companion for CLI applications
3. **Alternatives:** Spectre.Console.Cli, CliFx, Terminal.Gui (documented as alternatives)
4. **Not recommended:** Cocona (due to maintenance concerns)
5. **Licensing preference:** MIT

### Why

- User request — captured for team memory and template guidance
- Spectre.Console has broad community adoption and active maintenance
- MIT licensing aligns with template licensing strategy
- Alternative frameworks provide flexibility for different use cases

### Impact

- CLI template research document updated
- CLI plan refined to prioritize maintained packages
- Template scope clarified for downstream development

---

## CLI Planning Artifacts Relocation — User Directive

**By:** Lee Buxton (via Copilot)  
**Date:** 2026-04-12T22:05:35Z  
**Decision:** Use `.tmp/` in the repo as the final location for planning artifacts

### Context

CLI planning work has produced finalized artifacts that need persistent home outside of temporary working directories.

### Resolution

- `.tmp/` directory added to `.gitignore` for local planning artifact storage
- Moved artifacts: `thesereyn-cli-template-plan.md`, `thesereyn-cli-template-research.md`, `thesereyn-cli-template-repo-fit.md`
- Working copies remain unfrozen until planning phase completion

### Rationale

- Keeps finalized planning work accessible to team while respecting planning workflow
- Avoids polluting main codebase with intermediate research
- Allows user to defer committing working state until ready

### Impact

- CLI planning artifacts now centrally located in `.tmp/`
- Team has reference location for CLI requirements and analysis
- Deferred move of working copies allows continued iteration

---


---

## CLI Template Composition Strategy

**By:** Holden (Lead)  
**Date:** 2026-04-12  
**Status:** RECOMMENDATION — pending user approval

### Context

Lee has asked for a plan to add a third template (TheSereyn.Templates.CLI) to the composition workspace. This requires evaluating whether the current base + overlay model holds, or whether web-specific content in base/ needs restructuring.

### Core Finding

**Base/ is currently web-flavored .NET, not universal .NET.** This was acceptable with two web templates but adding CLI exposes the bias.

Web-specific content currently in base:
- `.github/copilot-instructions.md` (~120 lines): Stack table (Minimal APIs, REPR), HTTP/REST RFCs, CORS, security headers, CSRF, rate limiting, ASP.NET OpenTelemetry, REST/OpenAPI micro-checklists
- `.copilot/skills/project-conventions/SKILL.md` (~130 lines): RFC 9457 Problem Details, REPR Pattern, cursor-based pagination, Clean Architecture, health check endpoints, API patterns
- `.copilot/skills/aspnetcore-api-security/`, `browser-security-headers/`, `rfc-compliance/`, `dotnet-authn-authz/` (entirely web-specific)
- `.devcontainer/devcontainer.json`: `forwardPorts: [5000, 5001]` (Kestrel ports)
- `README.md`: Clean Architecture with Api/ folder, `dotnet run --project src/YourProject.Api/`

### Recommendation: Refactored Base + Overlays (No Mixins Yet)

**Make base/ truly universal .NET. Move web-specific content to overlay append files and overlay skill overrides.**

#### Why Not Mixins

| Factor | Assessment |
|--------|-----------|
| Duplication cost | ~120 lines in one file (copilot-instructions append), duplicated in 2 overlays |
| Mixin complexity cost | compose.sh changes, templates.json schema change, new directory, documentation, CI updates |
| Template count | 3 (threshold was "4+" per existing compose.sh guidance) |
| Verdict | Duplication is cheaper than mixin infrastructure at this scale |

#### Changes

**Stays in base (universal .NET):**
- `.editorconfig`, `.gitattributes`, `.gitignore`, `LICENSE`
- `Directory.Build.props`, `Directory.Packages.props`, `global.json`, `stylecop.json`
- `.vscode/settings.json`
- `.devcontainer/devcontainer.json` (keep as-is; ports are harmless for CLI)
- `.devcontainer/post-create-shared.sh`, `post-create.sh`
- `.copilot/mcp-config.json`
- `.github/CODEOWNERS`
- `.github/prompts/*` (first-time-setup needs minor CLI-awareness)
- All 25 skills in `.copilot/skills/` (including 4 web-specific ones, which stay as reference material)

**Moves from base to overlays (web-specific):**

1. **`base/.github/copilot-instructions.md`** → Refactor to universal .NET
2. **`overlays/minimalapi/.github/copilot-instructions.append.md`** — NEW file with web-specific content
3. **`overlays/blazor/.github/copilot-instructions.append.md`** — EXPAND with web-specific content
4. **`base/README.md`** → Make universal
5. **`overlays/cli/`** — NEW overlay with CLI-specific content

### Impact

- MinimalApi overlay grows to ~5 files (README, append, skill overrides)
- Blazor overlay adds append pattern
- Base becomes genuinely template-neutral
- No changes needed to compose.sh, templates.json schema, or CI workflows

---

## CLI Template Onboarding — Platform Plan

**By:** Amos (Platform Engineer)  
**Date:** 2026-04-12  
**Status:** PROPOSED — awaiting Holden review

### Finding: Base Is MinimalApi-Centric

Current `base/` carries web-specific assumptions wrong for CLI:
- Stack table: "ASP.NET Core Minimal APIs, REPR pattern"
- Clean Architecture with Api/ project
- CORS/CSRF/antiforgery/rate-limiting security sections
- OpenTelemetry with `AddAspNetCoreInstrumentation`
- REST micro-checklists
- `dotnet new webapi` in manual setup
- `forwardPorts: [5000, 5001]` in devcontainer

If we add CLI with current base, the composed CLI template ships with irrelevant web API instructions and port-forwarding rules.

### Recommendation: Refactor Base Before Adding CLI Overlay

**Option A (RECOMMENDED):** Extract web-specific content from base → overlays
1. Refactor `base/.github/copilot-instructions.md` to generic .NET
2. Move API-specific sections to `overlays/minimalapi/.github/copilot-instructions.append.md`
3. Refactor `base/README.md` to generic template README
4. Remove `forwardPorts` from base devcontainer; web overlays add their own

**Why:** Refactoring work is bounded (3–4 base files) and pays for itself immediately. Compose mechanics (compose.sh, templates.json, workflows) need zero changes.

### Sequencing

1. **Phase 1: Base refactoring** — extract web-specific content from base (Amos + Naomi)
2. **Phase 2: CLI overlay creation** — add `overlays/cli/` with CLI-specific content (Naomi)
3. **Phase 3: Wiring** — add to `templates.json`, create downstream repo, verify publish flow (Amos)

**Phase 1 must land before Phase 2.** Phase 3 can happen in parallel with Phase 2.

### Risk

Phase 1 touches files that affect both MinimalApi and Blazor output. Must compose-and-verify all three templates after refactoring.

---

## CLI Template Content Split — Audit Findings

**By:** Naomi (Template Engineer)  
**Date:** 2026-04-12  
**Status:** PROPOSED — awaiting user decisions

### Finding Summary

Of ~18 content surfaces in base, **6 carry web-specific content that would actively mislead Copilot in CLI context**:

**Critical (actively misleading):**
1. `base/.github/copilot-instructions.md` — Stack table, security, observability, delivery format all assume web
2. `base/.copilot/skills/project-conventions/SKILL.md` — Almost entirely web-specific (REPR, pagination, health checks, Clean Architecture)
3. `base/README.md` — Scaffolds `dotnet new webapi`; architecture shows Api/ layer

**Moderate (inaccurate but harmless):**
4. `base/.devcontainer/devcontainer.json` — `forwardPorts: [5000, 5001]` meaningless for CLI
5. `base/.github/prompts/first-time-setup.prompt.md` — References web patterns
6. `base/.editorconfig` — `[*.razor]` section (harmless)

### Proposed Approach: Generalize Base

Generalize `base/` to be template-neutral; use `.append.md` in all three overlays for template-specific content.

### Decisions Needed from User

1. **CLI template source code?** (Program.cs + .csproj vs. AI-first)
2. **Azure CLI in base devcontainer?** (Keep for all or web-only?)
3. **Generic Host in CLI?** (Default or opt-in?)
4. **MinimalApi devcontainer override?** (Needed if ports move to overlay)

### Impact

- **MinimalApi:** Grows from 1 to ~5 files
- **Blazor:** Adds append pattern content
- **Base:** Genuinely template-neutral; scales to 4+ templates

---

---




---
---

---


# Security Review: CLI Template & Base-Layer Refactor

**By:** Drummer (Security Reviewer)
**Date:** 2026-04-14
**Commit:** `41f3efb` (Naomi)
**Verdict:** ✅ APPROVED

## Scope

- Base copilot-instructions generalisation (web content → overlays)
- MinimalApi overlay: new `copilot-instructions.append.md` with web security
- Blazor overlay: expanded `copilot-instructions.append.md` with web security
- CLI overlay: README, copilot-instructions append, `cli-development` skill, `project-conventions` skill

## Security Content Preservation — Web Templates

All web security guidance removed from base is fully preserved in both overlay appends:

| Guidance | MinimalApi | Blazor |
|----------|-----------|--------|
| OAuth/OIDC + PKCE + DPoP | ✅ | ✅ |
| CORS (no AllowAnyOrigin) | ✅ | ✅ |
| Security headers (HSTS, CSP, X-Content-Type-Options, X-Frame-Options, Referrer-Policy, Permissions-Policy) | ✅ | ✅ (+COEP/CORP/COOP) |
| Input validation (model binding) | ✅ | ✅ |
| Output encoding (HtmlEncode, Razor) | ✅ | ✅ |
| CSRF protection (antiforgery) | ✅ | ✅ |
| Rate limiting middleware | ✅ | ✅ |
| EF Core EnableSensitiveDataLogging(false) | ✅ | ✅ |
| OWASP API Security Top 10 (2023) | ✅ | ✅ |
| ASP.NET Core OTel setup pattern | ✅ | ✅ |
| Web security skills (dotnet-authn-authz, aspnetcore-api-security, browser-security-headers) | ✅ | ✅ |
| rfc-compliance skill | ✅ | ✅ |
| REST + Auth micro-checklists | ✅ | ✅ |
| Web ask-first triggers (auth provider, middleware ordering, etc.) | ✅ | ✅ |

**No security regression for existing downstream repos.**

## Base Layer — Universal Security Retained

Base correctly retains template-neutral security:
- Input validation (generic boundary principle)
- Output encoding (SQL, shell, markup — no web-specific framing)
- Secrets management (dotnet user-secrets, Key Vault, .gitignore)
- No PII logging
- STRIDE threat modelling
- Dependency security (`dotnet list package --vulnerable`)
- Security review workflow (security-review-core, OWASP Top 10 2021)

## CLI Overlay — Security Assessment

### Positives

1. **Argument validation** — correctly directs to System.CommandLine's built-in validation (custom parse delegates, `Required` property)
2. **File path safety** — explicit path traversal guidance (`Path.GetFullPath()`, boundary checks)
3. **Shell injection** — correctly recommends `ProcessStartInfo.ArgumentList` over string concatenation
4. **Credential handling** — correctly warns that CLI args are visible in process listings; directs to env vars / credential stores
5. **Markup escaping** — `Markup.Escape(userInput)` demonstrated in Spectre.Console examples, preventing terminal injection
6. **Non-TTY safety** — `AnsiConsole.Profile.Capabilities.Interactive` check documented before any interactive prompts
7. **Anti-patterns** — correctly calls out: no secrets on CLI, no interactive prompts in piped mode, no swallowed exceptions, no `Environment.Exit()` in library code

### API Verification

System.CommandLine APIs verified against Microsoft Learn (net-10.0-pp reference):
- `SetAction()` — confirmed current API (replaces deprecated `SetHandler`)
- `ParseResult.GetValue()` — confirmed
- `Parse(args).Invoke()` / `InvokeAsync()` — confirmed
- `Option<T>.Required`, `Recursive`, `CustomParser`, `AllowMultipleArgumentsPerToken` — confirmed
- Package: `System.CommandLine v3.0.0-preview` on .NET 10 platform — expected for .NET 10 timeline

### Dependency Claims

- System.CommandLine: MIT, Microsoft-maintained ✅
- Spectre.Console: MIT, .NET Foundation ✅
- Cocona: correctly marked as archived (Dec 2025), not recommended ✅

### No Issues Found

- No insecure defaults introduced
- No misleading security guidance
- No hallucinated APIs or incorrect package claims
- Exit code conventions are standard (0/1/2/130)
- Error output correctly separates stdout (data) from stderr (diagnostics)

## Non-Blocking Observations

None. This is a clean implementation.

## Decision

APPROVED — no changes required. The base-layer refactor correctly generalises shared content while preserving all web security guidance in overlay appends. The CLI overlay introduces appropriate, accurate CLI-specific security guidance with no insecure patterns.
# CLI Template Implementation — Lead Review

**By:** Holden (Lead)
**Date:** 2026-04-14
**Verdict:** ✅ APPROVED

## Scope

Two commits on `dev`:
- `0296327` (Amos) — `templates.json`, root `README.md`, overlay placeholder
- `41f3efb` (Naomi) — base generalisation, CLI overlay content, web content redistribution

## Review Checklist

### 1. Is base template-neutral enough for CLI?

**Yes.** `base/.github/copilot-instructions.md` reduced from 252→205 lines. All web content (HTTP RFCs, CORS, CSRF, security headers, ASP.NET Core OTel patterns, health check endpoints) removed. Remaining content is generic .NET: stack table, MCP tools, dependency policy, security principles, code quality, TUnit, OpenTelemetry (generic), Spec Kit workflow.

### 2. Was shared web guidance moved to the right overlay shape?

**Yes.** Both MinimalApi and Blazor received new `copilot-instructions.append.md` files with the web content extracted from base. Blazor's append preserves its pre-existing Blazor-specific sections (Blazor UI, hosting model, Playwright, Blazor security skills) while prepending the shared web content.

### 3. Does the CLI overlay fit the composition model?

**Yes.** Uses all three overlay semantics correctly:
- **Replace:** `README.md`, `.copilot/skills/project-conventions/SKILL.md`
- **Add:** `.copilot/skills/cli-development/SKILL.md`
- **Append:** `.github/copilot-instructions.append.md`

### 4. Content quality

- **cli-development skill** — Comprehensive. System.CommandLine patterns (single/multi-command, async, custom validation), Spectre.Console output, exit codes, testing with TUnit, alternative packages with maintenance-aware recommendations (Cocona explicitly deprecated per Lee's directive).
- **project-conventions** — Clean CLI-specific replacement. Exit codes (not Problem Details), command-handler pattern, command organisation, CLI naming, non-TTY safety.
- **copilot-instructions append** — Focused CLI additions: CLI Stack table, CLI security (arg validation, file path safety, shell injection, credential handling), CLI observability, CLI ask-first triggers.
- **README.md** — Standalone CLI getting started, architecture, key conventions, dependency list.

## Known Trade-Offs (Accepted)

1. **Base `project-conventions` skill is web-specific** — Replaced by CLI overlay. MinimalApi/Blazor consume it directly. Session 15 decision: "replace rather than split." Sound at 3 templates.
2. **4 web security skills in base** (aspnetcore-api-security, browser-security-headers, rfc-compliance, dotnet-authn-authz) — Flow into CLI output unreferenced. Session 15 decision: "harmless reference material." Agree.
3. **Web content duplication** (~88 lines) between MinimalApi and Blazor appends — Expected. Mixin layer deferred to 4+ templates per Session 15.

## Minor Nit (Non-Blocking)

- `overlays/cli/.gitkeep` — Now unnecessary since overlay has real content. Clean up in a future housekeeping pass.

## Outcome

Ship as-is. Both commits are clean, composition-correct, and aligned with the Session 15 architectural plan.
# Decision: CLI Template Repo Wiring

**By:** Amos (Platform Engineer)
**Date:** 2026-04-14
**Status:** Implemented on `dev`

## Changes

| File | Change |
|------|--------|
| `templates.json` | Added `cli` overlay → `TheSereyn/TheSereyn.Templates.CLI` entry |
| `README.md` (workspace root) | Added CLI to downstream table, workspace structure tree, and local development examples |
| `overlays/cli/` | Created empty directory (required for compose.sh overlay resolution) |

## No Workflow or Script Changes Required

The infrastructure is fully data-driven:
- `compose.sh` reads `templates.json` dynamically — no TEMPLATES array to update
- `compose-and-publish.yml` builds its strategy matrix from `templates.json` — no hardcoded matrix entries
- `pr-validate.yml` iterates `templates.json` — CLI validation is automatic

**Zero gaps found.** The existing data-driven design handles CLI onboarding without any pipeline modifications.

## Validation

- `jq` parsed `templates.json` successfully (valid JSON)
- `compose.sh --dry-run` recognized all three templates
- `compose.sh` full run composed CLI output (46 files from base, 0 overlay files pending Naomi's content)
- `output/TheSereyn.Templates.CLI/README.md` present, file count ≥ 5 — passes PR validation threshold

## Remaining Work (Not in This Change)

- **Naomi:** CLI overlay content (skills, source files, append files) in `overlays/cli/`
- **Downstream repo:** `TheSereyn/TheSereyn.Templates.CLI` must be created on GitHub as a template repo
- **Secret:** `TEMPLATE_PUSH_TOKEN` must have push access to the new downstream repo
# CLI Template Implementation — Base/Overlay Content Split

**By:** Naomi (Template Engineer)
**Date:** 2026-04-14
**Status:** Implemented on dev

## Decision

Refactored `base/.github/copilot-instructions.md` to be template-neutral, moving web/API-specific guidance into overlay append files shared by MinimalApi and Blazor. Created the CLI template overlay with System.CommandLine + Spectre.Console as the default stack.

## What Moved Out of Base

| Content | Was in base | Now in overlays |
|---------|-------------|-----------------|
| Stack rows: API (Minimal APIs, REPR), Architecture (Clean Architecture) | copilot-instructions.md | minimalapi + blazor appends |
| HTTP/REST RFCs (9205, 9110, 3986, 9457) + IETF HTTPAPI WG | copilot-instructions.md | minimalapi + blazor appends |
| Web security (CORS, security headers, CSRF, rate limiting, auth with [Authorize]) | copilot-instructions.md | minimalapi + blazor appends |
| ASP.NET Core OTel setup (AddAspNetCoreInstrumentation code example) | copilot-instructions.md | minimalapi + blazor appends |
| REST micro-checklist | copilot-instructions.md | minimalapi + blazor appends |
| API-specific ask-first triggers (OIDC, persistence, messaging, API versioning, middleware) | copilot-instructions.md | minimalapi + blazor appends |
| Web-specific skills (rfc-compliance, dotnet-authn-authz, aspnetcore-api-security, browser-security-headers) | copilot-instructions.md | minimalapi + blazor appends |
| OpenAPI/Swagger delivery format note | copilot-instructions.md | minimalapi + blazor appends |
| Clean Architecture diagram + webapi manual setup | README.md | (removed — template-specific READMEs handle this) |

## What Stays in Base

- .NET 10 + C# runtime, TUnit, StyleCop, OpenTelemetry (stack table)
- MCP Tools source-of-truth policy
- Dependency policy (changed "ASP.NET Core" to "framework")
- Universal security: input validation, output encoding, secrets, logging, threat modelling, dependency security
- Code quality rules (nullable, file-scoped, async all the way, CancellationToken)
- OTel key conventions (OTLP, service name, ActivitySource, Meter — no web-specific example)
- TUnit testing section
- Delivery format (with generic "Documentation updates" instead of "Docs/OpenAPI updates")
- Spec Kit / Squad workflow
- Universal security skills (security-review-core tree minus web-specific entries)
- All compliance skills

## CLI Overlay Created

| File | Purpose |
|------|---------|
| `overlays/cli/README.md` | CLI template README — System.CommandLine + Spectre.Console architecture |
| `overlays/cli/.github/copilot-instructions.append.md` | CLI stack, CLI security, CLI observability, CLI ask-first triggers, CLI micro-checklists |
| `overlays/cli/.copilot/skills/cli-development/SKILL.md` | Full CLI development skill — System.CommandLine API patterns (verified against MS Learn), Spectre.Console output, exit codes, testing, alternative packages |
| `overlays/cli/.copilot/skills/project-conventions/SKILL.md` | CLI-specific conventions (replaces base via overlay semantics) — command-handler pattern, exit codes, error output, CLI testing, CLI anti-patterns |

## Shared Web Content Pattern

Both MinimalApi and Blazor overlay appends contain identical shared web sections (Stack, RFCs, Web Security, Web Observability, Web Delivery, Web Ask-First, Web Micro-Checklists, Web Skills). This is intentional duplication per the base+overlay model — no mixin layer needed at 3 templates.

## Validation

- `./compose.sh` succeeds for all three templates (minimalapi, blazor, cli)
- MinimalApi composed output contains web-specific content ✓
- Blazor composed output contains web + Blazor content ✓
- CLI composed output has zero web references, has CLI content ✓
- CLI project-conventions skill correctly replaces base version via overlay semantics ✓
- System.CommandLine API patterns verified against Microsoft Learn docs (SetAction, Parse, Invoke, Option<T>, Argument<T>, Recursive, etc.)

## Rationale

The latest directive overrides Session 14's audit — some MinimalApi-originated items (web security, RFCs, OTel with ASP.NET Core instrumentation) are legitimately shared with Blazor and belong in both web overlays rather than being left in base where they'd mislead CLI development. The `.tmp/` artifacts informed CLI stack choices (System.CommandLine + Spectre.Console) but not base/overlay boundaries.
### 2026-04-14T17:56:50Z: User directive
**By:** Lee Buxton (via Copilot)
**What:** Treat the latest session directive as authoritative; `.tmp/` files are prior-session artifacts only. Implement the CLI template and explicitly move MinimalApi-first items out of `base/` where appropriate, while keeping content that is truly shared with Blazor in the right shared/overlay shape.
**Why:** User request — captured for team memory

---

## Decision: Create TheSereyn.Templates.CLI Downstream Repo

**By:** Amos (Platform Engineer)  
**Date:** 2026-04-14  
**Status:** Completed

### Context

CLI template onboarding requires a downstream GitHub repo to receive composed output from `compose.sh`. The repo was created to match the settings of the two existing sibling repos (`TheSereyn.Templates.MinimalApi`, `TheSereyn.Templates.Blazor`).

### Settings Applied

| Setting | Value | Matches siblings |
|---------|-------|-----------------|
| Visibility | Public | ✅ |
| Template repo | Yes | ✅ |
| Description | `.NET CLI project template — composed from TheSereyn.Templates` | ✅ (pattern aligned) |
| License | MIT | ✅ |
| Issues | Disabled | ✅ |
| Wiki | Disabled | ✅ |
| Default branch | main | ✅ |

### Repo Details

- **Repository:** https://github.com/TheSereyn/TheSereyn.Templates.CLI
- **Visibility:** Public template repository
- **Alignment:** Matches sibling downstream repos per user guidance

### Follow-Up Required

1. **`TEMPLATE_PUSH_TOKEN`** — Lee to configure the secret with push access to this repo (required for `compose-and-publish.yml` to push composed output)
2. **First publish** — Once the CLI overlay is merged and a `v*` tag is pushed on main, the workflow will compose and push content to this repo automatically

### Notes

- Coordinator clarified to refer to Blazor/MinimalApi repos for settings if needed; repo creation already followed that guidance
