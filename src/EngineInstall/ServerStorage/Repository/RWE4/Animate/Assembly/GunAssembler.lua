local Resources = require(game.ReplicatedStorage.Resources)
local Typer = Resources:LoadLibrary("Typer")
local Make = Resources:LoadLibrary("Make")
local PseudoInstance = Resources:LoadLibrary("PseudoInstance")
local inList = Resources:LoadLibrary("inList")
local Joint = Resources:LoadLibrary("Joint")
local AttachmentsList = Resources:LoadConfiguration("Attachment")
local WeapBuilder = Resources:LoadLibrary("WeapBuilder")
local Furnitures = Resources:LoadConfiguration("Furniture")
local Furniture = Resources:LoadLibrary("Furniture")
local Attachment = Resources:LoadLibrary("Attachment")
local Magazines = Resources:LoadConfiguration("Magazine")
local RunService = game:GetService("RunService")
local CF = CFrame.new
local CFANG = CFrame.Angles
local RAD = math.rad
local AssemblyInfo = Resources:LoadConfiguration("GunAssemblyInfo")
local WeaponUtils = Resources:LoadLibrary("WeaponUtils")
local AA = Resources:LoadLibrary("AbstractAssembler")

local ModelHelpers = {
	["MagPoint"] = function(model,Handle,opts)
		local item = Handle.Parent
		local function isSpringPart(v)
			return (not inList(v.Name,{
				"SpringPiston";
			})) and not v.Name:find("SpringLeg")
		end
		for _, v in ipairs(model:GetChildren()) do
			if v:IsA("BasePart") and  not isSpringPart(v) then
				if v.Name:find("SpringLeg") then
					local springLegLabel = v.Name:match("SpringLeg(%a+)")
					if springLegLabel then
						local springLegWeld = Joint("AssembleParent",model.SpringBase,v,CF(),model.SpringJoints,("SpringLJoint"..springLegLabel))
						local originalSize = Instance.new("Vector3Value")
						originalSize.Name = "OriginalSize"
						originalSize.Value = v.Size
						originalSize.Parent = v
						v.Anchored = false
					end
				elseif v.Name == "SpringPiston" then
					local springPistonWeld = Joint("AssembleParent",model.SpringBase,v,CF(),model.SpringJoints,"SpringPistonJoint")
					v.Anchored = false
				end
			elseif v:IsA("BasePart") and v.Name ~= "Main" then
				local origCF = v.CFrame
				local oCV = Instance.new("CFrameValue")
				oCV.Name = "origCF"
				oCV.Value = Handle.CFrame:toObjectSpace(origCF)
				oCV.Parent = v
				local w = Joint("Assemble",opts.isDBShotgun and item.ReceiverHinge or model.PrimaryPart,v,CF(),"MagPAttachment")
				v.Anchored = false
				v.CanCollide = false
			end
		end	
		local function getMagMain(opts)
			if opts.isRevolver then
				return item:FindFirstChild("CarouselCylinder")
			elseif item:FindFirstChild("MagSlide") then
				return item.MagSlide
			elseif opts.isDBShotgun then
				return item.ReceiverHinge
			else
				return Handle
			end
		end
		local magPointA = Joint("Assemble",getMagMain(opts),model.PrimaryPart,CF(),"MagPointWeld")
		model.PrimaryPart.Anchored = false
		model.PrimaryPart.CanCollide = false	
	end; 
	["MagPointB"] = function(model,Handle,opts)
		local item = Handle.Parent
		for _, v in ipairs(model:GetChildren()) do
			if v:IsA("BasePart") and v.Name ~= "Main" then
				local w = Joint("Assemble",model.PrimaryPart,v,CF(),"MagPAttachment")
				v.Anchored = false
				v.CanCollide = false
			end
		end	
		local function getMagMain(opts)
			if opts.isRevolver then
				return item:FindFirstChild("CarouselCylinder")
			elseif item:FindFirstChild("MagSlide") then
				return item.MagSlide
			else
				return Handle
			end
		end
		local magPointA = Joint("Assemble",getMagMain(opts),model.PrimaryPart,CF(),"MagPointWeld")
		model.PrimaryPart.Anchored = false
		model.PrimaryPart.CanCollide = false	
	end; 
	["ShellStorage"] = function(model,Handle,opts)
		local item = Handle.Parent
		for _, v in ipairs(model:GetChildren()) do
			if v:IsA("BasePart") and v ~= model.PrimaryPart then
				local w = Joint("Assemble",model.PrimaryPart,v,CF(),"ShellStorageAttachment")
				v.Anchored = false
				v.CanCollide = false
			end
		end	
		local function getMagMain(opts)
			return Handle
		end
		local magPointA = Joint("Assemble",getMagMain(opts),model.PrimaryPart,CF(),"ShellStorageWeld")
		model.PrimaryPart.Anchored = false
		model.PrimaryPart.CanCollide = false	
	end;
	["Sling"] = function(model,Handle,opts)
		local item = Handle.Parent
		for _, v in ipairs(model:GetChildren()) do
			if v:IsA("BasePart") then
				local w = Joint("Assemble",Handle,v,CF(),"SlingWeld")
				v.Anchored = false
				v.CanCollide = false
			end
		end
		local slingRope = Joint("AssembleSling",model.SlingA,model.SlingB,opts.Sling,item,"MainSling")

	end;
	["Grenade"] = function(model,Handle,opts)
		local item = Handle.Parent
		for _, v in ipairs(model:GetChildren()) do				
			if v:IsA("BasePart") and v.Name ~= "Main" then
				local origCF = v.CFrame
				local oCV = Instance.new("CFrameValue")
				oCV.Name = "origCF"
				oCV.Value = Handle.CFrame:toObjectSpace(origCF)
				oCV.Parent = v
				local w = Joint("Assemble",opts.isDBShotgun and item.ReceiverHinge or model.PrimaryPart,v,CF(),"MagPAttachment")
				v.Anchored = false
				v.CanCollide = false
			end
		end	
		local function getMagMain(opts)
			return item.NadeIPoint
		end
		local magPointA = Joint("Assemble",getMagMain(opts),model.PrimaryPart,CF(),"MagPointWeld")
		model.PrimaryPart.Anchored = false
		model.PrimaryPart.CanCollide = false	
	end; 
}
local ItemAssembler = PseudoInstance:Register("GunAssembler",{
	Properties = {
		BoltWelds = Typer.EmptyTableOrDictionaryOfInstancesWhichIsAJointInstance;
		BoltPCF = Typer.EmptyTableOrTable;
	};

	Methods = {
		addBolt = function(self,bolt,slidepart,bolte)
			if bolt:FindFirstChild("BoltRole") then
				if bolt.BoltRole:IsA("StringValue") then
					if bolt.Name == "Bolt" then
						bolt.Anchored = true
						local bRole = bolt.BoltRole.Value
						local cond = true
						if bolte then
							if bolte:FindFirstChild("BoltRole") then
								cond = bolte.BoltRole.Value == bRole
							end
						end
						self.BoltWelds[bRole] = Joint("Assemble",(cond and bolte or slidepart),bolt,CF(),"BoltWeld")
						bolt.Anchored = false
					end
				end
			end
		end;
		findBolt = function(self, sm, role)
			local result = nil
			for _, gunPart in ipairs(sm:GetChildren()) do
				if gunPart:IsA("BasePart") then
					if gunPart.Name == "Bolt" then
						if gunPart:FindFirstChild("BoltRole") then
							if gunPart.BoltRole.Value == role then
								result = gunPart
							end
						end
					end	
				end
			end
			return result
		end;
		makeSheatheWeld = function(self, item ,Torso,LLeg,RLeg)
			local SW = Instance.new("Motor6D")
			SW.Name = "SheatheWeld"
			local S = require(item.SETTINGS)
			local guntype = S.sheatheSettings.gunProfile
			local weldmode = S.sheatheSettings.weldProfile
			local distance = S.sheatheSettings.CFrameSettings.position
			local rotation = S.sheatheSettings.CFrameSettings.rotation
			local y = S.sheatheSettings.CFrameSettings.y
			local x = S.sheatheSettings.CFrameSettings.x
			local SPPart 
			if guntype == 1 or guntype == 2 then
				SW.Part0 = Torso
				SPPart = Torso
			elseif guntype == 3 or guntype == 4 then
				if weldmode == 1 then
					SW.Part0 = RLeg
					SPPart = RLeg
				elseif weldmode == 2 then
					SW.Part0 = LLeg
					SPPart = LLeg
				elseif weldmode == 3 or weldmode == 4  then
					SW.Part0 = Torso	
					SPPart = Torso			
				end
			end
			SW.Parent = SPPart
			self.sheatheWeld = SW
		end;
		destroySheatheModel = function(self)
			self.sheatheModel:Destroy()
			self.sheatheWeld:Destroy()
		end;
		GetAssemblyTable = function(self, item, part,  sType)
			sType = sType or WeaponUtils:GetSubType(item)
			local tab
			for _, newTab in ipairs(AssemblyInfo.Specials) do
				if part.Name == newTab.PartName then
					if newTab.Condition(item, part, self.WeapBuilder.S,sType) then
						tab = newTab
						break;
					end
				end
			end
			return tab
		end,
		Assemble = function(self, item, extras)
			local Type = item:FindFirstChild("Type") 
			if not Type then return end
			do
				if Type.Value == "Gun" or Type.Value == "Launcher" then
					if self.sheatheModel then
						if self.sheatheModel:FindFirstChild("Origin") then
							self.sheatheModel.Origin.Value:SetAttribute("Taken", false)
						end
						self.sheatheModel:Destroy()
					end
					self.WeapBuilder.Weapon = item
					if extras.attachments then
						for slot,attachmentName in pairs(extras.attachments) do
							local newAttachment = AttachmentsList[attachmentName.Name]
							if newAttachment and  inList(slot,{"Bolt";}) then
								newAttachment:AddWeapon(item.Name)
								for _, v in ipairs(item:GetChildren()) do
									if v:HasTag("Bolt") and table.find({"Bolt";"BoltPart";"BoltEffector";}, v.Name) then
										v:Destroy()
									end
								end
								if not extras.player then
									newAttachment:ApplyAI(item,"HoldPart")
									continue
								end
								if extras.player then
									newAttachment:Apply(item,"HoldPart",extras.player,false,attachmentName.CFrame)
								end
							end
						end
					end
					local Handle = item:FindFirstChild("HoldPart") or item:FindFirstChild("Handle")
					for _, v in ipairs(item:GetChildren()) do
						if v:IsA("BasePart") and (not v:HasTag("AttachmentPart")) then
							if self.CFrames[v] then
								print(v.Name,"Pos:",self.CFrames[v])
								v.CFrame = Handle.CFrame * self.CFrames[v]
							end
							if inList(v.Name,self.WeapBuilder.WeldedParts) then
								for  _, v2 in ipairs(v:GetChildren()) do
									if v2:IsA("JointInstance") then
										v2:Destroy()
									end
								end
							end
							v.Anchored = true
						end
					end
					if item.Type.Value == "Launcher" then
						if item:FindFirstChild("Grenade") then
							item.Grenade:Destroy()
						end
					end  
					if item:FindFirstChild("MagPointNode") then
						if item:FindFirstChild("MagPoint") then
							item.MagPoint:Destroy()
						end
					end  
					if item:FindFirstChild("MagPoint") then
						for _, v in ipairs(item.MagPoint:GetChildren()) do
							if v:IsA("BasePart") and v:FindFirstChild("origCF") then
								v.CFrame = Handle.CFrame * v.origCF.Value
								v.origCF:Destroy()
							end
						end
					end
					local sType = WeaponUtils:GetSubType(item)
					if extras.attachments then
						for slot,attachmentName in pairs(extras.attachments) do
							local newAttachment = AttachmentsList[attachmentName.Name]
							if newAttachment and  inList(slot,{"Stock";"Optics"}) then
								newAttachment:AddWeapon(item.Name)
								if not extras.player then
									newAttachment:ApplyAI(item,"HoldPart")
									continue
								end
								if extras.player then
									newAttachment:Apply(item,"HoldPart",extras.player,false,attachmentName.CFrame)
								end
							end
						end
					end
					if item.Type.Value == "Gun" then 
						for _, v in ipairs(item.SlidePart:GetChildren()) do
							if v:IsA("JointInstance") and ( v:HasTag("AttachmentPart")) then
								if v.Part1:HasTag("Bolt") and table.find({"Bolt";"BoltPart";"BoltEffector";}, v.Part1.Name) then
									v:Destroy()
								end
								v.Anchored = true
							end
						end
					end
					for _, v in ipairs(item:GetChildren()) do
						if v:IsA("BasePart") then
							self.CFrames[v] = Handle.CFrame:toObjectSpace(v.CFrame)
							if  sType then
								local tab = self:GetAssemblyTable(item, v, sType)
								if tab then
									tab.OnAssemble(item,v,Joint,function(...)
										self:addBolt(...)
									end,self.WeapBuilder.S,function(...)
										return self:findBolt(...)
									end)
								else
									if v.Name ~= "HoldPart" and ((not v:FindFirstChild("AttachmentJointRef") and not v:FindFirstChild("Part0V")) or true) then
										v.Anchored = true
										v.CanCollide = false
										local wPart = Handle
										if v:FindFirstChild("WeldToStock") then
											wPart = item.Stock
										end
										if v:FindFirstChild("ReceiverAttach") and item:FindFirstChild("Receiver") then
											wPart = item.Receiver
										end
										if v.Name == "SafetyEffector" or v.Name == "SelectorEffector" then
											if v:FindFirstChild("BoltRole") then
												wPart = self:findBolt(item,v.BoltRole.Value)
											end
										elseif v.Name == "SafetySlide" then
											if self.WeapBuilder.S.boltSettings.weldSafetySlideToBolt then
												if v:FindFirstChild("BoltRole") then
													wPart = self:findBolt(item, v.BoltRole.Value)
												end
											end
										elseif v.Name:find("MainSight")  then
											if item:FindFirstChild("BarrelReleaseHinge") and self.WeapBuilder.S.weldSightToBarrel  then
												wPart = item.ReceiverHinge
											end				
										elseif v.Name == "RailPart"  then
											if item:FindFirstChild("BarrelReleaseHinge") and self.WeapBuilder.S.weldRailToBarrel  then
												wPart = item.ReceiverHinge
											end				
										elseif v.Name == "MainBarrel"  then
											if item:FindFirstChild("BarrelReleaseHinge") and  item:FindFirstChild("ReceiverHinge") then
												wPart = item.ReceiverHinge
											end	
										elseif v.Name == "EjectorSlide"  then
											wPart = item.MainBarrel
										elseif v.Name == "Handguard" then
											if item:FindFirstChild("BarrelReleaseHinge") and  item:FindFirstChild("ReceiverHinge") then
												wPart = item.ReceiverHinge
											end	
										elseif v.Name == "LeftGrip" then
											if item:FindFirstChild("ForegripHandle") and v:GetAttribute("AttachToFG") then
												wPart = item.ForegripHandle
											end	
										end
										if sType == "Revolver" and v.Name:sub(1,3) == "Mag" and not v.Name:find("Case") then
											wPart = item.Carousel
										end
										local Weld = Joint("Assemble",wPart,v,CF(),"MainWeld")
										v.Anchored = false																																								
									end	
								end

							end					
						end
					end

					if extras then 
						if extras.attachments then
							for slot,attachmentName in pairs(extras.attachments) do
								local newAttachment = AttachmentsList[attachmentName.Name]
								if newAttachment and (slot == "MagPoint" or slot == "StorageLeft") then
									if not item:FindFirstChild("MagPoint") then
										newAttachment:AddWeapon(item.Name)
										if not extras.player then
											newAttachment:ApplyAI(item,"HoldPart")
											continue
										end
										newAttachment:Apply(item,"HoldPart",extras.player,false,attachmentName.CFrame)
									end
								
								end
							end
						end
					end
					for _, v in ipairs(item:GetChildren()) do
						if v:IsA("Model") then
							if ModelHelpers[v.Name] then
								local sType = WeaponUtils:GetSubType(item)
								ModelHelpers[v.Name](v,Handle,{
									isRevolver = sType == "Revolver";
									isDBShotgun = item:FindFirstChild("BarrelReleaseHinge");
									Sling = {
										Color = extras.slingColor or BrickColor.new("Brown");
										Length = 4.25;
										Thickness = 0.1;
									};
								})								
							end
						end
					end
					if item:FindFirstChild("Rounds") then
						for _, v in ipairs(item.Rounds:GetDescendants()) do
							if v:IsA("BasePart") then
								v.Anchored = false
							end
						end
					end
					if extras then 

						if extras.defaults then
							for _,attachmentName in pairs(extras.defaults) do
								local newAttachment = AttachmentsList[attachmentName]
								if newAttachment then
									if extras.attachments then
										if extras.attachments[newAttachment.Slot] then
											continue
										end
									end
									newAttachment:AddWeapon(item.Name)
									if (not item:FindFirstChild("Lid")) or newAttachment.Slot ~= "Optics"  then
										newAttachment:ApplyAI(item,"HoldPart")
									elseif (item:FindFirstChild("Lid") and newAttachment.Slot == "Optics") then
										newAttachment:ApplyAI(item,"Lid")
									end	
								end
							end
						end				
						if self.WeapBuilder.S.defaultAttachments then
							for _, attachmentName in ipairs(self.WeapBuilder.S.defaultAttachments) do
								local newAttachment = AttachmentsList[attachmentName]
								if newAttachment then
									if extras.attachments then
										if extras.attachments[newAttachment.Slot] then
											continue
										end
									end
									newAttachment:AddWeapon(item.Name)
									if (not item:FindFirstChild("Lid")) or newAttachment.Slot ~= "Optics"  then
										newAttachment:Apply(item,"HoldPart",extras.player or false,false,CF(),true)
									elseif (item:FindFirstChild("Lid") and newAttachment.Slot == "Optics") then
										newAttachment:Apply(item,"Lid",extras.player or false,false,CF(),true)
									end	
								end
							end
						end		
						if extras.attachments then
							for slot,attachmentName in pairs(extras.attachments) do
								local newAttachment = AttachmentsList[attachmentName.Name]
								if newAttachment and not inList(slot,{"MagPoint";"StorageLeft";"Stock";"Bolt";"Optics"}) then
									newAttachment:AddWeapon(item.Name)
									if not extras.player then
										if (not item:FindFirstChild("Lid")) or slot ~= "Optics"  then
											newAttachment:ApplyAI(item,"HoldPart")
										elseif (item:FindFirstChild("Lid") and slot == "Optics") then
											newAttachment:ApplyAI(item,"Lid")
										end	
										continue
									end
									if extras.player then
										if (not item:FindFirstChild("Lid")) or slot ~= "Optics"  then
											newAttachment:Apply(item,"HoldPart",extras.player,false,attachmentName.CFrame)
										elseif (item:FindFirstChild("Lid") and slot == "Optics") then
											newAttachment:Apply(item,"Lid",extras.player,false,attachmentName.CFrame)
										end	
									end

								end
							end
						end
						if extras.furniture then
							if Furnitures[extras.furniture] then
								Furnitures[extras.furniture]:Apply(item)
							end
						end
						if extras.alloy then
							if Furnitures[extras.alloy] then
								Furnitures[extras.alloy]:Apply(item)
							end
						end	
						if item:FindFirstChild("Rounds") then
							for _, v in ipairs(item.Rounds:GetDescendants()) do
								if v:IsA("BasePart") then
									v.Anchored = false
								end
							end
						end
						task.spawn(function()
							local timeout = 20
							local t = 0
							repeat t +=  task.wait(1) if t >= timeout then break end until item:IsDescendantOf(workspace)
							if item:IsDescendantOf(workspace) then
								for _, v in item:GetChildren() do
									for  _, v2 in (v:GetChildren()) do
										if v2:IsA("JointInstance") then
											if not v2.Active then
												v2:Destroy()
											end
										end
									end
								end
							end
						end)
					
					end	

				end
				item.HoldPart.Anchored = false
			end
		end;
		getSheatheData = function(self, Character, item)
			if item then
				local SheatheData do
					for _, sp in Character:GetDescendants() do
						if sp:IsA("BasePart") and sp.Name == "SheathePoint" then
							local slot = sp:GetAttribute("Type")
							if slot == item.Type.Value then
								if sp:GetAttribute("Whitelist") then
									local l = sp:GetAttribute("Whitelist")
									l = string.split(l,",")
									local typeVal : StringValue = item:FindFirstChild(slot .. "Type")
									if not table.find(l, typeVal.Value) then
										continue
									end
									if sp:GetAttribute("Taken") then
										continue
									end
									SheatheData = sp
								end
							end
						end
					end
				end					
				return SheatheData
			end
			return nil
		end,
		sheathe = function(self, Character, item, extras)
			if not Character:FindFirstChild("SheathedWeapons") then
				return
			end
			local dat = self:getSheatheData(Character, item)
			if dat then
				dat:SetAttribute("Taken", true)
				local part = dat
				if part and part:IsA("BasePart") then
					self.sheatheModel = Resources:GetItem(item.Name):Clone()
					local Handle = item:FindFirstChild("HoldPart") or item:FindFirstChild("Handle")
					for _, v in ipairs(self.sheatheModel:GetChildren()) do
						if v:IsA("Model") then
							if ModelHelpers[v.Name] then
								if self.sheatheModel:FindFirstChild("GunType") then
									ModelHelpers[v.Name](v,Handle,{
										isRevolver = self.sheatheModel.GunType.Value == "Revolver";
										isDBShotgun = self.sheatheModel:FindFirstChild("BarrelReleaseHinge");
									})								
								end
							end	
						end
					end
					if extras.attachments then
						for slot,attachmentName in pairs(extras.attachments) do
							local newAttachment = AttachmentsList[attachmentName.Name]
							if newAttachment and not inList(slot,{"MagPoint";"StorageLeft";"Stock";}) then
								newAttachment:AddWeapon(self.sheatheModel.Name)
								if not extras.player then
									if (not self.sheatheModel:FindFirstChild("Lid")) or slot ~= "Optics"  then
										newAttachment:ApplyAI(self.sheatheModel,"HoldPart")
									elseif (self.sheatheModel:FindFirstChild("Lid") and slot == "Optics") then
										newAttachment:ApplyAI(self.sheatheModel,"Lid")
									end	
									continue
								end
								if extras.player then
									if (not self.sheatheModel:FindFirstChild("Lid")) or slot ~= "Optics"  then
										newAttachment:Apply(self.sheatheModel,"HoldPart",extras.player,false,attachmentName.CFrame)
									elseif (self.sheatheModel:FindFirstChild("Lid") and slot == "Optics") then
										newAttachment:Apply(self.sheatheModel,"Lid",extras.player,false,attachmentName.CFrame)
									end	
								end

							end
						end
					end
					if extras.defaults then
						for _,attachmentName in pairs(extras.defaults) do
							local newAttachment = AttachmentsList[attachmentName]
							if newAttachment then
								if extras.attachments then
									if extras.attachments[newAttachment.Slot] then
										continue
									end
								end
								newAttachment:AddWeapon(self.sheatheModel.Name)
								if (not self.sheatheModel:FindFirstChild("Lid")) or newAttachment.Slot ~= "Optics"  then
									newAttachment:ApplyAI(self.sheatheModel,"HoldPart")
								elseif (self.sheatheModel:FindFirstChild("Lid") and newAttachment.Slot == "Optics") then
									newAttachment:ApplyAI(self.sheatheModel,"Lid")
								end	
							end
						end
					end
					for _, Obj in self.sheatheModel:GetChildren() do
						if Obj:IsA("BasePart") and Obj ~= self.sheatheModel.PrimaryPart  then
							Obj.Anchored  = true				
							local Weld = Joint("Assemble",self.sheatheModel.HoldPart,Obj,CF(),"MainWeld")
							Obj.Anchored = false
							Obj.CanCollide = false
						end
					end
					self.sheatheModel.Parent = Character.SheathedWeapons
					local dcf = dat.CFrame
					local S = require(self.sheatheModel.SETTINGS)
					if S.sheatheSettings then
						if S.sheatheSettings.offset then
							dcf += S.sheatheSettings.offset
						end
					end
					self.sheatheModel:SetPrimaryPartCFrame(dcf)
					self.sheatheWeld = Joint("AssembleC", part, self.sheatheModel.HoldPart, dcf, CF(), "MainWeld")
					self.sheatheModel.PrimaryPart.Anchored  = false
					self.sheatheModel.HoldPart.CanCollide = false
					local sheatheVal = Instance.new("ObjectValue")
					sheatheVal.Name = "Origin"
					sheatheVal.Value = dat
					sheatheVal.Parent = self.sheatheModel
					if item:GetAttribute("MagType") then
						local player = game.Players:GetPlayerFromCharacter(Character)
						self.sheatheModel:SetAttribute("MagType", item:GetAttribute("MagType"))
						self.sheatheModel:SetAttribute("ClipSize", item:GetAttribute("ClipSize"))
						self.sheatheModel:SetAttribute("Ammo", item:GetAttribute("Ammo"))
						self.sheatheModel:SetAttribute("Mags", item:GetAttribute("Mags"))
						self.sheatheModel:SetAttribute("AmmoInd", item:GetAttribute("AmmoInd"))
						self.sheatheModel:SetAttribute("GaugeIndex", item:GetAttribute("GaugeIndex"))
						local magNew = Magazines[item:GetAttribute("MagType")]
						if magNew and player then
							local mag = magNew:getMag(true, player)
							magNew:ApplyFake(self.sheatheModel, mag, player)	
						end	
					end
					if item:FindFirstChild("Rounds") then
						for _, v in ipairs(self.sheatheModel.Rounds:GetDescendants()) do
							if v:IsA("BasePart") then
								v.Anchored = false
							end
						end
					end
				end
			end
		end;	
	};
	Call = function(self,...)
		self:Assemble(...)
	end;
	Init = function(self,lType)
		self.WeapBuilder = WeapBuilder.new(lType or "Gun",{
			"SlidePart";
			"PumpPart";
			"LidHinge";
			"Lid";
			"Bolt";
			"BoltEffector";
			"LidEffector";
			"EjectionRod";
			"CarouselCylinder";
			"CylinderHinge";
			"CylinderEffector";
			"CylinderUnitEffector";
			"CylinderUnitHinge";
			"CarryHandleEffector";
			"CarryHandleHinge";
			"CarryHandle";
			"Hammer";
			"HammerHinge";
			"HammerEffector";
			"DumpPart";
			"EjectionRodSlide";
			"StockMain";
			"StockHinge";
			"Stock";
			"StockPart";
			"StockSlide";
			"BipodMain";
			"BipodYHinge";
			"MainSightHinge";
			"MainSightEffector";
			"MainSightLeaf";
			"MainSightLeafPart";
			"MainSightLeafCylinder";
			"BipodLeftHinge";
			"BipodLeftEffector";
			"BipodRightEffector";
			"RightBipodEffector";
			"LeftBipodEffector";
			"LeftBipodHinge";
			"LeftBipodLeg";
			"RightBipodLeg";			
			"RightBipodHinge";
			"HoldPart";
			"SelectorHinge";
			"FireModeSwitch";
			"SafetyHinge";
			"SafetySwitch";
			"SafetySlide";
			"SafetySwitchTab";
			"SelectFireTab";		
			"SelectorEffector";
			"SafetyEffector";	
			"CoverHinge";
			"CoverEffector";
			"EjectionCover";
			"TriggerHinge";
			"TriggerSear";
			"Trigger";	
			"PaddleReleaseHinge";
			"PaddleRelease";	
			"Receiver";
			"TriggerEffector";
			"PaddleReleaseEffector";
			"ReceiverEffector";
			"ReceiverHinge";
			"EjectorSlide";
			"MagnificationHinge";
			"BayonetEffector";
			"BayonetHinge";
			"BayonetBlade";
			"AccessDoorHinge";
			"AccessDoorEffector";
			"ForwardAssistBase";
			"NadeBarrelHinge";
			"NadePoint";
			"NadeBarrel";
			"NadeIPoint";
			"NadeBarrelEffector";
			"Breach";
		})
		self:rawset("BoltWelds",{});

		self:rawset("CFrames",{});

		self:superinit()
	end;
}, AA)

return ItemAssembler;