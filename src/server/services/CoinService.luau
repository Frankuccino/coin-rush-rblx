-- CoinService handles all coin lifecycle and collection logic.
-- Uses server-side proximity detection (not Touched) for reliable collection.
-- Anchored non-colliding parts do not reliably fire Touched; magnitude check is deterministic.

local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CoinService = Knit.CreateService({
	Name = "CoinService",
	Client = {},
})

local COIN_TAG = require(ReplicatedStorage.Shared.constants.CoinConstants).Tag
local COLLECTION_RADIUS = 3.5

function CoinService:KnitStart()
	print("[CoinService] Started")

	self.PlayerDataService = Knit.GetService("PlayerDataService")
	self.GameService = Knit.GetService("GameService")

	task.defer(function()
		self:_connectCoins()
	end)

	self._proximityConnection = RunService.Heartbeat:Connect(function()
		self:_checkProximity()
	end)
end

function CoinService:_connectCoins()
	local coins = CollectionService:GetTagged(COIN_TAG)

	print("Found coins:", #coins)

	for _, coin in ipairs(coins) do
		self:_hookCoin(coin)
	end

	CollectionService:GetInstanceAddedSignal(COIN_TAG):Connect(function(coin)
		print("New coin tagged:", coin.Name)
		self:_hookCoin(coin)
	end)
end

function CoinService:_hookCoin(coin)
	if not coin:IsA("BasePart") then
		return
	end

	if coin:GetAttribute("Hooked") then
		return
	end

	coin:SetAttribute("Hooked", true)
end

function CoinService:_checkProximity()
	local coins = CollectionService:GetTagged(COIN_TAG)
	local players = Players:GetPlayers()

	for _, coin in ipairs(coins) do
		if coin:GetAttribute("Collected") then
			continue
		end

		local coinPos = coin.Position

		for _, player in ipairs(players) do
			local character = player.Character
			if not character then
				continue
			end

			local root = character:FindFirstChild("HumanoidRootPart")
			if not root then
				continue
			end

			if (coinPos - root.Position).Magnitude <= COLLECTION_RADIUS then
				self:_collectCoin(player, coin)
			end
		end
	end
end

function CoinService:_collectCoin(player, coin)
	if coin:GetAttribute("Collected") then
		return
	end

	coin:SetAttribute("Collected", true)
	coin.CanTouch = false
	coin.CanCollide = false

	-- permanent progression
	self.PlayerDataService:addCoins(player, 1)

	-- round tracking
	local roundScore = self.GameService:AddRoundCoin(player, 1)
	-- UI Update
	self.GameService.Client.RoundCoinsUpdated:Fire(player, roundScore)

	print(player.Name .. " collected a coin!")
	coin:Destroy()
end

function CoinService:KnitStop()
	if self._proximityConnection then
		self._proximityConnection:Disconnect()
		self._proximityConnection = nil
	end
end

return CoinService
