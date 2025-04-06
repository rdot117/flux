local ReplicatedStorage = game:GetService("ReplicatedStorage")

local packages = ReplicatedStorage.packages

local lab = require(packages.lab)
local flux = require(packages.flux)

local source = flux.source
local computed = flux.computed
local element = flux.element
local root = flux.root

local weak_ref = lab.weak_ref
local collect = lab.collect
local it = lab.it
local test = lab.test
local expect = lab.expect

test("flux element instance management", function()
    it("updates instance properties from sources", function()
        local base_position = source(Vector3.new(0, 0, 0))
        local part_name = source("test_part")
        
        local test_part = element "Part" {
            Position = base_position,
            Name = part_name
        } :: BasePart

        expect(test_part.Position == Vector3.new(0, 0, 0)).to_be(true)
        expect(test_part.Name == "test_part").to_be(true)

        base_position(Vector3.new(1, 1, 1))
        part_name("updated_test_part")

        expect(test_part.Position == Vector3.new(1, 1, 1)).to_be(true)
        expect(test_part.Name == "updated_test_part").to_be(true)
    end)

    it("handles invalid property assignments", function()
        expect().to_throw(function()
            element "Part" {
                InvalidProperty = "test"
            }
        end)

        expect().to_throw(function()
            element "Part" {
                Position = "not_a_vector3"
            }
        end)
    end)

    it("handles static children in props", function()
        local test_folder = element "Folder" {
            Name = "parent_folder",

            element "Part" {
                Name = "test_child_1"
            },

            element "Part" {
                Name = "test_child_2"
            }
        } :: Folder

        expect(#test_folder:GetChildren() == 2).to_be(true)
        expect(test_folder:FindFirstChild("test_child_1")).to_not_be(nil)
        expect(test_folder:FindFirstChild("test_child_2")).to_not_be(nil)
    end)

    it("handles dynamic children in props", function()
        local num_children = source(2)
        local parent_folder = element "Folder" {
            Name = "test_folder",
            
            computed(function(use)
                local count = use(num_children)
                local children = {}
                
                for i = 1, count do
                    children[i] = element "Part" {
                        Name = "test_child_" .. i
                    }
                end
                
                return children
            end)
        } :: Folder

        expect(#parent_folder:GetChildren() == 2).to_be(true)
        expect(parent_folder:FindFirstChild("test_child_1")).to_not_be(nil)
        expect(parent_folder:FindFirstChild("test_child_2")).to_not_be(nil)

        num_children(1)
        expect(#parent_folder:GetChildren() == 1).to_be(true)
        expect(parent_folder:FindFirstChild("test_child_1")).to_not_be(nil)
        expect(parent_folder:FindFirstChild("test_child_2")).to_be(nil)

        num_children(0)
        expect(#parent_folder:GetChildren() == 0).to_be(true)
    end)

    it("handles erroring computeds", function()
        local should_error = source(false)
        local test_part = element "Part" {
            Position = computed(function(use)
                if use(should_error) then
                    error("Test error")
                end
                return Vector3.new()
            end)
        } :: BasePart

        expect(test_part.Position == Vector3.new()).to_be(true)

        expect().to_throw(function()
            should_error(true)
        end)
    end)

    it("cleans up when scope is destroyed", function()
        local weak_table = weak_ref()
        
        local _test_scope = root(function()
            local test_folder = element "Folder" {
                Name = "test_folder",

                element "Part" {
                    Name = "child_part"
                }
            } :: Folder

            weak_table.instance = test_folder
        end)

        expect(weak_table.instance:FindFirstChild("child_part")).to_not_be(nil)
        
        _test_scope = nil :: any
        collect()
        
        expect(weak_table.instance == nil).to_be(true)
    end)
end)

return nil