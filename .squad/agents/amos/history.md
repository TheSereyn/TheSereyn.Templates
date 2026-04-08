# Amos — History

## Core Context

**Project:** TheSereyn.Templates — composition workspace for .NET project templates.
**User:** Lee Buxton
**Team:** Holden (Lead), Naomi (Template Engineer), Amos (Platform Engineer), Drummer (Security Reviewer), Scribe, Ralph

**My domain — pipeline and infrastructure:**
- `compose.sh` — main composition script; TEMPLATES array defines overlay:RepoName pairs
- `.github/workflows/compose-and-publish.yml` — tag-triggered publish; guard job checks tag is on main; strategy matrix per template
- `.github/workflows/squad-*.yml` — squad automation (triage, heartbeat, issue-assign, sync-labels)
- `base/.devcontainer/devcontainer.json` — .NET 10, Node 22, GH CLI, Azure CLI, Docker-outside-of-Docker
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
