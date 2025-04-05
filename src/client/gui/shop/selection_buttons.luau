local ReplicatedStorage = game:GetService("ReplicatedStorage")

local packages = ReplicatedStorage.packages
local gui = script.Parent.Parent

local flux = require(packages.flux)
local button_events = require(gui.hooks.button_events)

local source = flux.source
local element = flux.element
local spring = flux.spring
local computed = flux.computed

local function selection_button(props: {
    index: number,
    selected: flux.Source<number>,
    size: flux.UsedAs<UDim2>,
    image: flux.UsedAs<string>,
    children: flux.UsedAs<flux.Children>,
})
    local pressed = source(false)
    local hovering = source(false)

    return element "TextButton" {
        Name = "selection_button",

        Size = spring(0.6, 26, computed(function(use)
            if use(hovering) then
                if use(pressed) then
                    return UDim2.fromScale(0.9, 0.9)
                else
                    return UDim2.fromScale(1.1, 1.1)
                end
            else
                return UDim2.fromScale(1, 1)
            end
        end)),

        [button_events] = {
            pressed = pressed,
            hovering = hovering,
        }
    }
end

return function(props: {
    Selected: flux.Source<number>,
})

end
