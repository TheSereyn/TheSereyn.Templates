# Plan: TheSereyn Template Repositories

## TL;DR
A **composition workspace** (`TheSereyn.Templates`) that is itself a GitHub repo, containing shared base files and per-template overlays. A tag-triggered GitHub Actions workflow composes and pushes to two downstream GitHub template repositories — **TheSereyn.Templates.Blazor** (full-stack .NET + Blazor) and **TheSereyn.Templates.MinimalApi** (back-end only). Each composed template provides a Copilot-ready starting point: DevContainer, lean instructions with placeholders, generic skills, a Business Analyst agent, Squad (auto-installed), pre-configured MCP servers (Learn, Azure, GitHub), and a one-shot setup prompt. No solution scaffolding — Squad handles project design.

---

## Architecture

### Repo Strategy
- **`TheSereyn.Templates`** is a GitHub repo (the composition workspace / source of truth)
- It contains `base/` (shared files) and `overlays/<template>/` (template-specific additions/overrides)
- A `compose.sh` script merges base + overlay into `output/<template>/`
- `output/` is `.gitignored` — never committed to the parent repo
- Each output folder is an independent git repo pushed to its own GitHub template repository
- A tag-triggered GitHub Actions workflow automates compose + push to template repos

### Branching Strategy
- `main` — stable, tagged releases trigger template publishing
- `dev` — working branch, PRs merged into `main`
- Never push directly to `main`

### Workspace Structure
```
TheSereyn.Templates/                    ← GitHub repo (source of truth)
├── .github/
│   ├── copilot-instructions.md         # Instructions for THIS workspace (template management)
│   ├── copilot/
│   │   └── skills/
│   │       └── template-management/SKILL.md   # How overlays, compose, and publishing work
│   └── workflows/
│       └── compose-and-publish.yml     # Tag-triggered: compose + push to template repos
├── base/                               # Shared files for ALL templates
│   ├── .devcontainer/
│   │   └── devcontainer.json
│   ├── .github/
│   │   ├── copilot-instructions.md
│   │   ├── agents/
│   │   │   └── Business Analyst.agent.md
│   │   ├── copilot/
│   │   │   └── skills/
│   │   │       ├── tunit-testing/SKILL.md
│   │   │       ├── project-conventions/SKILL.md
│   │   │       ├── requirements-gathering/SKILL.md
│   │   │       └── playwright-cli/SKILL.md
│   │   └── prompts/
│   │       └── first-time-setup.prompt.md
│   ├── .copilot/
│   │   └── mcp-config.json
│   ├── .vscode/
│   │   └── settings.json
│   ├── .editorconfig
│   ├── .gitignore
│   ├── .gitattributes
│   └── stylecop.json
├── overlays/
│   ├── minimalapi/
│   │   └── README.md                  # Replaces base README
│   └── blazor/
│       ├── .github/
│       │   ├── copilot-instructions.append.md   # Appended to base instructions
│       │   └── copilot/
│       │       └── skills/
│       │           └── blazor-architecture/SKILL.md
│       └── README.md                  # Replaces base README
├── compose.sh                          # Merges base + overlay → output/<name>
├── plan.md                             # This file
├── copilot-instructions.md             # (existing generic reference — can be removed after migration)
└── output/                             # .gitignored — composed template repos
    ├── TheSereyn.Templates.MinimalApi/
    └── TheSereyn.Templates.Blazor/
```

### Overlay Semantics
- **Same path as base** → file **replaces** the base version (e.g., `README.md`)
- **New path not in base** → file is **added** (e.g., `blazor-architecture/SKILL.md`)
- **`*.append.md` convention** → content is **appended** to the matching base file (e.g., `copilot-instructions.append.md` appends to `copilot-instructions.md`)

### Template Relationship
- **TheSereyn.Templates.MinimalApi** = `base/` + `overlays/minimalapi/` (back-end only: API + Worker + shared contracts guidance)
- **TheSereyn.Templates.Blazor** = `base/` + `overlays/blazor/` (full-stack: adds Blazor skills, hosting/multi-frontend patterns)

Both share: DevContainer, MCP config, Squad (auto-installed), BA agent, all generic skills, editorconfig, stylecop, gitignore, gitattributes, setup prompt

---

## Steps

### Phase 0: Workspace Setup — TheSereyn.Templates

