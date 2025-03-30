--!strict
local package = script.Parent

local types = require(package.types)

type ContextImpl<T> = types.ContextImpl<T>
type Context<T> = types.Context<T>

local Context = {}
Context.__index = Context

Context.__call = function<T>(self: ContextImpl<T>, newValue: T, during: (...unknown) -> ...unknown)
    local previous_value = self._value
    self._value = newValue

    local ok, result = pcall(during)
    if not ok then
        error(`[context]: error when executing code within context: {result}`, 0)
    end

    self._value = previous_value
    return result
end

function Context.new<T>(initial: T): Context<T>
    local self = (setmetatable({}, Context) :: any) :: ContextImpl<T>
    self._value = initial

    return self :: any
end

function Context.destroy<T>(self: ContextImpl<T>)
    self._value = (nil :: any) :: T
end

return function<T>(initial: T): Context<T>
    return Context.new(initial)
end
