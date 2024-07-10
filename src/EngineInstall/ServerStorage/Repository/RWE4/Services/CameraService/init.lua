local CameraService = {}
local CamMode = require(script.CamMode)
local RAD = math.rad
local SIN = math.sin
local CF = CFrame.new
local VEC2 = Vector2.new
local V3 = Vector3.new
local MIN = math.min
local Resources = require(game.ReplicatedStorage.Resources)
local FastSpawn = Resources:LoadLibrary("FastSpawn")
local Enumeration = Resources:LoadLibrary("Enumeration")
local Lerps = Resources:LoadLibrary("Lerps")
local Tween = Resources:LoadLibrary("Tween")
local CameraShaker = Resources:LoadLibrary("CameraShaker")
local Spring = Resources:LoadLibrary("Spring")


CameraService.CurrentModeVars = {}
if not _G.CurrentCameraInfo then
	_G.CurrentCameraInfo = {
		Humanoid = nil;
		Vector = Vector3.new()
	};
end
function CameraService:SetCurrentHumanoid(humanoid)
	_G.CurrentCameraInfo.Humanoid = humanoid
end
function CameraService:SetCameraOffset(v)
	_G.CurrentCameraInfo.Vector = v;
end
CameraService.Cam = workspace.CurrentCamera
CameraService.CFrame = CameraService.Cam.CFrame
CameraService.Focus = nil;
local LastCompNumber = 0
CameraService.CurrentCamMode = _G.currentCamMode or nil;
CameraService.PreviousCamMode = _G.currentCamMode or nil;
CameraService.Angles = VEC2(0,0)
CameraService.FPActive =  false;
CameraService.FOVCFrame = CameraService.CFrame;
CameraService.FOVAmount = CameraService.Cam.FieldOfView
CameraService.CurrentState = "None";
function CameraService:CreateModeMoment(name,...)
	return CamMode.CreateMode(name,...)
end
local RS = game:GetService("RunService")
CameraService.setFixedCam = function(CamCF)
	CameraService.Cam.CameraType = Enum.CameraType.Fixed
	CameraService.Cam.CFrame = CamCF
end
CameraService.setCustomCam = function(Character)
	CameraService.Cam.CameraSubject = Character.Humanoid
	CameraService.Cam.CameraType = Enum.CameraType.Custom
end
CameraService.scriptCam = function(scriptFunc)
	CameraService.Cam.CameraType = Enum.CameraType.Scriptable
	scriptFunc()
end
CameraService.setFOV = function(FOV)
	CameraService.Cam.FieldOfView = FOV
end
function CameraService:tweenCam(Mode,Alpha,Duration,...)
	if CameraService.CurrentCamMode then
		Mode.Subject = CameraService.CurrentCamMode.Subject
	end
	CameraService.CurrentState = "Tween"
	local args = {...}
	if args[1] then
		Mode.Subject = args[1]
	end
	FastSpawn(function()
		Tween.new(Duration, Alpha, "CamCF", true, function(x)
			CameraService.CFrame = Lerps.CFrame(CameraService.CurrentCamMode:getCFrame(),Mode:getCFrame(),x)
		end):Wait()
		self:setCamMode(Mode.Name,Mode.Subject)
		CameraService.CurrentState = "None"
	end)
end
function CameraService:tweenToMode(camMode,Alpha,Duration,...)
	local newMode = CameraService:CreateModeMoment(camMode)
	local args = {...}
	if args[1] then
		newMode.Subject = args[1]
	end
	CameraService:tweenCam(newMode,Alpha,Duration,...)

end
function CameraService:setCamMode(mode,...)
	CameraService.Cam.CameraType = Enum.CameraType.Scriptable
	if mode then
		local oldMoment = CameraService.CurrentCamMode
		local result = CameraService:CreateModeMoment(mode)
		if result then
			CameraService.CurrentCamMode = result
			_G.CurrentCamMode = result.Name
			local args = {...}
			if args[1] then
				CameraService.CurrentCamMode.Subject = args[1]
				return true
			else
				if oldMoment then
					CameraService.CurrentCamMode.Subject = args[1] or oldMoment.Subject
					return true
				end
			end
		end
	end
end
CameraService.currentShakeCF = CF()
CameraService.CamShaker = CameraShaker.new(Enum.RenderPriority.Camera.Value + 1,function(shakeCF)
	CameraService.currentShakeCF = shakeCF
end)
CameraService.CamShaker:Start()
function CameraService:Shake(shakeType)
	CameraService.CamShaker:Shake(CameraShaker.Presets[shakeType])
