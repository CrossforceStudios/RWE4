local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Resources = require(ReplicatedStorage:WaitForChild("Resources",10))
local Players = game:GetService("Players")
local player = Players.LocalPlayer
-- Setup your flags here
Resources:SetupFlags({

})
local Character = nil;
local CharacterParts = {};

_G.CharacterStance = {};
-- Necessary Modules
local RemoteService = Resources:LoadLibrary("RemoteService")
local CameraService = Resources:LoadLibrary("CameraService")
--CameraService:startClient()
player.CharacterAdded:Connect(function(ch)
    Character = ch
    CharacterParts.Head = ch:WaitForChild("Head", 20)
    --CameraService:setCamMode("FirstPerson", CharacterParts.Head)
    CharacterParts.ASM = Resources:LoadLibrary("AnimateHelper")(Character)

end)
