# TheSereyn.Templates — Comprehensive Review
*Review date: 2026-04-04*
*Reviewers: Holden (Architecture), Naomi (Content), Amos (Platform), Drummer (Security)*

*Last updated: 2025-07-21 — security skills tree implementation on branch `feature/security-skills-tree` resolves findings #13 (partial), #24, #29, #32, #61 and partially mitigates #25. See resolution notes in §7.*

---

## Executive Summary

The composition workspace has a sound foundation — the overlay model is clean, `compose.sh` is correct, the copilot-instructions and skill library are comprehensive, and the build configuration enforces strict code quality. However, **the templates are not production-ready for the stated audience.** Five critical issues must be resolved first: (1) the MCP configuration references npm packages that do not exist, meaning all MCP tooling is broken on day one; (2) the devcontainer is Podman-only and will hard-fail for Docker Desktop users — the majority of the target audience; (3) the `postCreateCommand` chain includes commands (`copilot plugin`) that cannot work during the container lifecycle stage they run in; (4) the ISO 27001 compliance skill cites Annex A control numbers from the superseded 2013 version while claiming 2022 alignment; and (5) GitHub Actions are pinned to mutable tags, creating supply chain exposure. The #1 fix before anyone uses these templates: **replace the non-existent `@anthropic/*` MCP package names with the correct official packages.**

---

## 1. Cross-Cutting Findings

These findings were independently identified by multiple reviewers, indicating high confidence.

### 1.1 Incorrect MCP Package Names — All MCP Tooling Is Broken
- **Identified by:** Naomi, Amos
- **Severity:** Critical
- **Description:** Both `base/.copilot/mcp-config.json` and `overlays/blazor/.copilot/mcp-config.json` reference npm packages that return 404:
  - `@anthropic/github-mcp-server` → does not exist. Correct package: **`@modelcontextprotocol/server-github`**
  - `@anthropic/playwright-mcp-server` → does not exist. Correct package: **`@playwright/mcp`** (maintained by Microsoft)
- **Impact:** Every developer who opens the template in VS Code gets broken MCP servers. No GitHub code search, no Playwright integration. The Blazor overlay duplicates the base config (full-file replacement), so both files must be updated.
- **Recommendation:** Replace package names in both `base/.copilot/mcp-config.json` and `overlays/blazor/.copilot/mcp-config.json`. Pin to specific versions (e.g., `@modelcontextprotocol/server-github@0.6.2`) to prevent supply chain attacks via `npx -y`.

### 1.2 Podman-Only DevContainer Fails Docker Desktop Users
- **Identified by:** Holden, Amos
- **Severity:** Critical
- **Description:** The devcontainer configuration contains two Podman-specific elements that cause hard failures on Docker:
  1. `"runArgs": ["--userns=keep-id", "--security-opt=label=disable"]` — `--userns=keep-id` is Podman-only. Docker rejects it with `unknown flag` and the container does not start.
  2. `"mounts": ["source=${localEnv:XDG_RUNTIME_DIR}/podman/podman.sock,..."]` — `XDG_RUNTIME_DIR` is unset on macOS and Windows. The mount resolves to a non-existent path and fails.
- **Impact:** Any developer using Docker Desktop on macOS or Windows — the most common setup — cannot use the template. The README lists Docker as a supported prerequisite, making this a broken promise.
- **Recommendation:** Either (a) remove Podman-specific `runArgs` and mount, relying on `remoteUser: vscode` and the `docker-outside-of-docker` feature; (b) provide separate `.devcontainer/<profile>/devcontainer.json` for Docker and Podman; or (c) document that Podman is required and remove Docker from prerequisites.

### 1.3 ISO 27001 Skill Uses Superseded 2013 Control Numbering
- **Identified by:** Naomi, Drummer
- **Severity:** Critical
- **Description:** The `compliance-iso27001` skill references Annex A controls A.8, A.9, A.12, A.14, A.16, A.18 — all from **ISO 27001:2013**. ISO 27001:2022 completely restructured Annex A from 14 domains (114 controls) to 4 themes (93 controls): A.5 Organisational, A.6 People, A.7 Physical, A.8 Technological. None of the cited control numbers match the current standard.
- **Impact:** A developer or auditor cross-referencing this skill against ISO 27001:2022 will find no matching control numbers. This undermines the credibility of the compliance guidance and could cause audit failures. The skill also omits 11 new controls added in 2022 (e.g., A.5.7 Threat Intelligence, A.8.9 Configuration Management, A.8.11 Data Masking, A.8.28 Secure Coding).
- **Recommendation:** Rewrite the ISO 27001 skill using 2022 Annex A themes and control numbers. Include the 11 new 2022 controls. Add ISMS scope definition, risk assessment methodology reference, and Statement of Applicability (SoA) guidance.

### 1.4 GitHub Actions Pinned to Mutable Tags — Supply Chain Risk
- **Identified by:** Holden, Amos, Drummer
- **Severity:** Critical
- **Description:** `actions/checkout@v4` is used 3 times in `compose-and-publish.yml` and `actions/github-script@v7` is used in all 4 Squad workflows. These are mutable tag references — a compromised tag could inject code into every workflow run.
- **Impact:** An attacker who compromises the `actions/checkout` tag or repository could inject code into the compose-and-publish workflow, which has write access to downstream template repositories via `TEMPLATE_PUSH_TOKEN`.
- **Recommendation:** Pin all actions to full SHAs (e.g., `actions/checkout@b4ffde65f46336ab88eb53be808477a3936bae11 # v4.1.7`). Add Dependabot for GitHub Actions to automate SHA updates.

