local ReplicatedStorage = game:GetService("ReplicatedStorage")

local tests = ReplicatedStorage.tests
local packages = ReplicatedStorage.packages

local lab = require(packages.lab.exports)

lab.run_tests(tests)

return nil