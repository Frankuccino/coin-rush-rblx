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
			wins = 0,
			prestigeLevel = 0,
			sessionCoins = 0,
		}

		local leaderstats = Instance.new("Folder")
		leaderstats.Name = "leaderstats"
		leaderstats.Parent = player

		local coins = Instance.new("IntValue")
		coins.Name = "Coins"
		coins.Value = 0
		coins.Parent = leaderstats

		local wins = Instance.new("IntValue")
		wins.Name = "Wins"
		wins.Value = 0
		wins.Parent = leaderstats
	end)

	Players.PlayerRemoving:Connect(function(player)
		playerData[player] = nil
	end)
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

-- modifies ~ add wins to the player's total
function PlayerDataService:addWins(player, amount)
	local data = playerData[player]

	if not data then
		return
	end

	data.wins += amount

	local leaderstats = player:FindFirstChild("leaderstats")

	if not leaderstats then
		return
	end

	local wins = leaderstats:FindFirstChild("Wins")

	if not wins then
		return
	end

	wins.Value = data.wins
end

-- prestige ~ track prestige level and multiplier
function PlayerDataService:addPrestigeLevel(player, amount)
	local data = playerData[player]

	if not data then
		return
	end

	data.prestigeLevel += amount
end

function PlayerDataService:getPrestigeLevel(player): number
	local data = playerData[player]

	if not data then
		return 0
	end

	return data.prestigeLevel
end

-- session coins ~ reset each round, used for prestige eligibility
function PlayerDataService:addSessionCoins(player, amount)
	local data = playerData[player]

	if not data then
		return
	end

	data.sessionCoins += amount
end

function PlayerDataService:getSessionCoins(player): number
	local data = playerData[player]

	if not data then
		return 0
	end

	return data.sessionCoins
end

function PlayerDataService:setSessionCoins(player, amount)
	local data = playerData[player]

	if not data then
		return
	end

	data.sessionCoins = amount
end

function PlayerDataService:getMultiplier(player): number
	local data = playerData[player]

	if not data then
		return 1
	end

	return 1 + (0.1 * data.prestigeLevel)
end

function PlayerDataService:prestigePlayer(player): boolean
	local data = playerData[player]

	if not data then
		return false
	end

	data.prestigeLevel += 1
	data.sessionCoins = 0

	self.Client.PrestigeCompleted:Fire(player, data.prestigeLevel)

	return true
end

return PlayerDataService
