
## Web Stack

| Layer | Technology |
|-------|-----------|
| **API** | ASP.NET Core Minimal APIs, REPR pattern |
| **Architecture** | Clean Architecture (modular monolith or microservices) |

## HTTP/REST Standards

- **HTTP/REST:** RFC 9205 (Building Protocols with HTTP), RFC 9110 (HTTP Semantics), RFC 3986 (URI), RFC 9457 (Problem Details)
- **IETF HTTPAPI WG:** Rate limiting, idempotency-key, etc.

## Web Security

- **Authentication:** OAuth/OIDC with PKCE for public clients; consider DPoP where elevated token binding is required. Use `[Authorize]` attributes and policies — never rely on client-side checks alone.
- **CORS:** Never use `AllowAnyOrigin()` in production. Enumerate allowed origins explicitly. `AllowAnyOrigin` with `AllowCredentials` is rejected by browsers and is a CORS misconfiguration.
- **Security headers:** Apply all of the following in middleware or reverse proxy:
  - `Strict-Transport-Security` (HSTS) — enforce HTTPS
  - `Content-Security-Policy` — restrict resource sources
  - `X-Content-Type-Options: nosniff` — prevent MIME sniffing
  - `X-Frame-Options: DENY` or CSP `frame-ancestors` — prevent clickjacking
  - `Referrer-Policy: strict-origin-when-cross-origin`
  - `Permissions-Policy` — restrict browser features
- **Input validation (web):** Use model binding validation attributes (`[Required]`, `[MaxLength]`, `[RegularExpression]`). Do not trust client-supplied identifiers without ownership checks.
- **Output encoding (web):** HTML-encode all user-supplied content rendered in HTML. Use `HttpUtility.HtmlEncode` or Razor's automatic encoding.
- **CSRF protection:** Enable ASP.NET Core antiforgery for state-changing form submissions. APIs using JWT bearer authentication are inherently CSRF-resistant (no cookies) — but cookie-authenticated APIs must enforce antiforgery.
- **Rate limiting:** Apply `RateLimiter` middleware for all public endpoints. Use `AddRateLimiter` / `RequireRateLimiting` in ASP.NET Core 7+.
- **EF Core logging:** Set `EnableSensitiveDataLogging(false)` in EF Core production config.
- **OWASP:** Consult API Security Top 10 (2023) for API-specific threat categories.

## Web Observability — ASP.NET Core

### Standard Setup Pattern

```csharp
builder.Services.AddOpenTelemetry()
    .ConfigureResource(r => r.AddService(
        serviceName: builder.Environment.ApplicationName,
        serviceVersion: Assembly.GetExecutingAssembly()
                                .GetCustomAttribute<AssemblyInformationalVersionAttribute>()
                                ?.InformationalVersion ?? "unknown"))
    .WithTracing(tracing => tracing
        .AddAspNetCoreInstrumentation()
        .AddHttpClientInstrumentation()
        .AddOtlpExporter())
    .WithMetrics(metrics => metrics
        .AddAspNetCoreInstrumentation()
        .AddHttpClientInstrumentation()
        .AddRuntimeInstrumentation()
        .AddOtlpExporter())
    .WithLogging(logging => logging
        .AddOtlpExporter());
```

### Health Checks

- Health checks at `/health`, `/health/live`, `/health/ready`
- **Correlation:** `TraceId`, `SpanId`, `CorrelationId` on all log entries

## Web Delivery Additions

- Include **OpenAPI/Swagger** documentation updates with every endpoint change

## Web Ask-First Triggers

Copilot must also clarify before coding if any of these are unclear:

- Auth provider configuration (OIDC authority, flows, scopes)
- Persistence technology and partitioning strategy
- Messaging/eventing approach
- API versioning policy
- Middleware ordering (auth, CORS, rate limiting)

## Web Micro-Checklists

- **REST:** Status codes + ProblemDetails + validation + versioning + auth + OpenAPI
- **Auth:** Authz enforced, tokens validated, CORS configured

## Additional Skills

### Code Quality and Conventions (Web)
- `rfc-compliance` — HTTP/REST RFC standards checking (9205, 9110, 3986, 9457)

### Security (Web)
- `dotnet-authn-authz` — ASP.NET Core auth/authz, claims, policies, token and cookie review
- `aspnetcore-api-security` — Middleware ordering, CORS, antiforgery, input validation, exception handling
- `browser-security-headers` — CSP, HSTS, COEP/CORP/COOP, cross-origin isolation
