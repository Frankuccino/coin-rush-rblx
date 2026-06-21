-- Player data types.

export type PlayerProfile = {
	coins: number,
	wins: number,
	prestigeLevel: number,
	sessionCoins: number,
	lastLogin: DateTime?,
	currentStreak: number,
	bestStreak: number,
	lastChestClaim: DateTime?,
	cosmetics: {
		halo: boolean,
		trail: boolean,
		victoryEffect: boolean,
	},
}

export type LeaderboardEntry = {
	userId: number,
	userName: string,
	score: number,
	rank: number,
}

return {}
