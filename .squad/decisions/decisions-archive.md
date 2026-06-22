# Decisions Archive

Archived entries from decisions.md — older than 30 days (before 2026-03-20).

---

## Decision: Full Setup Shape — Compliance UX Proposal

**By:** Naomi (Template Engineer)  
**Date:** 2026-04-14  
**Status:** Approved — implementation pending  

Proposed 10-step project-setup with security at Step 2 (non-negotiable), compliance at Step 8 (skippable), and dedicated `/compliance-setup` prompt.

Key points: ~4 min to skip, ~6 min to answer, compliance depth moved to dedicated prompt to keep initial setup lean.

---

## Decision: Compliance Scope — Full Setup + Skip-Later Model

**By:** Drummer (Security Reviewer)  
**Date:** 2026-04-14  
**Status:** Approved — implementation pending

Three non-negotiable items in initial setup (~2 min): .gitignore verification, dotnet user-secrets init, branch protection on main.

Compliance question asked but skippable. Detailed framework guidance moved to /compliance-setup (idempotent, standalone, additive, skip-friendly).

