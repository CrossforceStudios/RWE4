local WU = {};
local HttpService = game:GetService("HttpService")
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Resources = require(game.ReplicatedStorage.Resources)
local GearManifest = Resources:LoadConfiguration("GearManifest")
local RemoteService = Resources:LoadLibrary("RemoteService")
local MagazinesList = Resources:LoadConfiguration("Magazine")
local ItemTypes = Resources:LoadConfiguration("ItemTypes")
local EventUtils = Resources:LoadLibrary("EventUtils")

function WU:HasItemCapability(item, capabilityName)
	local itemType = item.Type.Value
	local it = ItemTypes.Types[itemType]
	if it then
		if not it.Capabilities then
			return false
		end
		return table.find(it.Capabilities, capabilityName)
	end
end

function WU:HasHook(item, hookName, api, mApi)
	local itemType = item.Type.Value
	local it = ItemTypes.Types[itemType]
	if it then
		if not it.Hooks then
			return false
		end
		if not it.Hooks[hookName] then
			return false
		end
		return it.Hooks[hookName] ~= nil
	end
	return false
end

function WU:RunHook(item, hookName, api, mApi)
	local itemType = item.Type.Value
	local it = ItemTypes.Types[itemType]
	if it then
		if not it.Hooks then
			return
		end
		if not it.Hooks[hookName] then
			return
		end
		return it.Hooks[hookName] (api, mApi)
	end
end

function WU:IterateStats(item, cb)
	local itemType = item.Type.Value
	local it = ItemTypes.Types[itemType]
	if it then
		if not it.Statistics then
			return
		end
		for k, stat in it.Statistics do
			if cb then
				cb(k, stat)
			end
		end
	end
end

function WU:GetSubType(item)
	local itemType = item.Type.Value
	local it = ItemTypes.Types[itemType]
	if it then
		if not it.SubTypeName then
			return nil
		end
		local val = item:FindFirstChild(it.SubTypeName .. "Type")
		if val then
			return val.Value
		end
		return nil
	end
end

function WU:GetClipName(item)
	local itemType = item.Type.Value
	local it = ItemTypes.Types[itemType]
	if it then
		if  it.SubTypeName and it.SubTypeData then
			local val = item:FindFirstChild(it.SubTypeName .. "Type")
			if val then
				return it.SubTypeData[val.Value].ClipName
			end
			return "Ammo"
		end
		return it.ClipName or "Ammo"
	end
	return "Ammo"

end

function WU:GetBasePose(item)
	if not item then
		return "regular";
	end
	local itemType = item.Type.Value
	local it = ItemTypes.Types[itemType]
	if it then
		if not it.Animation then
			return nil
		end
		return it.Animation.poseName
	end
end

function WU:GetAnimCF(item, animTab, ...)
	if not item then
		return CFrame.new();
	end
	local itemType = item.Type.Value
	local it = ItemTypes.Types[itemType]
	if it then
		if not it.Animation then
			return CFrame.new()
		end
		if not it.Animation.animCF then
			return CFrame.new()
		end
		return it.Animation.animCF(animTab, ...)
	end
end

function WU:CanUseEquipPose(item)
	local itemType = item.Type.Value
	local it = ItemTypes.Types[itemType]
	if it then
		if not it.Animation then
			return false
		end
		return it.Animation.equipPose
	end
end



function WU:StartTypeProcessor()
	RemoteService.listen("Server", "Send", "PerformItemAction", function(player, action, item, ...)
		_G.SetupItemAPI()
		local itemType = item.Type.Value
		local it = ItemTypes.Types[itemType]
		if not it.Actions then
			return
		end
		if it.Actions[action] then
			it.Actions[action](player, item, self.ServerAPI, ...)
		end
	end)
	RemoteService.listen("Server", "Fetch", "PerformAsyncItemAction", function(player, action, item, ...)
		_G.SetupItemAPI()
		local itemType = item.Type.Value
		local it = ItemTypes.Types[itemType]
		if not it.AsyncActions then
			return
		end
		if it.AsyncActions[action] then
			return it.AsyncActions[action](player, item, self.ServerAPI, ...)
		end
	end)
end

