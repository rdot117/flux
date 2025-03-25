export type Stack<T> = {
	_size: number,
	_values: {T},
	
	size: (self: Stack<T>) -> number,
	is_empty: (self: Stack<T>) -> boolean,

	push: (self: Stack<T>, item: T) -> (),
	peek: (self: Stack<T>) -> T?,
	pop: (self: Stack<T>) -> T?,

	destroy: (self: Stack<T>) -> (),
}

local Stack = {}
Stack.__index = Stack

function Stack.new<T>(initial: {T}?): Stack<T>
	local self = (setmetatable({}, Stack) :: any) :: Stack<T>

	self._values = initial or {}
	self._size = if initial then #initial else 0

	return self
end

function Stack.size<T>(self: Stack<T>)
	return self._size
end

function Stack.is_empty<T>(self: Stack<T>)
	return self:size() == 0
end

function Stack.push<T>(self: Stack<T>, item: T)
	self._size += 1
	self._values[self._size] = item
end

function Stack.peek<T>(self: Stack<T>)
	if self._size <= 0 then
		return
	end

	return self._values[self._size]
end

function Stack.pop<T>(self: Stack<T>)
	if self._size <= 0 then
		return
	end

	local popped = self._values[self._size]
	self._values[self._size] = nil
	self._size -= 1

	return popped
end

function Stack.destroy<T>(self: Stack<T>)
	self._size = 0
	table.clear(self._values)
end

return Stack