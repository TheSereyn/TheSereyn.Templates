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

## Learnings

- Session 1 (2026-04-04): Team initialized. Holden is Lead. Universe: The Expanse.

- Session 2 (2026-04-04): Led comprehensive template review with all team members.
  - Identified 62 consolidated recommendations across architecture, content, platform, security
  - 6 Critical blockers must be fixed before templates are production-ready
  - Key finding: MCP packages, devcontainer (Podman-only), postCreateCommand chain all broken
  - Most critical: All MCP tooling fails day one due to non-existent `@anthropic/*` package names
  - Devcontainer hard-fails on Docker Desktop (majority of target users)
  - GitHub Actions pinned to mutable tags (supply chain risk)
  - Assembled individual findings into consolidated 341-line review with full remediation guidance
  - Cross-cutting findings indicate high confidence in critical issues

- Session 3 (2026-04-05): Reviewed Naomi's prompt split implementation against spec.
  - APPROVED: All three files (`pre-container-setup.prompt.md`, `first-time-setup.prompt.md`, `README.md`) match the design spec
  - Minor acceptable deviations: 8 steps vs 7 (better UX), "Podman Desktop" vs "Podman" (better for target audience), 4 README steps vs 3 (self-contained)
  - Key finding: `pre-container-setup.prompt.md` is untracked in git — needs `git add` before PR
  - Lesson: Splitting composite steps (open + wait) into discrete steps improves scannability for checklist-style prompts

- Session 4 (2026-04-04T17:49:01Z): Scribe closed prompt-split phase.
   - Naomi's implementation matches spec — approved for PR #21
   - Drummer approved security — no changes required
   - Amos opened PR to dev
   - Orchestration log created and archived
   - Inbox decisions merged to decisions.md

- Session 5 (2026-04-06): Fixed pre-container vs in-container template variable split.
  - `devcontainer.json` `{{PROJECT_NAME}}` moved to pre-container phase (Step 5 in pre-container-setup.prompt.md)
  - Rationale: Docker/VS Code reads container name at build time; setting it inside container after first build is a silent no-op
  - Removed `devcontainer.json` from first-time-setup.prompt.md Step 5 file list
  - Decision note written to .squad/decisions/inbox/holden-precontainer-var-split.md
  - Overlay devcontainer.json files unchanged — {{PROJECT_NAME}} placeholder correct as-is

- Session 6 (2026-04-08): Reviewed and landed Amos follow-up commit a2c894e to main.
  - Commit: docs-only — Amos history (Session 5) + workflow disable decision record
  - Reviewed diff: 2 files in `.squad/`, 41 lines added, no code/config/security surface
  - Approved as-is: accurate record of PR #25 work, follows decision recording pattern
  - Created PR #26 (dev → main), merged. Main fully caught up to dev.
  - Amos's `.yml.disabled` rename pattern is the right call — simple, reversible, self-documenting
  - Workflow: PR #25 landed the substance, PR #26 landed the documentation trail

- Session 7 (2026-04-08): Spec Kit integration decision.
  - Reviewed Spec Kit (github/spec-kit) — Python CLI installed via `uv tool install`, scaffolds `.specify/` dir with SDD slash commands
  - Decision: Runtime init, not pre-generated artifacts. Install `specify` CLI in devcontainer, guide users to `specify init --here --ai copilot` during first-time-setup
  - Spec Kit + Squad pairing: Spec Kit owns specification → planning → task breakdown; Squad owns implementation. `/speckit.implement` superseded by Squad agents
  - Placement: 100% base/, 0% overlays. SDD is template-agnostic
  - Technical: Need `uv` (standalone installer or pip) + `uv tool install specify-cli --from git+https://github.com/github/spec-kit.git@vX.Y.Z` pinned to release tag
  - Security: Drummer to review `curl | sh` for uv installer; pip alternative available since Python 3.12 ships with Ubuntu Noble
  - Decision recorded to `.squad/decisions/inbox/holden-spec-kit-integration.md`
  - Implementation assigned: Amos (devcontainer), Naomi (prompts/docs/instructions), Drummer (security review)

- Session 8 (2026-04-08): Reviewed Spec Kit integration change set on dev (4 commits, 16 files, 466 insertions).
  - APPROVED with two required revisions before merging to main.
  - Architecture is correct: 100% base/ placement, overlay duplication where overlay replaces base, Spec Kit + Squad pairing coherent across all 10 content artifacts.
  - Issue 1 (Naomi): Version pinning contradiction — first-time-setup.prompt.md and spec-driven-development SKILL.md use `@latest` instead of the pre-installed pinned binary. Fix: `specify init --here --ai copilot` (use the v0.5.0 binary installed by post-create.sh).
  - Issue 2 (Naomi/Drummer): curl | sh fallback in Step 10 contradicts Amos's `pip install uv` security choice. Fix: use `python3 -m pip install --user uv` as fallback, or Drummer formally approves curl | sh.
  - Non-blocking: `/speckit.implement` listed in SKILL.md command table but superseded by Squad — add clarifying note.
  - Decision recorded to `.squad/decisions/inbox/holden-spec-kit-review.md`

- Session 8 (2026-04-08): Spec Kit batch 1 — Team execution and decision merge.
  - Amos completed devcontainer integration: uv + specify-cli@v0.5.0 in base + Blazor overlay post-create.sh; Python 3.12 feature added
  - Naomi completed template guidance: spec-driven-development skill, copilot-instructions updates, first-time-setup prompt (added Step 10 — Spec Kit init), README updates
  - Spec Kit integration is now production-ready for all downstream templates
  - Decision inbox merge in progress — all 7 inbox files consolidated into decisions.md under 2026-04-08 section
  - Orchestration logs written for Holden, Naomi, Amos; session log written; git commit pending
