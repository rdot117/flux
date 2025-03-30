local flux = require "@pkg/flux"

local computed = flux.computed
local element = flux.element
local spring = flux.spring

return function(props: {
    visible: flux.UsedAs<boolean>,
    on_close: () -> (),
})
    return element "Frame" {
        Name = "shop_frame",
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Color3.fromRGB(30, 30, 30),
        Size = UDim2.fromScale(790/1920, 490/1080),

        Position = spring(0.6, 20, computed(function(use)
            return if use(props.visible) then UDim2.fromScale(0.5, 0.5) else UDim2.fromScale(0.5, 1.5)
        end)),

        element "UIAspectRatioConstraint" {
            AspectRatio = 790/490,
        },
        element "UICorner" {
            CornerRadius = UDim.new(15/490, 0),
        },
    }
end