function WU:PerformServerAction(player, item, action, ...)
	if RunService:IsClient() then
		RemoteService.send("Server", "PerformItemAction", action, item, ...)
	else
		local itemType = item.Type.Value
		local it = ItemTypes.Types[itemType]
		if not it.Actions then
			return
		end
		if it.Actions[action] then
			it.Actions[action](player, item, self.ServerAPI, ...)
		end
	end
end

function WU:PerformAsyncServerAction(player, item, action, ...)
	if RunService:IsClient() then
		return RemoteService.fetch("Server", "PerformAsyncItemAction", action, item, ...)
	else
		local itemType = item.Type.Value
		local it = ItemTypes.Types[itemType]
		if not it.AsyncActions then
			return
		end
		if it.AsyncActions[action] then
			return it.AsyncActions[action](player, item, self.ServerAPI, ...)
		end
	end
end

function WU:PerformInputAction(player, item, action, api, ...)
	if RunService:IsServer() then
		return
	end
	local itemType = item.Type.Value
	local it = ItemTypes.Types[itemType]
	if not it.Input then
		return
	end
	if not it.Input.Actions then
		return
	end
	if it.Input.Actions[action] then
		it.Input.Actions[action](player, item, api, ...)
	end
end

function WU:PerformActivation(player, item, api, ...)
	if RunService:IsServer() then
		return
	end
	local itemType = item.Type.Value
	local it = ItemTypes.Types[itemType]
	if not it.Input then
		return
	end
	if not it.Input.Activate then
		return
	end
	it.Input.Activate(player, item, api, ...)
end


function WU:GetInputScheme(item)
	if not RunService:IsClient() then
		return
	end
	local itemType = item.Type.Value
	local it = ItemTypes.Types[itemType]
	if not it.Input then
		return
	end
	if it.Input.Scheme then
		return it.Input.Scheme
	end
end

function WU:GetHUDContext(item, hud)
	if not RunService:IsClient() then
		return
	end
	if not item:FindFirstChild("Type") then
		return
	end
	local itemType = item.Type.Value
	local it = ItemTypes.Types[itemType]
	if not it.HUD then
		return
	end
	if it.HUD.InitContext then
		return it.HUD.InitContext(hud)
	end
end

function WU:FindReticle(weapon: Model,  tag: string) : {BasePart}
	local res = {}
	for _, wp in weapon:GetChildren() do
		if wp:IsA("BasePart") then
			if wp.Name == "MainSightReticle" then
				local mainSightTag = wp:GetAttribute("ReticleShape")
				if mainSightTag == tag then
					table.insert(res, wp)
				else
					wp.Transparency = 1
				end
			end

		end
	end
	return res
end

function WU:ChangeGrenadeColor(weapon: Model, color: BrickColor)
	weapon:SetAttribute("SmokeColor", color)
	for _, v in ipairs(weapon:GetChildren()) do
		if v.Name == "ColorBand" and v:IsA("BasePart") then
			v.BrickColor = BrickColor.new(weapon:GetAttribute("SmokeColor"))
		end	
	end
end

