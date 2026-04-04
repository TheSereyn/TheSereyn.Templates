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
