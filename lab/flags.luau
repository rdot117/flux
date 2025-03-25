--!strict
local package = script.Parent

local types = require(package.types)

type Test = types.Test

return {
	current = nil :: Test?
}