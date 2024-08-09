-- Description:

	-- A Module which heavily relies on 
	-- script.AnimationValues to retrieve
	-- animations and play them.
	
	-- This is a modularized version of the Animate
	-- script in the Character.  I made this
	-- so you won't have to copy the Animate script
	-- and edit it.  You can do a lot by script
	-- (see ConfigureWalkAnimation [EXAMPLE])
	

-- TODO:
	--2. FIX EMOTE CODE; SOMETIMES ERRORS 
	--	 (PROBABLY NOT DO THIS SINCE THERE 
	--   WILL MAY BE AN EMOTE WHEEL).
	--3. TOO MANY FUNCTIONS, SOON, I WILL DOCUMENT
	--4. MAKE MODULE COMPATIBLE WITH 
	--   NON-CHARACTERS.
	--6. TOOLS ACT A LITTLE WEIRD, BUT THEY DO
	--   THEIR JOB
-- COMPLETE:
	--1. FIX ERRORS WITH self.lastTick.
	--5. SOMETIMES FREE-FALL ANIMATION DOES
	--   NOT WORK.
	
-- Constant Values



local RunService = game:GetService("RunService")
-- AnimationValues
local Resources = require(game.ReplicatedStorage:WaitForChild("Resources",200))
local RemoteService = Resources:LoadLibrary("RemoteService")
local PseudoInstance = Resources:LoadLibrary("PseudoInstance")
local Typer = Resources:LoadLibrary("Typer")
local WPF = Resources:LoadLibrary("WeightedProbabilityFunction")
local AnimationValues = require(script:WaitForChild("AnimationValues"))
local fastSpawn = Resources:LoadLibrary("FastSpawn")
local globalAnimation = Instance.new("Animation")
local Animate = PseudoInstance:Register("Animate",{
	
	Internals = {
		"currentAnimInstance";
		"currentAnimTrack";
		"animTable";
		lastTick = 0;
		animNames = AnimationValues.animNames.R6;
		runningFunctionIf   = function(self, speed)
			if self.Figure:GetAttribute("Sprinting") then
				self:playAnimation("run", 0.1, self.Humanoid)
				self.CurrentAnimSpeed = speed / 21.5
			else
				self:playAnimation("walk", 0.1, self.Humanoid)
				self.CurrentAnimSpeed = speed / 14.5
			end
			
		end;
		runningFunctionElse = function(self)
			self:playAnimation("idle", 0.1, self.Humanoid)
		end;
		swimCheck = 0;
		toolAnim = "None";
		toolAnimTime = 0;
		"Animator";
		jumpMaxLimbVelocity = 0.75;
		toolTransitionTime = 0.1;
		fallTransitionTime = 0.3;	
		"toolAnimTrack";
		"toolAnimInstance";
		"ragdoll";
		rollAnimation = function(self,animName)
			return self.animTable[animName].animFinder()
		end;
		getTool = function(self)	
			if self.Figure then
				for _, child in ipairs(self.Figure:GetChildren()) do
					if child:FindFirstChild("HoldPart") then 
						return child 
					end
				end
			end
			
			return nil
		end;
		
		getToolAnim = function(self,tool)
			for _, child in ipairs(tool:GetChildren()) do
				if child.Name == "toolanim" and child:IsA("StringValue") then
					return child
				end
			end
			
			return
		end;
		animateTool = function(self)
			if self.toolAnim == "None" then
				self:playToolAnimation("toolnone", self.toolTransitionTime, self.Humanoid, Enum.AnimationPriority.Idle)
				return
			end
		end;	
	};
	
	Properties = {
		Torso = Typer.OptionalInstanceWhichIsABasePart;
		Humanoid = Typer.InstanceOfClassHumanoid;
		CurrentAnim = Typer.String;
		ToolAnim = Typer.String;
		CurrentAnimSpeed = Typer.AssignSignature(2, Typer.Number, function(self, speed)
			self:rawset("CurrentAnimSpeed",speed)
			self.currentAnimTrack:AdjustSpeed(speed)
		end);
		RunningCheck = Typer.Number;
		JumpAnimTime = Typer.Number;
		JumpAnimDuration = Typer.Number;
		Figure = Typer.AssignSignature(2, Typer.OptionalInstanceOfClassModel, function(self, fig)
			self:rawset("Figure",fig)
			self.Torso = fig:FindFirstChild("Torso") or fig:FindFirstChild("HumanoidRootPart")
			self.Humanoid 	  = fig:FindFirstChildOfClass("Humanoid");
			self.CurrentAnim = "";
		end);

	};
	
	Methods = {
		GetLastTick = function(self)
			return self.lastTick
		end;
		RandomInt = function(self, a, b)
			return Random.new(tick()):NextInteger(a, b)
		end;
		
		EndCurrentAnimTrack = function(self,TransitionTime)
			-- A function which ends the current
			-- animation
			self.currentAnimTrack:Stop(TransitionTime)
		end;
		GetAnim = function(self,Name)
			-- Returns animation according to current 
			-- animNames table (ex. animNames is for R6
			-- animations for a certain character)
			return self.animNames[Name]
		end;
		createAnimationSet = function(self, name, fileList)
			if self.animTable[name] then
				return
			end
			
			globalAnimation	= Instance.new("Animation")

			
			self.animTable[name] = {}
			self.animTable[name].count = 0
			self.animTable[name].totalWeight = 0	
			
			self.animTable[name].getTotalWeight = function(self)
				return self.totalWeight
			end
			self.animTable[name].getCount = function(self)
				return self.count
			end
			
			-- fallback to defaults
			if self.animTable[name].count <= 0 then
				local weightFinder = {}
				for idx, anim in pairs(fileList) do
					globalAnimation.AnimationId = anim.id
					
					
		--			print(idx, anim)
					self.animTable[name].anims = {};
					self.animTable[name].anims[idx] = {}
					self.animTable[name].anims[idx].anim  = self.Animator:LoadAnimation(globalAnimation)
					if anim.priority then
						self.animTable[name].anims[idx].anim.Priority = anim.priority
					end
					if anim.priority then
						self.animTable[name].anims[idx].anim.Priority = anim.priority
					end
					self.animTable[name].anims[idx].anim:AdjustWeight(anim.weight)
					weightFinder[self.animTable[name].anims[idx].anim] = anim.weight
					self.animTable[name].count = self.animTable[name].count + 1
					self.animTable[name].totalWeight = self.animTable[name].totalWeight + anim.weight
					self.Janitor:Add(self.animTable[name].anims[idx].anim,"Destroy",name.."Anim")
				end
				weightFinder = WPF.new(weightFinder)
				self.animTable[name].animFinder = weightFinder;
				weightFinder = nil 
			end
			globalAnimation:Destroy()
		end;
		setupAnimations = function(self)
			for name, fileList in pairs(self.animNames) do
				if type(fileList) ~= "function" then
					self:createAnimationSet(name, fileList)
				end
			end	
		end;
		stopAllAnimations = function(self)
			local oldAnim = self.CurrentAnim
		
		
			self.CurrentAnim = ""
			self.currentAnimInstance = nil
			self.Janitor:Remove("KeyframeHandler")
		
			if self.currentAnimTrack then
				self:EndCurrentAnimTrack()
			end
			
			return oldAnim
		end;
		stopToolAnimations = function(self)
			local oldAnim = self.toolAnim
		
			self.Janitor:Remove("KeyframeHandlerTool")
		
			self.toolAnim = ""
			self.toolAnimInstance = nil
			self.Janitor:Remove('toolAnim')
			if self.toolAnimTrack then
				self.toolAnimTrack:Stop()
			end
			return oldAnim
		end;	
		playAnimation = function(self, animName, transitionTime, humanoid) 
		--		print(animName .. " " .. idx .. " [" .. origRoll .. "]")
			if game.CollectionService:HasTag(self.Humanoid,"Unconscious") then 
				return
			end
			local anim = self:rollAnimation(animName)
		
			-- switch animation		
			if anim ~= self.currentAnimInstance then
				
				if self.currentAnimTrack then
					self.currentAnimTrack:Stop(transitionTime)
					self.Janitor:Remove("KeyframeHandler")
				end
		
			
				-- load it to the humanoid; get AnimationTrack
				self.currentAnimTrack = anim
				-- play the animation
				self.currentAnimTrack:Play(transitionTime)
				self.CurrentAnim = animName
				self.currentAnimInstance = anim
				self.CurrentAnimSpeed = 1.0

				-- set up keyframe name triggers
				
				self.Janitor:Add(self.currentAnimTrack.KeyframeReached:Connect(function(frameName)
					if frameName == "End" then
				
						local repeatAnim = self.CurrentAnim
						-- return to idle if finishing an emote
						
						local animSpeed = self.CurrentAnimSpeed
						self:playAnimation(repeatAnim, 0.0, self.Humanoid)
						self.CurrentAnimSpeed  = animSpeed
					end
				end),"Disconnect","KeyframeHandler")
				
			end
		end;
	playToolAnimation = function(self, animName, transitionTime, humanoid, priority)	 
	--		print(animName .. " * " .. idx .. " [" .. origRoll .. "]")
		local anim = self:rollAnimation(animName)
	
		if self.toolAnimInstance ~= anim then
				
			if self.toolAnimTrack then
				self.toolAnimTrack:Stop()
				self.Janitor:Remove("KeyframeHandlerTool")
				transitionTime = 0
			end
						
			-- load it to the humanoid; get AnimationTrack
			self.toolAnimTrack = anim
			-- play the animation
			self.toolAnimTrack:Play(transitionTime)
			self.toolAnim = animName
			self.toolAnimInstance = anim
			self.Janitor:Add(self.toolAnimTrack.KeyframeReached:Connect(function(frameName)
				if frameName == "End" then
					self:playToolAnimation(animName, 0.0, self.Humanoid)
				end
			end),"Disconnect","KeyframeHandlerTool")
		end
	end;
	StopAnims = function(self)
				self:stopAllAnimations()
				self:stopToolAnimations()
	end;
	Destroy = function(self)
		self.Janitor:Cleanup()
	end
		
	};
	
	Init = function(self,Figure)
		self:superinit()
		self.Figure = Figure;
		self.Animator = self.Humanoid:WaitForChild("Animator",200);
		self.animTable = {};
		self:setupAnimations()
		self:playAnimation("idle", 0.1, self.Humanoid)
		self.RunningCheck = 0.01
		self.JumpAnimTime = 0;
		self.JumpAnimDuration = 0.3;
		local time1 = 0;

		self.Janitor:Add(self.Humanoid.Running:Connect(function(speed)
			if (not _G.ClimbState) then
				if not _G.CharacterStance[self.Humanoid] then
					local speed_actual = self.Torso.CFrame:VectorToObjectSpace(self.Torso.Velocity).Magnitude
					if speed_actual > self.RunningCheck then
						self:runningFunctionIf(speed_actual)
					else
						self:runningFunctionElse(speed_actual)
					end
				elseif _G.CharacterStance[self.Humanoid] < 1 then
					local speed_actual = self.Torso.CFrame:VectorToObjectSpace(self.Torso.Velocity).Magnitude
					if speed_actual > self.RunningCheck then
						self:runningFunctionIf(speed_actual)
					else
						self:runningFunctionElse(speed_actual)
					end
				else
					self:stopAllAnimations()
				end
			end
		end),"Disconnect")
		self.Janitor:Add(self.Humanoid.Ragdoll:Connect(function()
			if self.currentAnimTrack then
				self.currentAnimTrack:Stop()
				self.Janitor:Remove("KeyframeHandler")
			end
			self.ragdoll = true
		end))
	
		if self.Humanoid:GetStateEnabled(Enum.HumanoidStateType.Jumping) then
			self.Janitor:Add(self.Humanoid.Jumping:Connect(function()
			
				self:playAnimation("jump", 0.1, self.Humanoid)
				self.JumpAnimTime = self.JumpAnimDuration
			end),"Disconnect")
		end
		if self.Humanoid:GetStateEnabled(Enum.HumanoidStateType.Freefall) then
			self.Janitor:Add(self.Humanoid.FreeFalling:Connect(function(active)
				if active then
					self:playAnimation("fall", self.fallTransitionTime, self.Humanoid)
				end
			end),"Disconnect")
		end	
		if self.Humanoid:GetStateEnabled(Enum.HumanoidStateType.Seated) then
			self.Janitor:Add(self.Humanoid.Seated:Connect(function(active)
				if active then
					self:playAnimation("sit", 0.5, self.Humanoid)
				end
			end),"Disconnect")
		end	
		self.Janitor:Add(self.Figure.ChildAdded:Connect(function(c)
			
			local tool = self:getTool()
			if tool and tool:FindFirstChild("HoldPart") then
				self:animateTool()		
			else
				self:stopToolAnimations()
				self.toolAnim = "None"
				self.toolAnimInstance = nil
				self.toolAnimTime = 0
			end
		end),"Disconnect")
		self.CurrentAnimSpeed = 1.0;	
	end;
})
	
return function(Character)
	return PseudoInstance.new("Animate",Character or script.Parent)
end