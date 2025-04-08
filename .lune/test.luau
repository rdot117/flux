-- modules
local fs = require "@lune/fs"
local process = require "@lune/process"
local roblox = require "@lune/roblox"

-- imports
local Instance = roblox.Instance
local test_package = process.args[1]

-- constants
local TEST_PLACE = "test.rbxl"

-- functions
local function inject_text_context()
    local test_file = fs.readFile(TEST_PLACE)

    local game = roblox.deserializePlace(test_file)
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

    local new_test_file = roblox.serializePlace(game)
    fs.writeFile(TEST_PLACE, new_test_file)
end

-- sourcemap updates
process.spawn("rojo", { "sourcemap", "default.project.json", "--output", "sourcemap.json" })
print "[test]: updated rojo sourcemap"

-- build rbxl
process.spawn("rojo", { "build", "default.project.json", "-o", TEST_PLACE })
print "[test]: built test file"

-- test context flag
inject_text_context()
print "[test]: injected text context"

-- run-in-roblox
print "[test]: attempting to run in roblox"
process.spawn("run-in-roblox", { "--script", "scripts/run_test.luau", "--place", TEST_PLACE }, { stdio = "forward" })