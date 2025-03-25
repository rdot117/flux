--!strict

--[=[
	Accepts a `chore` parameter, which can be either
	a `function`, `RBXScriptConnection`, `Instance`, `thread`,
	object with `:destroy()` method, object with `:Destroy()`
	method, or `scope`
]=]
local function do_cleaning(chore: any)

	-- case 1: function
	if typeof(chore) == "function" then
		chore()
	
	-- case 2: connection
	elseif typeof(chore) == "RBXScriptConnection" then
		chore:Disconnect()

	-- case 3: instance
	elseif typeof(chore) == "Instance" then
		chore:Destroy()

	-- case 4: thread
	elseif typeof(chore) == "thread" then
		local cancelled = false
		if coroutine.running() ~= chore then
			cancelled = pcall(task.cancel, chore)
		end

		if not cancelled then
			task.defer(task.cancel, chore)
		end

	-- case 5: table
	elseif typeof(chore) == "table" then
		
		-- case 6: object with :destroy method
		if typeof(chore.destroy) == "function" then
			chore:destroy()

		-- case 7: object with :Destroy() method
		elseif typeof(chore.Destroy) == "function" then
			chore:Destroy()

		-- case 8: scope
		else
			for index, sub in chore do
				chore[index] = nil
				do_cleaning(sub)
			end
		end
	end
end

return do_cleaning