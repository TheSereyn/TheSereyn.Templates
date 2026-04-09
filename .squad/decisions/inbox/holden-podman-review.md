# Decision: Approve Podman Compatibility Restoration

**By:** Holden (Lead)
**Date:** 2026-04-09
**Status:** ✅ APPROVED

## Scope

Quality gate review of commits `2ccef32`, `4e839ba`, `0a2d769` on `dev` — restoring Podman compatibility that was broken by Docker-specific devcontainer features.

## Verdict: APPROVED

### What was broken

The `docker-outside-of-docker` devcontainer feature hardcodes a bind mount of `/var/run/docker.sock → /var/run/docker-host.sock`. On Podman hosts, `/var/run/docker.sock` does not exist, causing container creation to fail entirely.

### Fix path (two iterations, correct final state)

1. **Amos (2ccef32):** Swapped to `docker-in-docker:2` — removes host socket dependency but requires privileged mode, which fails on rootless Podman (the default Podman configuration). Partial fix.
2. **Naomi (4e839ba):** Removed Docker feature entirely — no scripts, workflows, or template files need Docker CLI inside the container. The feature was speculative. Complete fix.

### Why the trade-off is acceptable

- **No capability loss:** Templates ship no Dockerfiles, docker-compose files, or CI workflows that invoke `docker` inside the dev container. The Docker feature was prospective convenience, not a dependency.
- **User agency preserved:** Projects that later need Docker CLI access can add `docker-in-docker` or `docker-outside-of-docker` to their own `devcontainer.json`. One line of JSON.
- **Lean dependency principle upheld:** Don't ship what isn't needed. This is core template philosophy.
- **Both runtimes now work:** Docker Desktop users lose nothing from the core workflow (dotnet build/test/run). Podman users can now build and open the container successfully.

### Documentation accuracy verified

- `pre-container-setup.prompt.md`: Runtime-neutral language ("container runtime" not "Docker and VS Code"), Podman Desktop recommendation with Linux CLI fallback guidance
- All 3 READMEs: Prerequisites link "Docker Desktop" / "Podman Desktop", no "Docker-in-Docker" in What's Included tables
- Composition verified: both MinimalApi and Blazor templates compose cleanly

### No Docker regression

Confirmed: zero references to `docker.sock`, `docker-in-docker`, `docker-outside-of-docker`, or `privileged` mode in any devcontainer.json (base or overlay). `--security-opt=label=disable` correctly retained for SELinux compatibility.

## Next Steps

- Merge inbox decision records (this file + Amos's + Naomi's) into `decisions.md`
- PR dev → main when ready
- No further revision needed
