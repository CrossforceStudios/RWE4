local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Resources = require(ReplicatedStorage:WaitForChild("Resources",10))
-- Setup your flags here
Resources:SetupFlags({

})
-- Necessary Modules
local RemoteService = Resources:LoadLibrary("RemoteService")