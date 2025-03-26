--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local flux = require(ReplicatedStorage.shared.flux)
local lab = require(ReplicatedStorage.lab)

local source = flux.source
local peek = flux.peek

type Source<T> = flux.Source<T>

lab.test("simple frame and property assignment", function()
	local frame = flux.element "Frame" {
		Name = "test_frame",
	}

	lab.expect(frame.Name == "test_frame")

	frame:Destroy()
end)

lab.test("simple parent", function()
	local part = flux.element "Part" {
		Name = "test_part",
		Parent = workspace,
	}

	lab.expect(part.Parent == workspace)

	part:Destroy()
end)

lab.test("reactive property", function()
	local visible = source(false)

	local frame = flux.element "Frame" {
		Name = "test_frame",
		Visible = visible,
	} :: Frame

	lab.expect_equal(frame.Visible, peek(visible))

	visible(true)
	lab.expect_equal(frame.Visible, peek(visible))

	frame:Destroy()
end)

lab.test("invalid property error", function()
	lab.expect_error(function()
		local frame = flux.element "Frame" {
			Name = "test_frame",
			invalid_property = true,
		}

		frame:Destroy()
	end)
end)

lab.test("nexted props", function()
	local frame = flux.element "Frame" {
		Name = "initial_name",

		{
			Name = "nested_name",

			{
				Name = "deep_name",
			}
		}
	}

	lab.expect_equal(frame.Name, "deep_name")

	frame:Destroy()
end)

lab.test("basic children", function()
	local frame = flux.element "Frame" {
		flux.element "TextButton" {
			Name = "button",
		}
	}

	lab.expect(frame:FindFirstChild("button") ~= nil)

	frame:Destroy()
end)

lab.test("dynamic parenting", function()
	local handle = flux.root(function()
		local a = flux.element "Frame" {
			Name = "a",
		}

		local b = flux.element "Frame" {
			Name = "b",
		}

		local c = flux.element "Frame" {
			Name = "c",
		}

		local children: Source<Instance | {Instance}> = source({a, b})

		local frame = flux.element "Frame" {
			children,
		}

		lab.expect(frame:FindFirstChild("a") ~= nil and frame:FindFirstChild("b") ~= nil and not frame:FindFirstChild("c"))

		children(c)
		lab.expect(not frame:FindFirstChild("a") ~= nil and not frame:FindFirstChild("b") ~= nil and frame:FindFirstChild("c") ~= nil)

		children({a})
		lab.expect(frame:FindFirstChild("a") ~= nil and not frame:FindFirstChild("b") and not frame:FindFirstChild("c"))

		children({b})
		lab.expect((not frame:FindFirstChild("a") and frame:FindFirstChild("b") and not frame:FindFirstChild("c")) :: boolean)
	end)

	handle()
end)

return nil
