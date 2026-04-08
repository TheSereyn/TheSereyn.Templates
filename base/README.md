# {{PROJECT_NAME}}

{{DESCRIPTION}}

> **Note:** This is an AI-first template designed to work with GitHub Copilot. The project scaffold and architecture are generated through Copilot Chat prompts during first-time setup. A fallback manual setup section is provided below for environments where Copilot is unavailable.

## Getting Started

### Prerequisites

This project uses a **Dev Container** for a consistent development environment. You need:

- [Docker](https://www.docker.com/) or [Podman](https://podman.io/)
- [VS Code](https://code.visualstudio.com/) with the [Dev Containers extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers)

### First-Time Setup

1. Complete the **[pre-container setup](.github/prompts/pre-container-setup.prompt.md)** — install prerequisites on your local machine
2. Click **"Use this template"** on GitHub, clone your new repository, and open it in VS Code
3. When prompted, click **"Reopen in Container"** (or run `Dev Containers: Reopen in Container` from the command palette)
4. Once the container is ready, run the **first-time-setup** prompt:
   - Open Copilot Chat
   - Type: `@workspace /first-time-setup`
   - Follow the prompts to configure your project identity

### Manual Setup (Without Copilot)

If GitHub Copilot is unavailable, the Dev Container still provides a complete .NET development environment. To set up the project manually:

1. Replace all placeholder tokens in project files:
   - `{{PROJECT_NAME}}` → your project name
   - `{{NAMESPACE}}` → your root namespace (e.g., `Acme.MyProject`)
   - `{{DESCRIPTION}}` → a one-line project description
   - In `LICENSE`: `{{YEAR}}` → current year, `{{AUTHOR}}` → author or organisation name
2. Create your solution and project files following Clean Architecture:
   ```bash
   dotnet new sln -n {{PROJECT_NAME}}
   dotnet new classlib -n {{PROJECT_NAME}}.Domain
   dotnet new classlib -n {{PROJECT_NAME}}.Application
   dotnet new classlib -n {{PROJECT_NAME}}.Infrastructure
   dotnet new webapi -n {{PROJECT_NAME}}.Api --use-minimal-apis
   ```
3. Configure StyleCop by reviewing `stylecop.json` and `.editorconfig`
4. Review `.copilot/skills/` for documented conventions and patterns

### What's Included

| Component | Description |
|-----------|-------------|
| **Dev Container** | .NET 10, Node 22, GitHub CLI, Docker-outside-of-Docker |
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

```bash
# Build the solution
dotnet build

# Run tests
dotnet test

# Run the application
dotnet run --project src/YourProject.Api/
```

## Architecture

This project follows **Clean Architecture** principles:

```
src/
├── Domain/           # Entities, value objects, domain events, interfaces
├── Application/      # Use cases, commands, queries, handlers, DTOs
├── Infrastructure/   # Database, external services, messaging
└── Api/              # Minimal API endpoints, DI composition root
```

## License

License is configured during first-time setup.
