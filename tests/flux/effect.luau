--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local flux = require(ReplicatedStorage.shared.flux)
local lab = require(ReplicatedStorage.lab)

local source = flux.source
local effect = flux.effect
local peek = flux.peek

lab.test("simple effect", function()

	local value = 0
	local counter = source(3)

	effect(function(use)
		value = use(counter)
	end)

	lab.expect_equal(value, peek(counter))

	for i = 1, math.random(10, 20) do
		counter(math.random(1, 1000))
		lab.expect_equal(value, peek(counter))
	end
end)

lab.test("effect run counter", function()
	local counter = source(0)
	local computes = 0

	local disconnect = effect(function(use)
		computes += 1
		return use(counter)
	end)

	lab.expect(computes == 1)

	-- ensure reading does not recompute
	peek(counter)
	lab.expect(computes == 1)

	-- setting should call a compute
	counter(1)
	lab.expect(computes == 2)

	-- stop computes
	disconnect()

	-- setting should no longer call a compute
	counter(3)
	lab.expect(computes == 2)
end)

lab.test("effect switch dependency detection", function()
	local a = source(0)
	local b = source("hi")
	local switch = source(false)

	local computes = 0
	effect(function(use)
		computes += 1
		if use(switch) then
			use(b)
		else
			use(a)
		end
	end)

	lab.expect_equal(computes, 1)

	switch(true)
	lab.expect_equal(computes, 2)

	b("hello")
	lab.expect_equal(computes, 3)

	a(4)
	lab.expect_equal(computes, 3)

	switch(false)
	lab.expect_equal(computes, 4)
end)

return nil