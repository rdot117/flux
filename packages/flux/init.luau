local package = script

local types = require(package.types)
local source = require(package.source)
local effect = require(package.effect)
local computed = require(package.computed)
local scopes = require(package.scopes)
local element = require(package.element)
local hydrate = require(package.hydrate)
local graph = require(package.graph)
local context = require(package.context)
local spring = require(package.spring)

export type Scope = types.Scope
export type Source<T> = types.Source<T>
export type Computed<T> = types.Computed<T>
export type UsedAs<T> = types.UsedAs<T>
export type Context<T> = types.Context<T>
export type Children = types.Children

return {

    -- reactive
	source = source,
	computed = computed,
	effect = effect,

	-- nodes
	peek = graph.peek,
	is_node = types.is_node,

	-- instances
	element = element,
	hydrate = hydrate,

	-- scopes
	root = scopes.root,
	in_scope = scopes.in_scope,
	use_cleanup = scopes.use_cleanup,
	use_event = scopes.use_event,

	-- animation
	spring = spring,

	-- contexts
	context = context,
}
