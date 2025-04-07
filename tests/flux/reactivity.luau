local ReplicatedStorage = game:GetService("ReplicatedStorage")

local packages = ReplicatedStorage.packages

local testlab = require(packages.testlab)
local flux = require(packages.flux)

local use_cleanup = flux.use_cleanup

local it = testlab.it
local test = testlab.test
local expect = testlab.expect
local source = flux.source
local computed = flux.computed
local effect = flux.effect
local peek = flux.peek

type Source<T> = flux.Source<T>

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
        local trigger_count = 0

        effect(function(use)
            use(count_source)
            trigger_count += 1
        end)

        expect(trigger_count).to_be(1)

        count_source(2)
        expect(trigger_count).to_be(2)
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
        
        source_a(15) -- should not affect the computed
        expect(peek(conditional_computed)).to_be(20)
    end)

    it("handles undefined/nil values correctly", function()
        local nil_source = source(nil) :: Source<string?>
        local computed_with_nil = computed(function(use)
            return use(nil_source) or "default"
        end)

        expect(peek(computed_with_nil)).to_be("default")

        nil_source("value")
        expect(peek(computed_with_nil)).to_be("value")
    end)

    it("maintains correct state with rapid updates", function()
        local count_source = source(0)
        local last_value = 0

        effect(function(use)
            last_value = use(count_source)
        end)

        for i = 1, 100 do
            expect(last_value).to_be(i - 1)
            count_source(i)
        end

        expect(last_value).to_be(100)
    end)

    it("handles complex data structures", function()
        local data = source({ count = 0, text = "hello" })

        local struct_computed = computed(function(use)
            return use(data).count + string.len(use(data).text)
        end)

        expect(peek(struct_computed)).to_be(5)

        data({ count = 10, text = "world" })
        expect(peek(struct_computed)).to_be(15)
    end)

    it("properly cleans up effects", function()
        local count = 0
        local cleanup_count = 0
        local trigger = source(true)
        
        effect(function(use)
            if use(trigger) then
                count += 1
            end

            use_cleanup(function()
                cleanup_count += 1
                count -= 1
            end)
        end)

        expect(count).to_be(1)
        expect(cleanup_count).to_be(0)
        
        trigger(false)
        expect(cleanup_count).to_be(1)
        expect(count).to_be(0)
    end)

    it("handles conditional effect creation", function()
        local should_track = source(true)
        local value = source(0)

        local track_count = 0

        effect(function(use)
            if use(should_track) then
                use(value)
            end

            track_count += 1
        end)

        expect(track_count).to_be(1)

        value(1) -- should trigger
        expect(track_count).to_be(2)

        should_track(false) -- should trigger
        expect(track_count).to_be(3)

        value(2) -- should not trigger
        expect(track_count).to_be(3)

        should_track(true) -- should trigger
        expect(track_count).to_be(4)
    end)
end)

return nil
