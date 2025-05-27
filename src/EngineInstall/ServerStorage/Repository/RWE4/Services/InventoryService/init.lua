local InventoryService = {}
InventoryService.AvailableCamos = {}
InventoryService.AvailableLoadoutPackages = {}
local AttachmentCache = require(script.AttachmentCache)
local RS = game:GetService("RunService")
local Resources = require(game.ReplicatedStorage.Resources)
local RemoteService = Resources:LoadLibrary("RemoteService")
local Translate = Resources:LoadLibrary("TranslateHelper")
InventoryService.Attachment = Resources:LoadLibrary("Attachment")
InventoryService.WeaponSet = Resources:LoadLibrary("WeaponSet")
InventoryService.LoadoutClass = Resources:LoadLibrary("LoadoutClass")


InventoryService.AdapterList = {}
for _, item in ipairs(script.AttachmentAdapters:GetChildren()) do
	if item:IsA("ModuleScript") then
		InventoryService.AdapterList[item.Name] = require(item);
	end
end
function InventoryService:CreateLoadoutUI(scope,...)
	local args = {...}
	local result
	if scope == "ClassSetup:Item" then
				local index = args[1]
				local item = args[2]
				local tlator = args[4]
				result = Resources:GetUITemplate("WeaponItem"):Clone()
				result.LayoutOrder = index
				result.Name = item.Name
				result.WeaponName.Text = item.Name
				if item.Type.Value == "Gun" then
					result.WeaponType.Text = tlator and Translate.translateGameString("GunCat",item.GunType.Value) or item.GunType.Value
				elseif item.Type.Value == "Grenade" then
					result.WeaponType.Text = tlator and Translate.translateGameString("GrenadeCat",item.GrenadeType.Value) or item.GrenadeType.Value
				elseif item.Type.Value == "Launcher" then
					result.WeaponType.Text = tlator and Translate.translateGameString("LauncherCat",item.LauncherType.Value) or item.LauncherType.Value
				elseif item.Type.Value == "Blade" then
					result.WeaponType.Text = "Bladed Weapon"
				else
					result.WeaponType.Text = item.Type.Value 
				end
				local slotItem = args[3]
				if slotItem then
					if item == slotItem then
						result.ImageColor3 = Color3.fromRGB(0,163,255)
						result.UseButton.ImageColor3 = Color3.fromRGB(19,19,25)
						for _, info in pairs(result:GetChildren()) do
							if info:IsA("TextLabel") then
								info.TextColor3 = Color3.fromRGB(255,255,255)
								info.Underline.BackgroundColor3 = Color3.fromRGB(255,255,255)
							end
						end
					end
				end
	elseif scope == "WeaponStats:Staple" then
				local title = args[2]
				local name = args[1]
				local value = args[3]
				local item = args[4]
				result = Resources:GetUITemplate("Readable"):Clone()
				result.Name = name
				result.StatName.Text = title
				result.StatValue.Text = value(item, require(item.SETTINGS), _G.StatsAPI)
	elseif scope == "Appearance:Tier" then
				local tierData = args[2]
				local name = args[1]
				result = Resources:GetUITemplate("TierCompositeButton"):Clone()
				result.Name = name
				result.TierName.Text = tierData.Name
	end 
	return result
end
function InventoryService:CreateAttachmentCache(...)
	return AttachmentCache.new(...)
end
function InventoryService:UpdateLoadoutMenuFromServer(player,loadout,slot,att,mag,furn,condition)
		if loadout[slot] then
			if condition(loadout[slot]) or condition == nil then
				local initLoadout = loadout:GetSlotDict()
				RemoteService.send("Client",player,"UpdateMenuLoadout","Primary",loadout[slot],att,mag,furn,initLoadout)
			end
		end
end

return InventoryService