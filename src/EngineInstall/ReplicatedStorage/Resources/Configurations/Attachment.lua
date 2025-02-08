local Resources = require(game.ReplicatedStorage.Resources)
local Attachment = Resources:LoadLibrary("Attachment")
local inList = function(Element, List)
	for _, v in pairs(List) do
		if v == Element then
			return true
		end
	end
	return false
end
local Attachments = {
	--[[
    Example:
    
    ["ACOG"] = Attachment.new("ACOG","Trijicon ACOG TA-02","Optics","SightNode",{
			FOV = 29;		
	},"Primary",false,"A scope commonly used on infantry weapons.","M4","M4A1","SCAR-L","SCAR-H","SCAR HAMR","SCAR SSR");
	
    ]]--
	
};	

return Attachments