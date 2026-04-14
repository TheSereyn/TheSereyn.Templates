# Amos — History

## Core Context

**Project:** TheSereyn.Templates — composition workspace for .NET project templates.
**User:** Lee Buxton
**Team:** Holden (Lead), Naomi (Template Engineer), Amos (Platform Engineer), Drummer (Security Reviewer), Scribe, Ralph

**My domain — pipeline and infrastructure:**
- `compose.sh` — main composition script; TEMPLATES array defines overlay:RepoName pairs
- `.github/workflows/compose-and-publish.yml` — tag-triggered publish; guard job checks tag is on main; strategy matrix per template
- `.github/workflows/squad-*.yml` — squad automation (triage, heartbeat, issue-assign, sync-labels)
- `base/.devcontainer/devcontainer.json` — .NET 10, Node 22, GH CLI, Azure CLI, Docker-in-Docker
- `base/.copilot/mcp-config.json` — MCP servers (Microsoft Learn, Azure, GitHub)
- `overlays/blazor/.devcontainer/devcontainer.json` — Blazor devcontainer override
- `overlays/blazor/.copilot/mcp-config.json` — Blazor MCP override
- `.gitattributes`, `.editorconfig`, `.vscode/settings.json`

**New template checklist:**
1. Add `"overlay:RepoName"` entry to `TEMPLATES` array in `compose.sh`
2. Create `overlays/<name>/` folder with at minimum a README.md
3. Create downstream GitHub repo (TheSereyn/TheSereyn.Templates.<Name>) as a template repo
4. Add to matrix in `compose-and-publish.yml`
5. Ensure `TEMPLATE_PUSH_TOKEN` has push access to the new repo

**Publish flow:** `v*` tag on main → guard checks tag on main → compose matrix builds each template → clone downstream repo → sync composed output → commit + push + tag downstream

## Learnings

- Session 1 (2026-04-04): Team initialized. I am the platform and pipeline specialist.

- Session 2 (2026-04-04): Conducted platform and devcontainer review across all templates.
  - Found 5 critical blockers requiring immediate fix
  - Critical 1: Devcontainer is Podman-only — `--userns=keep-id` fails on Docker Desktop
  - Critical 2: MCP config references non-existent npm packages (shared with Naomi)
  - Critical 3: PostCreateCommand chain fails at `copilot plugin` step (CLI not on PATH during container build)
  - Critical 4: No version pinning on package installs (supply chain risk)
  - Critical 5: GitHub Actions pinned to mutable tags (shared with Holden, Drummer)
  - XDG_RUNTIME_DIR mount also fails on macOS/Windows (unset environment variable)
  - Tested on both Docker Desktop and Podman — confirmed Docker failures
  - Blazor overlay duplicates near-identical files, creating maintenance drift
  - New template checklist is sound and well-documented

- Session 3 (2026-04-04): Created feature/prompt-split branch, committed Naomi's prompt split work, pushed, and opened PR #21 to dev.
  - PR: https://github.com/TheSereyn/TheSereyn.Templates/pull/21
  - Staged 10 files: new pre-container-setup.prompt.md, revised first-time-setup.prompt.md, updated README.md, agent charter model updates, inbox review files
  - Clean commit with Co-authored-by trailer per project convention

- Session 4 (2026-04-04T17:49:01Z): Scribe closed prompt-split phase.
   - PR #21 merged approval from Drummer (security) and Holden (spec)
   - Naomi's implementation approved and staged
   - Orchestration log created and archived
   - Inbox decisions merged to decisions.md

- Session 5 (2026-04-08): Updated Squad and disabled squad workflows.
  - Squad update landed new/modified files: `.github/agents/squad.agent.md`, `.squad/templates/*`, 7 new workflow files, 4 modified workflow files
  - Disabled all 11 squad workflows by renaming `.yml` → `.yml.disabled` (GitHub Actions ignores non-YAML extensions)
  - Disablement method: file rename is simplest, clearest, and fully reversible (rename back to re-enable)
  - `.squad/templates/` files showed as modified in working tree due to CRLF normalization but had no actual content diff — git's autocrlf handling
  - Committed to dev, pushed, opened PR #25, merged to main
  - Active workflows confirmed untouched: `compose-and-publish.yml`, `pr-validate.yml`
  - Pattern: prefer `.yml.disabled` over deleting or gutting workflow files — preserves content for easy re-enablement

