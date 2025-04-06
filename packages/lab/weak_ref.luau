--[=[
    Retrurns a weak reference table.
    Weak references are useful for caching or storing objects
]=]
function weak_ref(): { [any]: any }
    return setmetatable({}, { __mode = "kv" }) :: any
end

return weak_ref