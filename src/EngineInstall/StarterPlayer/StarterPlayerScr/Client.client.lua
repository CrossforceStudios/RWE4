local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Resources = require(ReplicatedStorage:WaitForChild("Resources",10))
local Players = game:GetService("Players")
local player = Players.LocalPlayer
-- Setup your flags here
Resources:SetupFlags({

})
-- Necessary Modules
local RemoteService = Resources:LoadLibrary("RemoteService")
local CameraService = Resources:LoadLibrary("CameraService")
CameraService:startClient()
player.CharacterAdded:Connect(function(ch)
    CameraService:setCamMode("FirstPerson", ch:WaitForChild("Head", 20))
end)
