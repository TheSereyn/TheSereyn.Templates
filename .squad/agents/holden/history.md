# Holden — History

## Core Context

**Project:** TheSereyn.Templates — composition workspace for .NET project templates.
**User:** Lee Buxton
**Team:** Holden (Lead), Naomi (Template Engineer), Amos (Platform Engineer), Drummer (Security Reviewer), Scribe, Ralph

**Key files:**
- `base/` — shared files for ALL templates
- `overlays/<name>/` — per-template additions and overrides
- `compose.sh` — merges base + overlay → `output/<template>/`
- `.github/workflows/compose-and-publish.yml` — tag-triggered publish to downstream repos
- `output/` — gitignored build artifacts; never edit directly

**Overlay semantics:**
- Same path as base → replaces base version
- New path → added
- `*.append.md` → content appended to matching base file

**Downstream templates:**
- TheSereyn.Templates.MinimalApi (`overlays/minimalapi/`)
- TheSereyn.Templates.Blazor (`overlays/blazor/`)

**Release process:** dev → PR → main → `v*` tag → compose-and-publish workflow fires

**Key decisions archive (Sessions 1-10, 2026-04-04 to 2026-04-08):**
- **Session 1-2:** Team initialized. Comprehensive template review (62 recommendations, 6 critical blockers). Most critical: MCP packages non-existent `@anthropic/*` names, devcontainer Podman-only, GitHub Actions mutable tags.
- **Session 3-4:** Prompt split implementation approved (3 files match spec). Pre-container-setup.md needs `git add`. Lesson: splitting composite steps improves scannability.
- **Session 5-6:** Pre-container variable split for `devcontainer.json` and `{{PROJECT_NAME}}` rationalized. Amos PR #26 merge; `.yml.disabled` pattern approved.
- **Sessions 7-10:** Spec Kit integration (github/spec-kit). Installed via `uv tool install`, scaffolds `.specify/` dir. Spec Kit owns spec→planning→breakdown; Squad owns implementation. Base files only. Two revision iterations (version pinning, fallback security). Drummer security review: main-branch 4 HIGH, 4 MEDIUM, 4 LOW findings.
- **Sessions 11-12:** Podman compatibility restoration approved. Docker features (DooD/DinD) removed — incompatible with Podman. Trade-off: users add Docker feature themselves if needed.

## Learnings

- Session 13 (2026-04-12T21:59:52Z): CLI template planning preference refinement
    - Orchestration logs created: 2026-04-12T21:59:52Z-holden.md (plan refinement), 2026-04-12T21:59:52Z-naomi.md (research update)
    - Session log created: 2026-04-12T21:59:52Z-cli-template-planning-preferences.md
    - Decision inbox merged: Two directives consolidated into decisions.md (maintained packages preference, Spectre.Console primary default, MIT licensing)
    - Inbox files deleted: copilot-directive-2026-04-12T21:54:08Z.md, copilot-directive-2026-04-12T21:55:56Z.md
    - CLI template planning refined per user directive (Lee Buxton):
      * Prefer maintained CLI packages (no abandoned/deprecated tooling)
      * Make Spectre.Console the primary default
      * Keep Spectre.Console.Cli, CliFx, Terminal.Gui as alternatives
      * Demote Cocona due to maintenance concerns
      * Record MIT as licensing preference
    - Decisions.md now ~29.5KB; archive will trigger at next ~10KB growth
    - Status: CLI template planning preferences documented and ready for downstream composition

- Session 14 (2026-04-12T22:13:20Z): CLI planning artifacts relocation
    - Coordinator completed artifact move to `.tmp/` — finalized CLI planning files now centrally located
    - Scribe merging decision inbox and creating orchestration artifacts

