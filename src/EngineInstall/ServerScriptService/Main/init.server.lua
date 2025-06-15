local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local PhysicsService = game:GetService("PhysicsService")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local Resources = require(ReplicatedStorage:WaitForChild("Resources",10))
-- Setup your flags here
Resources:SetupFlags({

})
-- Necessary Modules
local RemoteService = Resources:LoadLibrary("RemoteService")
local EventSystem = Resources:LoadLibrary("EventUtils")
local createViewModel = Resources:LoadLibrary("createViewModel")
local FactionService = Resources:LoadLibrary("FactionService")
local PhotoSiris = Resources:LoadLibrary("PhotoSiris")
local FastDelay = Resources:LoadLibrary("FastDelay")
local Ragdoll = Resources:LoadLibrary("Ragdoll")
local fastSpawn = Resources:LoadLibrary("FastSpawn")
local Janitor = Resources:LoadLibrary("Janitor")
local PseudoInstance = Resources:LoadLibrary("PseudoInstance")
local Lerps = Resources:LoadLibrary("Lerps")
local Tween = Resources:LoadLibrary("Tween")
local Signal = Resources:LoadLibrary("Signal")
local MathRound = Resources:LoadLibrary("MathRound")
local WeaponUtils = Resources:LoadLibrary("WeaponUtils")
local InventoryService = Resources:LoadLibrary("InventoryService")
local Enumeration = Resources:LoadLibrary("Enumeration")

--- Configs
local AttachmentsList = Resources:LoadConfiguration("Attachment")
local AOptions = Resources:LoadConfiguration("AttachmentGroups")
local Cartridges =  Resources:LoadConfiguration("Cartridge")
local AttachmentModules = Resources:LoadConfiguration("AttachmentModules")
local MagazinesList = Resources:LoadConfiguration("Magazine")
-- Event System + Server Plugins 
local ServerSettings = require(script.Parent.ServerSettings)
for _, event in ServerSettings.Events do
    EventSystem:AddEvent(event)
end
local ServerPlugins = {} do
	for i, pl: ModuleScript in script.Plugins:GetDescendants() do
		if pl:IsA("ModuleScript") then
			print("Loading Server Plugin", pl.Name, "...")
			ServerPlugins[i] = require(pl)
		end
	end
	local count = #ServerPlugins
	for i, pl: ModuleScript in script.Parent.Plugins:GetDescendants() do
		if pl:IsA("ModuleScript") then
			print("Loading Server Plugin", pl.Name, "...")
			ServerPlugins[count + i] = require(pl)
		end
	end
end
-- Arm C0 Values
local armC0 = {
	CFrame.new(-1.5, 0, 0) * CFrame.Angles(math.rad(90), 0, 0);
	CFrame.new(1.5, 0, 0) * CFrame.Angles(math.rad(90), 0, 0);
}
-- Other values
local Grips = {};
local gunIgnores = {};
local animWelds = {};
local ragdolls = {};
local jans = {};
local MagazineLibraries = {};
local AttachmentLibraries = {};
local furnitures = {};

