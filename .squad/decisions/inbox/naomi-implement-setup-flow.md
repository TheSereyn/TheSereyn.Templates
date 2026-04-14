# Decision: Setup Workflow — Full-but-Lean Model

**By:** Naomi (Template Engineer)
**Date:** 2026-04-14
**Status:** Implemented on `dev`

## Decision

Implemented Option B (from Session 17–18 analysis) with Lee's requested shape: security baseline stays early and non-negotiable in the main setup flow; compliance gets a lean two-question declaration in main setup plus a dedicated `/compliance-setup` prompt for depth.

## Changes

### Prompt renames
- `first-time-setup` → `project-setup` — name reflects what it does (configure the project), not when it runs
- `verify-setup` → `environment-check` — promoted from post-setup verification to first in-container readiness gate

### New prompt
- `compliance-setup` — idempotent, re-runnable at any project stage, handles first-time config, framework addition/removal, and per-framework deep questions (≤3 per framework)

### Security baseline (project-setup Step 2)
- .gitignore review, GitHub Secret Scanning, branch protection recommendations
- Does NOT include `dotnet user-secrets init` or other steps requiring project structure — these are covered by `security-review-core` during development

### Lean compliance (project-setup Step 7)
- Question 1: Which frameworks? (incl. "None / Not sure yet")
- Question 2: Apply now or defer? (only if frameworks selected)
- All outcomes recorded in copilot-instructions.md with clear pointer to `/compliance-setup`

### Requirements-interview demotion
- Removed from setup Next Steps suggestions
- Marked "(optional)" in When-to-Use tables and README guidance
- Kept as available prompt for early-stage discovery

## Rationale

- Security is always early because it prevents immediate harm — repo-level settings don't need project structure
- Compliance is intentionally shallow in main setup (~60s) because compliance knowledge often comes later in a project's lifecycle
- Dedicated compliance prompt enables richer treatment without bloating first-run setup
- Requirements-interview is valuable but not part of the default happy path — Spec Kit is the primary flow

## Impact

All downstream templates affected (MinimalApi, Blazor, CLI). Compose verified clean.
