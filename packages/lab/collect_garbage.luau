--[=[
    Trigger's a garbage collection cycle by allocating a large amount
    of junk memory  and then waiting for the next frame.
]=] 

local function collect_garbage()
	for _ = 1, 1e4 do
		local _ = table.create(1e3)
	end

	task.wait()
end

return collect_garbage