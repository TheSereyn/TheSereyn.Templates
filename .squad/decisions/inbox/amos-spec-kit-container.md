# Decision: Spec Kit CLI Installation in Dev Container

**By:** Amos (Platform Engineer)
**Date:** 2026-04-08
**Status:** Implemented on dev

## Decision

Install Spec Kit CLI (`specify-cli`) in the shared dev container via `uv tool install`, pinned to v0.5.0. Python 3.12 added as a devcontainer feature to provide the required runtime.

## Implementation

- **Python feature:** `ghcr.io/devcontainers/features/python:1` with `version: "3.12"` added to devcontainer.json
- **uv install:** `python3 -m pip install --user --quiet uv` in post-create.sh
- **Spec Kit install:** `uv tool install specify-cli --from "git+https://github.com/github/spec-kit.git@v0.5.0"` — pinned to release tag
- **PATH:** `~/.local/bin` added to .bashrc for uv tools to be available in subsequent shells

## Rationale

- `uv` is Spec Kit's officially recommended package manager
- Pinned to v0.5.0 (latest stable release) for reproducibility
- Used `pip install` for uv (not `curl | sh`) per security review guidance
- Applied to both base and Blazor overlay since overlay replaces base
- Idempotent: `|| true` guards and `uv tool install` is safe to re-run

## Versioning

When Spec Kit releases a new version, update the `@v0.5.0` tag in both `base/.devcontainer/post-create.sh` and `overlays/blazor/.devcontainer/post-create.sh`. The `uv` package manager itself is left unpinned (backward-compatible tool).
