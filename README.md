# kitr/logger

A lightweight, configurable logger for [Luau](https://luau-lang.org) on [Lune](https://lune-org.github.io). Provides a simple API with leveled logging, ANSI colors, timestamps, and custom sinks.

## Installation

```bash
pesde add kitr/logger
```

## Quick Start

```luau
local Logger = require("@pkg/kitr_logger")

Logger.configure({ name = "App", level = "info" })

Logger.info("Hello", "world!")
Logger.warn("Something looks off")
Logger.error("oh my god detected unfunny:", 67)
```

```md
[App] [INFO] Hello world!
[App] [WARN] Something looks off
[App] [ERROR] oh my god detected unfunny: 67
```

## API

### Creating a Logger

```lua
local log = Logger.new({
    name = "Server",        -- optional, shown in brackets
    level = "debug",        -- "trace" | "debug" | "info" | "warn" | "error" | "fatal"
    colors = true,          -- enable ANSI color output
    timestamps = true,      -- prepend UTC timestamps
    sink = function(line, level)  -- custom output (default: print)
        io.write(line, "\n")
    end,
})
```

### Logging

```lua
log:trace("verbose detail")
log:debug("debug info")
log:info("general info")
log:warn("warning")
log:error("error")
log:fatal("fatal error")
```

Multiple arguments are space-joined automatically.

### Level Management

```lua
log:getLevel()               -- returns current level name
log:setLevel("warn")         -- change level at runtime
log:isLevelEnabled("debug")  -- check if a level would be logged
```

### Default Logger (Module-Level)

Use the module directly as a singleton:

```lua
Logger.configure({ name = "App", level = "warn" })
Logger.info("hidden")        -- filtered out
Logger.warn("visible")
Logger.getLevel()            -- "warn"
Logger.setLevel("trace")
```

## Configuration Options

| Option      | Type                          | Default   | Description                        |
|-------------|-------------------------------|-----------|------------------------------------|
| `name`      | `string?`                     | `nil`     | Logger name shown in brackets      |
| `level`     | `LevelName?`                  | `"info"`  | Minimum level to log               |
| `colors`    | `boolean?`                    | `false`   | Enable ANSI color codes            |
| `timestamps`| `boolean?`                    | `false`   | Prepend ISO 8601 UTC timestamps    |
| `sink`      | `((string, LevelName) -> ())?`| `print`   | Custom output function             |

## Levels

| Level   | Value | Color          |
|---------|-------|----------------|
| `trace` | 10    | Gray           |
| `debug` | 20    | Light blue     |
| `info`  | 30    | Green          |
| `warn`  | 40    | Yellow         |
| `error` | 50    | Bold red       |
| `fatal` | 60    | Purple         |

## Running Tests

```bash
lune run tests/iguessbro.luau
```

## License

MIT &copy; SillyKitr
