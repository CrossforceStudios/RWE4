return {
	Gun = function(api)
		local plr = api.Player
		local PlayerLoadouts = api.PlayerLoadouts;
		local hVal = 2
		local cVal = 1.5
		local lVal = 1
		local Cartridge = api.Cartridge
		local weapon = plr:IsA("Player") and PlayerLoadouts[plr].CurrentWeapon or api.Weapon;
		if not api.getOrigin() then
			return
		end
		local hitHumanoid
		if not api.Hit then return end
		if weapon  then
			hitHumanoid = api.getHumanoid(api.Hit,0)
			if not hitHumanoid then
				api.addToIgnore(api.Hit)
				local newH, newP, newN =  api.findNewHit()
				if newH then
					hitHumanoid = api.doDamage("Gun", plr, api.Settings, newH, newP, newN, api.Direction, api.Distance + (newP - api.Position).magnitude, api.Ignore, Cartridge, weapon, api.Health, api.Origin)
				end
			elseif hitHumanoid and hitHumanoid.Name:find("Target") then
				if api.getBloodDB(hitHumanoid.Parent) then return end
				if hitHumanoid.Parent:FindFirstChild("NotReady") then return end
				local dmg = api.getBaseDamage(weapon,api.Settings,api.Distance,Cartridge)
				local chosenDamage = 0
				local headShot = false
				if dmg then
					if api.Hit.Name == "Head" then
						headShot = true
						chosenDamage = dmg  * api.Accurand(hVal, hVal + 0.1, 0.01)
					elseif api.Hit.Name:find "Torso" then
						chosenDamage = dmg * api.Accurand(cVal, cVal + 0.1, 0.01)
					elseif api.Hit.Name ~= "HumanoidRootPart" then
						chosenDamage = dmg * api.Accurand(lVal, lVal + 0.1, 0.01)
					end
					if api.Health then
						chosenDamage = chosenDamage + (dmg) 
					end
				end
				if chosenDamage and not api.getBloodDB(hitHumanoid.Parent) then
					api.setBloodDB(hitHumanoid.Parent, true)
					api.tagHumanoid(weapon,hitHumanoid,plr,chosenDamage,hitHumanoid.Health,headShot,(api.Hit.CFrame.p - api.Origin).Magnitude,api.fHP(api.Hit))
					api.RemoteService.bounceU("Client","ShowImpactFromPoint", api.Hit, api.Position, api.Normal, api.Distance, hitHumanoid or false, Cartridge.Name, api.Hit.Material)
					api.setBloodDB(hitHumanoid.Parent, false)
				end
			elseif hitHumanoid and hitHumanoid.Health > 0 and api.FactionService:IsEnemy(plr:IsA("Player") and plr or require(plr.BOT),hitHumanoid) then
				if api.getBloodDB(hitHumanoid.Parent) then return end
				if hitHumanoid.Parent:FindFirstChild("NotReady") then return end
				local dmg = api.getBaseDamage(weapon,api.Settings,api.Distance,Cartridge)
				local chosenDamage = 0
				local headShot = false
				if dmg then
					if api.Hit.Name == "Head" then
						headShot = true
						chosenDamage = dmg  * api.Accurand(hVal, hVal + 0.1, 0.01)
					elseif api.Hit.Name:find "Torso" then
						chosenDamage = dmg * api.Accurand(cVal, cVal + 0.1, 0.01)
					elseif api.Hit.Name ~= "HumanoidRootPart" then
						chosenDamage = dmg * api.Accurand(lVal, lVal + 0.1, 0.01)
					end
					if api.Health then
						chosenDamage = chosenDamage + (dmg) 
					end
				end
				if headShot then
					api.RemoteService.bounce("Client","FlingHat",hitHumanoid.Parent)
				end
				if chosenDamage and not api.getBloodDB(hitHumanoid.Parent) then
					api.setBloodDB(hitHumanoid.Parent, true)

					if hitHumanoid:GetAttribute("HumanoidType") ~= "Target" then
						api.tagHumanoid(weapon,hitHumanoid,plr,chosenDamage,hitHumanoid.Health,headShot,(api.Hit.CFrame.p - api.Origin).Magnitude,api.fHP(api.Hit))
						for _, mo in pairs(_G.Mobs) do
							if mo.AddSense then
								mo:AddSense("Damage","Teammate",{
									hitHumanoid.Parent;
									plr:IsA("Player") and plr.Character or plr;
								})
							end
						end
						api.RemoteService.bounceU("Client","Bleed",api.Hit,api.Position,api.Normal)
					else
						hitHumanoid:TakeDamage(chosenDamage)
						if hitHumanoid.Health <= 0 then
							hitHumanoid.Health = 100
						end
					end
					api.setBloodDB(hitHumanoid.Parent, false)
				end
			end
		end
		return hitHumanoid
	end;
	Prop = function(api)
		local hVal = 2
		local cVal = 1.5
		local lVal = 1
		local plr = api.Player
		local Cartridge = api.Cartridge
		local weapon = plr:IsA("Player") and api.PlayerLoadouts[plr].CurrentWeapon or api.Weapon

		local hitHumanoid
		if not api.Hit then return end
		if weapon  then
			hitHumanoid = api.Hit
			if not hitHumanoid then
				return
			elseif hitHumanoid and hitHumanoid:GetAttribute("Health") then
				if api.getBloodDB(hitHumanoid.Parent) then return end
				local dmg = api.getBaseDamage(weapon,api.Settings,api.Distance,Cartridge)
				local chosenDamage = 0
				local headShot = false
				if dmg then
					chosenDamage = dmg * api.Accurand(cVal, cVal + 0.1, 0.01)
					if api.Health then
						chosenDamage = chosenDamage + (dmg) 
					end
				end
				if chosenDamage and not api.getBloodDB(hitHumanoid.Parent)  then
					api.setBloodDB(hitHumanoid.Parent, true)
					hitHumanoid:SetAttribute("Health", hitHumanoid:GetAttribute("Health") - chosenDamage)
					if hitHumanoid:GetAttribute("Health") <= 0 then
						game.CollectionService:AddTag(hitHumanoid,"DestroyedProp")
						task.delay(1.5, function()
							hitHumanoid:Destroy()
						end)
					end
					api.setBloodDB(hitHumanoid.Parent, false)
					return
				end
			else
				hitHumanoid = api.Hit.Parent
				if not hitHumanoid then
					return
				elseif hitHumanoid and hitHumanoid:GetAttribute("Health") then
					if api.getBloodDB(hitHumanoid.Parent) then return end
					local dmg = api.getBaseDamage(weapon,api.Settings,api.Distance,Cartridge)
					local chosenDamage = 0
					local headShot = false
					if dmg then
						chosenDamage = dmg * api.Accurand(cVal, cVal + 0.1, 0.01)
						if api.Health then
							chosenDamage = chosenDamage + (dmg) 
						end
					end
					if chosenDamage and not api.getBloodDB(hitHumanoid.Parent) then
						api.setBloodDB(hitHumanoid.Parent, true)
						hitHumanoid:SetAttribute("Health", hitHumanoid:GetAttribute("Health") - chosenDamage)
						if hitHumanoid:GetAttribute("Health") <= 0 then
							game.CollectionService:AddTag(hitHumanoid,"DestroyedProp")
							task.delay(1.5, function()
								hitHumanoid:Destroy()
							end)
						end
						api.setBloodDB(hitHumanoid.Parent, false)
					end
				end
			end
		end
		return hitHumanoid;
	end
}
