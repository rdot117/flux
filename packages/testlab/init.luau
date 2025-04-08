local package = script

local tests = require(package.tests)
local expect = require(package.expect)
local collect = require(package.collect)
local weak_ref = require(package.weak_ref)
local log = require(package.log)

return {
    collect = collect,
    weak_ref = weak_ref,
    log = log,
    run_tests = tests.run_tests,
    expect = expect,

    test = tests.test_suite,
    it = tests.test_case,
}