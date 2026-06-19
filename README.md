# kitr/logger

A lightweight, configurable logger for [Luau](https://luau-lang.org) on [Lune](https://lune-org.github.io). Provides a simple API with leveled logging, ANSI colors, timestamps, and custom sinks.

## Installation

```bash
pesde add kitr/logger
```

## Quick Start

```luau
local Logger = require("path/to/kitr_logger")
Logger.configure({ name = "App", level = "info" })

Logger.info("Hello", "world!")
Logger.warn("Something looks off")
Logger.error("oh my god detected unfunny:", 67)
```

Output:

```ini
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

### Logger Methods

| Method  | Description                    |
| ------- | ------------------------------ |
| `trace` | Log at trace level             |
| `debug` | Log at debug level             |
| `info`  | Log at info level              |
| `warn`  | Log at warn level              |
| `error` | Log at error level             |
| `fatal` | Log at fatal level             |

## Configuration Options

| Option       | Type                           | Default  | Description                     |
| ------------ | ------------------------------ | -------- | ------------------------------- |
| `name`       | `string?`                      | `nil`    | Logger name shown in brackets   |
| `level`      | `LevelName?`                   | `"info"` | Minimum level to log            |
| `colors`     | `boolean?`                     | `false`  | Enable ANSI color codes         |
| `timestamps` | `boolean?`                     | `false`  | Prepend ISO 8601 UTC timestamps |
| `sink`       | `((string, LevelName) -> ())?` | `print`  | Custom output function          |

## Running Tests

```bash
lune run tests/iguessbro.luau
```

## License

MIT &copy; SillyKitr
