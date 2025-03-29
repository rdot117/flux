--!strict
local output_messages = {

    -- errors
    process_in_suite = "[lab]: attempted to call `previous` inside of a test suite",
    test_out_of_suite = "[lab]: attempted to call `test` outside of a test suite",
    test_stack_mismatch = "[lab]: test mismatch in suite test_stack after running test (%s)",
    err_in_test = "[lab]: errored while running test (%s): %s",

    -- logging
    suite_running = "[lab]: test suit (%s) is running",
    suite_passed = "[🟢]: test suite (%s) has passed (%s/%s)",
    suite_failed = "[🔴]: test suite (%s) has failed (%s/%s)",
    test_passed = "[+]: %s has passed",
    test_failed = "[-]: %s has failed",
}

local function format(key: string, ...: any)
    return string.format(output_messages[key], ...)
end

local function flush(messages: { string })
    local output = nil
    for _, message in messages do
        if output == nil then
            output = message
        else
            output = output .. `\n{message}`
        end
    end

    print(output)
end

local function flush_error(messages: { string })

end

local function error(key: string, ...: any)
    error(format(key, ...))
end

return {
    error = error,
    format = format,
    flush = flush,
}
