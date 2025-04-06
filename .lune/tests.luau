-- local fs = require "@lune/fs"
local process = require "@lune/process"
local install = require "install"

install()

-- local test_file = process.args[1]
-- if not test_file then
--     print("[test] usage: `lune run test test_name`")
--     return
-- end

-- local function find_valid_path(path: string): string?
--     local ok = pcall(fs.readFile, path)
--     if ok then
--         return path
--     end

--     ok = pcall(fs.readFile, path .. ".luau")
--     if ok then
--         return path .. ".luau"
--     end

--     ok = pcall(fs.readFile, path .. ".lua")
--     if ok then
--         return path .. ".lua"
--     end

--     return
-- end

-- -- validate path
-- local path = find_valid_path("tests/" .. test_file)
-- if not path then
--     print(string.format("[test]: invalid test provided %s", test_file))
--     return
-- end

-- print("[tests]: found test file at " .. path)

-- sourcemap updates
process.spawn("rojo", { "sourcemap", "default.project.json", "--output", "sourcemap.json" })
print "[tests]: updated rojo sourcemap"

-- build rbxl
process.spawn("rojo", {"build", "-o", "build.rbxl"})
print "[tests]: built test file"

-- run-in-roblox
print "[tests]: attempting to run in roblox"
process.spawn("run-in-roblox", { "--script", "run_tests.luau", "--place", "build.rbxl" }, { stdio = "forward" })