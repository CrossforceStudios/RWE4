local Resources = require(game.ReplicatedStorage.Resources)
local Furniture = Resources:LoadLibrary("Furniture")
local Furnitures = {
    --[[
        Format:
        ["Name"] = {"Name","Title",{"Weapons To Include";};{
            ["PartName"] = {
                Color = Color3.fromRGB(r,g,b);
                Material = Desired Material;
            };	
        };"Furniture Type (Alloy or Furniture)"};

    ]]--
	
}

return setmetatable({},{
	__index = function(self,k)
		if k == "list" then
			return Furnitures
		elseif Furnitures[k] then
			return Furniture.new(unpack(Furnitures[k]))		
		end
		return nil;
	end;
});