------
function runInit(plr: Player)
	AttachmentLibraries[plr] = {}
	MagazineLibraries[plr] = {}
	furnitures[plr] = {};
	local function aggregateWeapon(item, useMags)
		if  WeaponUtils:HasItemCapability(item, "Aggregate") then
			AttachmentLibraries[plr][item.Name] = {};
			for _, v in ipairs(AttachmentModules.Slots) do
				AttachmentLibraries[plr][item.Name][v] = {
					Name = "";
					CFrame = CFrame.new();
					Options = {};
				};

			end
			local UsableMags = require(item.SETTINGS)
			if UsableMags then
				if UsableMags.defaultAttachments then
					for k, v in ipairs(UsableMags.defaultAttachments) do
						local att = AttachmentsList[v]
						if att then
							AttachmentLibraries[plr][item.Name][att.Slot].Name = v;
						end		
					end
				end
				for _, pl in ServerPlugins do
					if pl.OnAggregateWeapon then
						pl.OnAggregateWeapon({
							setOptions = function(attr)
								if AOptions[attr.Name] then
									if #AttachmentLibraries[plr][item.Name][attr.Slot].Options <= 0 then
										AttachmentLibraries[plr][item.Name][attr.Slot].Options = AOptions[attr.Name].DefaultOptions
									end
								end
							end,
							setCFrame = function(attr)
								AttachmentLibraries[plr][item.Name][attr.Slot].CFrame = CFrame.new(attr.CF.X, attr.CF.Y, attr.CF.Z)
							end,
							setName = function(attr)
								AttachmentLibraries[plr][item.Name][attr.Slot].Name = attr.Name;
							end,
							Item = item;
							Player = plr;
						},Resources:GetLocalTable("Components"))
					end
				end
				if useMags then
					UsableMags = UsableMags.reloadSettings
					if UsableMags then
						UsableMags = UsableMags.usableMags
						if UsableMags then
							MagazineLibraries[plr][item.Name] = UsableMags[1]
						end
					end
				end
			end
			if item.Type.Value == "Gun" or item.Type.Value == "Launcher"  then
				furnitures[plr][item.Name] = {
					furniture = "";
					alloy = "";
				}	
			end	
		elseif item.Type.Value == "Grenade" then
			if item.GrenadeType.Value == "Smoke" then
				local S = require(item.SETTINGS)
				if S.smokeValues then
					item:SetAttribute("SmokeColor", S.smokeValues[1].Name)
				end
			end
		end
	end
	if RunService:IsStudio() then
		for _, itemObj in ipairs(ReplicatedStorage.Resources.Items:GetChildren()) do
			if not itemObj:FindFirstChild("Type") then
				continue
			end
			aggregateWeapon(itemObj, itemObj:FindFirstChild("MagPoint") or itemObj:FindFirstChild("MagPointNode"))
			--table.insert(saveGames[plr]:GetSettings().Inventory,itemObj.Name)		
		end
	else
		for itemName, _ in pairs(Starters) do
			local item = Resources:PtrItem(itemName)
			if item then
				aggregateWeapon(item, item:FindFirstChild("MagPoint") or item:FindFirstChild("MagPointNode"))
				--table.insert(saveGames[plr]:GetSettings().Inventory,item.Name)		
			end
		end
		for  _, itemName in ipairs(saveGames[plr].Unlocks) do
			local item = Resources:PtrItem(itemName)
			if item then
				aggregateWeapon(item, item:FindFirstChild("MagPoint") or item:FindFirstChild("MagPointNode"))
				--table.insert(saveGames[plr]:GetSettings().Inventory,item.Name)		
			end
		end
	end 
	plr.CharacterAdded:Connect(function(c)
		local head = c:WaitForChild("Head",200)
		local torso  = c:WaitForChild("Torso",200)
		jans[plr] = Janitor.new()

		local ViewM do
			local RArm = c:FindFirstChild("Right Arm")
			local LArm = c:FindFirstChild("Left Arm")
			local ViewM2, gripTab = createViewModel(plr, c, torso, armC0, gMH)
			head:SetNetworkOwner(plr)
			torso:SetNetworkOwner(plr)
			ViewM = ViewM2
			LArm.Size = Vector3.new(0.8,2,0.8)
			RArm.Size = Vector3.new(0.8,2,0.8)
			Grips[plr] = {
				Right = gripTab[1];
				Left = gripTab[2];
			}
			gunIgnores[plr] = ViewM.gunIgnore;
			animWelds[plr.Name] = ViewM.animWeld;	
			task.delay(0.5, function()
				RemoteService.send("Client",plr,"SetPartsClient", ViewM)
				RemoteService.send("Client",plr,"SetGripsClient",gripTab)
			end)
		end

		c:WaitForChild("Humanoid", 200)
		ragdolls[plr] = PseudoInstance.new("Ragdoll",c)
		fastSpawn(function() ragdolls[plr]:Setup() end)
		jans[plr]:Add(EventSystem:ConnectEvent("ItemEquipped", function(char,item)
			if char == c then
				WeaponUtils:RunHook(item, "OnServerEquip", {
					Item = item;	
				}, {
					furnitures = furnitures[plr];
					AttachmentLibrary = AttachmentLibraries[plr];
					Player = plr;
					Character = c;
					Grips = Grips[plr];
					RemoteService = RemoteService;
					--[[setBayonet = function(item, val)
						bayonets[item] = val;
					end,]]--
					MagazinesList = MagazinesList;
					MagazineLibrary = MagazineLibraries[plr];
					InventoryService = InventoryService;
					Janitor = jans[plr];
					fillGrenadeCrate = function(plr2)
						--fillGrenadeCrate(plr2, PlayerLoadouts)
					end;
					setMagazine = function(plr2, item2, mag)
						MagazineLibraries[plr2][item2.Name] = mag
					end,
					Cartridges = Cartridges;
					
				})
			end			
		end), "Disconnect")
		jans[plr]:Add(c.ChildAdded:connect(function(item)
			if c.Parent.Name == "SheathedWeapons" then
				return
			end
			if item:IsA("Model") then
				if item:FindFirstChild("Type") then
					EventSystem:FireEvent("ItemEquipped", c, item)
				end
			end
		end),"Disconnect")
		jans[plr]:Add(c.Humanoid.Died:Connect(function()
			c:SetAttribute("FaceState","Dead")
			for i, grip in pairs(Grips[plr]) do
				if grip then
					grip:Destroy()
				end
			end
			--healthAgents[plr] = nil;
			Grips[plr] = {
				Left = nil;
				Right = nil;
			};
			RemoteService.send("Client",plr,"SetCar",nil,nil)
			fastSpawn(function()
				--[[XPMs[plr]:Collect()
				XPMs[plr]:CalculateHealth()
				pcall(function()
					XPMs[plr]:Distribute(function()

					end)
				end)]]--
				if Resources:FindGlobalFeature("RagdollOnDeath") then
					ragdolls[plr]:Ragdoll()
				end
			end)
			--[[fastSpawn(function()
				RemoteService.fetch("Client",plr,"DisplayFeats",notifList[plr])
				notifList[plr].achievement = nil;
				notifList[plr].level = nil;
				notifList[plr].unlock = nil;
				RemoteService.send("Client",plr,"ResetToMenu")

			end)
			]]--

			fastSpawn(function()
				task.wait(3)

				RemoteService.bounceOthers("Client",plr,"FadeCharacter",c,3)
				task.wait(3)
			end)
			jans[plr]:Cleanup()
			jans[plr]:Destroy()
			jans[plr] = nil
			--[[if script:GetAttribute("GameMode"):find("Tutorial") then
				FastDelay(3, function()
					FastWait(6)
					deployPlayer(plr)		
				end)
			end]]--
		end),"Disconnect")
		for k, v in ServerSettings.CharacterStats do
			c:SetAttribute(k, v)
		end
	end)
	for _, pl in ServerPlugins do
		if pl.PlayerAdded then
			pl.PlayerAdded({
				RemoteService = RemoteService;
				Player = plr;
				
			})
		end
	end
	task.delay(10, function()
		if true then
			plr:LoadCharacter()
		end
	end)
