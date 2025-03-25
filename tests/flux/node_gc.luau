--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local lab = require(ReplicatedStorage.lab)
local flux = require(ReplicatedStorage.shared.flux)
local do_cleaning = require(ReplicatedStorage.shared.do_cleaning)

local source = flux.source
local effect = flux.effect
local computed = flux.computed

lab.test("source garbage collects", function()
	lab.skip()

	local ref = source(0)

	local weak = lab.weak_ref()
	weak[1] = ref

	lab.expect_equal(#weak, 1)

	ref = nil :: any
	lab.garbage_collect()

	lab.expect_equal(#weak, 0)
end)

lab.test("effect garbage collects after source collects", function()
	lab.skip()
	
	local counter = source(0)

	local handle = effect(function(use)
		use(counter)
	end)

	local weak = lab.weak_ref()

	table.insert(weak, counter)
	table.insert(weak, handle)
	lab.expect_equal(#weak, 2)

	handle = nil :: any
	lab.garbage_collect()
	lab.expect_equal(#weak, 2)

	counter = nil :: any
	lab.garbage_collect()
	lab.expect_equal(#weak, 0)
end)

lab.test("computed garbage collects after source collects", function()
	local counter = source(0)

	local handle = computed(function(use)
		return use(counter)
	end)

	local weak = lab.weak_ref()

	table.insert(weak, counter)
	table.insert(weak, handle)
	lab.expect_equal(#weak, 2)

	handle = nil :: any
	lab.garbage_collect()
	lab.expect_equal(#weak, 2)

	counter = nil :: any
	lab.garbage_collect()
	lab.expect_equal(#weak, 0)
end)

lab.test("source garbage collects after scope cleans", function()
	local weak = lab.weak_ref()
	
	local scope = flux.root(function()

		local ref = source(0)
		table.insert(weak, ref)

		ref = nil :: any
	end)

	lab.garbage_collect()
	lab.expect_equal(#weak, 1)

	do_cleaning(scope)
	lab.garbage_collect()
	lab.expect_equal(#weak, 0)
end)

return nil