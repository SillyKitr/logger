-- Types for developers
export type LevelName = "trace" | "debug" | "info" | "warn" | "error" | "fatal" | "off"
export type Sink = (line: string, level: LevelName) -> ()

export type Options = {
	name: string?,
	level: LevelName?,
	timestamps: boolean?,
	colors: boolean?,
	sink: Sink?,
}

export type Logger = {
	setLevel: (self: Logger, level: LevelName) -> (),
	getLevel: (self: Logger) -> LevelName,
	isLevelEnabled: (self: Logger, level: LevelName) -> boolean,
	trace: (self: Logger, ...any) -> (),
	debug: (self: Logger, ...any) -> (),
	info: (self: Logger, ...any) -> (),
	warn: (self: Logger, ...any) -> (),
	error: (self: Logger, ...any) -> (),
	fatal: (self: Logger, ...any) -> (),
}

-- Higher values mean more important messages.
local LEVEL_VALUES = {
	trace = 10,
	debug = 20,
	info = 30,
	warn = 40,
	error = 50,
	fatal = 60,
	off = math.huge,
}

local LEVEL_COLORS = {
	trace = "\27[38;5;244m",
	debug = "\27[38;5;117m",
	info = "\27[38;5;120m",
	warn = "\27[38;5;221m",
	error = "\27[1;31m",
	fatal = "\27[38;5;135m",
}

local RESET = "\27[0m"

local LoggerModule = {}
LoggerModule.__index = LoggerModule

local function defaultSink(line: string)
	print(line)
end

local function parseLevel(level: LevelName): LevelName
	local normalized = string.lower(level) :: LevelName

	if LEVEL_VALUES[normalized] == nil then
		error(string.format("invalid log level '%s'", tostring(level)), 3)
	end

	return normalized
end

local function stringify(...: any): string
	local count = select("#", ...)
	local parts = table.create(count)

	for index = 1, count do
		parts[index] = tostring(select(index, ...))
	end

	return table.concat(parts, " ")
end

local function timestamp(): string
	return os.date("!%Y-%m-%dT%H:%M:%SZ")
end

local function buildLine(self, level: LevelName, message: string): string
	local parts = {}

	if self._timestamps then
		table.insert(parts, string.format("[%s]", timestamp()))
	end

	if self._name ~= nil and self._name ~= "" then
		table.insert(parts, string.format("[%s]", self._name))
	end

	table.insert(parts, string.format("[%s]", string.upper(level)))

	local line = table.concat(parts, " ")
	if message ~= "" then
		line ..= " " .. message
	end

	if self._colors then
		local color = LEVEL_COLORS[level]
		if color ~= nil then
			line = color .. line .. RESET
		end
	end

	return line
end

function LoggerModule:setLevel(level: LevelName)
	local parsedLevel = parseLevel(level)

	self._levelName = parsedLevel
	self._levelValue = LEVEL_VALUES[parsedLevel]
end

function LoggerModule:getLevel(): LevelName
	return self._levelName
end

function LoggerModule:isLevelEnabled(level: LevelName): boolean
	return LEVEL_VALUES[parseLevel(level)] >= self._levelValue
end

function LoggerModule:_log(level: LevelName, ...: any)
	if not self:isLevelEnabled(level) then
		return
	end

	self._sink(buildLine(self, level, stringify(...)), level)
end

-- QoL: use only the module instead of going through hell.
function LoggerModule:trace(...: any)
	self:_log("trace", ...)
end

function LoggerModule:debug(...: any)
	self:_log("debug", ...)
end

function LoggerModule:info(...: any)
	self:_log("info", ...)
end

function LoggerModule:warn(...: any)
	self:_log("warn", ...)
end

function LoggerModule:error(...: any)
	self:_log("error", ...)
end

function LoggerModule:fatal(...: any)
	self:_log("fatal", ...)
end

local Logger = {}

Logger.Level = {
	Trace = "trace",
	Debug = "debug",
	Info = "info",
	Warn = "warn",
	Error = "error",
	Fatal = "fatal",
	Off = "off",
}

function Logger.new(options: Options?): Logger
	local opts = options or {} :: Options

	local self = setmetatable({
		_name = opts.name,
		_timestamps = if opts.timestamps == nil then false else opts.timestamps,
		_colors = if opts.colors == nil then false else opts.colors,
		_sink = opts.sink or defaultSink,
		_levelName = "info" :: LevelName,
		_levelValue = LEVEL_VALUES.info,
	}, LoggerModule)

	self:setLevel(opts.level or "info")

	return self :: any
end

local defaultLogger = Logger.new()

-- QoL: I don't know why am I doing the exact same thing here but it's nice
function Logger.configure(options: Options?): Logger
	defaultLogger = Logger.new(options)
	return defaultLogger
end

function Logger.setLevel(level: LevelName)
	defaultLogger:setLevel(level)
end

function Logger.getLevel(): LevelName
	return defaultLogger:getLevel()
end

function Logger.trace(...: any)
	defaultLogger:trace(...)
end

function Logger.debug(...: any)
	defaultLogger:debug(...)
end

function Logger.info(...: any)
	defaultLogger:info(...)
end

function Logger.warn(...: any)
	defaultLogger:warn(...)
end

function Logger.error(...: any)
	defaultLogger:error(...)
end

function Logger.fatal(...: any)
	defaultLogger:fatal(...)
end

return Logger
