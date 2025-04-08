local package = script.Parent

local scopes = require(package.scopes)

--[=[
    Returns a constructor that wraps the object in a scope
]=]

local function constructor<R, P...>(constructor: (P...) -> R): (P...) -> R
    return function(...: P...): R
        local handle = constructor(...)
    
        if scopes.in_scope() then
            scopes.use_cleanup(handle)
        end
    
        return handle
    end
end

return constructor

