--!strict
local package = script.Parent

local types = require(package.types)

type TestSuite = types.TestSuite

return {
    current_suite = nil :: TestSuite?
}