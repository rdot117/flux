local package = script.Parent

local types = require(package.types)
local contexts = require(package.contexts)

type Test = types.Test
type Expect = types.Expect

local function get_test(): Test
    local context = contexts:peek()

    if not context or context.type ~= "test" then
        error("[lab]: attempted to use `log` outside of a test")
    end

    return context :: any
end

--[=[
    Logs a given message to be displayed,
    under the current running test's context
]=]
local function log(message: string)
    local test = get_test()

    table.insert(test.logs, message)
end

return log