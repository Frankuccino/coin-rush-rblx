-- players spawn at lobby SpawnLocation
-- HUD shows "Waiting for players..."
-- Round starts only when a player enters an ArenaEntry part (manual trigger)
-- No automatic lobby countdown loop

local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)
local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")
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
		LeaderboardUpdated = Knit.CreateSignal(),
		WinnerAnnounced = Knit.CreateSignal(),
		GlobalLeaderboardUpdated = Knit.CreateSignal(),
		CoinCollected = Knit.CreateSignal(),
		PrestigeAvailable = Knit.CreateSignal(),
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
GameService._arenaEntryParts = {}
GameService._arenaConnections = {}
GameService._arenaBorder = nil
GameService._queueSpawn = nil
GameService._arenaEntryCooldown = 0

function GameService:_setState(newState)
	self._state = newState
	print("[GameService] State changed to:", newState)

	self.Client.StateChanged:FireAll(newState)
end

-- Helper: awards coins for a specific player in the current round
function GameService:AddRoundCoin(player: Player, amount: number): number
	local userId = player.UserId
	self._roundCoins[userId] = (self._roundCoins[userId] or 0) + amount
	self.PlayerDataService:addSessionCoins(player, amount)
	return self._roundCoins[userId]
end

-- Resolve all parts tagged ArenaEntry (manual round-start triggers)
function GameService:_resolveArenaEntries()
	if #self._arenaEntryParts > 0 then
		return
	end

	local parts = CollectionService:GetTagged("ArenaEntry")
	local filtered = {}
	local count = 0
	for i = 1, #parts do
		local part = parts[i]
		if part:IsA("BasePart") and part.Name == "ArenaEntry" then
			count += 1
			filtered[count] = part :: BasePart
		end
	end
	self._arenaEntryParts = filtered
end

-- Called when a player touches/enters an ArenaEntry part
function GameService:_tryStartRound(_player: Player)
	-- only allow entry during Lobby, after cooldown
	if self._state ~= "Lobby" then
		return
	end
	if os.time() < self._arenaEntryCooldown then
		return
	end

	local count = #Players:GetPlayers()
	if count < MIN_PLAYERS then
		print("[GameService] Not enough players to start round:", count)
		return
	end

	self:_startCountdown()
end

-- Listen for Touched events on all ArenaEntry parts
function GameService:_wireArenaEntries()
	for _, part in ipairs(self._arenaEntryParts) do
		local conn = part.Touched:Connect(function(hit)
			local character = hit.Parent
			if not character then
				return
			end
			local player = Players:GetPlayerFromCharacter(character)
			if player then
				self:_tryStartRound(player)
			end
		end)
		self._arenaConnections[part] = conn
	end
end

function GameService:_resolveArenaBorder(): Part?
	if self._arenaBorder then
		return self._arenaBorder
	end

	local ws = game:GetService("Workspace")
	local candidates = {
		ws:FindFirstChild("Arena")
			and ws.Arena:FindFirstChild("ArenaEntrance")
			and ws.Arena.ArenaEntrance:FindFirstChild("ArenaBorder"),
		ws:FindFirstChild("Arena") and ws.Arena:FindFirstChild("ArenaBorder"),
		ws:FindFirstChild("ArenaBorder"),
	}
	for _, part in candidates do
		if part and part:IsA("BasePart") then
			self._arenaBorder = part :: BasePart
			return self._arenaBorder
		end
	end
	return nil
end

function GameService:_resolveQueueSpawn(): Part?
	if self._queueSpawn then
		return self._queueSpawn
	end

	local ws = game:GetService("Workspace")
	local candidates = {
		ws:FindFirstChild("Arena")
			and ws.Arena:FindFirstChild("ArenaEntrance")
			and ws.Arena.ArenaEntrance:FindFirstChild("ArenaQueueSpawn"),
		ws:FindFirstChild("Arena") and ws.Arena:FindFirstChild("ArenaQueueSpawn"),
		ws:FindFirstChild("ArenaQueueSpawn"),
	}
	for _, part in candidates do
		if part and part:IsA("BasePart") then
			self._queueSpawn = part :: BasePart
			return self._queueSpawn
		end
	end
	return nil
end

function GameService:_setArenaBarrier(state: string)
	local border = self:_resolveArenaBorder()
	if not border then
		return
	end

	-- open in these states, closed otherwise
	if state == "Active" or state == "Lobby" or state == "CountdownGrace" then
		border.CanCollide = false
	else
		border.CanCollide = true
	end
end

function GameService:_teleportLatePlayersToQueue()
	local queueSpawn = self:_resolveQueueSpawn()
	if not queueSpawn then
		return
	end

	local allPlayers = Players:GetPlayers()
	for _, player in ipairs(allPlayers) do
		if not player.Character then
			continue
		end
		local root = player.Character:FindFirstChild("HumanoidRootPart")
		if not root then
			continue
		end

		-- Check if player is inside the arena (simple distance check near arena center)
		local arenaCenter = Vector3.new(0, -27.737, 259) -- arena position from your current setup
		local distanceFromArena = (root.Position - arenaCenter).Magnitude
		local ARENA_RADIUS = 40 -- approximate arena extent

		if distanceFromArena > ARENA_RADIUS then
			-- Player is outside arena (in lobby/queue), leave them
			continue
		end

		-- Player is inside arena but shouldn't be, teleport to queue
		if queueSpawn then
			root.CFrame = queueSpawn.CFrame + Vector3.new(0, 3, 0)
			print("[GameService] Teleported", player.Name, "to queue (late entry)")
		end
	end
