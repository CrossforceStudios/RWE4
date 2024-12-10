local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Resources = require(ReplicatedStorage:WaitForChild("Resources",10))
local Players = game:GetService("Players")
local player = Players.LocalPlayer
-- Setup your flags here
Resources:SetupFlags({

})
local Character = nil;
local Humanoid = nil;
local CharacterParts = {};

_G.CharacterStance = {};
-- Necessary Modules
local RemoteService = Resources:LoadLibrary("RemoteService")
local CameraService = Resources:LoadLibrary("CameraService")
local PseudoInstance = Resources:LoadLibrary("PseudoInstance")
local fastSpawn = Resources:LoadLibrary("FastSpawn")
local InputComp = Resources:LoadLibrary("InputComponent")
local Janitor = Resources:LoadLibrary("Janitor")
-- Shortcuts
local VEC2 = Vector2.new
local RAD = math.rad
----
_G.CameraAng = VEC2(0,0)

-- Important Client Parts
local ClientSettings = require(script.Parent:WaitForChild("ClientSettings", 20))

local RenderEngine = {};
local Connections = {};
local ViewModel = {
	gunIgnore = nil;
	playerFolder = nil;
	headWeld = nil;
	headWeld2 = nil;
	armBase = nil;
	animWeld = nil;
	ABWeld = nil;
	LWeld = nil;
	RWeld = nil;
	LWeld2 = nil;
	RWeld2 = nil;
	Grips = {
		Left = nil;
		Right = nil;
		Current = "Right";
	};
}
---------
CameraService:startClient()
local soundUpdate do
	local SoundBox2 = PseudoInstance.new("SoundBox",script.Parent.Footsteps,script.Parent.DeathSounds,script.Parent.JumpSounds)
	SoundBox2:Setup()
	--SoundBox2:SetStanceSounds(ClientSettings.StanceSounds)
	soundUpdate = function(worldDt)
		SoundBox2:UpdateAll(worldDt)
	end
end
do
	local sequences = {};
	sequences.General = {};
	sequences.Camera = {};
	function RenderEngine:Start()
		table.insert(Connections,RunService.Heartbeat:Connect(function(dt)
			for i, seqFunc in ipairs(sequences["General"]) do
				seqFunc(dt)
			end
		end))
		RunService:BindToRenderStep("UpdateCam",Enum.RenderPriority.Camera.Value,function(dt)
			--if (not CharacterParts.HAgent) or (not CharacterParts.HAgent.Health) then return end
			--if CharacterParts.HAgent.Health > 0 and (not CharacterParts.HAgent:GetStateProperty("Unconscious"))  then
				for i, seqFunc in ipairs(sequences["Camera"]) do
					seqFunc(dt)
				end
			--end
		end)
	end
	function RenderEngine:AddGeneralRender(renderFunc: (number) -> any)
		table.insert(sequences["General"], renderFunc)
	end
	function RenderEngine:AddCameraRender(renderFunc: (number) -> any)
		table.insert(sequences["Camera"], renderFunc)
	end
	RenderEngine:AddCameraRender(function(dt)
		local camOff = Vector2.new(0,0)
		CameraService.CurrentCamMode.cameraPerspective = _G.CameraAng + camOff
		InputComp.CharacterController:UpdateMovement(Character,InputComp.CharacterController.IState,mm)		
		InputComp.CharacterController:Update(dt,function(jump)
			Humanoid.Jump = jump --and Character:GetAttribute("CurrentStamina") >= threshold
		end)
		InputComp.CharacterController:UpdateJump()
		if ViewModel.headWeld and (not Humanoid.Sit) and (not Character.ExitingVehicle.Value) then
			--ViewModel.headWeld.C1 = CF.ANG(-_G.CameraAng.y - finalCamOffset.Y, 0, 0)
			ViewModel.headWeld.C1 = CFrame.Angles(-_G.CameraAng.y, 0, 0)
			--[[if CurrentItem.Aimed and angle_turn then
				ViewModel.headWeld2.C1 = CFrame.new(0, -0.5, 0) * CF.ANG(0, 0, CurrentItem.Settings.aimSettings.headTilt) * CF.RAW(0, 0.5, 0)
			elseif not CurrentItem.Aimed then
				ViewModel.headWeld2.C1 = CF.ANG(0, 0, 0)
			end ]]--
			--CharacterParts.HRP.CFrame = CF.RAW(CharacterParts.HRP.Position) * CF.ANG(0, _G.CameraAng.x + finalCamOffset.X, 0)
			CharacterParts.HRP.CFrame = CFrame.new(CharacterParts.HRP.Position) * CFrame.Angles(0, _G.CameraAng.x, 0)
		end
		--CameraService.CurrentCamMode.offset = V3(finalCamOffset.X,finalCamOffset.Y,CharState.crawlCamRot + finalCamOffset.Z + (CharState.leanAnim.Pos.p));
	end)

