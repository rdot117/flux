local ReplicatedStorage = game:GetService("ReplicatedStorage")

local packages = ReplicatedStorage.packages

local lab = require(packages.lab.exports)
local flux = require(packages.flux.exports)

local it = lab.it
local test = lab.test
local expect = lab.expect
local source = flux.source
local computed = flux.computed
local effect = flux.effect
local peek = flux.peek

test("flux reactivity", function()
    it("updates sources", function()
        local count_source = source(10)
        expect(peek(count_source)).to_be(10)
        count_source(20)
        expect(peek(count_source)).to_be(20)
    end)

    it("computes values based on sources", function()
        local count_source = source(5)
        local doubled_computed = computed(function(use)
            return use(count_source) * 2
        end)
        expect(peek(doubled_computed)).to_be(10)
        count_source(7)
        expect(peek(doubled_computed)).to_be(14)
    end)

    it("triggers effects when sources change", function()
        local count_source = source(1)
        local effect_triggered = false

        effect(function(use)
            local _ = use(count_source)
            effect_triggered = true
        end)

        count_source(2)
        expect(effect_triggered).to_be(true)
    end)

    it("handles multiple sources in a computed", function()
        local source_a = source(3)
        local source_b = source(4)
        local sum_computed = computed(function(use)
            return use(source_a) + use(source_b)
        end)

        expect(peek(sum_computed)).to_be(7)
        source_a(5)
        expect(peek(sum_computed)).to_be(9)
        source_b(6)
        expect(peek(sum_computed)).to_be(11)
    end)

    it("handles nested computeds", function()
        local base_source = source(2)
        local doubled_computed = computed(function(use)
            return use(base_source) * 2
        end)

        local tripled_computed = computed(function(use)
            return use(doubled_computed) * 1.5
        end)

        expect(peek(tripled_computed)).to_be(6)
        base_source(4)
        expect(peek(tripled_computed)).to_be(12)
    end)

    it("cleans up dependencies when switching", function()
        local toggle_source = source(true)
        local source_a = source(10)
        local source_b = source(20)
        local conditional_computed = computed(function(use)
            if use(toggle_source) then
                return use(source_a)
            else
                return use(source_b)
            end
        end)

        expect(peek(conditional_computed)).to_be(10)
        toggle_source(false)
        expect(peek(conditional_computed)).to_be(20)
        source_a(15) -- Should not affect the computed
        expect(peek(conditional_computed)).to_be(20)
    end)
end)

return nil
