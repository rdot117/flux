--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local tests = ReplicatedStorage.tests
local lab = require(ReplicatedStorage.lab.globals)

local example_suite = tests.example_suite
lab.suite(example_suite)

return nil
