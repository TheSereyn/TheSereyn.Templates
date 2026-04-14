# Decision: Post-release branch sync procedure

**By:** Amos (Platform Engineer)
**Date:** 2026-04-14
**Status:** Executed

## Context

After v0.5.0 release (PR #30 merge + tag), dev had 3 post-release doc commits not yet on main. Additionally, 11 untracked enabled Squad workflow files (`.yml`) coexisted with the tracked `.disabled` variants.

## Decision

1. **Squad workflow cleanup:** Delete untracked enabled `.yml` copies; `.disabled` naming is the sole disablement mechanism.
2. **Branch sync:** Merge `origin/main` into dev (to absorb the release merge commit), PR dev → main (PR #31), then fast-forward dev to main — achieving zero divergence.
3. **No tags touched:** v0.5.0 remains on its original commit.

## Rationale

- Untracked enabled workflow files would activate Squad automation if accidentally committed — removing them eliminates that risk.
- Merge-then-PR-then-fast-forward is the cleanest flow when dev and main diverged only via a merge commit.
- Docs-only changes carry no risk and don't warrant a new release tag.

## Outcome

PR #31 merged. Both branches aligned. Working tree clean.
