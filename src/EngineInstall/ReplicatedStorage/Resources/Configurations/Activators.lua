local mineObjects = {};
local Resources = require(game.ReplicatedStorage.Resources)
local ED = Resources:LoadConfiguration("ExplosiveData")
local ldH = nil;
local VehiclePierce = {}
local triggers = {
	["Projectile"] = {
		activate =  function(api)
			local player = api.Player
			local bCFrame = api.BulletCFrame
			local PlayerLoadouts = api.PlayerLoadouts
			local w = api.Weapon
			local weapon
			local projectMode = api.ProjectMode
			if projectMode == "WeaponPlayer" then
				weapon = (player:IsA("Player")) and PlayerLoadouts[player].CurrentWeapon or w
			elseif projectMode == "WeaponAI" and player:IsA("Model") then
				weapon = w
			elseif projectMode == "Cannon" or projectMode == "WeaponHelo" or  projectMode == "MGTurret" or  projectMode == "Coax" then
				weapon = w
			end
			if not weapon then
				return false
			end
			local Main
			if projectMode ~= "WeaponHelo" and projectMode ~= "MGTurret"  and (not weapon:FindFirstAncestor("Cannons")) and (projectMode ~= "Coax") then
				Main = api.getFirePort(api.Mode)
				if not Main then
					return false
				end
				if not Main:IsDescendantOf(weapon) then
					return
				end
				if not Main:FindFirstChild("BarrelIndex") then
					return false
				end
				if Main.BarrelIndex.Value ~= api.Mode then
					return false
				end
			else
				Main = api.MainPart
			end
			local Dir

			local SE
			if projectMode ~= "WeaponHelo"  and projectMode ~= "MGTurret"  and (not weapon:FindFirstAncestor("Cannons")) then
				SE = weapon:FindFirstChild("SETTINGS") or weapon.Parent:FindFirstChild("SETTINGS")
				if not SE then
					return false
				end
				SE = require(SE)
			end
			local cartName

			local succ, cartridge, err 
			local mag
			local args = {
				Cartridge = api.CartridgeName;
				damageSettings = api.DamageSettings;
				ArmamentType = api.ArmamentType;
				Grenade = api.GrenadeType;
				Helo = api.Helicopter;
			};
			if projectMode == "Cannon" then
				cartridge = api.Cartridges[args.Cartridge] or api.CartridgeObj
				cartName = args.Cartridge
			elseif projectMode == "WeaponHelo" or projectMode == "MGTurret"  then
				cartridge = api.Cartridges[args.Cartridge] or api.CartridgeObj
				cartName = args.Cartridge
				if api.GaugeIndex then
					args.Gauge = api.GaugeIndex
					cartridge:SetupGauge(api.GaugeIndex)
				end
			elseif projectMode == "Coax" then
				cartridge = api.CartridgeObj
				cartName = api.Cartridge
				if api.GaugeIndex then
					args.Gauge = api.GaugeIndex
					cartridge:SetupGauge(api.GaugeIndex)
				end
			else
				mag = api.Magazines[weapon:GetAttribute("MagType")]
				succ, cartridge, err = pcall(function() return api.CartridgeObj or (args.Grenade and api.Cartridges[weapon:GetAttribute("CurrentGrenade")] or  ((weapon:GetAttribute("GaugeIndex") and nil or api.Cartridges[mag.CartridgeName]))) end)
				if not succ then
					print(err)
					return false
				end

				if weapon:GetAttribute("GaugeIndex") then
					cartridge = api.Cartridges[mag.CartridgeName]
					args.Gauge = cartridge.GaugeIndex
					cartridge:SetupGauge(weapon:GetAttribute("GaugeIndex"))
				end
				if SE then
					if SE.bulletSettings then
						if SE.bulletSettings.RangeModifier then
							cartridge.Range = cartridge.Range + SE.bulletSettings.RangeModifier
						end
						if SE.bulletSettings.VelocityModifier then
							cartridge.Velocity = cartridge.Velocity + SE.bulletSettings.VelocityModifier
						end
						if SE.bulletSettings.AccelerationModifier then
							cartridge.Acceleration = cartridge.Acceleration + SE.bulletSettings.AccelerationModifier
						end
						if SE.bulletSettings.SizeOverride then
							cartridge.Size = SE.bulletSettings.SizeOverride
						end
						if SE.bulletSettings.ColorOverride then
							cartridge.ColorOverride = SE.bulletSettings.ColorOverride
						end
						cartridge:SetupBarrel(SE.bulletSettings, weapon)
						args.BulletSettings = SE.bulletSettings
						args.Weapon = weapon
					end
				end
				if weapon:GetAttribute("GaugeIndex")  then
					local mt = weapon:GetAttribute("MagType")
					if weapon:FindFirstChild("Magazine") then
						mt = mag.CartridgeName
					end
					if cartridge.ShotAmount > 1 then
						Dir = api.getDirection(api.GaugeTypes[mt] or cartridge,player)
					end
				end
				if Dir then
					bCFrame = bCFrame * Dir
				end
				cartName = mag.CartridgeName 
				args.partial  = SE.reloadSettings.partialMag	
				if weapon:GetAttribute("CurrentGrenade") then
					local gn = weapon:FindFirstChild("Grenade")
					if gn then
						local gnh = gn:FindFirstChild("GrenadeHead")
						if gnh then
							gnh:Destroy()
						end
					end
				end
			end
			cartridge:CalibrateSize()
			local Character
			if  (not weapon:FindFirstAncestor("Ships")) then
				Character = player:IsA("Player") and player.Character or player
				if (not Character) then
					return false
				end
			end
			args.Velocity = cartridge.Velocity
			if projectMode ~= "WeaponHelo" and projectMode ~= "MGTurret" and projectMode ~= "SniperTurret"  and (not weapon:FindFirstAncestor("Cannons")) then
				args.magRotation = (cartridge.IsMag and SE.reloadSettings) and SE.reloadSettings.magRotation or nil;
			else
				SE = {}
				SE.damageSettings = args.damageSettings;
			end
			args.Gravity = cartridge.Acceleration
			args.Direction =  (bCFrame.lookVector.Unit)
			args.plr  = player
			if projectMode ~= "WeaponHelo" then
				if cartridge.IsMag then
					if weapon:FindFirstChild("Magazine")  and not SE.reloadSettings.partialMag then
						weapon.Magazine:Destroy()
					elseif weapon:FindFirstChild("Magazine")  and SE.reloadSettings.partialMag then
						if  weapon:FindFirstChild("MagIsRocket",true) then
							if  weapon:FindFirstChild("MagIsRocket",true):FindFirstAncestor("Magazine") then
								weapon.Magazine:Destroy()
							end			
						elseif weapon.Magazine:FindFirstChild("Rounds") then
							weapon.Magazine.Rounds:GetChildren()[1]:Destroy()
						end	
					end			
				end
			else
				if args.ArmamentType == "Rockets" or args.ArmamentType == "Missile" then
					args.RenderRocketParticles = true
				end
			end
			args.Main = Main

			local ID = api.RNG:NextInteger(-1e9,1e9)
			args.ID = ID
			args.Accel = api.V3(0,-(args.Gravity or cartridge.Acceleration),0)
			if Character then
				args.CharVelocity = Character:FindFirstChildOfClass("Humanoid").MoveDirection
			end
			local RayParams = RaycastParams.new()
			local map = workspace.CurrentMap.Value do
				args.Ignore = args.Ignore or {}

				args.Ignore[#args.Ignore+1] = map.ReverbAreas
				if Character then
					args.Ignore[#args.Ignore+1] = Character;
				end
				args.Ignore[#args.Ignore+1] = map:FindFirstChild("LandmarkZones")
				args.Ignore[#args.Ignore+1] = map:FindFirstChild("MapCenter")
				args.Ignore[#args.Ignore+1] = map:FindFirstChild("MapCamera")
				args.Ignore[#args.Ignore+1] = map:FindFirstChild("SandParts")
				args.Ignore[#args.Ignore+1] = map:FindFirstChild("MapWaters")
				local man = require(map.Manifest) do
					if man.MapIgnore then
						for _, ignoreObj in man.MapIgnore do
							args[#args.Ignore+1] = ignoreObj;
						end
					end
				end
				if args.Helo then
					args.Ignore[#args.Ignore+1] = args.Helo
				end
			end
			RayParams.IgnoreWater = false
			RayParams.FilterDescendantsInstances = args.Ignore
			RayParams.FilterType = Enum.RaycastFilterType.Exclude

			args.RayParams = RayParams		 
			if projectMode == "MGTurret"  then
				print(Main)
				api.RemoteService.bounce("Client","MuzzleFlashMGT", Main)
				local ObjectV = Instance.new("ObjectValue")
				ObjectV.Value = Main.Parent
				ObjectV.Parent = workspace.ShellIgnore
				task.delay(0.6, function()
					ObjectV:Destroy()
				end)
			end
			api.addOrigin(ID,bCFrame.p, args.Direction.Unit,cartridge.Range,api.ExplosiveData[cartridge.Name],args.Ignore,args.plr,SE.damageSettings,cartridge,api.ExplosiveData[cartridge.Name],weapon,args.Grenade,args.Hollow)
			api.setCannonFlag(ID, projectMode == "Cannon")
			api.setWeapon(ID, weapon)
			local missile
			if args.ArmamentType == "Missile" then
				if not args.Lock then
					return 
				end
				missile = cartridge:getBullet({})
				missile:SetPrimaryPartCFrame(bCFrame)
				missile.Parent = workspace.BulletStorage
				api.RemoteService.bounce("Client","MakeMissile",cartName,args,player,missile)
			else
				api.RemoteService.bounce("Client","MakeBullet",bCFrame,cartName,args,player)
			end
			if projectMode == "WeaponPlayer" then
				api.WeaponUtils:PerformServerAction(player, weapon, "AddBarrelHeat")
			end
			local CanPierceFunction  = api.penetrationFunction(cartridge,api.getOrigin(ID),api.isWallIgnored)
			if projectMode == "Cannon" and (not weapon:FindFirstAncestor("Cannons")) then
				CanPierceFunction = function(cast, raycastI, vel, bullet, origin)
					local h, p, n = raycastI.Instance, raycastI.Position, raycastI.Normal
					local m = raycastI.Material
					local dir = cast.UserData.Direction;
					local dist = cast.StateInfo.DistanceCovered;
					local ori = origin;
					local tankPart = (h:FindFirstAncestor("Wheels") or h:FindFirstAncestor("Doors") or h:FindFirstAncestor("Body") or h:FindFirstAncestor("Hull") or h:FindFirstAncestor("Cannon"))
					if tankPart then
						local armor = h.Parent:FindFirstChild("Armor")
						if armor then
							if cartridge.Penetration > (armor.Value / 100) then
								return true, cartridge.Penetration, (vel * 0.25), dist
							end
						end
					end
					return false, cartridge.Penetration, (vel), dist
				end;
			elseif projectMode == "Cannon" and (weapon:FindFirstAncestor("Cannons")) then
				CanPierceFunction = function(cast, raycastI, vel, bullet, origin)
					local h, p, n = raycastI.Instance, raycastI.Position, raycastI.Normal
					local m = raycastI.Material
					local dir = cast.UserData.Direction;
					local dist = cast.StateInfo.DistanceCovered;
					local ori = origin;
					return false, cartridge.Penetration, (vel * 0.25), dist
				end;
			end
			if args.ArmamentType ~= "Missile" then
				local dat = api.newBehavior()
				for k, v in pairs({ 
					RaycastParams = RayParams;
					MaxDistance = cartridge.Range;
					Acceleration = args.Accel;
					CanPierceFunction = CanPierceFunction;
					AutoIgnoreContainer = api.ExplosiveData[cartName];
					}) do
					dat[k] = v
				end
				api.castProjectile(ID, bCFrame.p,args.Direction,(args.Velocity) , dat)
			else
				local dat = api.newMissileBehavior()
				if args.Helo then
					RayParams:AddToFilter(args.Helo)
				end
				for k, v in pairs({ 
					RaycastParams = RayParams,
					Acceleration = Vector3.new(),
					MaxDistance = 10000,
					CanPierceFunction = nil,
					HighFidelityBehavior = api.MissileCast.HighFidelityBehavior.Default,
					HighFidelitySegmentSize = 0.5,
					CosmeticBulletTemplate = missile.PrimaryPart,
					CosmeticBulletProvider = nil,
					CosmeticBulletContainer = workspace.RocketIgnore,
					AutoIgnoreContainer = true;
					TargetFactor = 4;
					}) do
					dat[k] = v
				end
				api.castMissileProjectile(ID, bCFrame.p,args.Direction,(args.Velocity), args.Lock, dat)
			end

			if projectMode == "WeaponPlayer" then
				if api.WeaponUtils:HasItemCapability(weapon, "Dispose") then
					if api.WeaponUtils:GetSubType(weapon) == "Disposable" then
						weapon:SetAttribute("NoSheathe", true)
						if player:IsA("Model") then
							if _G.Mobs[player] then
								_G.Mobs[player].MEM:SwitchTo(_G.Mobs[player],"Primary")
							end
						end
					end
				end
			end
		end,
		activationType = "Projectile";
	};

}

local TriggerStates = {
	["Projectile"] = {
		Type  = "Projectile";
		OnProcessLength = function(cast, lastPoint, segmentVelocity, cosmeticBulletObject, ID, player)
			for _, mo in pairs(_G.Mobs) do
				if mo and getmetatable(mo) then
					mo:AddSense("Sight","Bullet",{
						lastPoint;
						player:IsA("Player") and player.Character or player;
					})
				end
			end
		end,
		OnProcessHit = function(cast, resultOfCast, segmentVelocity, cosmeticBulletObject, ID, player, originalDirection)
			local H,P,N,M,Bullet,Vel = resultOfCast.Instance, resultOfCast.Position, resultOfCast.Normal, resultOfCast.Material, cosmeticBulletObject, segmentVelocity
			for _, mo in pairs(_G.Mobs) do
				if mo and getmetatable(mo) then
					mo:AddSense("Sight","Bullet",{
						P;
						player:IsA("Player") and player.Character or player;
					})
				end
			end
		end,
	};
	["ProjectileImpulse"] = {
		Type = "Projectile";
		OnPreProcessHit = function(cast, resultOfCast, segmentVelocity, cosmeticBulletObject, ID, player, originalDirection)
			local H,P,N,M,Bullet,Vel = resultOfCast.Instance, resultOfCast.Position, resultOfCast.Normal, resultOfCast.Material, cosmeticBulletObject, segmentVelocity
			if H:HasTag("PhysicalObject") or H.Parent:HasTag("PhysicalObject") then
				H:ApplyImpulseAtPosition(originalDirection.Unit * (segmentVelocity/5), P)
			end
		end,
		OnProcessPierce = function(cast, resultOfCast, segmentVelocity, cosmeticBulletObject, ID, player, originalDirection)
			local H,P,N,M,Bullet,Vel = resultOfCast.Instance, resultOfCast.Position, resultOfCast.Normal, resultOfCast.Material, cosmeticBulletObject, segmentVelocity
			if H:HasTag("PhysicalObject") or H.Parent:HasTag("PhysicalObject") then
				H:ApplyImpulseAtPosition(originalDirection.Unit * (segmentVelocity/5), P)
			end
		end,
	};
	["GlassProjectile"] = {
		Type = "Projectile";
		OnProcessHit = function(cast, resultOfCast, segmentVelocity, cosmeticBulletObject, ID, player, originalDirection)
			local H,P,N,M,Bullet,Vel = resultOfCast.Instance, resultOfCast.Position, resultOfCast.Normal, resultOfCast.Material, cosmeticBulletObject, segmentVelocity
			if H:FindFirstChild("BreakingPoint") then
				game.CollectionService:AddTag(H,"GlassBreak")
				task.delay(0.3, function()
					H:Destroy()
				end)
			end
		end,
		OnProcessPierce = function(cast, resultOfCast, segmentVelocity, cosmeticBulletObject, ID, player, originalDirection, activatorComp)
			local H,P,N,M,Bullet,Vel = resultOfCast.Instance, resultOfCast.Position, resultOfCast.Normal, resultOfCast.Material, cosmeticBulletObject, segmentVelocity
			if H:FindFirstChild("BreakingPoint") then
				H:SetAttribute("ResVelocity", segmentVelocity)
				game.CollectionService:AddTag(H,"GlassBreak")
				task.delay(0.3, function()
					H:Destroy()
				end)
			end
		end,
	};
	["LightsProjectile"] = {
		Type = "Projectile";
		OnProcessHit = function(cast, resultOfCast, segmentVelocity, cosmeticBulletObject, ID, player, originalDirection)
			local H,P,N,M,Bullet,Vel = resultOfCast.Instance, resultOfCast.Position, resultOfCast.Normal, resultOfCast.Material, cosmeticBulletObject, segmentVelocity
			if H.Parent then
				if workspace.CurrentMap.Value:FindFirstChild("Lights") then
					if H:IsDescendantOf(workspace.CurrentMap.Value:FindFirstChild("Lights"))  then
						if H:FindFirstChildWhichIsA("Light") then
							H:AddTag("DeadLight")
						end
					end	
				end
			end
		end,
		OnProcessPierce = function(cast, resultOfCast, segmentVelocity, cosmeticBulletObject, ID, player, originalDirection, activatorComp)
			local H,P,N,M,Bullet,Vel = resultOfCast.Instance, resultOfCast.Position, resultOfCast.Normal, resultOfCast.Material, cosmeticBulletObject, segmentVelocity
			if H.Parent then
				if workspace.CurrentMap.Value:FindFirstChild("Lights") then
					if H:IsDescendantOf(workspace.CurrentMap.Value:FindFirstChild("Lights"))  then
						if H:FindFirstChildWhichIsA("Light") then
							H:AddTag("DeadLight")
						end
					end	
				end
			end
		end,
	};
	["Destruction"] = {
		Type = "Projectile";
		OnProcessPierce = function(cast, resultOfCast, segmentVelocity, cosmeticBulletObject, ID, player, originalDirection, activatorComp)
			local H,P,N,M,Bullet,Vel = resultOfCast.Instance, resultOfCast.Position, resultOfCast.Normal, resultOfCast.Material, cosmeticBulletObject, segmentVelocity
			activatorComp:destroyHit(ID, Vel, H)
		end,
	};
	["Damage"] = {
		Type = "Projectile";
		OnProcessPierce = function(cast, resultOfCast, segmentVelocity, cosmeticBulletObject, ID, player, originalDirection,  activatorComp, originStub, Props)
			local hitHumanoid
			local Damage = Resources:GetComponent("Damage")
			local H,P,N,M,Bullet,Vel = resultOfCast.Instance, resultOfCast.Position, resultOfCast.Normal, resultOfCast.Material, cosmeticBulletObject, segmentVelocity
			if not originStub.cannon then
				local helo = _G.heloSS.getHelo(H)
				if helo then
					_G.heloSS.damage(H, originStub.dist, originStub.c.Damage.Min/10, originStub.plr)
					return
				end
				if originStub.es then
					activatorComp:triggerExplosive(ID,originStub.g,H,P,N,originStub.d,originStub.ig,originStub.o,M,originStub.c.Name)
					ldH = nil
				else
					hitHumanoid = Damage("Gun", originStub.plr, ID,   originStub.m, H, P, N, originStub.d, originStub.dist, originStub.ig, originStub.c, originStub.g, originStub.h, originStub.o)
					if hitHumanoid and hitHumanoid ~= ldH then
						ldH = hitHumanoid
					else
						ldH = nil
					end
				end

			end			
			if originStub.es and originStub.cannon  then
				local hitAncestry = (H:FindFirstAncestor("Wheels") or H:FindFirstAncestor("Doors") or H:FindFirstAncestor("Body") or H:FindFirstAncestor("Hull") or H:FindFirstAncestor("Cannon"))
				if (H.Transparency <= 0.75 and (not originStub.E)) or (hitAncestry) then
					activatorComp:triggerExplosive(ID,originStub.g,H,P,N,originStub.d,originStub.ig,originStub.o,M,originStub.c.Name)
					if originStub.es then
						if originStub.es.Type == "HEAT" or originStub.es.Type == "TPA" then
							--_G.CampaignEvents.PointAttacked:Fire(H,P,N)
						end
					end
					if originStub.E then
						task.wait(0.15)
						originStub.E = nil;
					end
				end	
			elseif (not hitHumanoid) then
				if game.CollectionService:HasTag(H.Parent, "DestructProp") or game.CollectionService:HasTag(H, "DestructProp") then
					Damage("Prop", originStub.plr,  originStub.m, H, P, N, originStub.d, originStub.dist, originStub.ig, originStub.c, originStub.g, originStub.h, originStub.o)
				end
				Props.RemoteService.bounceU("Client","ShowImpactFromPoint", H, P, N, M, originStub.d, hitHumanoid or false, originStub.c.Name)


			end
		end,
		OnProcessHit = function(cast, resultOfCast, segmentVelocity, cosmeticBulletObject, ID, player, originalDirection, originStub, activatorComp, Props)
			local H,P,N,M,Bullet,Vel = resultOfCast.Instance, resultOfCast.Position, resultOfCast.Normal, resultOfCast.Material, cosmeticBulletObject, segmentVelocity
			local hitHumanoid
			local Damage = Resources:GetComponent("Damage")
			if originStub.es then
				if not originStub.cannon then
					local c =  originStub.c
					if ED[c.Name] then
						activatorComp:triggerExplosive(ID,originStub.g,resultOfCast.Instance, resultOfCast.Position, resultOfCast.Normal,originStub.d,originStub.ig,originStub.o,resultOfCast.Material,originStub.c.Name)
						ldH = nil
					else
						hitHumanoid = Damage("Gun", originStub.plr, ID,  originStub.m, resultOfCast.Instance, resultOfCast.Position, resultOfCast.Normal, originStub.d, originStub.dist, originStub.ig, originStub.c, originStub.g, originStub.h, originStub.o)
						if hitHumanoid and hitHumanoid ~= ldH then
							ldH = hitHumanoid
						else
							ldH = nil
						end
					end
				else
					local hitAncestry = (resultOfCast.Instance:FindFirstAncestor("Wheels") or resultOfCast.Instance:FindFirstAncestor("Doors") or resultOfCast.Instance:FindFirstAncestor("Body") or resultOfCast.Instance:FindFirstAncestor("Hull") or resultOfCast.Instance:FindFirstAncestor("Cannon"))
					if (resultOfCast.Instance.Transparency <= 0.75 and (not originStub.E)) or hitAncestry then
						activatorComp:triggerExplosive(ID,originStub.g, resultOfCast.Instance, resultOfCast.Position, resultOfCast.Normal,originStub.d,originStub.ig,originStub.o,resultOfCast.Material,originStub.c.Name)
						if originStub.es then
							if originStub.es.Type == "HEAT" or originStub.es.Type == "TPA" then
								Props.Events:FireEvent("CampaignPointAttacked",resultOfCast.Instance, resultOfCast.Position, resultOfCast.Normal)
							end
						end

					end	
				end	
			else
				local ldH = nil
				local hitHumanoid 
				local helo = _G.heloSS.getHelo(resultOfCast.Instance)

				if originStub and not originStub.deb  then
					originStub.deb = true;
					if originStub.c.IsIncendiary then
						_G.Destruction:AddFire(resultOfCast.Instance)
					end
					if helo then
						_G.heloSS.damage(resultOfCast.Instance,originStub.dist, originStub.c.Damage.Min/10, originStub.plr)
						originStub.deb = false;
						return
					end
					if game.CollectionService:HasTag(resultOfCast.Instance.Parent, "DestructProp") or game.CollectionService:HasTag(resultOfCast.Instance, "DestructProp") then
						Damage("Prop", originStub.plr,  originStub.m, resultOfCast.Instance, resultOfCast.Position, resultOfCast.Normal, originStub.d, originStub.dist, originStub.ig, originStub.c, originStub.g, originStub.h, originStub.o)
					end

					hitHumanoid = Damage("Gun", originStub.plr, ID,  originStub.m, resultOfCast.Instance, resultOfCast.Position, resultOfCast.Normal, originStub.d, originStub.dist, originStub.ig, originStub.c, originStub.g, originStub.h, originStub.o)
					if hitHumanoid and hitHumanoid ~= ldH then
						ldH = hitHumanoid
						Props.Events:FireEvent("CampaignCharacterDamaged",hitHumanoid, hitHumanoid.Parent)
					else
						ldH = nil
					end



					if (not activatorComp:isWallIgnored(resultOfCast.Instance)) and (not hitHumanoid) then
						Props.RemoteService.bounceU("Client","ShowImpactFromPoint", resultOfCast.Instance, resultOfCast.Position, resultOfCast.Normal, resultOfCast.Material, originStub.d, hitHumanoid or false, originStub.c.Name)

					end
					originStub.deb = false
				end
			end
			if originStub.cannon or originStub.c.IsAntiMateriel then
				local hitAncestry = (H:FindFirstAncestor("Wheels") or H:FindFirstAncestor("Doors") or H:FindFirstAncestor("Body") or H:FindFirstAncestor("Hull") or H:FindFirstAncestor("Cannon"))
				if hitAncestry and (not VehiclePierce[hitAncestry]) then
					VehiclePierce[hitAncestry] = true
					if hitAncestry:FindFirstChild("Armor") then
						Resources:GetComponent("Vehicles"):GetHealth(hitAncestry.Parent):TakeDamage(math.floor(hitAncestry.Armor.Value), originStub.plr or false, originStub.weap)
						hitAncestry:SetAttribute("Health", hitAncestry:GetAttribute("Health") - (math.floor(hitAncestry.Armor.Value)))
						if H:FindFirstAncestor("TrackGuard") or  H:FindFirstAncestor"Body" then
							local vb2 = hitAncestry.Parent:FindFirstChild("Wheels")
							if vb2 then
								vb2:SetAttribute("Health", vb2:GetAttribute("Health") - (hitAncestry.Armor.Value))
							end
						elseif H:FindFirstAncestor("Cannon") then
							if hitAncestry.Parent then
								hitAncestry.Parent:SetAttribute("Health", hitAncestry.Parent:GetAttribute("Health") - (hitAncestry.Armor.Value*2))
							end
						end
					end
					
					task.delay(0.75,function()
						VehiclePierce[hitAncestry] = false
					end)
				end
			end
		end,
		
	}

};


local ExplosionStates = {
	["Vehicle"] = function(I,Gun,H,P,N,bulletDirection,Ignore,Main,M,es,Radius,createExplosion,plr,Type)
		local tankSettings, E
		if Gun.Parent and Gun.Parent:FindFirstChild("IsTank") then
			Gun = Gun.Parent
			tankSettings = require(Gun.SETTINGS)
		end
		local helo = _G.heloSS.getHelo(Gun)

		if helo then
			local se = require(helo:FindFirstChild("WeaponsList"))
			if se then
				for _, tab in ipairs(se) do
					if es == se.Cartridge then
						se = tab
						break;
					end
				end
			end
			if se then
				E = createExplosion(P,Radius,Type.."Projectile",{
					Player = plr;
					Weapon = Gun;
					S = se;
					Origin = Main;
					Radius = Radius * 4;
					damageHelo = _G.heloSS.damage;
				})
			end
			return E, tankSettings
		end
		if Gun:FindFirstAncestor("Cannons") or Gun:FindFirstAncestor("Turrets") then
			E = createExplosion(P,Radius,Type.."Projectile",{
				Player = plr;
				Weapon = Gun;
				S = {
					damageSettings = {
						Start = {
							Dist = 0.01;
						};
						End = {
							Dist = 0.3;
						};
						Multipliers = {
							Chest = 1;
							Head = 1.5;
							Limbs = 1;
						};
					};
				};
				Origin = Main;
				Radius = Radius * 4;
				damageHelo = _G.heloSS.damage;
			})
			return E, tankSettings
		end
		return false, tankSettings
	end,
};

return {
	Triggers = triggers;
	TriggerStates = TriggerStates;	
	ExplosionStates = ExplosionStates;
}