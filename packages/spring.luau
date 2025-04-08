local RunService = game:GetService("RunService")

local EPSILON = 1e-3

export type Spring<T> = {
	p: T, position: T,
	v: T, velocity: T,
	t: T, target: T,

	s: number, speed: number,
	d: number, damping: number,
	_speed: number,
	_damping: number,

	_type: string,
	_time: number,
	_positions: {number},
	_velocities: {number},
	_targets: {number},

	_binds: { [() -> ()]: boolean },
	_bind_conn: RBXScriptConnection | false,

	_watch: (self: Spring<T>) -> (),
	_update: (self: Spring<T>, dt: number?) -> ({number}, {number}),

	_should_sleep: (self: Spring<T>, positions: { number }, velocities: { number }) -> boolean,
	_sleep: (self: Spring<T>) -> (),

	step: (self: Spring<T>, dt: number) -> (),
	bind: (self: Spring<T>, bind: () -> ()) -> () -> (),
	destroy: (self: Spring<T>) -> (),
}

local function from_quaternion(x: number, y: number, z: number, w: number)
	return CFrame.new(0, 0, 0, x, y, z, w)
end

local function to_quaternion(cframe: CFrame)
	local axis, theta = cframe:ToAxisAngle()
	theta = theta * 0.5
	axis = axis * math.sin(theta)
	return { axis.X, axis.Y, axis.Z, math.cos(theta) }
end

local function from_oklab(lab: {number})
	local  lRoot = lab[1] + lab[2] * 0.3963377774 + lab[3] * 0.2158037573
	local  mRoot = lab[1] - lab[2] * 0.1055613458 - lab[3] * 0.0638541728
	local  sRoot = lab[1] - lab[2] * 0.0894841775 - lab[3] * 1.2914855480

	local  l = lRoot ^ 3
	local  m = mRoot ^ 3
	local  s = sRoot ^ 3

	local  red = l * 4.0767416621 - m * 3.3077115913 + s * 0.2309699292
	local  green = l * -1.2684380046 + m * 2.6097574011 - s * 0.3413193965
	local  blue = l * -0.0041960863 - m * 0.7034186147 + s * 1.7076147010

	return Color3.new(
		math.clamp(red, 0, 1),
		math.clamp(green, 0, 1),
		math.clamp(blue, 0, 1)
	)
end

local function to_oklab(rgb: Color3)
	local l = rgb.R * 0.4122214708 + rgb.G * 0.5363325363 + rgb.B * 0.0514459929
	local m = rgb.R * 0.2119034982 + rgb.G * 0.6806995451 + rgb.B * 0.1073969566
	local s = rgb.R * 0.0883024619 + rgb.G * 0.2817188376 + rgb.B * 0.6299787005

	local lRoot = l ^ (1/3)
	local mRoot = m ^ (1/3)
	local sRoot = s ^ (1/3)

	return {
		lRoot * 0.2104542553 + mRoot * 0.7936177850 - sRoot * 0.0040720468,
		lRoot * 1.9779984951 - mRoot * 2.4285922050 + sRoot * 0.4505937099,
		lRoot * 0.0259040371 + mRoot * 0.7827717662 - sRoot * 0.8086757660
	}
end

local function update(p0: number, v0: number, p1: number, d: number, s: number, t: number)
	local d2 = d*d

	local h, si, co
	if d2 < 1 then
		h = math.sqrt(1 - d2)
		local ep = math.exp(-d*t)/h
		co, si = ep*math.cos(h*t), ep*math.sin(h*t)
	elseif d2 == 1 then
		h = 1
		local ep = math.exp(-d*t)/h
		co, si = ep, ep*t
	else
		h = math.sqrt(d2 - 1)
		local u = math.exp((-d + h)*t)/(2*h)
		local v = math.exp((-d - h)*t)/(2*h)
		co, si = u + v, u - v
	end

	local a0 = h*co + d*si
	local a1 = 1 - (h*co + d*si)
	local a2 = si/s

	local b0 = -s*si
	local b1 = s*si
	local b2 = h*co - d*si

	return
		a0*p0 + a1*p1 + a2*v0,
		b0*p0 + b1*p1 + b2*v0
end

local function unpack_components(packed: any): {number}
	if typeof(packed) == "number" then
		return { packed }
	elseif typeof(packed) == "Vector3" then
		return { packed.X, packed.Y, packed.Z }
	elseif typeof(packed) == "Color3" then
		return to_oklab(packed)
	elseif typeof(packed) == "CFrame" then
		return to_quaternion(packed)
	elseif typeof(packed) == "UDim2" then
	   return { packed.X.Scale, packed.X.Offset, packed.Y.Scale, packed.Y.Offset }
	else
		error("[spring]: unable to unpack type " .. typeof(packed))
	end
end

local function pack_type(type: string, unpacked: { number }): any
	if type == "number" then
		return unpacked[1]
	elseif type == "Vector3" then
		return Vector3.new(unpacked[1], unpacked[2], unpacked[3])
	elseif type == "Color3" then
		return from_oklab(unpacked)
	elseif type == "CFrame" then
		return from_quaternion(unpacked[1], unpacked[2], unpacked[3], unpacked[4])
	elseif type == "UDim2" then
	   return UDim2.new(unpacked[1], unpacked[2], unpacked[3], unpacked[4])
	else
		error("[spring]: unable to pack animatable type " .. type)
	end
