# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.3.3] - 2026-04-04

### Added
- `css-design-system` skill (Blazor overlay) — AI guidance for CSS architecture using Design Tokens + CUBE CSS + Blazor CSS Isolation; covers design token vocabulary, `@layer` ordering, CUBE CSS layout primitives, dark theme pattern, WCAG 2.1 AA accessibility, `prefers-reduced-motion`, and modern CSS features (container queries, `:has()`, logical properties, `oklch()`, `color-mix()`)
- Updated `blazor-architecture` skill — new CSS Architecture section cross-referencing the `css-design-system` skill

## [0.3.2] - 2026-04-04

### Fixed
- `pre-container-setup.prompt.md` — added Step 5 "Set Container Name": instructs users to replace `{{PROJECT_NAME}}` in `.devcontainer/devcontainer.json` on the host machine before opening the container, with explanation of why this must be done pre-build
- `first-time-setup.prompt.md` — removed `.devcontainer/devcontainer.json` from Step 5 placeholder resolution (container name is now a pre-container task, not an in-container one)

## [0.3.1] - 2026-04-04

### Added
- `pre-container-setup.prompt.md` — host-side checklist prompt (run before creating the devcontainer)
- NuGet MCP server (`nuget-mcp` global tool) — configured in project-level `mcp-config.json` for both templates
- Microsoft Docs MCP (`microsoftdocs/mcp`) — HTTP server seeded in user-level Copilot CLI config (`~/.copilot/mcp.json`)
- microsoftdocs/mcp skills auto-installed at container build time (`microsoft-docs`, `microsoft-code-reference`, `microsoft-skill-creator` + references)
- Playwright MCP (`@playwright/mcp`) — configured in project-level and user-level MCP configs (Blazor template)
- Playwright CLI (`@playwright/cli`) installed globally + `playwright-cli install --skills` runs at container build time (Blazor template)
- Playwright browser binaries installed via `npx playwright install --with-deps` (Blazor template)

### Changed
- DevContainer base image updated to `mcr.microsoft.com/devcontainers/dotnet:dev-10.0-noble` (both templates) — supports .NET 10.0.5 dev builds required for NuGet MCP
- `first-time-setup.prompt.md` refactored — in-container steps only; references `pre-container-setup` for host-side steps
- MCP server key renamed `microsoftdocs` (project-level) to match org name; user-level retains `microsoft-learn` (matching plugin convention)

### Fixed
- `post-create.sh` no longer attempts `copilot plugin install` at container lifecycle stage — replaced with direct skill/config file writes
- Playwright MCP package corrected: `@anthropic/playwright-mcp-server` → `@playwright/mcp`

## [0.3.0] - 2026-04-04

### Added
- Security skills tree: 14 modular skills under `.copilot/skills/` including `security-review-core`, `dotnet-authn-authz`, `blazor-wasm-security`, `aspnetcore-api-security`, and more
- `hire-security-architect.prompt.md` — Squad prompt to create a Security Architect agent
- `global.json` — activates Microsoft Testing Platform (MTP) native mode for TUnit tests
- `CONTRIBUTING.md` — overlay conventions, local testing workflow, release process
- `CHANGELOG.md` — this file
- `LICENSE` — MIT license for downstream template repos
- `CODEOWNERS` — code ownership assignments
- PR validation workflow — validates compose output on every PR
- Dependabot configuration — automated GitHub Actions SHA updates
- Security-focused analyzers: `Microsoft.CodeAnalysis.BannedApiAnalyzers`, `Meziantou.Analyzer`

### Fixed
- MCP package names corrected (`@anthropic/github-mcp-server` → `@modelcontextprotocol/server-github`, `@anthropic/playwright-mcp-server` → `@playwright/mcp`)
- DevContainer Docker compatibility — removed Podman-specific `--userns=keep-id` and socket mount
- `postCreateCommand` extracted to `post-create.sh` — removes `copilot plugin` commands that failed at container lifecycle stage
- StyleCop.Analyzers pinned to specific version (no longer wildcard `1.2.0-beta.*`)
- `AdditionalFiles` reference for `stylecop.json` added to `Directory.Build.props`
- GitHub Actions pinned to full commit SHAs — eliminates mutable tag supply chain risk
- Guard job `origin/main` grep pattern uses exact match to prevent `origin/main-v2` false positives
- `fail-fast: false` added to matrix strategy — template publish jobs are independent
- `compose-and-publish.yml` upgraded: concurrency group, timeouts, pre-flight secret check, push validation
- SOC 2 skill: added PI1, P1, Type I/II, audit evidence guidance
- ISO 27001 skill: rewritten with 2022 Annex A (correct control numbers)
- PCI DSS skill: updated to v4.0.1, added scope reduction and Requirement 7
- GDPR skill: added Article 22, Chapter V, Article 8
- HIPAA skill: expanded Physical Safeguards, detailed de-identification methods
- Security Principles in `copilot-instructions.md` expanded with actionable specifics
- Blazor `blazor-architecture` skill: added InteractiveAuto render mode
- TUnit `global.json` example: `rollForward` changed to `latestFeature`
- Rate limit headers in `rfc-compliance` skill updated to reflect Draft-07 single structured header

## [Earlier versions]

See [GitHub Releases](https://github.com/TheSereyn/TheSereyn.Templates/releases) for earlier release notes.
