--!strict
local package = script.Parent

local types = require(package.types)
local flags = require(package.flags)

type Test = types.Test
type TestSuite = types.TestSuite

local log_messages = {

    -- errors
    process_in_suite = "[lab]: attempted to call `previous` inside of a test suite",
    test_out_of_suite = "[lab]: attempted to call `test` outside of a test suite",
    test_stack_mismatch = "[lab]: test mismatch in suite test_stack after running test (%s)",

    -- logging
    error_loc = "[ERROR]: %s",
    test_errored = "[ERROR]: %s has errored (%s/%s)",
    test_passed = "[+]: %s has passed (%s/%s)",
    test_failed = "[-]: %s has failed (%s/%s)",
}

local function format(key: string, ...: unknown)
    return string.format(log_messages[key], ...)
end

local function indent(indents: number)
    local base = ""
    for indent = 1, indents do
        base = base .. "\t"
    end
    return base
end

local function error(key: string, ...: unknown)
    error(format(key, ...))
end

local function test_complete()
    local suite = flags.current_suite :: TestSuite
    local test = suite.test_stack:peek() :: Test
    local parent = suite.test_stack:peek(suite.test_stack:size() - 1) :: types.Test

    for _, message in test.output_messages do
        table.insert(parent.output_messages, message)
    end
end

local function test_passed()
    local suite = flags.current_suite :: TestSuite
    local test = suite.test_stack:peek() :: Test

    local parent = suite.test_stack:peek(suite.test_stack:size() - 1)
    if parent then
        parent.tests_passed += 1
        parent.total_tests += 1
    end

    local message = indent(suite.test_stack:size() - 1)
        .. format("test_passed", test.name, test.tests_passed, test.total_tests)

    table.insert(test.output_messages, 1, message)
end

local function test_failed()
    local suite = flags.current_suite :: TestSuite
    local test = suite.test_stack:peek() :: Test

    local parent = suite.test_stack:peek(suite.test_stack:size() - 1)
    if parent then
        parent.total_tests += 1
    end

    local message = indent(suite.test_stack:size() - 1)
        .. format("test_failed", test.name, test.tests_passed, test.total_tests)

    table.insert(test.output_messages, 1, message)
end

local function test_error(err: string)
    local suite = flags.current_suite :: TestSuite

    local test = suite.test_stack:peek() :: Test
    test.total_tests += 1

    local message = indent(suite.test_stack:size() - 1)
        .. format("test_errored", test.name, test.tests_passed, test.total_tests)

    table.insert(test.output_messages, 1, message)

    local err_message = indent(suite.test_stack:size())
        .. format("error_loc", err)

    table.insert(test.output_messages, err_message)
end

return {
    test_passed = test_passed,
    test_failed = test_failed,
    test_complete = test_complete,
    test_error = test_error,
}
