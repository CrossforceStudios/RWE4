local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Resources = require(ReplicatedStorage.Resources)

local HttpService = game:GetService("HttpService")
local ServerScriptService = game:GetService("ServerScriptService")
local LaunchTypes = Resources:LoadConfiguration("Activators")
local FastCast = Resources:LoadLibrary("FastCast")
--local MissileCast = Resources:LoadLibrary("MissileCast")
--local GrenadeCast = Resources:LoadLibrary("GrenadeCast")
local createExplosion = Resources:LoadLibrary("CreateExplosion")
return {
	Init = function(Props,Components)
		local ProjectileM = {}
		local origins = {}
		local grenadeOrigins = {}
		--local grenadeEffects = Resources:LoadConfiguration("GrenadeEffects")
		local cartridgeP = Resources:LoadLibrary("cartridgePenetration")
		local caster = FastCast.new()
		--local mCaster = MissileCast.new()
		--local gCaster = GrenadeCast.new()
		function ProjectileM:removeOrigin(id)
			origins[id] = nil
		end
		function ProjectileM:destroyHit(ID, segmentVelocity, H)
			local cart = origins[ID].c
			if cart then
				if cart:CanDestroy(segmentVelocity.Magnitude, H) then
					task.spawn(function()
						cart:DestroyPart(H, segmentVelocity)
					end)
					return
				end
			end
		end
		caster.CastTerminating:Connect(function(cast)
			ProjectileM:removeOrigin(cast.UserData.ID)
		end)
		caster.LengthChanged:Connect(function(cast, lastPoint, segmentVelocity, cosmeticBulletObject, ID)
			local TriggerStates = LaunchTypes.TriggerStates 
			if origins[ID] then
				if origins[ID].plr then
					for k, state in TriggerStates do
						if state.Type ~= "Projectile" then
							continue
						end
						if state.OnProcessLength then
							state.OnProcessLength(cast, lastPoint, segmentVelocity, cosmeticBulletObject, ID, origins[ID].plr)
						end
					end
				end
			end
		end)
		caster.RayHit:Connect(function(cast, resultOfCast, segmentVelocity, cosmeticBulletObject, ID)
			if not resultOfCast then
				return
			end
			local TriggerStates = LaunchTypes.TriggerStates 
			for k, state in TriggerStates do
				if state.Type ~= "Projectile" then
					continue
				end
				if state.OnPreProcessHit then
					state.OnPreProcessHit(cast, resultOfCast, segmentVelocity, cosmeticBulletObject, ID, origins[ID].plr, origins[ID].d)
				end
			end
			if origins[ID] then
				if origins[ID].plr then
					for k, state in TriggerStates do
						if state.Type ~= "Projectile" then
							continue
						end
						if state.OnProcessHit then
							state.OnProcessHit(cast, resultOfCast, segmentVelocity, cosmeticBulletObject, ID, origins[ID].plr, origins[ID].d, origins[ID], ProjectileM, Props)
						end
					end
				end
			end




				
		end)
		caster.RayPierced:Connect(function(cast, resultOfCast, segmentVelocity, cosmeticBulletObject, ID)
			local H,P,N,M = resultOfCast.Instance, resultOfCast.Position, resultOfCast.Normal, resultOfCast.Material
			local TriggerStates = LaunchTypes.TriggerStates 
			if origins[ID] then
				if origins[ID].plr then
					for k, state in TriggerStates do
						if state.Type ~= "Projectile" then
							continue
						end
						if state.OnProcessPierce then
							state.OnProcessPierce(cast, resultOfCast, segmentVelocity, cosmeticBulletObject, ID, origins[ID].plr, origins[ID].d, ProjectileM, origins[ID], Props)
						end
					end
				end
			end
			local ldH = nil
			local hitHumanoid 

			
		end)
        --[[
		gCaster.CastTerminating:Connect(function(cast,explode,position)
			if explode then
				if grenadeOrigins[cast.UserData.ID].g then
					if grenadeEffects[grenadeOrigins[cast.UserData.ID].gt] and grenadeOrigins[cast.UserData.ID].gt ~= "Projectile"  then
						grenadeEffects[grenadeOrigins[cast.UserData.ID].gt](cast.RayInfo.CosmeticNadeObject or false,grenadeOrigins[cast.UserData.ID].dmg,position,grenadeOrigins[cast.UserData.ID].plr)
					end
				end
			end
			cast.RayInfo.CosmeticNadeObject:Destroy()
			ProjectileM:removeGrenadeOrigin(cast.UserData.ID)
		end)	
		gCaster.RayHit:Connect(function(cast, resultOfCast, segmentVelocity, cosmeticBulletObject)
			local H,P,N,M,GN,ID = resultOfCast.Instance,  resultOfCast.Position, resultOfCast.Normal, resultOfCast.Material, cosmeticBulletObject, cast.UserData.ID
			if cast.RayInfo.CosmeticNadeObject then
				if grenadeOrigins[cast.UserData.ID].gt == "Projectile" then
					grenadeEffects.Projectile(cast.RayInfo.CosmeticNadeObject or false,grenadeOrigins[cast.UserData.ID].dmg,H,P,grenadeOrigins[cast.UserData.ID].plr,ID,origins[ID].o)
				elseif grenadeEffects[grenadeOrigins[cast.UserData.ID].gt] then
					grenadeEffects[grenadeOrigins[cast.UserData.ID].gt](cosmeticBulletObject,grenadeOrigins[cast.UserData.ID].dmg,P,grenadeOrigins[cast.UserData.ID].plr,N)
				end
			end
		end)
		gCaster.NadeBounced:Connect(function(cast, resultOfCast, segmentVelocity, cosmeticNadeObject)
			local o = resultOfCast.Instance
			if o and o:FindFirstChild("BreakingPoint") then
				game.CollectionService:AddTag(o,"GlassBreak")
				task.delay(0.3, function()
					o:Destroy()
				end)
			end
		end)
        ]]--
        --[[
		mCaster.LengthChanged:Connect(function(cast, lastPoint, rayDir, rayDisplacement, segmentVelocity, cosmeticBulletObject)
			local ML = cosmeticBulletObject.Size.Z / 2
			local target  = cast.StateInfo.Target 
			local rot = {target.CFrame:ToEulerAnglesXYZ()}
			local cf = CFrame.new(lastPoint, lastPoint + rayDir) * CFrame.new(0,0,-(rayDisplacement - ML))
			local rot2 = {cf:ToEulerAnglesXYZ()};
			local velocity = cast:GetVelocity() 
			local diff = target.Velocity - velocity
			local cfAng = CFrame.new(lastPoint, lastPoint + (target.CFrame.Position - lastPoint).Unit * rayDir.Magnitude)
			local cfAng2 = cfAng - cfAng.Position
			local cf2 =  CFrame.new(cfAng.Position) * cfAng2:Lerp(CFrame.new(cfAng.Position), 0.01) * CFrame.new(0,0,-(rayDisplacement - ML))
			cast:SetVelocity(cf2.LookVector.Unit *  cast.RayInfo.MaxDistance/30)
			for _, v in ipairs(workspace.Terrain:GetChildren()) do
				if v:IsA("Attachment") and v.Name == "FlarePoint" then
					if (v.CFrame.Position - cf2.Position).Magnitude <= 25 then
						local exp = createExplosion(cf2.Position, 12.5 , "HE",{
							S = {};
							Radius = 12.5;
						})
						exp.Parent = workspace
						cast:Terminate()
						return
					end
				end
			end
		end)
		mCaster.RayHit:Connect(function(cast,result,vel,bullet)
			if result then
				local H, P, N, M = result.Instance, result.Position, result.Normal, result.Material
				if origins[cast.UserData.ID].es then
					local helo = _G.heloSS.getHelo(H)
					local hitAncestry = (H:FindFirstAncestor("Wheels") or H:FindFirstAncestor("Doors") or H:FindFirstAncestor("Body") or H:FindFirstAncestor("Hull") or H:FindFirstAncestor("Cannon"))
					if (H.Transparency <= 0.75 and (not origins[cast.UserData.ID].E)) or hitAncestry or helo then
						ProjectileM:triggerExplosive(cast.UserData.ID,origins[cast.UserData.ID].g,H,P,N,origins[cast.UserData.ID].d,origins[cast.UserData.ID].ig,origins[cast.UserData.ID].o,M,origins[cast.UserData.ID].c.Name)
						if origins[cast.UserData.ID].E then
							task.wait(1.5)
							origins[cast.UserData.ID].E = nil;
						end
						if H.Parent then
							if workspace.CurrentMap.Value:FindFirstChild("Lights") then
								if H:IsDescendantOf(workspace.CurrentMap.Value:FindFirstChild("Lights"))  then
									if H:FindFirstChildWhichIsA("Light") then
										H:AddTag("DeadLight")
									end
								end	
							end
						end	
						if hitAncestry.Parent:FindFirstChild("IsTank") then
							Props.Events:FireEvent("TankHit",hitAncestry.Parent, origins[cast.UserData.ID].plr)
						end
					end
				end
			end
		end)
        ]]--
		function ProjectileM:launch(launcherType, args)
			local launcher = LaunchTypes.Triggers[launcherType]
			if not args.Vars then
				args.Vars = {}
			end
			if launcher then
				launcher.activate({
					Player = args.player;
					Weapon = args.weapon;
					PlayerLoadouts = Props.PlayerLoadouts();
					ProjectMode = args.projectMode;
					Mode = args.mode;
					MainPart = args.Vars.Main;
					BulletCFrame = args.bCFrame;
					getFirePort = function(index)
						local result 
						for _, p in ipairs(args.weapon:GetChildren()) do
							if p:IsA("BasePart") then
								if p.Name == "Main" then
									if p:FindFirstChild("BarrelIndex") then
										if p.BarrelIndex.Value == index then
											result = p
											break;
										end
									end
								end
							end
						end
						return result
					end,
					CartridgeName = args.Vars.Cartridge;
					Cartridges = Props.Cartridges;
					CartridgeObj = args.cart;
					GaugeIndex = args.GaugeIndex;
					Magazines = Props.MagazinesList;
					GaugeTypes = Props.GaugeTypes;
					getDirection = function(SE)
						local spreadDir = nil
						if SE.Spread then
							local randSpread1 = Props.RAD(Props.Accurand(0, 365))
							local randSpread2 = Props.RAD(Props.Accurand(-(SE.Spread), SE.Spread, 0.01))
							spreadDir = CFrame.fromAxisAngle(Props.V3(0, 0, 1),randSpread1) * Props.CFANG(randSpread2, 0, 0)
						end
						return spreadDir
					end,
					DamageSettings = args.Vars.damageSettings;
					ArmamentType = args.Vars.ArmamentType;
					GrenadeType = args.Vars.Grenade;
					V3 = Props.V3;
					AntiCheat = Props.AntiCheat;
					RNG = Props.RNG;
					RemoteService = Props.RemoteService;
					addOrigin = function(id,o,d,r,e,ig,plr,m,c,es,g,gn,cannon)
						origins[id] = {
							o = o;
							r = r;
							e = e;
							d = d;
							ig = ig;
							plr = plr;
							m = m;
							c = c;
							g = g;
							gn = gn;
							es = es;
							dist  = 0;
							pC = 0;
							cannon = cannon;
							deb = false;
						}
					end;
					ExplosiveData = Props.ExplosiveData;
					setCannonFlag = function(ID, cannon)
						origins[ID].cannon = cannon;
					end,
					setWeapon = function(ID, weapon)
						origins[ID].weapon = weapon;
					end,
					WeaponUtils = Props.WeaponUtils;
					penetrationFunction = cartridgeP;
					getOrigin = function(ID)
						return origins[ID]
					end,
					isWallIgnored = function(Wall)
						return ( 
							(Wall.Transparency >= 1) or
								(Wall.Parent and (not Wall.Parent:FindFirstChildOfClass("Humanoid"))) and (not Wall.CanCollide))
					end,
					newBehavior = function()
						return FastCast.newBehavior()
					end,
					newGrenadeBehavior = function()
						return GrenadeCast.newBehavior()
					end,
					castProjectile = function(id, pos, direction, velocity, dat)
						origins[id].cast = caster:Fire(pos, direction, velocity, dat, id)	
					end,
					newMissileBehavior = function()
						return MissileCast.newBehavior()
					end,
					Helicopter = args.Vars.Helo;
					MissileCast = MissileCast;
					castMissileProjectile = function(id, pos, direction, velocity, lock, dat)
						origins[id].cast = mCaster:Fire(id, pos, direction, velocity, lock, dat)
					end,
					getItem = function(name)
						return Resources:GetItem(name)
					end,
					assembleNade = function(nadeCopy, player)
						if Props.AssemblerList()[player] then
							Props.AssemblerList()[player]["Grenade"]:Assemble(nadeCopy)
						else
							local na = Props.PseudoInstance.new("GrenadeAssembler",{})
							na:Assemble(nadeCopy)
							na:Destroy()
							na = nil
						end
					end,
					LookPoint = args.lookPoint;
					ChargeAddend = args.chargeAddend;
					GrenadeTime = args.time;
					gunIgnore = Props.gunIgnores[args.player];
					addGrenadeOrigin = function(id,o,d,ig,plr,dmg,g,gt,dur,es,h)
						grenadeOrigins[id] = {
							o = o;
							d = d;
							ig = ig;
							plr = plr;
							dmg = dmg;
							g = g;
							gt = gt;
							dur = dur;
							es = es;
							h = h or false;
						}
					end,
					castGrenade = function(id, origin, direction, velocity, params)
						gCaster:Fire(origin, direction, velocity, params, id)
					end,
					updateLoadoutSlot = Props.UpdateLoadoutSlot;
					Joint = Props.Joint;
					createCharge = function(mine, player)
						local charge = Props.PseudoInstance.new("ExplosiveMine",game.HttpService:GenerateGUID(false),mine,mine,player)
						game.CollectionService:AddTag(mine,game.HttpService:GenerateGUID(false))
						game.CollectionService:AddTag(mine,"Weapon")
						mine.Parent = player.Carry
						Props.UpdateLoadoutSlot(player, mine, 4, "Bomb")
						return charge
					end,
					MineCFrame = args.mineCF;
					ChargeName = args.mineName;
					getNewEffect = function(effectName)
						return Resources:GetEffect(effectName):Clone()
					end,
					ChargeFuse = args.fuse;
					Charge = args.bomb;
					createFusedCharge = function(mine,bomb,player)
						return Props.PseudoInstance.new("ExplosiveMine",game.HttpService:GenerateGUID(false),mine,bomb,player)
					end,
				})
			end
		end
		function ProjectileM:getOrigin(ID)
			return origins[ID]
		end
		function ProjectileM:isWallIgnored(Wall)
			return ( 
				(Wall.Transparency >= 1) or
					(Wall.Parent and (not Wall.Parent:FindFirstChildOfClass("Humanoid"))) and (not Wall.CanCollide))
		end
		function ProjectileM:addGrenadeOrigin(id,o,d,ig,plr,dmg,g,gt,dur,es,h)
			grenadeOrigins[id] = {
				o = o;
				d = d;
				ig = ig;
				plr = plr;
				dmg = dmg;
				g = g;
				gt = gt;
				dur = dur;
				es = es;
				h = h or false;
			}
		end
		function ProjectileM:removeGrenadeOrigin(id)
			grenadeOrigins[id] = nil
		end;
		local explosionFC = 1000;
		function ProjectileM:BurnExp(gun,radius,H,P,N,M,player,I,Main)
			explosionFC += 1;
			origins[I].E = createExplosion(P,radius,"TPA",{
				Player = player;
				Weapon = gun;
				S = require(gun.SETTINGS);
				Origin = Main;
				Radius = radius * 4;
				Count = explosionFC;
			})
			_G.Destruction:AddFire(H)
		end
		function ProjectileM:SpawnFire(gun,P,radius,player)
			local S = require(gun.SETTINGS)

			local part = Instance.new("Part")
			explosionFC = explosionFC + 1;
			part.Name = "FirePart" .. explosionFC
			local ray = Ray.new(P,Vector3.new(0,-1,0) * 100)
			local h, p, n = workspace:Raycast(ray.Origin, ray.Direction)
			if h then
				part.CFrame = CFrame.new(p + (n) + Vector3.new(0,1.5,0))
			else
				part.CFrame = CFrame.new(P + n + Vector3.new(0,1.5,0))
			end
			local Point1 = part.CFrame.Position+Vector3.new(-radius/2,-radius/8,-radius/2)
			local Point2 = part.CFrame.Position+Vector3.new(radius/2,radius/8,radius/2)
			local FireRegion = Region3.new(Point1,Point2)			
			part.Anchored = true
			part.CanCollide = false
			part.Size = Vector3.new(radius,radius/5,radius)
			part.Orientation = Vector3.new(0,0,0)
			part.Transparency = 1
			local explosion = createExplosion(part.CFrame.Position,radius,"Incendiary",{
				Part = part;
				Count = explosionFC; 
			})
			explosion.Parent = workspace
			part.Parent = workspace
			local conn 
			local DPS = 25
			local td = 0;
			conn = Props.RunService.Heartbeat:Connect(function(dt)
				td = td + dt;
				for _,Part in ipairs(workspace:FindPartsInRegion3(FireRegion,nil,math.huge)) do
					if Part.Name == ("HumanoidRootPart"or"Head") and Part.Parent:FindFirstChildOfClass("Humanoid") then
						local Humanoid = Part.Parent:FindFirstChildOfClass("Humanoid")
						if Props.FactionService:IsEnemy(player:IsA("Player") and player or require(player.BOT),Humanoid) then 
							Props.tagHumanoid(gun,Humanoid,player,(Humanoid.MaxHealth*(DPS*0.005)),Humanoid.Health,false,0,Part)
						else
							Humanoid:TakeDamage((Humanoid.MaxHealth*(DPS*0.005)))
						end
					end
				end
				if td >= 10 then
					conn:Disconnect()
				end
			end)
			task.wait(10)
			part:Destroy()
		end;
		function ProjectileM:triggerExplosive(I,Gun,H,P,N,bulletDirection,Ignore,Main,M,es)
			local es2 = Props.ExplosiveData[es]
			local plr = origins[I].plr
			local Radius = es2.Radius
			local Type = es2.Type
			if Type == "TPA" then 
				ProjectileM:BurnExp(Gun,Radius,H,P,N,M,plr,I,Main)
				return
			elseif Type == "Incendiary" then
				ProjectileM:SpawnFire(Gun,P,Radius,plr)
				return
			elseif Type == "DBFire" then
				explosionFC += 1;
				origins[I].E = createExplosion(P,Radius,"DBFire",{
					Player = plr;
					Weapon = Gun;
					S =  Resources:LoadItemConfig(Gun.Name);
					Origin = Main;
					Radius = Radius * 4;
					Count = explosionFC;
					Normal = N;
				})
				_G.Destruction:AddFire(H)
			end
			local ExplosionStates = LaunchTypes.ExplosionStates;
			local eResult = nil
			local tankSettings
			for _, state in ExplosionStates do
				eResult, tankSettings = state(I,Gun,H,P,N,bulletDirection,Ignore,Main,M,es,Radius,createExplosion,plr,Type)
				if eResult then
					break
				end
			end
			if eResult then
				return eResult
			end
			
			origins[I].E = createExplosion(P,Radius,Type.."Projectile",{
				Player = plr;
				Weapon = Gun;
				S = tankSettings or  Resources:LoadItemConfig(Gun.Name);
				Origin = Main;
				Radius = Radius * 4;
				damageHelo = _G.heloSS.damage;
			})

		end
		Resources:AddComponent("WeaponActivator", ProjectileM)
	end;

}