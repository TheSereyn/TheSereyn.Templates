---
mode: text
description: "Host-level prerequisites and setup steps. Complete these on your local machine before opening the dev container."
---

# Pre-Container Setup

Complete these steps on your local machine before opening the dev container. Once ready, follow the in-container `first-time-setup` prompt to configure your project.

## Steps

### 1. Container Runtime

Install **[Docker Desktop](https://www.docker.com/)** or **[Podman Desktop](https://podman.io/)** — both are fully supported. Make sure the runtime is running before proceeding.

### 2. VS Code + Dev Containers Extension

Install [VS Code](https://code.visualstudio.com/) and the **Dev Containers** extension (`ms-vscode-remote.remote-containers`).

If you prefer another container-aware editor (e.g., Cursor, JetBrains), verify it supports the Dev Containers spec.

### 3. Git Identity

Configure your git identity on the host (this carries into the container):

```bash
git config --global user.name "Your Name"
git config --global user.email "your@email.com"
```

### 4. GitHub Authentication

Authenticate the GitHub CLI on the host (the container inherits host credentials):

```bash
gh auth login
```

### 5. Create from Template

On GitHub, click **"Use this template" → "Create a new repository"**. Then clone your new repo locally:

```bash
git clone https://github.com/<your-org>/<your-repo>.git
cd <your-repo>
```

### 6. Open in Dev Container

Open the repo folder in VS Code. When prompted, click **"Reopen in Container"**.

If the prompt doesn't appear, run the command palette (`Ctrl+Shift+P` / `Cmd+Shift+P`) and select **"Dev Containers: Reopen in Container"**.

### 7. Wait for Post-Create

The container will build and run `post-create.sh` automatically. Watch the terminal for output.

It installs:
- GitHub CLI extensions (`gh-copilot`)
- Squad CLI (`@bradygaster/squad-cli`)
- *(Blazor template only)* Playwright browser binaries

This may take several minutes on first build.

### 8. Next Step

Once the container is ready, open **Copilot Chat** and run:

```
@workspace /first-time-setup
```
