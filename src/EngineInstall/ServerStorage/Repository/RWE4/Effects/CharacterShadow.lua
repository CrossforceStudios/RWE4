------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @CloneTrooper1019's First Person Shadows, RoStrap edition
-- Created in 2016
-- Modularized and updated 2019 by @Aerodos12
-- renders shadows in first person
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local Resources = require(game.ReplicatedStorage.Resources)
local Janitor = Resources:LoadLibrary("Janitor")
local spawn = Resources:LoadLibrary("FastSpawn")
local PseudoInstance = Resources:LoadLibrary("PseudoInstance")
local Typer = Resources:LoadLibrary("Typer")
local Lighting = game:GetService("Lighting")
local AU = Resources:LoadLibrary("AngleUtils")
local Components = Resources:GetLocalTable("Components")
local ignore = {
	"SlingA";
	"SlingB";
	"ShellMain";	
	"MagCase";
	"Cap";
	"Case";
	"Primer";
	"MagLink";
	"MagHollowSpitzer";
	"MagSlide";
	"MagSlidePart";
	"RocketCharge";
	"RocketFrontBand";
	"Wing1";
	"Wing2";
	"Wing3";
	"Wing4";
	"Wing5";
	"Wing6";
	"WingEffector1";
	"WingEffector2";
	"WingEffector3";
	"WingEffector4";
	"WingEffector5";
	"WingEffector6";
	"WingHinge1";
	"WingHinge2";
	"WingHinge3";
	"WingHinge4";
	"WingHinge5";
	"WingHinge6";
	"WingBase";
	"RoundMain";
	"Middle";
	"MagSpitzer";
	"MagPos";
	"PouchShadow";
}
return PseudoInstance:Register("CharacterShadow",{
	Internals = {
		"ProjectedChar";
		PartCount = 0;
		"Humanoid";
		"Hider";
		Parts = {};
		ViewModels = {};
		AddPart = function(self,child,model)
			if child.Transparency >= 1 and child.Name ~= "HumanoidRootPart" then
				return
			end
			if child:FindFirstAncestor("Magazines") then
				return
			end
			if child:FindFirstAncestor("SpringPortions") then
				return
			end
			if table.find(ignore,child.Name)  then
				return
			end	
			assert(Typer.InstanceWhichIsABasePart(child))
			self.PartCount = self.PartCount + 1
			child.Anchored = true
			local clone = child:Clone()
			clone.Name = clone.Name
			clone.Anchored = true
			child.Anchored = false
			for _,v in ipairs(clone:GetChildren()) do
				if v:IsA("JointInstance") then
					v:Destroy()
				end
			end
			if child:IsDescendantOf(self.Char) then
				if clone.Transparency <= 0.5 then
					clone.Transparency = 0
				end
			elseif child:FindFirstAncestor("gunIgnore_"..self.Player.Name) then
				if clone.Transparency < 1 then
					clone.Transparency = 0
				end
			end
			clone.Parent = self.ProjectedChar
			self.Janitor:Add(child.ChildAdded:connect(function (child2)
				if child2:IsA("SpecialMesh") then
					clone:ClearAllChildren()
					child2:Clone().Parent = clone
				end
			end),"Disconnect")
			self.Janitor:Add(clone,"Destroy","Part_"..self.PartCount)
			self.Parts[child] = clone;
		end;
		AddAccoutrement = function(self,child)
			self:AddPart(child.Handle)
		end;
		AddItemOrGear = function(self,child)
			for _, itemP in ipairs(child:GetChildren()) do
				if itemP:IsA("BasePart") and not table.find(ignore,itemP.Name)   then
					if itemP:FindFirstAncestor("Magazine") or itemP:FindFirstAncestor("Rounds") then
						continue
					end
					self:AddPart(itemP)

				end
			end
			self.Janitor:Add(child.Parent.ChildRemoved:Connect(function(child2)
				if child2 == child then
					for _, p in ipairs(child:GetChildren()) do
						if p:IsA("BasePart") and self.Parts[p] then
							self.Parts[p]:Destroy()
							self.Parts[p] = nil;
						end
					end
				end
			end),"Disconnect")			
		end;
		GetProjection = function(self)
			local sunPos = self:GetSunPosition()
			local focusPoint = self.Char.Head.CFrame.p
			local sunDist = (focusPoint - sunPos).magnitude
			local rootPart = self.Char:FindFirstChild("HumanoidRootPart")
			if rootPart then
				local projectorRoot = self.Parts[rootPart]
				if projectorRoot then
					local objCF = rootPart.CFrame
					local objPos = objCF.p
					local objRot = objCF - objPos
					local realDist = (focusPoint - objPos).magnitude
					local lerpScale = (realDist/sunDist) * 10
					local projectPos = focusPoint:lerp(sunPos,lerpScale)
					local camOffset = objPos - focusPoint
					return rootPart, projectorRoot, CFrame.new(projectPos + camOffset) * objRot, objCF
				end
			end
			return nil, nil, nil, nil
		end;
	};
	Properties = {
		Char = Typer.InstanceOfClassModel;
		CurrentCamera = Typer.OptionalInstanceOfClassCamera;
		Player = Typer.InstanceOfClassPlayer;
	};

	Methods = {
		AddObject = function(self,child)
			if child:IsA("BasePart") then
				self:AddPart(child)
			elseif child:IsA("Model") and child:FindFirstChild("HoldPart") then
				self:AddItemOrGear(child)
			elseif child:IsA("Model") and child:FindFirstChild("Middle") then
				self:AddItemOrGear(child)
			elseif child:IsA("Accoutrement") and child:FindFirstChild("Handle") then
				self:AddAccoutrement(child)
			end
		end;
		GetFocusDistance = function(self)
			local camCF = self.CurrentCamera.CFrame
			local camFoc = self.CurrentCamera.Focus
			local dist = (camFoc.p - camCF.p).Magnitude
			return dist
		end;
		GetSunCFrame = function(self)
			local lookingAtSun = AU.lookAt(self.CurrentCamera.CFrame.p,self:GetSunPosition())
			local relativeToSun = lookingAtSun:toObjectSpace(self.Char.Head.CFrame)
			return relativeToSun
		end;
		GetSunPosition = function(self)
			return Lighting:GetSunDirection()  * 10000
		end;
		Destroy = function(self)
			self.Janitor:Cleanup()
			self.Parts = {};
		end;
		InitShadow = function(self)
			if not self.Player:FindFirstChild("ShadowHolder") then
				local shadowH = Instance.new("Folder")
				shadowH.Name = "ShadowHolder"
				shadowH.Parent = self.Player
				self.Hider = shadowH
				self.Janitor:Add(self.Hider,"Destroy","Hider")
			else
				self.Hider = self.Player:FindFirstChild("ShadowHolder")
			end
			for _, charPart in self.Char:GetChildren() do
				self:AddObject(charPart)
			end
			self.Janitor:Add(self.Char.ChildAdded:Connect(function(charP)
				self:AddObject(charP)
			end),"Disconnect")
			for _, ViewModel in ipairs(self.ViewModels) do
				for _, charPart in ipairs(ViewModel:GetDescendants()) do
					if charPart:IsA("BasePart") then
						self:AddObject(charPart)
					end
				end
				self.Janitor:Add(ViewModel.DescendantAdded:Connect(function(charP)
					if charP:IsA("BasePart") then	
						self:AddObject(charP)
					end
				end),"Disconnect")
			end	
		end;
		AddViewModel = function(self,vm)
			self.ViewModels[#self.ViewModels+1] = vm
			for _, charPart in ipairs(vm:GetDescendants()) do
				if charPart:IsA("BasePart") then
					self:AddObject(charPart)
				end
			end
			self.Janitor:Add(vm.ChildAdded:Connect(function(charP)
				self:AddObject(charP)
			end),"Disconnect")
		end;
		Update = function(self, sit)
			local sunPos = self:GetSunPosition()
			if sunPos.Y > 0 and not sit then -- If the sun is actually out...
				local dist = self:GetFocusDistance()
				if self.Player == game.Players.LocalPlayer and Components.Camera.CurrentCamMode.Name:find("FirstPerson") ~= nil  then -- If we are near first person...
					local relativeToSun = self:GetSunCFrame()
					local facing = sunPos.Unit:Dot(self.CurrentCamera.CFrame.LookVector)
					if facing < 0  then -- If we are looking away from the sun...
						local rootPart, projectorRoot, projection, objCF = self:GetProjection(sunPos)
						-- Project the HumanoidRootPart towards the sun relative to the camera's position.
						if projection then
							projectorRoot.CFrame = projection
							-- CFrame all shadow limbs relative to the shadow HumanoidRootPart with an object space relative to their corresponding real offsets.
							for realObj,projectorObj in (self.Parts) do
								if realObj ~= rootPart and realObj:IsA("BasePart") then
									projectorObj.CFrame = projectorRoot.CFrame * objCF:toObjectSpace(realObj.CFrame)

								end
							end
							-- All conditions were met, render the shadow.
							self.ProjectedChar.Parent = workspace.ShadowIgnore
							return

						end
					end
				end
			end
			self.ProjectedChar.Parent = self.Hider
		end;
	};

	Init = function(self,char,player,viewModels)
		self.Char = char
		self.ProjectedChar = Instance.new("Model")
		self.ProjectedChar.Name = self.Char.Name.."_ProjectedShadow"
		self.Humanoid = Instance.new("Humanoid")
		self.Humanoid.Name = "Projector"
		self.Humanoid.Parent = self.ProjectedChar
		self.Humanoid.AutoRotate = false
		self.Humanoid:ChangeState("Physics")
		if viewModels then
			self.ViewModels = viewModels;
		end
		self.CurrentCamera = workspace.CurrentCamera;
		self.Janitor:Add(self.ProjectedChar)
		self.Player = player or game.Players.LocalPlayer
		self:superinit()
	end
})
