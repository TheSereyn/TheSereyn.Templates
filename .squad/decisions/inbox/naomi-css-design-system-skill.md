# Decision: CSS Design System Skill for Blazor Template

**By:** Naomi (Template Engineer)
**Date:** 2026-04-06
**Status:** Completed

## Decision

Created a new `css-design-system` skill at `overlays/blazor/.copilot/skills/css-design-system/SKILL.md` that provides CSS architecture guidance for Blazor projects. Updated the existing `blazor-architecture` skill with a CSS Architecture section cross-referencing the new skill.

## Architecture

**Design Tokens + CUBE CSS + Blazor CSS Isolation** — three pillars:

1. Design Tokens — all design values as CSS custom properties in `_tokens.css`
2. CUBE CSS — global CSS in `@layer`-ordered files (compositions, utilities)
3. Blazor CSS Isolation — every component has a `.razor.css` file referencing tokens

## Key Decisions (Lee-approved, autonomous)

- **Dark theme:** Included using `oklch()` + `color-mix()` + `[data-theme="dark"]` with `prefers-color-scheme` as initial default
- **Colour palette:** Neutral defaults — projects customise tokens, no baked-in brand
- **Accessibility:** WCAG 2.1 AA baseline with contrast ratio guidance and `prefers-reduced-motion`
- **Animations:** `prefers-reduced-motion` included in accessibility section

## Scope

The skill is AI guidance (same pattern as `tunit-testing`, `stylecop-compliance`), not a deployable CSS framework. It does not prescribe importing Bootstrap, Tailwind, or any external library.

## Changes

- `overlays/blazor/.copilot/skills/css-design-system/SKILL.md` — new skill (14 sections)
- `overlays/blazor/.copilot/skills/blazor-architecture/SKILL.md` — added CSS Architecture section + reference link
