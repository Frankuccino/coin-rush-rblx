-- CoinSpawner spawns coins at random positions inside ArenaBounds every 2s.
-- ArenaBounds is a non-collidable, invisible Part placed in the arena folder.
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
local _arenaBoundsParts: { BasePart } = {}

function CoinSpawner:_resolveArenaBounds(): { BasePart }
	if #_arenaBoundsParts > 0 then
		return _arenaBoundsParts
	end

	local parts = CollectionService:GetTagged("ArenaBounds")
	local filtered = table.create(#parts)
	local count = 0
	for i = 1, #parts do
		local candidate = parts[i]
		if candidate:IsA("BasePart") then
			count += 1
			filtered[count] = candidate :: BasePart
		end
	end
	if count == 0 then
		warn("[CoinSpawner] No ArenaBounds tagged BaseParts found; coins will not spawn")
	end
	_arenaBoundsParts = filtered
	return filtered
end

function CoinSpawner:Start()
	if ACTIVE then
		return
	end
	ACTIVE = true
	_arenaBoundsParts = {}
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

function CoinSpawner:_pickTier()
	local totalWeight = 0
	for _, tier in pairs(COIN_CONSTANTS.Tiers) do
		totalWeight += tier.Weight
	end

	local roll = math.random(totalWeight)
	local cumulative = 0

	for tierName, tier in pairs(COIN_CONSTANTS.Tiers) do
		cumulative += tier.Weight
		if roll <= cumulative then
			return tierName
		end
	end

	return "Common"
end

function CoinSpawner:_spawnCoin()
	local coin = COIN_TEMPLATE:Clone()
	local tier = self:_pickTier()
	local boundsParts = self:_resolveArenaBounds()

	coin:SetAttribute("Tier", tier)
	coin:SetAttribute("Value", COIN_CONSTANTS.Tiers[tier].Value)
	coin.Color = COIN_CONSTANTS.Tiers[tier].Color

	if #boundsParts > 0 then
		local boundsPart = boundsParts[math.random(1, #boundsParts)]
		local size = boundsPart.Size
		local pos = boundsPart.Position
		coin.Position = Vector3.new(
			pos.X + math.random(-size.X / 2, size.X / 2),
			pos.Y + size.Y / 2,
			pos.Z + math.random(-size.Z / 2, size.Z / 2)
		)
	else
		coin.Position = Vector3.new(
			math.random(COIN_CONSTANTS.SpawnBounds.MinX, COIN_CONSTANTS.SpawnBounds.MaxX),
			COIN_CONSTANTS.SpawnBounds.Y,
			math.random(COIN_CONSTANTS.SpawnBounds.MinZ, COIN_CONSTANTS.SpawnBounds.MaxZ)
		)
	end

	coin.Anchored = true
	coin.CanCollide = false
	coin.Parent = workspace

	CollectionService:AddTag(coin, COIN_TAG)

	table.insert(spawnedCoins, coin)
end

return CoinSpawner
