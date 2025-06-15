local RunService = game:GetService("RunService")
local Lighting = game.Lighting
local Resources = require(game.ReplicatedStorage.Resources)
local Enumeration = Resources:LoadLibrary("Enumeration")
local Tween = Resources:LoadLibrary("Tween")
local fastSpawn = Resources:LoadLibrary("FastSpawn")
local FastWait = Resources:LoadLibrary("FastWait")
local PhotoSiris = Resources:LoadLibrary("PhotoSiris")
local Lerps = Resources:LoadLibrary("Lerps")
local RemoteService = Resources:LoadLibrary("RemoteService")
local Signal = Resources:LoadLibrary("Signal")
local Bezier = Resources:LoadLibrary("Bezier")
local WaterService = Resources:LoadLibrary("Water")
local MovementHelper = {};
MovementHelper.BlurCounter = 1;
MovementHelper.SprintMulti = 1;
MovementHelper.Dampener = 5;
MovementHelper.Range = {
	Blur = 25;
	Range = 10;
}
MovementHelper.Swimming = false
MovementHelper.SwimmingChanged = Signal.new()
MovementHelper.SprintChanged = Signal.new()
MovementHelper.BWS = 14;
MovementHelper.Vector = workspace.CurrentCamera.CFrame.LookVector
local function degreesToDot() return math.cos(math.rad(MovementHelper.Range.Range)) end
function MovementHelper:Blur(lv)
	if self.BlurCounter % self.Dampener == 0 then
		local dot = self.Vector:Dot(lv)
		if dot >= degreesToDot() then
			local prev = Lighting.GameBlur.Size
			Tween.new(.25, Enumeration.EasingFunction.Acceleration.Value, "motionBlur", true, function(x)
				PhotoSiris:SetBlurChannel("Game",Lerps.number(prev,0,x))
			end)
		else 
			local prev = Lighting.GameBlur.Size
			Tween.new(.25, Enumeration.EasingFunction.Acceleration.Value, "motionBlur", true, function(x)
				PhotoSiris:SetBlurChannel("Game",Lerps.number(prev,(1 - dot) * (self.Range.Blur / 2),x))
			end)
		end
		self.Vector = lv
		self.BlurCounter += 1;
	end
end
function MovementHelper:GetCollisionData(player)
	local Char = player.Character
	local Head = Char:FindFirstChild("Head")
	local rp = RaycastParams.new()
	rp.FilterDescendantsInstances = {Char;workspace.ignoreModel}
	rp.FilterType = Enum.RaycastFilterType.Blacklist
	rp.IgnoreWater = true
	local res = workspace:Raycast(Head.CFrame.p, Head.CFrame.lookVector * 5, rp)
	if res then
		local distLerp = 1 - ((res.Position - Head.CFrame.p).Magnitude / 5)
		local Hit = res.Instance
		return true, Hit, distLerp
	end
	return false
end
function MovementHelper:ToggleSprint(player,cs,keyDown)
	if RunService:IsClient() then
		RemoteService.fetch("Server","ToggleSprint",keyDown,self.SprintMulti >= 1.25)
	end
	local stats2 = player.Character
	if stats2 then
		self.Sprint = stats2:GetAttribute("Sprinting")
		if self.Sprint ~= nil then
			self.SprintChanged:Fire(self.Sprint)
		end
	end
end
function MovementHelper:GetWalkSpeedAI(baseWalkSpeed,character,agent,sprint,stance)
	if baseWalkSpeed then
		self.BWS = baseWalkSpeed
	end
	local stats = character
	if stats then
		self.walkSpeedMult = stats:GetAttribute("walkSpeedMult")
		local currentS, maxS = stats:GetAttribute("CurrentStamina"), stats:GetAttribute("MaxStamina")
		local percent = math.clamp(currentS/maxS, 0, 1)
		if agent then 
			if agent:GetStateProperty("Unconscious") then
				return 0
			end
		end
		self.walkPenalty = stats:GetAttribute("walkPenalty") 
		return  ((((((sprint and stance == 0 and percent > 0) and 1.5 or 1) * self.walkSpeedMult * self.BWS)/math.clamp(stance*2,1,8)) - (self.walkPenalty or 0)) + (stats:GetAttribute("offsetSpeed") or 0)) * self.SprintMulti
	end
	return baseWalkSpeed
