-- Typed remote contracts for Knit.
-- Declare every remote once here; import this module everywhere.

local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)

-- StateChanged: server -> all clients
-- FireAll(newState: string)
local StateChanged = Knit.CreateRemote("StateChanged") :: any

-- CountdownUpdated: server -> all clients
-- FireAll(secondsLeft: number)
local CountdownUpdated = Knit.CreateRemote("CountdownUpdated") :: any

-- TimerUpdated: server -> all clients
-- FireAll(secondsLeft: number)
local TimerUpdated = Knit.CreateRemote("TimerUpdated") :: any

-- RoundCoinsUpdated: server -> specific client
-- Fire(player: Player, roundScore: number)
local RoundCoinsUpdated = Knit.CreateRemote("RoundCoinsUpdated") :: any

-- Used for round rankings
-- FireAll(topThree: { userId: number, userName: string, score: number, rank: number }[])
local LeaderboardUpdated = Knit.CreateRemote("LeaderboardUpdated") :: any

-- Fired after winner is determined
-- FireAll(winnerName: string, score: number)
local WinnerAnnounced = Knit.CreateRemote("WinnerAnnounced") :: any

-- Global session leaderboard (sorted by Wins)
-- FireAll(entries: { userId: number, userName: string, wins: number, coins: number }[])
local GlobalLeaderboardUpdated = Knit.CreateRemote("GlobalLeaderboardUpdated") :: any

-- Coin collection event (server -> all clients)
-- FireAll(player: Player, amount: number, tier: string)
local CoinCollected = Knit.CreateRemote("CoinCollected") :: any

return {
	StateChanged = StateChanged,
	CountdownUpdated = CountdownUpdated,
	TimerUpdated = TimerUpdated,
	RoundCoinsUpdated = RoundCoinsUpdated,
	LeaderboardUpdated = LeaderboardUpdated,
	WinnerAnnounced = WinnerAnnounced,
	GlobalLeaderboardUpdated = GlobalLeaderboardUpdated,
	CoinCollected = CoinCollected,
}
