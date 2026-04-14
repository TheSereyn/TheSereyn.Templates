---
name: "project-conventions"
description: "Core coding conventions and patterns for .NET CLI projects — error handling, command patterns, code style, naming, async, and testing conventions"
---

# Project Conventions

## Error Handling — Structured Exit Codes

All CLI error conditions produce a non-zero exit code and a diagnostic message on stderr.

| Exit Code | Meaning | Example |
|-----------|---------|---------|
| `0` | Success | Command completed normally |
| `1` | Usage / argument error | Missing required option, invalid argument value |
| `2` | Runtime error | File not found, network failure, permission denied |

**Error output conventions:**

- Errors and warnings go to **stderr** — never stdout
- Data and command results go to **stdout** — must be pipeable
- Use Spectre.Console markup for human-readable error messages: `[red]Error:[/] description`
- For machine-consumable output, write JSON to stdout and diagnostics to stderr

```csharp
// Structured error handling in a command action
rootCommand.SetAction(parseResult =>
{
    try
    {
        RunCommand(parseResult);
        return 0;
    }
    catch (FileNotFoundException ex)
    {
        AnsiConsole.MarkupLine("[red]Error:[/] {0}", Markup.Escape(ex.Message));
        return 2;
    }
    catch (ArgumentException ex)
    {
        AnsiConsole.MarkupLine("[yellow]Usage error:[/] {0}", Markup.Escape(ex.Message));
        return 1;
    }
});
```

**Domain exceptions** (e.g., `ConfigurationException`, `ValidationException`) are caught in the command action and mapped to appropriate exit codes. Do not let unhandled exceptions propagate to the user — always return a meaningful exit code.

## Command Architecture

### Command-Handler Pattern

Separate command definition (parsing) from command logic (handling):

```csharp
// Command definition — parsing concerns only
public static Command CreateExportCommand()
{
    Option<FileInfo> outputOption = new("--output", "-o")
    {
        Description = "Output file path",
        Required = true
    };

    Option<string> formatOption = new("--format", "-f")
    {
        Description = "Output format",
        DefaultValueFactory = _ => "json"
    };

    Command command = new("export", "Export data to a file")
    {
        outputOption,
        formatOption
    };

    command.SetAction(async (parseResult, ct) =>
    {
        FileInfo output = parseResult.GetValue(outputOption)!;
        string format = parseResult.GetValue(formatOption)!;
        return await ExportHandler.ExecuteAsync(output, format, ct);
    });

    return command;
}

// Handler — business logic, testable in isolation
public static class ExportHandler
{
    public static async Task<int> ExecuteAsync(
        FileInfo output,
        string format,
        CancellationToken ct)
    {
        // Implementation
        return 0;
    }
}
```

### Command Organisation

```
src/
├── Commands/
│   ├── Export/
│   │   ├── ExportCommand.cs      # Command definition (options, arguments, wiring)
│   │   └── ExportHandler.cs      # Business logic
│   ├── Import/
│   │   ├── ImportCommand.cs
│   │   └── ImportHandler.cs
│   └── CommandRegistration.cs    # Registers all commands on RootCommand
├── Infrastructure/
│   ├── FileSystem/               # File I/O abstractions
│   └── Configuration/            # App configuration
└── Program.cs                    # Entry point — RootCommand + parse + invoke
```

## Code Style

### Analyzers and Build Configuration

- **StyleCop Analyzers** with standard rules enabled
- **`AnalysisLevel=latest-all`** for maximum coverage
- **`Nullable=enable`** — nullable reference types everywhere
- **`ImplicitUsings=enable`** — implicit global usings
- **`LangVersion=latest`** — latest C# features
- **File-scoped namespaces** — always

### Naming Conventions

