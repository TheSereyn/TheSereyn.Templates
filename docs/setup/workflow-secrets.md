# Workflow Secrets Setup

## TEMPLATE_PUSH_TOKEN

The `compose-and-publish.yml` workflow requires a `TEMPLATE_PUSH_TOKEN` secret to push composed templates to downstream repositories.

### Required Scope

The token must have the following permissions on each downstream repository:
- **Contents: Write** — to push commits and tags

### Setup

**Option 1: Personal Access Token (Current)**

1. Go to GitHub Settings → Developer Settings → Personal Access Tokens → Fine-grained tokens
2. Click "Generate new token"
3. Set expiration (90 days recommended; set a calendar reminder to rotate)
4. Set resource owner to your organisation or account
5. Under "Repository access", select only the downstream template repositories:
   - `TheSereyn/TheSereyn.Templates.MinimalApi`
   - `TheSereyn/TheSereyn.Templates.Blazor`
6. Under "Repository permissions", grant **Contents: Read and write**
7. Copy the token
8. In this repository: Settings → Secrets and Variables → Actions → New repository secret
9. Name: `TEMPLATE_PUSH_TOKEN`, Value: (paste the token)

**Security note:** This PAT is tied to a user account. If the account owner leaves, the token breaks. Consider migrating to a GitHub App for organisation-level resilience (Option 2).

**Option 2: GitHub App (Recommended for teams)**

A GitHub App scoped to specific repositories eliminates the user dependency:

1. Create a GitHub App in your organisation settings
2. Grant it "Contents: Write" permission on downstream repos
3. Generate an installation access token in the workflow using the `actions/create-github-app-token` action
4. Replace `TEMPLATE_PUSH_TOKEN` references with the app-generated token

### Token Rotation

Set a reminder to rotate the PAT before it expires. An expired token produces a cryptic `403` error in the workflow. The pre-flight check at the start of `compose-and-publish.yml` will fail with a clear error message if the secret is missing, but not if it has expired.