**0a. Initialize the workspace repo** *(no dependencies)* — **PARTIALLY DONE**
- ✅ `git init`, initial commit on `main`, pushed to `origin`
- ✅ GitHub repo created: `TheSereyn/TheSereyn.Templates` (remote configured)
- ✅ `.gitignore` exists (currently only ignores `/_reference/`)
- 🔲 Expand `.gitignore` — add: `output/`, `.DS_Store`, `Thumbs.db`, `*~`, `*.swp`, `node_modules/`
- 🔲 `README.md` — workspace purpose, what it composes, how to use `compose.sh`, branching model (`dev` → PR → `main` → tag → publish), link to downstream template repos
- 🔲 `.gitattributes` — `* text=auto eol=lf`, mark `compose.sh` as executable (`*.sh text eol=lf`), markdown/json/yaml as text
- 🔲 `.editorconfig` — workspace-level formatting for markdown, yaml, json, shell scripts (NOT the .NET template `.editorconfig` which lives in `base/`)
- 🔲 `LICENSE` — MIT license, copyright `TheSereyn`
- 🔲 Create `dev` branch from `main` and push
- 🔲 Set GitHub repo description: *"Composition workspace for .NET project templates. Composes shared base + per-template overlays into Copilot-ready GitHub template repos (Blazor full-stack, MinimalApi back-end). Includes DevContainer, MCP servers, skills, BA agent, and Squad integration."*

**0b. Workspace copilot-instructions.md** *(no dependencies)*
- Create `.github/copilot-instructions.md` for this workspace (NOT the template instructions — those go in `base/`)
- Lean, focused on template management tasks:
  - Project identity: TheSereyn.Templates — composition workspace for .NET project templates
  - How this workspace is structured (base + overlays + compose)
  - Never edit `output/` directly — always edit `base/` or `overlays/`
  - Branching: work on `dev`, PR to `main`, tag to publish
  - Pointer to `template-management` skill for overlay conventions and compose details

**0c. Template management skill** *(no dependencies)*
- Create `.github/copilot/skills/template-management/SKILL.md`
- Covers:
  - Overlay conventions: replace, add, `*.append.md` for concatenation
  - How to add a new template: create `overlays/<name>/`, add to compose script and workflow matrix
  - How compose.sh works: copy base → apply overlay → handle appends
  - Testing changes locally: run `./compose.sh` and inspect `output/`
  - Publishing: tag on main triggers workflow → compose → push to template repos
  - Template repo setup: GitHub template flag, secrets for push access
  - What belongs in base vs overlay (decision criteria)

**0d. Compose script** *(no dependencies)*
- Create `compose.sh`
- For each template defined in a list (minimalapi, blazor):
  1. Clean `output/TheSereyn.Templates.<Name>/` (preserve `.git/` if exists)
  2. Copy all files from `base/` into the output folder
  3. Copy overlay files on top (file-level overwrite for same paths)
  4. Process `*.append.md` files: find matching base file, append content, remove the `*.append.md` file
  5. Add a generated `README.md` footer noting the template was composed from `TheSereyn.Templates` at version `$TAG`
- Script is idempotent and safe to re-run

**0e. GitHub Actions workflow** *(depends on 0d)*
- Create `.github/workflows/compose-and-publish.yml`
- **Trigger**: tag push matching `v*` (e.g., `v1.0.0`, `v1.1.0`)
- **Steps per template** (matrix strategy):
  1. Checkout `TheSereyn.Templates` at the tag
  2. Run `compose.sh` for the template
  3. Clone the target template repo (`TheSereyn.Templates.<Name>`)
  4. Sync composed output into the clone (rsync or cp, excluding `.git/`)
  5. Commit with message `"Composed from TheSereyn.Templates@<tag>"`
  6. Push if there are changes
  7. Tag the template repo with the same version tag
- **Secrets required**: `TEMPLATE_PUSH_TOKEN` — PAT or GitHub App token with `contents: write` on template repos

---

### Phase 1: Base Template Content (in `base/`)

