
local Explosions = {};
local vDebounces = {
	["HE"] = {};
	["HEAT"] = {};
	["Frag"] = {};

};
_G.ExplosionCounts = {
	["Flash"] = 0;
	["Smoke"] = 0;
};
local Resources = require(game.ReplicatedStorage.Resources)
local getBaseDamage = Resources:LoadLibrary("getProjectileBaseDmg")
local FactionService = Resources:LoadLibrary("FactionService")
local tagHumanoid = Resources:LoadLibrary("tagHumanoid")
local PhysicsService = game:GetService("PhysicsService")
local FastDelay = Resources:LoadLibrary("FastDelay")
local FastWait = Resources:LoadLibrary("FastWait")
local Make = Resources:LoadLibrary("Make")
local PseudoInstance = Resources:LoadLibrary("PseudoInstance")
local RemoteService = Resources:LoadLibrary("RemoteService")
local getHumanoid = Resources:LoadLibrary("getHumanoid")
local Tween = Resources:LoadLibrary("Tween")
local WeaponUtils = Resources:LoadLibrary("WeaponUtils")
local EventUtils = Resources:LoadLibrary("EventUtils")
local Components = Resources:GetLocalTable("Components")
local RNG = Random.new()
local PROP_MAX_HEALTH = 100
---
local fragment  = {}
local explosionRenderTypes = {

};
do
	if not _G.ESIDS then
		_G.ESIDS = {
			383597236,
			383597378,
			873196719,
			873196678,
			873196633,
			873196591,
			2759713309,
			2814355743
		}
	end
	explosionRenderTypes.Explosion = function(e,p,h,effects)
		local player = game.Players.LocalPlayer
		local sound = h.CreateESound(p)
		sound:Play()
		e.Hit:Connect(function(o,d)
			if p:FindFirstChild("Tank") then
				Components.Destruction:flingTankPart(o,d)	
			end	
		end)
		local C = effects.Explosion:GetChildren()
		for i, v in ipairs(C) do
			if v:IsA("ParticleEmitter") then
				local Particle = v:Clone()
				Particle.Parent = p
				Particle.Size = NumberSequence.new(e.BlastRadius/4)
				Particle:Emit(Particle.EmitCount.Value)
				Particle = nil;
			end
		end 
		Components.Camera:ShakeExplosion(e)
		local ShakeMagnitude = player:DistanceFromCharacter(e.Position)/(e.BlastRadius/8)
		if ShakeMagnitude < 25 then
			Components.Input.PlayRumble("Explosion")
		end
		h.createLights(p,e)
		FastWait(.75)
		FastDelay(sound.TimeLength - .75,function()
			sound:Destroy()
			sound = nil;
		end)
		FastDelay(30 - .75,function()
			p:Destroy()
			p = nil;
		end)
		return true;
	end;
	explosionRenderTypes.Flash = function(e,p,h,effects)
		local part = h.createFlash(p,e)
		local bl = h.createBrightLight(part,e)
		local bang = h.CreateFlashSound(part)
		bang:Play()
		local Ring = h.CreateRingSound(part)
		Components.Explosion.FlashPlayer(part,e,function(elTime, tw)
			h.stopSounds(workspace)
			Ring:Play()
			h.tweenInSound(Ring, elTime)
			FastWait(.1)
			h.muffle(workspace)
			FastDelay(Ring.TimeLength/10, function()
				h.tweenOutSound(Ring, elTime)
				h.unmuffleSounds()
			end)

		end,function(elTime, tw)

		end)
		Tween(bl, "Brightness", 0, "Smooth", .25, false)
		Tween(bl, "Color", Color3.fromRGB(0,0,0), "Smooth", .25, false)

		FastDelay(.5, function()
			bl:Destroy()
			part:Destroy()
			part = nil
			bl = nil;
		end)
		return true			
	end;
	explosionRenderTypes.Fire = function(e,p,h,effects)
		if p:FindFirstChild("FireM") then					
			local esi = h.CreateESound(p,"rbxassetid://626807593")
			esi.PlaybackSpeed = 1.5;
			esi.Parent = p
			esi:Play()
		end
		local es = h.CreateESound(p,"rbxassetid://156283121")
		es.PlaybackSpeed = 1.5;
		es.Parent = p
		es:Play()
		local expPart = effects.Fire.Explosion:Clone()
		expPart.Parent = p
		expPart:Emit(300)
		local fire = PseudoInstance.Make("ParticleFire",{
			Size = e.BlastRadius/5;				
		})
		fire.CFrame = p.CFrame	
		fire:SetParentSize(Vector3.new(e.BlastRadius,e.BlastRadius/5,e.BlastRadius))
		FastDelay(10,function()
			p:Destroy()
			fire:Destroy()
			p = nil;
			fire = nil;
		end)
		return true;
	end;
	explosionRenderTypes.TPA = function(e,p,h,effects)
		if p:FindFirstChild("FireM") then					
			local esi = h.CreateESound(p,"rbxassetid://626807593")
			esi.PlaybackSpeed = 1.5;
			esi.Parent = p
			esi:Play()
		end
		local expPart = effects.Fire.Explosion:Clone()
		expPart.Parent = p
		expPart:Emit(300)
		FastDelay(5,function()
			p:Destroy()
			p = nil;
		end)
		return true;
	end;
	explosionRenderTypes.CS = function(e,p,h,effects)
		if p:FindFirstChild("FireM") then					
			local esi = h.CreateESound(p,"rbxassetid://626807593")
			esi.PlaybackSpeed = 1.5;
			esi.Parent = p
			esi:Play()
		end
		local expPart = effects.Fire.Explosion:Clone()
		expPart.Parent = p
		expPart:Emit(300)
		FastDelay(5,function()
			p:Destroy()
			p = nil;
		end)
		return true;
	end;
	explosionRenderTypes.DBFire = function(e,p,h,effects)
		local expPart = Resources:GetEffect("DBSparks"):Clone()
		for _, v in ipairs(Enum.NormalId:GetEnumItems()) do
			local v2 = e:GetAttribute("Normal").Unit
			local values = {}
			for i,xv in ipairs({"X";"Y";"Z"}) do
				local n = v2[xv]
				if math.sign(n) ~= n and math.sign(n) ~= 0 then
					n = n * (1/n) 	
				end
				values[i] = n
			end
			v2 = Vector3.new(unpack(values))
			local v3 = Vector3.FromNormalId(v)
			if v3 == v2 then
				expPart.EmissionDirection = v
				break
			end
		end
		expPart.Parent = p
		expPart:Emit(4000)
		FastDelay(5,function()
			p:Destroy()
			p = nil;
		end)
		return true;
	end;
	explosionRenderTypes.Smoke = function(e,p,h,effects)
		local Smokes = {};
		Smokes[1] = effects.Smoke.Smoke:Clone()
		Smokes[1].Rate *= p:GetAttribute("Radius") / 125
		Smokes[1].Color = if e:GetAttribute("SmokeColor") then ColorSequence.new(BrickColor.new(e:GetAttribute("SmokeColor")).Color) else Smokes[1].Color
		Smokes[1].Parent = p
		local f = effects.Smoke.Fuse:Clone()
		f.Parent = p
		f:Play()
		f.Ended:Connect(function()
			f:Destroy()
		end)
		for _, v in ipairs(Smokes) do
			v.Enabled = true;
			task.delay(p:GetAttribute("EffectTime")/2, function()
				v.Enabled = false
			end)
		end
		return true;

	end;
