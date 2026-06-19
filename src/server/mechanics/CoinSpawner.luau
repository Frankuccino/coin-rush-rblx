local CollectionService = game:GetService("CollectionService")
local ServerStorage = game:GetService("ServerStorage")

local CoinSpawner = {}
local COIN_TAG = "Coin"
local COIN_TEMPLATE = ServerStorage:WaitForChild("Coin")

local ACTIVE = false
local spawnedCoins = {}

function CoinSpawner:Start()
	if ACTIVE then
		return
	end
	ACTIVE = true
	self:_spawnLoop()
end

function CoinSpawner:Stop()
	ACTIVE = false

	for _, coin in ipairs(spawnedCoins) do
		if coin and coin.Parent then
			coin:Destroy()
		end
	end

	table.clear(spawnedCoins)
end

function CoinSpawner:_spawnLoop()
	task.spawn(function()
		while ACTIVE do
			self:_spawnCoin()
			task.wait(2)
		end
	end)
end

function CoinSpawner:_spawnCoin()
	local coin = COIN_TEMPLATE:Clone()

	coin.Position = Vector3.new(math.random(-50, 50), 5, math.random(-50, 50))

	coin.Anchored = true
	coin.CanCollide = false
	coin.Parent = workspace

	CollectionService:AddTag(coin, COIN_TAG)

	table.insert(spawnedCoins, coin)
end

return CoinSpawner