end

function GameService:_getPlayerCount()
	return #Players:GetPlayers()
end

-- Start Game Match Countdown
function GameService:_startCountdown()
	self:_setState("Countdown")
	self:_setArenaBarrier("CountdownGrace") -- open for 5s entry window

	-- close barrier after grace period, then prevent Touched re-entry for the entire round
	task.delay(5, function()
		if self._state == "Countdown" then
			self:_setArenaBarrier("Countdown")
		end
	end)

	self._arenaEntryCooldown = os.time() + COUNTDOWN_TIME + ROUND_TIME + INTERMISSION_TIME + 3

	self:_teleportLatePlayersToQueue()

	for i = COUNTDOWN_TIME, 1, -1 do
		self.Client.CountdownUpdated:FireAll(i)
		self.Client.TimerUpdated:FireAll(i)
		task.wait(1)
	end

	self:_startRound()
end

-- Start Round ~ players play within the Round Time
function GameService:_startRound()
	self._roundCoins = {}

	-- reset session prestige data for all players
	for _, p in ipairs(Players:GetPlayers()) do
		self.PlayerDataService:setSessionCoins(p, 0)
	end

	CoinSpawner:Start()

	self:_setState("Active")
	self:_setArenaBarrier("Active") -- open during active play

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
	self:_setArenaBarrier("Results") -- close during results/intermission

	CoinSpawner:Stop()

	-- compute rankings ( userId -> score )
	local rankings = {}
	for userId, score in pairs(self._roundCoins) do
		table.insert(rankings, {
			userId = userId,
			score = score,
		})
	end
	table.sort(rankings, function(a, b)
		return a.score > b.score
	end)

	-- fire round leaderboard (top 3)
	local topThree = {}
	for i = 1, math.min(3, #rankings) do
		local entry = rankings[i]
		local player = Players:GetPlayerByUserId(entry.userId)
		if player then
			table.insert(topThree, {
				userId = entry.userId,
				userName = player.Name,
				score = entry.score,
				rank = i,
			})
		end
	end
	self.Client.LeaderboardUpdated:FireAll(topThree)

	-- winner spotlight
	local winnerName = nil
	local winnerScore = 0
	if #rankings > 0 then
		local topUserId = rankings[1].userId
		local winner = Players:GetPlayerByUserId(topUserId)
		if winner then
			winnerScore = rankings[1].score
			winnerName = winner.Name
			print(" Winner:", winner.Name, "with", winnerScore, "coins!")
			self.PlayerDataService:addWins(winner, 1)
			self.Client.WinnerAnnounced:FireAll(winnerName, winnerScore)
		else
			print(" Winner (left): userId", rankings[1].userId, "with", rankings[1].score, "coins!")
		end
	end

	-- global leaderboard (session snapshot)
	local globalEntries = {}
	for _, player in ipairs(Players:GetPlayers()) do
		local leaderstats = player:FindFirstChild("leaderstats")
		if leaderstats then
			local winsValue = leaderstats:FindFirstChild("Wins")
			local coinsValue = leaderstats:FindFirstChild("Coins")
			if winsValue and coinsValue then
				table.insert(globalEntries, {
					userId = player.UserId,
					userName = player.Name,
					wins = winsValue.Value,
					coins = coinsValue.Value,
				})
			end
		end
	end
	table.sort(globalEntries, function(a, b)
		return a.wins > b.wins
	end)
	self.Client.GlobalLeaderboardUpdated:FireAll(globalEntries)

	for i = INTERMISSION_TIME, 1, -1 do
		print("Intermission time remaining: " .. i .. " seconds")
		self.Client.TimerUpdated:FireAll(i)

		task.wait(1)
	end

	-- teleport all players out of arena to ArenaExit when round ends
	local ws = game:GetService("Workspace")
	local arenaExit = ws:FindFirstChild("Arena") and ws.Arena:FindFirstChild("ArenaEntrance") and ws.Arena.ArenaEntrance:FindFirstChild("ArenaExit")
	local teleportTarget = arenaExit

	if not teleportTarget then
		for _, obj in ipairs(ws:GetDescendants()) do
			if obj:IsA("SpawnLocation") then
				teleportTarget = obj
				break
			end
		end
	end

	if not teleportTarget then
		teleportTarget = self:_resolveQueueSpawn()
	end

	if teleportTarget then
		for _, player in ipairs(Players:GetPlayers()) do
			if not player.Character then
				continue
			end
			local root = player.Character:FindFirstChild("HumanoidRootPart")
			if not root then
				continue
			end
			root.CFrame = teleportTarget.CFrame + Vector3.new(0, 3, 0)
		end
	end

	-- prevent instant re-entry for a few seconds after round ends
	self._arenaEntryCooldown = os.time() + 8

	self._roundCoins = {}
	self:_setState("Lobby")
	self:_setArenaBarrier("Lobby")
end

-- Initialize GameService
function GameService:KnitStart()
	print("[GameService] Started")
	self.PlayerDataService = Knit.GetService("PlayerDataService")

	self:_resolveArenaEntries()
	self:_wireArenaEntries()
	self:_setArenaBarrier("Lobby") -- lobby entrance open on startup

	-- broadcast initial state to all connecting clients
	self:_setState(self._state)
end

function GameService:KnitStop()
	-- no persistent loop to cancel anymore
end

function GameService:DevStart()
	if self._state ~= "Lobby" then
		print("[GameService] Cannot dev start, not in lobby")
		return
	end

	self:_startCountdown()
end

return GameService
