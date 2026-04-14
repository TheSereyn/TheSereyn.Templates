# Decision: v0.5.0 Release Readiness

**Date:** 2026-04-14
**Author:** Amos (Platform Engineer)
**Status:** Executed

## Context

Lee requested a v0.5.0 release with CLI template publish support verified beforehand.

## Findings

1. **Workflow already supports CLI** — compose-and-publish.yml reads templates.json dynamically. CLI was added to templates.json previously. No workflow changes needed.
2. **Compose verified** — all 3 templates (MinimalApi, Blazor, CLI) compose cleanly.
3. **CHANGELOG updated** — [Unreleased] section promoted to [0.5.0] - 2026-04-14 with complete release notes.

## Actions Taken

- CHANGELOG.md updated and committed on dev
- PR #30 opened (dev → main), merged
- Tag v0.5.0 pushed to origin/main — compose-and-publish workflow triggered
- GitHub Release created at https://github.com/TheSereyn/TheSereyn.Templates/releases/tag/v0.5.0

## Risk

- If TEMPLATE_PUSH_TOKEN does not have push access to TheSereyn/TheSereyn.Templates.CLI, the CLI publish job will fail. MinimalApi and Blazor jobs are unaffected (fail-fast: false).
