-- Game service types.

export type RoundCoinMap = { [number]: number } -- userId -> score

export type GameState = "Lobby" | "Countdown" | "Active" | "Results"

export type Rankings = {
	userId: number,
	score: number,
}

return {}
