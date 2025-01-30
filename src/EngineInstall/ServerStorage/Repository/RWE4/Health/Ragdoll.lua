local Resources = require(game.ReplicatedStorage.Resources)
local RemoteService = Resources:LoadLibrary("RemoteService")
local RS = game:GetService("RunService")
local PhysicsService = game:GetService("PhysicsService")
local FastDelay = Resources:LoadLibrary("FastDelay")
local PseudoInstance = Resources:LoadLibrary("PseudoInstance")
local Typer = Resources:LoadLibrary("Typer")
local FastWait = Resources:LoadLibrary("FastWait")

-- Gravity that joint friction values were tuned under.
local REFERENCE_GRAVITY = 196.2

-- ReferenceMass values from mass of child part. Used to normalized "stiffness" for differently
-- sized avatars (with different mass).
local DEFAULT_MAX_FRICTION_TORQUE = 1 --500
local R6_HEAD_LIMITS = {
	UpperAngle = 30,
	TwistLowerAngle = -40,
	TwistUpperAngle = 40,
}

local R6_SHOULDER_LIMITS = {
	UpperAngle = 110,
	TwistLowerAngle = -85,
	TwistUpperAngle = 85,
}

local R6_HIP_LIMITS = {
	UpperAngle = 40,
	TwistLowerAngle = -5,
	TwistUpperAngle = 80,
}
return PseudoInstance:Register("Ragdoll",{
	
	Internals = {
		"Humanoid";
		"HRP";
		"RootPart";
		"Head";
		"CInstances";
		"JointTable";
		"RootJoint";
	};
	
	Properties = {
		Character = Typer.AssignSignature(2, Typer.OptionalInstanceOfClassModel, function(self, char)
			self:rawset("Character",char)
			if char then
				if char:FindFirstChildOfClass("Humanoid") then
					self.Humanoid = char:FindFirstChildOfClass("Humanoid")
					self.HRP = char:FindFirstChild("Torso")
					self.RootPart = char.PrimaryPart
					self.Head = char:FindFirstChild("Head")					
				end
				if game.Players:GetPlayerFromCharacter(char) then
					self.Player = game.Players:GetPlayerFromCharacter(char)
				end
			end
		end);
		
		Player = Typer.OptionalInstanceOfClassPlayer;
	};


	Methods = {
		Setup = function(self)
			local NewAttachmentRight = Instance.new("Attachment")
				NewAttachmentRight.Parent = self.Character["Right Leg"]
				NewAttachmentRight.Name = "RagdollAttachment"
				NewAttachmentRight.Position = Vector3.new(0, 1, 0)
				table.insert(self.CInstances,NewAttachmentRight)
					
				local NewAttachmentLeft = Instance.new("Attachment")
				NewAttachmentLeft.Parent = self.Character["Left Leg"]
				NewAttachmentLeft.Name = "RagdollAttachment"
				NewAttachmentLeft.Position = Vector3.new(0, 1, 0)
				table.insert(self.CInstances,NewAttachmentLeft)
				
					
				local WaistLeftAttachment = Instance.new("Attachment")
				WaistLeftAttachment.Parent = self.HRP
				WaistLeftAttachment.Name = "WaistLeftAttachment"
				WaistLeftAttachment.Position = Vector3.new(-0.5, -1, 0)
				table.insert(self.CInstances,WaistLeftAttachment)
				
				
				local WaistRightAttachment = Instance.new("Attachment")
				WaistRightAttachment.Parent = self.HRP
				WaistRightAttachment.Name = "WaistRightAttachment"
				WaistRightAttachment.Position = Vector3.new(0.5, -1, 0)
				table.insert(self.CInstances,WaistRightAttachment)
			
				local Parts = {
						["Right Arm"] = {{"BallSocketConstraint";true};{self.HRP.RightCollarAttachment, self.Character["Right Arm"].RightShoulderAttachment; -170, 170}},
						["Left Arm"] = {{"BallSocketConstraint";true};{self.HRP.LeftCollarAttachment, self.Character["Left Arm"].LeftShoulderAttachment; -170, 170}},
						["Left Leg"] = {{"BallSocketConstraint";true};{WaistLeftAttachment, NewAttachmentLeft; -170, 170}},
						["Right Leg"] = {{"BallSocketConstraint";true};{WaistRightAttachment, NewAttachmentRight;  -170, 170}},
				};	
				for i, v in pairs(Parts) do
					local Part = self.Character:FindFirstChild(i)
					if Part then
						local Constraint = Instance.new(v[1][1])
						Constraint.Parent = Part
						if Constraint:IsA("JointInstance") then
							Constraint.Part0 = v[2][1].Parent
							Constraint.Part1 = v[2][2].Parent	
						elseif not Constraint:IsA("JointInstance") then
							Constraint.Attachment0 = v[2][1]
							Constraint.Attachment1 = v[2][2]
							Constraint.LimitsEnabled = v[1][2] or true
							if Constraint:IsA("BallSocketConstraint") then
								Constraint.TwistLimitsEnabled = Constraint.LimitsEnabled
								if Constraint.TwistLimitsEnabled then
									Constraint.TwistLowerAngle = v[2][3]
									Constraint.TwistUpperAngle = v[2][4]
								end
								local maxFrictionTorque = self:GetMaxFrictionTorque(Part)
								Constraint.MaxFrictionTorque = maxFrictionTorque
								
							else
								Constraint.LowerAngle = v[2][3]
								Constraint.UpperAngle = v[2][4]
							end
			
							
						end
						if Part ~= self.Character.PrimaryPart then
							self:MakeLimbCollidable(Part)
						end
						Constraint.Enabled = false				
						table.insert(self.CInstances,Constraint)
					end
				end
				for i, v in ipairs(self.CInstances) do
					if typeof(v) == "Instance" then
						self.Janitor:Add(v,"Destroy","Joint"..i)
					end
				end			
		end; 
		MakeLimbCollidable = function(self, limb)
			if limb:IsA("BasePart") and (limb.Name:find("Arm")  or limb.Name:find("Leg")) then
				local limbCollider = Instance.new("Part")
				limbCollider.Name = "LimbCollider"
				limbCollider.Shape = Enum.PartType.Cylinder
				limbCollider.Size = Vector3.new(1,1.3,1)
				limbCollider.Transparency = 1;
				limbCollider.CFrame = limb.CFrame
				limbCollider.CanCollide = false
				local limbCW = Instance.new("Motor6D")
				limbCW.Part0 = limb
				limbCW.Part1 = limbCollider
				limbCW.C0 = CFrame.Angles(0,0,math.pi/2) * CFrame.new(-0.4,0,0)
				limbCollider.Parent = limb
				limbCW.Parent = limb
				self.Janitor:Add(limbCollider)
				self.Janitor:Add(limbCW)
			end			
		end;
		
		GetMaxFrictionTorque = function(self, part)
			local limits 
			if part.Name:find("Leg") then
				limits = R6_HIP_LIMITS
			elseif part.Name:find("Arm") then
				limits = R6_SHOULDER_LIMITS
			else
				limits = R6_HEAD_LIMITS	
			end
			local gravityScale = workspace.Gravity / REFERENCE_GRAVITY
			local referenceMass = limits.ReferenceMass
			local massScale = referenceMass and (part:GetMass() / referenceMass) or 1
			local maxTorque = limits.FrictionTorque or DEFAULT_MAX_FRICTION_TORQUE
			return maxTorque * massScale * gravityScale 
		end;
		
		Revive = function(self)
			

			if self.HRP and self.HRP:CanSetNetworkOwnership() and self.Player then
					self.HRP:SetNetworkOwner(self.Player)
			end
			for i, v in ipairs(self.CInstances) do
				if v:IsA("BallSocketConstraint") then
					v.Enabled = false
				elseif v:IsA("WeldConstraint") then
					v.Enabled = false
				elseif v:IsA("NoCollisionConstraint") then
					v:Destroy()
				end
			end;
			
			
			for i, v in ipairs(self.Character:GetChildren()) do
				if v:IsA("BasePart") and self.Player then
					v:SetNetworkOwner(self.Player)
				end
			end

			for _, n in ipairs({"Left Hip";"Right Hip";"Left Shoulder";"Right Shoulder"}) do
				local joint = self.HRP:FindFirstChild(n)
				if joint then
					joint.Enabled = true
				end
			end	
			
			local Humanoid = self.Humanoid
			Humanoid.WalkSpeed = 16
			Humanoid.Jump = true
			if not self.Player then
				Humanoid.AutoRotate = true	
			end

			if RS:IsServer() then self.Character.Parent = (self.Player) and workspace or workspace.Mobs end
			game.CollectionService:RemoveTag(self.Character,"Ragdoll")
			for _, v in ipairs(self.Character:GetChildren()) do
				if v:IsA("BasePart") then
					v.CanCollide = true;
				end
			end
			Humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp,true)
			self.Character:SetPrimaryPartCFrame(self.RootPart.CFrame + Vector3.new(0,4,0))
			
			Humanoid:ChangeState("GettingUp")
		end;
		
		Ragdoll = function(self, dontremove)
			if RS:IsServer() then
				if self.HRP and self.HRP:CanSetNetworkOwnership() and self.Player then
						self.HRP:SetNetworkOwner(self.Player)
				end
				if dontremove then
					self.Humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp,false)
					self.Humanoid:ChangeState("Ragdoll")
					if not self.Player then self.HRP.AssemblyLinearVelocity = self.HRP.CFrame:vectorToWorldSpace(Vector3.new(0,-5,5)) end
					FastWait(1.5)
				end
				if self.RootPart then
					local ncc = Instance.new("NoCollisionConstraint")
					ncc.Name = "RagdollColl"
					ncc.Part0 = self.RootPart
					ncc.Part1 = self.HRP
					ncc.Parent = self.Character
					table.insert(self.CInstances,ncc)
				end
				if  self.Player then
					for i, v in ipairs(self.Character:GetChildren()) do
						if v:IsA("BasePart") then
							v:SetNetworkOwner(nil)
						end
					end
					
				end
					for i, v in ipairs(self.Character:GetDescendants()) do
						if v:IsA("BasePart") and v.Name == "LimbCollider" then
							v.CanCollide = true
						end
					end
				for _, model in ipairs(self.Character:GetChildren()) do
					if model:FindFirstChild("HoldPart")  then
						if self.Player and self.Player:IsA("Player") then 
							model.Parent = self.Player
							continue
						end
						model:Destroy()
					end
				end
				for _, n in ipairs({"Left Hip";"Right Hip";"Left Shoulder";"Right Shoulder";}) do
					local joint = self.HRP:FindFirstChild(n)
					if joint then
						joint.Enabled = false
					end
				end	
				
				FastDelay(0,function()
					for _, v in next, self.Character:GetDescendants() do
						if v:IsA'Sound' then
							v:Destroy()
						elseif v:IsA("Constraint") then
							v.Enabled = true
						end
					end	
				end)
				
				
				local Humanoid = self.Humanoid
				Humanoid.WalkSpeed = 0
				if not self.Player then
					Humanoid.AutoRotate = false
				end
				Humanoid.WalkToPoint = Vector3.new()
				game.CollectionService:AddTag(self.Character,"Ragdoll")
				if (not dontremove)  then
					self.Character.Parent = workspace.CorpseIgnore	
					FastDelay(6,function()
						if self.Character then
							self.Character:Destroy()
						end
					end)
				end	
			end
		end;
		
	};
	
	Call = function(self,dontremove)
		self:Ragdoll(dontremove)
	end;
	
	Init = function(self,character)
		self.CInstances = {};
		self.JointTable = {};
		if character then
			self.Character = character;
		end
		self:superinit()
	end;
})
