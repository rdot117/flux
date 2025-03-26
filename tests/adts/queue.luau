--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local shared = ReplicatedStorage.shared

local lab = require(ReplicatedStorage.lab)
local Queue = require(shared.queue)
local Stack = require(shared.stack)

type Queue<T> = Queue.Queue<T>
type Stack<T> = Stack.Stack<T>

lab.test("queue random enqueue and dequeue", function()

	local order = {}
	for i = 1, math.random(10, 100) do
		order[i] = math.random(1, 10000)
	end

	local queue: Queue<number> = Queue.new()
	for i = 1, #order do
		local value = order[i]
		queue:enqueue(value)
	end

	lab.expect_equal(queue:size(), #order)

	for i = 1, #order do
		local value = order[i]
		local popped = queue:dequeue()

		lab.expect_equal(value, popped)
	end

	lab.expect_equal(queue:size(), 0)
end)

return nil
