---
name: "template-management"
description: "How to manage TheSereyn.Templates: overlay conventions, compose process, adding new templates, and publishing to downstream repos"
---

# Template Management

## Overlay Conventions

Templates are composed by merging `base/` with an overlay from `overlays/<template>/`.

### File Resolution Rules

1. **Replace** — If an overlay file has the same relative path as a base file, the overlay version replaces the base version entirely.
2. **Add** — If an overlay file has a path that doesn't exist in base, it is added to the output.
3. **Append** — Files named `*.append.md` have their content appended to the matching base file. The `.append` suffix is stripped from the output filename.
   - Example: `overlays/blazor/.github/copilot-instructions.append.md` appends to `base/.github/copilot-instructions.md` → output has a single `copilot-instructions.md` with both contents.

### What Belongs in Base vs Overlay

| Criteria | Location |
|----------|----------|
| Used by ALL templates | `base/` |
| Template-specific (e.g., Blazor skills, custom README) | `overlays/<template>/` |
| Additive instructions for a specific template | `overlays/<template>/` as `*.append.md` |

## Compose Process

`compose.sh` performs these steps for each template:

1. Clean the output directory (`output/TheSereyn.Templates.<Name>/`), preserving `.git/` if it exists
2. Copy all files from `base/` into the output directory
3. Copy overlay files on top (same path = overwrite)
4. Process `*.append.md` files: find the matching base file, append content with a blank-line separator, remove the `.append.md` file
5. Optionally stamp a version footer if `$TAG` is set

### Running Locally

```bash
./compose.sh
ls output/TheSereyn.Templates.MinimalApi/
ls output/TheSereyn.Templates.Blazor/
```

## Adding a New Template

1. Create `overlays/<name>/` with any template-specific files
2. Add the template name to the `TEMPLATES` array in `compose.sh`
3. Add the template to the workflow matrix in `.github/workflows/compose-and-publish.yml`
4. Create the target GitHub repo (`TheSereyn/TheSereyn.Templates.<Name>`) with the template flag enabled
5. Run `./compose.sh` locally and verify the output

## Publishing

Publishing is automated via GitHub Actions:

1. Merge `dev` → `main` via PR
2. Tag `main` with a version: `git tag v1.0.0 && git push origin v1.0.0`
3. The `compose-and-publish` workflow triggers, composes each template, and pushes to the downstream repos
4. Each downstream repo is tagged with the same version

### Secrets Required

- `TEMPLATE_PUSH_TOKEN` — A fine-grained PAT (or GitHub App token) with `contents: write` on the downstream template repos

## Template Repo Setup

Each downstream repo must:

- Exist on GitHub under `TheSereyn/`
- Have the "Template repository" checkbox enabled in Settings
- Be listed in the workflow matrix
