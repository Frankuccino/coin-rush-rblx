-- CoinSpawnService spawns coins every 2s at random arena positions using CollectionService tags
-- Coins spin via RunService.Heartbeaton the server (simple CFrame rotation)
-- Player touches coin -> Touched event fires -> server validates proximity -> awards coins -> fires UI update
-- Collect VFX (ParticleEmmitter bursr + TweenService scale-down) plays on client via RemoteEvent
-- 60-second server timer decrements, fires each second to clients for HUD timer
-- Timer reaches 0 -> transition to Results

local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")

local CoinService = Knit.CreateService({
	Name = "CoinService",
	Client = {},
})

local COIN_TAG = "Coin"

function CoinService:KnitStart()
	print("[CoinService] Started")
	self:_connectCoins()
end

function CoinService:_connectCoins()
	local coins = CollectionService:GetTagged(COIN_TAG)

	print("Found coins:", #coins)

	for _, coin in ipairs(coins) do
		self:_hookCoin(coin)
	end

	CollectionService:GetInstanceAddedSignal(COIN_TAG):Connect(function(coin)
		print("New coin tagged:", coin.Name)
		self:_hookCoin(coin)
	end)
end

function CoinService:_hookCoin(coin)
	if not coin:IsA("BasePart") then
		return
	end

	-- when player touches a coin
	coin.Touched:Connect(function(hit)
		local character = hit.Parent

		local player = Players:GetPlayerFromCharacter(character)

		if not player then
			return
		end

		self:_collectCoin(player, coin)
	end)
end

function CoinService:_collectCoin(player, coin)
	if coin:GetAttribute("Collected") then
		return
	end

	coin:SetAttribute("Collected", true)
	print(player.Name .. " collected a coin!")

	coin:Destroy()
end

return CoinService
