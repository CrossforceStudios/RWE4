local RunService = game:GetService("RunService")
local PhotoSiris = {}
local Lighting = game.Lighting
local Resources = require(game.ReplicatedStorage.Resources)
local Enumeration = Resources:LoadLibrary("Enumeration")
local Tween = Resources:LoadLibrary("Tween")
local Lerps = Resources:LoadLibrary("Lerps")
local Array = Resources:LoadLibrary("Array")
local fastSpawn = Resources:LoadLibrary("FastSpawn")
local Color = Resources:LoadLibrary("Color")
local FastWait = Resources:LoadLibrary("FastWait")
local Signal = Resources:LoadLibrary("Signal")
local getHumanoid = Resources:LoadLibrary("getHumanoid")
local ObjectHighlight = Resources:LoadLibrary("ObjectHighlight")
local Lightning = Resources:LoadLibrary("Lightning")
local Make = Resources:LoadLibrary("Make")
local FastDelay = Resources:LoadLibrary("FastDelay")
local AU = Resources:LoadLibrary("AngleUtils")
local SE = Resources:LoadLibrary("StringExtras")
local EventUtils = Resources:LoadLibrary("EventUtils")

local RNG = Random.new()
local blurChannels = {
	Game = Lighting:WaitForChild("GameBlur",200);
	UI = Lighting:WaitForChild("UIBlur",200);
}
PhotoSiris.Map = nil;
PhotoSiris.Clouds = workspace.Terrain:WaitForChild("Clouds",200)
PhotoSiris.CloudCoverChanged = PhotoSiris.Clouds:GetPropertyChangedSignal("Cover")
PhotoSiris.CloudDensityRequested = PhotoSiris.Clouds:GetAttributeChangedSignal("CloudDensity")
PhotoSiris.ThunderChanged = PhotoSiris.Clouds:GetAttributeChangedSignal("Thunder")
PhotoSiris.Previous = {
	Ambient = nil;
	OAmbient = nil;
	Atm = {

	}
}
PhotoSiris.MoonPhase = 1;
PhotoSiris.MoonPhases = {
	"rbxassetid://7630566792";
	"rbxassetid://7630573723";
	"rbxassetid://7630579204";
	"rbxassetid://7630588061";
	"rbxassetid://7630593462";
	"rbxassetid://7630599091";
	"rbxassetid://7630605486";
	"rbxassetid://7630613307"
};
local filters = Resources:LoadConfiguration("LightingFilters")

PhotoSiris.CurrentFilter = nil;
function PhotoSiris:LoadLightingFilter(filterName)
	if filters[filterName] then
		PhotoSiris.CurrentFilter = filters[filterName];
	end
end
local StarCount = 0
local ShaderData = Resources:LoadConfiguration("NightSky")
ShaderData.Runner = {}
function PhotoSiris:CheckNightSky()
	if PhotoSiris:GetCurrentTimeOfDay() == "Night" or PhotoSiris:GetCurrentTimeOfDay() == "Dusk" then
		if not ShaderData.HoldPart then
			ShaderData.HoldPart = Instance.new("Part")
			ShaderData.HoldPart.Parent = workspace.StarIgnore
			ShaderData.HoldPart.Size = Vector3.new(1,1,1)
			ShaderData.HoldPart.Anchored = true
			ShaderData.HoldPart.Position = workspace.CurrentCamera.CFrame.Position		
			ShaderData.HoldPart.Name = "CamTracker"
			ShaderData.HoldPart.CanCollide = false
			ShaderData.HoldPart.CanQuery = false
			ShaderData.HoldPart.CanTouch = false
			ShaderData.HoldPart.Transparency = 1
			ShaderData.HoldPart.Massless = true
		end
	else
		if ShaderData.HoldPart then
			ShaderData.HoldPart:Destroy()
		end
	end
end
if not ShaderData.StarsSet then
	ShaderData.StarsSet = {
		{};	
	};
end

function PhotoSiris:SpawnStar()
	local st = Instance.new("Part")
	st.Shape = Enum.PartType.Ball
	st.Material = Enum.Material.Neon
	st.Name = "STAR_"..StarCount
	st.Parent = workspace.StarIgnore
	st.Size = Vector3.new(ShaderData.Size,ShaderData.Size,ShaderData.Size)
	st.Anchored = false
	st.CanCollide = false
	st.CanTouch = false
	st.CanQuery = false
	st.Massless = true
	st.Orientation = Vector3.new(math.random(-180, 180),math.random(-180, 180),math.random(-180, 180))
	return st
end


function PhotoSiris:SpawnMeteorTrails(Star: BasePart, StarSize : number)
	local Color = Lerps.Color3(ShaderData.Color.StartColor, ShaderData.Color.EndColor, RNG:NextNumber(0,1))

	local Att1 = Instance.new("Attachment")
	local Att2 = Instance.new("Attachment")
	local Att3 = Instance.new("Attachment")
	Att3.Name = "MID"

	Att1.Parent = Star
	Att2.Parent = Star
	Att3.Parent = Star

	Att1.Position = Vector3.new(0,StarSize/2,0)
	Att2.Position = Vector3.new(0,-StarSize/2,0)

	local StarTrail = Instance.new("Trail")
	StarTrail.Parent = Star

	StarTrail.Texture = "rbxassetid://11714870748"

	StarTrail.Name = "Trail"

	StarTrail.Attachment0 = Att1
	StarTrail.Attachment1 = Att2

	StarTrail.LightInfluence = 0
	StarTrail.LightEmission = 1
	StarTrail.Brightness = Random.new():NextNumber(ShaderData.StarFalls.BrightnessLevels[1], ShaderData.StarFalls.BrightnessLevels[2])

	StarTrail.Transparency = NumberSequence.new{
		NumberSequenceKeypoint.new(0, 0),
		NumberSequenceKeypoint.new(0.5, 1),
		NumberSequenceKeypoint.new(1, 1),
	}

	StarTrail.WidthScale = NumberSequence.new{
		NumberSequenceKeypoint.new(0,StarSize),
		NumberSequenceKeypoint.new(1,0),
	}

	StarTrail.FaceCamera = true
	StarTrail.Color = ColorSequence.new{
		ColorSequenceKeypoint.new(0, Color),
		ColorSequenceKeypoint.new(1, Color),
	}

	StarTrail.Lifetime = Random.new():NextNumber(ShaderData.StarFalls.TrailLifeTimes[1], ShaderData.StarFalls.TrailLifeTimes[2])

	StarTrail.MinLength = 0.1
	StarTrail.MaxLength = math.random(ShaderData.StarFalls.StarDistance/10, ShaderData.StarFalls.StarDistance)