- Session 6 (2026-04-08): Added Spec Kit CLI to shared dev container experience.
  - Added `ghcr.io/devcontainers/features/python:1` (v3.12) to both base and Blazor overlay devcontainer.json
  - Added uv install via `pip install --user` in post-create.sh, then `uv tool install specify-cli` pinned to v0.5.0
  - Added `~/.local/bin` to PATH in .bashrc heredoc (required for uv tools and pip --user installs)
  - All four files updated: base devcontainer.json + post-create.sh, blazor overlay devcontainer.json + post-create.sh
  - Blazor overlay replaces base (not appends), so both must be kept in sync for shared tooling
  - compose.sh verified: both MinimalApi and Blazor outputs include the Spec Kit changes
  - Spec Kit install is idempotent (`|| true` on uv tool install) and safe to re-run
  - Chose pip over `curl | sh` for uv install to stay consistent with Drummer's security review findings

- Session 7 (2026-04-08): Added Spec Kit CLI to shared dev container experience.
  - Added `ghcr.io/devcontainers/features/python:1` (v3.12) to both base and Blazor overlay devcontainer.json
  - Added uv install via `pip install --user` in post-create.sh, then `uv tool install specify-cli` pinned to v0.5.0
  - Added `~/.local/bin` to PATH in .bashrc heredoc (required for uv tools and pip --user installs)
  - All four files updated: base devcontainer.json + post-create.sh, blazor overlay devcontainer.json + post-create.sh
  - Blazor overlay replaces base (not appends), so both must be kept in sync for shared tooling
  - compose.sh verified: both MinimalApi and Blazor outputs include the Spec Kit changes
  - Spec Kit install is idempotent (`|| true` on uv tool install) and safe to re-run
  - Chose pip over `curl | sh` for uv install to stay consistent with Drummer's security review findings

- Session 8 (2026-04-08): Spec Kit batch 1 — Team execution and decision merge.
  - Session 6 work (workflow disable) complete; Session 7 work (Spec Kit devcontainer) complete and committed
  - Decision inbox merge in progress — all 7 inbox files consolidated into decisions.md under 2026-04-08 section
  - Orchestration logs written for Amos; session log written; git commit pending

- Session 9 (2026-04-08): Spec Kit batch 2 — Revision under lockout reassignment.
   - Accepted lockout reassignment from Holden (Naomi cannot revise her own rejected artifacts)
   - Completed two required revisions to restore version consistency and fix security fallback:
     * Issue 1 (Version pinning): Replaced `uvx --from ...@latest` with direct call to pre-installed binary `specify init --here --ai copilot` in both files
     * Issue 2 (curl | sh): Replaced fallback with `python3 -m pip install --user uv` + PATH export, aligning with my own post-create.sh security choice
   - Ran compose.sh to verify template output regenerates cleanly with changes
   - Drummer re-reviewed → ✅ APPROVED; no lockout triggered
   - Holden re-reviewed → ✅ APPROVED FOR MERGE TO MAIN
   - Orchestration log written: 2026-04-08T10:17:21Z-amos.md
   - Ready for merge to main; compose-and-publish workflow pending tag push

- Session 10 (2026-04-08): Scribe administrative handoff — Main-branch security review and batch 3 assignment.
   - Orchestration log finalized: 2026-04-08T10:17:21Z-amos.md (captures batch 2 revision completion)
   - Main-branch comprehensive security review findings recorded to decisions.md (4 HIGH, 4 MEDIUM, 4 LOW, 14 security wins documented)
   - NEW BATCH 3 ASSIGNMENTS IDENTIFIED (supply chain / npm pinning):
     * H1: Pin npm packages (@bradygaster/squad-cli, @playwright/cli@latest) in post-create.sh — multiple files affected
     * H2: Pin MCP server packages (@anthropic/github-mcp-server, @playwright/mcp) via npx -y versioning or pre-install pattern
     * H3: Pin MSDOCS skill fetch to commit SHA + add integrity verification (microsoftdocs/mcp main branch fetch currently unpinned/unverified)
   - Positive findings: Spec Kit integration meets security standards (v0.5.0 pinned, no curl|sh, no secrets, GitHub-owned source) ✅
   - Team status: batch 2 approved for merge; batch 3 work (H1/H2/H3) pending prioritization and scoping