function WU:RefillAmmoFromCache(plr,cartName: string, cache: Model, PlayerLoadouts: {})
	if not cache then return true end
	if  typeof(plr) == "Instance" and plr:IsA("Player")  then
		if (plr:DistanceFromCharacter(cache:GetPivot().Position) > 15) then
			return true
		end
	else
		if ((plr:GetPrimaryPartCFrame().Position - cache:GetPivot().Position).Magnitude > 15) then
			return true
		end
	end

	if not cache:FindFirstChild("AmmoDispenser") then return true end
	local weapons = {}
	if plr:IsA("Player") then
		for _, v in ipairs({"Primary";"Secondary"}) do
			if PlayerLoadouts[plr][v] then
				local S = require(PlayerLoadouts[plr][v].SETTINGS)
				if S then
					local mag = MagazinesList[PlayerLoadouts[plr][v]:GetAttribute("MagType")]
					if mag then
						if mag.CartridgeName == cartName then
							table.insert(weapons, PlayerLoadouts[plr][v])	

						end
					end
				end
			end
		end
	else
		for _, v in ipairs({"Primary";"Secondary";}) do
			if plr.MEM[plr][v] then
				local S = require(plr.MEM[plr][v].SETTINGS)
				if S then
					local mag = MagazinesList[plr.MEM[plr][v]:GetAttribute("MagType")]
					if mag then
						if mag.CartridgeName == cartName then
							table.insert(weapons, plr.MEM[plr][v])	

						end
					end
				end
			end
		end
	end

	local usage = game.HttpService:JSONDecode(cache.AmmoDispenser:GetAttribute("Usage"))
	local function getUsage(ammoName)
		for _, tab in usage do
			if tab[1] == ammoName then
				return tab[2]
			end
		end
		return 0;
	end
	local function decrementUsage(ammoName, amount)
		for i, tab in usage do
			if tab[1] == ammoName then
				usage[i][2] -= amount;
				return usage[i][2]
			end
		end
		return 0;
	end
	if #weapons > 0 then
		for _, v in ipairs(weapons) do
			if v:GetAttribute("Mags") <= 2 and  getUsage(cartName) > 0 then
				if _G.Inventories[plr] then
					_G.Inventories[plr]:AddItem(v:GetAttribute("MagType"))
				end
				v:SetAttribute("Mags", if _G.Inventories[plr] then _G.Inventories[plr]:GetCount(v:GetAttribute("MagType")) else v:GetAttribute("Mags") + 1)
				v:SetAttribute("Ammo", v:GetAttribute("ClipSize"))
				decrementUsage(cartName, v:GetAttribute("ClipSize"))
				cache.AmmoDispenser:SetAttribute("Usage",game.HttpService:JSONEncode(usage))
			end
		end
	end
	return true
end

function WU:GetDefaultWeapons(player: Player, unit: string, slot: string)
	if not player.Team then
		return 
	end
	local gm = GearManifest.Items[player.Team.Name]
	if gm then
		gm = gm[unit]
		if gm then
			return gm[slot]
		end
	end
end

function WU:SetFirstWeapon(player: Player, PlayerLoadouts: {}, slot: string, firstCome: boolean, changeUnitWeapon: (weapon: Model?, slot2: string) -> (), uO: {}, AttachmentLibraries: {}, MagazineLibraries: {}, furnitures: {})
	if firstCome then
		_G.UpdateFirstCome(player, changeUnitWeapon, slot, uO)
	elseif player.Team then
		local gm = GearManifest.Items[player.Team.Name]
		if gm then
			gm = gm[player:GetAttribute("Unit")]
			if gm then
				gm = gm[slot] 
				if gm then
					if PlayerLoadouts[player][slot] then
						PlayerLoadouts[player][slot]:Destroy()
						PlayerLoadouts[player][slot] = nil;
					end
					local gm2 = {} do
						for i, item in gm do 
							if ((RunService:IsStudio()) or  _G.IsItemUnlocked(player,Resources:GetItem(item))) then
								table.insert(gm2, i, item)
							end
						end
					end
					
					local count = #gm2
					if count > 0 then
						local weaponName = gm2[math.random(1, count)]
						PlayerLoadouts[player][slot] = self:GetNewWeapon(player, weaponName) 
						changeUnitWeapon(PlayerLoadouts[player][slot], slot)
					else
						_G.UpdateFirstCome(player, changeUnitWeapon, slot, uO)
					end
				else
					_G.UpdateFirstCome(player, changeUnitWeapon, slot, uO)
				end
			else
				_G.UpdateFirstCome(player, changeUnitWeapon, slot, uO)
			end
		else
			_G.UpdateFirstCome(player, changeUnitWeapon, slot, uO)

		end
	end
end

function WU:HasEnoughAmmo(player, weapon)
	if player:IsA("Player") then
		if weapon:GetAttribute("AmmoInd") then
			local mt = weapon:GetAttribute("MagType")
			if mt then
				local magCount = weapon:GetAttribute("AmmoInd")
				return magCount > 0 
			end
		end
		return weapon:GetAttribute("Ammo") > 0
	elseif player:IsA("Model") then
		if weapon:GetAttribute("AmmoInd") then
			local mt = weapon:GetAttribute("MagType")
			if mt then
				local magCount = weapon:GetAttribute("AmmoInd")
				return magCount > 0 
			end
		end
		return weapon:GetAttribute("Ammo") > 0
	end
end

