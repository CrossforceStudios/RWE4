local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Resources = require(ReplicatedStorage.Resources)

local HttpService = game:GetService("HttpService")
local DamageEffects = Resources:LoadConfiguration("DamageEffects")
local ServerScriptService = game:GetService("ServerScriptService")
local tagHumanoid = Resources:LoadLibrary("tagHumanoid")
local flingHat = Resources:LoadLibrary("flingHat")
local getHumanoid = Resources:LoadLibrary("getHumanoid")
local getBaseDamage = Resources:LoadLibrary("getProjectileBaseDmg")
local fHP = Resources:LoadLibrary("findHumanoidPart")

return {
	Init = function(Props,Components)
		local Damage = {} do
			Damage.Effects = {};
			Damage.Humanoids = {};	
			Damage.tagHumanoid = tagHumanoid
			local blood = {};
			for k, damageEffect in DamageEffects do
				Damage.Effects[k] = damageEffect
			end
			local doDamage
			doDamage = function(dmgType, plr,ID,S,H, P, N, D, Dist, customIgnore, c, w, hp, ori)
				local de = Damage.Effects[dmgType]
				if de  then
					de({
						Player = plr;
						getOrigin = function()
							local comp = Resources:GetComponent("WeaponActivator")
							return comp:getOrigin(ID)
						end,
						Settings = S;
						Cartridge = c;
						PlayerLoadouts = Props.PlayerLoadouts();
						getHumanoid = getHumanoid;
						addToIgnore = function(item)
							table.insert(customIgnore, item)
						end,
						Hit = H;
						Position = P;
						Direction = D;
						Distance = Dist;
						Weapon = w;
						findNewHit = function()
							local newRay = Ray.new(P, D * (c.Range - Dist + 0.1))
							local rp = RaycastParams.new()
							rp.FilterType = Enum.RaycastFilterType.Exclude
							rp.FilterDescendantsInstances = customIgnore;
							local result = workspace:Raycast(newRay.Origin, newRay.Direction, rp)
							if result then
								return result.Instance, result.Position, result.Normal
							end
						end,
						doDamage = doDamage;
						Ignore = customIgnore;
						Health = hp;
						Origin = ori;
						getBloodDB = function(Parent)
							return blood[Parent]
						end,
						setBloodDB = function(Parent, val)
							blood[Parent] = val;
						end,
						getBaseDamage = getBaseDamage;
						Accurand = Props.Accurand;
						RemoteService = Props.RemoteService;
						Normal = N;
						FactionService = Props.FactionService;
						fHP = fHP;
						tagHumanoid = tagHumanoid;
					})
				end
			end
			function Damage:Fire(H,dmg,hum,plr)
				tagHumanoid(Props.PlayerLoadouts[plr].CurrentWeapon,hum,plr,dmg,hum.Health,false,0,H)
				hum:TakeDamage(dmg)	
			end;
			function Damage:VehicleEffect(ve,occupant,attacker,w,dist,H)
				if ve then
					if ve:GetAttribute("Health") then
						if ve:GetAttribute("Health") <= 0 then
							occupant:TakeDamage(occupant.Health)
							return 2
						end
					end
				end
				return 0
			end
			Damage = setmetatable(Damage,{
				__call = function(self, dt, ...)
					doDamage(dt, ...)
				end;
				__index = function(self, k)
					if Props.Typer.InstanceOfClassHumanoid(k) then
						return self.Humanoids[k]
					end
				end;
				__newindex = function(self, k, v)
					if Props.Typer.InstanceOfClassHumanoid(k) then
						self.Humanoids[k] = v
					end
				end;
			})
		end 
		Resources:AddComponent("Damage", Damage) 
	end;

}