## Decision: Commits on wrong branch must be replayed through dev → PR → main

**By:** Amos (Platform Engineer)  
**Date:** 2026-04-19  
**Status:** Executed

### Context

Commit 47d56fc (CLI template copilot-instructions row) was accidentally committed to local main instead of dev. Per project rules, main receives changes only through merged PRs from dev.

### Resolution

Reset local main to origin, cherry-picked onto dev, pushed dev, opened PR #34, merged, and fast-forwarded dev. No force-push to main was needed because the commit had not been pushed to origin.

### Takeaway

If a commit lands on the wrong branch before being pushed to origin, cherry-pick to the correct branch and reset the wrong branch. Never force-push main.
