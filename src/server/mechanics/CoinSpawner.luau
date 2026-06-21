-- CoinSpawner spawns coins at random arena positions every 2s via CollectionService tags.
-- Player touches coin -> Touched event fires -> server validates proximity -> awards coins -> fires UI update.
-- Coins are destroyed on collection; no persistent VFX or spin logic is handled here.
-- Round lifecycle (start/stop/timer) is managed by GameService.

local CollectionService = game:GetService("CollectionService")
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CoinSpawner = {}
local COIN_TAG = require(ReplicatedStorage.Shared.constants.CoinConstants).Tag
local COIN_CONSTANTS = require(ReplicatedStorage.Shared.constants.CoinConstants)
local COIN_TEMPLATE = ServerStorage:WaitForChild("Coin")

local ACTIVE = false
local spawnedCoins = {}

function CoinSpawner:Start()
	if ACTIVE then
		return
	end
	ACTIVE = true
	self:_spawnLoop()
end

function CoinSpawner:Stop()
	ACTIVE = false

	for _, coin in ipairs(spawnedCoins) do
		if coin and coin.Parent then
			coin:Destroy()
		end
	end

	table.clear(spawnedCoins)
end

function CoinSpawner:_spawnLoop()
	task.spawn(function()
		while ACTIVE do
			self:_spawnCoin()
			task.wait(COIN_CONSTANTS.SpawnInterval)
		end
	end)
end

function CoinSpawner:_spawnCoin()
	local coin = COIN_TEMPLATE:Clone()
	local bounds = COIN_CONSTANTS.SpawnBounds

	coin.Position = Vector3.new(
		math.random(bounds.MinX, bounds.MaxX),
		bounds.Y,
		math.random(bounds.MinZ, bounds.MaxZ)
	)

	coin.Anchored = true
	coin.CanCollide = false
	coin.Parent = workspace

	CollectionService:AddTag(coin, COIN_TAG)

	table.insert(spawnedCoins, coin)
end

return CoinSpawner
