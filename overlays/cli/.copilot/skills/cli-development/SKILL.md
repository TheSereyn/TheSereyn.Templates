---
name: "cli-development"
description: "CLI application development patterns — System.CommandLine parsing, Spectre.Console output, command architecture, testing, exit codes, and alternative packages"
---

# CLI Development

## System.CommandLine — Argument Parsing

System.CommandLine is the Microsoft-maintained library for command-line parsing in .NET. It handles argument parsing, command routing, help generation, tab completion, and middleware.

**Package:** `System.CommandLine` (MIT, Microsoft-maintained)
**Docs:** [Microsoft Learn — System.CommandLine](https://learn.microsoft.com/dotnet/standard/commandline/)

### Core Concepts

| Concept | Class | Purpose |
|---------|-------|---------|
| Root command | `RootCommand` | Entry point — represents the application itself |
| Subcommand | `Command` | A verb or action the user invokes |
| Option | `Option<T>` | Named parameter (`--name value`, `-n value`) |
| Argument | `Argument<T>` | Positional parameter |
| Action | `SetAction()` | Delegate invoked when a command is parsed |

### Single-Command Pattern

For simple CLIs with one action:

```csharp
using System.CommandLine;

Option<FileInfo> inputOption = new("--input", "-i")
{
    Description = "Input file to process",
    Required = true
};

Option<bool> verboseOption = new("--verbose", "-v")
{
    Description = "Show verbose output"
};

RootCommand rootCommand = new("Tool description goes here")
{
    inputOption,
    verboseOption
};

rootCommand.SetAction(parseResult =>
{
    FileInfo input = parseResult.GetValue(inputOption)!;
    bool verbose = parseResult.GetValue(verboseOption);
    // Command logic here
    return 0;
});

return rootCommand.Parse(args).Invoke();
```

### Multi-Command Pattern

For CLIs with subcommands:

```csharp
using System.CommandLine;

// Global option — available to all subcommands
Option<bool> verboseOption = new("--verbose", "-v")
{
    Description = "Show verbose output",
    Recursive = true
};

RootCommand rootCommand = new("Multi-command CLI tool");
rootCommand.Options.Add(verboseOption);

// Subcommands
Command listCommand = new("list", "List all items");
Command addCommand = new("add", "Add a new item");

Argument<string> nameArgument = new("name")
{
    Description = "Name of the item to add"
};
addCommand.Arguments.Add(nameArgument);

rootCommand.Subcommands.Add(listCommand);
rootCommand.Subcommands.Add(addCommand);

listCommand.SetAction(parseResult =>
{
    bool verbose = parseResult.GetValue(verboseOption);
    // List logic
    return 0;
});

addCommand.SetAction(parseResult =>
{
    string name = parseResult.GetValue(nameArgument)!;
    // Add logic
    return 0;
});

return rootCommand.Parse(args).Invoke();
```

### Async Commands

For commands that perform I/O:

```csharp
rootCommand.SetAction(async (parseResult, cancellationToken) =>
{
    FileInfo input = parseResult.GetValue(inputOption)!;
    await ProcessFileAsync(input, cancellationToken);
    return 0;
});

return await rootCommand.Parse(args).InvokeAsync();
```

### Custom Validation

Use custom parse delegates for complex validation:

```csharp
Option<FileInfo> fileOption = new("--file")
{
    Description = "An existing file to process",
    CustomParser = result =>
    {
        string? filePath = result.Tokens.SingleOrDefault()?.Value;
        if (filePath is null)
        {
            result.AddError("File path is required");
            return null!;
        }

        FileInfo file = new(filePath);
        if (!file.Exists)
        {
            result.AddError($"File does not exist: {filePath}");
            return null!;
        }

        return file;
    }
};
```

### Key API Summary

| API | Purpose |
|-----|---------|
| `RootCommand` | Application entry point command |
| `Command` | Named subcommand |
| `Option<T>` | Named parameter with typed value |
| `Argument<T>` | Positional parameter with typed value |
| `command.SetAction(parseResult => ...)` | Sync action handler |
| `command.SetAction(async (parseResult, ct) => ...)` | Async action handler |
| `parseResult.GetValue(option)` | Retrieve parsed value by symbol reference |
| `parseResult.GetValue<T>("--name")` | Retrieve parsed value by name |
| `rootCommand.Parse(args).Invoke()` | Parse and invoke (sync) |
| `rootCommand.Parse(args).InvokeAsync()` | Parse and invoke (async) |
| `option.Required = true` | Mark option as required |
| `option.Recursive = true` | Option available to all subcommands |
| `option.AllowMultipleArgumentsPerToken = true` | Accept multiple values |

## Spectre.Console — Rich Terminal Output

Spectre.Console is the .NET Foundation library for rich terminal output. It pairs with System.CommandLine — one handles parsing, the other handles presentation.

**Package:** `Spectre.Console` (MIT, .NET Foundation)
**Docs:** [spectreconsole.net](https://spectreconsole.net/)

### Output Patterns

```csharp
using Spectre.Console;

// Styled markup
AnsiConsole.MarkupLine("[bold green]Success:[/] Operation completed");
AnsiConsole.MarkupLine("[red]Error:[/] {0}", Markup.Escape(userInput));

// Tables
var table = new Table();
table.AddColumn("Name");
table.AddColumn("Status");
table.AddRow("item-1", "[green]Active[/]");
table.AddRow("item-2", "[red]Inactive[/]");
AnsiConsole.Write(table);

// Progress
await AnsiConsole.Progress()
    .StartAsync(async ctx =>
    {
        var task = ctx.AddTask("Processing...");
        while (!ctx.IsFinished)
        {
            await Task.Delay(100);
            task.Increment(10);
        }
    });

// Status spinner
await AnsiConsole.Status()
    .StartAsync("Working...", async ctx =>
    {
        await DoWorkAsync();
        ctx.Status("Almost done...");
        await FinaliseAsync();
    });
```

### Interactive Prompts

```csharp
// Text prompt
string name = AnsiConsole.Ask<string>("What is your [green]name[/]?");

// Confirmation
bool proceed = AnsiConsole.Confirm("Continue?");

// Selection
string choice = AnsiConsole.Prompt(
    new SelectionPrompt<string>()
        .Title("Select an option:")
        .AddChoices("Option A", "Option B", "Option C"));
```

### Non-TTY Safety

Always check for interactive mode before using prompts:

```csharp
if (AnsiConsole.Profile.Capabilities.Interactive)
{
    // Safe to use prompts
    string answer = AnsiConsole.Ask<string>("Input:");
}
else
{
    // Non-interactive — read from stdin or use defaults
    string answer = Console.ReadLine() ?? throw new InvalidOperationException("No input available");
}
```

## Exit Code Conventions

| Code | Meaning | When to use |
|------|---------|-------------|
| `0` | Success | Command completed without errors |
| `1` | General error / usage error | Invalid arguments, missing required options, help requested |
| `2` | Runtime error | Operation failed (file not found, network error, etc.) |
| `130` | Interrupted | User pressed Ctrl+C (`SIGINT`) |

System.CommandLine returns `1` automatically for parse errors and `0` for help/version display.

For custom error exit codes:

```csharp
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
});
```

## Error Output Conventions

- **stdout** — command output (data, results, tables). Must be pipeable.
- **stderr** — errors, warnings, progress, status messages. Use `AnsiConsole.Console` with `new AnsiConsoleSettings { Out = new AnsiConsoleOutput(Console.Error) }` for styled error output.
- Never mix data output with diagnostic output on stdout.

## Testing CLI Commands

### Testing with TUnit

Test command handlers directly, not through `Process.Start()`:

```csharp
using TUnit.Core;

public class ListCommandTests
{
    [Test]
    public async Task ListCommand_WithValidInput_ReturnsZeroExitCode()
    {
        // Arrange
        var rootCommand = BuildRootCommand();

        // Act
        int exitCode = rootCommand.Parse("list").Invoke();

        // Assert
        await Assert.That(exitCode).IsEqualTo(0);
    }

    [Test]
    public async Task ListCommand_WithInvalidOption_ReturnsNonZero()
    {
        // Arrange
        var rootCommand = BuildRootCommand();

        // Act
        int exitCode = rootCommand.Parse("list --invalid").Invoke();

        // Assert
        await Assert.That(exitCode).IsNotEqualTo(0);
    }
}
```

### Testing Console Output

Capture Spectre.Console output using `TestConsole`:

```csharp
using Spectre.Console.Testing;

[Test]
public async Task Command_WritesExpectedOutput()
{
    // Arrange
    var console = new TestConsole();

    // Act
    RunCommandWithConsole(console);

    // Assert
    string output = console.Output;
    await Assert.That(output).Contains("Expected text");
}
```

### Testing Patterns

- Test command handlers as units — extract logic from `SetAction` into testable methods
- Test parse results: `rootCommand.Parse("--file test.txt")` returns `ParseResult` for assertions
- Test exit codes for each error path
- Test with and without interactive TTY
- Test stdin piping if the command supports it

## Alternative Packages

The default stack is System.CommandLine + Spectre.Console. These alternatives are documented for teams with different requirements:

### Spectre.Console.Cli

**When to choose:** Multi-command CLIs where you want a single package for both parsing and rich output with a unified API.

**Trade-off:** Steps away from the Microsoft-maintained parser. For projects that need System.CommandLine middleware extensibility or close BCL alignment, stick with the default stack.

**Package:** `Spectre.Console.Cli` (MIT, .NET Foundation)

### CliFx

**When to choose:** Attribute-based command routing with minimal binary size and Native AOT compatibility.

**Trade-off:** Single-maintainer project — verify current activity before adopting. Smaller community.

**Package:** `CliFx` (MIT)

### Terminal.Gui

**When to choose:** Full terminal UI applications (dashboards, configuration wizards, database browsers) — persistent event-driven interface, not command-parse-output cycle.

**Trade-off:** Fundamentally different paradigm from standard CLI apps. v2 rewrite in development.

**Package:** `Terminal.Gui` (MIT)

### Explicitly Not Recommended

**Cocona** — Archived December 2025. No further updates, bug fixes, or security patches. Do not adopt for new projects.

## Anti-Patterns

- **No interactive prompts in piped mode.** Always check `AnsiConsole.Profile.Capabilities.Interactive` or detect non-TTY stdin before prompting.
- **No secrets on the command line.** Arguments are visible in process listings. Use environment variables or credential stores.
- **No raw `Console.WriteLine` for structured output.** Use Spectre.Console for styled output or `System.Text.Json` for machine-readable output.
- **No swallowed exceptions.** Every error path must produce a non-zero exit code and a diagnostic message on stderr.
- **No `Environment.Exit()` in library code.** Return exit codes from command actions; let the host decide when to exit.

## References

- [System.CommandLine — Microsoft Learn](https://learn.microsoft.com/dotnet/standard/commandline/)
- [System.CommandLine Tutorial](https://learn.microsoft.com/dotnet/standard/commandline/get-started-tutorial)
- [Spectre.Console — Official Documentation](https://spectreconsole.net/)
- [.NET Console Apps — Microsoft Learn](https://learn.microsoft.com/dotnet/core/tutorials/with-visual-studio-code)
