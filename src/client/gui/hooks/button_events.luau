local ReplicatedStorage = game:GetService("ReplicatedStorage")

local packages = ReplicatedStorage.packages

local flux = require(packages.flux.exports)
local scopes = require(packages.flux.scopes)

return {
    apply = function(instance: Instance, props)
        if not instance:IsA("GuiButton") then
            return
        end

        local pressed: flux.Source<boolean>? = props.pressed
        local hovering: flux.Source<boolean>? = props.hovering

        local pressInputs = 0
		local hoverInputs = 0
		local inputs = {}

		local function update()
			if pressed then
				pressed(pressInputs > 0)
			end

			if hovering then
				hovering(hoverInputs > 0)
			end
		end

		local function untrack(input: InputObject)
			local release = inputs[input]
			inputs[input] = nil

			if release then
				release()
			end
		end

		local function track(input: InputObject, release: () -> ())
			update()

			local inputStateConn = input:GetPropertyChangedSignal("UserInputState"):Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					untrack(input)
				end
			end)

			inputs[input] = function()
				release()

				inputStateConn:Disconnect()
				update()
			end
		end

		local input_began = instance.InputBegan:Connect(function(input: InputObject)
			if input.UserInputState == Enum.UserInputState.Begin then
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					pressInputs += 1

					track(input, function()
						pressInputs -= 1
					end)
				end
			elseif input.UserInputState == Enum.UserInputState.Change then
				if input.UserInputType == Enum.UserInputType.MouseMovement then
					hoverInputs += 1

					track(input, function()
						hoverInputs -= 1
					end)
				end
			end
		end)

		local input_ended = instance.InputEnded:Connect(function(input: InputObject)
			untrack(input)
		end)

		if scopes.in_scope() then
		    scopes.use_cleanup(input_began)
			scopes.use_cleanup(input_ended)
		end
    end,
}