end

local Spring = {}

Spring.__index = function<T>(self: Spring<T>, key: string)

	-- packed keys
	if key == "p" or key == "position" then
		local positions = self:_update()
		return pack_type(self._type, positions)
	elseif key == "v" or key == "velocity" then
		local _, velocities = self:_update()
		return pack_type(self._type, velocities)
	elseif key == "t" or key == "target" then
		local targets = self._targets
		return pack_type(self._type, targets)
	end

	-- properties
	if key == "s" or key == "speed" then
		return self._speed
	elseif key == "d" or key == "damping" then
		return self._damping
	end

	-- methods
	if Spring[key] then
		return Spring[key]
	end

	return
end

Spring.__newindex = function<T>(self: Spring<T>, key: string, value: T)

	-- motion keys
	if key == "p" or key == "position" then
		local new_type = typeof(value)
		if new_type ~= self._type then
			error("[spring]: provided invalid type " .. new_type)
		end

		local positions = unpack_components(value)
		local _, velocities = self:_update()
		self._time = os.clock()
		self._positions = positions
		self._velocities = velocities

		self:_watch()
	elseif key == "v" or key == "velocity" then
		local new_type = typeof(value)
		if new_type ~= self._type then
			error("[spring]: provided invalid type " .. new_type)
		end

		local velocities = unpack_components(value)
		local positions = self:_update()
		self._time = os.clock()
		self._positions = positions
		self._velocities = velocities

		self:_watch()
	elseif key == "t" or key == "target" then
		local new_type = typeof(value)
		if new_type ~= self._type then
			error("[spring]: provided invalid type " .. new_type)
		end

		local targets = unpack_components(value)
		local positions, velocities = self:_update()
		self._time = os.clock()
		self._positions = positions
		self._velocities = velocities
		self._targets = targets

		self:_watch()
	elseif key == "s" or key == "speed" then
		if typeof(value) ~= "number" then
			error("[spring]: invalid speed type " .. typeof(value))
		end

		local positions, velocities = self:_update()
		self._time = os.clock()
		self._positions = positions
		self._velocities = velocities
		self._speed = value

		self:_watch()
	elseif key == "d" or key == "damping" then
		if typeof(value) ~= "number" then
			error("[spring]: invalid damping type " .. typeof(value))
		end

		local positions, velocities = self:_update()
		self._time = os.clock()
		self._positions = positions
		self._velocities = velocities
		self._damping = value

		self:_watch()
	else
		error("[spring]: unable to set key " .. key)
	end
end

function Spring.new<T>(initial: T?)
	local self = {} :: Spring<T>

	initial = initial or 0 :: any

	self._time = os.clock()
	self._type = typeof(initial)
	self._positions = unpack_components(initial)
	self._velocities = table.create(#self._positions, 0)
	self._targets = table.clone(self._positions)
	self._bind_conn = false
	self._binds = {}

	self._speed = 10
	self._damping = 1

	return (setmetatable(self, Spring) :: any) :: Spring<T>
end

function Spring._update<T>(self: Spring<T>, dt: number?)
	local new_positions = {}
	local new_velocities = {}

	local delta = if dt then self._speed * dt else self._speed * (os.clock() - self._time)

	for i = 1, #self._positions do
		local p0 = self._positions[i]
		local v0 = self._velocities[i]
		local p1 = self._targets[i]

		local p, v = update(p0, v0, p1, self._damping, self._speed, delta)
		new_positions[i], new_velocities[i] = p, v
	end

	return new_positions, new_velocities
end

function Spring._should_sleep<T>(self: Spring<T>, positions: { number }, velocities: { number })
	
	for i = 1, #positions do
		local position = positions[i]
		local velocity = velocities[i]
		local target = self._targets[i]

		local displacement = math.abs(target - position)
		if displacement > EPSILON or math.abs(velocity) > EPSILON then
			return false
		end
	end

	return true
end

function Spring._sleep<T>(self: Spring<T>)

	-- no point in checking spring state
	-- once it has fallen asleep
	if self._bind_conn then
		self._bind_conn:Disconnect()
		self._bind_conn = false
	end

	self._positions = table.clone(self._targets)
	self._velocities = table.create(#self._positions, 0)
	self._time = os.clock()
end

function Spring._watch<T>(self: Spring<T>)

	local positions = self._positions
	local velocities = self._velocities

	-- no need to watch if we should sleep
	if self:_should_sleep(positions, velocities) then
		self:_sleep()
		return
	end

	if self._bind_conn then
		return
	end

	self._bind_conn = RunService.Heartbeat:Connect(function()
		positions, velocities = self:_update()

		if self:_should_sleep(positions, velocities) then
			self:_sleep()
		end

		-- update binds
		for bind, _ in self._binds do
			task.spawn(bind)
		end
	end)
end

function Spring.step<T>(self: Spring<T>, dt: number)
	local new_positions, new_velocities = self:_update(dt)
	
	self._positions = new_positions
	self._velocities = new_velocities
	self._time = os.clock()
	
	self:_watch()
end

function Spring.bind<T>(self: Spring<T>, bind: () -> ())
	self._binds[bind] = true

	return function()
		self._binds[bind] = nil
	end
end

function Spring.destroy<T>(self: Spring<T>)
	if self._bind_conn then
		self._bind_conn:Disconnect()
		self._bind_conn = false
	end

	self._binds = {}
end

return Spring