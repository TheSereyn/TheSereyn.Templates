# Decision: Replace docker-outside-of-docker with docker-in-docker

**By:** Amos (Platform Engineer)
**Date:** 2026-04-09
**Status:** Implemented on dev

## Context

The `docker-outside-of-docker` devcontainer feature bind-mounts the host's `/var/run/docker.sock` into the container. On Podman hosts, this file does not exist — causing container creation to fail entirely. This broke Podman support, which was previously working.

## Decision

Replace `ghcr.io/devcontainers/features/docker-outside-of-docker:1` with `ghcr.io/devcontainers/features/docker-in-docker:2` in both the base and Blazor overlay devcontainer.json files.

### Why docker-in-docker

- Runs its own Docker daemon (Moby engine) inside the container
- Zero dependency on the host's container runtime or socket
- Works identically on Docker, Podman, and GitHub Codespaces hosts
- The `docker-outside-of-docker` feature cannot be made runtime-aware — the socket path is hardcoded in a mount declaration that the devcontainer CLI evaluates before any lifecycle script runs

### Configuration

```json
"ghcr.io/devcontainers/features/docker-in-docker:2": {
  "installDockerBuildx": false
}
```

- `moby: true` (default) — required; docker-in-docker needs the engine
- `installDockerBuildx: false` — matches prior minimal config
- `--security-opt=label=disable` runArg retained — still needed for Podman on SELinux

### Known Limitation

On rootless Podman hosts, `dockerd` inside the container may fail to start if the host doesn't grant sufficient privileges (cgroups, overlayfs). The container itself builds and runs fine — only Docker commands inside would be unavailable. This is an inherent Podman rootless limitation, not a template defect. Full Docker-in-Docker parity requires either rootful Podman or Docker as the host runtime.

## Files Changed

- `base/.devcontainer/devcontainer.json` — feature swap
- `overlays/blazor/.devcontainer/devcontainer.json` — feature swap (overlay replaces base)
- `base/README.md` — "Docker-outside-of-Docker" → "Docker-in-Docker" in table
- `overlays/blazor/README.md` — same
- `overlays/minimalapi/README.md` — same

## Docs Impact

The pre-container-setup prompt already says "Install Docker Desktop or Podman Desktop — both are fully supported" and needs no change. Naomi should be aware of the terminology change from "Docker-outside-of-Docker" to "Docker-in-Docker" if any future prompt or skill references the specific feature name.