end

Explosions["HEProjectile"] = {

	Hit = function(Obj,Dist,EX)
		if Obj:FindFirstChild("BreakingPoint") then
			game.CollectionService:AddTag(Obj, "GlassBreak")
			FastDelay(0.3, function()
				Obj:Destroy()
			end)
			return
		end
		if Obj:HasTag("DestructProp") then
			local health = Obj:GetAttribute("Health")
			local distanceFactor = Dist / EX.Radius
			distanceFactor = 1 - distanceFactor
			local newDamage = PROP_MAX_HEALTH * distanceFactor;
			Obj:SetAttribute("Health", health)
			return
		end
		if Obj:HasTag("PhysicalObject") or Obj.Parent:HasTag("PhysicalObject") then
			Obj:ApplyImpulseAtPosition(EX.Radius * RNG:NextUnitVector() * 1e2, Obj.Position)
			return
		end
		if Obj.Name == "Fragment" and (not fragment[Obj]) then
			fragment[Obj] = true
			if Obj:GetAttribute("CTag") then
				if _G.Destruction:CanCollapse(Obj:GetAttribute("CTag"), Obj:GetAttribute("CFactor")) then
					task.spawn(function() _G.Destruction:Collapse(Obj:GetAttribute("CTag"), Obj:GetAttribute("CFactor")) end)
				end	
				game.CollectionService:RemoveTag(Obj,Obj:GetAttribute("CTag"))
			end
			game.CollectionService:AddTag(Obj,"Fragment")
			return
		end
		if not vDebounces["HE"][Obj.Parent] then
			local player = EX.Player;
			local S  = EX.S;
			local playerObj = ((not player:IsA("Player")) and require(player.BOT) or player)
			if Obj.Parent  then
				if EX.damageHelo then
					EX.damageHelo(Obj,Dist,8,playerObj)
				end
				local hitHumanoid = getHumanoid(Obj,0)
				if hitHumanoid and hitHumanoid.Health > 0  then
					local distanceFactor = Dist / EX.Radius
					distanceFactor = 1 - distanceFactor
					local newDamage = hitHumanoid.Health * distanceFactor;
					if hitHumanoid.SeatPart then
						if hitHumanoid.SeatPart.Parent then
							if hitHumanoid.SeatPart.Parent:FindFirstChild("IsTank") then
								return
							end
							local unit = RNG:NextUnitVector()
							Obj:ApplyImpulse((unit * ((EX.Radius/2) * distanceFactor)) * 1e3)
						end
					end
					if hitHumanoid.Name == "Target" then
						tagHumanoid(EX.Weapon,hitHumanoid,player,newDamage,hitHumanoid.Health,Obj.Name == "Head",Dist,Obj,true)
					elseif hitHumanoid.Parent:GetAttribute("OwnerTeam") then
						tagHumanoid(EX.Weapon,hitHumanoid,player,newDamage/2,hitHumanoid.Health,Obj.Name == "Head",Dist,Obj,true)
						if hitHumanoid.Health <= 0 then
							for _, v in ipairs(hitHumanoid.Parent:GetDescendants()) do
								if v:IsA("BasePart") then
									v.BrickColor = BrickColor.new("Really black")
								end
							end
							EventUtils:FireEvent("CacheDestroyed",hitHumanoid.Parent, player)

							RemoteService.bounce("Client","FadeCharacter", hitHumanoid.Parent, 3)
							FastDelay(3, function()
								hitHumanoid.Parent:Destroy()
							end)
						end
					elseif FactionService:IsEnemy(playerObj,hitHumanoid) then
						tagHumanoid(EX.Weapon,hitHumanoid,player,newDamage,hitHumanoid.Health,Obj.Name == "Head",Dist,Obj,true)
					else
						tagHumanoid(EX.Weapon,hitHumanoid,player,newDamage,hitHumanoid.Health,Obj.Name == "Head",Dist,Obj,true)
					end

					return
				end
			end						
		end

	end;
};