- Session 5 (2026-04-08): Spec Kit integration batch — platform hardening and security fixes
   - Received reassignment per reviewer lockout policy (Naomi locked out; Amos owns revision)
   - Fixed H1 (npm packages): Centralised version pinning in post-create-shared.sh (SQUAD_CLI_VERSION=0.9.1, PLAYWRIGHT_CLI_VERSION=0.1.6, MSDOCS_COMMIT=933e0c5)
   - Fixed H2 (MCP npx): Updated to @modelcontextprotocol/server-github@2025.4.8, @playwright/mcp@0.0.70
   - Fixed H3 (MSDOCS): Pinned to commit SHA with fatal error handling (no more `|| true`)
   - Fixed H4 (gitignore): Added *.pfx, *.key, *.pem, *.p12, *.cer patterns
   - Created pr-validate.yml (devcontainer drift detection)
   - Enhanced compose-and-publish.yml (pre-flight token validation)
   - Created verify-setup.prompt.md (environment health check)
   - All HIGH findings resolved; Drummer approved remediation batch
   - Holden cleared merge to main; ready for v* tag

- Session 11 (2026-04-09): Restored Podman compatibility — replaced docker-outside-of-docker with docker-in-docker.
   - Root cause: `docker-outside-of-docker` feature hardcodes a bind mount of `/var/run/docker.sock` from host. Podman hosts don't have this file, so container creation fails entirely.
   - Fix: Switched to `docker-in-docker:2` which runs its own Docker daemon inside the container — no host socket dependency.
   - Changed files: `base/.devcontainer/devcontainer.json`, `overlays/blazor/.devcontainer/devcontainer.json`, `base/README.md`, `overlays/blazor/README.md`, `overlays/minimalapi/README.md`
   - Dropped `"moby": false` (docker-in-docker needs the engine; moby defaults to true)
   - Kept `"installDockerBuildx": false` to match prior minimal intent
   - Kept `"--security-opt=label=disable"` runArg (still needed for Podman on SELinux)
   - Compose verified: both MinimalApi and Blazor outputs regenerated cleanly
   - Known limitation: on rootless Podman hosts, dockerd inside the container may not start if the host doesn't grant sufficient privileges. The container itself still builds and works — only Docker commands inside would be unavailable.
   - Docs impact: "Docker-outside-of-Docker" → "Docker-in-Docker" in all README tables. No changes needed to pre-container-setup prompt (already runtime-neutral).

- Session 12 (2026-04-09): Podman compatibility restoration completed — feature removal final state.
   - Discovered blocker: docker-in-docker:2 requires `"privileged": true`, which fails on rootless Podman (default configuration).
   - Collaborated with Naomi: proposal to remove Docker feature entirely (no template code depends on it; it was speculative).
   - Naomi implemented full solution: removed Docker feature from base and overlays, updated all README surfaces and pre-container-setup prompt for runtime neutrality.
   - Holden reviewed and approved: trade-off is acceptable because no workflows/scripts need Docker CLI inside container. Users can add the feature themselves if needed.
   - Commits: 2ccef32 (interim docker-in-docker swap), 4e839ba (final feature removal), 0a2d769 (docs alignment), 2bf95b6 (approval gate)
   - Outcome: Podman support restored; Docker Desktop experience unchanged; both runtimes now work identically for all core workflows.
   - Decision records merged to decisions.md; orchestration logs and session log written.

