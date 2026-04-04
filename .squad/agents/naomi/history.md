# Naomi — History

## Core Context

**Project:** TheSereyn.Templates — composition workspace for .NET project templates.
**User:** Lee Buxton
**Team:** Holden (Lead), Naomi (Template Engineer), Amos (Platform Engineer), Drummer (Security Reviewer), Scribe, Ralph

**My domain — template content:**
- `base/.github/copilot-instructions.md` — .NET coding standards for all templates
- `base/.github/copilot/skills/` — TUnit, StyleCop, compliance (GDPR, HIPAA, PCI DSS, SOC2, ISO27001), security-review, security-register, RFC compliance, code-analyzers, project-conventions, requirements-gathering, squad-setup
- `base/.github/prompts/` — first-time-setup, requirements-interview
- `base/Directory.Build.props` — .NET 10, TreatWarningsAsErrors, StyleCop, AnalysisLevel=latest-all
- `base/stylecop.json` — StyleCop config
- `base/README.md` — template README (uses {{PROJECT_NAME}} and {{DESCRIPTION}} placeholders)
- `overlays/blazor/` — Blazor-specific additions: devcontainer, mcp-config, copilot-instructions append, blazor-architecture skill, README
- `overlays/minimalapi/` — Minimal API README

**Key standards:**
- TUnit (not xUnit/NUnit/MSTest), async assertions
- StyleCop + Roslyn analyzers, TreatWarningsAsErrors
- Nullable enabled, file-scoped namespaces, implicit usings
- OpenTelemetry for observability
- IETF RFC 9205/9110/3986/9457 for HTTP/REST

## Learnings

- Session 1 (2026-04-04): Team initialized. I am the template content specialist.

- Session 2 (2026-04-04): Conducted content review with Microsoft Learn MCP validation.
  - Found 18 content findings, 3 Critical
  - Critical issue 1: MCP config references non-existent `@anthropic/*` packages (shared with Amos)
  - Critical issue 2: README lists "Azure" MCP server not actually configured in base
  - Critical issue 3: ISO 27001 skill cites superseded 2013 control numbers (shared with Drummer)
  - Blazor overlay README contains inaccurate claims about features
  - MinimalApi README inherits incorrect Azure reference
  - MCP package issue is highest priority — all MCP tooling broken on day one
  - Used Microsoft Learn documentation to validate .NET standards and compliance references
  - Overlay full-file replacements create drift risk between base and template versions
