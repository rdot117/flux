--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local packages = ReplicatedStorage.packages
local shop = script.Parent.Parent

local flux = require(packages.flux)
local ui_labs = require(packages.ui_labs)
local shop_frame = require(shop.shop_frame)

local source = flux.source

local story = ui_labs.CreateGenericStory({
    controls = {
        visible = false,
    },

}, function(props)
    local handle = flux.root(function()
        local visible = source(props.controls.visible)

        local frame = shop_frame {
            visible = visible,
            on_close = function()
                print("on_close activated")
            end,
        }

        props.subscribe(function(controls)
            visible(controls.visible)
        end)

        frame.Parent = props.target
    end)

    return function()
        handle()
    end
end)

return story
