--!strict
local package = script.Parent

local scopes = require(package.scopes)
local hydrate = require(package.hydrate)

local function element(classname: string)
	return function(props: { [any]: any })
		local ok, instance = pcall(Instance.new, classname)
		if not ok then
			error("[flux]: attempted to create invalid instance: " .. classname, 0)
		end

		if scopes.in_scope() then
			scopes.use_cleanup(instance)
		end

		hydrate(instance, props)
		return instance
	end
end

return element