end

function PhotoSiris:PositionMeteor(Star: BasePart)
	local CameraPosition = workspace.CurrentCamera.CFrame.Position
	local X = RNG:NextNumber(-1, 1)
	local Y = RNG:NextNumber(-1, 1)
	local Z = RNG:NextNumber(-1, 1)
	local StarPosition = Vector3.new(X*ShaderData.StarFalls.StarDistance, Y*ShaderData.StarFalls.StarDistance, Z*ShaderData.StarFalls.StarDistance)
	StarPosition = StarPosition + (Vector3.new(X,Y,Z) * Vector3.new(ShaderData.StarFalls.StarDistance,ShaderData.StarFalls.StarDistance,ShaderData.StarFalls.StarDistance))
	Star.Position = CameraPosition + StarPosition

end

function PhotoSiris:SpawnMeteorStar()
	local st = PhotoSiris:SpawnStar()
	local StarSize = math.random(ShaderData.StarFalls.SizeRangeMin, ShaderData.StarFalls.SizeRangeMax)
	st.Size = Vector3.new(StarSize,StarSize,StarSize)
	PhotoSiris:SpawnMeteorTrails(st,StarSize)
	PhotoSiris:PositionMeteor(st)
	return st
end
local Weather = {
	CloudType = "Clear";
	TempCloudType = "Clear";
};
function PhotoSiris:GetRunnerAPI()
	return {
		Camera = workspace.CurrentCamera;
		CF = CFrame.new;
		StarParent = workspace.StarIgnore;
		V3 = Vector3.new;
		StarCount = ShaderData.Stars;
		Parent = ShaderData.HoldPart;
		Player = game.Players.LocalPlayer;
		Lighting = Lighting;
		getStarCount = function()
			return #ShaderData.StarsSet[1]
		end,
		Tween = Tween;
		createStar = function()
			return PhotoSiris:SpawnStar()
		end,
		setFlicker = function(star)
			game.CollectionService:AddTag(star, "StarFlicker")
			star:SetAttribute("OriginalColor", star.Color)
		end,
		getRandomStart = function()
			local X = RNG:NextNumber(-1, 1)
			local Y = RNG:NextNumber(-1, 1)
			local Z = RNG:NextNumber(-1, 1)
			local StarPosition = Vector3.new(X, Y, Z)*ShaderData.StarDistance
			return StarPosition, Vector3.new(X, Y, Z)
		end,
		offsetStar = function(star, CameraPosition, StarPosition, UnitVector)
			StarPosition = StarPosition + (Vector3.new(UnitVector.X,UnitVector.Y,UnitVector.Z) * ShaderData.StarDistance)
			star.Position = CameraPosition + StarPosition

			local Distance = (CameraPosition - star.Position).Magnitude
			if Distance < ShaderData.StarDistanceThreshold then
				star.Position = star.Position * ShaderData.StarDistanceThresholdMultiplier
			end
		end,
		attachToSky = function(star)
			local Weld = Instance.new("WeldConstraint")
			Weld.Part0 = ShaderData.HoldPart
			Weld.Part1 = star
			Weld.Parent = star
		end,
		Size = ShaderData.Size;
		getColor = function()
			return Lerps.Color3(ShaderData.Color.StartColor, ShaderData.Color.EndColor, RNG:NextNumber(0,1))
		end,
		getChance = function()
			return RNG:NextInteger(0,1)
		end,
		AddStars = function(Star)
			if not ShaderData.StarsSet then
				ShaderData.StarsSet = {
					{};	
				};
			end
			table.insert(ShaderData.StarsSet[1], #ShaderData.StarsSet[1]+1, Star)
		end,
		isNight = function()
			return PhotoSiris:GetCurrentTimeOfDay() == "Night" or PhotoSiris:GetCurrentTimeOfDay() == "Dusk";
		end,
		getFlickeringStars = function()
			return game.CollectionService:GetTagged("StarFlicker")
		end,
		FlickRate = ShaderData.StarFlicker.FlickRate;
		MaxClock = ShaderData.MaxClock;
		FlickTweenTime =  ShaderData.StarFlicker.TweenTime;
		GetFlickColor = function(StarColor : Color3)
			local FlickerData = ShaderData.StarFlicker

			local MinAlpha  : number = FlickerData.FlickAlphaMin
			local MaxAlpha  : number = FlickerData.FlickAlphaMax

			local Alpha : number = RNG:NextNumber(MinAlpha, MaxAlpha)

			local FlickColor = FlickerData.FlickColor
			local NewColor = Lerps.Color3(StarColor, FlickColor, Alpha)

			return NewColor
		end;
		spawnMeteorStar = function()
			return PhotoSiris:SpawnMeteorStar()
		end,
		spawnMeteor = function()
			local StarFallData = ShaderData.StarFalls

			local MotherPack = Instance.new("Folder")
			MotherPack.Parent = ShaderData.HoldPart
			MotherPack.Name = "STAR_FALL_"..SE:Generate(1)

			local Star : BasePart = PhotoSiris:SpawnMeteorStar()
			local StarPosition = Star.Position

			local Trail : Trail = Star.Trail

			Star.Anchored = false

			local LinearVelocity = Instance.new("LinearVelocity")
			LinearVelocity.Parent = Star
			LinearVelocity.Attachment0 = Star.MID
			LinearVelocity.MaxForce = 99999999999999
			LinearVelocity.RelativeTo = Enum.ActuatorRelativeTo.World
			LinearVelocity.VectorVelocity = Vector3.new(0,0,0)

			Star.Transparency = 1

			local StarNormalPosition = Vector3.new(RNG:NextNumber(0,1),RNG:NextNumber(0,1),RNG:NextNumber(0,1))

			local TimeMax = math.random(StarFallData.TimeMaxes.Min, StarFallData.TimeMaxes.Max)
			local CurrentTime = 0

			local MaxToVisible = TimeMax/9
			local StartToInvisible = TimeMax - (TimeMax/9)

			ShaderData.CurrentMeteor = Star

			return CurrentTime, StarNormalPosition, TimeMax,MaxToVisible, StartToInvisible
		end,
		GetCurrentStar =  function()
			return ShaderData.CurrentMeteor
		end,
		DestroyCurrentStar = function()
			if not ShaderData.CurrentMeteor then
				return
			end
			ShaderData.CurrentMeteor:Destroy()
			ShaderData.CurrentMeteor = nil
		end,
		StarSpeed = ShaderData.StarFalls.StarSpeed;
		StarDistance = ShaderData.StarFalls.StarDistance;
		StarSpeedMultiplier = ShaderData.StarFalls.StarSpeedMultiplier;
		GetSunDirection = function()
			return Lighting:GetSunDirection()
		end,
		hasClouds = function()
			return PhotoSiris.Clouds.Cover >= 1 and  PhotoSiris.Clouds.Density > .1
		end,
		GetCloudDensity = function()
			return PhotoSiris.Clouds.Density
		end,
		GetAngleSize = function()
			return Lighting.Sky.SunAngularSize
		end,
		SunToCam = function(Character: Model)
			if not Character then
				return
			end
			local _, OnScreen = workspace.CurrentCamera:WorldToScreenPoint(_G.SunPart.Position)
			local NumOfObstructions = #workspace.CurrentCamera:GetPartsObscuringTarget({workspace.CurrentCamera.CFrame.Position,_G.SunPart.Position},{_G.SunPart,Character})
			local PlayerRoot = Character.PrimaryPart
			local rayStartPosition = workspace.CurrentCamera.CFrame.Position
			local rayDestination = _G.SunPart.Position
			local rayDir = rayDestination - rayStartPosition
			local findTerrainParams = RaycastParams.new()
			findTerrainParams.FilterType = Enum.RaycastFilterType.Exclude
			findTerrainParams.FilterDescendantsInstances = {Character,_G.SunPart}
			findTerrainParams.IgnoreWater = true

			local result = workspace:Raycast(rayStartPosition, rayDir * (rayStartPosition - rayDestination).Magnitude,findTerrainParams)
			if result and result.Material then
				return "OSO"
			end

			if OnScreen then
				return if NumOfObstructions <= 0 then "OSU" else "OSO"
			end
			return "OFS" --Sun is off-screen
		end,
		GetTimeOfDay = function()
			return PhotoSiris:GetCurrentTimeOfDay()
		end,
		SunRayN = Lighting.SunLight;
		SunRayF = Lighting.SunLightFar;
	}
end

local function toggleLights()
	if PhotoSiris.Map then
		local lights = PhotoSiris.Map:FindFirstChild("Lights")
		if lights and PhotoSiris.CurrentFilter then
			for _, l in pairs(lights:GetChildren()) do
				if l:IsA("BasePart") then
					if not game.CollectionService:HasTag(l,"DeadLight") then
						local on = PhotoSiris.CurrentFilter.Periods[PhotoSiris:GetLightingPeriod()].LightsOn
						l.Material = on and Enum.Material.Neon or  Enum.Material.SmoothPlastic
						l.BrickColor = on and BrickColor.White() or BrickColor.new("Medium stone grey")
						for _, v in ipairs(l:GetChildren()) do
							if v:IsA("Light") or v:IsA("Beam") then
								v.Enabled = on	
							end
						end
					elseif (game.CollectionService:HasTag(l,"DeadLight")) then
						l.Material =   Enum.Material.SmoothPlastic
						l.BrickColor =  BrickColor.new("Medium stone grey")
						for _, v in ipairs(l:GetChildren()) do

							if v:IsA("Light") or v:IsA("Beam") then
								v.Enabled = false	
							end
						end
					end
				elseif l:IsA("Model") then
					local l2 = l:FindFirstChild("LampLight")
					if l2 and (not game.CollectionService:HasTag(l2,"DeadLight")) then
						local on = PhotoSiris.CurrentFilter.Periods[PhotoSiris:GetLightingPeriod()].LightsOn
						l2.Material = on and "Neon" or "SmoothPlastic"
						l2.BrickColor = on and BrickColor.White() or BrickColor.new("Medium stone grey")
						for _, v in ipairs(l2:GetChildren()) do
							if v:IsA("Light") or v:IsA("Beam") then
								v.Enabled = on	
							end

						end
					elseif l2 and (game.CollectionService:HasTag(l2,"DeadLight")) then
						l2.Material =  Enum.Material.SmoothPlastic
						l2.BrickColor =  BrickColor.new("Medium stone grey")
						for _, v in ipairs(l2:GetChildren()) do

							if v:IsA("Light") or v:IsA("Beam") then
								v.Enabled = false	
							end

						end
					end
				end

			end
		end
	end
end


local Clouds = {
	"Clear";
	"Stratus";
	"Cumulus";
	"Cumulonimbus";
	"Nimbus";

} 

local CloudCover = {
	["Clear"] = 0;
	["Stratus"] = 0.25;
	["Cumulus"] = 0.5;
	["Cumulonimbus"] = 1;
	["Nimbus"] = 1;
}

local CloudDensity = {
	["Clear"] = 0;
	["Stratus"] = 0.4;
	["Cumulus"] = 0.6;
	["Cumulonimbus"] = 0.8;
	["Nimbus"] = 1;
}
do
	local RNG = Random.new()
	local Close = {9116307330}
	local Medium = {9116307330}
	local Far = {9116301252}
	
	PhotoSiris.LightningRequested = Signal.new()
	PhotoSiris.LightningEffectRequested = Signal.new()
	PhotoSiris.LightningOn = false
	if RunService:IsServer() then
		local humanoids = {}
		workspace.ChildAdded:Connect(function(c)
			if c.Name == "ThunderImpact" and c:IsA("Explosion") then
				c.Hit:Connect(function(o,d)
					print(o)
					local humanoid = getHumanoid(o,0)
					if humanoid and (not humanoids[humanoid]) then
						humanoids[humanoid] = true
						humanoid:TakeDamage(45)
						FastDelay(5, function()
							humanoids[humanoid] = false
						end)
					end
				end)	
			end
		end)
		PhotoSiris.ThunderChanged:Connect(function()
			if PhotoSiris.Clouds:GetAttribute("Thunder") then
				local cf = workspace.CurrentMap.Value:GetModelCFrame()
				local X, Y = workspace.CurrentMap.Value:GetExtentsSize().X/2 * RNG:NextNumber(0,1), RNG:NextNumber(0,1) * workspace.CurrentMap.Value:GetExtentsSize().Z/2;
				local origin = Vector3.new(X * (math.random(1,2) == 2 and 1 or -1),5000,Y * (math.random(1,2) == 2 and 1 or -1))
				local rp = RaycastParams.new()
				rp.FilterDescendantsInstances = {
					workspace.CurrentMap.Value:FindFirstChild("LandmarkZones");
					workspace.CurrentMap.Value:FindFirstChild("ReverbAreas");
					workspace.CurrentMap.Value:FindFirstChild("MapCamera");
				}
				rp.FilterType = Enum.RaycastFilterType.Blacklist
				rp.IgnoreWater = false
				local res = workspace:Raycast(origin, (Vector3.new(origin.X,0,origin.Z) - origin), rp)
				if res then			
					local exp = Make("Explosion"){
						BlastRadius = 20;
						BlastPressure = 1000;
						Position = res.Position;
						DestroyJointRadiusPercent = 0;
						Visible = false;
						ExplosionType = Enum.ExplosionType.NoCraters;
					};
					exp.Name = "ThunderImpact"
					exp:SetAttribute("DebrisColor", res.Instance.BrickColor.Color)
					exp.Parent = workspace
					exp.Hit:Connect(function(o,d)
						if not o:IsA("Terrain") then
							_G.Destruction:AddFire(o)
						end
					end)
					print(exp, exp.Parent)
				end
				task.delay(.5, function()
					PhotoSiris.Clouds:SetAttribute("Thunder", nil)
				end)
			end
		end)
		local tChooseWeather = 0;
		local tEvents = 0;
		local tTransition = 0;
		local timeStep = math.random(45,90)
		local baseWind = workspace.GlobalWind
		if not script:GetAttribute("GustIntervals") then
			script:SetAttribute("GustIntervals", 100)
		end
		if not script:GetAttribute("GustDuration") then
			script:SetAttribute("GustDuration", 2.5)
		end
		if not script:GetAttribute("BaseGustVelocity") then
			script:SetAttribute("BaseGustVelocity", 25, 0, 10)
		end
		if not script:GetAttribute("BaseGustVelocity") then
			script:SetAttribute("BaseGustVelocity", 25, 0, 10)
		end
		if not script:GetAttribute("GustScale") then
			script:SetAttribute("GustScale", 5)
		end
		if not script:GetAttribute("TimeScale") then
			script:SetAttribute("TimeScale", .5)
		end
		if not script:GetAttribute("TimeScaleDiff") then
			script:SetAttribute("TimeScaleDiff", .1)
		end
		local DurationOfGust = script:GetAttribute("GustDuration") / script:GetAttribute("GustIntervals")
		local GustFrequency = DurationOfGust / script:GetAttribute("GustDuration")
		local tGO = 0
		local gusting = false
		local tGInterval = 0;
		local gusts = 0;
		local gustScale = script:GetAttribute("GustScale")
		RunService.Stepped:Connect(function(_,dt)
			if (not _G.GameMode) then return end
			if (_G.GameMode:find("Tutorial")) then return end
			if _G.GameMode == "Campaign" then return end
			if workspace:GetAttribute("NoLightCycle") then
				return
			end
			tChooseWeather += dt;
			tEvents += dt;
			if not gusting then
				tGO += dt;

			else
				tGInterval += dt;
				if tGInterval >= DurationOfGust then
					tGInterval = 0;
					if gusts >= script:GetAttribute("GustIntervals") then
						gusting = false
						gusts = 0
					else
						gusts += 1;
						local f = math.sin(math.pi * GustFrequency * gusts)
						workspace.GlobalWind = baseWind * f * script:GetAttribute("BaseGustVelocity")
					end
				end
			end
			if tChooseWeather >= timeStep then
				tChooseWeather = 0;
				timeStep = math.random(30,60)
				Weather.TempCloudType = Clouds[math.random(1,#Clouds)]
				PhotoSiris.Clouds:SetAttribute("CloudState",Weather.TempCloudType)
				PhotoSiris.Clouds:SetAttribute("CloudCover",CloudCover[Weather.TempCloudType])
				PhotoSiris.Clouds:SetAttribute("CloudDensity",CloudDensity[Weather.TempCloudType])
				tTransition = 36
			end
			if tTransition > 0 then
				tTransition -= dt;
				if tTransition <= 0 then
					tTransition = 0;
					Weather.CloudType = Weather.TempCloudType;

					PhotoSiris.LightningOn =  (Weather.CloudType == "Nimbus" and RNG:NextInteger(1,2) == 2)
				end
			end
			if tEvents >= 10 then
				tEvents = 0;
				local chance = RNG:NextInteger(0,2)
				if chance == 1 then
					workspace.GlobalWind = RNG:NextUnitVector() * RNG:NextInteger(2, 5)
				elseif chance == 2 then
					baseWind = workspace.GlobalWind
					if tGO >= gustScale and (not gusting) then
						tGO = 0
						gusting = true
						tGInterval = 0;
						gusts = 0;
						gustScale = script:GetAttribute("GustScale") * math.random()
					end
				else
					workspace.GlobalWind = Vector3.new()
				end
				if workspace:GetAttribute("Climate") ~= "Alpine" then
					PhotoSiris.Clouds:SetAttribute("Thunder",PhotoSiris.LightningOn)
				end
			end
			game.Lighting:SetAttribute("ChooseWeather",tChooseWeather)	
		end)
	else	
		local player  = game.Players.LocalPlayer
		PhotoSiris.VolumetricData = {
			Depth = 50;
			LightEmission = 1;
			RenderMethod = "Beams";
			LayerSpacing = 1;
			Transparency = 0.996;
		}
		local Volumetrics = require(script.Volumetrics)
		local volumetric
		if Resources:FindGlobalFeature("VolumetricLighting") then
			volumetric = Volumetrics.new(workspace.CurrentCamera, PhotoSiris.VolumetricData.Depth, PhotoSiris.VolumetricData.LayerSpacing, Enumeration.VolumetricRenderMethod[PhotoSiris.VolumetricData.RenderMethod].Value)
			volumetric:RenderVolumetrics()
		end
		function PhotoSiris:ChangeVolumetricProperty(name, value)
			if PhotoSiris.VolumetricData[name] ~= nil and Resources:FindGlobalFeature("VolumetricLighting") then
				PhotoSiris.VolumetricData[name] = value
				volumetric[name] = value
				volumetric:RenderVolumetrics()
			end
		end
		function PhotoSiris:ChangeVolumetricTransparency(value)
			if value ~= nil and Resources:FindGlobalFeature("VolumetricLighting") then
				self:ChangeVolumetricProperty("Transparency", value)
			end
		end
		function PhotoSiris:ChangeVolumetricSpacing(value)
			if value ~= nil and Resources:FindGlobalFeature("VolumetricLighting") then
				self:ChangeVolumetricProperty("LayerSpacing", value)
			end
		end
		function PhotoSiris:ChangeVolumetricLayers(value)
			if value ~= nil and Resources:FindGlobalFeature("VolumetricLighting") then
				self:ChangeVolumetricProperty("Depth", value)
			end
		end
		function PhotoSiris:ToggleVolumetrics(bool: boolean)
			if  Resources:FindGlobalFeature("VolumetricLighting") then
				volumetric.Visible = bool
				volumetric:RenderVolumetrics()
			end
		end
		workspace.ChildAdded:Connect(function(c)
			if c.Name == "ThunderImpact" and c:IsA("Explosion") and PhotoSiris.Map then
				local lightning = Lightning.new(c.Position + Vector3.new(0,500,0), c.Position, {
					color = Color3.fromRGB(255,255,255)
				})
				lightning:Draw()
				if player.Character then
					if player.Character.Parent then
						local ePoint = Instance.new("Attachment")
						ePoint.CFrame = CFrame.new(c.Position)
						ePoint.Parent = workspace.Terrain
						if AU.CanSee(ePoint, player.Character.Head, 90) then
							Lighting.GameCC.Enabled = true
							Lighting.GameCC.TintColor = Color3.fromRGB(229, 233, 255)
							Tween(Lighting.GameCC, "Brightness", 0.9, "Standard", 0.15, false, function(status)
								Tween(Lighting.GameCC, "Brightness", 0, "Standard", 0.15, false, function(status)
									Lighting.GameCC.Enabled = false
									Lighting.GameCC.TintColor = Color3.fromRGB(255, 255, 255)
								end)
							end) 
							FastDelay(0.2, function()
								ePoint:Destroy()
							end)
						end	
					end
				end
				PhotoSiris.LightningRequested:Fire(c, c:GetAttribute("DebrisColor"))
				FastDelay(0.2, function()
					lightning:Destroy()
				end)
			end
		end)	

		PhotoSiris.LightningRequested:Connect(function(te, color)
			local sound = script.Thunder:Clone()
			local light = Instance.new("PointLight")
			light.Brightness = 5
			light.Enabled = true
			light.Range = te.BlastRadius
			local att = Instance.new("Attachment")
			att.CFrame = CFrame.new(te.Position)
			att.Parent = workspace.Terrain
			local Id
			local dist = (player.Character.PrimaryPart.Position - te.Position).magnitude
			if dist  < 256 then 
				Id = Close[RNG:NextInteger(1, #Close)]
			elseif dist < 512 then 
				Id = Medium[RNG:NextInteger(1, #Medium)]
			else 
				Id = Far[RNG:NextInteger(1, #Far)] 
			end
			sound.Volume = 2
			sound.RollOffMinDistance = 256;
			sound.RollOffMaxDistance = 2048;
			local pc = RNG:NextNumber(-2, 2) / 10
			sound.Pitch = 1 + pc
			sound.SoundId = "rbxassetid://"..Id
			sound.Parent = att
			light.Parent = att;
			FastDelay(0.1, function()
				PhotoSiris.LightningEffectRequested:Fire(sound,att,light,te)
			end)
			do
				local expDebris = script.Debris:Clone()
				expDebris.Parent = att
				expDebris.Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, color);
					ColorSequenceKeypoint.new(1, expDebris.Color.Keypoints[2].Value);
				})
				expDebris:Emit(450)
			end
		end)
		RunService.Heartbeat:Connect(function(dt)
			if ShaderData.Runner then
				for _, runner in pairs(ShaderData.Runner) do
					for _, runnerFunc in runner do
						if typeof(runnerFunc) == "function" then
							runnerFunc(dt, PhotoSiris:GetRunnerAPI())
						end
					end
				end
			end
		end)
		RunService.RenderStepped:Connect(function(dt)
			if volumetric then
				volumetric:UpdateVolumetrics(dt)
			end
		end)
	end
end
function PhotoSiris:AllFilters()
	return filters;
end
function PhotoSiris:GetLightingPeriod(t) --// Gets the index name of the current LightingPeriod that the ClockTime is within
	local CurrentTime = t or Lighting.ClockTime
	if not PhotoSiris.CurrentFilter then warn("Error: No Lighting Filter Detected.") return end
	for LightingPeriod, PeriodSettings in pairs(PhotoSiris.CurrentFilter.Periods) do
		if PeriodSettings.TimeStart < PeriodSettings.TimeEnd then --// Expected (ex: starts at 5 ends at 13)
			if CurrentTime >= PeriodSettings.TimeStart and CurrentTime < PeriodSettings.TimeEnd then
				return LightingPeriod
			end
		else --// Slightly abnormal cases where times go over midnight (ex: starts at 22 ends at 4)
			if (CurrentTime >= PeriodSettings.TimeStart and CurrentTime < 24) or CurrentTime < PeriodSettings.TimeEnd then
				return LightingPeriod
			end
		end
	end

	warn("Error: Current ClockTime ".. CurrentTime.. " is not within a specified Time Period")
end
function PhotoSiris:TweenLightToTime()
	local LightingPeriod = PhotoSiris:GetLightingPeriod()
	local set = PhotoSiris.CurrentFilter.Periods
	if set then
		local tw
		for propName, propVal in pairs({Ambient = set[LightingPeriod].Ambient, Brightness = set[LightingPeriod].Brightness, OutdoorAmbient = set[LightingPeriod].OutdoorAmbient, ShadowSoftness = set[LightingPeriod].ShadowSoftness}) do
			if not propVal then
				continue
			end
			tw = Tween(Lighting,propName,propVal,Enumeration.EasingFunction.Linear.Value,20,true)			
		end
		tw:Wait()
		PhotoSiris.Previous.Ambient = game.Lighting.Ambient
		PhotoSiris.Previous.OAmbient = game.Lighting.OutdoorAmbient
		PhotoSiris:SetSunlightEnabled(set.SunRaysEnabled)
	end
end
function PhotoSiris:ChangeAtmosphere(t)
	if not PhotoSiris.Map then
		return
	end
	local currentTimeDay = PhotoSiris:GetCurrentTimeOfDay()
	local cover = PhotoSiris.Clouds:GetAttribute("CloudCover") or 0
	local atm2key = ((currentTimeDay == "Dusk" or  currentTimeDay == "Night") and "Night" or "Day") .. (cover>= 0.95 and "Rain" or  "")
	if PhotoSiris.CurrentAtmosphere == atm2key then
		return
	end
	local photoman = PhotoSiris.Map:FindFirstChild("PhotoMan")
	if photoman then
		photoman = require(photoman)
		local atmosphere1 = photoman.Atmospheres[PhotoSiris.CurrentAtmosphere]
		local atmosphere2 = photoman.Atmospheres[atm2key]
		PhotoSiris.CloudsChanging = true
		FastDelay(t, function()
			PhotoSiris.CurrentAtmosphere = atm2key
			PhotoSiris.CloudsChanging = false
		end)
		Tween(Lighting.Atmosphere, "Density", atmosphere2.Density, "Smoother", t, true)
		Tween(Lighting.Atmosphere, "Offset", atmosphere2.Offset,  "Smoother", t, true)
		Tween(Lighting.Atmosphere, "Color", atmosphere2.Color, "Smoother", t, true)
		Tween(Lighting.Atmosphere, "Haze", atmosphere2.Haze, "Smoother", t, true)
		Tween(Lighting.Atmosphere, "Decay", atmosphere2.Decay, "Smoother", t, true)
		return Tween(Lighting.Atmosphere, "Glare", atmosphere2.Glare,  "Smoother", t, true)
	end

end
function PhotoSiris:StartWeatherClient()
	local lightTimeChanged = PhotoSiris:SetupDayCycleChange(EventUtils:GetEvent("MapReady"))
	local lightStageGrid = PhotoSiris:InitGrid()
	PhotoSiris.CloudDensityRequested:Connect(function()
		local cover = PhotoSiris.Clouds:GetAttribute("CloudCover")
		local density = PhotoSiris.Clouds:GetAttribute("CloudDensity")
		if PhotoSiris.Clouds.Density <= 0 then
			PhotoSiris.Previous.Ambient = game.Lighting.Ambient
			PhotoSiris.Previous.OAmbient = game.Lighting.OutdoorAmbient
			PhotoSiris.Previous.Brightness = game.Lighting.Brightness
			PhotoSiris.Previous.Atm.Density = game.Lighting.Atmosphere.Density
			PhotoSiris.Previous.Atm.Offset = game.Lighting.Atmosphere.Offset
			PhotoSiris.Previous.Atm.Color = game.Lighting.Atmosphere.Color
			PhotoSiris.Previous.Atm.Haze = game.Lighting.Atmosphere.Haze
			PhotoSiris.Previous.Atm.Decay = game.Lighting.Atmosphere.Decay
			PhotoSiris.Previous.Atm.Glare = game.Lighting.Atmosphere.Glare
		end

		local LightingPeriod = PhotoSiris:GetLightingPeriod()
		local set = PhotoSiris.CurrentFilter.Periods
		if set then
			local tw

			local rn = RNG:NextNumber(12, 20)
			Tween.new(rn, "Smoother", "Clouds", true, function(x)
				PhotoSiris.Clouds.Cover = ((PhotoSiris.Clouds.Cover - cover) / 2) + cover + (((PhotoSiris.Clouds.Cover - cover) / 2) * math.cos((x * math.pi) / 12))
				PhotoSiris.Clouds.Density = ((PhotoSiris.Clouds.Density - density) / 2) + density + (((PhotoSiris.Clouds.Density - density) / 2) * math.cos((x * math.pi) / 12))
				game.Lighting.Ambient = Lerps.Color3(PhotoSiris.Previous.Ambient,set[LightingPeriod].Ambient or Color3.fromRGB(130,130,130), PhotoSiris.Clouds.Density)
				game.Lighting.OutdoorAmbient = Lerps.Color3(PhotoSiris.Previous.OAmbient, set[LightingPeriod].OutdoorAmbient or Color3.fromRGB(120,120,120), PhotoSiris.Clouds.Density)
				game.Lighting.Brightness = Lerps.number(PhotoSiris.Previous.Brightness, set[LightingPeriod].Brightness or 1, x)

			end)
			local tw = PhotoSiris:ChangeAtmosphere(rn)
			if tw then
				tw:Wait()
			end
		end
		game.Lighting.Sky.CelestialBodiesShown = (PhotoSiris.Clouds.Cover <= 0.95)

	end)
	local currentTimeDay = PhotoSiris:GetCurrentTimeOfDay()
	PhotoSiris.CurrentAtmosphere = ((currentTimeDay == "Dusk" or  currentTimeDay == "Night") and "Night" or "Day") .. (PhotoSiris.Clouds.Cover >= 0.95 and "Rain" or  "")
	local player = game.Players.LocalPlayer
	local conn = lightTimeChanged:Connect(function()

		if workspace:FindFirstChild("HasLight",true) then
			if not  workspace:FindFirstChild("HasLight",true).Value then
				return
			end
		end
		game.Lighting.ClockTime = game.Lighting:GetAttribute("Clock")

		local mam = (game.Lighting.ClockTime*60)
		mam = mam/60
		if player.Character then
			local hh =  player.Character:FindFirstChild("HourHinge",true)
			if hh  then
				hh.C1 = PhotoSiris:GetHourCFrame() * CFrame.Angles(math.rad(hh.Parent.Parent:GetAttribute("StartAngle") or 0), 0, 0)
			end
			local mh =  player.Character:FindFirstChild("MinuteHinge",true)
			if mh  then
				mh.C1 = PhotoSiris:GetMinuteCFrame() * CFrame.Angles(math.rad(mh.Parent.Parent:GetAttribute("StartMAngle") or 0), 0, 0)
			end				
		end
		local lightStage = PhotoSiris:GetLightingPeriod()
		do
			for n, v in pairs(lightStageGrid) do
				if n ~= lightStage then
					lightStageGrid[n] = false;
				end
			end
		end

		if PhotoSiris.Map then
			local mapMan = PhotoSiris.Map:FindFirstChild("Manifest")
			if mapMan then
				mapMan = require(mapMan)
				Lighting.CoveCC.Enabled = mapMan.IsCove
				Lighting.CoveBloom.Enabled = mapMan.IsCove
				if mapMan.IsCove then
					Lighting.Ambient = Color3.fromRGB(47, 47, 47)
					Lighting.Ambient = Color3.fromRGB(47, 47, 47)
					Lighting.OutdoorAmbient = Color3.fromRGB(0, 160, 250)
				end
			elseif not  lightStageGrid[lightStage] then
				lightStageGrid[lightStage] = true
				PhotoSiris:TweenLightToTime()


			end
		end
		if not PhotoSiris.CloudsChanging then
			local currentTimeDay = PhotoSiris:GetCurrentTimeOfDay()
			local cover = PhotoSiris.Clouds:GetAttribute("CloudCover") or 0
			PhotoSiris:ChangeAtmosphere(RNG:NextNumber(12,20))	
		end	
		if Lighting.ClockTime == 6 then
			PhotoSiris.MoonPhase += 1
			if PhotoSiris.MoonPhase >= 8 then
				PhotoSiris.MoonPhase = 1
			end
			Lighting.Sky.MoonTextureId = PhotoSiris.MoonPhases[PhotoSiris.MoonPhase]
		end
	end)
	Lighting.Sky.MoonTextureId = PhotoSiris.MoonPhases[PhotoSiris.MoonPhase]
	local tw = PhotoSiris:ChangeAtmosphere(RNG:NextNumber(6, 12))
	if tw then
		tw:Wait()
	end
end
function PhotoSiris:ForceTime(t)
	Lighting.ClockTime = t
	local LightingPeriod = PhotoSiris:GetLightingPeriod(t)
	local set = PhotoSiris.CurrentFilter.Periods
	if set then
		local tw
		for propName, propVal in pairs({Ambient = set[LightingPeriod].Ambient, OutdoorAmbient = set[LightingPeriod].OutdoorAmbient, ShadowSoftness = set[LightingPeriod].ShadowSoftness}) do
			tw = Tween(Lighting,propName,propVal,Enumeration.EasingFunction.Linear.Value,0.5,true)			
		end
		PhotoSiris.Previous.Ambient = game.Lighting.Ambient
		PhotoSiris.Previous.OAmbient = game.Lighting.OutdoorAmbient
		tw:Wait()
		PhotoSiris:SetSunlightEnabled(set.SunRaysEnabled)
		fastSpawn(function()
			toggleLights()
		end)
	end
end
function PhotoSiris:SetBlurChannel(name,val)
	blurChannels[name].Size = val
end
function PhotoSiris:TweenFog(fogSettings)
	for k, val in pairs(fogSettings) do
		if Lighting[k] then
			Tween(Lighting, k, val, Enumeration.EasingFunction.Deceleration.Value, 2.5, false)
		end
	end
end
function PhotoSiris:InitGrid()
	return {
		["Night"] = false;
		["Dawn"] = false;
		["Day"]  = false;
		["Dusk"] = false;
		["NightOne"] = false;
		["NightTwo"] = false;
	}
end
function PhotoSiris:GetCurrentTimeOfDay()
	local ct = Lighting:GetAttribute("Clock")
	if (ct >= 0 and ct < 6) or (ct >= 18 and ct <= 24) then
		return "Night";
	elseif (ct >= 6 and ct < 6.25) then
		return "Dawn";
	elseif (ct >= 6.25 and ct < 17.75) then
		return "Day";
	elseif (ct >= 17.75 and ct < 18) then
		return "Dusk"
	end
end
PhotoSiris.TimeScale = script:GetAttribute("TimeScale") or 2.5
PhotoSiris.TimeScaleDiff = script:GetAttribute("TimeScaleDiff") or 0.1

function PhotoSiris:SetupClock(ct)
	Lighting:SetAttribute("Clock", ct)
end
function PhotoSiris:StartCycle(map)
	local tTime = 0;
	RunService.Heartbeat:Connect(function(dt)
		if _G.GameMode == "Campaign" then return end
		tTime += dt
		if (not workspace:GetAttribute("NoLightCycle")) and tTime >= PhotoSiris.TimeScale	then
			tTime = 0;
			Lighting:SetAttribute("Clock",Lighting:GetAttribute("Clock") + ((PhotoSiris.TimeScaleDiff + dt)/36))	
			if Lighting:GetAttribute("Clock") >= 24 then
				Lighting:SetAttribute("Clock",0)
			end

		end

	end)
end
function PhotoSiris:ForceCove()
	if PhotoSiris.Map then
		local mapMan = PhotoSiris.Map:FindFirstChild("Manifest")
		if mapMan then
			mapMan = require(mapMan)
			Lighting.CoveCC.Enabled = mapMan.IsCove
			Lighting.CoveBloom.Enabled = mapMan.IsCove
			Lighting.Ambient = Color3.fromRGB(47, 47, 47)
			Lighting.Ambient = Color3.fromRGB(47, 47, 47)
			Lighting.OutdoorAmbient = Color3.fromRGB(0, 160, 250)
			local photoman = PhotoSiris.Map:FindFirstChild("PhotoMan")
			if photoman then
				photoman = require(photoman)				
				local cover = PhotoSiris.Clouds:GetAttribute("CloudCover") or mapMan.InitialCloudCover
				Tween.new(1, "Smoother", "Clouds", true, function(x)
					PhotoSiris.Clouds.Cover = ((PhotoSiris.Clouds.Cover - cover) / 2) + cover + (((PhotoSiris.Clouds.Cover - cover) / 2) * math.cos((x * math.pi) / 12))
				end)
				local currentTimeDay = PhotoSiris:GetCurrentTimeOfDay()
				local atm2key = ((currentTimeDay == "Dusk" or  currentTimeDay == "Night") and "Night" or "Day") .. (cover>= 0.95 and "Rain" or  "")
				if PhotoSiris.CurrentAtmosphere == atm2key then
					return
				end
				local atmosphere1 = photoman.Atmospheres[PhotoSiris.CurrentAtmosphere]
				local atmosphere2 = photoman.Atmospheres[atm2key]
				PhotoSiris.CloudsChanging = true
				FastDelay(1, function()
					PhotoSiris.CurrentAtmosphere = atm2key
					PhotoSiris.CloudsChanging = false
				end)
				Tween(Lighting.Atmosphere, "Density", atmosphere2.Density, "Smoother", 1, true)
				Tween(Lighting.Atmosphere, "Offset", atmosphere2.Offset,  "Smoother", 1, true)
				Tween(Lighting.Atmosphere, "Color", atmosphere2.Color, "Smoother", 1, true)
				Tween(Lighting.Atmosphere, "Haze", atmosphere2.Haze, "Smoother", 1, true)
				Tween(Lighting.Atmosphere, "Decay", atmosphere2.Decay, "Smoother", 1, true)
				return Tween(Lighting.Atmosphere, "Glare", atmosphere2.Glare,  "Smoother", 1, true)
			end
		end
	end
end
function PhotoSiris:SetSunlightEnabled(enabled)
	Lighting.SunLight.Enabled = enabled
	Lighting.SunLightFar.Enabled = enabled

end
function PhotoSiris:GetMinAfterSixPM()
	return Lighting:GetMinutesAfterMidnight()-1080
end
function PhotoSiris:GetMinuteCFrame()
	local _, minutes = string.match(game.Lighting.TimeOfDay, "^(%d%d):(%d%d)")
	return  CFrame.Angles(math.rad(minutes * 6),0,0)
end
function PhotoSiris:GetHourCFrame()
	local hours, minutes = string.match(game.Lighting.TimeOfDay, "^(%d%d):(%d%d)")
	return CFrame.Angles(math.rad((hours * 30)+ (minutes * 0.5)),0,0)
end
function PhotoSiris:SetupDayCycleChange(MapReady)
	if MapReady then
		MapReady:Connect(function(map)
			PhotoSiris.Map = map;
			ShaderData.Runner = {}
			PhotoSiris:CheckNightSky()
			for _, runner in script.Runners:GetChildren() do
				ShaderData.Runner[runner.Name] = {};
				local runners = runner:GetChildren() 
				table.sort(runners, function(a,b)
					return a:GetAttribute("RunIndex") < b:GetAttribute("RunIndex")
				end)
				for _, runnerFunc in runners do
					table.insert(ShaderData.Runner[runner.Name], require(runnerFunc))
				end
			end
		end)
	end
	game.CollectionService:GetInstanceAddedSignal("DeadLight"):Connect(toggleLights)
	Lighting:GetAttributeChangedSignal("Clock"):Connect(function()
		toggleLights()	
		local Period = PhotoSiris:GetLightingPeriod()
		local P = PhotoSiris.CurrentFilter.Periods[Period]
		if P then
			PhotoSiris:SetSunlightEnabled(P.SunRaysEnabled)
		end
		PhotoSiris:CheckNightSky()

	end)
	return Lighting:GetAttributeChangedSignal("Clock")
end
function PhotoSiris:ApplyNVG(nvgS)
	if nvgS.Brightness then
		Tween(Lighting.NVGLight,"Brightness",nvgS.Brightness,Enumeration.EasingFunction.InOutQuad.Value,0.5,true)
	end
	if nvgS.Color then
		Tween(Lighting.NVGLight,"TintColor",Color.toDullerVariant(nvgS.Color.Color,0.95),Enumeration.EasingFunction.InOutQuad.Value,0.5,true)
	end
	Tween(Lighting.NVGLight,"Saturation",-1,Enumeration.EasingFunction.InOutQuad.Value,0.5,true)
	Tween(Lighting.NVGLight,"Contrast",.8,Enumeration.EasingFunction.InOutQuad.Value,0.5,true)
	Tween(Lighting,"ExposureCompensation",3,"InOutQuad",0.5,true)
	_G.HM:toggleGrain(true)
end;
function PhotoSiris:RemoveNVG()
	Tween(Lighting.NVGLight,"Brightness",0,Enumeration.EasingFunction.InOutQuad.Value,0.5,true)
	Tween(Lighting.NVGLight,"TintColor",Color3.fromRGB(255,255,255),Enumeration.EasingFunction.InOutQuad.Value,0.5,true)
	Tween(Lighting.NVGLight,"Saturation",0,Enumeration.EasingFunction.InOutQuad.Value,0.5,true)
	Tween(Lighting.NVGLight,"Contrast",0,Enumeration.EasingFunction.InOutQuad.Value,0.5,true)
	Tween(Lighting,"ExposureCompensation",0,"InOutQuad",0.5,true)

	_G.HM:toggleGrain(false)

end;
PhotoSiris.OriginalColors = {};
function PhotoSiris:ApplyThermal(char)
	Tween(Lighting.NVGLight,"Brightness",0.8,Enumeration.EasingFunction.InOutQuad.Value,0.5,true)
	Tween(Lighting.NVGLight,"TintColor",Color.toDullerVariant(Color3.fromRGB(255,255,255),0.85),Enumeration.EasingFunction.InOutQuad.Value,0.5,true)
	Tween(Lighting.NVGLight,"Saturation",-1,Enumeration.EasingFunction.InOutQuad.Value,0.5,true)
	Tween(Lighting.NVGLight,"Contrast",.8,Enumeration.EasingFunction.InOutQuad.Value,0.5,true)
	Tween(Lighting,"ExposureCompensation",3,"InOutQuad",0.5,true)

	for _, v in ipairs(workspace:GetChildren()) do
		if v:IsA("Model") and game.Players:GetPlayerFromCharacter(v) then
			if game.Players:GetPlayerFromCharacter(v) == game.Players.LocalPlayer then continue end
			for _, v2 in ipairs(v:GetDescendants()) do
				if v2:IsA("BasePart") then
					PhotoSiris.OriginalColors[v] = {v.Color;v.Material};
					v.Material = Enum.Material.Neon;	
				end
			end
		end
	end
	for _, v in ipairs(workspace.Vehicles:GetDescendants()) do
		if v:IsA("BasePart") then
			PhotoSiris.OriginalColors[v] = {v.Color;v.Material};
			v.Material = Enum.Material.Neon;
		end
	end
	PhotoSiris.MHC = workspace.ChildAdded:Connect(function(desc)
		if desc:IsA("Model") and game.Players:GetPlayerFromCharacter(desc) then
			if game.Players:GetPlayerFromCharacter(desc) == game.Players.LocalPlayer then return end
			for _, v2 in ipairs(desc:GetDescendants()) do
				if v2:IsA("BasePart") then
					PhotoSiris.OriginalColors[desc] = {desc.Color;desc.Material};
					desc.Material = Enum.Material.Neon;	
				end
			end
		end
	end)
	PhotoSiris.THC = workspace.Vehicles.DescendantAdded:Connect(function(desc)
		if desc:IsA("BasePart") then
			PhotoSiris.OriginalColors[desc] = {desc.Color;desc.Material};
			desc.Material = Enum.Material.Neon;
		end
	end)
	_G.HM:toggleGrain(true)
end;
function PhotoSiris:RemoveThermal()
	Tween(Lighting.NVGLight,"Brightness",0,Enumeration.EasingFunction.InOutQuad.Value,0.5,true)
	Tween(Lighting.NVGLight,"TintColor",Color3.fromRGB(255,255,255),Enumeration.EasingFunction.InOutQuad.Value,0.5,true)
	Tween(Lighting.NVGLight,"Saturation",0,Enumeration.EasingFunction.InOutQuad.Value,0.5,true)
	Tween(Lighting.NVGLight,"Contrast",0,Enumeration.EasingFunction.InOutQuad.Value,0.5,true)
	Tween(Lighting,"ExposureCompensation",0,"InOutQuad",0.5,true)

	_G.HM:toggleGrain(false)

	if PhotoSiris.THC then 
		PhotoSiris.THC:Disconnect()
	end
	if PhotoSiris.MHC then 
		PhotoSiris.MHC:Disconnect()
	end
	for _, v in ipairs(workspace:GetChildren()) do
		if v:IsA("Model") and game.Players:GetPlayerFromCharacter(v) then
			if game.Players:GetPlayerFromCharacter(v) == game.Players.LocalPlayer then continue end
			for _, v2 in ipairs(v:GetDescendants()) do
				if v2:IsA("BasePart") then
					v2.Material = PhotoSiris.OriginalColors[v][2]
					PhotoSiris.OriginalColors[v] = nil;			
				end
			end
		end
	end
	for _, v in ipairs(workspace.Vehicles:GetDescendants()) do
		if v:IsA("BasePart") then
			v.Material = PhotoSiris.OriginalColors[v][2]
			PhotoSiris.OriginalColors[v] = nil;			
		end
	end
end;
return PhotoSiris