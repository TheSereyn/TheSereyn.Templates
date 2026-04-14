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


### Session 13 (2026-04-12T21:59:52Z): CLI Template Planning Preferences

- Orchestration logs created: 2026-04-12T21:59:52Z-naomi.md (research update and template guidance)
- Session log created: 2026-04-12T21:59:52Z-cli-template-planning-preferences.md
- Decision inbox merged: Two directives consolidated into decisions.md:
  * Prefer maintained CLI packages (no deprecated/abandoned tooling)
  * Spectre.Console as primary default
  * Spectre.Console.Cli, CliFx, Terminal.Gui as alternatives
  * Cocona marked not recommended (maintenance concerns)
  * MIT licensing preference confirmed
- Inbox files deleted: copilot-directive-2026-04-12T21:54:08Z.md, copilot-directive-2026-04-12T21:55:56Z.md
- CLI research document updated with package maintenance prioritization and Spectre.Console recommendation
- Template guidance refined for CLI template composition
- Ready for downstream CLI template implementation

### Session 14 (2026-04-12): CLI Template Content Split Audit

- **Read-only planning pass:** Audited all base/ and overlay/ content to identify what must change before CLI template can compose cleanly.
- **Core finding:** base/ is not template-neutral — copilot-instructions.md, project-conventions skill, README.md, devcontainer.json, and first-time-setup prompt all carry web/API assumptions that would mislead Copilot in a CLI context.
- **Recommended approach:** Generalize base/ to be template-neutral, use `.append.md` in all three overlays (minimalapi, blazor, cli) to add template-specific content.
- **Key split decisions:**
  - copilot-instructions.md: Stack table, security principles, observability, delivery format, ask-first triggers, micro-checklists all need web content extracted.
  - project-conventions skill: Must be split — universal .NET patterns stay in base, API-specific patterns (REPR, RFC 9457, pagination, URL structure) move to a new `api-conventions` skill in web overlays.
  - Base README: Architecture diagram, manual setup commands, example commands all web-specific — need generalization.
  - Devcontainer: `forwardPorts` must leave base. MinimalApi overlay needs its own devcontainer.json (currently inherits base's).
  - Security skills in base: Can stay — they're reference material, not injected into every interaction.
- **MinimalApi overlay impact:** Grows from 1 file to ~5 files (README, copilot-instructions.append, devcontainer, api-conventions skill).
- **5 user decisions identified** that materially affect the content plan (starter code, Azure CLI, Generic Host, forwarded ports, minimalapi devcontainer).
- **Decision record written:** `.squad/decisions/inbox/naomi-cli-template-split.md`
- **Key learning:** The base/.github/copilot-instructions.md is the highest-impact file — it's read by Copilot for every interaction. Web-specific content here actively misleads CLI development. Skills are lower-impact because they're only consulted when referenced.
- **Key learning:** The thin minimalapi overlay (1 file) only works because base IS the minimalapi template. Once base is generalized, minimalapi must carry its own web-specific content — it can no longer free-ride on base.

### Session 16 (2026-04-14T17:24:29Z): CLI Template Planning — Squad Execution & Artifact Merge

- **Execution complete:** Content audit merged into unified team strategy
- **Decision committed:** naomi-cli-template-split.md consolidated into decisions.md (deduplicated with Holden and Amos inputs)
- **Orchestration log created:** 2026-04-14T17:24:29Z-naomi.md documents audit findings and CLI overlay content
- **Inbox file deleted:** naomi-cli-template-split.md removed post-merge
- **Agent history updated:** Tracks content split specifics, user decision flags, overlay growth calculations
- **Template engineering readiness:** Phase 1 (base generalization) planned; Phase 2 (CLI overlay creation) scoped and ready for execution

## 2026-04-14: CLI Template Content Split

Generalised base to template-neutral (252→205 lines); created CLI overlay with System.CommandLine + Spectre.Console; preserved web guidance in MinimalApi/Blazor appends. All three templates compose successfully. Commit: 41f3efb. Approvals: ✅ Holden (Lead), ✅ Drummer (Security).

## 2026-04-14: Team Orchestration — Prompt Guidance Update

Squad orchestration cycle completed. Prompt guidance work (commit 2f86516) approved and archived to decisions. Three inbox entries merged to decisions.md; orchestration logs written; team history updated cross-agent. Ready for tag push to main.

### Session 17 (2026-04-14): Compliance vs Security Hardening — Onboarding Analysis & Orchestration

- **Task:** Evaluate whether compliance setup (Step 8) and security hardening (Step 12) should remain together in first-run setup, be split, or deferred.
- **Key finding:** These two concerns are structurally different. Security hardening is operational infrastructure (universal, mechanical, prevents immediate harm). Compliance is strategic governance (project-specific, requires domain knowledge, no immediate risk from deferral).
- **Gap analysis conducted:** Setup journey from "Use this template" through readiness for Spec Kit. Current issues: first-time-setup mixes four responsibilities; verify-setup duplicates verification; requirements-interview surfaced incorrectly; pre-container-setup bleeding into in-container; README sequencing backwards.
- **Target flow identified:** README → pre-container-setup → environment-check (rename verify-setup) → project-setup (rename first-time-setup) → Spec Kit handoff
- **Requirements-interview verdict:** Keep it, demote out of setup. Optional off-ramp for vague ideas; Spec Kit is primary default.
- **Three options presented to Lee:**
  - **Option A:** Keep both early (restructured) — move security hardening to Step 2; improve compliance framing; preserve maximum protection
  - **Option B:** Split — security stays early, compliance gets dedicated `/compliance-setup` prompt — compliance elevated, not demoted
  - **Option C:** Defer both — rejected; security gaps in interim window
- **Recommendation (Naomi):** Option B with elevation framing. Security stays non-negotiable; compliance gets first-class dedicated prompt with richer treatment after requirements gathering.
- **Orchestration completed:** Two decision files written (`setup-journey-gap-analysis-20260414.md`, `naomi-compliance-setup.md`); awaiting Lee's decision between Options A, B, or C before implementation phase.
- **Decisions merged:** Gap analysis and recommendations merged to .squad/decisions.md; inbox files deleted; orchestration log written (2026-04-14T19:21:07Z-naomi.md).
