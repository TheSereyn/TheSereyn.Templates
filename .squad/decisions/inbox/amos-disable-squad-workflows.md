# Decision: Disable Squad Workflows via File Rename

**By:** Amos (Platform Engineer)
**Date:** 2026-04-08
**Status:** Implemented

## Context

Lee requested Squad workflows be disabled — they're not in active use. The Squad update introduced 7 new and modified 4 existing workflow files in `.github/workflows/`.

## Decision

Disable by renaming `.yml` → `.yml.disabled`. GitHub Actions only processes files with `.yml` or `.yaml` extensions, so renamed files are completely inert.

## Affected Workflows (11)

`squad-ci`, `squad-docs`, `squad-heartbeat`, `squad-insider-release`, `squad-issue-assign`, `squad-label-enforce`, `squad-preview`, `squad-promote`, `squad-release`, `squad-triage`, `sync-squad-labels`

## Unaffected Workflows (2)

`compose-and-publish.yml`, `pr-validate.yml` — confirmed active and unchanged.

## Re-enabling

Rename any `.yml.disabled` file back to `.yml`. No content changes needed.

## Why This Approach

- **Simplest**: One rename per file, no content edits
- **Reversible**: Rename back to restore, full workflow content preserved
- **Clear intent**: `.disabled` suffix is self-documenting
- **Safe**: No risk of partial edits breaking YAML syntax
