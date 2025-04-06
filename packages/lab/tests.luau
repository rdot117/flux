local packages = script.Parent.Parent
local package = script.Parent

local types = require(package.types)
local pretty = require(package.pretty)
local contexts = require(package.contexts)
local Queue = require(packages.adts.queue)

type Queue<T> = Queue.Queue<T>
type Context = types.Context
type Test = types.Test
 
local function wrap_context(
    context: Context,
    run: () -> ()
)
    contexts:push(context)

    run()

    if context ~= contexts:pop() then
        error("[lab]: context mismatch")
    end
end

local function test_context(
    name: string,
    run: () -> ()
)
    local context = contexts:peek()
    if not context then
        error("[lab]: attempted to use `test` outside a test context")
    end

    local labels = table.clone(context.labels)
    table.insert(labels, name)

    local suite: Context = {
        type = "suite",
        items = context.items,
        time_taken = 0,
        labels = labels,
    }

    table.insert(context.items, suite)

    return suite
end

local function test_suite(
    name: string,
    run: () -> ()
)
    local suite = test_context(name, run)
    local start = os.clock()

    wrap_context(suite, run)
    suite.time_taken = os.clock() - start
end

local function test_case(
    name: string,
    run: () -> ()
)
    local test = test_context(name, run) :: Test
    test.type = "test"
    test.failed = false

    local start = os.clock()

    wrap_context(test, function()
        local ok, err: string? = pcall(run)
        if not ok then
            test.failed = true
            test.error = (err :: string) .. `\n{debug.traceback()}`
        end
    end)

    test.time_taken = os.clock() - start

    if test.failed then
        test.status = "failed"

        -- propogate failure up
        local context = contexts:peek() :: Context
        if context.type == "test" then
            local parent_test = context :: Test
            parent_test.failed = true
        end
    else
        test.status = "passed"
    end
end

local function run_tests(
    ...: Instance
)
    if contexts:peek() then
        error("[lab]: attempted to call `run_tests` while already within a test context")
    end

    local instances = { ... }

    local start = os.clock()
    local context: Context = {
        type = "run",
        items = {},
        labels = {},
        time_taken = 0,
    }

    wrap_context(context, function()

        -- run test suites and cases
        local to_require: Queue<Instance> = Queue.new()
        for _, root in instances do
            to_require:enqueue(root)
        end

        while not to_require:is_empty() do
            local instance = to_require:dequeue() :: Instance

            if instance:IsA("ModuleScript") then
                local _run = require(instance) :: any
            else
                for _, children in instance:GetChildren() do
                    to_require:enqueue(children)
                end
            end
        end
    end)

    context.time_taken = os.clock() - start

    -- tally all tests
    local tally = {
        passed = 0,
        failed = 0,
    }

    for _, item in context.items do
        if item.type ~= "test" then
            continue
        end

        local test = item :: Test
        tally[test.status] += 1
    end

    -- log results
    print(pretty.log(context, tally))
end

return {
    run_tests = run_tests,
    test_case = test_case,
    test_suite = test_suite,
}