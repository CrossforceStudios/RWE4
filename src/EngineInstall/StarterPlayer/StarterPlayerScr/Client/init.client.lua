local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Resources = require(ReplicatedStorage:WaitForChild("Resources",10))
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local Components = Resources:GetLocalTable("Components")
Resources:AddComponent("Tweener", Resources:LoadLibrary("TweenHandler")())
print(Components.Tweener)
-- ClientPlugins Loading
local ClientPlugins = {} do
	for i, pl: ModuleScript in script.Plugins:GetDescendants() do
		if pl:IsA("ModuleScript") then
			ClientPlugins[i] = require(pl)
		end
	end
end
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
local removeElement = Resources:LoadLibrary("removeElement")
local PhotoSiris = Resources:LoadLibrary("PhotoSiris")
local Lerps = Resources:LoadLibrary("Lerps")
local Enumeration = Resources:LoadLibrary("Enumeration")
local EventUtils = Resources:LoadLibrary("EventUtils")

-- Shortcuts
local VEC2 = Vector2.new
local V3 = Vector3.new
local RAD = math.rad
local RNG = Random.new()
----
_G.CameraAng = VEC2(0,0)
----
local UP_RATE = 0.05

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
	fastSpawn(function()
		while  Character.Parent do
			local animWeld = ViewModel.animWeld
			if animWeld and animWeld.Parent then
				pcall(function()
					RemoteService.sendU("Server","SignalTween",CharacterJoints.Root,CharacterJoints.Root.C0,false,"Smooth",0.2)
				end)
				task.wait(0.1)
				pcall(function()
					RemoteService.sendU("Server","SignalTween",ViewModel.headWeld,false,ViewModel.headWeld.C1,"Smooth",if UP_RATE < 0.05 then UP_RATE * 2 else UP_RATE * 2)
					RemoteService.sendU("Server","SignalTween",animWeld,animWeld.C0,animWeld.C1,"Smooth",if UP_RATE < 0.05 then UP_RATE * 2 else UP_RATE * 2)
				end)
				task.wait(if UP_RATE < 0.05 then UP_RATE * 2 else UP_RATE * 2)								
			end
			task.wait(UP_RATE)
		end
	end)
    RenderEngine:AddGeneralRender(function(dt)
		soundUpdate(dt)					
	end)
	RenderEngine:AddGeneralRender(function(dt)
		--CharState.walkSpeed = CharState:calcWalkSpeed(CurrentItem.Settings and CurrentItem.Settings.baseWalkSpeed or 14)
		--Humanoid.WalkSpeed = CharState.walkSpeed
		if  ViewModel.Shadow then
			ViewModel.Shadow:Update(Humanoid.Sit)	
		end	
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
do 
	local tween = Resources:GetComponent("Tweener")
	tween:addTweenFunction("Joint", function(Joint,newC0,newC1,Alpha,Duration,isBlade,ignoreRepl,action)
		if not Joint then return end
		if typeof(Alpha) == "string" then 
			Alpha = getAlpha(Alpha)
		end
		runAsync(function()
			if Duration <= 0 then
				if not ignoreRepl then
					if newC0 then
						Joint.C0 = newC0
						RemoteService.send("Server","SetJointC0",Joint,Joint.C0)
					end
					if newC1 then
						Joint.C1 = newC1
						RemoteService.send("Server","SetJointC1",Joint,Joint.C1)
					end
				end
			else
				if newC0 then
					local t0 = tick()
					if Joint.Name ~= "BoltWeld" then
						local tweenO = Tween(Joint, "C0", newC0, Alpha, Duration, true, function(status)
							local s0 = status
							if not ignoreRepl and tick() - t0 <= Duration then
								Joint.C0 = newC0 
							end
							if s0 == Enum.TweenStatus.Completed then
								if action and (not newC1) then action() end
							end
						end)
					else
						local tweenO = Tween(Joint, "C0", newC0, Alpha, Duration, false, function(status)
							local s0 = status
							if not ignoreRepl and tick() - t0 <= Duration then
								Joint.C0 = newC0 
							end
						end)
					end
				end
				if newC1 then
					local t0 = tick()
					if Joint.Name ~= "BoltWeld" then
						local tweenO = Tween(Joint, "C1", newC1, Alpha, Duration, true, function(status)
							local s0 = status
							if not ignoreRepl and tick() - t0 <= Duration then
								Joint.C1 = newC1 
								RemoteService.send("Server","SetJointC1",Joint,Joint.C1)
							end
							if s0 == Enum.TweenStatus.Completed then
								if action and (not newC0) then action() end
							end
						end)
					else
						local tweenO = Tween(Joint, "C1", newC1, Alpha, Duration, false, function(status)
							local s0 = status
							if not ignoreRepl and tick() - t0 <= Duration then
								Joint.C1 = newC1 
								RemoteService.send("Server","SetJointC1",Joint,Joint.C1)
							end
						end)
					end

				end
			end
		end)
		if not ignoreRepl then		
			RemoteService.sendU("Server","SignalTween",Joint,newC0 or false,newC1 or false,getAlphaName(Alpha),Duration)	
		end
	end)
	RemoteService.listenU("Client","Bounce","TweenJoint",function(joint,newC0,newC1,alphaName,duration)
		local alpha = getAlpha(alphaName)
		tween("Joint",joint,newC0,newC1,alpha,duration,false,true)
	end)
end

-------
player.CharacterAdded:Connect(function(ch)
    Character = ch
	Humanoid = Character:WaitForChild("Humanoid", 20)
    CharacterParts.Head = ch:WaitForChild("Head", 20)
	CharacterParts.HRP = Character.PrimaryPart
	player.CameraMode = Enum.CameraMode.LockFirstPerson
	InputComp.ToggleMouseControl(false, InputComp.Platform ~= "Touch")
    CharacterParts.ASM = Resources:LoadLibrary("AnimateHelper")(Character)
	Humanoid:SetStateEnabled(Enum.HumanoidStateType.Swimming,false)
    CameraService:setCamMode("FirstPerson", CharacterParts.Head)
	ViewModel.Shadow = PseudoInstance.new("CharacterShadow",Character,player,{ViewModel.gunIgnore});
	ViewModel.Shadow:InitShadow()
    startRenders()
	table.insert(Connections,Humanoid.StateChanged:Connect(function(old,new)
		InputComp.CharacterController.State = (new)
	end))
	InputComp.CharacterController:Enable(true)
end)
player.DescendantRemoving:Connect(function(c)
	if c == Character then
		if (not c.Parent) then --or c.Parent == workspace.CorpseIgnore then

			for i, conn in Connections do
				conn:Disconnect()
				Connections[i] = nil
			end
		
			for _, pluginObj in ClientPlugins do
				pluginObj.OnCharacterRemoving({
					CharacterJanitor = Jan_Char;
					RS = RunService;
					ViewModel = ViewModel;
					taskSpawn = runAsync;
					CharState = CharState;
					RemoteService = RemoteService;
					DepthOfField = game.Lighting.ItemDepth;
				}, Components)
			end

			table.clear(Connections)
			InputComp.CharacterController:Enable(false)
		end
	end
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
do
	InputComp.SetupCharacter()

	Components.Input = InputComp
	Components.Camera = CameraService
	Components.Lighting = PhotoSiris
	UpdateKeys()

	for _, pl in ClientPlugins do
		if pl.Init then
			pl.Init({
				Lerps = Lerps;
				V3 = V3;
				RNG = RNG;
				Enumeration = Enumeration;
				ClientSettings = ClientSettings;
				Events = EventUtils;
			}, Components)
		end
	end
end