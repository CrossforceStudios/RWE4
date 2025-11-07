local CollectionService = game:GetService("CollectionService")
local DamageTag = {}
local Resources = require(game.ReplicatedStorage.Resources)
local fastSpawn = Resources:LoadLibrary("FastSpawn")
local FastDelay = Resources:LoadLibrary("FastDelay")
local RunService = game:GetService("RunService")
local t = Resources:LoadLibrary("t")

DamageTag.__index = DamageTag
function DamageTag.BooleanToString(bool)
	return((bool) and "1" or "0")
end
function DamageTag.StringToBoolean(str)
	local num = tonumber(str)
	local result = false
	if num then
		if num < 2  and num >  -1 then
			result = (num == 1)
		else 
			result = false
		end
	end
	return result
end
function DamageTag.new(ID,Dmg,Weapon,Killer,isHeadShot,distance,isExplosive,eType)
	local self = setmetatable({},DamageTag)
	self.ID = ID
	self.dmg = Dmg
	self.WeaponID = Weapon
	self.Killer = Killer
	self.Headshot = isHeadShot or false

	self.Dist = distance
	self.Health = nil;
	self.Applied = false;
	if not self.ID then
		return nil
	end
	self.Explosive = isExplosive or false
	self.ExplosionType = eType or "explosive"
	self.TagString = "ID = " .. self.ID .. " Dmg = " .. self.dmg .. " WID = " .. self.WeaponID .. " KID = " .. self.Killer .. " Headshot = " .. DamageTag.BooleanToString(self.Headshot) .. " Explosive = " .. DamageTag.BooleanToString(self.Explosive)  .. " ExplosionType = " .. self.ExplosionType  .. " Dist = " .. tostring(self.Dist) .. " "
	return self
end
function DamageTag:SetHeadshot(value)
	self.Headshot = value
end
function DamageTag.ParseTag(tagStr)
	local obj = {}
	local pattern = "(%a+)%s?=%s?([%w%p]+)%s"
	for key, val in tagStr:gmatch(pattern) do
		if key == "Dmg" then
			obj.dmg = tonumber(val)
		elseif key == "WID" then
			obj.WeaponID = val
		elseif key == "ID" then
			obj.ID = val
		elseif key == "KID" then
			obj.Killer = val
		elseif key == "Headshot" then
			obj.Headshot = DamageTag.StringToBoolean(val)
		elseif key == "Explosive" then
			obj.Explosive = DamageTag.StringToBoolean(val)
		elseif key == "ExplosionType" then
			obj.ExplosionType = val
		elseif key == "Dist" then
			obj.Dist = tonumber(val)
		end
	end
	local tag = DamageTag.new(obj.ID,obj.dmg,obj.WeaponID,obj.Killer,obj.Headshot,obj.Dist,obj.Explosive, obj.ExplosionType)
	return tag
end
function DamageTag:GetWeapon()
	local WID = self.WeaponID
	local wTagged = CollectionService:GetTagged(WID)[1]
	return wTagged
end
function DamageTag:GetWeaponName()
	local WID = self.WeaponID
	local wTagged = CollectionService:GetTagged(WID)
	if #wTagged <= 0 then return end
	if not CollectionService:HasTag(wTagged[1],"Weapon") then return end
	return wTagged[1].Name
end
function DamageTag:Destroy() 
	setmetatable(self, nil)
end
function DamageTag:AddWound(part,enemy)
	local humanoid = part.Parent:FindFirstChildOfClass("Humanoid")
	local repl = humanoid
	if repl then
		self.entityPart = part.Name
		if part:GetAttribute("BleedRate") then
			if self.entityPart == "Head" then
				part:SetAttribute("BleedRate", part:GetAttribute("BleedRate") +  200)
			else
				part:SetAttribute("BleedRate", part:GetAttribute("BleedRate") +  (t.match("(Left|Right)")(self.entityPart) and 10 or 20))
			end
		end
	end
end

