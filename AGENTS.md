# Working in this repository

This repository composes .NET templates.

- `base/` contains shared template source.
- `overlays/` contains template-specific additions and overrides.
- `output/` contains generated templates.

Edit the source in `base/` or `overlays/`. Run `bash validate.sh` from the
repository root after making changes. See [CONTRIBUTING.md](CONTRIBUTING.md)
for prerequisites and development conventions.
