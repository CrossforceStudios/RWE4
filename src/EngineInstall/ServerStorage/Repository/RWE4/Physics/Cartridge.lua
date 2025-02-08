local Cartridge = {}
local UtilService = require(game.ReplicatedStorage.Resources)
local Typer = UtilService:LoadLibrary("Typer")
local Gauge = UtilService:LoadConfiguration("Gauges")
local GaugeTypes = UtilService:LoadConfiguration("GaugeTypes")
local BarrelLengths = UtilService:LoadConfiguration("BarrelLengths")
local MathRound = UtilService:LoadLibrary("MathRound")
local BreakingPoints = UtilService:LoadConfiguration("BreakingPoints")
local SPEED_OF_SOUND = 675
Cartridge.ModifierPattern = "M%-(%a+)%s?=%s?([%-%.%d]+)"
Cartridge.PenetrationConfig = {
	[Enum.Material.Glass] = 25;
	[Enum.Material.Ice] = 25;
	[Enum.Material.Neon] = 25;
	[Enum.Material.Foil] = 25;
	[Enum.Material.Fabric] = 25;
	[Enum.Material.CorrodedMetal] = 20;
	[Enum.Material.Wood] = 20;
	[Enum.Material.WoodPlanks] = 20;
	[Enum.Material.Plastic] = 15;
	[Enum.Material.SmoothPlastic] = 15;
	[Enum.Material.Marble] = 15;
	[Enum.Material.Pebble] = 15;
	[Enum.Material.Basalt] = 15;
	[Enum.Material.Cobblestone] = 15;
	[Enum.Material.Granite] = 15;
	[Enum.Material.DiamondPlate] = 10;
	[Enum.Material.Sand] = 10;
	[Enum.Material.Slate] = 10;
	[Enum.Material.Concrete] = 10;
	[Enum.Material.Brick] = 10;
	[Enum.Material.Grass] = 10;
	[Enum.Material.Metal] = 5;
}
Cartridge.__index = Cartridge
local fragment = {};
function Cartridge.new(...)
	local cartridge = {}
	local args = {...}
	cartridge.Name = args[1]
	cartridge.Title = args[2]
	cartridge.Range = args[3]
	cartridge.OrigRange = cartridge.Range
	cartridge.InstantHit = args[4]
	cartridge.Velocity = args[5]
	cartridge.OrigVelocity = cartridge.Velocity
	cartridge.Color = args[6]
	cartridge.Transparency = args[7]
	cartridge.Size = args[8]
	cartridge.Acceleration = args[9]
	cartridge.Length = args[10]
	cartridge.Size = cartridge.Size + Vector3.new(0,0,(cartridge.Size.Z + ( cartridge.Size.Z * cartridge.Length)))
	cartridge.Modifier = nil;
	cartridge.OriginalSize = cartridge.Size
	cartridge.Damage = args[11]
	cartridge.OrigDamage = cartridge.Damage
	cartridge.Penetration = args[12] or 0;
	cartridge.OrigPenetration = cartridge.Penetration
	cartridge.Density = args[13] or 0.5
	cartridge.IsMag = args[14] or false
	cartridge.IsAntiMateriel = args[15] or false
	cartridge.IsIncendiary = args[16] or false
	
	cartridge.Gauge = false;
	cartridge.ShotAmount = 1;
	return setmetatable(cartridge,Cartridge)
end
function Cartridge:GetInventoryInfo()
	return {
		Name = self.Name;
		Title =  self.Title;
		Type = "Resource";
		StartingAmt = 0;
		Max = 1e5;
		Category = if self.isGrenade then "Grenades" else "Magazines";
		Unit = "All";
		Droppable = true;
		Pinnable = false;
		Weight = 1;
		Desc = self.Title;
	};
end
function Cartridge:CalibrateSize()
		self.Size = self.Size + Vector3.new(0,0,self.Size.Z + ( self.Size.Z * self.Length))
end
function Cartridge:getCaliberDiff()
	return self.Length/0.2
end
function Cartridge:GetPenetrationDepth(dist)
	return self.Range * dist
end
function Cartridge:CanDestroy(velocity: number, part: BasePart)
	local minVel = BreakingPoints[part.Material]
	if minVel then
		return velocity >= minVel
	end
	return false
