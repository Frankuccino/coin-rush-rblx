-- PricingService owns all upgrade cost formulas.
-- Server-authoritative: never trust client to calculate price.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local PricingService = Knit.CreateService({
	Name = "PricingService",
	Client = {
		GetUpgradeCost = Knit.CreateRemote(),
	},
})

-- Tunable constants. Move to RoundConfig or a dedicated PricingConfig later.
local COIN_VALUE_BASE = 100
local COIN_VALUE_SCALE = 1.15

local WALK_SPEED_BASE = 200
local WALK_SPEED_SCALE = 1.18

local MAGNET_RANGE_BASE = 500
local MAGNET_RANGE_SCALE = 1.20

local COIN_SPAWN_RATE_BASE = 1000
local COIN_SPAWN_RATE_SCALE = 1.25

--[[
	Returns the cost for the next level of an upgrade.

	currentLevel: how many levels the player already owns in this track.
	Returns integer cost.
]]
function PricingService:GetUpgradeCost(upgradeId: string, currentLevel: number): number
	if currentLevel < 0 then
		error("currentLevel must be >= 0")
	end

	if upgradeId == "CoinValue" then
		return math.floor(COIN_VALUE_BASE * (COIN_VALUE_SCALE ^ currentLevel))
	elseif upgradeId == "WalkSpeed" then
		return math.floor(WALK_SPEED_BASE * (WALK_SPEED_SCALE ^ currentLevel))
	elseif upgradeId == "MagnetRange" then
		return math.floor(MAGNET_RANGE_BASE * (MAGNET_RANGE_SCALE ^ currentLevel))
	elseif upgradeId == "CoinSpawnRate" then
		return math.floor(COIN_SPAWN_RATE_BASE * (COIN_SPAWN_RATE_SCALE ^ currentLevel))
	else
		error("Unknown upgradeId: " .. upgradeId)
	end
end

--[[
	Returns the effect value at a given level.
	Clients use this for display only; server uses same formulas for authority.
]]
function PricingService:GetUpgradeEffect(upgradeId: string, currentLevel: number): number
	if upgradeId == "CoinValue" then
		-- +10% per level
		return currentLevel * 0.10
	elseif upgradeId == "WalkSpeed" then
		-- +5% per level
		return currentLevel * 0.05
	elseif upgradeId == "MagnetRange" then
		-- +1 stud per level
		return currentLevel * 1
	elseif upgradeId == "CoinSpawnRate" then
		-- +1 coin per spawn interval per level
		return currentLevel * 1
	else
		error("Unknown upgradeId: " .. upgradeId)
	end
end

function PricingService:KnitStart()
	print("[PricingService] Started")
end

return PricingService
