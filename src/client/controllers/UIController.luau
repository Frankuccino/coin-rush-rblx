local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local UIStyle = require(ReplicatedStorage.Shared.modules.UIStyle)

local UIController = Knit.CreateController({
	Name = "UIController",
})

type LeaderboardEntry = {
	userId: number,
	userName: string,
	score: number,
	rank: number,
}

type GlobalEntry = {
	userId: number,
	userName: string,
	wins: number,
	coins: number,
}

local player = Players.LocalPlayer

local FADE_INFO = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local POP_INFO = TweenInfo.new(0.18, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

-- ════════════════════════════ LIFECYCLE ════════════════════════════

function UIController:KnitInit()
	self._connections = {}
	self._elements = {}
end

function UIController:KnitStart()
	print("[UIController] Started")
	self.GameService = Knit.GetService("GameService")
	self:_setupUI()
	self:_connectSignals()
end

-- ════════════════════════════ BUILD ════════════════════════════

function UIController:_setupUI()
	local playerGui = player:WaitForChild("PlayerGui")

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "HUD"
	screenGui.ResetOnSpawn = false
	screenGui.IgnoreGuiInset = false
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.Parent = playerGui
	self._screenGui = screenGui

	-- Coin counter, top-left
	local coinCard = self:_createCard({
		name = "CoinCard",
		size = UDim2.new(0, 160, 0, 44),
		position = UDim2.new(0, 16, 0, 12),
		anchorPoint = Vector2.new(0, 0),
		parent = screenGui,
	})
	self._elements.coinLabel = self:_createLabel({
		name = "CoinValue",
		text = "0",
		textColor = UIStyle.Colors.Accent,
		font = UIStyle.FontBold,
		textSize = 20,
		size = UDim2.new(1, -16, 1, 0),
		position = UDim2.new(0, 16, 0, 0),
		textXAlignment = Enum.TextXAlignment.Left,
		parent = coinCard,
	})

	-- Timer, top-center
	local timerCard = self:_createCard({
		name = "TimerCard",
		size = UDim2.new(0, 140, 0, 44),
		position = UDim2.new(0.5, 0, 0, 12),
		anchorPoint = Vector2.new(0.5, 0),
		parent = screenGui,
	})
	self._elements.timerLabel = self:_createLabel({
		name = "TimerValue",
		text = "--:--",
		textColor = UIStyle.Colors.TextPrimary,
		font = UIStyle.FontBold,
		textSize = 20,
		size = UDim2.new(1, 0, 1, 0),
		parent = timerCard,
	})

	-- State pill, below timer
	local statePill = self:_createCard({
		name = "StatePill",
		size = UDim2.new(0, 120, 0, 28),
		position = UDim2.new(0.5, 0, 0, 64),
		anchorPoint = Vector2.new(0.5, 0),
		backgroundColor = UIStyle.Colors.Surface,
		parent = screenGui,
	})
	self._elements.stateLabel = self:_createLabel({
		name = "StateValue",
		text = "Lobby",
		textColor = UIStyle.Colors.TextSecondary,
		font = UIStyle.Font,
		textSize = 13,
		size = UDim2.new(1, 0, 1, 0),
		parent = statePill,
	})

	-- Results overlay (hidden until Results state)
	local resultsOverlay = Instance.new("Frame")
	resultsOverlay.Name = "ResultsOverlay"
	resultsOverlay.Size = UDim2.fromScale(1, 1)
	resultsOverlay.Position = UDim2.fromScale(0, 0)
	resultsOverlay.AnchorPoint = Vector2.new(0, 0)
	resultsOverlay.BackgroundTransparency = 1
	resultsOverlay.Visible = false
	resultsOverlay.Parent = screenGui
	self._elements.resultsOverlay = resultsOverlay

	-- Backdrop: semi-transparent surface for readability
	local backdrop = Instance.new("Frame")
	backdrop.Name = "Backdrop"
	backdrop.Size = UDim2.fromScale(1, 1)
	backdrop.BackgroundColor3 = Color3.new(0, 0, 0)
	backdrop.BackgroundTransparency = 0.55
	backdrop.Parent = resultsOverlay

	-- Winner podium container (centered)
	local winnerPodium = Instance.new("Frame")
	winnerPodium.Name = "WinnerPodium"
	winnerPodium.Size = UDim2.new(0, 420, 0, 400)
	winnerPodium.Position = UDim2.new(0.5, 0, 0.5, 0)
	winnerPodium.AnchorPoint = Vector2.new(0.5, 0.5)
	winnerPodium.BackgroundTransparency = 1
	winnerPodium.Parent = resultsOverlay
	self._elements.winnerPodium = winnerPodium

	-- Winner card (top of podium)
	local winnerCard = self:_createCard({
		name = "WinnerCard",
		size = UDim2.new(1, 0, 0, 110),
		position = UDim2.new(0, 0, 0, 0),
		anchorPoint = Vector2.new(0, 0),
		backgroundColor = UIStyle.Colors.Surface,
		parent = winnerPodium,
	})
	local crown = self:_createLabel({
		name = "Crown",
		text = "👑",
		textColor = UIStyle.Colors.Accent,
		font = UIStyle.FontBold,
		textSize = 28,
		size = UDim2.new(0, 40, 0, 40),
		position = UDim2.new(0, 12, 0, 8),
		textXAlignment = Enum.TextXAlignment.Center,
		parent = winnerCard,
	})
	self._elements.winnerLabel = self:_createLabel({
		name = "WinnerText",
		text = "",
		textColor = UIStyle.Colors.TextPrimary,
		font = UIStyle.FontBold,
		textSize = 22,
		size = UDim2.new(1, -64, 1, 0),
		position = UDim2.new(0, 56, 0, 0),
		textXAlignment = Enum.TextXAlignment.Left,
		parent = winnerCard,
	})
	self._elements.winnerScoreLabel = self:_createLabel({
		name = "WinnerScore",
		text = "",
		textColor = UIStyle.Colors.Accent,
		font = UIStyle.FontBold,
		textSize = 18,
		size = UDim2.new(1, -64, 0, 24),
		position = UDim2.new(0, 56, 0, 28),
		textXAlignment = Enum.TextXAlignment.Left,
		parent = winnerCard,
	})

	-- Round leaderboard panel (below winner)
	local roundPanel = self:_createCard({
		name = "RoundLeaderboard",
		size = UDim2.new(1, 0, 1, -100),
		position = UDim2.new(0, 0, 0, 110),
		anchorPoint = Vector2.new(0, 0),
		backgroundColor = UIStyle.Colors.Surface,
		parent = winnerPodium,
	})
	roundPanel.Visible = false
	self._elements.roundLeaderboard = roundPanel
	self._elements.roundTitle = self:_createLabel({
		name = "RoundTitle",
		text = "Round Rankings",
		textColor = UIStyle.Colors.TextSecondary,
		font = UIStyle.FontBold,
		textSize = 14,
		size = UDim2.new(1, -16, 0, 24),
		position = UDim2.new(0, 8, 0, 6),
		textXAlignment = Enum.TextXAlignment.Left,
		parent = roundPanel,
	})

	-- Global leaderboard panel (hidden, shown via dedicated toggle or below round)
	local globalPanel = self:_createCard({
		name = "GlobalLeaderboard",
		size = UDim2.new(1, 0, 1, -100),
		position = UDim2.new(0, 0, 0, 110),
		anchorPoint = Vector2.new(0, 0),
		backgroundColor = UIStyle.Colors.Surface,
		parent = winnerPodium,
	})
	globalPanel.Visible = false
	self._elements.globalLeaderboard = globalPanel
	self._elements.globalTitle = self:_createLabel({
		name = "GlobalTitle",
		text = "Global Leaderboard",
		textColor = UIStyle.Colors.TextSecondary,
		font = UIStyle.FontBold,
		textSize = 14,
		size = UDim2.new(1, -16, 0, 24),
		position = UDim2.new(0, 8, 0, 6),
		textXAlignment = Enum.TextXAlignment.Left,
		parent = globalPanel,
	})

	-- Prestige button (bottom-right of podium, visible when prestige available)
	local prestigeButton = self:_createCard({
		name = "PrestigeButton",
		size = UDim2.new(0, 180, 0, 36),
		position = UDim2.new(1, -196, 1, -48),
		anchorPoint = Vector2.new(1, 1),
		backgroundColor = UIStyle.Colors.Accent,
		parent = winnerPodium,
	})
	prestigeButton.Visible = false
	self._elements.prestigeButton = prestigeButton
	self:_createLabel({
		name = "PrestigeText",
		text = "PRESTIGE",
		textColor = Color3.new(0, 0, 0),
		font = UIStyle.FontBold,
		textSize = 14,
		size = UDim2.new(1, 0, 1, 0),
		textXAlignment = Enum.TextXAlignment.Center,
		parent = prestigeButton,
	})

	local prestigeConn
	prestigeConn = prestigeButton.InputBegan:Connect(function(input)
		if
			input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch
		then
			self:_showPrestigeConfirm()
		end
	end)
	table.insert(self._connections, prestigeConn)

	-- Prestige confirm modal
	local modalOverlay = Instance.new("Frame")
	modalOverlay.Name = "PrestigeModal"
	modalOverlay.Size = UDim2.fromScale(1, 1)
	modalOverlay.BackgroundTransparency = 0.4
	modalOverlay.BackgroundColor3 = Color3.new(0, 0, 0)
	modalOverlay.Visible = false
	modalOverlay.Parent = screenGui
	self._elements.prestigeModal = modalOverlay

	local modalCard = self:_createCard({
		name = "PrestigeCard",
		size = UDim2.new(0, 320, 0, 180),
		position = UDim2.new(0.5, 0, 0.5, -90),
		anchorPoint = Vector2.new(0.5, 0.5),
		backgroundColor = UIStyle.Colors.Surface,
		parent = modalOverlay,
	})
	modalCard.BackgroundTransparency = 0
	self:_createLabel({
		name = "PrestigeTitle",
		text = "Confirm Prestige",
		textColor = UIStyle.Colors.TextPrimary,
		font = UIStyle.FontBold,
		textSize = 22,
		size = UDim2.new(1, -24, 0, 36),
		position = UDim2.new(0, 12, 0, 12),
		textXAlignment = Enum.TextXAlignment.Center,
		parent = modalCard,
	})
	self:_createLabel({
		name = "PrestigeDesc",
		text = "Prestige will reset session coins.\nYou will gain a permanent +10% multiplier per level.",
		textColor = UIStyle.Colors.TextSecondary,
		font = UIStyle.Font,
		textSize = 14,
		size = UDim2.new(1, -24, 0, 60),
		position = UDim2.new(0, 12, 0, 56),
		textXAlignment = Enum.TextXAlignment.Left,
		parent = modalCard,
	})
	local confirmButton = self:_createCard({
		name = "PrestigeConfirm",
		size = UDim2.new(0, 120, 0, 36),
		position = UDim2.new(0.5, -80, 1, -56),
		anchorPoint = Vector2.new(0.5, 1),
		backgroundColor = UIStyle.Colors.Accent,
		parent = modalCard,
	})
	confirmButton.BackgroundTransparency = 0
	self:_createLabel({
		name = "PrestigeConfirmText",
		text = "CONFIRM",
		textColor = Color3.new(0, 0, 0),
		font = UIStyle.FontBold,
		textSize = 14,
		size = UDim2.new(1, 0, 1, 0),
		textXAlignment = Enum.TextXAlignment.Center,
		parent = confirmButton,
	})
	local cancelButton = self:_createCard({
		name = "PrestigeCancel",
		size = UDim2.new(0, 120, 0, 36),
		position = UDim2.new(0.5, 80, 1, -56),
		anchorPoint = Vector2.new(0.5, 1),
		backgroundColor = UIStyle.Colors.Surface,
		parent = modalCard,
	})
	cancelButton.BackgroundTransparency = 0
	self:_createLabel({
		name = "PrestigeCancelText",
		text = "CANCEL",
		textColor = UIStyle.Colors.TextPrimary,
		font = UIStyle.FontBold,
		textSize = 14,
		size = UDim2.new(1, 0, 1, 0),
		textXAlignment = Enum.TextXAlignment.Center,
		parent = cancelButton,
	})

	local confirmConn
	confirmConn = confirmButton.InputBegan:Connect(function(input)
		if
			input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch
		then
			self:_hidePrestigeConfirm()
			self:_handlePrestige()
		end
	end)
	table.insert(self._connections, confirmConn)

	local cancelConn
	cancelConn = cancelButton.InputBegan:Connect(function(input)
		if
			input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch
		then
			self:_hidePrestigeConfirm()
		end
	end)
	table.insert(self._connections, cancelConn)

	-- Intermission big timer
	local intermissionTimer = self:_createLabel({
		name = "IntermissionTimer",
		text = "",
		textColor = UIStyle.Colors.Accent,
		font = UIStyle.FontBold,
		textSize = 64,
		size = UDim2.new(0, 200, 0, 80),
		position = UDim2.new(0.5, -100, 0.5, -40),
		anchorPoint = Vector2.new(0.5, 0.5),
		textXAlignment = Enum.TextXAlignment.Center,
		parent = screenGui,
	})
	intermissionTimer.Visible = false
	self._elements.intermissionTimer = intermissionTimer
end

-- ════════════════════════════ FACTORIES ════════════════════════════

type CardOptions = {
	name: string,
	size: UDim2,
	position: UDim2,
	anchorPoint: Vector2,
	backgroundColor: Color3?,
	parent: Instance,
}

function UIController:_createCard(opts: CardOptions): Frame
	local frame = Instance.new("Frame")
	frame.Name = opts.name
	frame.Size = opts.size
	frame.Position = opts.position
	frame.AnchorPoint = opts.anchorPoint
	frame.BackgroundColor3 = opts.backgroundColor or UIStyle.Colors.Surface
	frame.BorderSizePixel = 0
	frame.Parent = opts.parent

	UIStyle.applyCorner(frame)
	UIStyle.applyStroke(frame)

	return frame
end

type LabelOptions = {
	name: string,
	text: string,
	textColor: Color3,
	font: Enum.Font,
	textSize: number,
	size: UDim2,
	position: UDim2?,
	textXAlignment: Enum.TextXAlignment?,
	parent: Instance,
}

function UIController:_createLabel(opts: LabelOptions): TextLabel
	local label = Instance.new("TextLabel")
	label.Name = opts.name
	label.Text = opts.text
	label.TextColor3 = opts.textColor
	label.Font = opts.font
	label.TextSize = opts.textSize
	label.Size = opts.size
	label.Position = opts.position or UDim2.new(0, 0, 0, 0)
	label.TextXAlignment = opts.textXAlignment or Enum.TextXAlignment.Center
	label.TextYAlignment = Enum.TextYAlignment.Center
	label.BackgroundTransparency = 1
	label.Parent = opts.parent
	return label
end

-- ════════════════════════════ SIGNALS ════════════════════════════

function UIController:_connectSignals()
	local gameService = self.GameService

	local function connect(signal, callback)
		local conn = signal:Connect(callback)
		table.insert(self._connections, conn)
	end

	connect(gameService.TimerUpdated, function(timeLeft)
		self:_setTimer(timeLeft)
	end)

	connect(gameService.CountdownUpdated, function(timeLeft)
		self:_updateArenaCountdownText(timeLeft)
	end)

	connect(gameService.StateChanged, function(state)
		self:_setState(state)
		self:_handleState(state)
	end)

	connect(gameService.RoundCoinsUpdated, function(score)
		self:_setCoins(score)
	end)

	connect(gameService.LeaderboardUpdated, function(topThree)
		self:_showRoundLeaderboard(topThree)
	end)

	connect(gameService.WinnerAnnounced, function(winnerName, score)
		self:_showWinnerAnnouncement(winnerName, score)
	end)

	connect(gameService.GlobalLeaderboardUpdated, function(entries)
		self:_showGlobalLeaderboard(entries)
	end)

	connect(gameService.PrestigeAvailable, function()
		self:_showPrestigeButton()
	end)

	if gameService.PrestigeCompleted then
		connect(gameService.PrestigeCompleted, function()
			self:_hidePrestigeButton()
		end)
	end

	connect(gameService.CoinCollected, function(_player, amount, _tier)
		self:_spawnCoinPopup(amount)
	end)
end

-- ════════════════════════════ UPDATE HANDLERS ════════════════════════════

function UIController:_setCoins(amount: number)
	local label = self._elements.coinLabel
	label.Text = tostring(amount)

	-- Pop animation via TweenService, not a raw loop
	local card = label.Parent :: Frame
	local original = card.Size
	card.Size = UDim2.new(
		original.X.Scale,
		original.X.Offset * 1.08,
		original.Y.Scale,
		original.Y.Offset * 1.08
	)
	TweenService:Create(card, POP_INFO, { Size = original }):Play()
end

function UIController:_setTimer(secondsRemaining: number)
	local minutes = math.floor(secondsRemaining / 60)
	local seconds = secondsRemaining % 60
	local text = string.format("%d:%02d", minutes, seconds)
	self._elements.timerLabel.Text = text

	local interTimer = self._elements.intermissionTimer
	if interTimer and interTimer.Visible then
		interTimer.Text = text
	end
end

function UIController:_updateArenaCountdownText(timeLeft: number)
	local ws = game:GetService("Workspace")
	local countdownPart = ws:FindFirstChild("Arena")
		and ws.Arena:FindFirstChild("ArenaEntrance")
		and ws.Arena.ArenaEntrance:FindFirstChild("ArenaCountdown")
	if not countdownPart then
		return
	end

	local surfaceGui = countdownPart:FindFirstChild("SurfaceGui")
	if not surfaceGui then
		return
	end

	local textLabel = surfaceGui:FindFirstChild("TextLabel")
	if not textLabel then
		return
	end

	textLabel.Text = tostring(timeLeft)
end

function UIController:_setState(state: string)
	self._elements.stateLabel.Text = state
end

function UIController:_handleState(state: string)
	local results = self._elements.resultsOverlay
	if not results then
		return
	end

	if state == "Results" then
		results.Visible = true
		-- clear stray popups from the HUD so nothing overlaps results
		for _, child in ipairs(self._screenGui:GetChildren()) do
			if child.Name == "CoinPopup" then
				child:Destroy()
			end
		end
	else
		results.Visible = false
	end

	-- intermission big timer
	local interTimer = self._elements.intermissionTimer
	if interTimer then
		if state == "Intermission" then
			interTimer.Visible = true
		else
			interTimer.Visible = false
		end
	end
end

function UIController:_spawnCoinPopup(amount: number)
	local pop = self:_createCard({
		name = "CoinPopup",
		size = UDim2.new(0, 80, 0, 36),
		position = UDim2.new(0.5, -40, 0.5, -80),
		anchorPoint = Vector2.new(0.5, 0.5),
		backgroundColor = UIStyle.Colors.Surface,
		parent = self._screenGui,
	})

	local label = self:_createLabel({
		name = "PopupText",
		text = "+" .. tostring(amount),
		textColor = UIStyle.Colors.Accent,
		font = UIStyle.FontBold,
		textSize = 18,
		size = UDim2.new(1, 0, 1, 0),
		parent = pop,
	})

	local tween = TweenService:Create(
		pop,
		TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{ Position = UDim2.new(0.5, -40, 0.25, -80) }
	)
	tween:Play()
	task.delay(0.6, function()
		pop:Destroy()
	end)
end

function UIController:_showRoundLeaderboard(topThree: {
	userId: number,
	userName: string,
	score: number,
	rank: number,
})
	local panel = self._elements.roundLeaderboard
	local title = self._elements.roundTitle
	if not panel or not title then
		return
	end

	panel.Visible = true

	-- clear previous rows
	for _, child in ipairs(panel:GetChildren()) do
		if child.Name ~= "RoundTitle" then
			child:Destroy()
		end
	end

	local function makeRow(i: number, name: string, score: number)
		local row = self:_createCard({
			name = "Rank" .. i,
			size = UDim2.new(1, -16, 0, 26),
			position = UDim2.new(0, 8, 0, 32 + (i - 1) * 30),
			anchorPoint = Vector2.new(0, 0),
			backgroundColor = UIStyle.Colors.Surface,
			parent = panel,
		})

		local medal = ""
		if i == 1 then
			medal = "🥇 "
		elseif i == 2 then
			medal = "🥈 "
		elseif i == 3 then
			medal = "🥉 "
		end

		self:_createLabel({
			name = "Rank" .. i .. "Text",
			text = medal .. i .. ". " .. name .. "  " .. tostring(score),
			textColor = UIStyle.Colors.TextPrimary,
			font = UIStyle.Font,
			textSize = 13,
			size = UDim2.new(1, -8, 1, 0),
			position = UDim2.new(0, 4, 0, 0),
			textXAlignment = Enum.TextXAlignment.Left,
			parent = row,
		})
	end

	if topThree and #topThree >= 1 then
		makeRow(topThree[1].rank, topThree[1].userName, topThree[1].score)
	end
	if topThree and #topThree >= 2 then
		makeRow(topThree[2].rank, topThree[2].userName, topThree[2].score)
	end
	if topThree and #topThree >= 3 then
		makeRow(topThree[3].rank, topThree[3].userName, topThree[3].score)
	end
end

function UIController:_showWinnerAnnouncement(winnerName: string, score: number)
	if not self._elements.winnerLabel then
		return
	end
	self._elements.winnerLabel.Text = winnerName .. " claimed the crown!"
	if self._elements.winnerScoreLabel then
		self._elements.winnerScoreLabel.Text = tostring(score) .. " coins"
	end
end

function UIController:_showGlobalLeaderboard(entries)
	local panel = self._elements.globalLeaderboard
	local title = self._elements.globalTitle
	if not panel or not title then
		return
	end

	panel.Visible = true

	-- hide round panel while global is shown
	if self._elements.roundLeaderboard then
		self._elements.roundLeaderboard.Visible = false
	end

	-- clear previous rows
	for _, child in ipairs(panel:GetChildren()) do
		if child.Name ~= "GlobalTitle" then
			child:Destroy()
		end
	end

	local function makeRow(i: number, name: string, wins: number, coins: number)
		local row = self:_createCard({
			name = "GlobalRank" .. i,
			size = UDim2.new(1, -16, 0, 26),
			position = UDim2.new(0, 8, 0, 32 + (i - 1) * 30),
			anchorPoint = Vector2.new(0, 0),
			backgroundColor = UIStyle.Colors.Surface,
			parent = panel,
		})

		local medal = ""
		if i == 1 then
			medal = "🥇 "
		elseif i == 2 then
			medal = "🥈 "
		elseif i == 3 then
			medal = "🥉 "
		end

		self:_createLabel({
			name = "GlobalRank" .. i .. "Text",
			text = string.format("%s%d. %s  Wins:%d Coins:%d", medal, i, name, wins, coins),
			textColor = UIStyle.Colors.TextPrimary,
			font = UIStyle.Font,
			textSize = 13,
			size = UDim2.new(1, -8, 1, 0),
			position = UDim2.new(0, 4, 0, 0),
			textXAlignment = Enum.TextXAlignment.Left,
			parent = row,
		})
	end

	if entries then
		for i = 1, math.min(5, #entries) do
			local entry = entries[i]
			makeRow(i, entry.userName, entry.wins, entry.coins)
		end
	end
end

function UIController:_showPrestigeButton()
	if self._elements.prestigeButton then
		self._elements.prestigeButton.Visible = true
	end
end

function UIController:_hidePrestigeButton()
	if self._elements.prestigeButton then
		self._elements.prestigeButton.Visible = false
	end
end

function UIController:_showPrestigeConfirm()
	if self._elements.prestigeModal then
		self._elements.prestigeModal.Visible = true
	end
end

function UIController:_hidePrestigeConfirm()
	if self._elements.prestigeModal then
		self._elements.prestigeModal.Visible = false
	end
end

function UIController:_handlePrestige()
	local gameService = self.GameService
	if gameService and gameService.Prestige then
		gameService:Prestige(player)
	end
end

-- ════════════════════════════ CLEANUP ════════════════════════════

function UIController:Destroy()
	for _, conn in self._connections do
		conn:Disconnect()
	end
	self._connections = {}

	if self._screenGui then
		self._screenGui:Destroy()
	end
end

return UIController