end
function Cartridge:DestroyPart(part: BasePart, velocity)
	if part.Name == "Fragment" and (not fragment[part]) then
		fragment[part] = true
		if velocity then
			part:SetAttribute("ResVelocity", velocity)
		end
		game.CollectionService:AddTag(part,"Fragment")

		if part:GetAttribute("CTag") then
			if _G.Destruction:CanCollapse(part:GetAttribute("CTag")) then
				task.spawn(function() _G.Destruction:Collapse(part:GetAttribute("CTag")) end)
			end	
			game.CollectionService:RemoveTag(part,part:GetAttribute("CTag"))
		end
		return
	end
end
function Cartridge:GetPenetrationDecay(wall)
	return 1 - (Cartridge.PenetrationConfig[wall.Material]/25)
end
function Cartridge:resetModifiedStats()
	if not self.Modifier then  return end
	if typeof(self.Modifier) ~= "string" then return end
	local modifierProperties = {	}
	modifierProperties.Name, modifierProperties.Value = self.Modifier:match(Cartridge.ModifierPattern)
	if typeof(modifierProperties.Name) ~= "string" then return end
	modifierProperties.Value =  tonumber(modifierProperties.Value)
	if Typer.Check({"number"}, modifierProperties.Value) then
		if modifierProperties.Name == "Range" then
			self.Range = self.Range - modifierProperties.Value
			self.OrigRange = self.Range
		elseif modifierProperties.Name == "Velocity" then
			self.Velocity = self.Velocity - modifierProperties.Value
			self.OrigVelocity = self.Velocity
		elseif modifierProperties.Name == "Acceleration" then
			self.Acceleration = self.Acceleration - modifierProperties.Value
			
		end
	end
end
function Cartridge:GetShotName(gaugeIndex)
	local gi = GaugeTypes[self.Gauge.GaugeTypes[gaugeIndex]] 
	if gi then
		return gi.Name
	end
	return self.Name
end
function Cartridge:SetupGauge(gaugeIndex)
	self.Gauge =  Gauge[self.Name]
	if self.Gauge then
		for k,v in pairs(self.Gauge) do
				if self[k] ~= nil then
					if v ~= self[k] then
						self[k] = v
						if self["Orig"..k] then
							self["Orig"..k] = v
						end
					end
				end	
		end
		if gaugeIndex and self.Gauge.GaugeTypes[gaugeIndex] then
			self.Title = self.Title .. " (" .. self.Gauge.GaugeTypes[gaugeIndex] .. ")";
			for k,v in pairs(GaugeTypes[self.Gauge.GaugeTypes[gaugeIndex]]) do
				if self[k] ~= nil then
					if v ~= self[k] then
						self[k] = v
						if self["Orig"..k] then
							self["Orig"..k] = v
						end
					end
					
				end	
			end
		end
	end
end
local function getMaxSide(v)
	local result1, result2 = 0,"Z"
	for _, side in pairs({"X","Y","Z"}) do
		if v[side] > result1 then
			result1 = v[side]
			result2 = side
		end
	end
	return result1, result2
end
function Cartridge:getRequiredThickness(Wall,N)
	local  maxSideValue, maxSideKey = getMaxSide(N)
	if maxSideValue then
		return Wall.Size[maxSideKey] , maxSideKey 
	end
end

function Cartridge:getBullet(Vars)
	local Bullet = UtilService:GetSpitzer(Vars.Hollow and (self.Name.."Hollow") or self.Name):Clone()
	Bullet.PrimaryPart = Bullet:FindFirstChild("SpitzerMain");
	for _, part in ipairs(Bullet:GetChildren()) do 
		if part:IsA("BasePart") and part ~= Bullet.PrimaryPart then
			part.Anchored = true
			local shellWeld  = Instance.new("WeldConstraint")
			shellWeld.Part0 = Bullet.PrimaryPart
			shellWeld.Part1 = part
			shellWeld.Parent = Bullet
			shellWeld.Enabled = true
			part.Anchored = false
		end
	end
	return Bullet		
