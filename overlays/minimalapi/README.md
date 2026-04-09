# {{PROJECT_NAME}}

{{DESCRIPTION}}

## Template: TheSereyn.Templates.MinimalApi

Back-end only template for .NET projects with Minimal APIs, Worker Services, and shared contracts.

## Getting Started

### Prerequisites

- [Docker](https://www.docker.com/) or [Podman](https://podman.io/)
- [VS Code](https://code.visualstudio.com/) with the [Dev Containers extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers)

### First-Time Setup

1. Complete the **[pre-container setup](.github/prompts/pre-container-setup.prompt.md)** — install prerequisites on your local machine
2. Click **"Use this template"** on GitHub to create your new repository
3. Clone your new repo and open it in VS Code
4. When prompted, click **"Reopen in Container"**
5. Once the container is built, run the **first-time-setup** prompt:
   - Open Copilot Chat
   - Type: `@workspace /first-time-setup`
   - Follow the prompts to configure your project identity

### What's Included

| Component | Description |
|-----------|-------------|
| **Dev Container** | .NET 10, Node 22, GitHub CLI, Azure CLI, Docker-in-Docker |
| **MCP Servers** | Microsoft Learn, GitHub |
| **Spec Kit** | Spec-Driven Development — specifications, plans, and task decomposition |
| **Squad** | AI development team — implementation orchestrator after planning |
| **Skills** | TUnit testing, project conventions, spec-driven development, security (modular skill tree), RFC compliance, code analyzers |
| **Prompts** | First-time setup, pre-container setup, verify setup, requirements interview, hire security architect |
| **Code Quality** | StyleCop Analyzers, Roslyn Analyzers, .editorconfig, nullable reference types |

### Development Workflow

This project uses **Spec-Driven Development** with Spec Kit and Squad:

1. `/speckit.constitution` — Define project governance and principles
2. `/speckit.specify` — Capture what to build and why
3. `/speckit.plan` → `/speckit.tasks` — Technical plan and task breakdown
4. `@squad` — Implementation orchestration with specialist agents

For early-stage discovery, run `/requirements-interview` before specifying.

## Architecture

This template is designed for **back-end only** projects following **Clean Architecture**:

```
src/
├── Domain/           # Entities, value objects, domain events, interfaces
├── Application/      # Use cases, commands, queries, handlers, DTOs
├── Infrastructure/   # Database repos, external service clients, messaging
├── Api/              # ASP.NET Core Minimal API endpoints, DI composition root
├── Worker/           # Background processing with BackgroundService
└── Shared/           # Contracts, DTOs shared between projects
```

## Development

```bash
# Build
dotnet build

# Test (TUnit on Microsoft Testing Platform)
dotnet test

# Run the API
dotnet run --project src/YourProject.Api/
```

## Key Conventions

- **API Style:** Minimal APIs with REPR pattern (one endpoint per file)
- **Error Handling:** RFC 9457 Problem Details for all errors
- **Testing:** TUnit on Microsoft Testing Platform (NOT xUnit/NUnit)
- **Pagination:** Cursor-based for all list endpoints
- **Observability:** OpenTelemetry (traces, metrics, logs)

See the `project-conventions` and `tunit-testing` skills for detailed guidance.

## Dependencies

- [Roslyn Analyzers](https://learn.microsoft.com/dotnet/fundamentals/code-analysis/overview) — code quality and style analysis via `Directory.Build.props`
- [StyleCop Analyzers](https://github.com/DotNetAnalyzers/StyleCopAnalyzers) — formatting and structure rules via `Directory.Build.props`
- [TUnit](https://tunit.dev/) — testing framework on Microsoft Testing Platform
- [Squad](https://github.com/bradygaster/squad) — AI development team, installed via DevContainer

## License

License is configured during first-time setup.
