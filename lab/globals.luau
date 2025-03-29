--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local package = script.Parent
local shared = ReplicatedStorage.shared

local types = require(package.types)
local flags = require(package.flags)
local log = require(package.log)
local output = require(package.output)
local Stack = require(shared.stack)

type Test = types.Test
type TestSuite = types.TestSuite

local function suite(module_script: ModuleScript)
    if flags.current_suite then
        output.error("process_in_suite")
    end

    local test_suite: TestSuite = {
        name = module_script.Name,

        tests_passed = 0,
        total_tests = 0,

        test_stack = Stack.new(),
        output_messages = {},
    }

    test_suite.test_stack:push(test_suite)
    flags.current_suite = test_suite

    local ok, err: string? = pcall(function()
        local _run = require(module_script) :: any
    end)

    if not ok then
        output.error("err_in_test", err)
    end

    if test_suite.tests_passed == test_suite.total_tests then
        log.test_passed()
    else
        log.test_failed()
    end

    output.flush(test_suite.output_messages)
    flags.current_suite = nil
end

local function test(name: string, during: () -> ())
    local suite = flags.current_suite
    if not suite then
        output.error("test_out_of_suite")
        return
    end

    local test: Test = {
        name = name,
        tests_passed = 0,
        total_tests = 0,
        output_messages = {},
    }

    suite.test_stack:push(test)

    local ok, err: string? = pcall(during)
    if not ok then
        log.test_error(err :: string)
        log.test_complete()
        suite.test_stack:pop()
        return
    end

    if test.tests_passed == test.total_tests then
        log.test_passed()
    else
        log.test_failed()
    end

    log.test_complete()
    suite.test_stack:pop()
end

return {
    suite = suite,
    test = test,
}