end

function CameraService:ShakeTrip(shakeParams)
	local c = CameraShaker.CameraShakeInstance.new(10, 0.15, 5, 10)
	c.PositionalInfluence = Vector3.new()
	c.RotationalInfluence = shakeParams
	CameraService.CamShaker:Shake(c)
end
function CameraService:ShakeExplosion(desc)
	local ExDist = (game.Players.LocalPlayer.Character.Head.Position - desc.Position).magnitude
	local ShakeMagnitude = ExDist/(desc.BlastRadius/8)
	if ShakeMagnitude < 25 then
		CameraService.CamShaker:Start()
		CameraService.CamShaker:ShakeOnce(desc.BlastRadius/2, 5, 0, 1)
	end
end
function CameraService:ShakeBump(desc, posInf, rotInf)
	local effect = CameraService.CamShaker.Presets[desc.."Bump"]
	if effect then
		if posInf then
			effect.PositionInfluence = posInf
		end
		if rotInf then
			effect.RotationInfluence = rotInf
		end
		CameraService.CamShaker:Shake(effect)
	end
end
function CameraService:ShakeVibration(desc)
	local effect = CameraService.CamShaker.Presets["Vibration"]
	if effect then
		CameraService.CamShaker:Shake(effect)
	end
end
function CameraService:GetSize()
	return CameraService.Cam.ViewportSize
end
function CameraService:SetRoll(roll)
	CameraService.Cam:SetRoll(roll)
end
function CameraService:GetCFrameFrom2dPosition(x,y)
	local ray = CameraService.Cam:ScreenPointToRay(x,y,0)
	if ray then
		local h,p,n = workspace:FindPartOnRayWithIgnoreList(ray,{workspace.ignoreModel})
		return CF(CameraService.Cam.CFrame.p,p)
	end
end
function CameraService:GetCFrame2DCast(x,y,dist)
	local ray = CameraService.Cam:ScreenPointToRay(x,y,0)
	if ray then
		ray = Ray.new(ray.Origin,ray.Direction * dist)
		local h,p,n = workspace:FindPartOnRayWithIgnoreList(ray,{workspace.ignoreModel})
		return CF(CameraService.Cam.CFrame.p,p)
	end
end

function CameraService:startClient()
	RS:BindToRenderStep("CameraService_Cam",Enum.RenderPriority.Camera.Value+1,function(dt)
		CameraService.Cam.CameraType = Enum.CameraType.Scriptable
		if CameraService.CurrentCamMode and CameraService.CurrentState == "None" then
			if CameraService.ObscuringParts ~= nil then
				for _, part in CameraService.ObscuringParts do
					if part.LocalTransparencyModifier > 0 then
						part.LocalTransparencyModifier = 0
						for _, partCh in part:GetChildren() do
							if partCh:IsA("Texture") or  partCh:IsA("Decal") then
								partCh.LocalTransparencyModifier = 0
							end
						end
					end
				end
			end
			local camCF, camFocus = CameraService.CurrentCamMode:getCFrame(dt,CameraService.CurrentModeVars)
			CameraService.CFrame = camCF * CameraService.currentShakeCF
			if camFocus then
				CameraService.Cam.Focus = camFocus
				local ignore = {} do
					table.insert(ignore, workspace.Mobs)
					table.insert(ignore, workspace.ignoreModel)
					for _, plr in game.Players:GetPlayers() do
						table.insert(ignore, plr.Character)
					end
				end
				local size = CameraService.Cam.ViewportSize
				CameraService.ObscuringParts = CameraService.Cam:GetPartsObscuringTarget({camFocus.Position;}, ignore)
				if CameraService.ObscuringParts then
					for _, part in CameraService.ObscuringParts do
						if part.Transparency < 1 then
							part.LocalTransparencyModifier = 0.875
							for _, partCh in part:GetChildren() do
								if partCh:IsA("Texture") or  partCh:IsA("Decal") then
									partCh.LocalTransparencyModifier = 0.875
								end
							end
						end
					end
				end
			end
		end
		CameraService.Cam.CFrame = CameraService.CFrame
		if _G.CurrentCameraInfo.Humanoid then
			local off = _G.CurrentCameraInfo.Vector
			CameraService.Cam.CFrame *= CF(off);
		end

	end)
end
return CameraService