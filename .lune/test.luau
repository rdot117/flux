local fs = require "@lune/fs"
local process = require "@lune/process"
local roblox = require "@lune/roblox"
local install = require "install"

local Instance = roblox.Instance
install()

local test_package = process.args[1]

local function inject_text_context()
    local build_file = fs.readFile("build.rbxl")

    local game = roblox.deserializePlace(build_file)
    local ReplicatedStorage = game:GetService("ReplicatedStorage")

    local test_context = Instance.new("StringValue")
    test_context.Name = "test_context"
    test_context.Parent = ReplicatedStorage :: any

    if test_package then
        test_context.Value = "package"
        test_context:SetAttribute("test_package", test_package)
    else
        test_context.Value = "all"
    end

    local new_build_file = roblox.serializePlace(game)
    fs.writeFile("build.rbxl", new_build_file)
end

-- sourcemap updates
process.spawn("rojo", { "sourcemap", "default.project.json", "--output", "sourcemap.json" })
print "[test]: updated rojo sourcemap"

-- build rbxl
process.spawn("rojo", {"build", "-o", "build.rbxl"})
print "[test]: built test file"

-- test context flag
inject_text_context()
print "[test]: injected text context"

-- run-in-roblox
print "[test]: attempting to run in roblox"
process.spawn("run-in-roblox", { "--script", "run_test.luau", "--place", "build.rbxl" }, { stdio = "forward" })