end
EventSystem:ConnectEvent("PlayerAdded", runInit)
-----
RemoteService.listen("Server","Send","SetJointC0",function(player,Joint,JC0,set)
	pcall(function() if Joint then 	if  Joint.Part0 then  if (Joint.Part0:GetNetworkOwner() == player or table.find(jointIgnore,Joint.Name)) then	   Joint.C0 = JC0  end end end end)
end)
RemoteService.listen("Server","Send","SetJointC1",function(player,Joint,JC1,set)
	pcall(function() if Joint then if Joint.Part1 then if (Joint.Part1:GetNetworkOwner() == player or table.find(jointIgnore,Joint.Name)) then Joint.C1 = JC1   end end end end)
end)
RemoteService.listen("Server","Send","SetAJointC0",function(player,Joint,JC0)
	pcall(function()
		if Joint then
			if Joint.Part0 then
				if Joint.Part0:GetNetworkOwner() == player and Joint.Name == "animWeld" then 
					Joint.C0 = JC0
				end
			end
		end
	end)
end)
RemoteService.listenU("Server","Send","SignalTween",function(player,Joint,newC0,newC1,aName,Duration)
	if Joint then
		RemoteService.bounceOthersU("Client",player,"TweenJoint",Joint,newC0,newC1,aName,Duration)
		FastDelay(Duration,function()
			if newC0 then
				Joint.C0 = newC0
			end
			if newC1 then
				Joint.C1 = newC1
			end
		end)	
	end

end)
RemoteService.listen("Server","Send","SetAJointC1",function(player,Joint,JC1)
	pcall(function()
		if Joint then
			if Joint.Part1 then
				if Joint.Part1:GetNetworkOwner() == player and Joint.Name == "animWeld" then 
					Joint.C1 = JC1
				end
			end
		end
	end)
end)
-----
_G.SetupItemAPI = function()
	WeaponUtils.ServerAPI = {
		fillGrenadeCrate = fillGrenadeCrate;
		RemoteService = RemoteService;
		PlayerLoadouts = PlayerLoadouts;
		Gauges = Gauges;
		ReplicatedStorage = ReplicatedStorage;
		FastWait = FastWait;
		PseudoInstance = PseudoInstance;
		AssemblerList  = AssemblerList;
		getWeaponType = function(item)
			return WeaponUtils:GetSubType(item)
		end,
		MagazinesList = MagazinesList;
		MagazineAPI = Magazine;
		MagazineLibraries = MagazineLibraries;
		Cartridges = Cartridges;
		changeGrenadeColor = function(nade, color)
			WeaponUtils:ChangeGrenadeColor(nade, color)
		end,
	}
