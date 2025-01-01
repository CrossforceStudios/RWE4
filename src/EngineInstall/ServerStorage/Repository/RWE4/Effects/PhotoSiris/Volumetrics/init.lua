-- This is client only!!!

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local Resources = require(game.ReplicatedStorage.Resources)
local Enumeration = Resources:LoadLibrary("Enumeration")
Enumeration.VolumetricRenderMethod = {
	Beams = 1;
	Billboards = 2;
	Particles = 3;
	Trails = 4;
}

local player = Players.LocalPlayer

-- Camera Anchor Instance
local cameraPart = Instance.new("Part")
cameraPart.CanCollide = false
cameraPart.CanQuery = false
cameraPart.CanTouch = false
cameraPart.CastShadow = false
cameraPart.Massless = true
cameraPart.Anchored = true
cameraPart.Transparency = 1
cameraPart.Size = Vector3.new(1, 1, 1)
cameraPart.Material = Enum.Material.SmoothPlastic

local function createVolumetricBeam(transparency: number, lightEmission: number, ratioX: number, ratioY: number, spacing: number, index: number): Beam
	local beam = Instance.new("Beam")

	beam.Color = ColorSequence.new(Color3.new(.8, .8, .8))
	beam.Transparency = NumberSequence.new(transparency)
	beam.Segments = 1
	beam.TextureMode = Enum.TextureMode.Static
	beam.TextureSpeed = 0
	beam.LightEmission = lightEmission
	beam.LightInfluence = 1
	beam.Width0 = (ratioY * index) * (spacing * 2)
	beam.Width1 = (ratioY * index) * (spacing * 2)

	return beam
end

local function createVolumetricBillboard(transparency: number, viewportSize: Vector2)
	local billboard = Instance.new("BillboardGui")
	local frame = Instance.new("Frame")

	billboard.Size = UDim2.fromOffset(viewportSize.X, viewportSize.Y)
	billboard.LightInfluence = 1
	billboard.ZIndexBehavior = Enum.ZIndexBehavior.Global

	frame.Position = UDim2.new(0, -100, 0, -100)
	frame.Size = UDim2.new(1, 200, 1, 200)
	frame.BackgroundTransparency = transparency
	frame.AutoLocalize = false
	frame.Interactable = false
	frame.Active = false
	frame.Parent = billboard

	return billboard
end

local function createVolumetricTrail(transparency: number, lightEmission: number)
	local trail = Instance.new("Trail")

	trail.Transparency = NumberSequence.new(transparency)
	trail.LightInfluence = 1
	trail.LightEmission = lightEmission
	trail.TextureMode = Enum.TextureMode.Static
	trail.FaceCamera = false
	trail.Lifetime = 0.016

	return trail
end

local function renderBillboardVolumetrics(self)
	self.CamPart.Size = Vector3.new(1, 1, 1)
	local viewport = self._camViewport

	if #self._layers > 0 then
		for i, v in self._layers do
			if i > self.Depth then
				v.Enabled = false
				continue
			end
			v.Enabled = self.Visible
		end
	end

	for i = 1, self.Depth do
		local index = (i-1) * self.LayerSpacing

		local billboardGui = self._layers[i]
		local att: Attachment

		if billboardGui == nil then
			att = Instance.new("Attachment")
			billboardGui = createVolumetricBillboard(self.Transparency, viewport)
			billboardGui.Parent = att

			att.Parent = self.CamPart

			self._layers[i] = billboardGui
		else
			if not billboardGui.Enabled then
				continue
			end
			billboardGui.Size = UDim2.fromOffset(viewport.X, viewport.Y)
			billboardGui.Frame.BackgroundTransparency = self.Transparency
			att = billboardGui.Parent
			if not att:IsA("Attachment") then
				continue
			end
		end

		billboardGui.Enabled = self.Visible
		att.Position = Vector3.new(0, 0, -index)
	end
end

local function renderParticleVolumetrics(self)
	self.CamPart.Size = Vector3.new(150, 150, 1)

	if self._thread ~= nil then
		if coroutine.status(self._thread) == "running" or coroutine.status(self._thread) == "normal" then
			coroutine.close(self._thread)
			self._thread = nil
		end
	end

	self.Particles.Enabled = self.Visible	
	if self.Visible then
		self.Particles.Parent = self.CamPart
	else
		self.Particles.Parent = script
	end

	if self.Particles.Parent == script then
		self.Particles.TimeScale = 1
	end

	if self.Particles.Parent == self.CamPart then
		self._thread = task.delay(10, function()
			local tween = TweenService:Create(self.Particles, TweenInfo.new(1), {TimeScale =  0})
			tween.Completed:Once(function()
				tween:Destroy()
			end)
			tween:Play()
		end)
	end

	self.Particles.Transparency = NumberSequence.new(self.Transparency)
