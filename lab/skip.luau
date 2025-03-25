--!strict
local package = script.Parent

local flags = require(package.flags)
local results = require(package.results)

--[=[
	Skips the remainder of a test thread. Must be called inside of a test
]=]
local function skip()
	if not flags.current then
		error("[lab]: attempted to use `skip` outside of a test")
	end

	local test_thread = coroutine.running()

	task.defer(function()
		
		task.cancel(test_thread)
		results.case_skip("skipped test execution")

		task.spawn(flags.current.thread)
	end)

	coroutine.yield()
end

return skip