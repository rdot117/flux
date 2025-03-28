--!strict
local package = script.Parent
local shared = package.Parent

local types = require(package.types)
local scopes = require(package.scopes)
local graph = require(package.graph)
local effect = require(package.effect)
local Node = require(package.node)
local InternalSpring = require(shared.spring)

type UsedAs<T> = types.UsedAs<T>
type Spring<T> = types.Spring<T>
type SpringImpl<T> = types.SpringImpl<T>

local peek = graph.peek

local Spring = {}
setmetatable(Spring, Node)

Spring.__index = function<T>(self: Spring<T>, key: string): any
	if key == "_value" or key == "p" or key == "position" then
		return self._internal_spring.position
	elseif key == "v" or key == "velocity" then
		return self._internal_spring.velocity
	end

	if Spring[key] then
		return Spring[key]
	elseif Node[key] then
		return Node[key]
	end

	return
end

Spring.__newindex = function<T>(self: Spring<T>, key: string, value: any)
	if key == "p" or key == "position" then
		self._internal_spring.position = value
	elseif key == "v" or key == "velocity" then
		self._internal_spring.velocity = value
	else
		error("[spring]: unable to set key " .. key)
	end
end

function Spring.new<T>(damping: UsedAs<number>, speed: UsedAs<number>, target: UsedAs<T>): Spring<T>
	local self = Node.new() :: SpringImpl<T>

	self._internal_spring = InternalSpring.new(peek(target))
	
	self._internal_spring:bind(function()
		self._value = self._internal_spring.position
		graph.changed(self)
	end)

	self._unbind = effect(function(use)
		self._internal_spring.target = use(target)
		self._internal_spring.damping = use(damping)
		self._internal_spring.speed = use(speed)
	end)

	return (setmetatable(self, Spring) :: any) :: Spring<T>
end

function Spring._evaluate<T>(self: SpringImpl<T>)
	return true
end

function Spring.destroy<T>(self: SpringImpl<T>)
	self._value = (nil :: any) :: T

	self._unbind()
	self._internal_spring:destroy()

	Node.destroy(self)
end

return function<T>(damping: UsedAs<number>, speed: UsedAs<number>, target: UsedAs<T>)
	local handle = Spring.new(damping, speed, target)

	if scopes.in_scope() then
		scopes.use_cleanup(handle)
	end

	return handle
end