-- src/shared/modules/UIStyle.lua
-- Centralized design tokens. Never hardcode colors/sizes inline in controllers.

local UIStyle = {}

UIStyle.Colors = {
	Background = Color3.fromRGB(24, 24, 27),
	Surface = Color3.fromRGB(36, 36, 40),
	Border = Color3.fromRGB(58, 58, 64),
	TextPrimary = Color3.fromRGB(245, 245, 245),
	TextSecondary = Color3.fromRGB(165, 165, 170),
	Accent = Color3.fromRGB(255, 196, 0),
	Success = Color3.fromRGB(86, 214, 130),
	Danger = Color3.fromRGB(230, 90, 90),
}

UIStyle.Font = Enum.Font.GothamMedium
UIStyle.FontBold = Enum.Font.GothamBold

UIStyle.CornerRadius = UDim.new(0, 10)
UIStyle.Padding = UDim.new(0, 12)

-- Reusable instance factories keep every label/frame visually consistent
function UIStyle.applyCorner(instance: Instance, radius: UDim?)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = radius or UIStyle.CornerRadius
	corner.Parent = instance
	return corner
end

function UIStyle.applyStroke(instance: Instance, color: Color3?, thickness: number?)
	local stroke = Instance.new("UIStroke")
	stroke.Color = color or UIStyle.Colors.Border
	stroke.Thickness = thickness or 1
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Parent = instance
	return stroke
end

function UIStyle.applyPadding(instance: Instance, padding: UDim?)
	local pad = Instance.new("UIPadding")
	local p = padding or UIStyle.Padding
	pad.PaddingTop = p
	pad.PaddingBottom = p
	pad.PaddingLeft = p
	pad.PaddingRight = p
	pad.Parent = instance
	return pad
end

return UIStyle