- Session 13 (2026-04-12): CLI template onboarding — read-only planning pass.
    - Audited all input artifacts: plan, research, repo-fit analysis, templates.json, compose.sh, workflows, base/, overlays/
    - Key finding: base/ is MinimalApi-centric — copilot-instructions.md has ASP.NET Core stack table, CORS/CSRF/antiforgery sections, REST micro-checklists, webapi manual setup. README.md has Clean Architecture with Api/ project. devcontainer.json has forwardPorts [5000, 5001].
    - If CLI overlay is added without base refactoring, the composed CLI template ships with web API copilot instructions that are wrong for a console app.
    - Recommended Option A: refactor base to generic .NET, move web-specific content to overlays/minimalapi/ append files, then add CLI overlay cleanly.
    - compose.sh needs zero changes — fully data-driven from templates.json. Workflow matrix is dynamically generated. pr-validate.yml drift checks also work automatically.
    - MinimalApi currently has no devcontainer override (uses base as-is). Refactoring forwardPorts out of base means MinimalApi needs a new devcontainer.json overlay.
    - Blazor overlay already replaces devcontainer.json (adds port 5173 + Playwright extension) — refactoring would simplify it.
    - CLI overlay needs: README.md, copilot-instructions.append.md, cli-development SKILL.md, src/ project files. Does NOT need devcontainer, post-create, or MCP config overrides — base versions are correct for CLI.
    - Sequencing: Phase 1 (base refactoring) → Phase 2 (CLI overlay) → Phase 3 (downstream repo + wiring). Phase 3 can parallel Phase 2.
    - Decision proposal written to inbox: .squad/decisions/inbox/amos-cli-template-wiring.md
    - Key file paths for CLI work: templates.json, base/.github/copilot-instructions.md, base/README.md, base/.devcontainer/devcontainer.json, README.md (workspace root)

- Session 16 (2026-04-14T17:24:29Z): CLI Template Planning — Squad Execution & Artifact Merge
     - **Execution complete:** Platform analysis merged into unified team strategy
     - **Decision committed:** amos-cli-template-wiring.md consolidated into decisions.md (deduplicated with Holden and Naomi inputs)
     - **Orchestration log created:** 2026-04-14T17:24:29Z-amos.md documents platform findings
     - **Inbox file deleted:** amos-cli-template-wiring.md removed post-merge
     - **Agent history updated:** Tracks Phase 1/2/3 sequencing, base refactoring prerequisite, compose.sh stability
     - **Key confirmation:** Infrastructure (compose.sh, templates.json schema, workflows) needs zero changes
     - **Platform readiness:** Phase 3 (templates.json + downstream repo creation) ready for execution once Phases 1–2 complete

## 2026-04-14: CLI Template Wiring

Implemented CLI template onboarding: added to templates.json, updated workspace README, confirmed data-driven infrastructure. Commit: 0296327. Approval: ✅ Holden (Lead), ✅ Drummer (Security). Ready for downstream repo creation.

- Session 17 (2026-04-14T18:27:28Z): CLI Downstream Repo Creation — Execution & Scribe Handoff
      - **Repo created:** TheSereyn/TheSereyn.Templates.CLI on GitHub (public, template repo, MIT license, issues/wiki disabled, main default branch)
      - **Alignment:** Settings matched to sibling repos (MinimalApi, Blazor) per user guidance
      - **Orchestration log created:** 2026-04-14T18:27:28Z-amos.md documents repo creation execution
      - **Session log written:** 2026-04-14T18:27:28Z-cli-repo-creation.md consolidates repo outcome
      - **Decision inbox merged:** amos-create-cli-repo.md incorporated into decisions.md with full context
      - **Inbox file deleted:** amos-create-cli-repo.md removed post-merge
      - **Platform status:** Phase 3 (downstream repo wiring) complete; ready for Phase 1/2 base refactoring + CLI overlay implementation
      - **Follow-up tokens:** TEMPLATE_PUSH_TOKEN secret (Lee to configure); first publish triggers on v* tag push to main

