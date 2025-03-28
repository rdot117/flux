--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local flux = require(ReplicatedStorage.shared.flux)
local lab = require(ReplicatedStorage.lab)

local context = flux.context
local peek = flux.peek

lab.test("context value changes", function()
    local number_context = context(2)
    
    lab.expect_equal(peek(number_context), 2)

    number_context(4, function()
        lab.expect_equal(peek(number_context), 4)
    end)

    lab.expect_equal(peek(number_context), 2)
end)

return nil