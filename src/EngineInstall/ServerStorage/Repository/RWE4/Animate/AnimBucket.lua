local RunService = game:GetService("RunService")
-- AnimationValues
local Resources = require(game.ReplicatedStorage:WaitForChild("Resources",200))
local RemoteService = Resources:LoadLibrary("RemoteService")
local PseudoInstance = Resources:LoadLibrary("PseudoInstance")
local Typer = Resources:LoadLibrary("Typer")
local WPF = Resources:LoadLibrary("WeightedProbabilityFunction")
local fastSpawn = Resources:LoadLibrary("FastSpawn")
local aH = Resources:LoadLibrary("AnimateHelper")
local FaceStates = Resources:LoadConfiguration("FaceStates")
local EventUtils = Resources:LoadLibrary("EventUtils")
return PseudoInstance:Register("AnimBucket",{
	Methods = {
		getAnimHelper = function(self, c)
			if self.Janitor:Get(c) then
				return self.Janitor:Get(c)
			end		
		end;
		setFace = function(self, c, state)
			if Typer.String(state) then
				local fs = FaceStates[state]
				if fs and c then
					if fs.EyeId then
						if Typer.Number(fs.EyeId) then
							c.Head.Face.Texture = "rbxassetid://" .. fs.EyeId;
						elseif self.origFace[c] then
							c.Head.Face.Texture = self.origFace[c][1];
						end
						if Typer.Number(fs.MouthId) then
							c.Head.FaceMouth.Texture = "rbxassetid://" .. fs.MouthId;
						elseif self.origFace[c] then
							c.Head.FaceMouth.Texture = self.origFace[c][2];
						end
					else
						if fs.Id == "Outfit" and self.origFace[c] then
							c.Head.Face.Texture = self.origFace[c][1];
							c.Head.FaceMouth.Texture = self.origFace[c][2];
						elseif Typer.Number(fs.Id) then
							c.Head.Face.Texture = "rbxassetid://" .. fs.Id;
							c.Head.FaceMouth.Texture = self.origFace[c][2];

						end
					end
					c.Head.Face.Color3 = fs.Color3;
				end
			end
		end,
		setOrigFace = function(self, c)
			self.origFace[c] = {c.Head.Face.Texture;};
			if c.Head:FindFirstChild("FaceMouth") then
				table.insert(self.origFace[c], c.Head.FaceMouth.Texture)

			else
				table.insert(self.origFace[c], "")
			end
		end,
	};
	
	Internals = { 
		mCount = 0;
		pCount = 0;
		"Ready";
		origFace = {};
		pCounts = {};
		mCounts = {};
		
		addMob = function(self, mob)
			if not self.Ready then
				return
			end
			self.mCount += 1;
			mob:WaitForChild("Head",200)
			mob:WaitForChild("Torso",200)
			mob:WaitForChild("Left Arm",200)
			mob:WaitForChild("Right Arm",200)
			mob:WaitForChild("Left Leg",200)
			mob:WaitForChild("Right Leg",200)
			self.Janitor:Add(aH(mob),"Destroy",mob)
			self.mCounts[mob] = self.mCount
			local cS = "Mob"..self.mCounts[mob]
			do
				local face2 = mob.Head.Face:Clone()
				face2.Name = "FaceMouth"
				face2.Texture = ""
				face2.Parent = mob.Head
			end
			self.Janitor:Add(mob.Human.Died:Connect(function()
				repeat RunService.Heartbeat:Wait() until not mob.Parent
				self.Janitor:Remove(mob)
				self.Janitor:Remove(cS)
				self.mCounts[mob] = nil;
			end),"Disconnect",cS)
		end;
		addPlayerCharacter = function(self, pc)
			if not self.Ready then
				return
			end
			local p = game.Players:GetPlayerFromCharacter(pc)
			if not p then return end
			self.pCount += 1;
			pc:WaitForChild("Head",200)
			pc:WaitForChild("Torso",200)
			pc:WaitForChild("Left Arm",200)
			pc:WaitForChild("Right Arm",200)
			pc:WaitForChild("Left Leg",200)
			pc:WaitForChild("Right Leg",200)			
			self.Janitor:Add(aH(pc),"Destroy",p)
			self.pCounts[pc] = self.pCount
			local cS = "Player"..self.mCount
			self.Janitor:Add(pc:GetAttributeChangedSignal("FaceState"):Connect(function()
				local fs = pc:GetAttribute("FaceState")
				local fst = FaceStates[fs]
				if fst then
					
					if fst.EyeId then
						if Typer.Number(fst.EyeId) then
							pc.Head.Face.Texture = "rbxassetid://" .. fst.EyeId;
						elseif self.origFace[pc] then
							pc.Head.Face.Texture = self.origFace[pc][1];
						end
						if Typer.Number(fst.MouthId) then
							pc.Head.FaceMouth.Texture = "rbxassetid://" .. fst.MouthId;
						elseif self.origFace[pc] then
							pc.Head.FaceMouth.Texture = self.origFace[pc][2];
						end
					else
						if fst.Id == "Outfit" and self.origFace[pc] then
							pc.Head.Face.Texture = self.origFace[pc][1];
							pc.Head.FaceMouth.Texture = self.origFace[pc][2];
						elseif Typer.Number(fst.Id) then
							pc.Head.Face.Texture = "rbxassetid://" .. fst.Id;
							pc.Head.FaceMouth.Texture = self.origFace[pc][2];

						end
					end
					pc.Head.Face.Color3 = fst.Color3;
				end
			end), "Disconnect", cS.."Face")
			self.Janitor:Add(pc.Humanoid.Died:Connect(function()
				repeat RunService.Heartbeat:Wait() until not pc.Parent
				self.Janitor:Remove(p)
				self.Janitor:Remove(cS)
				self.Janitor:Remove(cS.."Face")
				self.pCounts[pc] = nil;

			end),"Disconnect",cS)
			
		end;
	};

	
	Init = function(self)
        if Resources:FindGlobalFeature("Maps") then
            EventUtils:ConnectEvent("MapReady",function()
                if not self.Ready then
                    self.Ready = true
                    self.mCount = 0
                end
            end)
        end
		self.Janitor:Add(workspace.ChildAdded:Connect(function(c)
			self:addPlayerCharacter(c)
		end),"Disconnect")
		self.Janitor:Add(workspace.Mobs.ChildAdded:Connect(function(c)
			self:addMob(c)
		end),"Disconnect")
		self:superinit()
	end;

})
