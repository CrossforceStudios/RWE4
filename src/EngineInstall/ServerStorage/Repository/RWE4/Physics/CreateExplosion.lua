
local Resources = require(game.ReplicatedStorage.Resources)
local Make = Resources:LoadLibrary("Make")
local ET = Resources:LoadConfiguration("ExplosionTypes")
function createExplosion(P,Radius,Type,Extras,Callback)
	local E 
	if (not ET.HitTypes[Type]) then 
		return nil;
	end
	if Type == "Custom" or  (not ET.HitTypes[Type].Create) then
		E = Make("Explosion"){
			BlastPressure = 0;
			BlastRadius = Radius;
			DestroyJointRadiusPercent = 0;
			ExplosionType = Enum.ExplosionType.NoCraters;
			Position = P;
		};
	else
		E = ET.HitTypes[Type].Create(P,Radius,Extras)
	end
	Extras.Position = P;
	local OnHit
	if Type == "Custom" then
		OnHit = Callback
	elseif ET.HitTypes[Type] then
		OnHit = ET.HitTypes[Type].Hit
	end
	if OnHit then 
		E.Hit:Connect(function(Obj,Dist)
			OnHit(Obj,Dist,Extras)
		end)
	end
	E.Parent = workspace
	return E
end	

return createExplosion