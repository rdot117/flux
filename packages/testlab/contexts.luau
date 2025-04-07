local package = script.Parent
local packages = package.Parent

local types = require(package.types)
local Stack = require(packages.adts.stack)

type Context = types.Context
type Stack<T> = Stack.Stack<T>

return Stack.new() :: Stack<Context>