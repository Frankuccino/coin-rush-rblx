local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)

local Controller = Knit.CreateController({
	Name = "Something",
})

function Controller:KnitStart() end

return Controller
