-- Description:

-- A Module which holds animation names for both
-- R6 and R15, dance names, and emote values.

-- The Animate module heavily depends on this
-- module to get its information

local Resources = require(game.ReplicatedStorage.Resources)
local player = game.Players.LocalPlayer
local PlayerScripts = player:WaitForChild("PlayerScripts", 20)
local CS = require(PlayerScripts:FindFirstChild("ClientSettings"))

-- R6_animNames
local R6_animNames = CS.AnimIds



-- Functions
local function GetAnimation(self, Name)
	return self[Name]
end

local function ConfigureAnimation(self, Name, AnimationNumber, NewId)
	local Animation = self:GetAnimation(Name)
	assert(Animation, "Given Name does not exist in animNames")

	Animation[AnimationNumber].id = NewId
end

R6_animNames.GetAnimation        = GetAnimation
R6_animNames.ConfigureAnimation  = ConfigureAnimation 


-- dances

-- emoteNames
return {
	animNames = {R6 = R6_animNames}; 
}