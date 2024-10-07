local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Resources = require(ReplicatedStorage:WaitForChild("Resources",10))
-- Setup your flags here
Resources:SetupFlags({

})
-- Necessary Modules
local Players = game:GetService("Players")
local RemoteService = Resources:LoadLibrary("RemoteService")
local EventSystem = Resources:LoadLibrary("EventUtils")
-- Event System
local ServerSettings = require(script.Parent.ServerSettings)
for _, event in ServerSettings.Events do
    EventSystem:AddEvent(event)
end

for _, pair in ServerSettings.CollisionPairs do
	PhysicsService:CollisionGroupSetCollidable(pair[1], pair[2], pair[3])
end

Players.PlayerAdded:Connect(function(plr)
	EventSystem:FireEvent("PlayerAdded", plr)
end)