- Session 18 (2026-04-14): v0.5.0 release — tag, PR, and publish.
    - **Workflow check:** compose-and-publish.yml already supports CLI template — matrix is data-driven from templates.json, no workflow changes needed.
    - **Compose verified:** all 3 templates (MinimalApi, Blazor, CLI) compose cleanly via compose.sh.
    - **CHANGELOG updated:** [Unreleased] to [0.5.0] - 2026-04-14 with full release notes covering CLI template, base generalization, setup workflow redesign, Podman fix, per-template copilot instruction overlays.
    - **PR #30 opened and merged:** dev to main, release: v0.5.0.
    - **Tag v0.5.0 pushed:** triggers compose-and-publish workflow (run ID 24420932683, confirmed queued).
    - **GitHub Release created:** https://github.com/TheSereyn/TheSereyn.Templates/releases/tag/v0.5.0
    - **Key finding:** No workflow or infrastructure changes needed — data-driven architecture from templates.json handled CLI onboarding with zero pipeline modifications.
    - **Reminder:** TEMPLATE_PUSH_TOKEN must have push access to TheSereyn/TheSereyn.Templates.CLI for the publish to succeed.

- Session 19 (2026-04-14T20:29:04Z): v0.5.0 Release Orchestration & Scribe Documentation
    - **Release readiness verified:** Workflow already supports CLI; all 3 templates compose cleanly.
    - **Execution complete:** PR #30 merged (dev → main), tag v0.5.0 pushed, GitHub Release published.
    - **Compose-and-publish workflow:** Run 24420932683 executed successfully; all three downstream repos (MinimalApi, Blazor, CLI) pushed and tagged v0.5.0.
    - **Release artifacts:** GitHub Release v0.5.0 targeting main; downstream repos contain expected prompts and manifests.
    - **Orchestration log created:** 2026-04-14T20:29:04Z-amos.md documents end-to-end execution.
    - **Note:** Post-release, minor stale wording identified in already-published CLI README; source docs corrected on dev by Naomi (follow-up doc cleanup pending dev push).
    - **Outcome:** v0.5.0 successfully released; all infrastructure and composition performed as designed.

- Session 20 (2026-04-14): Post-v0.5.0 branch sync — dev → main cleanup.
    - **Cleanup:** Removed 11 untracked enabled Squad workflow files (`.yml` copies left by Squad update). `.disabled` variants remain authoritative.
    - **Branch sync:** Merged `origin/main` into `dev` to incorporate v0.5.0 merge commit, then pushed dev.
    - **PR #31 opened and merged:** `dev → main`, docs-only sync (agent histories, decision records, release doc fixes, now.md update).
    - **Fast-forward:** After merge, fast-forwarded dev to main's new HEAD — branches fully aligned with zero divergence.
    - **Final workflow state:** 2 active (`compose-and-publish.yml`, `pr-validate.yml`), 11 disabled (`.yml.disabled`), zero untracked.
    - **No tags touched:** v0.5.0 tag preserved on its original commit.
    - **Key pattern:** When Squad updates drop enabled `.yml` copies alongside tracked `.disabled` files, always delete the untracked copies — the `.disabled` naming is the disablement mechanism.

- Session 21 (2026-04-14): Final dev/main alignment — closing residual single-commit drift.
    - **Drift:** One docs-only commit on dev (c8e7644: Amos history + sync decision inbox) not yet on main after PR #31 merge.
    - **Resolution:** Opened PR #32 (dev → main), merged via `--admin`, then fast-forwarded dev to main's merge commit.
    - **Verification:** Both branches at a9dbeb6, zero divergence in either direction.
    - **Pattern confirmed:** After merging dev → main via PR, always fast-forward dev to main's new merge commit to avoid residual 0/1 drift.

- Session 24 (2026-04-14T21:12:35Z): Post-release documentation finalization (Scribe)
    - **Inbox decisions merged:** holden-merge-gate.md, amos-sync-main.md, copilot-directive-20260414T210436Z.md → decisions.md (deduplicated, no conflicts).
    - **Inbox files deleted:** All three inbox/*.md files removed after merge.
    - **Orchestration logs created:** 2026-04-14T21:12:35Z-amos.md documents scope, status, key actions, verification.
    - **Session log created:** 2026-04-14T21:12:35Z-main-sync.md tracks post-release cleanup checkpoint.
    - **History updated:** Both Holden and Amos history.md updated with cross-agent team status.
    - **Next:** decisions.md size check (74.7 KB → archive if needed), history.md summarization, git commit.
