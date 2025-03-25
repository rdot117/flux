--!strict
local package = script.Parent

local flags = require(package.flags)

--[=[
	Trigger a garbage collection cycle by allocating a large amount of junk memory
	and then waiting for the next frame.
]=]
local function garbage_collect()
	if not flags.current then
		error("[lab]: attempted to use `garbage_collect` outside of a test")
	end

	for _ = 1, 1e4 do
		local _ = table.create(1e3)
	end
	
	task.wait()
end

return garbage_collect