end
function Cartridge:SetupBarrel(Settings, Weapon)
	local bs = Settings
	if bs then
		local bLength
		local mode = bs.BarrelMode 
		if mode == "Estimate" then
			bLength  = bs.BarrelLength
		elseif mode == "Geometry" then
			local partName = bs.PartName or "MainBarrel"
			local axis = bs.BarrelAxis or "X"
			local barrel = Weapon:FindFirstChild(partName)
			if barrel then
				bLength = barrel.Size[axis]
			end
		else
			return
		end
		if not BarrelLengths[self.Name] then
			return
		end
		do
			local origVel = self.OrigVelocity
			local origRange = self.OrigRange
			local origDmg = self.OrigDamage 
			local origPenetration = self.OrigPenetration 
			bLength = MathRound(bLength, 0.001)
			if bLength > BarrelLengths[self.Name] then
				self.Velocity = origVel * (1 + ((bLength/BarrelLengths[self.Name])/10))
				self.Range = origRange * (1 + ((bLength/BarrelLengths[self.Name])/10))
				self.Damage = NumberRange.new(origDmg.Min * (1 + ((bLength/BarrelLengths[self.Name])/10)), origDmg.Max * (1 + ((bLength/BarrelLengths[self.Name])/10)))
				self.Penetration = origPenetration * (1 + ((bLength/BarrelLengths[self.Name])/10))
			elseif bLength == BarrelLengths[self.Name]  then
				self.Velocity = self.OrigVelocity
				self.Range = self.OrigRange
				self.Damage = self.OrigDamage
				self.Penetration = self.OrigPenetration
			else
				self.Velocity = origVel * (bLength/BarrelLengths[self.Name])
				self.Range = origRange * (bLength/(BarrelLengths[self.Name]))
				self.Damage = NumberRange.new(origDmg.Min * (bLength/(BarrelLengths[self.Name])), origDmg.Max * (bLength/(BarrelLengths[self.Name])))
				self.Penetration = origPenetration * (bLength/(BarrelLengths[self.Name] * .25))
			end
			if not self.IsSub then
				self.Velocity  = math.clamp(self.Velocity, SPEED_OF_SOUND, 1e6)
			end
		end
	end
end
function Cartridge:makeSubSonic(percentage: number)
	self.Velocity = SPEED_OF_SOUND * math.clamp(percentage, 0.1, 1)
	self.IsSub = true
end
function Cartridge:getShell(steel)
	local name = self.Name
	if steel then
		name = name .. "Steel"
	end
	local shell = UtilService:GetEffect(name):Clone()
	for _, part in ipairs(shell:GetChildren()) do 
		if part:IsA("BasePart") and part ~= shell.PrimaryPart then
			part.Anchored = true
			local shellWeld  = Instance.new("WeldConstraint")
			shellWeld.Part0 = shell.PrimaryPart
			shellWeld.Part1 = part
			shellWeld.Parent = shell
			shellWeld.Enabled = true
			part.Anchored = false
		end
	end
	local shellSound = shell.PrimaryPart:FindFirstChild("ShellSound")
	if not shellSound then
		shellSound = Instance.new("Sound")
		shellSound.Name = "ShellSound"
		shellSound.SoundId = "rbxassetid://325025387"
		shellSound.Volume = 2
		shellSound.RollOffMaxDistance = 60
		shellSound.RollOffMinDistance = 30
		shellSound.PlaybackSpeed = 1 + (0.5 - self.Density)
	end
	shell.PrimaryPart.CanCollide = false
	shellSound.Parent = shell.PrimaryPart

	return shell
	
end

function Cartridge:getLink()
	local shell = UtilService:GetEffect(self.Name.."Link"):Clone()
	for _, part in ipairs(shell:GetChildren()) do 
		if part:IsA("BasePart") and part ~= shell.PrimaryPart then
			part.Anchored = true
			local shellWeld  = Instance.new("WeldConstraint")
			shellWeld.Part0 = shell.PrimaryPart
			shellWeld.Part1 = part
			shellWeld.Parent = shell
			shellWeld.Enabled = true
			part.Anchored = false
		end
	end
	local shellSound = Instance.new("Sound")
	shellSound.Name = "ShellSound"
	shellSound.SoundId = "rbxassetid://325025387"
	shellSound.Volume = 0.75
	shellSound.PlaybackSpeed = 3  * self.Density
	shellSound.Parent = shell
	shell.PrimaryPart.CanCollide = false
	return shell
	
end
return Cartridge