local UserInputService = game:GetService("UserInputService")

local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)

local DevController = {}

function DevController:KnitStart()
	local GameService = Knit.GetService("GameService")

	print("[DevController] Loaded - Press P to start game")

	UserInputService.InputBegan:Connect(function(input, gpe)
		if gpe then
			return
		end

		-- P = start game
		if input.KeyCode == Enum.KeyCode.P then
			print("[DevController] Forcing countdown")
			GameService:DevStart()
		end
	end)
end

return DevController