- Session 15: CLI template composition strategy — final planning pass
    - Full audit of base/ contents for CLI compatibility: identified ~120 lines of web-specific content in copilot-instructions.md, project-conventions skill ~65% web-specific
    - Architecture decision: Refactored Base + Overlays, no mixins. Make base universal .NET, push web content to overlay append files.
    - Key insight: base/.github/copilot-instructions.md is the critical refactoring target — Stack table, HTTP RFCs, CORS, security headers, CSRF, OpenTelemetry ASP.NET example all web-specific
    - 4 web-specific skills (aspnetcore-api-security, browser-security-headers, rfc-compliance, dotnet-authn-authz) stay in base as harmless reference material — not referenced in CLI copilot-instructions
    - project-conventions skill: CLI overlay replaces with CLI-specific version (exit codes, output discipline, command design) rather than splitting base
    - Mixin layer deferred: duplication (~120 lines copilot-instructions append) manageable at 3 templates. Revisit at 4+.
    - MinimalApi overlay grows: needs new copilot-instructions.append.md for web content removed from base
    - devcontainer.json: ports kept in base (harmless for CLI, avoids MinimalApi needing override)
    - Open question flagged: source code in CLI overlay (starter Program.cs) vs AI-first consistency
    - Decision written to: .squad/decisions/inbox/holden-cli-template-plan.md
    - Key file paths: .tmp/thesereyn-cli-template-plan.md (package strategy), .tmp/thesereyn-cli-template-research.md (ecosystem research), .tmp/thesereyn-cli-template-repo-fit.md (repo fit analysis)

- Session 16 (2026-04-14T17:24:29Z): CLI Template Planning — Squad Execution & Artifact Merge
     - **Three-agent cycle execution complete:** Holden (lead architectural decision), Amos (platform readiness), Naomi (content audit) converged on unified strategy
     - **Decision committed:** All three inbox files (holden-cli-template-plan, amos-cli-template-wiring, naomi-cli-template-split) consolidated into decisions.md
     - **Orchestration log created:** 2026-04-14T17:24:29Z-holden.md documents lead recommendation
     - **Session log created:** Consolidated team outcome showing three-agent convergence on base refactoring prerequisite
     - **Inbox file deleted:** holden-cli-template-plan.md removed post-merge
     - **Agent history updated:** Tracks architectural decision and next-phase sequencing
     - **Key outcomes:** Base refactoring is prerequisite; mixin layer deferred to 4+ templates; no infrastructure changes needed

## 2026-04-14: CLI Template Architecture Review

Reviewed Amos (wiring) + Naomi (base/overlay split). Verdict: ✅ APPROVED. Base is template-neutral; web guidance correctly in overlay appends; CLI overlay uses all three overlay semantics correctly. Known trade-off: base project-conventions is web-specific, replaced by CLI overlay. Non-blocking nit: remove .gitkeep in housekeeping.

## 2026-04-14: Team Orchestration — Prompt Guidance Update

Squad orchestration cycle completed. Prompt guidance review (commit 2f86516) approved and archived to decisions. Three inbox entries merged to decisions.md; orchestration logs written; team history updated cross-agent. Ready for tag push to main.

## Learnings

- Session 19: Setup workflow redesign review (commit eca2808)
    - **Verdict:** ✅ APPROVED — Naomi's full-but-lean setup redesign
    - Reviewed 15 changed files across base, overlays (minimalapi, blazor, cli), post-create scripts, copilot-instructions, and CHANGELOG
    - Flow coherence confirmed: `pre-container-setup` → `/environment-check` → `/project-setup` is a clean linear progression
    - Naming improved: `project-setup` describes what it does (not when); `environment-check` describes its role as readiness gate
    - Compliance model is well-scoped: two-question declaration in main setup (~60s), dedicated idempotent `/compliance-setup` for depth
    - Security baseline correctly placed at Step 2 — repo-level settings that don't need project structure
    - All four READMEs aligned identically; post-create scripts updated; copilot-instructions prompt table restructured
    - No stale references to old names (`first-time-setup`, `verify-setup`) in any active template files
    - Self-cleanup section in project-setup correctly separates one-time vs re-runnable prompts
    - Slight gh auth redundancy between environment-check and project-setup is acceptable (gate vs wizard pattern)
    - Decision written to: .squad/decisions/inbox/holden-review-setup-flow.md

### Session 19 (2026-04-14) — Setup Workflow Implementation Lead Review Complete

