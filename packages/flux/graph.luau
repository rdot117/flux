local package = script.Parent
local packages = package.Parent

local types = require(package.types)
local Queue = require(packages.adts.queue)
local Stack = require(packages.adts.stack)

type Node = types.Node
type Use = types.Use
type UsedAs<T> = types.UsedAs<T>
type Queue<T> = Queue.Queue<T>
type Stack<T> = Stack.Stack<T>
type Readable<T> = types.Readable<T>

local updates: Queue<Node> = Queue.new()
-- local capturing: Stack<Node> = Stack.new()

local function changed(root: Node)
	local initial_size = updates:size()
	updates:enqueue(root)

	while updates:size() > initial_size do
		local node = updates:dequeue()
		if not node then
			continue
		end

		if node:_evaluate() then
			for dependent, _ in node._dependents do
				updates:enqueue(dependent)
			end
		end
	end
end

local function capture<T...>(root: Node, evaluate: (...any) -> T..., ...: any): T...
	-- capturing:push(root)

	local args = {...}
	local ok, result = pcall(function()
		return { evaluate( table.unpack(args) ) }
	end)

	if not ok then
		error(result)
	end

	-- if root ~= capturing:pop() then
	-- 	error("[flux]: node mismatch", 0)
	-- end

	return table.unpack(result)
end

local function peek<T>(node: UsedAs<T>): T
	if types.is_readable(node) then
		return (node :: Readable<T>)._value
	end

	return node :: T
end

local function use(root: Node): Use
	return function<T>(used_as: UsedAs<T>): T
		if types.is_node(used_as) then
			local dependency = (used_as :: any) :: Node
			root._dependencies[dependency] = true
			dependency._dependents[root] = true
		end

		return peek(used_as)
	end
end

return {
	changed = changed,
	capture = capture,
	use = use,
	peek = peek,
}
