local package = script.Parent

local types = require(package.types)
local contexts = require(package.contexts)
local log = require(package.log)
local pretty = require(package.pretty)

type Test = types.Test
type Expect = types.Expect

local function get_test(): Test
    local context = contexts:peek()

    if not context or context.type ~= "test" then
        error("[lab]: attempted to use `expect` outside of a test")
    end

    return context :: any
end

local function expect(...: any)
    local params = {...}

    return {
        to_be = function(b: any)
            local test = get_test()

            local a = params[1]
            if a ~= b then
                test.failed = true
                log(
                    `[expect.to_be]: expected {a} to be {b}\n{pretty.indent_each(debug.traceback(), 1)}`
                )
            end
        end,

        to_be_greater_than = function(b: any)
            local test = get_test()

            local a = params[1]
            if a <= b then
                test.failed = true
                log(
                    `[expect.to_be_greater_than]: expected {a} to be greater than {b}\n{pretty.indent_each(debug.traceback(), 1)}`
                )
            end
        end,

        to_be_less_than = function(b: any)
            local test = get_test()

            local a = params[1]
            if a >= b then
                test.failed = true
                log(
                    `[expect.to_be_less_than]: expected {a} to be less than {b}\n{pretty.indent_each(debug.traceback(), 1)}`
                )
            end
        end,

        to_not_be = function(b: any)
            local test = get_test()

            local a = params[1]
            if a == b then
                test.failed = true
                log(
                    `[expect.to_not_be]: expected {a} to not be {b}\n{pretty.indent_each(debug.traceback(), 1)}`
                )
            end
        end,

        to_be_a = function(b: string)
            local test = get_test()

            local a = params[1]
            if typeof(a) ~= b then
                test.failed = true
                log(
                    `[expect.to_be_a]: expected {a} to be a {b}\n{pretty.indent_each(debug.traceback(), 1)}`
                )
            end
        end,

        to_throw = function(
            run: () -> ()
        )
            local test = get_test()
    
            local ok, err: string? = pcall(run)
            if ok then
                test.failed = true
                log(`[expect.to_throw]: callback did not error\n{pretty.indent_each(debug.traceback(), 1)}`)
            else
                log(`[expect.to_throw]: callback errored\n{pretty.indent(1)}{err}`)
            end
        end,

        to_not_throw = function(
            run: () -> ()
        )
            local test = get_test()
    
            local ok = pcall(run)
            if not ok then
                test.failed = true
                log(`[expect.to_not_throw]: callback errored\n{pretty.indent_each(debug.traceback(), 1)}`)
            end
        end,
    }
end

return expect