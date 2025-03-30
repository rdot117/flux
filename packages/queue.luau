--!strict
type Node<T> = {
	value: T,
	next: Node<T>?,
}

export type Queue<T> = {
	_size: number,
	_head: Node<T>?,
	_tail: Node<T>?,

	size: (self: Queue<T>) -> number,
	is_empty: (self: Queue<T>) -> boolean,

	enqueue: (self: Queue<T>, value: T) -> (),
	peek: (self: Queue<T>) -> T?,
	dequeue: (self: Queue<T>) -> T?,

	destroy: (self: Queue<T>) -> (),
}

local Queue = {}
Queue.__index = Queue

function Queue.new()
	return (setmetatable({ _size = 0,}, Queue) :: any) :: Queue<any>
end

function Queue.size<T>(self: Queue<T>)
	return self._size
end

function Queue.is_empty<T>(self: Queue<T>)
	return self:size() == 0
end

function Queue.enqueue<T>(self: Queue<T>, value: T)
	if self._tail then
		self._tail.next = {
			value = value,
		}

		self._tail = self._tail.next
	else
		self._head = {
			value = value,
		}

		self._tail = self._head
	end

	self._size += 1
end

function Queue.peek<T>(self: Queue<T>): T?
	if not self._head then
		return
	end

	return self._head.value
end

function Queue.dequeue<T>(self: Queue<T>): T?
	if not self._head then
		return
	end

	local popped = self._head
	self._head = popped.next
	self._size -= 1

	if popped == self._tail then
		self._tail = nil
	end

	return popped.value
end

function Queue.destroy<T>(self: Queue<T>)
	self._size = 0
	self._head = nil
	self._tail = nil
end

return Queue
