local types = require "./types"

type Node = types.Node
type NodeSet = types.NodeSet

local Node = {}
Node.__index = Node

function Node.new(): Node
	local self = (setmetatable({}, Node) :: any) :: Node

	self._dependencies = {}
	self._dependents = {}

	return self
end

function Node._evaluate(self: Node)
	return false
end

function Node._clear_dependencies(self: Node)
	local dependencies = self._dependencies

	self._dependencies = {}
	for dependency, _ in dependencies do
		dependency._dependents[self] = nil
	end

	return dependencies
end

function Node._clear_dependents(self: Node)
	local dependents = self._dependents

	self._dependents = {}
	for dependent, _ in dependents do
		dependent._dependencies[self] = nil
	end

	return dependents
end

function Node.destroy(self: Node)
	self:_clear_dependencies()
	self:_clear_dependents()
end

return Node
