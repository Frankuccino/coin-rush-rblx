-- Coin-related constants.
-- Spawn bounds, intervals, and tier definitions live here.

export type CoinTier = "Common" | "Rare" | "Epic"

return {

	-- CollectionService tag used to identify coins
	Tag = "Coin",

	-- Fallback spawn area bounds (used only if ArenaBounds part is missing)
	SpawnBounds = {
		MinX = -50,
		MaxX = 50,
		MinZ = -50,
		MaxZ = 50,
		Y = 5,
	},

	-- Seconds between spawns
	SpawnInterval = 2,

	-- Base coin value
	BaseValue = 1,

	-- Tier configuration
	Tiers = {
		Common = {
			Weight = 70,
			Value = 1,
			Color = Color3.fromRGB(255, 196, 0),
		},
		Rare = {
			Weight = 25,
			Value = 2,
			Color = Color3.fromRGB(86, 170, 255),
		},
		Epic = {
			Weight = 5,
			Value = 3,
			Color = Color3.fromRGB(200, 120, 255),
		},
	},
}
