local Resources = require(game.ReplicatedStorage.Resources)
local SeriesM = Resources:LoadLibrary("SeriesMath")
local Lerps = Resources:LoadLibrary("Lerps")
local DropoffModels = Resources:LoadConfiguration("DropoffModels")
local function getBaseDamage(Gun,S,Dist,CurrentCartridge)
	if Gun.Parent then
		local startDmg = CurrentCartridge.Damage.Min
		local startDist = S.Start.Dist
		local endDmg = CurrentCartridge.Damage.Max
		local endDist = S.End.Dist
		if S.Model then
			endDist = DropoffModels[S.Model].Max
			startDist = DropoffModels[S.Model].Min
		end
		local dmg =  (
			(
				Dist < startDist * CurrentCartridge.Range
			) and startDmg or
				(
					Dist >= startDist * CurrentCartridge.Range and
					Dist < endDist * CurrentCartridge.Range
				) and Lerps.number(startDmg, endDmg, SeriesM:Map(Dist / CurrentCartridge.Range, startDist, endDist, 0, 1)) or
				(
					Dist >= endDist * CurrentCartridge.Range
				) and endDmg
		)
		return dmg
	end
end
return getBaseDamage;