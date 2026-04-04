# Work Routing

How to decide who handles what.

## Routing Table

| Work Type | Route To | Examples |
|-----------|----------|----------|
| Scope decisions, base vs overlay strategy, new template design | Holden | "Should this go in base or overlay?", "Design the gRPC template", "What's the plan for v2?" |
| PR review, approval gates | Holden | "Review this PR", "Is this ready to ship?" |
| Issue triage | Holden | `squad` label applied → Holden reads issue, assigns `squad:{member}` label |
| Template content: skills, copilot-instructions, prompts | Naomi | "Update the TUnit skill", "Add a new compliance framework skill", "Improve the copilot-instructions.md" |
| Template content: build config, Directory.Build.props, stylecop.json | Naomi | "Bump StyleCop version", "Add a new analyzer", "Update .NET version in build props" |
| Template content: README files, overlay design | Naomi | "Write the README for the new template", "Update the base README" |
| Composition script, compose.sh | Amos | "Fix the append logic", "Add versioning to compose.sh", "Debug why output is missing files" |
| GitHub Actions workflows | Amos | "Update compose-and-publish.yml", "Fix the guard job", "Add a preview workflow" |
| DevContainer, MCP config, VS Code settings | Amos | "Add a new tool to devcontainer", "Update MCP servers", "Add a VS Code extension" |
| New template onboarding | Amos | "Add a gRPC template", "Wire up the new downstream repo" |
| Security skill review | Drummer | "Review the GDPR skill", "Audit security-review SKILL.md", "Check the new auth patterns" |
| Security audit of copilot-instructions.md | Drummer | "Review the OAuth section", "Check PII logging guidance" |
| Quality gate on any security-adjacent content | Drummer | Any change touching auth, secrets, CORS, HTTPS, compliance |
| Session logging | Scribe | Automatic — always runs after substantial work |
| Work queue, backlog monitoring | Ralph | "Ralph, go", "What's on the board?", "Keep working" |

## Issue Routing

| Label | Action | Who |
|-------|--------|-----|
| `squad` | Triage: analyze issue, assign `squad:{member}` label | Lead |
| `squad:{name}` | Pick up issue and complete the work | Named member |

### How Issue Assignment Works

1. When a GitHub issue gets the `squad` label, the **Lead** triages it — analyzing content, assigning the right `squad:{member}` label, and commenting with triage notes.
2. When a `squad:{member}` label is applied, that member picks up the issue in their next session.
3. Members can reassign by removing their label and adding another member's label.
4. The `squad` label is the "inbox" — untriaged issues waiting for Lead review.

## Rules

1. **Eager by default** — spawn all agents who could usefully start work, including anticipatory downstream work.
2. **Scribe always runs** after substantial work, always as `mode: "background"`. Never blocks.
3. **Quick facts → coordinator answers directly.** Don't spawn an agent for "what port does the server run on?"
4. **When two agents could handle it**, pick the one whose domain is the primary concern.
5. **"Team, ..." → fan-out.** Spawn all relevant agents in parallel as `mode: "background"`.
6. **Anticipate downstream work.** If a feature is being built, spawn the tester to write test cases from requirements simultaneously.
7. **Issue-labeled work** — when a `squad:{member}` label is applied to an issue, route to that member. The Lead handles all `squad` (base label) triage.
