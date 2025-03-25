--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local flux = require(ReplicatedStorage.shared.flux)
local lab = require(ReplicatedStorage.lab)

local source = flux.source
local computed = flux.computed
local effect = flux.effect

lab.test("is_node with nodes, nil, and primitives", function()
	local source_node = source(0)
	local computed_node = computed(function() return nil end)
	local effect_node = effect(function() end)

	lab.expect(flux.is_node(source_node))
	lab.expect(flux.is_node(computed_node))
	lab.expect(flux.is_node(effect_node))

	lab.expect(not flux.is_node(nil))
	lab.expect(not flux.is_node(true))
	lab.expect(not flux.is_node(4))
	lab.expect(not flux.is_node("hello"))
end)

return nil