**1. DevContainer setup** *(no dependencies)*
- Create `base/.devcontainer/devcontainer.json` based on TheSereyn's proven config
- Base image: `mcr.microsoft.com/devcontainers/dotnet:10.0-noble`
- Features: Node 22, GitHub CLI, Azure CLI, Docker-outside-of-docker (Podman socket mount)
- VS Code extensions: C#, C# Dev Kit, Azure MCP Server, Copilot, Copilot Chat
- `postCreateCommand`: Install Copilot CLI (`@github/copilot`), Playwright CLI, Squad (latest from bradygaster/squad via npm), verify all tools (`dotnet --info`, `node --version`, `gh --version`, `az --version`, `copilot --version`)
- **Note**: Verify the correct Squad npm package name from https://github.com/bradygaster/squad before implementation

**2. MCP configuration** *(no dependencies)*
- Create `base/.copilot/mcp-config.json` with three servers:
  - **Microsoft Learn**: `{ "type": "http", "url": "https://learn.microsoft.com/api/mcp" }`
  - **Azure**: VS Code extension-based (`ms-azuretools.vscode-azure-mcp-server`) — already in DevContainer extensions
  - **GitHub**: `npx -y @anthropic/github-mcp-server` with `GITHUB_TOKEN` env var
- **Research needed**: Verify Copilot CLI MCP config format vs VS Code MCP config format

**3. Lean copilot-instructions.md** *(no dependencies)*
- Create `base/.github/copilot-instructions.md` — lean version derived from the evolution across projects
- Contains high-level guidance only (not domain-specific patterns — those go in skills)
- **Sections to include:**
  - Project Identity: `{{PROJECT_NAME}}`, `{{NAMESPACE}}`, `{{DESCRIPTION}}` placeholders
  - Stack: .NET 10, C#, ASP.NET Core, Clean Architecture (modular monolith or microservices)
  - Authoritative Standards: RFC 9205, 9110, 3986, 9457; IETF HTTPAPI WG; Microsoft Learn as source of truth
  - MCP Tools Policy: "CRITICAL" section — verify via Microsoft Learn MCP before using unfamiliar APIs; treat MCP as source of truth for .NET/C# features (from NGS/SellMyCyberTruck pattern)
  - .NET/C# Feature Validation: Must search docs first for unfamiliar syntax
  - Dependency Policy: MIT preferred, keep lean, no MediatR
  - Security Principles: OAuth/OIDC, OWASP, security-by-design (high-level — details in skills)
  - Code Quality: StyleCop, nullable, file-scoped namespaces, latest analysis level
  - PowerShell Terminal Reliability: Avoid `>>` continuation, use here-strings (from NGS pattern)
  - Testing: TUnit on Microsoft Testing Platform (pointer to skill for details)
  - Delivery Format: Summary, decisions, code, security, tests, docs, open questions, deviation notice
  - Ask-First Triggers: Scope, architecture boundaries, auth, persistence, deployment, NFRs
  - Deviation/Escalation Policy: Attempt compliant → present both → flag → confirm
  - Micro-Checklists: REST, Security, Performance, Observability, Tests, Deviation
- **Explicitly excluded from instructions** (delegated to skills): TUnit details, project conventions specifics, Cosmos/persistence patterns, messaging patterns, API patterns — these are project-specific

**4. Business Analyst agent** *(no dependencies)*
- Create `base/.github/agents/Business Analyst.agent.md` — adapted from Mimyre's version
- Generalized: remove any project-specific references
- Keeps the 10-phase interview methodology (Vision → Users → Functional → Domain → Integrations → NFRs → UI → Deployment → Constraints → Prioritization)
- Tools: `['read', 'edit', 'search', 'todo']`
- Reads copilot-instructions.md at session start for project context

**5. Squad — installed via DevContainer, not shipped** *(handled by step 1)*
- Do NOT ship a `squad.agent.md` in the template
- Squad is installed by `postCreateCommand` in the DevContainer (npm install), which places the agent file automatically
- The first-time setup prompt (step 8) includes a staleness check: compares installed Squad version against latest available and warns if outdated
- This ensures every new project always gets the latest Squad version at container creation time

