
## Blazor UI

This project includes Blazor UI project(s) and Razor Class Libraries (RCLs) for reusable components.

### Blazor Hosting Model

The hosting model must be decided **per feature** — this is an ask-first trigger. Do not assume Server or WASM without confirming requirements.

### UI Architecture Rules

- UI depends only on the Application layer (via API for WASM, direct for Server)
- Share DTOs/contracts only between API and WASM client — never domain types
- Put reusable UI in Razor Class Libraries (RCLs)
- Minimise JavaScript interop

### Skills

- `blazor-architecture` — Hosting model guidance, multi-frontend patterns, RCL strategy, performance, state management

## Playwright

Playwright CLI ([microsoft/playwright-cli](https://github.com/microsoft/playwright-cli)) is installed globally via `@playwright/cli` with skills registered for this agent.
Use `playwright-cli --help` for available commands. Browser binaries and OS dependencies are pre-installed via `npx playwright install --with-deps`.
