--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local flux = require(ReplicatedStorage.shared.flux)
local lab = require(ReplicatedStorage.lab)

local source = flux.source
local computed = flux.computed
local peek = flux.peek

lab.test("simple computed", function()
	local counter = source(0)

	local double = computed(function(use)
		return use(counter) * 2
	end)

	lab.expect_equal(peek(double), peek(counter) * 2)

	counter(1)
	lab.expect_equal(peek(double), peek(counter) * 2)

	counter(2)
	lab.expect_equal(peek(double), peek(counter) * 2)
end)

lab.test("computed run counter", function()
	local counter = source(0)
	local computes = 0

	local handle = computed(function(use)
		computes += 1
		return use(counter)
	end)

	lab.expect(computes == 1)

	peek(counter)
	lab.expect(computes == 1)

	peek(handle)
	lab.expect(computes == 1)

	counter(1)
	lab.expect(computes == 2)

	counter(2)
	lab.expect(computes == 3)
end)

lab.test("computed switch dependency detection", function()
	local a = source(0)
	local b = source("hi")
	local switch = source(false)

	local computes = 0
	local current = computed(function(use): number | string
		computes += 1

		if use(switch) then
			return use(b)
		else
			return use(a)
		end
	end)

	lab.expect_equal(peek(current), 0)
	lab.expect_equal(computes, 1)

	switch(true)
	lab.expect_equal(peek(current), "hi")
	lab.expect_equal(computes, 2)

	b("hello")
	lab.expect_equal(peek(current), "hello")
	lab.expect_equal(computes, 3)

	a(4)
	lab.expect_equal(peek(current), "hello")
	lab.expect_equal(computes, 3)

	switch(false)
	lab.expect_equal(peek(current), 4)
	lab.expect_equal(computes, 4)
end)

return nil