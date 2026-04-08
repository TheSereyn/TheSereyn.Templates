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
