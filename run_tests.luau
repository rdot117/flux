--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

print("requiring queue")

local queue = require(ReplicatedStorage.tests.adts.queue)

task.wait(10)

print("post require")

return nil
