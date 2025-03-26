--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local shared = ReplicatedStorage.shared

local lab = require(ReplicatedStorage.lab)
local Stack = require(shared.stack)

type Stack<T> = Stack.Stack<T>

lab.test("stack random push and pop", function()

	local order = {}
	for i = 1, math.random(10, 100) do
		order[i] = math.random(1, 10000)
	end

	local stack: Stack<number> = Stack.new()
	for i = 1, #order do
		local value = order[i]
		stack:push(value)
	end

	lab.expect_equal(stack:size(), #order)

	for i = #order, 1, -1 do
		local value = order[i]
		local popped = stack:pop()

		lab.expect_equal(value, popped)
	end

	lab.expect_equal(stack:size(), 0)
end)

return nil
