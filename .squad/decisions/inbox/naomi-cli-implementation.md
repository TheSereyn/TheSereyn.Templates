# CLI Template Implementation — Base/Overlay Content Split

**By:** Naomi (Template Engineer)
**Date:** 2026-04-14
**Status:** Implemented on dev

## Decision

Refactored `base/.github/copilot-instructions.md` to be template-neutral, moving web/API-specific guidance into overlay append files shared by MinimalApi and Blazor. Created the CLI template overlay with System.CommandLine + Spectre.Console as the default stack.

## What Moved Out of Base

| Content | Was in base | Now in overlays |
|---------|-------------|-----------------|
| Stack rows: API (Minimal APIs, REPR), Architecture (Clean Architecture) | copilot-instructions.md | minimalapi + blazor appends |
| HTTP/REST RFCs (9205, 9110, 3986, 9457) + IETF HTTPAPI WG | copilot-instructions.md | minimalapi + blazor appends |
| Web security (CORS, security headers, CSRF, rate limiting, auth with [Authorize]) | copilot-instructions.md | minimalapi + blazor appends |
| ASP.NET Core OTel setup (AddAspNetCoreInstrumentation code example) | copilot-instructions.md | minimalapi + blazor appends |
| REST micro-checklist | copilot-instructions.md | minimalapi + blazor appends |
| API-specific ask-first triggers (OIDC, persistence, messaging, API versioning, middleware) | copilot-instructions.md | minimalapi + blazor appends |
| Web-specific skills (rfc-compliance, dotnet-authn-authz, aspnetcore-api-security, browser-security-headers) | copilot-instructions.md | minimalapi + blazor appends |
| OpenAPI/Swagger delivery format note | copilot-instructions.md | minimalapi + blazor appends |
| Clean Architecture diagram + webapi manual setup | README.md | (removed — template-specific READMEs handle this) |

## What Stays in Base

- .NET 10 + C# runtime, TUnit, StyleCop, OpenTelemetry (stack table)
- MCP Tools source-of-truth policy
- Dependency policy (changed "ASP.NET Core" to "framework")
- Universal security: input validation, output encoding, secrets, logging, threat modelling, dependency security
- Code quality rules (nullable, file-scoped, async all the way, CancellationToken)
- OTel key conventions (OTLP, service name, ActivitySource, Meter — no web-specific example)
- TUnit testing section
- Delivery format (with generic "Documentation updates" instead of "Docs/OpenAPI updates")
- Spec Kit / Squad workflow
- Universal security skills (security-review-core tree minus web-specific entries)
- All compliance skills

## CLI Overlay Created

| File | Purpose |
|------|---------|
| `overlays/cli/README.md` | CLI template README — System.CommandLine + Spectre.Console architecture |
| `overlays/cli/.github/copilot-instructions.append.md` | CLI stack, CLI security, CLI observability, CLI ask-first triggers, CLI micro-checklists |
| `overlays/cli/.copilot/skills/cli-development/SKILL.md` | Full CLI development skill — System.CommandLine API patterns (verified against MS Learn), Spectre.Console output, exit codes, testing, alternative packages |
| `overlays/cli/.copilot/skills/project-conventions/SKILL.md` | CLI-specific conventions (replaces base via overlay semantics) — command-handler pattern, exit codes, error output, CLI testing, CLI anti-patterns |

## Shared Web Content Pattern

Both MinimalApi and Blazor overlay appends contain identical shared web sections (Stack, RFCs, Web Security, Web Observability, Web Delivery, Web Ask-First, Web Micro-Checklists, Web Skills). This is intentional duplication per the base+overlay model — no mixin layer needed at 3 templates.

## Validation

- `./compose.sh` succeeds for all three templates (minimalapi, blazor, cli)
- MinimalApi composed output contains web-specific content ✓
- Blazor composed output contains web + Blazor content ✓
- CLI composed output has zero web references, has CLI content ✓
- CLI project-conventions skill correctly replaces base version via overlay semantics ✓
- System.CommandLine API patterns verified against Microsoft Learn docs (SetAction, Parse, Invoke, Option<T>, Argument<T>, Recursive, etc.)

## Rationale

The latest directive overrides Session 14's audit — some MinimalApi-originated items (web security, RFCs, OTel with ASP.NET Core instrumentation) are legitimately shared with Blazor and belong in both web overlays rather than being left in base where they'd mislead CLI development. The `.tmp/` artifacts informed CLI stack choices (System.CommandLine + Spectre.Console) but not base/overlay boundaries.
