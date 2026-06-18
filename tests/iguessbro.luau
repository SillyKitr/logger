local Logger = require("../src")

local LEVELS = { "trace", "debug", "info", "warn", "error", "fatal" }

local function expect(condition: boolean, message: string)
	if not condition then
		error(message, 2)
	end
end

local function expectEqual(actual: any, expected: any, message: string)
	if actual ~= expected then
		error(string.format("%s: expected %s, got %s", message, tostring(expected), tostring(actual)), 2)
	end
end

local function runTest(name: string, callback: () -> ())
	print(string.format("Running: %s", name))
	callback()
	print(string.format("Passed: %s", name))
end

local function makeSink()
	local entries = {}

	local function sink(line: string, level: string)
		table.insert(entries, {
			line = line,
			level = level,
		})
	end

	return entries, sink
end

local function callLevel(log, level: string, ...: any)
	log[level](log, ...)
end

local function runAllLevels(log, prefix: string)
	for _, level in LEVELS do
		callLevel(log, level, prefix, level)
	end
end

local function testFormatting()
	local entries, sink = makeSink()
	local log = Logger.new({
		name = "Unit",
		level = "trace",
		colors = false,
		sink = sink,
	})

	log:info("hello", 123, true)
	log:info()

	expectEqual(#entries, 2, "formatting should capture two entries")
	expectEqual(entries[1].level, "info", "sink should receive the log level")
	expectEqual(entries[1].line, "[Unit] [INFO] hello 123 true", "message parts should be joined")
	expectEqual(entries[2].line, "[Unit] [INFO]", "empty messages should not leave trailing spaces")

	print(string.format("  captured %d formatted entries", #entries))
	print(string.format("  first line: %s", entries[1].line))
end

local function testFiltering()
	for thresholdIndex, threshold in LEVELS do
		local entries, sink = makeSink()
		local log = Logger.new({
			name = "Filter",
			level = threshold,
			colors = false,
			sink = sink,
		})

		runAllLevels(log, "checking")

		expectEqual(
			#entries,
			#LEVELS - thresholdIndex + 1,
			string.format("%s threshold should filter lower levels", threshold)
		)
		expectEqual(entries[1].level, threshold, string.format("%s threshold should start at itself", threshold))

		print(string.format("  level '%s' captured %d entries", threshold, #entries))
	end

	local entries, sink = makeSink()
	local log = Logger.new({
		level = "off",
		sink = sink,
	})

	runAllLevels(log, "hidden")
	expectEqual(#entries, 0, "off level should hide every message")
	print("  level 'off' captured 0 entries")
end

local function testSetLevel()
	local entries, sink = makeSink()
	local log = Logger.new({
		level = "error",
		colors = false,
		sink = sink,
	})

	expectEqual(log:getLevel(), "error", "getLevel should return the current level")
	expect(not log:isLevelEnabled("warn"), "warn should be disabled at error level")
	expect(log:isLevelEnabled("fatal"), "fatal should be enabled at error level")

	log:warn("hidden")
	log:error("visible")
	expectEqual(#entries, 1, "error threshold should only capture error and above")

	log:setLevel("trace")
	expectEqual(log:getLevel(), "trace", "setLevel should update the current level")

	runAllLevels(log, "visible")
	expectEqual(#entries, 7, "trace threshold should capture all six extra level calls")

	print(string.format("  setLevel changed level to '%s'", log:getLevel()))
	print(string.format("  captured %d entries after changing levels", #entries))
end

local function testColors()
	local entries, sink = makeSink()
	local log = Logger.new({
		name = "Color",
		level = "trace",
		colors = true,
		sink = sink,
	})

	log:info("green")
	log:error("red")

	expectEqual(string.sub(entries[1].line, 1, 11), "\27[38;5;120m", "info logs should be green")
	expectEqual(string.sub(entries[2].line, 1, 7), "\27[1;31m", "error logs should be red")
	expectEqual(string.sub(entries[1].line, -4), "\27[0m", "colored logs should reset the terminal")

	print("  verified info and error ANSI color codes")
end

local function testTimestamps()
	local entries, sink = makeSink()
	local log = Logger.new({
		name = "Clock",
		level = "info",
		timestamps = true,
		colors = false,
		sink = sink,
	})

	log:info("now")

	local pattern = "^%[%d%d%d%d%-%d%d%-%d%dT%d%d:%d%d:%d%dZ%] %[Clock%] %[INFO%] now$"
	expect(entries[1].line:match(pattern) ~= nil, "timestamp should use UTC ISO-like format")

	print(string.format("  timestamp line: %s", entries[1].line))
end

local function testDefaultLogger()
	local entries, sink = makeSink()

	local configured = Logger.configure({
		name = "Default",
		level = "warn",
		colors = false,
		sink = sink,
	})

	Logger.info("hidden")
	Logger.warn("visible")

	expectEqual(configured:getLevel(), "warn", "configure should return the configured default logger")
	expectEqual(Logger.getLevel(), "warn", "default getLevel should read the configured logger")
	expectEqual(#entries, 1, "default logger should respect configured level")
	expectEqual(entries[1].line, "[Default] [WARN] visible", "default logger should format with configured name")

	print(string.format("  default logger level is '%s'", Logger.getLevel()))
	print(string.format("  captured line: %s", entries[1].line))
end

local function testInvalidLevels()
	local log = Logger.new()

	local ok = pcall(function()
		log:setLevel("verbose" :: any)
	end)
	expect(not ok, "setLevel should reject invalid levels")

	ok = pcall(function()
		Logger.new({
			level = "verbose" :: any,
		})
	end)
	expect(not ok, "new should reject invalid levels")

	print("  invalid level checks failed as expected")
end

local function testStress()
	local entries, sink = makeSink()
	local log = Logger.new({
		name = "Stress",
		level = "trace",
		colors = false,
		sink = sink,
	})

	for index = 1, 1_000 do
		local level = LEVELS[((index - 1) % #LEVELS) + 1]
		callLevel(log, level, "message", index)
	end

	expectEqual(#entries, 1_000, "stress test should capture every message")
	expect(entries[1].line:find("message 1", 1, true) ~= nil, "stress test should keep first message text")
	expect(entries[#entries].line:find("message 1000", 1, true) ~= nil, "stress test should keep final message text")

	print(string.format("  stress captured %d entries", #entries))
	print(string.format("  first stress line: %s", entries[1].line))
	print(string.format("  last stress line: %s", entries[#entries].line))
end

runTest("formatting", testFormatting)
runTest("filtering", testFiltering)
runTest("setLevel", testSetLevel)
runTest("colors", testColors)
runTest("timestamps", testTimestamps)
runTest("default logger", testDefaultLogger)
runTest("invalid levels", testInvalidLevels)
runTest("stress", testStress)

print("All logger tests passed.")
