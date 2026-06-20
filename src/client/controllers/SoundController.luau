local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)

local Controller = Knit.CreateController({
	Name = script.Name,
})

function Controller:KnitStart() end

return Controller
