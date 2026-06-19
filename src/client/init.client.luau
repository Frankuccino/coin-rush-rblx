print("Client Started")

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)

print("[Client] Starting Knit...")

Knit.Start()
	:andThen(function()
		print("[Client] Knit started")
	end)
	:catch(function(err)
		warn("[Client] Knit failed:", err)
	end)
