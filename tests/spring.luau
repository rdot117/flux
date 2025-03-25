--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local shared = ReplicatedStorage.shared

local lab = require(ReplicatedStorage.lab)
local Spring = require(shared.spring)

lab.test("number moves smoothly", function()
	lab.skip()
	
	local spring = Spring.new(0)
	spring.speed = 10
	spring.damping = 0
	spring.target = 10

	local visual = Instance.new("Part")
	visual.Anchored = true
	visual.CanCollide = false
	visual.Size = Vector3.one * 4
	visual.Color = Color3.fromRGB(255, 0, 0)
	visual.Position = Vector3.yAxis * 10
	visual.Parent = workspace

	spring:bind(function()
		visual.Position = Vector3.yAxis * 10 + Vector3.yAxis * spring.position
	end)

	task.wait(10)

	spring:destroy()
	visual:Destroy()
end)

lab.test("vector3 moves smoothly", function()
	local spring = Spring.new(Vector3.yAxis * 10)
	spring.speed = 10
	spring.damping = 0
	spring.target = Vector3.yAxis * 20

	local visual = Instance.new("Part")
	visual.Anchored = true
	visual.CanCollide = false
	visual.Size = Vector3.one * 4
	visual.Color = Color3.fromRGB(255, 0, 0)
	visual.Position = spring.position
	visual.Parent = workspace

	spring:bind(function()
		visual.Position = spring.position
	end)

	task.wait(10)

	spring:destroy()
	visual:Destroy()
end)

return nil