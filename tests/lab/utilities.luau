--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local lab = require(ReplicatedStorage.lab)

lab.test("lab test util behaviors", function()

	-- failing cases
	lab.expect(not false) 
	lab.expect_equal(false, false)

	-- successful cases
	lab.expect(true)
	lab.expect_error(function() error("breaking code") end)
	lab.expect_equal(4, 4)
end)

lab.test("lab skip behavior", function()
	lab.skip()
	lab.expect(false)
end)

return nil