end
function MovementHelper:GetWalkSpeed(baseWalkSpeed,player,agent,iC,stance)
	if baseWalkSpeed then
		self.BWS = baseWalkSpeed
	end
	local stats2 = player.Character
	if stats2 then
		self.walkSpeedMult = stats2:GetAttribute("walkSpeedMult")
		local currentS, maxS = stats2:GetAttribute("CurrentStamina"), stats2:GetAttribute("MaxStamina")
		local percent = math.clamp(currentS/maxS, 0, 1)
		if agent and Resources:FindGlobalFeature("HealthState") then
			repeat RunService.Heartbeat:Wait() until pcall(function() return agent:GetStateProperty("Unconscious") end)
			 if agent:GetStateProperty("Unconscious") then
				return 0
			end
		end
		if (not iC.Binds["Core"]) and (not Resources:FindGlobalFeature("SprintDefaults")) then
			return (1*self.walkSpeedMult*self.BWS)/math.clamp(stance*2,1,8)
		end
		self.walkPenalty = stats2:GetAttribute("walkPenalty") 
		return  ((((((self.Sprint and stance == 0 and percent > 0) and 1.5 or 1) * self.walkSpeedMult * self.BWS)/math.clamp(stance*2,1,8)) - (self.walkPenalty or 0)) + (stats2:GetAttribute("offsetSpeed") or 0)) * self.SprintMulti
	end
	return baseWalkSpeed
end
function MovementHelper:GetStanceSpeed(stance)
		return (1 * self.walkSpeedMult * self.BWS/math.clamp(stance*2,1,8)) - self.walkPenalty
end

function MovementHelper:CheckForSwim()
	if not RunService:IsClient() then return end
	local plr = game.Players.LocalPlayer
	if (not plr.Character) or (not plr.Character.Parent) then return end
	local inWater, _, _ = WaterService:IsSubmerged(plr.Character);
	if MovementHelper.Swimming then
		inWater, _, _ = WaterService:IsSubmerged(plr.Character,MovementHelper.Swimming);
	end
	if inWater ~= MovementHelper.Swimming then	
		MovementHelper.Swimming = inWater;
		MovementHelper.SwimmingChanged:Fire(inWater)
	end
end
function MovementHelper:SetDOF(dof: DepthOfFieldEffect, options)
	MovementHelper.DepthOfField = dof;
	MovementHelper.DOFOptions = options;
end
local function penetratingRaycast(origin, direction, distance, ignore, ignoreFunction)
	local remainingCasts = 5
	local target = origin + direction * math.min(distance, 1e3)
	local hit
	repeat
		local ray = Ray.new(origin, (target - origin))
		local rp = RaycastParams.new()
		rp.IgnoreWater = true;
		rp.FilterType = Enum.RaycastFilterType.Blacklist
		rp.FilterDescendantsInstances = ignore
		hit = workspace:Raycast(ray.Origin, ray.Direction, rp)
		remainingCasts = remainingCasts - 1
		if hit then
			if ignoreFunction(hit.Instance) then
				table.insert(ignore, hit.Instance)
				hit = nil
			end
		end
	until origin == target or hit or remainingCasts == 0
	return origin, (hit and hit.Instance or nil)
end
local function shouldIgnore(part)
	return part.Transparency > 0.2
end
local function getDepth(camCF)
	local origin = camCF.Position
	local player = game.Players.LocalPlayer
	local position = penetratingRaycast(origin, camCF.LookVector,
		MovementHelper.DOFOptions.FocusDepth, { player.Character }, shouldIgnore)
	return (position - origin).magnitude
end
local function moveToward(origin, target, maxDelta)
	return origin + math.clamp(target - origin, -maxDelta, maxDelta)
end
local tAutoFocus = 0;
local intensity
function MovementHelper:SetupDOF()
	intensity = MovementHelper.DOFOptions.IntensityChar;
end
function MovementHelper:UpdateDOF(camCF,dt)
	local depthOfField = MovementHelper.DepthOfField
	if depthOfField.Enabled then
		local Head = MovementHelper.DOFOptions.Head
		local focusDistance, inFocusRadius, targetIntensity, focusSpeed
		tAutoFocus += dt
		if tAutoFocus < 0.3 then
			-- Camera was recently moved, focus on the player
			focusDistance = (camCF.Position - Head.CFrame.Position).magnitude
			inFocusRadius = math.clamp(focusDistance, Head.Parent:GetExtentsSize().Magnitude, 50)
			targetIntensity = 0.25
			focusSpeed = MovementHelper.DOFOptions.FocusSpeed
		else
			-- Camera has been static for a while, enable auto-focus
			focusDistance = getDepth(camCF)
			inFocusRadius = math.clamp(focusDistance * 0.5, Head.Parent:GetExtentsSize().Magnitude, Head.Parent:GetExtentsSize().Magnitude * 8)
			targetIntensity = 0.3
			focusSpeed = MovementHelper.DOFOptions.FocusSpeed
		end
		depthOfField.FocusDistance = moveToward(depthOfField.FocusDistance, focusDistance, dt * focusSpeed)
		depthOfField.InFocusRadius = moveToward(depthOfField.InFocusRadius, inFocusRadius, dt * focusSpeed)

		intensity = moveToward(intensity, targetIntensity, dt * 0.2)

		depthOfField.FarIntensity = intensity
		depthOfField.NearIntensity = intensity
	end
end
function MovementHelper:ResetAutoFocus()
	tAutoFocus = 0;
end
return MovementHelper