**Review delivered:** Holden approved setup workflow redesign (2026-04-14).

- ✅ **Flow coherence:** Renamed prompts clarify *what* they do. `environment-check` promoted to first in-container gate (validate before configuring).
- ✅ **Compliance model:** Full-but-lean design coherent. Two questions + skip/defer in main setup, dedicated `/compliance-setup` for depth (≤3 per framework).
- ✅ **Cross-template alignment:** All four READMEs identical. Post-create scripts updated. No stale references.
- ✅ **Scope:** Tightly scoped to setup flow. Requirements-interview correctly demoted to "(optional)".

**Non-blocking observations:** `gh auth status` appears in both environment-check and project-setup (acceptable: one is passive gate, one acts). Self-cleanup correctly separates one-time vs re-runnable.

**Verdict:** Approved. All checks pass.

**Decision merge:** Input merged to `.squad/decisions/decisions.md` by Scribe.

**Team synthesis:** Implementation, security review, and lead review all complete. Ready for merge and publication.

## Session 20 (2026-04-14): v0.5.0 Release Gate Review

**Verdict:** ❌ REJECT — documentation blockers prevent tagging.

**Content assessment:** v0.5.0 scope is substantial and justified — CLI template addition, base generalisation, Podman fix, setup workflow redesign. All three templates compose cleanly. CLI downstream repo exists.

**Blockers found:**
1. CHANGELOG missing entire [0.4.0] section (v0.4.0 was tagged but never documented)
2. CHANGELOG [Unreleased] incomplete — only covers setup workflow, missing CLI template, Podman fix, base refactor
3. README.md has stale references ("Docker-outside-of-docker", "First-time Setup Prompt")

**Assignment:** Naomi to resolve all three documentation blockers. After fixes, PR dev → main, then Holden re-gates for tag.

**Decision written to:** `.squad/decisions/inbox/holden-release-gate.md`

## Session 21 (2026-04-14): Doc-Fix Re-Review — v0.5.0 Release Gate

**Verdict:** ✅ APPROVE — all three documentation blockers from Session 20 resolved.

**Commits reviewed:** 370d204 (doc fixes), b2e8307 (Naomi history + decision record)

**Blocker resolution:**
1. ✅ CHANGELOG [0.4.0] backfilled — comprehensive section covering Spec Kit, supply-chain pinning, CI hardening, MCP fixes, verify-setup, and more
2. ✅ CHANGELOG [0.5.0] complete — CLI template, base generalisation, Podman fix, setup workflow redesign, compliance-setup, project-setup (with README rewrite) all documented
3. ✅ README.md stale references fixed — "Docker-outside-of-docker" → current DevContainer list; "First-time Setup Prompt" and "Business Analyst Agent" replaced with Spec Kit, Squad, and current prompt names

**Bonus:** CONTRIBUTING.md updated with CLI template in downstream list and validation section.

**[Unreleased]** section is empty (correct — everything moved to [0.5.0]).

**Status:** Documentation is release-ready. PR dev → main can proceed, then tag v0.5.0.

## Session 22 (2026-04-14T20:29:04Z): v0.5.0 Release Orchestration & Scribe Documentation

**Role in release execution:**
- **Initial gating (Session 20):** Identified three documentation blockers; rejected tagging; assigned remediation to Naomi.
- **Re-review (Session 21):** Verified all blockers resolved; approved release gate.
- **Release authorization:** Approved dev → main PR merge and v0.5.0 tag push.

**Release outcome:**
- ✅ GitHub Release v0.5.0 published targeting main
- ✅ Compose-and-publish workflow 24420932683 completed successfully
- ✅ All three downstream repos (MinimalApi, Blazor, CLI) pushed and tagged v0.5.0
- ✅ CLI repository contains expected prompts

**Follow-up:** Post-release, minor stale wording in already-published CLI README identified; Naomi corrected source docs on dev (pending dev push for cleanup).

**Orchestration log created:** 2026-04-14T20:29:04Z-holden.md documents two-phase review and approval flow.
