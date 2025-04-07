local ReplicatedStorage = game:GetService("ReplicatedStorage")

local packages = ReplicatedStorage.packages

local testlab = require(packages.testlab)
local Stack = require(packages.adts.stack)

local it = testlab.it
local test = testlab.test
local expect = testlab.expect

type Stack<T> = Stack.Stack<T>

test("stack functionality", function()
    it("pushes elements and maintains order", function()
        local stack = Stack.new() :: Stack<number>
        stack:push(1)
        stack:push(2)
        stack:push(3)

        expect(stack:size()).to_be(3)

        expect(stack:pop()).to_be(3)
        expect(stack:pop()).to_be(2)
        expect(stack:pop()).to_be(1)

        expect(stack:size()).to_be(0)
    end)

    it("peeks without removing elements", function()
        local stack = Stack.new() :: Stack<number>
        stack:push(1)
        stack:push(2)

        expect(stack:peek()).to_be(2)
        expect(stack:size()).to_be(2)

        expect(stack:peek()).to_be(2)
        expect(stack:size()).to_be(2)
    end)

    it("handles empty stack operations", function()
        local stack = Stack.new() :: Stack<number>
        expect(stack:pop()).to_be(nil)
        expect(stack:peek()).to_be(nil)
    end)

    it("tracks size correctly after operations", function()
        local stack = Stack.new() :: Stack<number>
        stack:push(1)
        stack:push(2)

        expect(stack:size()).to_be(2)

        stack:pop()
        expect(stack:size()).to_be(1)
    end)

    it("handles mixed data types", function()
        local stack = Stack.new() :: Stack<any>
        stack:push(1)
        stack:push("string")
        stack:push(true)
        stack:push(nil)

        expect(stack:pop()).to_be(nil)
        expect(stack:pop()).to_be(true)
        expect(stack:pop()).to_be("string")
        expect(stack:pop()).to_be(1)
    end)

    it("reuses stack after clearing", function()
        local stack = Stack.new() :: Stack<number>
        stack:push(1)

        stack:destroy()
        expect(stack:peek()).to_be(nil)

        stack:push(100)
        expect(stack:pop()).to_be(100)
    end)

    it("handles large push and pop operations", function()
        local stack = Stack.new() :: Stack<number>

        for i = 1, 10000 do
            stack:push(i)
        end

        for i = 10000, 1, -1 do
            expect(stack:pop()).to_be(i)
        end

        expect(stack:size()).to_be(0)
    end)

    it("clears the stack and resets size", function()
        local stack = Stack.new() :: Stack<number>
        stack:push(1)
        stack:push(2)

        stack:destroy()

        expect(stack:size()).to_be(0)
        expect(stack:peek()).to_be(nil)
    end)

    it("handles large amounts of mixed data", function()
        local stack = Stack.new() :: Stack<any>

        for i = 1, 1000 do
            stack:push(i)
            stack:push("string" .. i)
            stack:push(nil)
            stack:push(true)
        end

        expect(stack:size()).to_be(4000)

        for i = 1000, 1, -1 do
            expect(stack:pop()).to_be(true)
            expect(stack:pop()).to_be(nil)
            expect(stack:pop()).to_be("string" .. i)
            expect(stack:pop()).to_be(i)
        end

        expect(stack:size()).to_be(0)
    end)

    it("handles interleaved operations with mixed data and nil values", function()
        local stack = Stack.new() :: Stack<any>
        
        for i = 1, 500 do
            stack:push(i)
            stack:push(nil)
            expect(stack:pop()).to_be(nil)
            expect(stack:pop()).to_be(i)
        end

        expect(stack:size()).to_be(0)
    end)
end)

return nil