end
function startRenders()
    RenderEngine:AddGeneralRender(function(dt)
		soundUpdate(dt)					
	end)
	RenderEngine:Start()
end
RemoteService.listen("Client","Send","SetPartsClient",function(dict)
	for k, v  in pairs(dict) do
		ViewModel[k] = v;
	end
end)
RemoteService.listen("Client","Send","SetGripsClient",function(grips)
	ViewModel.Grips.Right = grips[1]
	ViewModel.Grips.Left = grips[2]
end)
player.CharacterAdded:Connect(function(ch)
    Character = ch
	Humanoid = Character:WaitForChild("Humanoid", 20)
    CharacterParts.Head = ch:WaitForChild("Head", 20)
	CharacterParts.HRP = Character.PrimaryPart
	player.CameraMode = Enum.CameraMode.LockFirstPerson
	InputComp.ToggleMouseControl(false, InputComp.Platform ~= "Touch")
    CameraService:setCamMode("FirstPerson", CharacterParts.Head)
    CharacterParts.ASM = Resources:LoadLibrary("AnimateHelper")(Character)
    startRenders()
	table.insert(Connections,Humanoid.StateChanged:Connect(function(old,new)
		InputComp.CharacterController.State = (new)
	end))
	InputComp.CharacterController:Enable(true)
end)
player.CharacterRemoving:Connect(function(c)
	for _, conn in Connections do
		conn:Disconnect()
	end
	table.clear(Connections)
	InputComp.CharacterController:Enable(false)
end)
----- Keybinds ------
local Jan = Janitor.new()
local function UpdateGeneralKeys()
	local function lookAround(pos,noDeg,gamepad)
		if  CameraService.CurrentCamMode then 
			if Character then
				if Humanoid then
					if  Humanoid.Health > 0 then
						--if (not CameraService.CutsceneSysBusy) and (CharState.MoveEnabled) then
						if  (not InputComp.Interacting) then
							local rawCamAng = _G.CameraAng  - pos
							_G.CameraAng  = VEC2(rawCamAng.x, (rawCamAng.y > RAD(80) and RAD(80) or rawCamAng.y < RAD(-80) and RAD(-80) or rawCamAng.y))		
							if ViewModel.headWeld then
								if ViewModel.headWeld.Part1 and ViewModel.headWeld.Part1:IsDescendantOf(workspace) then
									if Humanoid.SeatPart then
										if Humanoid.SeatPart.Name ~= "GunnerSeat" then					
											return
										end
									end
									uDelta = VEC2(if noDeg then pos.X else math.deg(pos.X),if noDeg then pos.Y else math.deg(pos.Y))
									kickCode = nil;
								end
							end		
						end
						--end	
					end
				end
			elseif CameraService.CurrentCamMode.Name:find("Spectate") then
				local rawCamAng = _G.CameraAng  - pos
				_G.CameraAng  = VEC2(rawCamAng.x, (rawCamAng.y > RAD(80) and RAD(80) or rawCamAng.y < RAD(-80) and RAD(-80) or rawCamAng.y))		
				uDelta = VEC2(if noDeg then pos.X else math.deg(pos.X),if noDeg then pos.Y else math.deg(pos.Y))
			end
		end
	end

	Jan:Add(InputComp.RegisterSchemeAxis("General","LookKeyboard",Enum.UserInputType.MouseMovement,"Rotation",Enum.KeyCode.Unknown):Connect(function(i,pos)
		lookAround(pos)
	end),"Disconnect")	
end;
local function UpdateKeys()
	UpdateGeneralKeys()
	for k, v in pairs(ClientSettings.MovementMap) do
		if typeof(v) == "table" then
			for _, ev in ipairs(v) do
				InputComp.CharacterController:SetInput(k,ev)
			end
			continue
		end
		InputComp.CharacterController:SetInput(k,v)
	end
end
fastSpawn(function()
	InputComp.SetupCharacter()
	UpdateKeys()
end)