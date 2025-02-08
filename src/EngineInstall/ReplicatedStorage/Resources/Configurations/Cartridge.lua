local Resources = require(game.ReplicatedStorage.Resources)
local Cartridge = Resources:LoadLibrary("Cartridge")
local Gauges = Resources:LoadConfiguration("Gauges")

local Cartridges = {
	Shells = {
        -- Used for tank shells and naval shells
		-- Example: ["308mm"] = true;
	
	};
	Args = {
        -- Format: {Name,Title,Range,Hitscan,Velocity,TracerColor,0,Vector3.new(0.1,0.1,5),196.2 * 0.15,0.15,NumberRange.new(32,50),0.25,0.55};
		--Example: ["7.62x39mm"] = {"7.62x39mm","7.62x39mm (M43)",689,false,1408,BrickColor.new("Really red"),0,Vector3.new(0.1,0.1,5),196.2 * 0.15,0.15,NumberRange.new(32,50),0.25,0.55};

	};
};
return setmetatable(
	Cartridges,
	{
	__index = function(self,k)
		local cartridge = self.Args[k] 
		if cartridge then 
				return Cartridge.new(unpack(cartridge));
		elseif k:lower() == "cartridgeidata" then
				local l = {}
				for k2, idc in self.Args do
					local c2 = Cartridge.new(unpack(idc))
					table.insert(l, c2:GetInventoryInfo())
					if Gauges[k2] then
						for i, gt in Gauges[k2].GaugeTypes do
							c2:SetupGauge(i)
							table.insert(l, c2)
						end
					end
				end
				return l
		end;
	end;
	}
)

