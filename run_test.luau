local ReplicatedStorage = game:GetService("ReplicatedStorage")

local tests = ReplicatedStorage.tests
local packages = ReplicatedStorage.packages
local test_context = ReplicatedStorage:FindFirstChild("test_context") :: StringValue

local testlab = require(packages.testlab)

if test_context.Value == "all" then
    testlab.run_tests(tests)
elseif test_context.Value == "package" then
    local test_package = test_context:GetAttribute("test_package")
    local package_tests = tests:FindFirstChild(test_package)
    if not package_tests then
        return nil
    end

    testlab.run_tests(package_tests)
end

return nil