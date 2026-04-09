# Naomi — History

## Core Context

**Project:** TheSereyn.Templates — composition workspace for .NET project templates.
**User:** Lee Buxton
**Team:** Holden (Lead), Naomi (Template Engineer), Amos (Platform Engineer), Drummer (Security Reviewer), Scribe, Ralph

**My domain — template content:**
- `base/.github/copilot-instructions.md` — .NET coding standards for all templates
- `base/.github/copilot/skills/` — TUnit, StyleCop, compliance (GDPR, HIPAA, PCI DSS, SOC2, ISO27001), security-review, security-register, RFC compliance, code-analyzers, project-conventions, requirements-gathering, squad-setup
- `base/.github/prompts/` — first-time-setup, requirements-interview
- `base/Directory.Build.props` — .NET 10, TreatWarningsAsErrors, StyleCop, AnalysisLevel=latest-all
- `base/stylecop.json` — StyleCop config
- `base/README.md` — template README (uses {{PROJECT_NAME}} and {{DESCRIPTION}} placeholders)
- `overlays/blazor/` — Blazor-specific additions: devcontainer, mcp-config, copilot-instructions append, blazor-architecture skill, README
- `overlays/minimalapi/` — Minimal API README

**Key standards:**
- TUnit (not xUnit/NUnit/MSTest), async assertions
- StyleCop + Roslyn analyzers, TreatWarningsAsErrors
- Nullable enabled, file-scoped namespaces, implicit usings
- OpenTelemetry for observability
- IETF RFC 9205/9110/3986/9457 for HTTP/REST

## Learnings

### Prior Work Summary (Sessions 1–10, 2026-04-04 to 2026-04-08)

**Foundation & Prompt Architecture:** Conducted comprehensive content review (18 findings, 3 critical: MCP config, README accuracy, ISO 27001 reference dates). Implemented prompt split (host pre-container setup vs in-container first-time-setup). Researched and built CSS Design System skill for Blazor (Design Tokens + CUBE CSS + CSS Isolation). Integrated Spec Kit as primary spec-driven development workflow (planning tool paired with Squad implementation orchestrator).

**Key learnings from early sessions:**
- Post-create redundancy analysis prevents duplicate work — prompts should focus only on in-container configuration tasks
- Blazor CSS isolation + CSS custom properties together enable consistent component design — scoped styles reference global tokens
- Handoff model (planning tool → implementation orchestrator) is a clean separation of concerns
- Reviewer lockout policy applied during Spec Kit batch 2 (locked out from own revisions; Amos completed fixes)
- Environment-first scope: templates provide dev environment + workflow scaffolding, not solution/project scaffolding

**Work on dev branch by end of Session 10:**
- Spec Kit integration complete (skill, prompts, copilot-instructions, README updates)
- CSS Design System skill authored for Blazor template
- Pre-container setup prompt and first-time-setup prompt unified architecture
- Spec Kit security validated; v0.5.0 pinned; curl | sh pattern eliminated
- All Spec Kit work ready for v* tag and compose-and-publish workflow

### Recent Sessions (Sessions 11–12, 2026-04-09)

- Session 11 (2026-04-09): Podman compatibility fix — Docker feature removal and docs alignment.
   - Root cause: `docker-outside-of-docker` feature bind-mounts `/var/run/docker.sock` which doesn't exist on Podman hosts. Amos's interim fix (`docker-in-docker:2`) requires `"privileged": true` which also fails for rootless Podman.
   - Resolution: Removed Docker feature from both `base/.devcontainer/devcontainer.json` and `overlays/blazor/.devcontainer/devcontainer.json`. No scripts or workflows depend on Docker CLI inside the container — the feature was speculative.
   - Updated `base/.github/prompts/pre-container-setup.prompt.md`: replaced "fully supported" with runtime-neutral language, added Podman Desktop recommendation and Linux CLI compatibility note (`podman-docker` / `podman.socket`), made Step 5 note runtime-neutral ("container runtime" not "Docker and VS Code")
   - Updated all 3 READMEs (base, blazor, minimalapi): Prerequisites now link to "Docker Desktop" and "Podman Desktop" (not generic "Docker"/"Podman"), removed "Docker-in-Docker" from What's Included tables
   - Compose verified: both MinimalApi and Blazor templates compose cleanly
   - Key learning: Docker features (DooD and DinD) both introduce Podman incompatibility. DooD needs host socket; DinD needs privileged mode. Neither is needed for the .NET development workflow — templates ship no Dockerfiles or compose files. Users can add Docker features later when their project needs container build capabilities.
   - Key learning: Podman Desktop handles Docker API compatibility transparently (VM-based). Podman CLI on Linux needs explicit compatibility setup (`podman-docker` package or `systemctl --user enable --now podman.socket`). Documentation should recommend Desktop path and note CLI alternative.

- Session 12 (2026-04-09): Podman fix completion — decision records finalized, documentation merged.
   - Amos's docker-in-docker interim fix identified as incomplete (requires privileged mode for rootless Podman).
   - Collaborated with Amos: proposed Docker feature removal (lean principle — no template code needs it).
   - Implemented final solution: removed feature from base and overlays, unified runtime-neutral language across all surfaces.
   - Holden review gate passed: trade-off acceptable because no capability loss and user agency preserved.
   - All three decision records (Amos interim, Naomi final, Holden gate) merged to decisions.md.
   - Orchestration logs and session log written.
   - Ready for PR dev → main.