| Element | Convention | Example |
|---------|-----------|---------|
| Types, methods, properties, constants | PascalCase | `ExportHandler`, `ExecuteAsync` |
| Local variables, parameters | camelCase | `outputFile`, `cancellationToken` |
| Private fields | _camelCase | `_fileSystem`, `_logger` |
| Interfaces | `I` prefix | `IExportService` |
| Async methods | `Async` suffix | `ExecuteAsync`, `ProcessAsync` |
| Command classes | `{Verb}{Entity}Command` | `ExportDataCommand` |
| Handler classes | `{Verb}{Entity}Handler` | `ExportDataHandler` |

### Guard Clauses

Use `ArgumentNullException.ThrowIfNull` and similar guard methods:

```csharp
public void Process(FileInfo file)
{
    ArgumentNullException.ThrowIfNull(file);
    ArgumentException.ThrowIfNullOrWhiteSpace(file.FullName);
}
```

## Async Patterns

**Async all the way — zero exceptions:**

```csharp
// Correct — async command with cancellation
rootCommand.SetAction(async (parseResult, cancellationToken) =>
{
    return await ProcessAsync(parseResult, cancellationToken);
});

return await rootCommand.Parse(args).InvokeAsync();
```

```csharp
// Prohibited — sync-over-async
var result = ProcessAsync(ct).Result;                    // NEVER
var result = ProcessAsync(ct).Wait();                    // NEVER
var result = ProcessAsync(ct).GetAwaiter().GetResult();  // NEVER
```

All async methods accept `CancellationToken`. Handle `Ctrl+C` gracefully via `Console.CancelKeyPress` or the cancellation token provided by System.CommandLine's async invoke.

## Configuration — Strongly-Typed Options

For CLI apps that need configuration beyond command-line arguments:

```csharp
public sealed class ToolOptions
{
    public const string SectionName = "Tool";
    public string DefaultFormat { get; init; } = "json";
    public int Timeout { get; init; } = 30;
}
```

Config hierarchy (highest wins): Environment vars > `appsettings.json` > defaults.
Env var nesting: double underscore `__` (e.g., `Tool__DefaultFormat`).

For simple CLIs, prefer command-line options over config files. Use config files when defaults need to persist across invocations.

## Testing Conventions

**Framework:** TUnit on Microsoft Testing Platform. See the `tunit-testing` skill for full details.

**Test method naming:** `{Method}_{Scenario}_{ExpectedResult}`

**Test structure:** Arrange-Act-Assert with async TUnit assertions.

**CLI-specific testing patterns:**

- Test command handlers directly (not via `Process.Start()`)
- Test exit codes for each success and failure path
- Test parse results with `rootCommand.Parse("--option value")`
- Capture and assert console output using `Spectre.Console.Testing.TestConsole`
- Test non-interactive (piped) behaviour separately from interactive behaviour

## Observability Conventions

- **OpenTelemetry** for traces, metrics, and logs (OTLP export)
- **Structured logging** — use `ILogger<T>` with `Microsoft.Extensions.Logging`, not `Console.WriteLine` for diagnostics
- **CLI-specific:** Trace each command invocation as a span; record exit codes as span attributes
- **Metrics:** Command invocation counts, duration histograms

## Anti-Patterns

- **No sync-over-async.** `.Result`, `.Wait()`, `.GetAwaiter().GetResult()` are bugs.
- **No PII in logs.** Use opaque identifiers, never emails/names/tokens.
- **No `Environment.Exit()` in library code.** Return exit codes from command actions.
- **No interactive prompts in non-TTY mode.** Always check for interactive capability.
- **No `!` null-forgiving operator** without a documented comment explaining why it's safe.
- **No secrets as command-line arguments.** Use environment variables or credential stores.
- **No mixing data and diagnostics on stdout.** Errors to stderr, data to stdout.

## References

- [System.CommandLine — Microsoft Learn](https://learn.microsoft.com/dotnet/standard/commandline/)
- [Spectre.Console — Official Documentation](https://spectreconsole.net/)
- [OpenTelemetry .NET](https://opentelemetry.io/docs/languages/dotnet/)
