local LoadoutClass = {}
local Resources = require(game.ReplicatedStorage.Resources)
local RemoteService = Resources:LoadLibrary("RemoteService")
local RunService = game:GetService("RunService")
local inList = Resources:LoadLibrary("inList")
local LoadoutConfig = Resources:LoadConfiguration("LoadoutConfig")
LoadoutClass.__index = LoadoutClass
function LoadoutClass:UpdateIgnored(list)
	self.Ignored = list
end

function LoadoutClass:UpdateLoadoutDirect(slot,weapon,changeFunc)
	if self.CurrentItems[self.Slots[slot]] then
		self.CurrentItems[self.Slots[slot]]:Destroy()
		self.CurrentItems[self.Slots[slot]] = false
		self[slot] = false
	end	
	if weapon then
		self.CurrentItems[self.Slots[slot]] = weapon
		if LoadoutConfig.PostValidators[slot] then
			if not LoadoutConfig.PostValidators[slot](weapon) then
				self.CurrentItems[self.Slots[slot]] = false
				self[slot] = false
			else
				self.CurrentItems[self.Slots[slot]] = weapon
				self[slot] = self.CurrentItems[self.Slots[slot]];
				changeFunc(weapon,slot)
			end		
		else
			self.CurrentItems[self.Slots[slot]] = false
			self[slot] = false
		end
	else
		self.CurrentItems[self.Slots[slot]] = false
		self[slot] = false
	end
end

function LoadoutClass:UpdateLoadout(slot,awt,plr,changeFunc,uL)
	local result 
	for _, itemN in uL do
		local item = Resources:GetItem(itemN)
		if LoadoutConfig.SelectValidators[slot] then
			if LoadoutConfig.SelectValidators[slot](item,awt) then
				result = item
			end		
		end

	end
	if self.CurrentItems[self.Slots[slot]] then
		self.CurrentItems[self.Slots[slot]]:Destroy()
		self.CurrentItems[self.Slots[slot]] = false
		self[slot] = false
	end	
	if result then
		
		result = result:Clone()
		self.CurrentItems[self.Slots[slot]] = result
		if LoadoutConfig.PostValidators[slot] then
			if not LoadoutConfig.PostValidators[slot](result) then
				self.CurrentItems[self.Slots[slot]] = false
				self[slot] = false
			else
				self.CurrentItems[self.Slots[slot]] = result
				self[slot] = self.CurrentItems[self.Slots[slot]];
				changeFunc(result,slot)
			end		
		else
			self.CurrentItems[self.Slots[slot]] = false
			self[slot] = false
		end
	else
		self.CurrentItems[self.Slots[slot]] = false
		self[slot] = false
	end
end

function LoadoutClass:__call(...)
	local args = {...}
	local SetLoadoutItem = Resources:GetLocalBindableEvent("SetLoadoutItem")

	if args[1] == "equip" then
		if typeof(args[2]) == "Instance" then
			if args[2]:IsA("Player" ) then
				local list = {};
				for _, slot in LoadoutConfig.Slots do
					table.insert(list, {slot, self.CurrentItems[self.Slots[slot]]})
				end 	
				for i, item in ipairs(list) do
					if inList(item[1],self.Ignored) then
						list[i][2] = false
					end
				end
				local plr = args[2]
				print("Starting loadout for " .. plr.Name)		
				local t = 0
				while t < 0.5 do
					t = t + RunService.Heartbeat:Wait()
				end
				if args[3] then
					local wt 
					for i, item in ipairs(list) do
						if item[2]  then
							wt = item[2]
							break;
						end
					end
					local Weapon = wt:Clone()			
					Weapon.Parent = plr.Character
					self.CurrentWeapon = Weapon;
				end
			end
		elseif typeof(args[2]) == "table" and tostring(args[2]):find("Mob") then
			self.CurrentItems[1] = self.Primary
			if args[2].Character:FindFirstChildOfClass("Tool") then
				args[2].Character:FindFirstChildOfClass("Tool").Parent = nil
			end
			args[2].Humanoid:EquipTool(self.CurrentItems[1])
			return self.CurrentItems[1]
		end
	end
end
function LoadoutClass:GetSlotList()
	local slots = {}
	for _, slot in LoadoutConfig.Slots do
		if self.Slots[slot] then 
			if self.CurrentItems[self.Slots[slot]] then
				table.insert(slots, {
					Name = self.CurrentItems[self.Slots[slot]].Name;
					Item = self.CurrentItems[self.Slots[slot]]
				})
			end
		end
	end
	return slots
end
function LoadoutClass:GetSlotDict()
	local slots = {}
	for _, slot in LoadoutConfig.Slots do
		if self.Slots[slot] then 
			if self[slot] then
				slots[slot] = self[slot] or false;
			end
		end
	end
	return slots
end
function LoadoutClass.CreateSlotUIsFromList(list,plr,unequip,equip)
	local slots = {}
	for i, slot in ipairs(list) do
		local button = script.LoadoutSlot:Clone()
		button.Item.Text = slot.Name
		button.SlotNumber.TextContent.Text = i
		button.LayoutOrder = i
		button.MouseButton1Click:connect(function()
			if plr.Character:FindFirstChild("Type") then
				if plr.Character:FindFirstChild("Type").Parent ~= slot.Item then
					RemoteService.send("Server","UnequipItems",plr.Character:FindFirstChild("Type").Parent)
					local t = 0
					while t < 0.5 do
						t = t + RunService.Heartbeat:Wait()
					end
					RemoteService.send("Server","EquipItem",slot.Item)
				end
			end
		end)
		slots[i] = button
	end
	return slots
end
function LoadoutClass:Serialize()
	local obj = {}
	for _, slot in LoadoutConfig.Slots do
		if self.Slots[slot] then 
			if self.CurrentItems[self.Slots[slot]] then
				obj[slot] = if self.CurrentItems[self.Slots[slot]] then self.CurrentItems[self.Slots[slot]].Name else "";
			end
		end
	end
	obj.Name = self.Name
	return obj
end
function LoadoutClass.new(name,...)
	local self = {}
	local args = {...}
	self.Name = name
	self.Slots = {};
	self.Cache = {};
	self.CurrentItems = {};
	self.Ignored = {};
	self.CurrentWeapon = nil;

	for i, slot in LoadoutConfig.Slots do
		self.Slots[slot] = i;
		self.CurrentItems[i] = args[i] or false;
		self.Cache[slot] = false;
	end
	return setmetatable(self,LoadoutClass)
end
return LoadoutClass