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
