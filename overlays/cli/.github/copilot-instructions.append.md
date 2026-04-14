
## CLI Stack

| Layer | Technology |
|-------|-----------|
| **Parsing** | System.CommandLine (argument parsing, command routing, middleware) |
| **Output** | Spectre.Console (tables, progress, prompts, styled markup) |
| **Architecture** | Command-handler pattern (one handler per command) |

## CLI Authoritative Sources

- **System.CommandLine:** [Microsoft Learn — System.CommandLine](https://learn.microsoft.com/dotnet/standard/commandline/)
- **Spectre.Console:** [spectreconsole.net](https://spectreconsole.net/)

## CLI Security

- **Argument validation:** Validate all command-line inputs before processing. Use System.CommandLine's built-in validation (custom parse delegates, `Required` property) to reject invalid input at the parsing layer.
- **File path safety:** Validate and canonicalise file paths from user input. Reject path traversal attempts (`..`, absolute paths when relative expected). Use `Path.GetFullPath()` and verify the resolved path is within expected boundaries.
- **Shell injection:** Never pass user-supplied arguments to `Process.Start()` or shell commands without proper escaping. Prefer direct `ProcessStartInfo.ArgumentList` over string concatenation.
- **Credential handling:** CLI apps that accept credentials (API keys, tokens) should prefer environment variables or secure credential stores over command-line arguments. Arguments are visible in process listings (`ps`, Task Manager).
- **Exit codes:** Use conventional exit codes — `0` for success, non-zero for failure. Do not leak internal error details to stderr in production builds.

## CLI Observability

For CLI applications, OpenTelemetry setup uses `Microsoft.Extensions.Hosting` Generic Host or direct SDK configuration:

- Use `ActivitySource` for tracing command execution spans
- Use `Meter` for command invocation counts and duration metrics
- Log to structured output (not just `Console.WriteLine`) — use `ILogger<T>` with `Microsoft.Extensions.Logging`
- CLI-specific: trace each command invocation as a span; record exit codes as span attributes

## CLI Delivery Additions

- Include **`--help` text review** with every command change — help text is the CLI's primary documentation surface
- Include **exit code documentation** for any new failure mode

## CLI Ask-First Triggers

Copilot must also clarify before coding if any of these are unclear:

- Single-command vs multi-command architecture
- Interactive vs non-interactive (piped/scripted) usage
- Output format requirements (human-readable, JSON, CSV, TAB-delimited)
- Global tool packaging (`dotnet tool install`) requirements
- Whether the CLI wraps an API or operates on local resources

## CLI Micro-Checklists

- **CLI UX:** Help text accurate, exit codes correct, stderr for errors, stdout for data
- **Parsing:** All options validated, required options enforced, custom validation where needed
- **Piping:** Supports stdin/stdout piping where appropriate, no interactive prompts in non-TTY mode

## Additional Skills

### CLI Development
- `cli-development` — System.CommandLine patterns, Spectre.Console output, command architecture, testing CLI apps, alternative packages
