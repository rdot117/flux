--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local lab = require(ReplicatedStorage.lab.globals)

local test = lab.test

test("test works", function()
    test("something works", function()

    end)

    error("test works error", 0)
end)

test("indented test works", function()
    test("indented successful test", function()

    end)
end)

return nil
