local package = script.Parent

local tests = require(package.tests)
local expect = require(package.expect)

return {
    run_tests = tests.run_tests,
    expect = expect,

    test = tests.test_suite,
    it = tests.test_case,
}