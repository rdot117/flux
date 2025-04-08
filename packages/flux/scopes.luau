local package = script.Parent
local packages = package.Parent

local types = require(package.types)
local do_cleaning = require(packages.do_cleaning)
local Stack = require(packages.adts.stack)

type Stack<T> = Stack.Stack<T>
type Scope = types.Scope

local scopes: Stack<Scope> = Stack.new()

local function in_scope()
	return scopes:peek() ~= nil
end

local function wrap<P>(scope: Scope, callback: (() -> P) | (() -> ())): P
	scopes:push(scope)

	local ok, err = pcall(callback)

	if scope ~= scopes:pop() then
		error(`[flux]: scope mismatch`, 0)
	end

	if not ok then
		error(`[flux]: error in wrap {err}`, 0)
	end

	return (err :: any)
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
