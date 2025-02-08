local Attachment = {}
Attachment.__index = Attachment
local Resources = require(game.ReplicatedStorage.Resources)
local RemoteService = Resources:LoadLibrary("RemoteService")
local PseudoInstance = Resources:LoadLibrary("PseudoInstance")
local Enumeration = Resources:LoadLibrary("Enumeration")
local WeapSet = Resources:LoadLibrary("WeaponSet")
local RunService = game:GetService("RunService")
local FastDelay = Resources:LoadLibrary("FastDelay")
local inList = Resources:LoadLibrary("inList")
local AttachmentModules = Resources:LoadConfiguration("AttachmentModules");
local Joint = Resources:LoadLibrary("Joint")
local findVariant = Resources:LoadLibrary("findVariant")
local AttTypes = Resources:LoadConfiguration("AttachmentTypes");

Attachment.AttachOffsets = {};
Attachment.CurrentAttachment = nil;
Attachment.PreviousWID = nil;

function Attachment.GetHighestSight(gun)
	local sightRange = 0 
	for _, part in ipairs(gun:GetChildren()) do
		if part.Name == "AimPart" then
			if part:FindFirstChild("AimOrder") then
				if sightRange <= part.AimOrder.Value then
					sightRange = part.AimOrder.Value
				end
			end
		end
	end
	if gun:FindFirstChild("SightNode") then
		if gun.SightNode:FindFirstChild("AimOrder") then
			sightRange = sightRange + gun.SightNode.AimOrder.Value
		end
	end
	if gun:GetAttribute("SightOffset") then
		sightRange = sightRange + gun:GetAttribute("SightOffset")
	end
	return sightRange
end

Attachment.RestrictionHelpers = {}
function Attachment.AddRestrictionHelp(attName,value)
	if typeof(value) ~= "function" then return end
	Attachment.RestrictionHelpers[attName] = value
end
function Attachment.getHelper(hName)
	return Attachment.RestrictionHelpers[hName]
end

function Attachment.new(...)
	local att = {}
	local args = {...}
	att.Name = args[1]
	att.Title = args[2]
	att.Type = args[3] or "Optics"
	att.Model = Resources:GetGunAttachment(att.Name):Clone()
	att.NodeName = args[4] or "SightNode"
	att.Weapons = {}
	att.ExtraData = args[5]
	att.Secondary = args[6]
	att.Offsets = {}
	local typeAtt = AttTypes[att.Type]
	if not typeAtt then
		error("Invalid attachment type.")
		return	
	end
	local slot = typeAtt.Slot
	if typeof(slot) == "function" then
		slot = slot(att, args)
	end
	att.Slot = slot
	if typeAtt.Init then
		typeAtt.Init(att, args)
	end
	att.Gun = nil;
	att.GunModel = nil;
	att.Active = false;
	att.Mounts = {}
	att.Desc = args[8] or nil;
	return setmetatable(att,Attachment)
end

