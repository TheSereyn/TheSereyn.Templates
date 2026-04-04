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
