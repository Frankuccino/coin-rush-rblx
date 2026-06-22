local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)

local Controller = Knit.CreateController({
	Name = script.Name,
})

local _currentState: string? = nil
local _lobbyMusic: Sound? = nil
local _arenaMusic: Sound? = nil
local _lobbyMusicMissing = false
local _arenaMusicMissing = false
local _winSound: Sound? = nil
local _loseSound: Sound? = nil
local _winSoundMissing = false
local _loseSoundMissing = false

function Controller:_resolveLobbyMusic(): Sound?
	if _lobbyMusicMissing then
		return nil
	end

	local candidates = {
		game:GetService("Workspace"):FindFirstChild("LobbyMusic"),
		game:GetService("ReplicatedStorage"):FindFirstChild("LobbyMusic"),
		game:GetService("ReplicatedStorage"):FindFirstChild("Audio")
			and game.ReplicatedStorage.Audio:FindFirstChild("LobbyMusic"),
	}
	for _, sound in candidates do
		if sound:IsA("Sound") then
			_lobbyMusicMissing = false
			return sound
		end
	end

	if not _lobbyMusicMissing then
		warn("[SoundController] LobbyMusic Sound not found in workspace/replicatedStorage")
		_lobbyMusicMissing = true
	end
	return nil
end

function Controller:_resolveArenaMusic(): Sound?
	if _arenaMusicMissing then
		return nil
	end

	local candidates = {
		game:GetService("Workspace"):FindFirstChild("ArenaMusic"),
		game:GetService("ReplicatedStorage"):FindFirstChild("ArenaMusic"),
		game:GetService("ReplicatedStorage"):FindFirstChild("Audio")
			and game.ReplicatedStorage.Audio:FindFirstChild("ArenaMusic"),
	}
	for _, sound in candidates do
		if sound:IsA("Sound") then
			_arenaMusicMissing = false
			return sound
		end
	end

	if not _arenaMusicMissing then
		warn("[SoundController] ArenaMusic Sound not found in workspace/replicatedStorage")
		_arenaMusicMissing = true
	end
	return nil
end

function Controller:_resolveWinSound(): Sound?
	if _winSoundMissing then
		return nil
	end

	local candidates = {
		game:GetService("Workspace"):FindFirstChild("WinSound"),
		game:GetService("ReplicatedStorage"):FindFirstChild("WinSound"),
		game:GetService("ReplicatedStorage"):FindFirstChild("Audio")
			and game.ReplicatedStorage.Audio:FindFirstChild("WinSound"),
	}
	for _, sound in candidates do
		if sound:IsA("Sound") then
			_winSoundMissing = false
			return sound
		end
	end

	if not _winSoundMissing then
		warn("[SoundController] WinSound Sound not found")
		_winSoundMissing = true
	end
	return nil
end

function Controller:_resolveLoseSound(): Sound?
	if _loseSoundMissing then
		return nil
	end

	local candidates = {
		game:GetService("Workspace"):FindFirstChild("LoseSound"),
		game:GetService("ReplicatedStorage"):FindFirstChild("LoseSound"),
		game:GetService("ReplicatedStorage"):FindFirstChild("Audio")
			and game.ReplicatedStorage.Audio:FindFirstChild("LoseSound"),
	}
	for _, sound in candidates do
		if sound:IsA("Sound") then
			_loseSoundMissing = false
			return sound
		end
	end

	if not _loseSoundMissing then
		warn("[SoundController] LoseSound Sound not found")
		_loseSoundMissing = true
	end
	return nil
end

function Controller:_setState(state: string)
	if _currentState == state then
		return
	end
	_currentState = state
	print("[SoundController] State changed to:", state)

	if state == "Active" then
		self:_stopLobbyMusic()
		self:_playArenaMusic()
	else
		self:_stopArenaMusic()
		self:_playLobbyMusic()
	end
end

function Controller:_playLobbyMusic()
	if not _lobbyMusic then
		_lobbyMusic = self:_resolveLobbyMusic()
		if not _lobbyMusic then
			return
		end
	end

	_lobbyMusic.Looped = true
	_lobbyMusic.Volume = 0.3

	if not _lobbyMusic.IsPlaying then
		_lobbyMusic:Play()
	end
end

function Controller:_stopLobbyMusic()
	if _lobbyMusic and _lobbyMusic.IsPlaying then
		_lobbyMusic:Stop()
	end
end

function Controller:_playArenaMusic()
	if not _arenaMusic then
		_arenaMusic = self:_resolveArenaMusic()
		if not _arenaMusic then
			-- fallback: keep lobby music if arena music missing
			return
		end
	end

	_arenaMusic.Looped = true
	_arenaMusic.Volume = 0.3

	if not _arenaMusic.IsPlaying then
		_arenaMusic:Play()
	end
end

function Controller:_stopArenaMusic()
	if _arenaMusic and _arenaMusic.IsPlaying then
		_arenaMusic:Stop()
	end
end

function Controller:_playWinSound()
	if not _winSound then
		_winSound = self:_resolveWinSound()
		if not _winSound then
			return
		end
	end

	if not _winSound.IsPlaying then
		_winSound:Play()
	end
end

function Controller:_playLoseSound()
	if not _loseSound then
		_loseSound = self:_resolveLoseSound()
		if not _loseSound then
			return
		end
	end

	if not _loseSound.IsPlaying then
		_loseSound:Play()
	end
end

function Controller:KnitStart()
	local GameService = Knit.GetService("GameService")
	local Players = game:GetService("Players")
	local localPlayer = Players.LocalPlayer

	if not GameService then
		warn("[SoundController] GameService not found")
		return
	end

	-- default to lobby music on startup; GameService starts in Lobby
	self:_playLobbyMusic()

	GameService.StateChanged:Connect(function(state)
		self:_setState(state)
	end)

	-- play win/lose SFX when results come in
	if localPlayer then
		GameService.WinnerAnnounced:Connect(function(winnerName: string, _winnerScore: number)
			if winnerName == localPlayer.Name then
				self:_playWinSound()
			else
				self:_playLoseSound()
			end
		end)
	end
end

return Controller
