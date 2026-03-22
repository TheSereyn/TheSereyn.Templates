# {{PROJECT_NAME}}

{{DESCRIPTION}}

## Getting Started

### Prerequisites

This project uses a **Dev Container** for a consistent development environment. You need:

- [Docker](https://www.docker.com/) or [Podman](https://podman.io/)
- [VS Code](https://code.visualstudio.com/) with the [Dev Containers extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers)

### First-Time Setup

1. Open this repository in VS Code
2. When prompted, click **"Reopen in Container"** (or run `Dev Containers: Reopen in Container` from the command palette)
3. Once the container is built, run the **first-time-setup** prompt:
   - Open Copilot Chat
   - Type: `@workspace /first-time-setup`
   - Follow the prompts to configure your project identity

### What's Included

| Component | Description |
|-----------|-------------|
| **Dev Container** | .NET 10, Node 22, GitHub CLI, Azure CLI, Docker-outside-of-Docker |
| **MCP Servers** | Microsoft Learn, Azure, GitHub |
| **Skills** | TUnit testing, project conventions, requirements gathering, Playwright CLI, security review, RFC compliance, code analyzers |
| **Prompts** | First-time setup, requirements interview |
| **Squad** | AI development team (auto-installed via DevContainer) |
| **Code Quality** | StyleCop Analyzers, Roslyn Analyzers, .editorconfig, nullable reference types |

### Development Workflow

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
