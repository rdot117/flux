--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local packages = ReplicatedStorage.packages

local flux = require(packages.flux)

local source = flux.source
local element = flux.element

local function selection_button(props: {
    index: number,
    selected: flux.Source<number>,
    size: flux.UsedAs<UDim2>,
    image: flux.UsedAs<string>,
    children: flux.UsedAs<flux.Children>,
})
    local pressed = source(false)
    local hovering = source(false)

    return element "Frame" {
        Name = "selection_buttons",
    }
end

return function(props: {
    Selected: flux.Source<number>,
})

end
