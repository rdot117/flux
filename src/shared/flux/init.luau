--!strict
local package = script

local source = require(package.source)
local effect = require(package.effect)
local computed = require(package.computed)
local types = require(package.types)
local scopes = require(package.scopes)
local element = require(package.element)
local hydrate = require(package.hydrate)
local graph = require(package.graph)

export type Scope = types.Scope
export type Source<T> = types.Source<T>
export type Computed<T> = types.Computed<T>
export type UsedAs<T> = types.UsedAs<T>

return {
	source = source,
	computed = computed,
	effect = effect,

	peek = graph.peek,
	is_node = types.is_node,

	element = element,
	hydrate = hydrate,

	root = scopes.root,
	use_cleanup = scopes.use_cleanup,
	use_event = scopes.use_event,
}
