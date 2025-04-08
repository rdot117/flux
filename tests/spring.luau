--[=[
    Tests spring implementation by AxisAngle and Quenty from Nevermore.

    Desmos visualizer used for determining numbers in tests can be found here:
    https://www.desmos.com/calculator/hn2i9shxbz
]=]
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local packages = ReplicatedStorage.packages

local testlab = require(packages.testlab)
local Spring = require(packages.spring)

local it = testlab.it
local test = testlab.test
local expect = testlab.expect

test("spring physics", function()
    it("creates spring with default parameters", function()
        local spring = Spring.new()
        expect(spring).to_be_a("table")
        expect(spring.position).to_be(0)
        expect(spring.velocity).to_be(0)
    end)

    it("creates spring with initial position", function()
        local spring = Spring.new(10)
        expect(spring.position).to_be(10)
        expect(spring.velocity).to_be(0)
    end)

    it("updates spring position over time", function()
        local spring = Spring.new(0)
        spring.target = 100

        spring:step(1/60)
        
        -- position should move towards target
        expect(spring.position).to_be_greater_than(0)
        expect(spring.position).to_be_less_than(spring.target)
    end)

    it("handles damping correctly", function()
        local spring = Spring.new(0)
        spring.speed = 5
        spring.target = 1
        spring.damping = 1

        spring:step(0.8)

        -- should be close to target with minimal oscillation
        expect(math.abs(spring.position - spring.target)).to_be_less_than(0.1)
        expect(math.abs(spring.velocity)).to_be_less_than(0.37)
    end)

    it("responds to changing targets", function()
        local spring = Spring.new(0)
        spring.speed = 20
        spring.target = 50
        
        spring:step(1)

        local mid_position = spring.position
        expect(mid_position).to_be_greater_than(0)

        spring.target = 0

        spring:step(1)
        expect(spring.position).to_be_less_than(mid_position)
    end)

    it("handles different speed settings", function()
        local fast_spring = Spring.new(0)
        local slow_spring = Spring.new(0)

        fast_spring.speed = 20
        slow_spring.speed = 5

        fast_spring.target = 100
        slow_spring.target = 100

        -- Step both springs
        fast_spring:step(0.1)
        slow_spring:step(0.1)

        expect(fast_spring.position).to_be_greater_than(slow_spring.position)
    end)

    it("maintains stability over long periods", function()

        local spring = Spring.new(0)
        spring.speed = 1
        spring.target = 100

        -- should NOT sleep yet
        spring:step(12)
        expect(spring.position).to_not_be(spring.target)

        -- should sleep
        spring:step(3)
        expect(spring.position).to_be(spring.target)
        expect(spring.velocity).to_be(0)
    end)

    it("handles vector3 values", function()
        local spring = Spring.new(Vector3.new())
        spring.target = Vector3.new(1, 2, 3)

        -- step a few frames
        spring:step(1)

        local final_pos = spring.position
        expect(final_pos.X).to_be_greater_than(0)
        expect(final_pos.Y).to_be_greater_than(0)
        expect(final_pos.Z).to_be_greater_than(0)
    end)

    it("allows property modification during simulation", function()
        local spring = Spring.new(0)
        spring.target = 100
        
        -- initial simulation with default values
        spring:step(1)

        -- change to be very slow
        local mid_position = spring.position
        spring.speed = 0.000000000000001
        spring.velocity = 0

        -- ensure when we change speed, position hasn't changed much
        spring:step(10)
        expect(spring.position - mid_position).to_be_less_than(0.001)
    end)

    it("handles oscillating behavior correctly", function()
        local spring = Spring.new(0)
        spring.speed = 3
        spring.damping = 0.5
        spring.target = 10

        -- overshoots due to low damping
        spring:step(1.2)
        expect(spring.position).to_be_greater_than(10)

        -- undershoots during oscillation
        spring:step(1.2)
        expect(spring.position).to_be_less_than(10)
    end)

    it("maintains precision with small values", function()
        local spring = Spring.new(0)
        spring.speed = 10
        spring.damping = 1
        spring.target = 0.0001

        spring:step(1)

        expect(spring.position).to_be(spring.target)
    end)

    it("handles rapid target changes", function()
        local spring = Spring.new(0)
        spring.speed = 15
        spring.damping = 1

        -- Rapidly change target 10 times
        for _ = 1, 10 do
            spring.target = 10
            spring:step(1/60)
            spring.target = -10            
            spring:step(1/60)
        end

        -- should still behave stably
        spring.target = 0

        spring:step(1)
        expect(math.abs(spring.position)).to_be_less_than(1)
    end)

    it("handles color3 interpolation", function()
        local spring = Spring.new(Color3.new(0, 0, 0))
        spring.target = Color3.new(1, 0.5, 0.25)
        spring.speed = 10
        
        spring:step(1)

        local color = spring.position
        expect(color.R).to_be_greater_than(0.5)
        expect(color.G).to_be_greater_than(0.2)
        expect(color.B).to_be_greater_than(0.1)
    end)
end)

return nil