end

local function renderBeamVolumetrics(self)
	self.CamPart.Size = Vector3.new(1, 1, 1)

	local fov = self._camFov
	local viewport = self._camViewport
	local tan = math.tan(math.rad(fov / 2))
	local ratioY = (0.1 * tan) / 0.1
	local ratioX = (0.1 * viewport.X * tan) / viewport.Y / 0.1

	if #self._layers > 0 then
		for i, v in self._layers do
			if i > self.Depth then
				v.Enabled = false
				continue
			end
			v.Enabled = self.Visible
		end
	end

	local yScale = (math.max(self.LayerSpacing, 1) * 2)
	for i = 1, self.Depth do
		local index = (i-1) * self.LayerSpacing

		local beam = self._layers[i]
		local att0: Attachment
		local att1: Attachment

		if beam == nil then
			beam = createVolumetricBeam(self.Transparency, self.LightEmission, ratioX, ratioY, self.LayerSpacing, index)
			att0 = Instance.new("Attachment")
			att1 = Instance.new("Attachment")

			beam.Name = "Beam"..tostring(i)
			att0.Name = "AttachmentA"..tostring(i)
			att1.Name = "AttachmentB"..tostring(i)

			beam.Attachment0 = att0
			beam.Attachment1 = att1

			beam.Parent = self.CamPart
			att0.Parent = self.CamPart
			att1.Parent = self.CamPart

			self._layers[i] = beam
		else
			if not beam.Enabled then
				continue
			end
			beam.Width0 = (ratioY * index) * yScale
			beam.Width1 = (ratioY * index) * yScale
			beam.Transparency = NumberSequence.new(self.Transparency)
			beam.LightEmission = self.LightEmission
			att0 = beam.Attachment0
			att1 = beam.Attachment1
		end

		beam.Enabled = self.Visible
		att0.Position = Vector3.new((ratioX * index), 0, -index)
		att1.Position = Vector3.new(-(ratioX * index), 0, -index)
	end
end

local function renderTrailVolumetrics(self)
	local fov = self._camFov
	local viewport = self._camViewport
	local tan = math.tan(math.rad(fov / 2))
	local ratioY = (0.1 * tan) / 0.1
	local ratioX = (0.1 * viewport.X * tan) / viewport.Y / 0.1

	if #self._layers > 0 then
		for i, v in self._layers do
			if i > self.Depth then
				v.Enabled = false
				continue
			end
			v.Enabled = self.Visible
		end
	end

	for i = 1, self.Depth do
		local index = (i-1) * self.LayerSpacing

		local trail = self._layers[i]
		local att0: Attachment
		local att1: Attachment

		if trail == nil then
			trail = createVolumetricTrail(self.Transparency, self.LightEmission)
			att0 = Instance.new("Attachment")
			att1 = Instance.new("Attachment")

			trail.Name = "Trail"..tostring(i)
			att0.Name = "AttachmentA"..tostring(i)
			att1.Name = "AttachmentB"..tostring(i)

			trail.Attachment0 = att0
			trail.Attachment1 = att1

			trail.Parent = self.CamPart
			att0.Parent = self.CamPart
			att1.Parent = self.CamPart

			self._layers[i] = trail
		else
			if not trail.Enabled then
				continue
			end
			trail.Transparency = NumberSequence.new(self.Transparency)
			trail.LightEmission = self.LightEmission
			att0 = trail.Attachment0
			att1 = trail.Attachment1
		end

		trail.Enabled = self.Visible
		att0.Position = Vector3.new((ratioX * index), 0, -index)
		att1.Position = Vector3.new(-(ratioX * index), 0, -index)
	end
end

