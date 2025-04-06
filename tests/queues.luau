local ReplicatedStorage = game:GetService("ReplicatedStorage")

local packages = ReplicatedStorage.packages

local lab = require(packages.lab)
local Queue = require(packages.adts.queue)

local it = lab.it
local test = lab.test
local expect = lab.expect

type Queue<T> = Queue.Queue<T>

test("queue functionality", function()
    it("enqueues elements and maintains order", function()
        local queue = Queue.new() :: Queue<number>
        queue:enqueue(1)
        queue:enqueue(2)
        queue:enqueue(3)
        expect(queue:size()).to_be(3)
        expect(queue:dequeue()).to_be(1)
        expect(queue:dequeue()).to_be(2)
        expect(queue:dequeue()).to_be(3)
        expect(queue:size()).to_be(0)
    end)

    it("peeks without removing elements", function()
        local queue = Queue.new() :: Queue<number>
        queue:enqueue(1)
        queue:enqueue(2)
        expect(queue:peek()).to_be(1)
        expect(queue:size()).to_be(2)

        -- ensure peek doesn't remove
        expect(queue:peek()).to_be(1) 
        expect(queue:size()).to_be(2)
    end)

    it("handles empty queue operations", function()
        local queue = Queue.new() :: Queue<number>
        expect(queue:dequeue()).to_be(nil)
        expect(queue:peek()).to_be(nil)
    end)

    it("tracks size correctly after operations", function()
        local queue = Queue.new() :: Queue<number>
        queue:enqueue(1)
        queue:enqueue(2)

        queue:dequeue()
        expect(queue:size()).to_be(1)
        expect(queue:peek()).to_be(2)
    end)

    it("includes nil values in queue", function()
        local queue = Queue.new() :: Queue<any>
        queue:enqueue(nil)
        queue:enqueue(1)

        expect(queue:size()).to_be(2)
        expect(queue:peek()).to_be(nil)
    end)

    it("identifies empty and non-empty states", function()
        local queue = Queue.new() :: Queue<number>
        expect(queue:is_empty()).to_be(true)

        queue:enqueue(1)
        expect(queue:is_empty()).to_be(false)
    end)

    it("handles mixed data types", function()
        local queue = Queue.new() :: Queue<any>
        queue:enqueue(1)
        queue:enqueue("string")
        queue:enqueue(true)
        queue:enqueue(nil)
        expect(queue:size()).to_be(4)
        expect(queue:dequeue()).to_be(1)
        expect(queue:dequeue()).to_be("string")
        expect(queue:dequeue()).to_be(true)
        expect(queue:dequeue()).to_be(nil)
        expect(queue:size()).to_be(0)
    end)

    it("reuses queue after clearing", function()
        local queue = Queue.new() :: Queue<number>
        queue:enqueue(1)

        queue:destroy()

        queue:enqueue(100)
        expect(queue:dequeue()).to_be(100)
    end)

    it("handles large enqueue and dequeue operations", function()
        local queue = Queue.new() :: Queue<number>

        for i = 1, 10000 do
            queue:enqueue(i)
        end

        for i = 1, 10000 do
            expect(queue:dequeue()).to_be(i)
        end

        expect(queue:size()).to_be(0)
    end)

    it("handles interleaved enqueue and dequeue operations", function()
        local queue = Queue.new() :: Queue<number>

        for i = 1, 5000 do
            queue:enqueue(i)
            expect(queue:dequeue()).to_be(i)
        end

        expect(queue:size()).to_be(0)
    end)

    it("clears the queue and resets size", function()
        local queue = Queue.new() :: Queue<number>
        queue:enqueue(1)
        queue:enqueue(2)

        queue:destroy()

        expect(queue:size()).to_be(0)
        expect(queue:peek()).to_be(nil)
    end)

    it("handles large amounts of mixed data", function()
        local queue = Queue.new() :: Queue<any>
        for i = 1, 1000 do
            queue:enqueue(i)
            queue:enqueue("string" .. i)
            queue:enqueue(nil)
            queue:enqueue(true)
        end

        expect(queue:size()).to_be(4000)

        for i = 1, 1000 do
            expect(queue:dequeue()).to_be(i)
            expect(queue:dequeue()).to_be("string" .. i)
            expect(queue:dequeue()).to_be(nil)
            expect(queue:dequeue()).to_be(true)
        end

        expect(queue:size()).to_be(0)
    end)

    it("handles interleaved operations with mixed data and nil values", function()
        local queue = Queue.new() :: Queue<any>

        for i = 1, 500 do
            queue:enqueue(i)
            queue:enqueue(nil)
            expect(queue:dequeue()).to_be(i)
            expect(queue:dequeue()).to_be(nil)
        end
        
        expect(queue:size()).to_be(0)
    end)
end)

return nil