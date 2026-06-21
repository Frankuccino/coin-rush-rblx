-- players spawn at lobby SpawnLocation
-- HUD shows "Waiting for players..." with current count
-- Minimum player count check runs every 5s via abortable loop
-- Once >= MinPlayers: transition to Countdown

local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoinSpawner = require(script.Parent.Parent.mechanics.CoinSpawner)
local RoundConfig = require(ReplicatedStorage.Shared.config.RoundConfig)

local GameService = Knit.CreateService({
	Name = "GameService",
	Client = {
		StateChanged = Knit.CreateSignal(),
		CountdownUpdated = Knit.CreateSignal(),

		RoundCoinsUpdated = Knit.CreateSignal(),
		TimerUpdated = Knit.CreateSignal(),
	},
})

-- CONFIG (from RoundConfig.luau)
local MIN_PLAYERS = RoundConfig.MinPlayers
local COUNTDOWN_TIME = RoundConfig.CountdownTime
local ROUND_TIME = RoundConfig.RoundTime
local INTERMISSION_TIME = RoundConfig.IntermissionTime

-- STATE
GameService._playerCount = 0
GameService._state = "Lobby"
GameService._roundCoins = {}
GameService._lobbyCancelled = false

function GameService:_setState(newState)
	self._state = newState
	print("[GameService] State changed to:", newState)

	self.Client.StateChanged:FireAll(newState)
end

-- Helper: awards coins for a specific player in the current round
function GameService:AddRoundCoin(player: Player, amount: number): number
	local userId = player.UserId
	self._roundCoins[userId] = (self._roundCoins[userId] or 0) + amount
	return self._roundCoins[userId]
end

-- Get the total players
function GameService:_getPlayerCount()
	return #Players:GetPlayers()
end

-- Check the current Lobby's Players Validity
-- Abortable: controlled by _lobbyCancelled flag
function GameService:_checkLobby()
	while not self._lobbyCancelled do
		task.wait(5)

		if self._state ~= "Lobby" then
			continue
		end

		local count = self:_getPlayerCount()

		if count >= MIN_PLAYERS then
			self:_startCountdown()
		else
			print("[GameService] Waiting for players...", count)
		end
	end
end

function GameService:_stopLobbyLoop()
	self._lobbyCancelled = true
end

-- Start Game Match Countdown
function GameService:_startCountdown()
	self:_setState("Countdown")

	for i = COUNTDOWN_TIME, 1, -1 do
		self.Client.CountdownUpdated:FireAll(i)
		task.wait(1)
	end

	self:_startRound()
end

-- Start Round ~ players play within the Round Time
function GameService:_startRound()
	self:_setState("Active")

	-- reset round data
	self._roundCoins = {}
	self._lobbyCancelled = false

	CoinSpawner:Start()

	for i = ROUND_TIME, 1, -1 do
		print("Round time remaining: " .. i .. " seconds")
		self.Client.TimerUpdated:FireAll(i)
		task.wait(1)
	end

	self:_endRound()
end

-- End Round ~ provide player intermission show results -> return to lobby.
function GameService:_endRound()
	self:_setState("Results")

	CoinSpawner:Stop()

	-- find winner (by userId, then resolve to Player if still present)
	local topUserId = nil
	local topScore = -1

	for userId, score in pairs(self._roundCoins) do
		if score > topScore then
			topScore = score
			topUserId = userId
		end
	end

	if topUserId then
		local winner = Players:GetPlayerByUserId(topUserId)
		if winner then
			print(" Winner:", winner.Name, "with", topScore, "coins")
		else
			print(" Winner (left): userId", topUserId, "with", topScore, "coins")
		end
	end

	for i = INTERMISSION_TIME, 1, -1 do
		print("Intermission time remaining: " .. i .. " seconds")
		task.wait(1)
	end

	self._roundCoins = {}
	self:_setState("Lobby")
end

-- Initialize GameService
function GameService:KnitStart()
	print("[GameService] Started")
	self._lobbyCancelled = false

	task.spawn(function()
		self:_checkLobby()
	end)
end

function GameService:KnitStop()
	self:_stopLobbyLoop()
end

function GameService:DevStart()
	if self._state ~= "Lobby" then
		print("[GameService] Cannot dev start, not in lobby")
		return
	end

	self:_startCountdown()
end

return GameService
