--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local package = script
local shared = ReplicatedStorage.shared

-- | modules | --
local types = require(package.types)
local flags = require(package.flags)
local results = require(package.results)
local Queue = require(shared.queue)

-- | types | --
type Queue<T> = Queue.Queue<T>
type Test = types.Test

-- | variables | --
local tests = Queue.new() :: Queue<Test>

-- | test functions | --
local function expect_error<T...>(handler: (T...) -> (), ...: T...)
	if not flags.current then
		error("[lab]: attempted to use `expect_error` outside of a test", 0)
	end

	local ok, err: string? = pcall(handler, ...)
	if ok then
		results.case_error("expect_error", "did not error")
	else
		results.case_success("expect_error", `errored: {err}`)
	end
end

local function expect(condition: boolean)
	if not flags.current then
		error("[lab]: attempted to use `expect` outside of a test", 0)
	end

	if condition then
		results.case_success("expect", "was true")
	else
		results.case_error("expect", "was false")
	end
end

local function expect_equal(a: any, b: any)
	if not flags.current then
		error("[lab]: attempted to use `expect_equal` outside of a test", 0)
	end

	if a == b then
		results.case_success("expect_equal", `{tostring(a)} was equal to {tostring(b)}`)
	else
		results.case_error("expect_equal", `{tostring(a)} was not equal to {tostring(b)}`)
	end
end

local function weak_ref(): { [any]: any }
	return setmetatable({}, { __mode = "kv" }) :: any
end

--[=[
	Trigger a garbage collection cycle by allocating a large amount of junk memory
	and then waiting for the next frame.
]=]
local function garbage_collect()
	if not flags.current then
		error("[lab]: attempted to use `garbage_collect` outside of a test")
	end

	for _ = 1, 1e4 do
		local _ = table.create(1e3)
	end
	
	task.wait()
end

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

-- | test execution functions | --
local function run(test: Test)

	flags.current = test
	test.thread = coroutine.running()
	results.starting(test.name)

	-- test handler thread, which resumes
	-- `processing` thread once complete
	local runner = coroutine.create(function()
		local ok, err: string? = pcall(test.handler)
		if not ok then
			error(`[lab: {test.name}]: test errored while running {err}`, 0)
		end

		task.spawn(test.thread)
	end)

	-- must defer runner thread, since this
	-- thread will be paused and therefore can't
	-- spawn the runner thread
	task.defer(runner)
	coroutine.yield()

	results.complete()
	flags.current = nil
end

local function flush_queue()
	while tests:size() > 0 do
		local test = tests:dequeue()
		run(test :: Test)
	end
end

-- | test constructor | --
local function test(name: string, handler: () -> ())
	tests:enqueue({
		name = name,
		handler = handler,
		results = {},

		errors = 0,
		successes = 0,

		skipped = false,
		thread = coroutine.running(),
	})

	if not flags.current then
		flush_queue()
	end
end

return {
	weak_ref = weak_ref,
	garbage_collect = garbage_collect,
	skip = skip,

	test = test,
	expect = expect,
	expect_equal = expect_equal,
	expect_error = expect_error,
}