local flip = false
local function renderTrails(buff: {Trail}, delta: number)
	flip = not flip

	if flip then
		for i, v in buff do
			local att0 = v.Attachment0
			local att1 = v.Attachment1
			local attPos0 = att0.Position
			local attPos1 = att1.Position

			v.Lifetime = math.floor(delta)

			att0.Position = Vector3.new(attPos0.X, 20 + attPos0.Z, attPos0.Z)
			att1.Position = Vector3.new(attPos1.X, 20 + attPos1.Z, attPos1.Z)
		end
	else
		for i, v in buff do
			local att0 = v.Attachment0
			local att1 = v.Attachment1
			local attPos0 = att0.Position
			local attPos1 = att1.Position

			v.Lifetime = math.floor(delta)

			att0.Position = Vector3.new(attPos0.X, -20 - attPos0.Z, attPos0.Z)
			att1.Position = Vector3.new(attPos1.X, -20 - attPos1.Z, attPos1.Z)
		end
	end
end

local function cleanUp(self)
	if self.RenderMethod ~= self._previousRenderMethod then
		for i, v in self._layers do
			if v:IsA("BillboardGui") then
				v.Parent:Destroy()
			end
			if v:IsA("Beam") or v:IsA("Trail") then
				v.Attachment0:Destroy()
				v.Attachment1:Destroy()
			end
			if v:IsA("ParticleEmitter") then
				continue
			end
			v:Destroy()
		end
		table.clear(self._layers)
		for _, v in self.CamPart:GetChildren() do
			if v:IsA("ParticleEmitter") then
				continue
			end
			v:Destroy()
		end
		self.Particles.Parent = script
		self.Particles.Enabled = false

		self._previousRenderMethod = self.RenderMethod
	end
end

local Volumetrics = {}
Volumetrics.__index = Volumetrics
Volumetrics.Enum = {
	
}

function Volumetrics.new(camera: Camera, depth: number, layerSpacing: number, renderMethod: number?)
	local self = setmetatable({}, Volumetrics)

	self.Camera = camera
	self.Depth = depth
	self.LayerSpacing = layerSpacing
	self.Transparency = 0.996
	self.LightEmission = 1
	self.Visible = true
	self.RenderMethod = renderMethod or Enumeration.VolumetricRenderMethod.Beams.Value
	self.CamPart = cameraPart:Clone()
	self.Particles = script.ParticleEmitter:Clone()

	self._camFov = camera.FieldOfView
	self._camViewport = camera.ViewportSize
	self._layers = {}
	self._previousRenderMethod = renderMethod or Enumeration.VolumetricRenderMethod.Beams.Value

	self.CamPart.Parent = camera

	self:RenderVolumetrics()

	self._cameraChangedConnection = self.Camera.Changed:Connect(function(property: string)
		if property == "FieldOfView" then
			self._camFov = self.Camera.FieldOfView
			self:RenderVolumetrics()
		elseif property == "ViewportSize" then
			self._camViewport = self.Camera.ViewportSize
			self:RenderVolumetrics()
		end
	end)

	return self
end

function Volumetrics:RenderVolumetrics()
	cleanUp(self)
	
	if self.RenderMethod == Enumeration.VolumetricRenderMethod.Beams.Value then
		self.Particles.Parent = script
		renderBeamVolumetrics(self)
		return
	end
	if self.RenderMethod == Enumeration.VolumetricRenderMethod.Billboards.Value then
		self.Particles.Parent = script
		renderBillboardVolumetrics(self)
		return
	end
	if self.RenderMethod == Enumeration.VolumetricRenderMethod.Particles.Value then
		renderParticleVolumetrics(self)
		return
	end
	if self.RenderMethod == Enumeration.VolumetricRenderMethod.Trails.Value then
		renderTrailVolumetrics(self)
		return
	end
	warn("Volumetrics: Invalid render method, aborting...")
end

local rayparams = RaycastParams.new()
rayparams.IgnoreWater = true
rayparams.FilterType = Enum.RaycastFilterType.Exclude

function Volumetrics:UpdateVolumetrics(dt: number)
	self.CamPart.CFrame = self.Camera.CFrame

	if self.RenderMethod == Enumeration.VolumetricRenderMethod.Trails.Value then
		renderTrails(self._layers, dt)
	end
end

function Volumetrics:Destroy()
	for _, v in ipairs(self._layers) do
		if v:IsA("BillboardGui") then
			if v.Parent then
				v.Parent:Destroy()
			end
		end
		if v:IsA("Beam") then
			v.Attachment0:Destroy()
			v.Attachment1:Destroy()
		end
		v:Destroy()
	end

	if self._cameraChangedConnection then
		self._cameraChangedConnection:Disconnect()
	end

	self.Particles:Destroy()
	self.CamPart:Destroy()

	table.clear(self._layers)
	table.clear(self)
	table.freeze(self)
end

return Volumetrics