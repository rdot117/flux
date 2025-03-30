--!strict
local package = script.Parent
local packages = package.Parent

local types = require(package.types)
local do_cleaning = require(packages.do_cleaning)
local Stack = require(packages.stack)

type Stack<T> = Stack.Stack<T>
type Scope = types.Scope

local scopes: Stack<Scope> = Stack.new()

local function in_scope()
	return scopes:peek() ~= nil
end

local function wrap(scope: Scope, callback: () -> ())
	scopes:push(scope)

	local ok, err: string? = pcall(callback)
	if not ok then
		error(`[flux]: errored while running callback in scope {err}`, 0)
	end

	if scope ~= scopes:pop() then
		error(`[flux]: scope mismatch`, 0)
	end
end

local function root(mount: () -> ())
	local scope = {}
	wrap(scope, mount)

	return function()
		do_cleaning(scope)
	end
end

local function use_cleanup(chore: any)
	local scope = scopes:peek()
	if scope == nil then
		error("[flux]: attempted to use a scope outside a scope", 0)
	end

	table.insert(scope, chore)
end

local function use_event<T...>(event: RBXScriptSignal<T...>, callback: (T...) -> ())
	use_cleanup(event:Connect(callback))
end

return {
	root = root,
	wrap = wrap,

	in_scope = in_scope,
	scopes = scopes,

	use_cleanup = use_cleanup,
	use_event = use_event,
}
