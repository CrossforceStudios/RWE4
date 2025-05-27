local Resources = require(game.ReplicatedStorage.Resources)
local Magazine = Resources:LoadLibrary("Magazine")
local MagList = {
	--[[
        Example: 
        ["M16Box"] = {"M16Box","M16 Box Magazine","5.56x45mm",20;4;0;false;false;false;false;true;true;false;};	
	]]--
	["AutoBlasterMag"] = {"AutoBlasterMag","Auto Blaster Mag","Laser",30;4;0;false;false;false;false;true;true;false;};	

};
return setmetatable({
	rawList = MagList;
},{
	__index = function(self,k)
		local magArray = MagList[k]
		if magArray then
			return Magazine.new(unpack(magArray))
		end
		return nil;
	end;
})
