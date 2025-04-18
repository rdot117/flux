local package = script.Parent
local packages = package.Parent

local types = require(package.types)
local graph = require(package.graph)
local scopes = require(package.scopes)
local do_cleaning = require(packages.do_cleaning)
local constructor = require(package.constructor)
local Node = require(package.node)

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
	self._scope = {}

	self._use = graph.use(self)
	self:_evaluate()

	return self :: any
end

function Computed._evaluate<T>(self: ComputedImpl<T>)

	self:_clear_dependencies()
	do_cleaning(self._scope)

	-- wrap source in scope, and capture dependencies
	local new_value = scopes.wrap(self._scope, function()
		return graph.capture(self, self._source, self._use)
	end)

	-- local new_value = graph.capture(self, self._source, self._use)

	if new_value ~= self._value then
		self._value = new_value
		return true
	end

	return false
end

function Computed.destroy<T>(self: ComputedImpl<T>)
	do_cleaning(self._scope)
	self._value = (nil :: any) :: T
	Node.destroy(self)
end

return constructor(Computed.new)
