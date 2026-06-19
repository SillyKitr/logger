# kitr/logger

A lightweight, configurable logger for [Luau](https://luau-lang.org) on [Lune](https://lune-org.github.io).

Features: leveled logging, ANSI colors, timestamps, custom sinks, and a simple API.

## Installation

```bash
pesde add kitr/logger
```

## Usage

```luau
local Logger = require("kitr/logger")
local log = Logger.new({
    name = "Example",
    level = "debug",
    colors = true,
})

log:info("Hello, world!")
log:warn("This is a warning")
log:error("Something went wrong")
```

See [examples](examples/) for more detailed usage.

## API Reference

Full API documentation is available in the [wiki](https://github.com/SillyKitr/logger/wiki).
By the way; this project is compatible with [Zune](https://github.com/Scythe-Technology/zune) too!

## Testing

```bash
lune run tests/iguessbro.luau
```

## License

[MIT](LICENSE)