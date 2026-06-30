-- UpgradeService handles purchasing upgrades and applying their effects.
-- Server is the authority; client requests purchase and reacts to signals.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Knit = require(ReplicatedStorage.Packages.Knit)

local UpgradeService = Knit.CreateService({
	Name = "UpgradeService",
	Client = {
		AttemptPurchase = Knit.CreateRemote(),
		PurchaseSucceeded = Knit.CreateSignal(),
		PurchaseFailed = Knit.CreateSignal(),
	},
})

local PricingService = require(script.Parent.PricingService)

local PlayerDataService

--[[
	Tracks applied runtime effects per player so they can be cleanly recalculated.

	Structure:
	{
		[player] = {
			CoinValue: number,      -- multiplier added to base coin value
			WalkSpeed: number,      -- added to base speed
			MagnetRange: number,    -- added to base radius
			CoinSpawnRate: number,  -- added to base spawn count
		}
	}
]]
local runtimeEffects = {}

function UpgradeService:_getEffects(player)
	if not runtimeEffects[player] then
		runtimeEffects[player] = {
			CoinValue = 0,
			WalkSpeed = 0,
			MagnetRange = 0,
			CoinSpawnRate = 0,
		}
	end
	return runtimeEffects[player]
end

--[[
	Recalculates all effects for a player from their saved levels.
	Call this after prestige or any level reset.
]]
function UpgradeService:RecalculateEffects(player)
	local data = PlayerDataService:getData(player)
	if not data then
		return
	end

	local effects = self:_getEffects(player)

	for upgradeId, level in data.upgrades do
		local effect = PricingService:GetUpgradeEffect(upgradeId, level)
		effects[upgradeId] = effect
	end
end

--[[
	Returns the current effect value for an upgrade on a player.
]]
function UpgradeService:GetEffect(player, upgradeId: string): number
	local effects = self:_getEffects(player)
	return effects[upgradeId] or 0
end

--[[
	Attempts to purchase one level of the given upgrade.

	Returns (success: boolean, reason: string?).
]]
function UpgradeService:AttemptPurchase(player, upgradeId: string): (boolean, string?)
	local data = PlayerDataService:getData(player)
	if not data then
		return false, "NO_DATA"
	end

	local currentLevel = data.upgrades[upgradeId] or 0
	local cost = PricingService:GetUpgradeCost(upgradeId, currentLevel)

	if data.coins < cost then
		return false, "INSUFFICIENT_FUNDS"
	end

	-- Deduct and increment
	PlayerDataService:addCoins(player, -cost)
	data.upgrades[upgradeId] = currentLevel + 1

	-- Update runtime effects
	local effect = PricingService:GetUpgradeEffect(upgradeId, data.upgrades[upgradeId])
	self:_getEffects(player)[upgradeId] = effect

	-- Notify client
	self.Client.PurchaseSucceeded:Fire(player, upgradeId, data.upgrades[upgradeId], cost)

	return true, nil
end

function UpgradeService:KnitInit()
	PlayerDataService = Knit.GetService("PlayerDataService")

	Players.PlayerAdded:Connect(function(player)
		self:_getEffects(player)
	end)

	Players.PlayerRemoving:Connect(function(player)
		runtimeEffects[player] = nil
	end)
end

function UpgradeService:KnitStart()
	print("[UpgradeService] Started")
end

return UpgradeService