**6. Generic skills** *(no dependencies, parallel with steps 1-4)*
- Create `base/.github/copilot/skills/` with four skills:

  a. **tunit-testing/SKILL.md** — Adapted from NGS's version
     - TUnit framework (Apache 2.0), NOT xUnit/NUnit/MSTest
     - Microsoft Testing Platform (MTP) native mode, NOT VSTest
     - `[Test]` attribute, async assertions `await Assert.That(...)`
     - CLI flags: `dotnet test`, `--report-trx`, `--coverage`
     - Setup/teardown: `[Before(Test)]`, `[After(Test)]`
     - Parameterized: `[Arguments(...)]`
     - WebApplicationFactory pattern (remove IHostedService)
     - CI flags table (MTP vs VSTest)

  b. **project-conventions/SKILL.md** — Merged from NGS + SellMyCyberTruck conventions
     - RFC 9457 Problem Details for all errors
     - REPR pattern (one endpoint/file, co-located DTOs)
     - Cursor-based pagination
     - Minimal APIs style
     - StyleCop + latest analysis level
     - Nullable ref types, implicit usings, file-scoped namespaces
     - Naming conventions: PascalCase types, camelCase locals, `I` prefix, `Async` suffix
     - Async all-the-way (no `.Result`/`.Wait()`)
     - Strongly-typed options via `IOptions<T>`
     - OpenTelemetry + structured logging + correlation IDs
     - Clean Architecture layer rules
     - Guard clauses, null checks (`ArgumentNullException.ThrowIfNull`)

  c. **requirements-gathering/SKILL.md** — Adapted from TheSereyn's version
     - Open questions as first-class artifacts (OQ-N format)
     - MoSCoW prioritization
     - Traceability matrix with decision links
     - Pattern for structured requirements elicitation

  d. **playwright-cli/SKILL.md** — Adapted from TheSereyn's version
     - Browser automation for web testing
     - Core commands: open, goto, click, fill, type, screenshot, snapshot
     - Integration with DevContainer's Playwright installation

