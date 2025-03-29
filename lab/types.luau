--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local shared = ReplicatedStorage.shared

local Stack = require(shared.stack)

type Stack<T> = Stack.Stack<T>

export type Test = {
    name: string,
    tests_passed: number,
    total_tests: number,
    output_messages: { string },
}

export type TestSuite = {
    name: string,

    tests_passed: number,
    total_tests: number,

    test_stack: Stack<Test>,
    output_messages: { string },
}

return nil
