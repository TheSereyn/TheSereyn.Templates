# Decisions

---
## Decision: Post-release branch sync procedure

**By:** Amos (Platform Engineer)  
**Date:** 2026-04-14  
**Status:** Executed

### Context

After v0.5.0 release (PR #30 merge + tag), dev had 3 post-release doc commits not yet on main. Additionally, 11 untracked enabled Squad workflow files (`.yml`) coexisted with the tracked `.disabled` variants.

### Decision

1. **Squad workflow cleanup:** Delete untracked enabled `.yml` copies; `.disabled` naming is the sole disablement mechanism.
2. **Branch sync:** Merge `origin/main` into dev (to absorb the release merge commit), PR dev → main (PR #31), then fast-forward dev to main — achieving zero divergence.
3. **No tags touched:** v0.5.0 remains on its original commit.

### Rationale

- Untracked enabled workflow files would activate Squad automation if accidentally committed — removing them eliminates that risk.
- Merge-then-PR-then-fast-forward is the cleanest flow when dev and main diverged only via a merge commit.
- Docs-only changes carry no risk and don't warrant a new release tag.

### Outcome

PR #31 merged. Both branches aligned. Working tree clean.

---

## Directive: Keep Squad workflows disabled (user request)

**Date:** 2026-04-14T21:04:36Z  
**By:** Lee Buxton (via Copilot)

Keep the Squad-related workflows disabled using the existing `.disabled` naming approach, and make sure any remaining `dev` changes are committed, synced, and merged into `main`.

**Rationale:** User request — captured for team memory.

---

## Decision: Always fast-forward dev after merging to main

**By:** Amos (Platform Engineer)  
**Date:** 2026-04-14  
**Status:** Approved — ongoing procedure

### Context

After PR #31 merged dev → main, a single docs commit remained on dev that wasn't on main. After that was merged via PR #32, the merge commit left main 1 ahead of dev.

### Decision

After every dev → main PR merge, immediately fast-forward dev to main's new HEAD. This prevents residual 0/1 drift that accumulates and confuses branch comparisons.

### Rationale

GitHub merge commits create a new commit on main not present on dev. Without the follow-up fast-forward, `rev-list` always shows main ahead by 1, making it impossible to verify true alignment. The fast-forward is always safe because dev is an ancestor of main's merge commit.
