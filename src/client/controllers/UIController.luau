local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local UIStyle = require(ReplicatedStorage.Shared.modules.UIStyle)

local UIController = Knit.CreateController({
	Name = "UIController",
})

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

	-- Coin counter, top-left, scale-anchored
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

	-- Timer, top-center — AnchorPoint(0.5, 0) so it stays centered on
	-- any resolution, unlike a hardcoded -100 offset
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

	-- State pill, below the timer, also center-anchored
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

	connect(gameService.StateChanged, function(state)
		self:_setState(state)
	end)

	connect(gameService.RoundCoinsUpdated, function(score)
		self:_setCoins(score)
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
	self._elements.timerLabel.Text = string.format("%d:%02d", minutes, seconds)
end

function UIController:_setState(state: string)
	self._elements.stateLabel.Text = state
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
