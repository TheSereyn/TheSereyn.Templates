# Drummer — History

## Core Context

**Project:** TheSereyn.Templates — composition workspace for .NET project templates.
**User:** Lee Buxton
**Team:** Holden (Lead), Naomi (Template Engineer), Amos (Platform Engineer), Drummer (Security Reviewer), Scribe, Ralph

**My domain — security and quality review:**
- Security skills in `base/.github/copilot/skills/`: compliance-gdpr, compliance-hipaa, compliance-pcidss, compliance-soc2, compliance-iso27001, security-review, security-register
- Security principles in `base/.github/copilot-instructions.md`: OAuth/OIDC, HTTPS, CORS, security headers, PKCE, no PII logging, no secrets in code, OWASP Top 10
- Any overlay content that touches authentication, authorization, or secrets handling

**Review triggers (always involve me):**
- Changes to any security skill SKILL.md
- Changes to security sections of copilot-instructions.md
- New compliance framework additions
- Any content touching OAuth, OIDC, secrets, PII, CORS, or HTTPS enforcement

**Rejection protocol:**
- Rejected work is locked out from the original author
- I name a different agent for the revision
- I state the exact violation and the correct approach

## Learnings

- Session 1 (2026-04-04): Team initialized. I am the security and quality gate.

- Session 2 (2026-04-04): Conducted comprehensive security and compliance review.
  - Found 20 security findings, 1 Critical
  - Critical 1: ISO 27001 skill uses superseded 2013 control numbering (shared with Naomi)
  - ISO 27001:2022 restructured Annex A (4 themes, 93 controls vs. old 14 domains, 114 controls)
  - 11 new controls added in 2022 (e.g., A.5.7 Threat Intelligence, A.8.9 Configuration Management)
  - GitHub Actions supply chain risk: `actions/checkout@v4` and `actions/github-script@v7` pinned to mutable tags
  - TEMPLATE_PUSH_TOKEN is PAT, user-scoped, undocumented — bus factor risk
  - PostCreateCommand has no version pinning: `@latest`, `npx -y` allow arbitrary package injection
  - Recommend: Pin all actions to commit SHAs, replace PAT with GitHub App token, update ISO skill to 2022 controls
  - All compliance skills require audit against current standard frameworks

- Session 3 (2026-04-05): Security review of prompt split (pre-container-setup + revised first-time-setup).
  - APPROVED — both files follow secure practices
  - `gh auth login` uses interactive OAuth flow with Dev Containers credential forwarding — no manual token handling
  - Git identity uses `--global` with placeholder examples — standard for developer workstations, acceptable PII
  - Clone step uses HTTPS with placeholder URLs — safe
  - Security Setup step (first-time-setup Step 9) is a net positive: .gitignore verification, user-secrets init, secret scanning, branch protection
  - Pre-existing post-create.sh version pinning concern remains (tracked from Session 2, not introduced by these prompts)
  - Developer-facing prompts should never instruct storing credentials in project files — verified clean

- Session 4 (2026-04-04T17:49:01Z): Scribe closed prompt-split phase.
   - Naomi's implementation approved — both prompts follow secure practices
   - Holden approved spec compliance — no changes required
   - Orchestration log created and archived
   - Inbox decisions merged to decisions.md

- Session 5 (2026-04-08): Security review of Spec Kit integration on `dev`.
  - APPROVED — Spec Kit integration follows reasonable security posture for enterprise templates
  - Spec Kit CLI install pinned to `v0.5.0` via Git tag — good supply chain practice
  - Source is GitHub-owned (`github/spec-kit`) — trusted origin
  - `uv` installed via pip (not `curl | sh`) as primary path — safe
  - No secrets, credentials, or insecure auth patterns introduced
  - Security Setup step preserved and renumbered (now Step 11)
  - Non-blocking: F1 — version inconsistency (`@latest` in init vs `v0.5.0` in install) is the top recommendation
  - Non-blocking: F2 — `curl | sh` fallback for uv documented but flaggable by enterprise security
  - Non-blocking: F3 — `uv` pip install not version-pinned
  - Non-blocking: F4 — Git tag is mutable; commit SHA would be stronger
  - Pre-existing unpinned installs (squad-cli, playwright, msdocs skills) remain from Session 2
  - Decision written to `.squad/decisions/inbox/drummer-spec-kit-review.md`

- Session 9 (2026-04-08): Spec Kit batch 2 — Revised artifacts re-review.
   - APPROVED revised artifacts per Amos reassignment from Holden lockout.
   - Issue 1 (Version pinning `@latest` → v0.5.0): RESOLVED ✅
     - `first-time-setup.prompt.md` Step 10 now uses `specify init --here --ai copilot` (pre-installed binary)
     - `spec-driven-development/SKILL.md` primary path uses pre-installed binary; standalone alternative correctly pinned to `@v0.5.0`
     - All three artifacts (post-create.sh, prompt, SKILL.md) now reference consistent v0.5.0 version. No `@latest` appears.
   - Issue 2 (curl | sh fallback removed): RESOLVED ✅
     - `first-time-setup.prompt.md` fallback now `python3 -m pip install --user uv` with PATH export
     - `spec-driven-development/SKILL.md` Prerequisites uses `pip install uv`, no curl | sh
     - Full base/ sweep: `grep -rn 'curl.*|.*sh'` returns zero — pattern eliminated project-wide
   - Security posture intact — no new concerns introduced
   - Orchestration log written: 2026-04-08T10:17:21Z-drummer.md
   - Decision entry merged to decisions.md (decision summary section)
