local package = script.Parent
local packages = package.Parent

local types = require(package.types)
local graph = require(package.graph)
local scopes = require(package.scopes)
local constructor = require(package.constructor)
local do_cleaning = require(packages.do_cleaning)
local Node = require(package.node)

type Use = types.Use
type Effect = types.Effect
type EffectImpl = types.EffectImpl

local Effect = {}
Effect.__index = Effect
setmetatable(Effect, Node)

Effect.__call = function(self: EffectImpl)
	self:destroy()
end

function Effect.new(source: (use: Use) -> ()): Effect
	local super = Node.new()

	local self = (setmetatable(super, Effect) :: any) :: EffectImpl
	self._source = source
	self._scope = {}

	self._use = graph.use(self)
	self:_evaluate()

	return (self :: any) :: Effect
end

function Effect._evaluate(self: EffectImpl)

	-- clear existing dependencies and effects
	self:_clear_dependencies()
	do_cleaning(self._scope)

	-- wrap source in scope, and capture dependencies
	scopes.wrap(self._scope, function()
		graph.capture(self, self._source, self._use)
	end)

	return false
end

function Effect.destroy(self: EffectImpl)
	do_cleaning(self._scope)
	Node.destroy(self)
end

return constructor(Effect.new)
