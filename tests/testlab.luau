local ReplicatedStorage = game:GetService("ReplicatedStorage")
local packages = ReplicatedStorage.packages

local testlab = require(packages.testlab)

local test = testlab.test
local it = testlab.it
local expect = testlab.expect
local log = testlab.log

test("lab framework", function()
    it("handles basic assertions", function()
        expect(true).to_be(true)
        expect(5).to_be(5)
        expect("test").to_be("test")
        expect(nil).to_be(nil)
    end)

    it("handles negative assertions", function()
        expect(5).to_not_be(6)
        expect("hello").to_not_be("world")
        expect(true).to_not_be(false)
    end)

    it("handles type checking", function()
        expect(5).to_be_a("number")
        expect("test").to_be_a("string")
        expect(function() end).to_be_a("function")
        expect({}).to_be_a("table")
    end)

    it("handles error catching", function()
        expect().to_throw(function()
            error("test error")
        end)

        expect().to_not_throw(function()
            -- no error
        end)
    end)

    local test_value = 0
    it("runs tests in order", function()
        test_value += 1
        expect(test_value).to_be(1)
    end)

    it("maintains state between tests", function()
        test_value += 1
        expect(test_value).to_be(2)
    end)

    it("logs: hello testlab!", function()
        log("hello testlab!")
    end)
end)

return nil
