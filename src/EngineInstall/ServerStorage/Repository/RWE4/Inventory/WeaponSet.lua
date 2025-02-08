local WeaponSet = {}
local Resources = require(game.ReplicatedStorage.Resources)
local RemoteService = Resources:LoadLibrary("RemoteService")
local PistolTypes = {
	"Pistol";
	"SpecialPistol";
	"MachinePistol";
	"Revolver";
	"RCP";
};
local Gadgets = {
	"Binoculars";
	"Medicine";
	"Build";
	"Radio";
	"Crate";
	"Fuel";
	"Repair";
}
local Bombs = {
	"";
}
local Blades = {
	"Melee";	
}
local RifleTypes = {
	"Assault";
	"LMG";
	"Carbine";
	"Shotgun";
	"TacticalShotgun";
	"Battle";
	"Sniper";
	"DMR";
	"PDW";
	"SMG";
	"GPMG";
	"IAR";
	"HMG";
	"HSMG";
	"SAW";
	"PCC";
	"SniperCarbine";
	"AMR";
	"Paramilitary";
}

local inList = Resources:LoadLibrary("inList")
WeaponSet.__index = WeaponSet
function WeaponSet.new(Primary,Secondary,Grenade,Bomb,Launcher,Melee,Role)
	local self = {}
	self.Primary = Primary
	if typeof(self.Primary) ~= "table" then return nil end
	self.Secondary = Secondary
	if typeof(self.Secondary) ~= "table" then return nil end
	self.Grenade = Grenade
	if typeof(self.Grenade) ~= "table" then return nil end
	self.Bomb = Bomb
	if typeof(self.Bomb) ~= "table" then return nil end	
	self.Launcher = Launcher
	if typeof(self.Launcher) ~= "table" then return nil end
	self.Melee = Melee
	if typeof(self.Melee) ~= "table" then return nil end	
	self.Role = Role
	if typeof(self.Role) ~= "table" then return nil end
	self.Filter = ""
	return setmetatable(self,WeaponSet)
end
function WeaponSet.GetRoleList()
	return Gadgets
end
function WeaponSet.IsRifle(bType)
	local isRifle = false
	for _, rifleType in ipairs(RifleTypes) do
		if bType == rifleType then
			isRifle = true
			break
		end
	end
	return isRifle
end
function WeaponSet.IsPistol(bType)
	local isPistol = false
	for _, pistolType in ipairs(PistolTypes) do
		if bType == pistolType then
			isPistol = true
			break
		end
	end
	return isPistol
end
function WeaponSet.All(plr,ul)
	local Primary,Secondary,Grenade,Bomb,Launcher,Melee,Role = {},{},{},{},{},{},{}
	for _, itemN in ipairs(ul) do
		local item = Resources:GetItem(itemN)
			if item:FindFirstChild("Type") then
				local itemType = item.Type.Value
				if itemType == "Gun" then
					local blaster = item 
					local blasterType = blaster:FindFirstChild("GunType")
					if blasterType then
						local bType = blasterType.Value
						if WeaponSet.IsRifle(bType) then
							Primary[#Primary+1] = blaster
						elseif WeaponSet.IsPistol(bType) then
							Secondary[#Secondary+1] = blaster
						end
					end
				elseif inList(itemType,Blades) then
					Melee[#Melee+1] = item
				elseif itemType == "Launcher" then
					Launcher[#Launcher+1] = item
				elseif itemType == "Grenade" then
					Grenade[#Grenade+1] = item
				elseif itemType == "Bomb" then
					Bomb[#Bomb+1] = item
				elseif inList(itemType,Gadgets) then
					Role[#Role+1] = item
				end
			end
		end
	return WeaponSet.new(Primary,Secondary,Grenade,Bomb,Launcher,Melee,Role)
end
function WeaponSet.GetLoadoutSlot(item)
				local itemType = item.Type.Value
				if itemType == "Gun" then
					local blaster = item 
					local blasterType = blaster:FindFirstChild("GunType")
					if blasterType then
						local bType = blasterType.Value
						if WeaponSet.IsRifle(bType) then
							return "Primary"
						elseif WeaponSet.IsPistol(bType) then
							return "Secondary"
						end
					end
				elseif inList(itemType,Blades) then
					return "Melee"
				elseif itemType == "Launcher" then
					return "Launcher"
				elseif itemType == "Grenade" then
					return "Grenade"
				elseif itemType == "Bomb" then
					return "Bomb"
				elseif inList(itemType,Gadgets) then
					return "Role"
				end
end
function WeaponSet:SetFilter(class)
	self.Filter = class
end

function WeaponSet:IsInClass(bType, class)
	local result = false
	for _, weaponType in ipairs(self.ClassFilters[class]) do
		if weaponType == bType then
			result = true
		end
	end
	return result
end
function WeaponSet:FindWeapon(weapon, Category)
	local result = 0
	for i, weapon2 in ipairs(Category) do
		if weapon2 == weapon then
			result = i
		end
	end
	return result
end
function WeaponSet:toTable()
	local t = {}
	t.Primary = self.Primary
	t.Secondary = self.Secondary
	t.Grenade = self.Grenade
	t.Bomb = self.Bomb
	t.Launcher = self.Launcher
	t.Melee = self.Melee
	t.Role = self.Role
	return t
end

return WeaponSet