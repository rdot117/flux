--!strict
local Selection = game:GetService("Selection")

local toolbar = plugin:CreateToolbar("🧪 Lab")
local runButton = toolbar:CreateButton("run_button", "Run selected module", "", "📝 Run")

runButton.Click:Connect(function()
	local selected = Selection:Get()
	if #selected < 1 then
		return
	end

	local module = selected[1]
	if not module:IsA("ModuleScript") then
		return
	end

	local clone = module:Clone()
	local _run = require(clone :: any) :: any

	runButton:SetActive(false)
end)