local package = script.Parent
local packages = package.Parent

local InternalSpring = require(packages.spring)

type InternalSpring<T> = InternalSpring.Spring<T>

export type Scope = {unknown}

-- node types
export type Node = {
	_evaluate: (self: Node) -> boolean,

	_dependents: NodeSet,
	_dependencies: NodeSet,

	_clear_dependencies: (self: Node) -> NodeSet,
	_clear_dependents: (self: Node) -> NodeSet,

	destroy: (self: Node) -> (),
}

export type NodeSet = { [Node]: true }

-- internal implementations
export type Readable<T> = { _value: T }
export type Usable<T> = Node & Readable<T>

export type SourceImpl<T> = Usable<T>

export type ComputedImpl<T> = Usable<T> & {
	_source: (use: Use) -> T,
	_use: Use,
}

export type EffectImpl = Node & {
	_scope: Scope,
	_source: (use: Use) -> (),
	_use: Use,
}

-- external apis
export type UsedAs<T> = T | Readable<T>
export type Source<T> = SourceImpl<T> & (new_value: T) -> T
export type Computed<T> = ComputedImpl<T>
export type Effect = () -> ()

-- consumer utilities
export type Use = <T>(used_as: UsedAs<T>) -> T

-- animation
export type SpringImpl<T> = Usable<T> & {
	position: T,
	velocity: T,

	_target: UsedAs<T>,
	_speed: UsedAs<number>,
	_damping: UsedAs<number>,

	_unbind: () -> (),
	_internal_spring: InternalSpring<T>,
}

export type Spring<T> = SpringImpl<T>

-- context
export type ContextImpl<T> = Readable<T>
export type Context<T> = <P...>(newValue: T, during: (...unknown) -> (P...)) -> P... & ContextImpl<T>

-- instances
export type Children = Instance | { Instance }

export type SpecialKey = {
    apply: (instance: Instance, ...unknown) -> ()
}

-- type functions
local function is_special_key(node: any)
    return typeof(node) == "table"
        and typeof(node.apply) == "function"
end

local function is_readable(node: any)
	return typeof(node) == "table"
end

local function is_node(node: any)
	return typeof(node) == "table"
		and typeof(node._dependencies) == "table"
		and typeof(node._dependents) == "table"
		and typeof(node.destroy) == "function"
end

return {
    is_special_key = is_special_key,
	is_readable = is_readable,
	is_node = is_node,
}
