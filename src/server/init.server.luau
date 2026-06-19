print("Server Started")
print("Hello world, from server!")

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)

print("[Server] Starting Knit...")

Knit.AddServices(script.Parent.Server.services)

Knit.Start()
	:andThen(function()
		print("[Server] Knit started")
	end)
	:catch(function(err)
		warn("[Server] Knit failed:", err)
	end)
