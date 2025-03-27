--!strict
local package = script.Parent
local shared = package.Parent

local types = require(package.types)
local effect = require(package.effect)
local Queue = require(shared.queue)

type UsedAs<T> = types.UsedAs<T>
type Queue<T> = Queue.Queue<T>

local INVALID_CHILDREN_TYPE = "[flux]: invalid children type: %s"
local PROPERTY_DOESNT_EXIST = "[flux]: attempted to set property that doesn't exist: %s"
local INVALID_PROPERTY = "[flux]: error setting property %s with value %s, error: %s"

local function has_property(instance: Instance, property: string)
	local impl = instance :: any

	local ok = pcall(function()
		impl[property] = impl[property]
	end)

	return ok
end

local function set_property(instance: Instance, property: string, value: any)
	local impl = instance :: any

	local ok, err = pcall(function()
		impl[property] = value
	end)

	if not ok then
		error(string.format(INVALID_PROPERTY, property, value, err), 0)
	end
end

local function bind_property(instance: Instance, property: string, value: UsedAs<any>)
	if not has_property(instance, property) then
		error(string.format(PROPERTY_DOESNT_EXIST, property), 0)
		return
	end

	if types.is_node(value) then
		effect(function(use)
			set_property(instance, property, use(value))
		end)
	else
		set_property(instance, property, value)
	end
end

local function bind_children(instance: Instance, children: UsedAs<any>)

	-- static child
	if typeof(children) == "Instance" then
		children.Parent = instance
		return
	end

	-- dynamic parenting
	if not types.is_node(children) then
		error(string.format(INVALID_CHILDREN_TYPE, typeof(children)), 0)
	end

	local previous_children: { Instance } = {}

	effect(function(use)
		local current_children = use(children) :: { Instance }
		if not current_children then
			current_children = {}
		end

		if typeof(current_children) == "Instance" then
			current_children = { current_children }
		end

		if typeof(current_children) == "table" then
			for _, child in previous_children do
				if not table.find(current_children, child) then
					child.Parent = nil
				end
			end

			for _, child in current_children do
				child.Parent = instance
			end

			previous_children = table.clone(current_children)
		end
	end)
end

--[=[
	Binds an instances properties, parent, and children according
	to the provided `layered_props` argument.
]=]
local function hydrate(instance: Instance, layered_props: { [any]: any })

	local props_queue: Queue<{ [any]: any}> = Queue.new()
	props_queue:enqueue(layered_props)

	local parent = nil

	while not props_queue:is_empty() do
		local props = props_queue:dequeue()
		if not props then
			continue
		end

		for key, value in props do

			-- case 0: parent key
			if key == "Parent" then
				parent = value
			end

			-- case 1: string key (property)
			if typeof(key) == "string" then
				bind_property(instance, key, value)

			-- case 2: instance/node value (child)
			elseif typeof(value) == "Instance" or types.is_node(value) then
				bind_children(instance, value)

			-- case 3: nested props
			elseif typeof(value) == "table" then
				props_queue:enqueue(value)
			end
		end
	end

	bind_property(instance, "Parent", parent)
end

return hydrate