function WU:HasEnoughMags(player, weapon)
	if player:IsA("Player") then
		local mt = weapon:GetAttribute("MagType")
		if mt then
			local magCount = weapon:GetAttribute(if weapon:GetAttribute("CurrentGrenade") then "Grenades" else "Mags")
			return magCount > 0
		end
	elseif player:IsA("Model") then
		return weapon:GetAttribute(if weapon:GetAttribute("CurrentGrenade") then "Grenades" else "Mags") > 0
	end
end

function WU:TakeFromCrate(weapon: Model, cache: Model, saveGames, Starters, plr: Player)
	local w
	if ((not table.find(saveGames[plr].Unlocks,weapon.Name)) and (not Starters[weapon.Name])) and (not RunService:IsStudio()) then
		return
	end

	w = weapon:Clone()
	if w.Type.Value == "Gun" then
		local listBox = cache:FindFirstChild(w.GunType.Value.."Crate")
		if listBox then
			local list = listBox:GetAttribute("Usage")
			if list then
				list = game.HttpService:JSONDecode(list)
				local function getWeaponCount(name)
					for _, tab in list do
						if tab[1] == name then
							return tab[2]
						end
					end
					return 0;
				end
				local function decrementWeapons(name, amount)
					for i, tab in list do
						if tab[1] == name then
							list[i][2] -= amount;
							return list[i][2]
						end
					end
					return 0;
				end
				if getWeaponCount(w.Name) <= 0 then
					w:Destroy()
					return
				end
				decrementWeapons(w.Name, 1)
				listBox:SetAttribute("Usage",game.HttpService:JSONEncode(list))
			end
		end
	end
	if w then
		return w
	end
end

function WU:TrySetupCharge(weapon : Model, bc: number)
	if weapon.Type.Value == "Bomb" then
		if weapon.BombType.Value:find("MinePack") then
			local bt = HttpService:GenerateGUID(false)
			CollectionService:AddTag(weapon, bt)
			local btDat = Instance.new("StringValue")
			btDat.Value = bt;
			btDat.Name = "BombTag"
			btDat.Parent = weapon;
			weapon:SetAttribute("BombCount", bc)
			weapon:SetAttribute("Detonated",false)
		end		
	end
end

function WU:ChangeChargeType(weapon: Model, player: Player, bombType: string)
	if weapon:FindFirstChild("ChargeType") then
		local S = require(weapon.SETTINGS)
		if S.chargeCategories then
			if table.find(S.chargeCategories, bombType) then
				if not workspace:FindFirstChild(player.Name) then
					weapon.ChargeType.Value = bombType
				end
			end
		end
	end
end

function WU:UnequipItems(plr: Player)
	if plr.Character then
		for _, item in ipairs(plr.Character:GetChildren()) do
			if item:FindFirstChild("Type") then
				if item.Type:IsA("StringValue") then
					item.Parent = plr.Carry
				end
			end
		end
	end
end

function WU:EquipItem(plr: Player, item: Model, PlayerLoadouts: {})
	if item:FindFirstChild("Type") then
		if not plr.Character:FindFirstChild("Type") then
			item.Parent = plr.Character
			PlayerLoadouts[plr].CurrentWeapon = item
			EventUtils:FireEvent("CampaignItemEquipped",plr, item)
		end
	end
end

function WU:GetNewWeapon(player: Player, wName) : Model?
	local  w: Model = Resources:GetItem(wName)
	if w then
		w = w:Clone()
	end
	if w then
		w.Parent = player.Carry
		if w:FindFirstChild("HoldPart") then
			if w.HoldPart:FindFirstChild("MainSound") then
				w.HoldPart.MainSound.SoundGroup = game.SoundService.SettingSounds.Game_FX
			end
		end	
		if w:FindFirstChild("Main") then
			if w.Main:FindFirstChild("FireSound") then
				w.Main.FireSound.SoundGroup = game.SoundService.SettingSounds.Game_FX
			end		
		end
		self:TrySetupCharge(w, player.Carry:GetAttribute("BombCount"))
		if w.Type.Value == "Melee" then
			_G.mS:AddWeapon(w,player)
		elseif w.Type.Value == "Crate" then
			if w.CrateType.Value == "Ammo" then
				local S = require(w.SETTINGS)
				w.Caliber.Value = S.defaults.Cartridge
			end
		end
	end
	return w
end


return WU