### 1.5 `postCreateCommand` Is Broken and Fragile
- **Identified by:** Holden, Amos, Drummer
- **Severity:** Critical
- **Description:** The `postCreateCommand` has multiple compounding failures:
  1. **`copilot plugin` commands will fail** — the `copilot` CLI is not on the PATH during `postCreateCommand` because VS Code extensions haven't loaded yet. Commands like `copilot plugin marketplace add` fail with `command not found`, stopping the entire chain.
  2. **`gh extension install github/gh-copilot`** requires prior `gh auth login` and is not idempotent — running twice fails.
  3. **Single `&&` chain** — any failure stops all subsequent commands. Base has 6+ chained commands; Blazor has 9+.
  4. **No version pinning** on any install (`gh extension install`, `npm install -g @playwright/cli@latest`, `npx -y @anthropic/*`), creating a supply chain attack surface.
- **Impact:** On a fresh container, the chain will fail at the `copilot plugin` step, silently skipping all remaining setup. Developers get an incomplete environment with no error explanation.
- **Recommendation:** Extract to `.devcontainer/post-create.sh` with individual error handling. Move `copilot plugin` commands to `postStartCommand` or documentation. Wrap `gh extension install` with `|| true`. Pin all package versions. Separate verification commands from installation commands.

### 1.6 Base README Contains Inaccurate Claims
- **Identified by:** Holden, Naomi
- **Severity:** High
- **Description:** The base `README.md` lists "Azure" in the MCP Servers row and "Playwright CLI" in the Skills row. No Azure MCP server is configured in `base/.copilot/mcp-config.json` (only Microsoft Learn and GitHub). Playwright is only present in the Blazor overlay. The MinimalApi overlay `README.md` inherits the same Azure inaccuracy.
- **Impact:** The MinimalApi template promises features that aren't present. Users who trust the README will look for configuration that doesn't exist.
- **Recommendation:** Remove "Azure" from MCP Servers and "Playwright CLI" from Skills in the base README. Fix the MinimalApi overlay README similarly. Ensure the Blazor overlay README accurately reflects its actual configuration.

### 1.7 Blazor Overlay Full-File Replacements Create Drift Risk
- **Identified by:** Holden, Amos
- **Severity:** High
- **Description:** The Blazor overlay replaces `devcontainer.json` and `mcp-config.json` entirely rather than appending or merging. These files are near-copies of the base versions with small additions (Playwright extension, Playwright install commands, Playwright MCP server). If a base change is made to either file, the Blazor overlay will silently not receive it.
- **Impact:** Fixing the MCP package names (Finding 1.1) requires updating both files independently. With more templates, this problem scales linearly — 5 templates means 5 near-identical copies to maintain.
- **Recommendation:** Either (a) implement a JSON merge strategy in `compose.sh` (e.g., using `jq`) so overlays can extend base JSON files, or (b) add CI drift detection that diffs replaced files against their base counterparts and flags divergence.

### 1.8 `TEMPLATE_PUSH_TOKEN` PAT Is Undocumented and User-Scoped
- **Identified by:** Holden, Amos, Drummer
- **Severity:** High
- **Description:** The `compose-and-publish.yml` workflow uses `secrets.TEMPLATE_PUSH_TOKEN` — a Personal Access Token (PAT) — to push to downstream repos. There is no documentation of the required scope, and no pre-flight check (a missing secret produces a cryptic auth error). PATs are tied to individual accounts: if that person leaves, the token breaks.
- **Impact:** Bus factor risk, potential over-scoping (a `repo`-scoped PAT grants access to all repos the user can see), and no audit trail distinguishing automated pushes from human ones.
- **Recommendation:** Replace with a GitHub App installation token scoped to `contents: write` on the downstream repos only. Document the minimum required permissions. Add a pre-flight check for the token's existence.

### 1.9 StyleCop Wildcard Beta Version Is a Supply Chain Risk
- **Identified by:** Holden, Drummer
- **Severity:** Medium
- **Description:** `Directory.Build.props` references `StyleCop.Analyzers Version="1.2.0-beta.*"`. The `*` wildcard means NuGet resolves to any matching pre-release version. Analyzers execute code in the compiler pipeline — a compromised version runs during every build.
- **Impact:** A malicious NuGet package matching `1.2.0-beta.*` would be automatically pulled into every project built from these templates.
- **Recommendation:** Pin to a specific version (e.g., `1.2.0-beta.556`). The beta is necessary for .NET 10 / C# 13 support (stable 1.1.x only supports C# 7.3), but the wildcard is not.

### 1.10 Missing `Directory.Packages.props` Despite Being Referenced
- **Identified by:** Holden, Drummer
- **Severity:** Low
- **Description:** `copilot-instructions.md` line 54 states "Follow `Directory.Packages.props` for central package management when present," but no such file exists in `base/`. Central Package Management (CPM) with `ManagePackageVersionsCentrally` prevents individual projects from pulling arbitrary package versions — a supply chain security control.
- **Recommendation:** Either add a `Directory.Packages.props` with CPM enabled, or remove the reference from copilot-instructions to avoid misleading Copilot agents.

---

## 2. Architecture (Holden)

### Composition & CI/CD

