# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

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
