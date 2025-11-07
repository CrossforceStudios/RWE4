local Resources = require(game.ReplicatedStorage.Resources)
local DamageTag = Resources:LoadLibrary("DamageTag")
local function tagHumanoid(Gun, humanoid, player, damage, previousHealth, headShot, dist, part, explosive, eType) 
	local tag 
	local p = game.Players:GetPlayerFromCharacter(humanoid.Parent)
	if humanoid.Health > 1 then
		tag = DamageTag.new((p and game.CollectionService:GetTags(p)[1] or  game.CollectionService:GetTags(humanoid.Parent)[1]),damage,game.CollectionService:GetTags(Gun)[1],game.CollectionService:GetTags(player)[1],headShot,dist,explosive,eType)
	else
		tag = DamageTag.new((p and game.CollectionService:GetTags(p)[1] or  game.CollectionService:GetTags(humanoid.Parent)[1]),previousHealth,game.CollectionService:GetTags(Gun)[1],game.CollectionService:GetTags(player)[1],headShot,dist,explosive,eType)
	end
	if part and humanoid.Name ~= "Target" then
		if part.Name == "Head" or part.Name == "Torso" or part.Name:find("Arm") or part.Name:find("Leg") then
			pcall(function() tag:AddWound(part) end)
		end
	end
	if tag then
		tag:MarkEnemy(humanoid)
	end
end 
return tagHumanoid