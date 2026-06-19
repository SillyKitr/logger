# kitr/logger

A lightweight, configurable logger for [Luau](https://luau-lang.org) on [Lune](https://lune-org.github.io). Provides a simple API with leveled logging, ANSI colors, timestamps, and custom sinks.

## Getting started

```bash
pesde add kitr/logger
```

### Example Usage
```luau
-- Example usage of this.
local Logger = require("../src")
local log = Logger.new({
        name = "Example",
        level = "trace",
		colors = true,
})

log:trace("This is a trace!")
log:debug("wow")
log:info("Who cares anyways?")
log:warn("mrrrp?")

-- // loops or whatever?
for i = 5,1,-1 do
    log:error("Bullshit spotted in davenport, iowa")
end

log:fatal("It's joever.")
```
Script [here](https://github.com/SillyKitr/logger/tree/master/examples) by the way
Output:

```ini
[example] [TRACE] This is a trace!
[example] [DEBUG] wow
[example] [INFO] Who cares anyways?
[example] [WARN] mrrrp?
[example] [ERROR] Bullshit spotted in davenport, iowa
[example] [ERROR] Bullshit spotted in davenport, iowa
[example] [ERROR] Bullshit spotted in davenport, iowa
[example] [ERROR] Bullshit spotted in davenport, iowa
[example] [ERROR] Bullshit spotted in davenport, iowa
[example] [FATAL] It's joever.
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