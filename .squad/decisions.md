# Squad Decisions

## Active Decisions

### 2026-04-04: Default agent model
**By:** Lee Buxton
**Decision:** Default model for all agents is `claude-opus-4.6`. Fall back to `claude-opus-4.5` if a specific capability is unavailable in 4.6. Only recommend a different model family when a required feature (e.g. vision) is unsupported by any opus model. Scribe is exempt — remains on `claude-haiku-4.5`.

## Governance

- All meaningful changes require team consensus
- Document architectural decisions here
- Keep history focused on work, decisions focused on direction
