--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local flux = require(ReplicatedStorage.shared.flux)
local lab = require(ReplicatedStorage.lab)

local source = flux.source
local peek = flux.peek

lab.test("source changes", function()
	local counter = source(0)
	
	lab.expect_equal(peek(counter), 0)

	counter(1)
	lab.expect_equal(peek(counter), 1)
end)

return nil