function DamageTag.RemoveWound(part,enemy)
	local humanoid = part.Parent:FindFirstChildOfClass("Humanoid")
	local repl = humanoid			
	if repl then
		local entityPart = part.Name
		if part:GetAttribute("BleedRate") then
			if entityPart == "Head" then
				part:SetAttribute("BleedRate", part:GetAttribute("BleedRate") -  200)
			else
				part:SetAttribute("BleedRate", part:GetAttribute("BleedRate") -  (t.match("(Left|Right)")(entityPart) and 10 or 20))
			end
		end
	end
end
function DamageTag:MarkEnemyVehicle(enemy,remove,damage)
	if (enemy:IsA("VehicleSeat")) then 
		remove = remove ~= nil and remove or true
		damage = damage ~= nil and damage or true
		enemy.Parent:SetAttribute("Health",enemy.Parent:GetAttribute("Health") - tonumber(self.dmg))
		local dmg = self.dmg
		CollectionService:AddTag(enemy,self.TagString)
		if damage and not self.Applied then
			self.Applied = true
			enemy:TakeDamage(self.dmg)
		end
		local tagStr = self.TagString
	end
end
function DamageTag.GetVehicleDTs(enemy)
	if (enemy:IsA("VehicleSeat")) then
		local l = {}
		for _, tagStr in ipairs(CollectionService:GetTags(enemy)) do
			local tag = DamageTag.ParseTag(tagStr)
			if tag then
				table.insert(l, tag)
			end
		end
		return l
	end
end
function DamageTag:MarkEnemy(enemy,remove,damage)
	if (enemy:IsA("Humanoid")) then 
		remove = remove ~= nil and remove or true
		damage = damage ~= nil and damage or true
		self.Health = enemy.Health - tonumber(self.dmg)
		local dmg = self.dmg
		CollectionService:AddTag(enemy,self.TagString)
		if damage and not self.Applied then
			self.Applied = true
			enemy:TakeDamage(self.dmg)
		end
		enemy.Parent:SetAttribute("Headshot", self.Headshot)
		local tagStr = self.TagString
		if remove then
			FastDelay(5 + (1 * (0.02 * self.Health)),function()

				if enemy.Parent and enemy.Parent:GetAttribute("Headshot") then
					enemy.Parent:SetAttribute("Headshot", false)
				end
				CollectionService:RemoveTag(enemy,tagStr)
				self:Destroy()
			end)
		else
			local selfChar = CollectionService:GetTagged(self.Killer)[1]
			if selfChar then
				if selfChar:IsA("Player") then
					fastSpawn(function()
						selfChar.Character.Humanoid.Died:Wait()
						if enemy then
							if  enemy.Health <= 0 then
								repeat RunService.Heartbeat:Wait()  until (not selfChar) or (not selfChar.Character.Parent)
							end
						end
						if enemy then
							if  CollectionService:HasTag(enemy,tagStr) then
								CollectionService:RemoveTag(enemy,tagStr)
								self:Destroy()
							end
						end
					end)
				elseif selfChar:IsA("Model") and selfChar:FindFirstChild("BOT") then
					fastSpawn(function()
						selfChar:FindFirstChildOfClass("Humanoid").Died:Wait()
						if enemy then
							if  enemy.Health <= 0 then
								repeat RunService.Heartbeat:Wait() until (not selfChar) or (not selfChar.Parent)
							end
						end
						if enemy then
							if  CollectionService:HasTag(enemy,tagStr) then
								CollectionService:RemoveTag(enemy,tagStr)
								self:Destroy()
							end
						end
					end)			
				end
			end
		end

	end
end
function DamageTag:GetEnemy()
	local enemy = CollectionService:GetTagged(self.ID)[1]
	if enemy then
		return enemy
	end
end
function DamageTag:GetKiller()
	local Killer = CollectionService:GetTagged(self.Killer)[1]
	if Killer then 
		return Killer
	end
end
return DamageTag