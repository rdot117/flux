local ReplicatedStorage = game:GetService("ReplicatedStorage")

local packages = ReplicatedStorage.packages

local testlab = require(packages.testlab)
local flux = require(packages.flux)

local source = flux.source
local computed = flux.computed
local effect = flux.effect
local root = flux.root
local use_cleanup = flux.use_cleanup

local weak_ref = testlab.weak_ref
local collect = testlab.collect
local it = testlab.it
local test = testlab.test
local expect = testlab.expect

type Source<T> = flux.Source<T>
type Computed<T> = flux.Computed<T>
type Effect = flux.Effect

test("flux memory management", function()

    it("garbage collects unused sources", function()
        local weak_table = weak_ref()

        local source = source(10) :: Source<any>
        weak_table.source = source

        expect(weak_table.source).to_be(source)
        
        collect()
        expect(weak_table.source).to_be(source)

        source = nil :: any

        collect()
        expect(weak_table.source).to_be(nil)
    end)

    it("garbage collects unused computeds", function()
        local weak_table = weak_ref()

        local source = source(10) :: Source<any>
        weak_table.source = source

        local computed = computed(function(use)
            return use(source) * 2
        end)

        weak_table.computed = computed
        computed = nil :: any

        expect(weak_table.source).to_be(source)
        expect(weak_table.computed == nil).to_be(false)
        
        collect()
        expect(weak_table.source).to_be(source)
        expect(weak_table.computed == nil).to_be(false)

        source = nil :: any

        collect()
        expect(weak_table.source).to_be(nil)
        expect(weak_table.computed).to_be(nil)
    end)

    it("garbage collects unused effects", function()
        local weak_table = weak_ref()

        local source = source(10) :: Source<any>
        weak_table.source = source

        local effect = effect(function(use)
            use(source)
        end)

        weak_table.effect = effect
        effect = nil :: any

        expect(weak_table.source).to_be(source)
        expect(weak_table.effect == nil).to_be(false)
        
        collect()
        expect(weak_table.source).to_be(source)
        expect(weak_table.effect == nil).to_be(false)

        source = nil :: any

        collect()
        expect(weak_table.source).to_be(nil)
        expect(weak_table.effect).to_be(nil)
    end)

    it("cleans up scopes and their dependencies", function()
        local weak_table = weak_ref()

        local _scope = root(function()
            local source = source(10)
            local computed = computed(function(use)
                return use(source) * 2
            end)

            local effect = flux.effect(function(use)
                use(computed)
            end)

            weak_table.source = source
            weak_table.computed = computed
            weak_table.effect = effect
        end)

        collect()
        expect(weak_table.source == nil).to_be(false)
        expect(weak_table.computed == nil).to_be(false)
        expect(weak_table.effect == nil).to_be(false)

       _scope = nil :: any

        collect()
        expect(weak_table.source).to_be(nil)
        expect(weak_table.computed).to_be(nil)
        expect(weak_table.effect).to_be(nil)
    end)

    it("handles nested scopes cleanup", function()
        local weak_table = weak_ref()

        local _scope, inner_scope = nil, nil

        _scope = root(function()
            inner_scope = root(function()
                weak_table.source = source(20)
            end)

            use_cleanup(inner_scope)
        end)

        collect()
        expect(weak_table.source == nil).to_be(false)

        inner_scope = nil :: any

        collect()
        expect(weak_table.source == nil).to_be(false)

        _scope = nil :: any

        collect()
        expect(weak_table.source).to_be(nil)
    end)
end)

return nil
