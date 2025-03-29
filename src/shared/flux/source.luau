--!strict
local package = script.Parent

local types = require(package.types)
local graph = require(package.graph)
local scopes = require(package.scopes)
local Node = require(package.node)

type Source<T> = types.Source<T>
type SourceImpl<T> = types.SourceImpl<T>

local Source = {}
Source.__index = Source
setmetatable(Source, Node)

Source.__call = function<T>(self: SourceImpl<T>, ...)
	if select("#", ...) > 0 then
		local new_value = ... :: T
		self._value = new_value

		graph.changed(self)
	end

	return self._value
end

function Source.new<T>(initial_value: T): Source<T>
	local super = Node.new()

	local self = (setmetatable(super, Source) :: any) :: SourceImpl<T>
	self._value = initial_value

	return (self :: any) :: Source<T>
end

function Source._evaluate<T>(self: SourceImpl<T>)
	return true
end

function Source.destroy<T>(self: SourceImpl<T>)
	self._value = (nil :: any) :: T
	Node.destroy(self)
end

return function<T>(initial_value: T): Source<T>
	local handle = Source.new(initial_value)

	if scopes.in_scope() then
		scopes.use_cleanup(handle)
	end

	return handle
end
