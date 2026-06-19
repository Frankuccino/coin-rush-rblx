-- players spawn at lobby SpawnLocation
-- HUD shows "Waiting for players..." with current count
-- Minimum player count check runs every 5s via task.spawn
-- Once >=2 players: transition to Countdown
-- PlayerAdded/PlayerRemoving update lobby count via RemoteEvent to all clients

function GameService:_checkLobby()
	local count = #Players:GetPlayers()
	if cout >= MIN_PLAYERS and self._state == "Lobby" then
		self:_setState("Countdown")
	end
end

print("Hello world")
