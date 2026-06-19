-- players spawn at lobby SpawnLocation
-- HUD shows "Waiting for players..." with current count
-- Minimum player count check runs every 5s via task.spawn
-- Once >=2 players: transition to Countdown
-- PlayerAdded/PlayerRemoving update lobby count via RemoteEvent to all clients
--

local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)
local Players = game:GetService("Players")
local CoinSpawner = require(script.Parent.Parent.mechanics.CoinSpawner)

local GameService = Knit.CreateService({
	Name = "GameService",
	Client = {
		StateChanged = Knit.CreateSignal(),
		CountdownUpdated = Knit.CreateSignal(),
	},
})

-- CONFIG
local MIN_PLAYERS = 1
local COUNTDOWN_TIME = 5
local ROUND_TIME = 60
local INTERMISSION_TIME = 5

-- STATE
GameService._playerCount = 0
GameService._state = "Lobby"

function GameService:_setState(newState)
	self._state = newState
	print("[GameService] State changed to:", newState)

	self.Client.StateChanged:FireAll(newState)
end

-- Get the total players
function GameService:_getPlayerCount()
	return #Players:GetPlayers()
end

-- Check the current Lobby's Players Validity
function GameService:_checkLobby()
	while true do
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

	CoinSpawner:Start()

	for i = ROUND_TIME, 1, -1 do
		print("Round time remaining: " .. i .. " seconds")
		task.wait(1)
	end

	self:_endRound()
end

-- End Round ~ provide player intermission show results -> return to lobby.
function GameService:_endRound()
	self:_setState("Results")

	CoinSpawner:Stop()

	for i = INTERMISSION_TIME, 1, -1 do
		print("Round time remaining: " .. i .. " seconds")
		task.wait(1)
	end

	self:_setState("Lobby")
end

-- Initialize GameService
function GameService:KnitStart()
	print("[GameService] Started")

	task.spawn(function()
		self:_checkLobby()
	end)
end

function GameService:DevStart()
	if self._state ~= "Lobby" then
		print("[GameService] Cannot dev start, not in lobby")
		return
	end

	self:_startCountdown()
end

return GameService