function Attachment:AddWeapon(weaponName,...)
	local args = {...}
	self.Weapons[#self.Weapons+1] = weaponName
	self.Offsets[weaponName] = args[1] or CFrame.new()
	self.Mounts[weaponName] = args[2] or nil;
end


function Attachment.ClearWeaponSlot(Gun,player,slot,slotType,dontClearClient)
	local currentAttachment
	if RunService:IsClient() and (not dontClearClient) then
		currentAttachment = RemoteService.fetch("Server","GetAttachmentSlot",Gun.Name,slot)
	elseif (not dontClearClient) then
		local getCurrentAttachment = Resources:GetLocalBindableFunction("GetAttachmentSlot")
		if player and player:IsA("Player") then currentAttachment = getCurrentAttachment:Invoke(player,Gun.Name,slot) end
	end
	if currentAttachment then
		local cName = currentAttachment.Name
		cName = findVariant(cName, currentAttachment.Options) or cName
		if RunService:IsClient() and (not dontClearClient) then RemoteService.fetch("Server","ClearAttachmentSlot",Gun.Name,slot) end
		for _, part in ipairs(Gun:GetChildren()) do
			if part:HasTag("Rail_" .. cName) then
				part:Destroy()
			end
		end
		if slotType then
			local attType = AttTypes[slotType]
			if attType then
				if attType.OnClearSlot then
					attType.OnClearSlot(Gun,slot,cName)
				end
			end
		end
	end
	Attachment.DetachMountGlobal(Gun, slot)
	if not Gun:FindFirstChild("SETTINGS") then 
		return 
	end
	local S = require(Gun.SETTINGS)
	if S.defaultAttachments  and RunService:IsClient() then
		local currentAttachment = slot
		if currentAttachment then
			local GameMenu = Resources:GetComponent("GameMenu")
			if GameMenu.AttachDefault then
				GameMenu.AttachDefault(player,Gun,currentAttachment)	
			end
		end	
	end
end
function Attachment:HasWeapon(weaponName)
	return inList(weaponName,self.Weapons)
end
function Attachment:MarkAsDefault()
	self.Default = true
end
function Attachment:ClearRailData(Gun)
	local gunName = Gun.Name
	if not WeaponAData[self.Name] then
		self.Mounts[gunName] = nil;
		self.Offsets[gunName] = CFrame.new();
		return
	end
	if not WeaponAData[self.Name][gunName] then
		self.Offsets[gunName] = CFrame.new();
		self.Mounts[gunName] = nil
	end
end
function Attachment:Detach(Gun)
	if not Gun then return false end
	for _, part in ipairs(Gun:GetChildren()) do
		if part:IsA("BasePart") then
			if part.Name == "Main_Old" then
				part.Name = "Main"
			elseif (part:FindFirstChild("AttachmentJointRef") and (game.CollectionService:HasTag(part,self.Slot))) then
				part:Destroy()
			end
		end
	end

end
function Attachment:AttachMount(weapon, name, slot, node)
	if (not RunService:IsServer()) and (not weapon.Parent:IsA("ViewportFrame")) then
		return
	end
	local mount = Resources:GetGunAttachment(name)
	if mount then
		mount = mount:Clone()
		mount:SetPrimaryPartCFrame(weapon:FindFirstChild(node).CFrame)
		for i, part in mount:GetChildren() do
			if part:IsA("BasePart") and part ~= mount.PrimaryPart then
				part.Parent = weapon
				local joint = Joint("Assemble", weapon.HoldPart, part, CFrame.new(), "MountAttachment")
				part.Anchored = false
				part:SetAttribute("MountSlot", slot)
			end
		end
		mount:Destroy()
	end
end
function Attachment.DetachMountGlobal(weapon, slot)
	for i, part in weapon:GetChildren() do
		if part:IsA("BasePart") and part:GetAttribute("MountSlot") == slot then
			part:Destroy()
		end
	end
end
function Attachment:DetachMount(weapon, slot)
	for i, part in weapon:GetChildren() do
		if part:IsA("BasePart") and part:GetAttribute("MountSlot") == slot then
			part:Destroy()
		end
	end
end
function Attachment:ApplyAI(Gun,mainPartName)
	if self.Type then
		local attType = AttTypes[self.Type]
		if attType then
			if attType.OnClearSlot then
				attType.OnClearSlot(Gun,self.Slot,self.Name)
			end
		end
	end
	self:DetachMount(Gun, self.Slot)
	local assembler = PseudoInstance.new("AttachmentAssembler",self.Type,self.ExtraData)
	assembler.weldMode = mainPartName;
	local gunName
	local cfOffset
	local sightRange = Attachment.GetHighestSight(Gun)
	if not self:HasWeapon(Gun.Name) then return end
	gunName = Gun.Name
	local refmodel=self.Model
	local menunode = Gun:FindFirstChild(self.NodeName)
	local mainpart = Gun:FindFirstChild(mainPartName)
	local mount
	if refmodel and menunode then
		local model=refmodel:Clone()	
		local sr2 = Attachment.GetHighestSight(model)
		local S = require(Gun.SETTINGS)
		local S2
		if refmodel:FindFirstChild("OFFSETS") then
			S2 = require(refmodel.OFFSETS)
		end 
		if S2 then
			cfOffset = S2[Gun.Name];
		end
		local attnode=model.Node
		local weldcframes={}
		local maincf=attnode.CFrame
		local parts=model:GetChildren()
		for i=1,#parts do
			local v=parts[i]
			if v:IsA("BasePart")then
				weldcframes[v]= maincf:toObjectSpace(v.CFrame)
			end
		end
		local typeAtt = AttTypes[self.Type]
		if model.PrimaryPart and menunode then
			model:PivotTo(menunode.CFrame * (cfOffset or CFrame.new()))
			if typeAtt then
				if typeAtt.OnPivot then
					typeAtt.OnPivot(self,Gun,model)
					return
				end
			end
		end			
		local soundId 
		local function clearJoints(p : BasePart)
			for _, j in p:GetChildren() do
				if j:IsA("JointInstance") then
					j.Part1.Anchored = true
					j:Destroy()
				end
			end
		end
		if typeAtt then
			if typeAtt.processOriginal then
				local del=Gun:GetChildren()
				typeAtt.processOriginal(self,del,Gun,S,sightRange,sr2,model,clearJoints)
			end
		end
		for _, v in ipairs(model:GetChildren()) do
			if v.Name == "AimPart" then
				if v:FindFirstChild("AimOrder") then
					if not v:FindFirstChild("KeepOrder") then
						v.AimOrder.Value = sightRange + (v.AimOrder.Value - (S.aimOrderOffset or 1))
					end
				end
			end
		end		
		if S.mountedSight then
			if S.mountedSight[self.Name] then
				self:AttachMount(Gun, S.mountedSight[self.Name], self.Slot,  self.NodeName)
			end
		end
		assembler:Assemble(model,Gun,self.NodeName,cfOffset or false,self.Offsets,self.Slot,((self.CFrame or CFrame.new())))
		if S.mainSightVisibility then
			if S.mainSightVisibility[self.Slot] ~= nil then
				for _, del in Gun:GetChildren() do
					if del:IsA("BasePart") then
						if del.Name:find("MainSight") and del:GetAttribute("Front") then
							del.Transparency = if S.mainSightVisibility[self.Slot] then 0 else 1
							if del:FindFirstChildOfClass("Decal") then
								del:FindFirstChildOfClass("Decal").Transparency = if S.mainSightVisibility[self.Slot] then 0 else 1
							end
						end
					end
				end					

			end
		end
		if typeAtt then
			if typeAtt.postAttach then
				typeAtt.postAttach(self,Gun,S)
			end
		end
		attnode:Destroy()
		model:Destroy()
	end
	if self.Gun and Gun ~= self.Gun then
		self.Gun = Gun
	elseif self.Gun == nil then 
		self.GunModel = Gun
	end


end
function Attachment:SetOptions(opts)
	self.NewOpts = opts;
end
function Attachment:Apply(Gun,mainPartName,player,sendToServer,slideCF,isDefault)
	local currentAttachment
	if RunService:IsClient() then
		currentAttachment = RemoteService.fetch("Server","GetAttachmentSlot",Gun.Name,self.Slot)
	else
		local getCurrentAttachment = Resources:GetLocalBindableFunction("GetAttachmentSlot")
		currentAttachment = (not isDefault) and  getCurrentAttachment:Invoke(player,Gun.Name,self.Slot) or nil;
	end
	if currentAttachment then

		if currentAttachment.Name  then
			local cName = currentAttachment.Name
			cName = findVariant(cName, self.NewOpts or currentAttachment.Options) or currentAttachment.Name
			if self.Type then
				local attType = AttTypes[self.Type]
				if attType then
					if attType.OnClearSlot then
						attType.OnClearSlot(Gun,self.Slot,cName)
					end
				end
			end
		end
		local Node =	Gun:FindFirstChild(self.NodeName .. "_Old")
		if Node then
			Node.Name = self.NodeName
		end
	end
	self:DetachMount(Gun, self.Slot)

	local assembler = PseudoInstance.new("AttachmentAssembler",self.Type,self.ExtraData)
	assembler.weldMode = mainPartName;
	local gunName
	local cfOffset
	local sightRange = Attachment.GetHighestSight(Gun)
	if not self:HasWeapon(Gun.Name) then return end
	gunName = Gun.Name
	local cName = self.Name
	if currentAttachment and (not self.Default) then
		cName = currentAttachment.Name
		cName = findVariant(cName, self.NewOpts or currentAttachment.Options) or currentAttachment.Name
	end
	local refmodel= Resources:GetGunAttachment(cName)
	local menunode = Gun:FindFirstChild(self.NodeName)
	local mainpart = Gun:FindFirstChild(mainPartName)
	local mount
	local typeAtt = AttTypes[self.Type]
	if refmodel  then
		if ((not Gun:FindFirstAncestorOfClass("ViewportFrame"))  and (not game.CollectionService:HasTag(Gun, "UnlockImage"))) and (player) then
			if (not player.Character)	then
				if sendToServer then
					local newAttachment = RemoteService.fetch("Server","GetAttachmentSlot",Gun.Name,self.Slot)
					if newAttachment ~= self.Name then
						RemoteService.send("Server","SetAttachmentSlot",Gun.Name,self.Slot,self.Name)
					end
				end
				return

			elseif (not player.Character.Parent) then
				if sendToServer then
					local newAttachment = RemoteService.fetch("Server","GetAttachmentSlot",Gun.Name,self.Slot)
					if newAttachment ~= self.Name then
						RemoteService.send("Server","SetAttachmentSlot",Gun.Name,self.Slot,self.Name)
					end
				end
				return

			end
		end
		local model=refmodel:Clone()	
		local sr2 = Attachment.GetHighestSight(model)
		local S = require(Gun.SETTINGS)
		local S2
		if refmodel:FindFirstChild("OFFSETS") then
			S2 = require(refmodel.OFFSETS)
		end 
		if S2 then
			cfOffset = S2[Gun.Name];
		end

		local attnode=model.Node
		local weldcframes={}
		local maincf=attnode.CFrame
		local parts=model:GetChildren()
		for i=1,#parts do
			local v=parts[i]
			if v:IsA("BasePart")then
				weldcframes[v]= maincf:toObjectSpace(v.CFrame)
			end
		end
		if model.PrimaryPart and menunode then
			model:PivotTo(menunode.CFrame * (cfOffset or CFrame.new()) * (slideCF or (currentAttachment.CFrame or CFrame.new())))
			if typeAtt then
				if typeAtt.OnPivot then
					typeAtt.OnPivot(self,Gun,model)
					return
				end
			end
		end		
		local soundId
		local function clearJoints(p : BasePart)
			for _, j in p:GetChildren() do
				if j:IsA("JointInstance") then
					j.Part1.Anchored = true
					j:Destroy()
				end
			end
		end
		if typeAtt then
			if typeAtt.processOriginal then
				local del=Gun:GetChildren()
				typeAtt.processOriginal(self,del,Gun,S,sightRange,sr2,model,clearJoints)
			end
		end
		local modelAimParts = {};
		for _, v in ipairs(model:GetChildren()) do
			if v.Name == "AimPart" then
				if v:FindFirstChild("AimOrder") then
					modelAimParts[v.AimOrder.Value] = v
				end
			end
		end			
		if S.mountedSight then
			if S.mountedSight[cName] then
				self:AttachMount(Gun, S.mountedSight[cName], self.Slot,  self.NodeName)
			end
		end
		assembler:Assemble(model,Gun,self.NodeName,cfOffset or false,self.Offsets,self.Slot,(slideCF or (currentAttachment.CFrame or CFrame.new())))
		for o, v in ipairs(modelAimParts) do
			if S.useAttOrder then
				v.AimOrder.Value = (o - (S.aimOrderOffset or 1))
			else
				v.AimOrder.Value = (sightRange) + (o - (S.aimOrderOffset or 1))
			end
		end		
		if S.mainSightVisibility then
			if S.mainSightVisibility[self.Slot] ~= nil then
				for _, del in Gun:GetChildren() do
					if del:IsA("BasePart") then
						if del.Name:find("MainSight") and del:GetAttribute("Front") then
							del.Transparency = if S.mainSightVisibility[self.Slot] then 0 else 1
							if del:FindFirstChildOfClass("Decal") then
								del:FindFirstChildOfClass("Decal").Transparency = if S.mainSightVisibility[self.Slot] then 0 else 1
							end
						end
					end
				end					

			end
		end
		if Gun:FindFirstChild("SightNode") then
			if not Gun.SightNode:FindFirstChild("AimOrder") then
				Gun:SetAttribute("SightOffset", (Gun:GetAttribute("SightOffset") or 0) + 1)
			end
		end
		table.clear(modelAimParts)
		attnode:Destroy()
		model:Destroy()
	end
	if self.Gun and Gun ~= self.Gun then
		self.Gun = Gun
	elseif self.Gun == nil then 
		self.GunModel = Gun
	end
	if typeAtt then
		if typeAtt.postAttach then
			typeAtt.postAttach(self,Gun,S)
		end
	end
	if RunService:IsClient() and sendToServer ~= false then
		local newAttachment = RemoteService.fetch("Server","GetAttachmentSlot",Gun.Name,self.Slot)
		if newAttachment ~= self.Name then
			RemoteService.send("Server","SetAttachmentSlot",Gun.Name,self.Slot,self.Name)
		end
	end
	if RunService:IsServer() and (self.ExtraData.Magazine) then
		_G.ChangeMag(Gun,player,self.ExtraData.Magazine)
	end;
end


function Attachment.AddAttachmentToWeapon(WName,AttachName,offset)
	Attachment.AttachOffsets[AttachName] = offset
end
return Attachment