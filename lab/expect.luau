--!strict
local package = script.Parent

local log = require(package.log)

local function expect(a: any)
    return {
        to_be = function(b: any)

        end,

        error = function(callback: () -> ())

        end,
    }
end

return {

}
