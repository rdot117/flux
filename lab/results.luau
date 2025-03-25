--!strict
local package = script.Parent

local flags = require(package.flags)

local SUCCESS_SYMBOL = "+"
local ERR_SYMBOL = "-"
local SKIP_SYMBOL = "~"
local TEST_FAILED_SYMBOL = "🔴"
local TEST_PASSED_SYMBOL = "🟢"
local TEST_SYMBOL = "📝"

local function inline(...: string)
	return string.format("[%s %s]: %s", ...)
end

local function header(...: string)
	return string.format("[%s %s]: %s", ...)
end

local function starting(name: string)
	print(header(TEST_SYMBOL, name, "starting"))
end

local function complete()
	local test = flags.current
	if not test then
		error("[lab]: attempted to use `complete` outside of a test")
	end

	local total = test.successes + test.errors
	local output = if test.errors > 0
		then header(TEST_FAILED_SYMBOL, test.name, `was not successful ({test.successes}/{total})`)
		else header(TEST_PASSED_SYMBOL, test.name, `was successful ({test.successes}/{total})`)

	print(output .. "\n")
end

local function case_result(...: string)
	if not flags.current then
		error("[lab]: attempted to use `case_result` outside of a test")
	end

	print(inline(...))

	table.insert(flags.current.results, inline(...))
end

local function case_error(...: string)
	if not flags.current then
		error("[lab]: attempted to use `case_error` outside of a test")
	end

	flags.current.errors += 1
	case_result(ERR_SYMBOL, ...)
end

local function case_success(...: string)
	if not flags.current then
		error("[lab]: attempted to use `case_success` outside of a test")
	end

	flags.current.successes += 1
	case_result(SUCCESS_SYMBOL, ...)
end

local function case_skip(...: string)
	if not flags.current then
		error("[lab]: attempted to use `case_success` outside of a test")
	end

	case_result(SKIP_SYMBOL, "skip", ...)
end

return {
	starting = starting,
	complete = complete,

	case_result = case_result,
	case_error = case_error,
	case_success = case_success,
	case_skip = case_skip,
}