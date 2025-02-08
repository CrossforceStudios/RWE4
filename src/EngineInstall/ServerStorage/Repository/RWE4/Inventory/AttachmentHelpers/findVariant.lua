local Resources = require(game.ReplicatedStorage.Resources)
local AG  = Resources:LoadConfiguration("AttachmentGroups")
local AndList = Resources:LoadLibrary("AndList")
return function(attachName: string, options: {number}) : string?
	local agSnip = AG[attachName]
	local result: string?
	if agSnip then
		for i, aMap in agSnip.AttachmentMap do
				local resList = {}
				for i2, val in aMap.Options do
					table.insert(resList, val == options[i2])
				end
				if AndList(resList) then
					result = aMap.Name
					break;
				end	
		end
	end
	return result
end