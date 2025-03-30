local types = require "../flux/types"
local source = require "../flux/source"
local effect = require "../flux/effect"
local computed = require "../flux/computed"
local scopes = require "../flux/scopes"
local element = require "../flux/element"
local hydrate = require "../flux/hydrate"
local graph = require "../flux/graph"
local context = require "../flux/context"
local spring = require "../flux/spring"

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