end
RemoteService.listen("Server","Send","ResetViewModel",function(player,Vars)
	if Vars.gunIgnore then
		Vars.gunIgnore:Destroy()
		gunIgnores[player] = nil;
		animWelds[player.Name] = nil;
	end
	if Vars.Shoulders then
		if Vars.LArm and Vars.RArm then
			if Vars.Shoulders.Right and Vars.Shoulders.Left then
				Vars.Shoulders.Right.Part1 = Vars.RArm
				Vars.Shoulders.Left.Part1 = Vars.LArm
				Vars.RArm.Transparency = 0
				Vars.LArm.Transparency = 0
			end
		end
	end
end)
RemoteService.listenU("Server","Send","PlayItemSoundServer",function(player,item,id,volume,pitch)
	RemoteService.bounceU("Client","PlayItemSound",item,id,volume,pitch)
	--[[for _, m in ipairs(_G.Mobs) do
		if m then
			m:Hear(player,cf.p)
		end
	end]]--
end)
-----
Players.PlayerAdded:Connect(function(plr)
	EventSystem:FireEvent("PlayerAdded", plr)
end)
WeaponUtils:StartTypeProcessor()
FactionService:startServer()
for _, pair in ServerSettings.CollisionPairs do
	if pair[1] == "Default" or pair[2] == "Default" then
		if PhysicsService:IsCollisionGroupRegistered(pair[1]) and PhysicsService:IsCollisionGroupRegistered(pair[2]) then
			PhysicsService:CollisionGroupSetCollidable(pair[1], pair[2], pair[3])
		else
			if pair[1] == "Default" then
				PhysicsService:RegisterCollisionGroup(pair[2])
			else
				PhysicsService:RegisterCollisionGroup(pair[1])
			end
			PhysicsService:CollisionGroupSetCollidable(pair[1], pair[2], pair[3])
		end
	else
		if PhysicsService:IsCollisionGroupRegistered(pair[1]) and PhysicsService:IsCollisionGroupRegistered(pair[2]) then
			PhysicsService:CollisionGroupSetCollidable(pair[1], pair[2], pair[3])
		else
			PhysicsService:RegisterCollisionGroup(pair[1])
			PhysicsService:RegisterCollisionGroup(pair[2])
			PhysicsService:CollisionGroupSetCollidable(pair[1], pair[2], pair[3])
		end
	end
end
task.spawn(function()
	for _, pl in ServerPlugins do
		if pl.Init then
			pl.Init({
				RemoteService = RemoteService;
				Lerps = Lerps;
				Tween = Tween;
				FactionService = FactionService;
				Events = EventSystem;
				fastSpawn = fastSpawn;
				FastDelay = FastDelay;
				Janitor = Janitor;
				Signal = Signal;
				Math = {
					Round = MathRound;
				};
				Enumeration = Enumeration;
			}, Resources:GetLocalTable("Components"))
		end
	end
end)
-----
if Resources:FindGlobalFeature("DayNightCycle") then
	PhotoSiris:SetupClock(Lighting.ClockTime)
	PhotoSiris:StartCycle()
end