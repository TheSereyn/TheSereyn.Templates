# Contributing to TheSereyn.Templates

## Table of Contents
- [Composition Model](#composition-model)
- [Local Development](#local-development)
- [Making Changes](#making-changes)
- [Branch Strategy](#branch-strategy)
- [Adding a New Template](#adding-a-new-template)
- [Release Process](#release-process)
- [Branch Protection](#branch-protection)

## Composition Model

This repository uses a base + overlay composition model:

- **`base/`** — Files shared across ALL templates. Changes here affect every template.
- **`overlays/<template>/`** — Per-template additions and overrides. Same path as base → replaces. New path → added. `*.append.md` → content appended to the matching base file.
- **`output/`** — Gitignored build artifacts. Never edit directly.

### Overlay Semantics

| Overlay file | Behaviour |
|-------------|-----------|
| Same path as base | Replaces the base version entirely |
| New path (not in base) | Added to the composed output |
| `*.append.md` | Content appended to the matching base file (strip `.append` from name) |

### Composition is Authoritative

**The composition workspace is the single source of truth.** Downstream template repositories (`TheSereyn.Templates.MinimalApi`, `TheSereyn.Templates.Blazor`) are generated from this workspace on every tag push. Any direct commits to downstream repos will be **overwritten** on the next publish.

If you need to hotfix a downstream repo, make the change here and republish.

## Local Development

### Prerequisites

- Docker Desktop or Podman
- VS Code with Dev Containers extension (recommended)

### Testing Composition Locally

```bash
# Compose all templates
bash compose.sh

# Inspect output
ls output/

# Compose a single template
bash compose.sh minimalapi
```

### Validating Changes

Before pushing, verify your compose output is valid:
```bash
# Compose and check output
bash compose.sh
test -f output/TheSereyn.Templates.MinimalApi/README.md && echo "MinimalApi OK"
test -f output/TheSereyn.Templates.Blazor/README.md && echo "Blazor OK"
```

## Making Changes

1. Branch from `dev`: `git checkout -b feature/your-feature dev`
2. Make changes in `base/` or `overlays/`
3. Test with `bash compose.sh`
4. Commit and push
5. Open a PR to `dev`
6. Once merged to `dev`, open a PR from `dev` to `main`
7. Tag on `main` to publish: `git tag v1.x.x && git push origin v1.x.x`

### Style

- Do not edit files in `output/` — they are build artifacts
- Commit messages: use conventional commits style (`fix:`, `feat:`, `chore:`, `docs:`)
- Include Co-authored-by trailer for Copilot-assisted commits

## Branch Strategy

| Branch | Purpose |
|--------|---------|
| `main` | Production. Protected. Only accepts PRs from `dev`. |
| `dev` | Integration branch. PRs from feature branches merge here. |
| `feature/*` | Feature branches. Branch from `dev`, PR to `dev`. |

**Never push directly to `main`.** Always go through a PR.

## Adding a New Template

1. Create `overlays/<template-name>/` directory
2. Add template-specific files and overrides
3. Add the template to `compose.sh` TEMPLATES array
4. Add the template to the workflow matrix in `.github/workflows/compose-and-publish.yml`
5. Create the downstream repository at `TheSereyn/TheSereyn.Templates.<TemplateName>`
6. Add `TEMPLATE_PUSH_TOKEN` to repository secrets (see `docs/setup/workflow-secrets.md`)

## Release Process

1. Merge `dev` → `main` via PR
2. Tag `main` with a SemVer tag: `v<MAJOR>.<MINOR>.<PATCH>`
3. Push the tag: `git push origin v<MAJOR>.<MINOR>.<PATCH>`
4. The `compose-and-publish.yml` workflow runs automatically and publishes to downstream repos

**Versioning:** Use SemVer (Semantic Versioning):
- **MAJOR** — breaking changes (e.g., removing a feature, changing placeholder token names)
- **MINOR** — new features or additions (e.g., new skill, new template)
- **PATCH** — bug fixes and corrections

## Branch Protection

The `main` branch requires the following protection rules (configure in Settings → Branches):
- ✅ Require pull request reviews before merging (1 reviewer)
- ✅ Require status checks to pass (PR Validate workflow)
- ✅ Require branches to be up to date before merging
- ✅ Restrict who can push to `main` (only admins + automation)

The `dev` branch requires:
- ✅ Require pull request reviews before merging
- ✅ Require status checks to pass

## Automated Commits (GPG Signing)

Commits made by `github-actions[bot]` during the compose-and-publish workflow are not GPG-signed. This is a known limitation of GitHub Actions automated workflows. The workflow uses `contents: read` permissions at the workflow level and only grants `contents: write` implicitly via the PAT for pushing to downstream repos. The trade-off is accepted for operational simplicity; if your organisation requires signed commits, consider replacing the PAT with a GitHub App that supports commit signing.
