local types = require "./types"
local graph = require "./graph"
local scopes = require "./scopes"
local Node = require "./node"

type Use = types.Use
type Computed<T> = types.Computed<T>
type ComputedImpl<T> = types.ComputedImpl<T>

local Computed = {}
Computed.__index = Computed
setmetatable(Computed, Node)

function Computed.new<T>(source: (use: Use) -> T): Computed<T>
	local super = Node.new()

	local self = (setmetatable(super, Computed) :: any) :: ComputedImpl<T>
	self._source = source

	self._use = graph.use(self)
	self:_evaluate()

	return (self :: any) :: Computed<T>
end

function Computed._evaluate<T>(self: ComputedImpl<T>)

	self:_clear_dependencies()

	local new_value = graph.capture(self, self._source, self._use)

	if new_value ~= self._value then
		self._value = new_value
		return true
	end

	return false
end

function Computed.destroy<T>(self: ComputedImpl<T>)
	self._value = (nil :: any) :: T
	Node.destroy(self)
end

return function<T>(source: (use: Use) -> T)
	local handle = Computed.new(source)

	if scopes.in_scope() then
		scopes.use_cleanup(handle)
	end

	return handle
end