**7. Root config files** *(no dependencies, parallel with above)*
- `base/.editorconfig` — Merged best version from SellMyCyberTruck (most comprehensive: UTF-8, LF, file-scoped namespaces, StyleCop rules, C# conventions)
- `base/stylecop.json` — Standard config (disable XML doc requirements for non-library, allow underscore prefixed fields)
- `base/.gitignore` — .NET + Squad runtime state + Playwright artifacts + build output
- `base/.gitattributes` — Union merge for Squad append-only files (decisions.md, history.md, logs)
- `base/.vscode/settings.json` — Auto-approve safe terminal commands (`dotnet build`, `dotnet sln`)
- `base/README.md` — Base README (template-specific overlays will replace this)

**8. First-time setup prompt** *(depends on steps 3, 1, 2)*
- Create `base/.github/prompts/first-time-setup.prompt.md`
- This is a one-shot runnable prompt that:
  1. **Verifies environment**: Checks DevContainer is running, all tools installed (dotnet, node, gh, az, copilot CLI, playwright, squad), MCP servers reachable
  2. **Collects project info**: Asks for project name, namespace root, brief description, GitHub repo URL
  3. **Resolves placeholders**: Updates `copilot-instructions.md` replacing `{{PROJECT_NAME}}`, `{{NAMESPACE}}`, `{{DESCRIPTION}}`
  4. **Initializes git**: If not already initialized, sets up git with the GitHub remote
  5. **Verifies Squad availability**: Confirms `squad.agent.md` is present and up-to-date (staleness check)
  6. **Provides next steps**: Tells the user to start a session with the Squad agent to begin project design (requirements gathering, team hiring, architecture)
  7. **Self-cleanup**: Instructs to delete the setup prompt file after completion (or renames it to `.completed`)
- The prompt does NOT: scaffold solution files, create projects, run `dotnet new`, or make architecture decisions

---

### Phase 2: Overlays

**9. MinimalApi overlay** *(depends on Phase 1)*
- Create `overlays/minimalapi/README.md` — template-specific README replacing the base
  - Describes this as the back-end only template (API + Worker + shared contracts)
  - Usage instructions, first-time setup, links to Squad/MCP/TUnit docs

**10. Blazor overlay** *(depends on Phase 1)*
- Create `overlays/blazor/README.md` — template-specific README replacing the base
  - Describes this as the full-stack template (API + Worker + Blazor UI)
  - Notes the additional Blazor skill and instructions addendum
  - Usage instructions, first-time setup, links to Squad/MCP/TUnit/Blazor docs

- Create `overlays/blazor/.github/copilot-instructions.append.md` — appended to base instructions
  - Blazor-specific section covering:
    - Solution structure includes Blazor UI project(s) + RCL(s)
    - Blazor hosting model must be decided per feature (ask-first trigger)
    - UI depends only on Application layer (via API for WASM, direct for Server)
    - Pointer to `blazor-architecture` skill for detailed patterns

- Create `overlays/blazor/.github/copilot/skills/blazor-architecture/SKILL.md`
  - Hosting model guidance: Server vs WASM vs Hybrid — when to choose which
  - Multi-frontend patterns (single API serving multiple Blazor apps — from NGS pattern)
  - RCL strategy for reusable UI components
  - Blazor performance: virtualization, render throttling, streaming rendering
  - JS interop minimization patterns
  - WASM AOT considerations
  - Component lifecycle and state management
  - DI lifetime guidance for Blazor (Scoped = per-circuit for Server, per-app for WASM)
  - Share DTOs only between API and WASM client — never domain types

---

### Phase 3: GitHub Setup & First Publish

**11. Create GitHub repos** *(depends on Phases 0, 1, 2)*
- Create `TheSereyn/TheSereyn.Templates` on GitHub (management repo — NOT a template)
- Create `TheSereyn/TheSereyn.Templates.MinimalApi` on GitHub (template repo flag ON)
- Create `TheSereyn/TheSereyn.Templates.Blazor` on GitHub (template repo flag ON)
- Add `TEMPLATE_PUSH_TOKEN` secret to `TheSereyn.Templates` repo

**12. Initial compose and push** *(depends on step 11)*
- Run `./compose.sh` locally to verify output
- Push `TheSereyn.Templates` to GitHub
- Tag `v1.0.0` to trigger the workflow
- Verify both template repos receive composed content
- Verify "Use this template" button appears on both template repos

---

## Relevant Files

### Workspace Files (TheSereyn.Templates repo)
- `.github/copilot-instructions.md` — Workspace instructions for template management
- `.github/copilot/skills/template-management/SKILL.md` — Overlay conventions, compose process, publishing
- `.github/workflows/compose-and-publish.yml` — Tag-triggered compose + push workflow
- `compose.sh` — Composition script (base + overlay → output)
- `.gitignore` — Ignores `output/`

### Base Template Files (in `base/`)
- `base/.devcontainer/devcontainer.json` — DevContainer config (reference: TheSereyn's devcontainer.json)
- `base/.github/copilot-instructions.md` — Lean template instructions (reference: NGS + SellMyCyberTruck, stripped to essentials)
- `base/.github/agents/Business Analyst.agent.md` — BA agent (reference: Mimyre's version, generalized)
- `base/.github/copilot/skills/tunit-testing/SKILL.md` — TUnit skill (reference: NGS `.squad/skills/tunit-testing/SKILL.md`)
- `base/.github/copilot/skills/project-conventions/SKILL.md` — Conventions skill (reference: NGS + SellMyCyberTruck)
- `base/.github/copilot/skills/requirements-gathering/SKILL.md` — Requirements skill (reference: TheSereyn)
- `base/.github/copilot/skills/playwright-cli/SKILL.md` — Playwright skill (reference: TheSereyn)
- `base/.github/prompts/first-time-setup.prompt.md` — One-shot setup prompt
- `base/.copilot/mcp-config.json` — MCP servers config
- `base/.vscode/settings.json` — VS Code settings
- `base/.editorconfig` — Code style (reference: SellMyCyberTruck)
- `base/stylecop.json` — StyleCop config (reference: TheSereyn/SellMyCyberTruck)
- `base/.gitignore` — Template gitignore rules
- `base/.gitattributes` — Merge strategies for Squad files
- `base/README.md` — Base README (overridden by overlays)

### Overlay Files
- `overlays/minimalapi/README.md` — MinimalApi-specific README
- `overlays/blazor/README.md` — Blazor-specific README
- `overlays/blazor/.github/copilot-instructions.append.md` — Blazor addendum to instructions
- `overlays/blazor/.github/copilot/skills/blazor-architecture/SKILL.md` — Blazor architecture skill

### Reference Files (existing projects)
- `/home/lee/Projects/TheSereyn/.devcontainer/devcontainer.json` — DevContainer baseline
- `/home/lee/Projects/TheSereyn/.github/agents/squad.agent.md` — Squad v0.8.25 (reference only; not shipped)
- `/home/lee/Projects/Mimyre/.github/agents/Business Analyst.agent.md` — BA agent source
- `/home/lee/Projects/NGS/.github/copilot-instructions.md` — MCP validation, PowerShell reliability sections
- `/home/lee/Projects/NGS/.squad/skills/tunit-testing/SKILL.md` — TUnit skill source
- `/home/lee/Projects/NGS/.squad/skills/project-conventions/SKILL.md` — Conventions skill source
- `/home/lee/Projects/SellMyCyberTruck/.editorconfig` — Best editorconfig version
- `/home/lee/Projects/SellMyCyberTruck/.github/copilot-instructions.md` — Latest instruction patterns

---

## Verification

1. **Structure check** — workspace has `base/`, `overlays/`, `compose.sh`, workflow, workspace instructions, and management skill
2. **Compose test** — run `./compose.sh`, verify `output/TheSereyn.Templates.MinimalApi/` and `output/TheSereyn.Templates.Blazor/` are correctly composed
3. **Overlay verify** — MinimalApi output has base files + minimalapi README; Blazor output has base files + blazor README + blazor skill + appended instructions
4. **DevContainer build** — open an output template in VS Code, rebuild DevContainer, verify all tools install (dotnet, node, gh, az, copilot, playwright, squad)
5. **MCP connectivity** — Learn MCP responds, GitHub MCP connects with token, Azure MCP extension loads
6. **Squad availability** — verify Squad installed and `.github/agents/squad.agent.md` detected
7. **Skills loading** — open Copilot chat in a composed template, verify all skills appear (4 for MinimalApi, 5 for Blazor)
8. **BA agent test** — start conversation with BA, verify it reads instructions
9. **Setup prompt test** — run first-time-setup, verify it resolves placeholders and checks Squad staleness
10. **Workflow test** — push tag to TheSereyn.Templates, verify workflow runs and pushes to both template repos
11. **GitHub template test** — create test repo via "Use this template" from each template repo, verify all files copy
12. **Copilot CLI MCP test** — inside DevContainer, verify CLI can reach MCP servers

---

## Decisions

- **Composition workspace approach**: `TheSereyn.Templates` is a GitHub repo that composes and publishes to downstream template repos. Single source of truth for shared content.
- **Tag-triggered publishing**: Only tagged releases on `main` trigger the compose-and-publish workflow. Avoids accidental template updates on every push.
- **Branching**: `dev` for work, PR to `main`, tag on `main` to publish. Never push directly to `main`.
- **Squad NOT shipped in template**: Installed via npm in DevContainer `postCreateCommand`. First-time setup prompt checks for version staleness.
- **No solution scaffolding**: Templates contain zero .NET project files. Squad + BA handle project design and creation.
- **No Directory.Build.props/global.json in template**: These are project-specific and created during solution setup by Squad.
- **Skills in `base/.github/copilot/skills/`** (not `.squad/skills/`): Skills should be available to all Copilot agents, not just Squad. The `.github/copilot/skills/` path is the VS Code standard.
- **Cosmos/Wolverine/messaging skills excluded**: These are project-specific choices made during Squad setup. The conventions skill covers the universal patterns.
- **Overlay semantics**: Same path = replace, new path = add, `*.append.md` = concatenate to matching base file.
- **Workspace has its own instructions + skills**: Lean instructions for template management context, plus a `template-management` skill covering overlay conventions, compose process, and publishing.
- **`output/` is gitignored**: Composed templates are build artifacts, not tracked in the workspace repo.

## Further Considerations

1. **Squad installation method**: Need to verify the correct npm package name and install command from https://github.com/bradygaster/squad. The `postCreateCommand` depends on this. If it's not an npm package, may need `gh extension install` or a different approach.
2. **Copilot CLI MCP config**: VS Code uses `.copilot/mcp-config.json`, but Copilot CLI in the terminal may need its own config format. Verify during implementation.
3. **MCP for Copilot CLI**: The `.copilot/mcp-config.json` serves VS Code but Copilot CLI may need separate config or env vars.
4. **GitHub App vs PAT for workflow**: A GitHub App token is more secure (scoped, rotatable) but a fine-grained PAT is simpler to set up. Either works — PAT is fine for a personal repo.
