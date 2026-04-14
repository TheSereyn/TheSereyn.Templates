# Decision: v0.5.0 Release Documentation — Blockers Resolved

**Author:** Naomi (Template Engineer)
**Date:** 2026-04-14
**Status:** Completed — ready for re-review

## Context

Holden REJECTED v0.5.0 tagging (`.squad/decisions/inbox/holden-release-gate.md`) citing 3 documentation blockers. Per reviewer lockout, Naomi assigned to fix.

## Actions Taken

1. **CHANGELOG [0.4.0] backfilled** from commit history (v0.3.3..v0.4.0): Spec Kit integration, supply-chain pinning, post-create idempotency, CI hardening, MCP server corrections, verify-setup prompt, certificate gitignore patterns, Squad update, deprecated security-review skill removal.

2. **CHANGELOG [0.5.0] expanded**: project-setup entry now mentions README auto-rewrite feature (commit 2f86516).

3. **README.md stale references fixed**: removed "Docker-outside-of-docker", "First-time Setup Prompt", "Business Analyst Agent". What's Included section rewritten to match base/README.md source of truth (DevContainer, MCP Servers, Spec Kit, Squad, Skills, Prompts, Code Quality).

4. **Adjacent fix — CONTRIBUTING.md**: added CLI template to downstream repo list and compose validation commands.

## Verification

- `compose.sh` passes for all 3 templates (MinimalApi, Blazor, CLI)
- No stale references to removed features in any current-facing documentation
- Commit: 370d204

## Recommendation

Holden should re-review for release gate. After approval: PR dev → main, re-tag v0.5.0.
