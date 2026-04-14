# {{PROJECT_NAME}}

{{DESCRIPTION}}

## Template: TheSereyn.Templates.CLI

Command-line application template for .NET projects with System.CommandLine and Spectre.Console.

> **Note:** Running `@workspace /project-setup` in Copilot Chat will collect your project details and rewrite this README as your project's own documentation.

## Getting Started

### Prerequisites

- [Docker Desktop](https://www.docker.com/) or [Podman Desktop](https://podman.io/)
- [VS Code](https://code.visualstudio.com/) with the [Dev Containers extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers)

### First-Time Setup

1. Complete the **[pre-container setup](.github/prompts/pre-container-setup.prompt.md)** — install prerequisites on your local machine
2. Click **"Use this template"** on GitHub to create your new repository
3. Clone your new repo and open it in VS Code
4. When prompted, click **"Reopen in Container"**
5. Once the container is built, run the **environment check** then **project setup**:
   - Open Copilot Chat
   - Type: `@workspace /environment-check` — verify the environment is healthy
   - Type: `@workspace /project-setup` — configure your project identity, security baseline, license, and compliance

### What's Included

| Component | Description |
|-----------|-------------|
| **Dev Container** | .NET 10, Node 22, GitHub CLI, Azure CLI |
| **MCP Servers** | Microsoft Learn, GitHub |
| **Spec Kit** | Spec-Driven Development — specifications, plans, and task decomposition |
| **Squad** | AI development team — implementation orchestrator after planning |
| **Skills** | TUnit testing, CLI development, project conventions, spec-driven development, security (modular skill tree), code analyzers |
| **Prompts** | Environment check, project setup, compliance setup, pre-container setup, requirements interview, hire security architect |
| **Code Quality** | StyleCop Analyzers, Roslyn Analyzers, .editorconfig, nullable reference types |

### Development Workflow

This project uses **Spec-Driven Development** with Spec Kit and Squad:

1. `/speckit.constitution` — Define project governance and principles
2. `/speckit.specify` — Capture what to build and why
3. `/speckit.plan` → `/speckit.tasks` — Technical plan and task breakdown
4. `@squad` — Implementation orchestration with specialist agents

For early-stage discovery, run `/requirements-interview` before specifying (optional).

## Architecture

This template is designed for **command-line applications** built on System.CommandLine and Spectre.Console:

```
src/
├── Commands/         # Command definitions and handlers
├── Infrastructure/   # External service clients, file I/O, configuration
└── Program.cs        # Entry point — RootCommand, parsing, invocation
tests/
└── Commands/         # TUnit tests for command handlers
```

## Development

```bash
# Build
dotnet build

# Test (TUnit on Microsoft Testing Platform)
dotnet test

# Run the CLI
dotnet run -- --help

# Run with arguments
dotnet run -- <command> [options]
```

## Key Conventions

- **Parsing:** System.CommandLine for argument parsing, command routing, and help generation
- **Output:** Spectre.Console for rich terminal output (tables, progress, prompts, markup)
- **Error Handling:** Structured exit codes (0 = success, 1 = usage error, 2 = runtime error)
- **Testing:** TUnit on Microsoft Testing Platform (NOT xUnit/NUnit)
- **Observability:** OpenTelemetry (traces, metrics, logs)

See the `cli-development` and `project-conventions` skills for detailed guidance.

## Dependencies

- [System.CommandLine](https://learn.microsoft.com/dotnet/standard/commandline/) — command-line parsing and invocation (Microsoft-maintained, MIT)
- [Spectre.Console](https://spectreconsole.net/) — rich terminal output (.NET Foundation, MIT)
- [Roslyn Analyzers](https://learn.microsoft.com/dotnet/fundamentals/code-analysis/overview) — code quality and style analysis via `Directory.Build.props`
- [StyleCop Analyzers](https://github.com/DotNetAnalyzers/StyleCopAnalyzers) — formatting and structure rules via `Directory.Build.props`
- [TUnit](https://tunit.dev/) — testing framework on Microsoft Testing Platform
- [Squad](https://github.com/bradygaster/squad) — AI development team, installed via DevContainer

## License

License is configured during first-time setup.