| Severity | Finding | Recommendation |
|----------|---------|----------------|
| **High** | No CI workflow runs `compose.sh` on pull requests. A broken overlay could merge to `main` and only fail at tag-push time. | Add a PR validation workflow that runs `compose.sh` and verifies output exists, JSON files parse, and minimum file count is met. |
| **High** | No sanity check before pushing to downstream repos. A broken compose could push an empty or corrupted template to production. | Add a validation step between compose and push: verify `output/<RepoName>/README.md` exists and has content. |
| **High** | Downstream divergence is silently overwritten. The sync step deletes everything in downstream repos except `.git/`. Direct commits (docs fixes, hotfixes) are destroyed without warning. | Document the "composition is authoritative" policy. Consider a backup step or warning when downstream has unmirrored commits. |
| **Medium** | `TEMPLATES` array in `compose.sh` and the workflow matrix must be kept in sync manually. Adding a template requires editing both files — a DRY (Don't Repeat Yourself) violation. | Extract to a shared `templates.json` manifest consumed by both `compose.sh` and the workflow matrix (via `fromJSON()`). |
| **Medium** | Git identity is `github-actions[bot]` with no GPG signing on downstream commits or tags. For a security-focused template, unsigned automated commits are inconsistent. | Consider GPG-signing automated commits or document why signing is not used. |
| **Low** | `compose.sh` composes all templates on every run; each CI matrix job only needs one. | Add an optional argument: `./compose.sh minimalapi`. |
| **Low** | No release notes or changelog generation. Tags are pushed downstream but no GitHub Release is created. | Create GitHub Releases with changelogs on downstream repos during publish. |
| **Low** | The "Tag template repo" step relies on the token being embedded in the remote URL from the clone step — an implicit dependency. | Set `GH_TOKEN` explicitly in the tag step. |

### Template Architecture

| Severity | Finding | Recommendation |
|----------|---------|----------------|
| **Medium** | No actual source code in either template — no `.sln`, `.csproj`, or `Program.cs`. The template relies entirely on Copilot + Squad to scaffold. A developer without Copilot has an empty project. | Document this explicitly as an "AI-first template" that requires Copilot. Add a minimal manual setup section. |
| **Medium** | No CHANGELOG or documented versioning strategy (SemVer? CalVer?). No guidance on what constitutes major vs minor vs patch for a template. | Adopt SemVer. Add a CHANGELOG.md. Consider conventional commits. |
| **Medium** | No CONTRIBUTING guide explaining overlay conventions, local testing, or the composition model. | Write `CONTRIBUTING.md` covering the overlay model, local testing workflow, and release process. |
| **Medium** | No branch protection documentation. The workflow assumes `main` is protected, but there's no evidence of configured rules. | Document expected branch protection settings or provide a setup script. |
| **Medium** | No fallback onboarding path if Copilot is unavailable. The entire setup relies on Copilot Chat prompts. | Add a minimal manual setup section to the README or a `setup.sh` script. |
| **Low** | No mixin/layer support for shared overlay fragments. Templates C and D both needing Playwright would require duplicating content. | Document as a future consideration at 4+ templates. |
| **Low** | No LICENSE file in base. Downstream template repos show "No license" on GitHub until the consumer runs first-time-setup. | Include a default LICENSE (MIT) in base with a note that it can be changed. |
| **Low** | No template preview/dry-run capability. No way to see composed output without committing. | Consider a `compose.sh --dry-run` or PR comment bot showing the diff. |
| **Low** | No CODEOWNERS or branch protection in downstream repos to prevent direct commits that would be overwritten. | Add CODEOWNERS and branch protection to downstream repos. |

---

## 3. Template Content (Naomi)

### Build Configuration

| Severity | Finding | Recommendation |
|----------|---------|----------------|
| **Critical** | No `global.json` exists in `base/`. The `tunit-testing` skill states MTP is configured via `global.json`, but the file is missing. Without it, MTP (Microsoft Testing Platform) native mode is not activated — `dotnet test` defaults to VSTest, and every MTP-specific flag (`--report-trx`, `--coverage`) will produce "exit code 5 — zero tests ran" failures. | Add `base/global.json` with `{"sdk":{"version":"10.0.100","rollForward":"latestFeature"},"test":{"runner":"Microsoft.Testing.Platform"}}`. |
| **High** | `Directory.Build.props` is missing an `<AdditionalFiles>` reference to `stylecop.json`. StyleCop may not discover its configuration in multi-project solutions without explicit inclusion. | Add `<AdditionalFiles Include="$(MSBuildThisFileDirectory)stylecop.json" Link="stylecop.json" />` to the `<ItemGroup>`. |

### Copilot Instructions

| Severity | Finding | Recommendation |
|----------|---------|----------------|
| **High** | Skills list in `copilot-instructions.md` is incomplete. Lists 7 skills but omits 6: `squad-setup`, `compliance-gdpr`, `compliance-hipaa`, `compliance-pcidss`, `compliance-soc2`, `compliance-iso27001`. | Add all 6 missing skills to the `## Skills` section. |
| **Medium** | Blazor `copilot-instructions.append.md` adds the `blazor-architecture` skill under `## Blazor UI` rather than the existing `## Skills` section. The composed file will have skills listed in two separate locations, which may confuse agents. | Restructure the append so skills go under the existing `## Skills` section, or add a cross-reference note. |
| **Low** | OpenTelemetry coverage is surface-level — only "traces, metrics, logs" with no mention of `.AddOpenTelemetry()` builder pattern or OTLP exporter configuration. | Add setup guidance for the .NET 8+ OpenTelemetry builder pattern. |

### Compliance Skills

| Severity | Finding | Recommendation |
|----------|---------|----------------|
| **Medium** | PCI DSS skill states "Version 4.0 is the current standard." PCI DSS v4.0.1 was released June 2024 as an errata update. | Update version reference to "Version 4.0.1". |
| **Medium** | `tunit-testing` skill example uses `"rollForward": "latestMinor"`. Microsoft docs recommend `"latestFeature"` for development, which picks up newer SDK feature bands within the same minor version. | Use `"latestFeature"` in the `global.json` template. |
| **Medium** | `blazor-architecture` skill does not mention `InteractiveAuto` render mode introduced in .NET 8+, which auto-switches between Server and WebAssembly. | Add `InteractiveAuto` as a fourth hosting option. |

### Prompts & READMEs

| Severity | Finding | Recommendation |
|----------|---------|----------------|
| **Medium** | `first-time-setup` Step 9 lists "Playwright CLI" in the skills review. The prompt is in `base/` so it runs for both templates, but Playwright is Blazor-only. | Conditionally mention Playwright only for Blazor, or remove from the generic listing. |
| **Low** | OWASP Top 10 heading in `security-review` skill doesn't specify the version year "2021". | Add "(2021)" to the heading for clarity. |
| **Low** | Rate Limit Headers in `rfc-compliance` skill reference separate `RateLimit-Limit`/`RateLimit-Remaining`/`RateLimit-Reset` headers. Draft-07 uses a single `RateLimit` structured header. | Update to reflect current draft state or note that header names may change. |
| **Low** | `first-time-setup` prompt doesn't mention `.editorconfig` or `stylecop.json` for verification or customisation. | Add a step informing users these files exist and can be customised. |
| **Low** | `tunit-testing` skill is missing `[After(Class)]`, `[Before(Assembly)]`, `[After(Assembly)]` hook attributes. | Add for completeness. |

---

## 4. Platform & DevContainer (Amos)

### DevContainer Reliability

| Severity | Finding | Recommendation |
|----------|---------|----------------|
| **High** | Both READMEs state "Squad — auto-installed via DevContainer," but there is no Squad installation step in `postCreateCommand`. `squad-setup` skill documents manual `npm install -g @bradygaster/squad-cli` followed by `squad init`. The README claim is false. | Either add `npm install -g @bradygaster/squad-cli && squad init` to `postCreateCommand`, or correct the README to say "installed manually." |
| **Medium** | Blazor `npx playwright install --with-deps` downloads browser binaries (~2 GB) and runs `apt-get install` for system dependencies. Takes 5–10 minutes and may fail if user is not root. This blocks container creation. | Make Playwright browser installation a documented manual step or move to `onCreateCommand` with progress feedback. |
| **Low** | `azure-cli` and `github-cli` devcontainer features have no tool version pinning. A major version bump could break scripts. | Consider pinning (e.g., `"version": "2"` for `github-cli`). |
| **Low** | `ms-dotnettools.csharp` extension may be redundant alongside `ms-dotnettools.csdevkit` — C# Dev Kit includes C# language support. | Evaluate whether both are needed; keeping both is defensible but worth documenting. |
| **Low** | No `forwardPorts` configured for common .NET ports (5000, 5001, 5173). Developers must manually forward ports to access running applications. | Add `"forwardPorts": [5000, 5001]` to the base devcontainer. |

### Workflow Issues

| Severity | Finding | Recommendation |
|----------|---------|----------------|
| **High** | `squad-heartbeat.yml` uses `${{ secrets.COPILOT_ASSIGN_TOKEN || secrets.GITHUB_TOKEN }}`. The `||` operator does not work for secrets in GitHub Actions expressions. If `COPILOT_ASSIGN_TOKEN` is unset, this resolves to empty string, not `GITHUB_TOKEN`. | Use a conditional expression or intermediate environment variable. |
| **Medium** | Workflow matrix `fail-fast` is not set to `false`. Default `true` means if the MinimalApi job fails, the Blazor job is cancelled. Templates should publish independently. | Add `fail-fast: false` to the matrix strategy. |
| **Medium** | Guard job branch check `grep -q 'origin/main'` could false-match branches like `origin/main-v2`. | Use `grep -qE '^\s*origin/main$'` for exact matching. |
| **Low** | `ubuntu-latest` runner currently maps to `ubuntu-24.04` but will eventually shift. | Consider pinning to `ubuntu-24.04` for predictability. |

---

## 5. Security (Drummer)

### Compliance Skills

| Severity | Finding | Recommendation |
|----------|---------|----------------|
| **High** | SOC 2 skill is missing dedicated sections for Processing Integrity (PI1) and Privacy (P1) criteria despite listing 5 Trust Service Criteria in the description. Type I vs Type II distinction is not covered. No evidence collection guidance for audits. | Add PI1 and P1 sections. Add Type I vs Type II explanation. Add guidance on audit evidence (access review logs, deployment logs, change approval records). |
| **Medium** | PCI DSS skill has no scope reduction guidance — the most practical PCI advice is "don't touch card data." Missing Requirement 7 (Restrict Access) which maps directly to RBAC (Role-Based Access Control) implementation. No mention of v4.0 future-dated requirements (mandatory since 31 March 2025). | Add scope reduction section recommending tokenisation. Add Requirement 7 coverage. Note phased timeline. |
| **Medium** | GDPR skill is missing Article 22 (Automated Decision-Making — increasingly relevant with AI/ML), international data transfers (Chapter V — SCCs, adequacy decisions, Schrems II), and Article 8 (children's data). | Add these as sections or checklist items. |
| **Medium** | `security-register` skill is missing status values (Won't Fix, Duplicate, False Positive), has no CVSS 3.1/4.0 scoring guidance for objective severity assessment, and lacks an "Informational" severity level that the `security-review` skill outputs. | Add missing statuses. Add CVSS reference. Align severity levels with `security-review`. |

### Security Review Skill

| Severity | Finding | Recommendation |
|----------|---------|----------------|
| **Medium** | `security-review` skill is missing several .NET-specific checks: `IHttpClientFactory` usage (socket exhaustion), mass assignment / over-posting prevention, EF Core raw SQL safety (`FromSqlRaw` vs `FromSqlInterpolated`), request size limits (`[RequestSizeLimit]`), `EnableSensitiveDataLogging` production leak, Blazor Content Security Policy (CSP), and output caching of authenticated data. | Add these to the .NET-Specific Checks section. |

### Copilot Instructions Security

| Severity | Finding | Recommendation |
|----------|---------|----------------|
| **Medium** | Security Principles in `copilot-instructions.md` are too terse. "strict CORS" doesn't warn against `AllowAnyOrigin()`. "security headers" doesn't list the required set (HSTS, CSP, `X-Content-Type-Options`, `X-Frame-Options`, `Referrer-Policy`, `Permissions-Policy`). Missing: input validation, output encoding, CSRF protection, rate limiting (`RateLimiter` middleware), dependency vulnerability scanning. | Expand with specific guidance for each area. Add the missing security principles. |

### DevContainer Security

| Severity | Finding | Recommendation |
|----------|---------|----------------|
| **High** | `docker-outside-of-docker` feature combined with the Podman socket mount gives the container full control over the host container runtime — start/stop/delete any container, mount any host directory, and potentially escalate to host-level access. Not documented as a risk. | Document as a known risk. Evaluate whether `docker-outside-of-docker` is needed in the base template or should be overlay-only. |
| **Medium** | MCP server `npx -y` commands execute with `GITHUB_TOKEN` injected via environment variable. An unpinned package (combined with Finding 1.1's wrong package names) could exfiltrate the token. | Pin MCP server package versions. (Partially addressed by Finding 1.1 fix.) |

### First-Time-Setup Security

| Severity | Finding | Recommendation |
|----------|---------|----------------|
| **Medium** | Setup flow is missing security-relevant steps: no `.gitignore` review for secrets (`appsettings.*.json`, `*.pfx`, `.env`), no `dotnet user-secrets init`, no branch protection guidance, no GitHub Secret Scanning enablement. | Add security-focused setup steps to the `first-time-setup` prompt. |

### Workflow & Build Security

| Severity | Finding | Recommendation |
|----------|---------|----------------|
| **Medium** | No security-focused analyzer packages beyond built-in Roslyn rules. `Microsoft.CodeAnalysis.BannedApiAnalyzers` can ban dangerous APIs (e.g., `MD5.Create()`, `HttpClient..ctor()`). `Meziantou.Analyzer` catches ReDoS-vulnerable regex, improper `StringComparison`, and more. | Add `BannedApiAnalyzers` at minimum. Consider `Meziantou.Analyzer`. |
| **Low** | `--security-opt=label=disable` disables SELinux label confinement without documentation. Acceptable for Podman development but removes a defence layer. | Add a comment explaining this is for Podman compatibility. |
| **Low** | No `timeout-minutes` on workflow jobs (default is 6 hours). No concurrency group to prevent parallel publishes from conflicting. | Add `timeout-minutes: 15` and a concurrency group. |
| **Low** | Token embedded in git clone URL is stored in `.git/config`. Safe under normal conditions (GitHub Actions masks secrets in logs), but verbose git logging (`GIT_TRACE`) could leak it. | Consider `git config` credential helper instead of URL embedding. |
| **Low** | Threat modelling in copilot-instructions says "early and often" with no methodology reference. | Add STRIDE reference and link to Microsoft Threat Modeling Tool. |
| **Low** | HIPAA skill's Physical Safeguards are not a primary section. De-identification methods (Safe Harbor vs Expert Determination) are mentioned but not detailed. | Expand to a dedicated Physical Safeguards section. Detail de-identification methods. |

---

## 6. What's Working Well

1. **The overlay composition model is clean and correct.** `compose.sh` is idempotent, uses `set -euo pipefail`, handles `.append.md` files correctly (including filenames with spaces via `find -print0`), and preserves `.git` directories in output. The base-then-overlay copy order produces correct results.

2. **The copilot-instructions are comprehensive and opinionated.** Stack definition, Clean Architecture layers, REPR (Request-Endpoint-Response) pattern, TUnit configuration, StyleCop rules, OAuth/OIDC with PKCE and DPoP, and "ask first" triggers are all well-specified. This is significantly more mature than most template projects.

3. **The skill library is extensive and mostly accurate.** 13 base skills plus 1 Blazor-specific skill. The `requirements-gathering` skill (10-phase structure with MoSCoW prioritisation) and `project-conventions` skill (RFC 9457 Problem Details, cursor-based pagination, async patterns) are production-ready. The `tunit-testing` "Common Agent Mistakes" section is particularly valuable.

4. **OWASP coverage is complete and current.** Both the Web Top 10 (2021) and API Security Top 10 (2023) are fully enumerated with correct category names and descriptions. The `security-review` output format is clear and actionable.

5. **The build configuration enforces strict code quality.** `TreatWarningsAsErrors`, `AnalysisLevel=latest-all`, `EnforceCodeStyleInBuild=true`, and nullable reference types together ensure that code quality and security-relevant warnings cannot be ignored.

6. **The workflow guard job is well-designed.** Verifying that a tag points to a commit on `main` before publishing prevents accidental releases from feature branches. The `permissions: contents: read` at workflow level follows least-privilege.

7. **Placeholder tokens are consistent.** `{{PROJECT_NAME}}`, `{{NAMESPACE}}`, `{{DESCRIPTION}}` are used consistently across all files and the `first-time-setup` prompt correctly references all of them with the right target files.

8. **The `.editorconfig` is thorough.** Covers all file types, has comprehensive C# conventions, well-justified StyleCop suppressions with comments, and appropriate nullable diagnostic escalation.

---

## 7. Consolidated Recommendations

A complete, deduplicated, prioritised list of all recommended actions.

| # | Priority | Area | Finding | Recommendation | Owner |
|---|----------|------|---------|----------------|-------|
| 1 | Critical | MCP Config | `@anthropic/github-mcp-server` and `@anthropic/playwright-mcp-server` do not exist on npm. All MCP tooling is broken. | Replace with `@modelcontextprotocol/server-github` and `@playwright/mcp`. Pin versions. Update both base and Blazor configs. | Amos |
| 2 | Critical | DevContainer | `--userns=keep-id` and Podman socket mount fail on Docker Desktop. Container won't start for most developers. | Remove Podman-specific runArgs/mount, or provide Docker/Podman profiles, or require Podman and update prerequisites. | Amos |
| 3 | Critical | Compliance | ISO 27001 skill uses 2013 Annex A numbering. All control numbers are wrong for the 2022 version. | Rewrite using 2022 themes (A.5–A.8). Include 11 new 2022 controls. Add ISMS scope, risk assessment, and SoA guidance. | Drummer |
| 4 | Critical | Workflow | `actions/checkout@v4` and `actions/github-script@v7` not pinned to SHA. Supply chain attack vector. | Pin to full SHAs. Add Dependabot for GitHub Actions. | Holden |
| 5 | Critical | DevContainer | `copilot plugin` commands in `postCreateCommand` fail — CLI not available at that lifecycle stage. `gh extension install` not idempotent. Single `&&` chain breaks on first failure. | Extract to `.devcontainer/post-create.sh`. Move `copilot plugin` to `postStartCommand` or docs. Wrap installs with `|| true`. Pin all versions. | Amos |
| 6 | Critical | Build Config | No `global.json` in base. MTP native mode not activated — TUnit tests will fail with documented flags. | Add `base/global.json` with SDK version pin and `"test":{"runner":"Microsoft.Testing.Platform"}`. | Naomi |
| 7 | High | README | Base and MinimalApi READMEs claim "Azure" MCP and "Playwright CLI" — neither exists in base. | Remove inaccurate claims. Ensure each README matches actual configuration. | Naomi |
| 8 | High | Base/Overlay | Blazor overlay replaces `devcontainer.json` and `mcp-config.json` entirely — drift risk when base changes. | Implement JSON merge in `compose.sh` (e.g., `jq`), or add CI drift detection comparing replaced files to base. | Holden |
| 9 | High | TEMPLATE_PUSH_TOKEN | PAT is undocumented, user-scoped (bus factor), potentially over-scoped. | Replace with GitHub App installation token. Document minimum permissions. Add pre-flight existence check. | Holden |
| 10 | High | Workflow | No CI workflow validates composition on PRs to `main`. Broken overlays can merge undetected. | Add a PR workflow that runs `compose.sh` and validates output (files exist, JSON parses, minimum file count). | Holden |
| 11 | High | Workflow | No validation before pushing to downstream repos. A corrupted compose could push broken content. | Add sanity check: verify README exists, JSON files parse, minimum file count met. | Holden |
| 12 | High | Workflow | Downstream divergence silently overwritten. Direct commits to downstream repos are destroyed. | Document "composition is authoritative" policy. Consider warning on unmirrored downstream commits. | Holden |
| 13 | High | copilot-instructions | Skills list missing 6 entries: `squad-setup`, `compliance-gdpr`, `compliance-hipaa`, `compliance-pcidss`, `compliance-soc2`, `compliance-iso27001`. | Add all 6 missing skills to the `## Skills` section. | Naomi | **Partially resolved** (`squad-setup` added; compliance skills now appended during `first-time-setup` when user selects frameworks — by design opt-in, not pre-listed) |
| 14 | High | Build Config | `Directory.Build.props` missing `<AdditionalFiles>` for `stylecop.json`. StyleCop config won't be found in multi-project solutions. | Add `<AdditionalFiles Include="$(MSBuildThisFileDirectory)stylecop.json" Link="stylecop.json" />`. | Naomi |
| 15 | High | README | "Squad — auto-installed via DevContainer" is false. No Squad install in `postCreateCommand`. | Add Squad install to `postCreateCommand` or correct the README. | Amos |
| 16 | High | Workflow | `squad-heartbeat.yml` secret fallback `secrets.COPILOT_ASSIGN_TOKEN \|\| secrets.GITHUB_TOKEN` is invalid syntax. Resolves to empty string. | Use a conditional expression or intermediate environment variable. | Amos |
| 17 | High | Compliance | SOC 2 skill missing Processing Integrity (PI1), Privacy (P1) criteria, Type I vs Type II distinction, and evidence collection guidance. | Add dedicated sections for all missing elements. | Drummer |
| 18 | High | DevContainer | `docker-outside-of-docker` + socket mount gives container full host container runtime control. Undocumented privilege escalation risk. | Document risk. Evaluate whether this belongs in base or overlay-only. | Drummer |
| 19 | Medium | Build Config | `StyleCop.Analyzers 1.2.0-beta.*` wildcard on pre-release is a supply chain risk — analyzers execute in the compiler pipeline. | Pin to specific version (e.g., `1.2.0-beta.556`). | Holden |
| 20 | Medium | Composition | `TEMPLATES` array and workflow matrix must be synced manually — DRY violation. | Extract to shared `templates.json`. Have workflow use `fromJSON()` for dynamic matrix. | Holden |
| 21 | Medium | Compliance | PCI DSS skill says "Version 4.0" — v4.0.1 released June 2024. No scope reduction guidance. Missing Requirement 7. | Update to v4.0.1. Add scope reduction (tokenisation). Add Requirement 7 (RBAC). | Drummer |
| 22 | Medium | Compliance | GDPR skill missing Article 22 (Automated Decision-Making), international data transfers (Chapter V), and children's data (Article 8). | Add as sections or checklist items. | Drummer |
| 23 | Medium | Compliance | `security-register` missing statuses (Won't Fix, Duplicate, False Positive), no CVSS guidance, no Informational severity. | Add missing statuses. Add CVSS reference. Align severity levels. | Drummer |
| 24 | Medium | security-review | Missing .NET-specific checks: `IHttpClientFactory`, mass assignment, EF Core raw SQL, request size limits, Blazor CSP, output caching of auth data. | Add to .NET-Specific Checks section. | Drummer | **Resolved** — replaced monolithic `security-review` with 10-skill modular tree. `data-access-and-validation` covers EF Core raw SQL and ownership; `aspnetcore-api-security` covers request size limits; `blazor-wasm-security` covers Blazor CSP; `serialization-file-upload-and-deserialization` covers related patterns. `security-review-core` is now the entry point. |
| 25 | Medium | copilot-instructions | Security Principles too terse. No `AllowAnyOrigin()` warning, no specific headers listed, missing input validation, output encoding, CSRF, rate limiting. | Expand with specific, actionable guidance for each area. | Drummer | **Partially mitigated** — the new security skill tree (`aspnetcore-api-security`, `browser-security-headers`, `dotnet-authn-authz`, `data-access-and-validation`) provides this depth at the skill layer. The `## Security Principles` section in `copilot-instructions.md` itself still warrants expansion as a future task. |
| 26 | Medium | first-time-setup | Missing security steps: `.gitignore` review for secrets, `dotnet user-secrets init`, branch protection guidance, Secret Scanning enablement. | Add security-focused setup steps. | Drummer |
| 27 | Medium | Build Config | No security-focused analyzers beyond built-in Roslyn. | Add `Microsoft.CodeAnalysis.BannedApiAnalyzers` at minimum. Consider `Meziantou.Analyzer`. | Drummer |
| 28 | Medium | MCP Security | MCP `npx -y` commands with unpinned packages and `GITHUB_TOKEN` injected — token exfiltration risk. | Pin MCP server package versions (addressed with Finding #1 fix). | Drummer |
| 29 | Medium | copilot-instructions | Blazor append adds skills under `## Blazor UI` instead of `## Skills` — two skills locations in composed file. | Restructure append to target `## Skills` section, or add cross-reference. | Naomi | **Resolved** — Blazor overlay `copilot-instructions.append.md` restructured: `blazor-architecture`, `blazor-wasm-security`, and `signalr-and-real-time-security` bullets now appear before `## Blazor UI` heading so they naturally extend the base `## Skills` list when appended. `### Skills` subsection removed. |
| 30 | Medium | tunit-testing | `rollForward` example uses `"latestMinor"` — `"latestFeature"` is more appropriate for development. | Change to `"latestFeature"` in the skill's `global.json` template. | Naomi |
| 31 | Medium | blazor-architecture | No mention of `InteractiveAuto` render mode (auto-switches Server ↔ WASM). | Add as a fourth hosting option. | Naomi |
| 32 | Medium | first-time-setup | Step 9 lists "Playwright CLI" in skills review — base prompt but Playwright is Blazor-only. | Remove from base listing or conditionally include. | Naomi | **Resolved** — Step 9 updated to remove Playwright CLI; now references `security-review-core` and Squad setup instead. |
| 33 | Medium | Architecture | No actual source code in templates. Developer without Copilot has an empty project. Not documented. | Document as "AI-first template" requiring Copilot. Add minimal manual setup guide. | Holden |
| 34 | Medium | Missing | No CHANGELOG or versioning strategy. | Adopt SemVer. Add CHANGELOG.md. Consider conventional commits. | Holden |
| 35 | Medium | Missing | No CONTRIBUTING guide. | Write CONTRIBUTING.md covering overlay conventions, testing, and release flow. | Holden |
| 36 | Medium | Missing | No branch protection documentation. | Document expected branch protection settings. | Holden |
| 37 | Medium | Missing | No fallback onboarding without Copilot. | Add manual setup section to README or a `setup.sh` script. | Holden |
| 38 | Medium | Workflow | Git identity has no GPG signing on downstream commits. | Sign automated commits or document rationale. | Holden |
| 39 | Medium | Workflow | `fail-fast` not set to `false` in matrix. One template failure cancels the other. | Add `fail-fast: false`. | Amos |
| 40 | Medium | Workflow | Guard job `grep -q 'origin/main'` could match `origin/main-v2`. | Use `grep -qE '^\s*origin/main$'`. | Amos |
| 41 | Medium | DevContainer | Blazor Playwright browser install takes 5–10 min and blocks container creation. | Make a documented manual step or move to `onCreateCommand`. | Amos |
| 42 | Low | Build Config | Missing `Directory.Packages.props` despite being referenced in copilot-instructions. | Add CPM or remove the reference. | Holden |
| 43 | Low | Composition | `compose.sh` composes all templates every run; matrix only needs one. | Add `--only <overlay>` argument. | Holden |
| 44 | Low | Scalability | No mixin/layer support for shared overlay fragments. | Document as future consideration at 4+ templates. | Holden |
| 45 | Low | Missing | No LICENSE in template repos until consumer runs setup. GitHub shows "No license." | Include a default LICENSE (MIT) in base. | Holden |
| 46 | Low | Missing | No release notes. Tags pushed downstream but no GitHub Release created. | Create releases with changelogs. | Holden |
| 47 | Low | Missing | No template preview/dry-run. | Add `compose.sh --dry-run`. | Holden |
| 48 | Low | Missing | No downstream repo protection (CODEOWNERS, branch rules). | Add CODEOWNERS and branch protection. | Holden |
| 49 | Low | copilot-instructions | OpenTelemetry coverage surface-level. No `.AddOpenTelemetry()` or OTLP guidance. | Add setup guidance for .NET 8+ OTel builder. | Naomi |
| 50 | Low | security-review | OWASP Top 10 heading doesn't specify "2021" year. | Add "(2021)" to heading. | Naomi |
| 51 | Low | rfc-compliance | Rate Limit Headers draft evolved — `RateLimit` is now a single structured header. | Update or note that header names may change. | Naomi |
| 52 | Low | first-time-setup | No mention of `.editorconfig` or `stylecop.json` verification during setup. | Add a step informing users these exist and can be customised. | Naomi |
| 53 | Low | tunit-testing | Missing `[After(Class)]`, `[Before(Assembly)]`, `[After(Assembly)]` hook attributes. | Add for completeness. | Naomi |
| 54 | Low | DevContainer | `azure-cli` and `github-cli` features have no version pin. | Consider pinning for reproducibility. | Amos |
| 55 | Low | DevContainer | `ms-dotnettools.csharp` may be redundant with `csdevkit`. | Evaluate or document why both are kept. | Amos |
| 56 | Low | DevContainer | No `forwardPorts` for common .NET ports. | Add `"forwardPorts": [5000, 5001]`. | Amos |
| 57 | Low | Workflow | `ubuntu-latest` runner could drift to a new OS version. | Pin to `ubuntu-24.04`. | Amos |
| 58 | Low | DevContainer | `--security-opt=label=disable` disables SELinux labelling without documentation. | Add comment explaining Podman compatibility rationale. | Drummer |
| 59 | Low | Workflow | No `timeout-minutes` or concurrency group on publish jobs. | Add `timeout-minutes: 15` and a concurrency group. | Drummer |
| 60 | Low | Workflow | Token embedded in clone URL stored in `.git/config`. | Use `git config` credential helper instead. | Drummer |
| 61 | Low | copilot-instructions | Threat modelling referenced with no methodology. | Add STRIDE reference and Microsoft Threat Modeling Tool link. | Drummer | **Resolved** — `security-review-core` skill encodes trust-boundary analysis and STRIDE-aligned review methodology. Referenced from `## Skills` section in `copilot-instructions.md`. |
| 62 | Low | Compliance | HIPAA Physical Safeguards not a primary section. De-identification methods not detailed. | Add Physical Safeguards section. Detail Safe Harbor vs Expert Determination. | Drummer |

---

## 8. Proposed Next Steps

1. **Fix MCP package names in `base/.copilot/mcp-config.json` and `overlays/blazor/.copilot/mcp-config.json`.** Replace `@anthropic/github-mcp-server` with `@modelcontextprotocol/server-github` and `@anthropic/playwright-mcp-server` with `@playwright/mcp`. Pin both to specific versions. This unblocks all MCP tooling for every user.

2. **Fix the devcontainer for Docker compatibility.** Remove `--userns=keep-id` from `runArgs` and the Podman socket mount from `mounts` in both `base/.devcontainer/devcontainer.json` and `overlays/blazor/.devcontainer/devcontainer.json`. This unblocks Docker Desktop users — the majority of the target audience.

3. **Fix `postCreateCommand` in both devcontainer files.** Extract to `.devcontainer/post-create.sh`. Remove `copilot plugin` commands (move to docs or `postStartCommand`). Wrap `gh extension install` with `|| true`. Pin all package versions. Add `base/global.json` with MTP configuration at the same time.

4. **Rewrite the ISO 27001 compliance skill** using 2022 Annex A themes and control numbers. This is the highest-impact compliance fix — every control number is currently wrong.

5. **Pin all GitHub Actions to full SHAs** in `compose-and-publish.yml` and all four Squad workflows. Add a Dependabot configuration for `github-actions` ecosystem to automate future updates.

---

## 9. Resolution Tracking

*Updated: 2025-07-21 — branch `feature/security-skills-tree`*

| # | Status | Notes |
|---|--------|-------|
| 13 | ⚠️ Partial | `squad-setup` added to `## Skills`. Compliance skills (gdpr/hipaa/pcidss/soc2/iso27001) are opt-in — `first-time-setup` now appends selected skills to `## Skills` when user chooses frameworks. By design they are not pre-listed in base. |
| 24 | ✅ Resolved | Monolithic `security-review` replaced with 10-skill modular security tree (`security-review-core` entry point). All missing .NET-specific checks now covered across dedicated skills. |
| 25 | ⚠️ Partial | Security skill tree provides depth at the skill layer. `## Security Principles` in `copilot-instructions.md` still warrants direct expansion (open). |
| 29 | ✅ Resolved | Blazor overlay restructured: all Blazor skill bullets now extend the base `## Skills` list. `### Skills` subsection under `## Blazor UI` removed. |
| 32 | ✅ Resolved | Step 9 of `first-time-setup` updated — Playwright CLI removed from base skills listing. |
| 61 | ✅ Resolved | `security-review-core` encodes trust-boundary analysis and STRIDE-aligned methodology. Entry point listed in `## Skills`. |

*All other findings remain open.*

---

*Generated by TheSereyn.Templates Squad — Holden, Naomi, Amos, Drummer*
