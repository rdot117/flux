local process = require "@lune/process"

--[=[
    Installs all rokit tools and wally packages,
    then updates the rojo sourcemap and wally-package-types
    accordingly
]=]
local function install()
    process.spawn("rokit", { "install" })

    -- process.spawn("wally", { "install" })
    -- process.spawn("rojo", { "sourcemap", "default.project.json", "--output", "sourcemap.json" })
    -- process.spawn("wally-package-types", { "--sourcemap", "sourcemap.json", "Packages/" })
end

return install
