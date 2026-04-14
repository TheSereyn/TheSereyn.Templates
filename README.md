# TheSereyn.Templates

Composition workspace for .NET project templates. Composes shared base files + per-template overlays into Copilot-ready GitHub template repositories.

## Downstream Templates

| Template | Description | Repo |
|----------|-------------|------|
| **TheSereyn.Templates.MinimalApi** | Back-end only: Minimal API + Worker + shared contracts | [TheSereyn/TheSereyn.Templates.MinimalApi](https://github.com/TheSereyn/TheSereyn.Templates.MinimalApi) |
| **TheSereyn.Templates.Blazor** | Full-stack: extends MinimalApi with Blazor skills and multi-frontend patterns | [TheSereyn/TheSereyn.Templates.Blazor](https://github.com/TheSereyn/TheSereyn.Templates.Blazor) |
| **TheSereyn.Templates.CLI** | Command-line tools: System.CommandLine + Spectre.Console | [TheSereyn/TheSereyn.Templates.CLI](https://github.com/TheSereyn/TheSereyn.Templates.CLI) |

## What's Included in Each Template

- **DevContainer** — .NET 10, Node 22, GitHub CLI, Azure CLI
- **MCP Servers** — Microsoft Learn, GitHub
- **Spec Kit** — Spec-Driven Development (specifications, plans, task decomposition)
- **Squad** — AI development team, auto-installed via DevContainer
- **Skills** — TUnit testing, project conventions, spec-driven development, security (modular skill tree), code analyzers
- **Prompts** — Environment check, project setup, compliance setup, pre-container setup
- **Code Quality** — StyleCop Analyzers, Roslyn Analyzers, .editorconfig, nullable reference types

## Workspace Structure

```
TheSereyn.Templates/
├── base/           # Shared files for ALL templates
├── overlays/       # Per-template additions and overrides
│   ├── minimalapi/
│   ├── blazor/
│   └── cli/
├── compose.sh      # Merges base + overlay → output/<template>/
└── output/         # .gitignored — composed template repos (build artifacts)
```

### Overlay Semantics

- **Same path as base** — file **replaces** the base version
- **New path** — file is **added**
- **`*.append.md`** — content is **appended** to the matching base file

## Branching and Publishing

```
dev → PR → main → tag (v*) → compose-and-publish workflow
```

1. Work on `dev` branch
2. Open PR to `main`, review, merge
3. Tag `main` with a version (e.g. `v1.0.0`)
4. Tag push triggers GitHub Actions workflow that composes templates and pushes to downstream repos

## Local Development

```bash
# Compose all templates locally
./compose.sh

# Inspect output
ls output/TheSereyn.Templates.MinimalApi/
ls output/TheSereyn.Templates.Blazor/
ls output/TheSereyn.Templates.CLI/
```

## License

[MIT](LICENSE)
