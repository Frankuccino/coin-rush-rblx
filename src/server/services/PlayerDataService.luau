-- Should own player-related data
-- Later on: Coins, Level, XP, Wins, Inventory

local Players = game:GetService("Players")
local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)

local PlayerDataService = Knit.CreateService({
	Name = "PlayerDataService",
	Client = {},
})

local playerData = {}

function PlayerDataService:KnitInit()
	Players.PlayerAdded:Connect(function(player)
		playerData[player] = {
			coins = 0,
		}

		local leaderstats = Instance.new("Folder")
		leaderstats.Name = "leaderstats"
		leaderstats.Parent = player

		local coins = Instance.new("IntValue")
		coins.Name = "Coins"
		coins.Value = 0
		coins.Parent = leaderstats
	end)

	Players.PlayerRemoving:Connect(function(player)
		playerData[player] = nil
	end)
end

-- reads ~ get the coins of the player (verb)
function PlayerDataService:getCoins(player)
	local data = playerData[player]

	if not data then
		return 0
	end

	return data.coins
end

-- modifies ~ add coins to the player's total
function PlayerDataService:addCoins(player, amount)
	print("[DEBUG] Awarding coin to", player.Name)
	local data = playerData[player]

	if not data then
		return
	end

	data.coins += amount

	local leaderstats = player:FindFirstChild("leaderstats")

	if not leaderstats then
		return
	end

	local coins = leaderstats:FindFirstChild("Coins")

	if not coins then
		return
	end

	coins.Value = data.coins
end

return PlayerDataService
