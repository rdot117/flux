local flux = require "@pkg/flux"
local ui_labs = require "@pkg/ui_labs"
local shop_frame = require "@gui/shop/shop_frame"

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
