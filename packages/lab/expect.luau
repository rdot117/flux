local package = script.Parent

local types = require(package.types)
local contexts = require(package.contexts)

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
                table.insert(test.logs, `[expect.to_be]: expected {a} to be {b}`)
            end
        end,

        not_error = function(
            run: () -> ()
        )
            local test = get_test()
    
            local ok = pcall(run)
            if not ok then
                test.failed = true
                table.insert(test.logs, "[expect.not_error]: callback errored")
            end
        end,
    
        error = function(
            run: () -> ()
        )
            local test = get_test()
    
            local ok = pcall(run)
            if ok then
                test.failed = true
                table.insert(test.logs, "[expect.error]: callback did not error")
            end
        end,
    }
end

return expect