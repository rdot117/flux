local function weak_ref(): { [any]: any }
	return setmetatable({}, { __mode = "kv" }) :: any
end

return weak_ref