local function getTank(obj)
	local VehiclesPar = workspace.Vehicles
	for _, v in VehiclesPar:GetChildren() do
		if obj:IsDescendantOf(v)  then
			return v
		end
	end
	return nil
end

local function getTankComp(tank,obj)
	for _, comp in tank:GetChildren() do
		if obj:IsDescendantOf(comp) then
			return comp
		end
	end
	return nil
end

local function getTankComps(tank)
	local c = 0
	for _, comp in tank:GetChildren() do
		if comp:IsA("Model") then
			c += 1
		end
	end
	return c
end

Explosions["HEATProjectile"] = {

	Hit = function(Obj,Dist,EX)

		--_G.CampaignEvents.PointAttacked:Fire(Obj,Obj.Position,-Obj.CFrame.UpVector)
		if Obj:HasTag("DestructProp") then
			local health = Obj:GetAttribute("Health")
			local distanceFactor = Dist / EX.Radius
			distanceFactor = 1 - distanceFactor
			local newDamage = PROP_MAX_HEALTH * distanceFactor;
			Obj:SetAttribute("Health", health)
			return
		end
		if Obj:FindFirstChild("BreakingPoint") then
			game.CollectionService:AddTag(Obj, "GlassBreak")
			FastDelay(0.3, function()
				Obj:Destroy()
			end)
			return
		end
		if Obj:HasTag("PhysicalObject") or Obj.Parent:HasTag("PhysicalObject") then
			Obj:ApplyImpulseAtPosition(EX.Radius * RNG:NextUnitVector() * 1e2, Obj.Position)
			return
		end
		if Obj.Parent then
			if Obj.Parent.Parent:GetAttribute("ShipHealth") then
				if Obj.Parent.Name == "Hull"  then

					local index = 0 
					local sinkOthers 
					sinkOthers = function(part)
						local newI = Obj:FindFirstAncestor("Hull").Parent:GetAttribute("ShipHealth") - 1
						Obj:FindFirstAncestor("Hull").Parent:SetAttribute("ShipHealth", newI)
						_G.Destruction:StartBillowingFire(Obj)
					end
					sinkOthers(Obj)
					if EX.Player then
						if EX.Player:IsA("Player") then
							Obj:FindFirstAncestor("Hull").Parent:SetAttribute("Attacker", EX.Player.Team.Name)
						else
							local B = require(EX.Player.BOT)
							Obj:FindFirstAncestor("Hull").Parent:SetAttribute("Attacker", B.Team.Name)
						end
					end
				elseif Obj.Parent.Name == "Cannon" and Obj.Parent:GetAttribute("CannonHealth") > 0  and (not Obj.Parent:GetAttribute("Destroyed")) then
					local index = 0 
					local sinkOthers 
					sinkOthers = function(part)
						local newI = Obj.Parent:GetAttribute("CannonHealth") - 1
						Obj.Parent:SetAttribute("CannonHealth", newI)
						if Obj.Parent:FindFirstChild("CannonHealth") <= 0 then
							if not Obj.Parent:GetAttribute("Destroyed") then
								Obj.Parent:SetAttribute("Destroyed", true)
								for _, v in Obj.Parent:GetDescendants() do
									if v:IsA("BasePart") then
										v.Material = Enum.Material.CorrodedMetal
									end
								end
								_G.Destruction:StartBillowingFire(Obj)
							end
						end 
						local newI = Obj:FindFirstAncestor("Hull").Parent:GetAttribute("ShipHealth") - 1
						Obj:FindFirstAncestor("Hull").Parent:SetAttribute("ShipHealth", newI)
					end
					sinkOthers(Obj)
				elseif Obj:FindFirstAncestor("MachineGun") then
					local mgt =  Obj:FindFirstAncestor("MachineGun")
					if mgt:GetAttribute("TurretHealth") > 0  and (not mgt:GetAttribute("Destroyed")) then
						local index = 0 
						local sinkOthers 
						sinkOthers = function(part)
							local newI = mgt:GetAttribute("TurretHealth") - 1
							mgt:SetAttribute("TurretHealth", newI)
							if mgt:FindFirstChild("TurretHealth") <= 0 then
								mgt:SetAttribute("Destroyed", true)
								for _, v in mgt:GetDescendants() do
									if v:IsA("JointInstance") then
										v:Destroy()
										v.Part1:ApplyImpulse(RNG:RandomUnitVector() * (RNG:NextInteger(1,8) * 1e3))
									end
								end
							end 
						end
						sinkOthers(Obj)
					end

				end
			end
		end

		if Obj:GetAttribute("FireCapable") then
			_G.Destruction:StartBillowingFire(Obj)
			return
		end
		if Obj:FindFirstAncestor("TransmissionTower") then
			if fragment[Obj:FindFirstAncestor("TransmissionTower")] then
				return
			end
			fragment[Obj:FindFirstAncestor("TransmissionTower")] = true
			_G.Destruction:flingCollapseGeneric(Obj:FindFirstAncestor("TransmissionTower"), Dist, EX.Player)
			return
		end

		if Obj.Name == "Fragment" and (not fragment[Obj]) then
			fragment[Obj] = true
			if Obj:GetAttribute("CTag") then
				if _G.Destruction:CanCollapse(Obj:GetAttribute("CTag"), Obj:GetAttribute("CFactor")) then
					task.spawn(function() _G.Destruction:Collapse(Obj:GetAttribute("CTag"), Obj:GetAttribute("CFactor")) end)
				end	
				game.CollectionService:RemoveTag(Obj,Obj:GetAttribute("CTag"))
			end
			game.CollectionService:AddTag(Obj,"Fragment")
			return
		end
		if not vDebounces["HEAT"][Obj.Parent] then
			local player = EX.Player;
			local S  = EX.S;
			local playerObj = ((not player:IsA("Player")) and require(player.BOT) or player)
			if EX.damageHelo then
				EX.damageHelo(Obj,Dist,8,playerObj)
			end
			local tank = getTank(Obj)
			if tank then
				local vb = getTankComp(tank, Obj)
				if vb then

					if  (not vDebounces["HEAT"][vb]) and tank:FindFirstChild("IsTank") then
						vDebounces["HEAT"][vb] = true
						local dmg = tank:GetAttribute("Health") / getTankComps(tank)
						local distanceFactor = Dist / EX.Radius
						distanceFactor = 1 - distanceFactor
						if EX.Weapon:FindFirstChild("Type") then
							if WeaponUtils:HasItemCapability(EX.Weapon, "DistanceDamage")  then
								dmg *= distanceFactor
							end
						end
						local vh = Resources:GetComponent("Vehicles"):GetHealth(tank)
						vh:TakeDamage(dmg, EX.Player, EX.Weapon)
						if tank:GetAttribute("Health") <= 10 and tank:GetAttribute("Health") > 0 then
							vh:Ignite()

							FastDelay(3, function()
								getTank(Obj):SetAttribute("Health", 0)
							end)
						end
						local data = vb
						if data then
							local health = data:GetAttribute("Health")
							if health then
								data:SetAttribute("Health", health - dmg)
								if Obj:FindFirstAncestor("TrackGuard") or  Obj:FindFirstAncestor"Body" then
									local vb2 = vb.Parent.Wheels
									if vb2 then
										vb2:SetAttribute("Health",vb2:GetAttribute("Health") - dmg)
									end
								end
							end
						end 
						print("Vehicle Health: ",tank:GetAttribute("Health"))

						FastDelay(0.05, function()
							vDebounces["HEAT"][vb] = false
						end)
						return
					elseif (not vDebounces["HEAT"][vb])  then
						vDebounces["HEAT"][vb] = true
						local distanceFactor = Dist / EX.Radius
						distanceFactor = 1 - distanceFactor
						local newDamage = vb.Parent:GetAttribute("Health")
						if newDamage <= 0 then
							vDebounces["HEAT"][vb] = false
							return
						end
						if EX.Weapon:FindFirstChild("Type") then
							if WeaponUtils:HasItemCapability(EX.Weapon, "DistanceDamage")  then
								newDamage *= distanceFactor
							end
						end
						local veh = Resources:GetComponent("Vehicles"):GetHealth(getTank(Obj))
						if veh then 
							veh:TakeDamage(newDamage, EX.Player, EX.Weapon) 
							if getTank(Obj):GetAttribute("Health") <= 10 and getTank(Obj):GetAttribute("Health") > 0 then
								veh:Ignite()
								FastDelay(3, function()
									getTank(Obj):SetAttribute("Health", 0)
								end)
							end
						end
						local unit = RNG:NextUnitVector()
						Obj:ApplyImpulse((unit * ((EX.Radius/2) * distanceFactor)) * 1e3)
						print("Vehicle Health: ",vb.Parent:GetAttribute("Health"))
						vDebounces["HEAT"][vb] = false
						return
					end		
				end
			end	
		end
		if  Obj:FindFirstAncestor("Ships") then
			if Obj:FindFirstAncestor("Ships") and Obj.Parent.Name == "Hull" then
				local phyical = Obj.CustomPhysicalProperties 
				phyical = PhysicalProperties.new(phyical.Density + math.random(25,60), phyical.Friction, phyical.Elasticity, phyical.FrictionWeight, phyical.ElasticityWeight)
				Obj.CustomPhysicalProperties = phyical
			end
		end
		if Obj.Parent  then
			local hitHumanoid = getHumanoid(Obj,0)
			local player = EX.Player;
			local playerObj = ((not player:IsA("Player")) and require(player.BOT) or player)
			if hitHumanoid and hitHumanoid.Health > 0  then
				local distanceFactor = Dist / EX.Radius
				distanceFactor = 1 - distanceFactor
				local newDamage = hitHumanoid.Health * distanceFactor;
				if hitHumanoid.SeatPart then
					if hitHumanoid.SeatPart.Parent then
						if hitHumanoid.SeatPart.Parent:FindFirstChild("IsTank") then
							return
						end
					end
				end
				if hitHumanoid.Name == "Target" then
					tagHumanoid(EX.Weapon,hitHumanoid,player,newDamage,hitHumanoid.Health,Obj.Name == "Head",Dist,Obj,true)
				elseif hitHumanoid.Parent:GetAttribute("OwnerTeam") then
					tagHumanoid(EX.Weapon,hitHumanoid,player,newDamage,hitHumanoid.Health,Obj.Name == "Head",Dist,Obj,true)
					print(hitHumanoid.Health)										
					if hitHumanoid.Health <= 0 then
						for _, v in ipairs(hitHumanoid.Parent:GetDescendants()) do
							if v:IsA("BasePart") then
								v.BrickColor = BrickColor.new("Really black")
							end
						end
						EventUtils:FireEvent("CacheDestroyed",hitHumanoid.Parent, player)
						RemoteService.bounce("Client","FadeCharacter", hitHumanoid.Parent, 3)
						FastDelay(3, function()
							hitHumanoid.Parent:Destroy()
						end)
					end
				elseif FactionService:IsEnemy(playerObj,hitHumanoid) then
					tagHumanoid(EX.Weapon,hitHumanoid,player,newDamage,hitHumanoid.Health,Obj.Name == "Head",Dist,Obj,true)
				else
					tagHumanoid(EX.Weapon,hitHumanoid,player,newDamage,hitHumanoid.Health,Obj.Name == "Head",Dist,Obj,true)
				end
				local unit = (Obj.CFrame.Position - EX.Position).Unit
				Obj:ApplyImpulse((unit * ((EX.Radius/10) * distanceFactor)) * 1e3)
				return
			end
		end

	end;
};
Explosions["HE"] = {

	Hit = function(Obj,Dist,EX)
		if Obj:FindFirstChild("BreakingPoint") then
			game.CollectionService:AddTag(Obj, "GlassBreak")
			FastDelay(0.3, function()
				Obj:Destroy()
			end)
			return
		end
		if Obj:HasTag("DestructProp") then
			local health = Obj:GetAttribute("Health")
			local distanceFactor = Dist / EX.Radius
			distanceFactor = 1 - distanceFactor
			local newDamage = PROP_MAX_HEALTH * distanceFactor;
			Obj:SetAttribute("Health", health)
			return
		end
		if Obj:HasTag("PhysicalObject") or Obj.Parent:HasTag("PhysicalObject") then
			Obj:ApplyImpulseAtPosition(EX.Radius * RNG:NextUnitVector() * 1e2, Obj.Position)
			return
		end
		if Obj.Name == "Fragment" and (not fragment[Obj]) then
			fragment[Obj] = true
			if Obj:GetAttribute("CTag") then
				if _G.Destruction:CanCollapse(Obj:GetAttribute("CTag"), Obj:GetAttribute("CFactor")) then
					task.spawn(function() _G.Destruction:Collapse(Obj:GetAttribute("CTag"), Obj:GetAttribute("CFactor")) end)
				end	
				game.CollectionService:RemoveTag(Obj,Obj:GetAttribute("CTag"))
			end
			game.CollectionService:AddTag(Obj,"Fragment")
			return
		end
		if not vDebounces["HE"][Obj.Parent] then
			local player = EX.Player;
			local S  = EX.S;
			local playerObj = ((not player:IsA("Player")) and require(player.BOT) or player)
			if Obj.Parent  then
				local hitHumanoid = getHumanoid(Obj,0)
				if hitHumanoid and hitHumanoid.Health > 0  then
					local distanceFactor = Dist / EX.Radius
					distanceFactor = 1 - distanceFactor
					local newDamage = hitHumanoid.Health * distanceFactor;
					if hitHumanoid.Name == "Target" then
						tagHumanoid(EX.Weapon,hitHumanoid,player,newDamage,hitHumanoid.Health,Obj.Name == "Head",Dist,Obj,true)
					elseif hitHumanoid.Parent:GetAttribute("OwnerTeam") then
						tagHumanoid(EX.Weapon,hitHumanoid,player,newDamage,hitHumanoid.Health,Obj.Name == "Head",Dist,Obj,true)
						if hitHumanoid.Health <= 0 then
							for _, v in ipairs(hitHumanoid.Parent:GetDescendants()) do
								if v:IsA("BasePart") then
									v.BrickColor = BrickColor.new("Really black")
								end
							end
							EventUtils:FireEvent("CacheDestroyed",hitHumanoid.Parent, player)
							RemoteService.bounce("Client","FadeCharacter", hitHumanoid.Parent, 3)
							FastDelay(3, function()
								hitHumanoid.Parent:Destroy()
							end)
						end
					elseif FactionService:IsEnemy(playerObj,hitHumanoid) then
						tagHumanoid(EX.Weapon,hitHumanoid,player,newDamage,hitHumanoid.Health,Obj.Name == "Head",Dist,Obj,true)
					else
						tagHumanoid(EX.Weapon,hitHumanoid,player,newDamage,hitHumanoid.Health,Obj.Name == "Head",Dist,Obj,true)

					end
					local unit = (Obj.CFrame.Position - EX.Position).Unit
					Obj:ApplyImpulse((unit * ((EX.Radius/10) * distanceFactor)) * 1e3)
					return
				end
			end						
		end
	end;
};
Explosions["Frag"] = {
	Hit = function(Obj,Dist,EX)
		if Obj:FindFirstChild("BreakingPoint") then
			game.CollectionService:AddTag(Obj, "GlassBreak")
			FastDelay(0.3, function()
				Obj:Destroy()
			end)
			return
		end
		if not vDebounces["Frag"][Obj.Parent] then
			local player = EX.Player;
			local S  = EX.S;
			local playerObj = ((not player:IsA("Player")) and require(player.BOT) or player)
			if Obj.Parent  then
				local hitHumanoid = getHumanoid(Obj,0)
				if hitHumanoid and hitHumanoid.Health > 0  then
					local distanceFactor = Dist / EX.Radius
					distanceFactor = 1 - distanceFactor
					local newDamage = hitHumanoid.Health * distanceFactor;
					if hitHumanoid.Name == "Target" then
						tagHumanoid(EX.Weapon,hitHumanoid,player,newDamage,hitHumanoid.Health,Obj.Name == "Head",Dist,Obj,true)
					elseif FactionService:IsEnemy(playerObj,hitHumanoid) then
						tagHumanoid(EX.Weapon,hitHumanoid,player,newDamage,hitHumanoid.Health,Obj.Name == "Head",Dist,Obj,true)
					else
						tagHumanoid(EX.Weapon,hitHumanoid,player,newDamage,hitHumanoid.Health,Obj.Name == "Head",Dist,Obj,true)
					end
					return
				end
			end						
		end
	end;
};
Explosions["HEAT"] = {

	Hit = function(Obj,Dist,EX)
		--_G.CampaignEvents.PointAttacked:Fire(Obj,Obj.Position,-Obj.CFrame.UpVector)
		if Obj:FindFirstChild("BreakingPoint") then
			game.CollectionService:AddTag(Obj, "GlassBreak")
			FastDelay(0.3, function()
				Obj:Destroy()
			end)
			return
		end
		if Obj:HasTag("DestructProp") then
			local health = Obj:GetAttribute("Health")
			local distanceFactor = Dist / EX.Radius
			distanceFactor = 1 - distanceFactor
			local newDamage = PROP_MAX_HEALTH * distanceFactor;
			Obj:SetAttribute("Health", health)
			return
		end
		if Obj.Name == "Fragment" and (not fragment[Obj]) then
			fragment[Obj] = true
			if Obj:GetAttribute("CTag") then
				if _G.Destruction:CanCollapse(Obj:GetAttribute("CTag"), Obj:GetAttribute("CFactor")) then
					task.spawn(function() _G.Destruction:Collapse(Obj:GetAttribute("CTag"), Obj:GetAttribute("CFactor")) end)
				end	
				game.CollectionService:RemoveTag(Obj,Obj:GetAttribute("CTag"))
			end
			game.CollectionService:AddTag(Obj,"Fragment")
			return
		end
		if Obj:HasTag("PhysicalObject") or Obj.Parent:HasTag("PhysicalObject") then
			Obj:ApplyImpulseAtPosition(EX.Radius * RNG:NextUnitVector() * 1e2, Obj.Position)
			return
		end
		if Obj:FindFirstAncestor("TransmissionTower") then
			if fragment[Obj:FindFirstAncestor("TransmissionTower")] then
				return
			end
			fragment[Obj:FindFirstAncestor("TransmissionTower")] = true
			_G.Destruction:flingCollapseGeneric(Obj:FindFirstAncestor("TransmissionTower"), Dist, EX.Player)
			return
		end
		if not vDebounces["HEAT"][Obj.Parent] then
			local player = EX.Player;
			local S  = EX.S;
			local playerObj = ((not player:IsA("Player")) and require(player.BOT) or player)
			if EX.damageHelo then
				EX.damageHelo(Obj,Dist,8,playerObj)
			end
			local tank = getTank(Obj)
			if tank then
				local vb = getTankComp(tank, Obj)
				if vb then

					if  (not vDebounces["HEAT"][vb]) and tank:FindFirstChild("IsTank") then
						vDebounces["HEAT"][vb] = true
						local dmg = tank:GetAttribute("Health") / getTankComps(tank)
						local distanceFactor = Dist / EX.Radius
						distanceFactor = 1 - distanceFactor
						if EX.Weapon:FindFirstChild("Type") then
							if WeaponUtils:HasItemCapability(EX.Weapon, "DistanceDamage")  then
								dmg *= distanceFactor
							end
						end
						local vh = Resources:GetComponent("Vehicles"):GetHealth(tank)
						vh:TakeDamage(dmg, EX.Player, EX.Weapon)
						if tank:GetAttribute("Health") <= 10 and tank:GetAttribute("Health") > 0 then
							vh:Ignite()

							FastDelay(3, function()
								tank:SetAttribute("Health", 0)
							end)
						end
						local data = vb
						if data then
							local health = data:GetAttribute("Health")
							if health then
								data:SetAttribute("Health", health - dmg)
								if Obj:FindFirstAncestor("TrackGuard") or  Obj:FindFirstAncestor"Body" then
									local vb2 = vb.Parent.Wheels
									if vb2 then
										vb2:SetAttribute("Health",vb2:GetAttribute("Health") - dmg)
									end
								end
							end
						end 
						print("Vehicle Health: ",vb.Parent:GetAttribute("Health"))

						FastDelay(0.05, function()
							vDebounces["HEAT"][vb] = false
						end)
						return
					elseif (not vDebounces["HEAT"][vb])  then
						vDebounces["HEAT"][vb] = true
						local distanceFactor = Dist / EX.Radius
						distanceFactor = 1 - distanceFactor
						local newDamage = vb.Parent:GetAttribute("Health")
						if newDamage <= 0 then
							vDebounces["HEAT"][vb] = false
							return
						end
						if EX.Weapon:FindFirstChild("Type") then
							if WeaponUtils:HasItemCapability(EX.Weapon, "DistanceDamage")  then
								newDamage *= distanceFactor
							end
						end
						local veh = Resources:GetComponent("Vehicles"):GetHealth(getTank(Obj))
						if veh then 
							veh:TakeDamage(newDamage, EX.Player, EX.Weapon) 
							if getTank(Obj):GetAttribute("Health") <= 10 and getTank(Obj):GetAttribute("Health") > 0 then
								veh:Ignite()
								FastDelay(3, function()
									getTank(Obj):SetAttribute("Health", 0)
								end)
							end
						end
						local unit = RNG:NextUnitVector()
						Obj:ApplyImpulse((unit * ((EX.Radius/2) * distanceFactor)) * 1e3)
						print("Vehicle Health: ",vb.Parent:GetAttribute("Health"))
						vDebounces["HEAT"][vb] = false
						return
					end		
				end
			end	
		end
		if Obj.Parent  then
			local hitHumanoid = getHumanoid(Obj,0)
			local player = EX.Player;
			local playerObj = ((not player:IsA("Player")) and require(player.BOT) or player)
			if hitHumanoid and hitHumanoid.Health > 0  then
				local distanceFactor = Dist / EX.Radius
				distanceFactor = 1 - distanceFactor
				local newDamage = hitHumanoid.Health * distanceFactor;
				if hitHumanoid.SeatPart then
					if hitHumanoid.SeatPart.Parent then
						if hitHumanoid.SeatPart.Parent:FindFirstChild("IsTank") then
							return
						end
					end
				end
				if hitHumanoid.Name == "Target" then
					tagHumanoid(EX.Weapon,hitHumanoid,player,newDamage,hitHumanoid.Health,Obj.Name == "Head",Dist,Obj,true)
				elseif hitHumanoid.Parent:GetAttribute("OwnerTeam") then
					tagHumanoid(EX.Weapon,hitHumanoid,player,newDamage,hitHumanoid.Health,Obj.Name == "Head",Dist,Obj,true)
					print(hitHumanoid.Health)										
					if hitHumanoid.Health <= 0 then
						for _, v in ipairs(hitHumanoid.Parent:GetDescendants()) do
							if v:IsA("BasePart") then
								v.BrickColor = BrickColor.new("Really black")
							end
						end
						EventUtils:FireEvent("CacheDestroyed",hitHumanoid.Parent, player)
						RemoteService.bounce("Client","FadeCharacter", hitHumanoid.Parent, 3)
						FastDelay(3, function()
							hitHumanoid.Parent:Destroy()
						end)
					end
				elseif FactionService:IsEnemy(playerObj,hitHumanoid) then
					tagHumanoid(EX.Weapon,hitHumanoid,player,newDamage,hitHumanoid.Health,Obj.Name == "Head",Dist,Obj,true)
				else
					tagHumanoid(EX.Weapon,hitHumanoid,player,newDamage,hitHumanoid.Health,Obj.Name == "Head",Dist,Obj,true)
				end
				local unit = (Obj.CFrame.Position - EX.Position).Unit
				Obj:ApplyImpulse((unit * ((EX.Radius/10) * distanceFactor)) * 1e3)
				return
			end
		end

	end;
};
Explosions["Flash"] = {

	Create = function(Pos,Radius,Extras)
		_G.ExplosionCounts["Flash"] += 1;
		local E = Instance.new("Explosion")
		E.Name = ("Flash%d"):format(_G.ExplosionCounts["Flash"])
		E.BlastPressure = 0;
		E.BlastRadius = Radius
		E.DestroyJointRadiusPercent = 0;
		E.ExplosionType = Enum.ExplosionType.NoCraters;
		E.Position = Pos;
		E.Parent = workspace
		return E;
	end;
};
Explosions["Incendiary"] = {

	Create = function(Pos,Radius,Extras)
		local E = Instance.new("Explosion")
		E.Name = ("Fire%d"):format(Extras.Count)
		E.BlastPressure = 0;
		E.BlastRadius = Radius
		E.DestroyJointRadiusPercent = 0;
		E.ExplosionType = Enum.ExplosionType.NoCraters;
		E.Position = Pos;
		E.Parent = workspace
		local partValue = Instance.new("ObjectValue")
		partValue.Name = "Fiery"
		partValue.Value = Extras.Part;
		local radiusValue = Instance.new("NumberValue")
		radiusValue.Name = "Radius"
		radiusValue.Value = Radius;
		radiusValue.Parent = E;
		partValue.Parent = E;
		return E;
	end;
};
Explosions["TPA"] = {
	Create = function(Pos,Radius,Extras)
		local E = Instance.new("Explosion")
		E.Name = ("Fire%d"):format(Extras.Count)
		E.BlastPressure = 0;
		E.BlastRadius = Radius
		E.DestroyJointRadiusPercent = 0;
		E.ExplosionType = Enum.ExplosionType.NoCraters;
		E.Position = Pos;
		E.Parent = workspace
		E.hit:Connect(function(Obj)
			_G.CampaignEvents.PointAttacked:Fire(Obj,Obj.Position,-Obj.CFrame.UpVector)
		end)
		local partValue = Instance.new("ObjectValue")
		partValue.Name = "Fiery"
		partValue.Value = Extras.Part;
		local radiusValue = Instance.new("NumberValue")
		radiusValue.Name = "Radius"
		radiusValue.Value = Radius;
		radiusValue.Parent = E;
		partValue.Parent = E;
		return E;
	end;
};
Explosions["CS"] = {
	Create = function(Pos,Radius,Extras)
		local E = Instance.new("Explosion")
		E.Name = ("Tear%d"):format(Extras.Count)
		E.BlastPressure = 0;
		E.BlastRadius = Radius
		E.DestroyJointRadiusPercent = 0;
		E.ExplosionType = Enum.ExplosionType.NoCraters;
		E.Position = Pos;
		E.Parent = workspace
		local partValue = Instance.new("ObjectValue")
		partValue.Name = "Teary"
		partValue.Value = Extras.Part;
		local radiusValue = Instance.new("NumberValue")
		radiusValue.Name = "Radius"
		radiusValue.Value = Radius;
		radiusValue.Parent = E;
		partValue.Parent = E;
		return E;
	end;
};
Explosions["DBFire"] = {
	Create = function(Pos,Radius,Extras)
		local E = Instance.new("Explosion")
		E.Name = ("DBFire%d"):format(Extras.Count)
		E.BlastPressure = 0;
		E.BlastRadius = Radius
		E.DestroyJointRadiusPercent = 0;
		E.ExplosionType = Enum.ExplosionType.NoCraters;
		E.Position = Pos;
		E.Parent = workspace
		local partValue = Instance.new("ObjectValue")
		partValue.Name = "Fiery"
		partValue.Value = Extras.Part;
		local radiusValue = Instance.new("NumberValue")
		radiusValue.Name = "Radius"
		radiusValue.Value = Radius;
		radiusValue.Parent = E;
		partValue.Parent = E;
		E:SetAttribute("Normal",Extras.Normal)
		return E;
	end;
};
Explosions["Smoke"] = {
	Create = function(Pos,Radius,Extras)
		_G.ExplosionCounts["Smoke"] += 1;
		local E = Instance.new("Explosion")
		E.Name = "Smoke".._G.ExplosionCounts["Smoke"]
		E.BlastPressure = 0;
		E.BlastRadius = Radius
		E.DestroyJointRadiusPercent = 0;
		E.ExplosionType = Enum.ExplosionType.NoCraters;
		E.Position = Pos;
		E:SetAttribute("Radius", Radius)
		E:SetAttribute("SmokeColor", Extras.smokeColor)
		if  Extras.S  and Extras.S.grenadeSettings then
			E:SetAttribute("EffectTime", Extras.S.grenadeSettings.detonationSettings.effectTime)
		else
			E:SetAttribute("EffectTime", 20)
		end
		local blockPart = Instance.new("Part")
		blockPart.Anchored = true;
		blockPart.CanCollide = false
		blockPart.Transparency = 1;
		blockPart.CFrame = CFrame.new(Pos);
		blockPart.Size = Extras.Size
		blockPart.Parent = workspace.SmokeIgnore
		blockPart.Name = E.Name 
		blockPart:SetAttribute("Radius", Radius)
		if  Extras.S  and Extras.S.grenadeSettings then
			FastDelay(Extras.S.grenadeSettings.detonationSettings.effectTime,function()
				blockPart:Destroy()
			end)
		else
			FastDelay(20 ,function()
				blockPart:Destroy()
			end)
		end

		E.Parent = workspace
		return E;
	end;
};
return {
	HitTypes = Explosions;
	RenderTypes = explosionRenderTypes;
}
