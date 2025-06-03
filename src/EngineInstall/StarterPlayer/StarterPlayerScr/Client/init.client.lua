local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Resources = require(ReplicatedStorage:WaitForChild("Resources",10))
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
---
local player = Players.LocalPlayer
local Components = Resources:GetLocalTable("Components")
Resources:AddComponent("Tweener", Resources:LoadLibrary("TweenHandler")())
--- math constants
local RAD = math.rad
local COS = math.cos;
local SIN = math.sin;
local ABS = math.abs
local C3RGB = Color3.fromRGB
local OBJ = Instance.new
local CF = {
	RAW = CFrame.new,
	ANG = CFrame.Angles,
	ID = CFrame.new();
	Inverse = CFrame.new().inverse,
	TOS = CFrame.new().toObjectSpace;
	Cache = {};
} do
	CF.FAxAR = CFrame.fromAxisAngle
	CF.FAxA = function(x,y,z)
		if not y then
			x,y,z=x.x,x.y,x.z
		end
		local m=(x*x+y*y+z*z)^0.5
		if m>1e-5 then
			local si=SIN(m/2)/m
			return CF.RAW(0,0,0,si*x,si*y,si*z,COS(m/2))
		else
			return CF.ID
		end
	end
end
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
local CharacterJoints = {
	Shoulders = {};
	Hips = {};
};

_G.CharacterStance = {};
local CharState = {};
local CurrentItem = {};
-- Necessary Modules
local Enumeration = Resources:LoadLibrary("Enumeration")
local RemoteService = Resources:LoadLibrary("RemoteService")
local CameraService = Resources:LoadLibrary("CameraService")
local PseudoInstance = Resources:LoadLibrary("PseudoInstance")
local fastSpawn = Resources:LoadLibrary("FastSpawn")
local InputComp = Resources:LoadLibrary("InputComponent")
local Janitor = Resources:LoadLibrary("Janitor")
local removeElement = Resources:LoadLibrary("removeElement")
local PhotoSiris = Resources:LoadLibrary("PhotoSiris")
local Lerps = Resources:LoadLibrary("Lerps")
local EventUtils = Resources:LoadLibrary("EventUtils")
local Spring = Resources:LoadLibrary("Spring")
local Tween = Resources:LoadLibrary("Tween")
local AndList = Resources:LoadLibrary("AndList")
local FastWait = Resources:LoadLibrary("FastWait")
local isIgnored = Resources:LoadLibrary("isIgnored")
local WeaponUtils = Resources:LoadLibrary("WeaponUtils")
local Signal = Resources:LoadLibrary("Signal")

-- Shortcuts
local VEC2 = Vector2.new
local V3 = Vector3.new
local RAD = math.rad
local RNG = Random.new()
----
_G.CameraAng = VEC2(0,0)
_G.gunRecoilSpring = Spring.new(0.45,15,V3())

----
local UP_RATE = 0.05

-- Important Client Parts
local ClientSettings = require(script.Parent:WaitForChild("ClientSettings", 20))
local ItemEquipped = Signal.new()
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
local function getAlpha(easing)
	return Enumeration.EasingFunction[easing].Value
end
---------
local lastSideRecoil = {0, 0}
local  recoilAnim = {
	Pos = V3();
	Rot = V3();
	Code = nil;
}
local  cRecoilAnim = {
	Pos = V3();
	Rot = V3();
	Code = nil;
}	

do 
	local swaySpring = Spring.new(1, 4, V3())
	local stances = {} do
		for k, stance in ClientSettings.Stances do
			if stance.Value then
				if typeof(stance.Value) == "number" then
					stances[k] = stance.Value
				end
			end
		end
	end
	local function gunBob(animName, a, r, dt)
		if not CurrentItem.Animations then
			return CF.RAW()
		end
		local anim = CurrentItem.Animations[animName]
		if anim then
			return anim(a, r, walkSpeedSpring.p, Humanoid.MoveDirection * CharacterParts.HRP.Velocity.Magnitude, pDist, dt)
		end
	end
	local function gunBobIdle(a, dt)
		return ClientSettings.IdleAnimation(a, dt)
	end
	local aimAngle, NVGOffset = 0, CF.RAW()
	local walkSpeedSpring = Spring.new(0.5,8,14)
	local disabledStances = {};
	local Stance = 0;
	local stanceSway = 1	
	local stanceTrans = false
	local currentState = "Idling";
	local lastPos = V3()
	local pDist = 0
	local idleAng = 0
	local crawlAlpha = 0
	local idleAlpha = 1
	local walkAlpha = 0
	local runAlpha = 0
	local aimAlpha = 0
	local leanAnim = {
		Pos = Spring.new(0.8,16,0);
		Rot = 0;
		Change = false;
		Factor  = ClientSettings.LeanAngle or RAD(15);
	};
	local Anim = {
		Pos = V3();
		Rot = Spring.new(1,4,V3());
		Ang = 0;
		Code = 0;
	};
	local lastPos = V3()
	local MotionVector = VEC2(0,0)
	CharState.getStanceIndex = function(self,stance)
		return stances[stance]
	end

	CharState.changeStance = function(self,stance,lean,silent)
		local tween = Resources:GetComponent("Tweener")
		local pssW = stanceSway
		local stanceTme = 0.5
		if (not lean) and (not silent) then
			RemoteService.send("Server","SignalChangeStance", stance)
		end
		UP_RATE = 0.06
		stance = typeof(stance) == "number" and getStance(stance) or stance
		stanceTrans = true
		if lean then
			CharacterJoints.Hips.Left.C1 = ClientSettings.StanceCF.leg.C1[stance][1] * CF.ANG(0, -leanAnim.Rot * RAD(-90), 0)
			CharacterJoints.Hips.Right.C1 =  ClientSettings.StanceCF.leg.C1[stance][2] * CF.ANG(0, -leanAnim.Rot * RAD(90), 0)
			CharacterJoints.Root.C0 = ClientSettings.StanceCF.HRP[stance]  * CF.ANG(0,-leanAnim.Rot * leanAnim.Factor,0)
			stanceTrans = false
			return
		end

		Tween.new(stanceTme, getAlpha("OutQuad"), "stanceSway", true, function(x)
			stanceSway  = Lerps.number(pssW,(1 - (stances[stance] * 0.25)),x)
		end)
		tween("Joint",ViewModel.ABWeld, ClientSettings.StanceCF.arm[stance], false, getAlpha("OutQuad"), stanceTme)
		tween("Joint",CharacterJoints.Hips.Left, ClientSettings.StanceCF.leg.C0[stance][1], ClientSettings.StanceCF.leg.C1[stance][1], getAlpha("OutQuad"),  stanceTme)
		tween("Joint",CharacterJoints.Hips.Right, ClientSettings.StanceCF.leg.C0[stance][2], ClientSettings.StanceCF.leg.C1[stance][2], getAlpha("OutQuad"),  stanceTme)
		tween("Joint",CharacterJoints.Root, ClientSettings.StanceCF.HRP[stance], false, getAlpha("OutQuad"),  stanceTme)
		if stance == "Prone" or stance == "ProneBack" then
			FastWait(stanceTme/2)
		end
		tween("Joint",ViewModel.headWeld, ClientSettings.StanceCF.head[stance], false, getAlpha("OutQuad"),  stanceTme)
		FastWait(stanceTme)
		CharState.Stance = stances[stance]
		UP_RATE = 0.1

		stanceTrans = false
	end;

	function CharState:runAnimCF(dt)
		local tween = Resources:GetComponent("Tweener")
		local pos = UIS:GetMouseDelta()
		if InputComp.Platform == "Console" then
			pos = InputComp:GetCurrentGamepadState(Enum.KeyCode.Thumbstick2).Position
			MotionVector = VEC2(pos.X * 18, pos.Y * 18)
		elseif InputComp.Platform == "Keyboard" then
			MotionVector = VEC2(math.clamp(pos.X, -18, 18),math.clamp(pos.Y, -18, 18))
		end
		
		local animTab = {
			CurrentItemValue = CurrentItem.Value;
			CurrentItemS = CurrentItem.Settings;
			Aimed = CurrentItem.Aimed;
			gunRecoilSpring = _G.gunRecoilSpring;
			CameraService = CameraService;
			stanceSway = stanceSway;
			Lerps = Lerps;
			stanceTrans = stanceTrans;
			CF = CF;
			SIN = SIN;
			COS = COS;
			RAD = RAD;
			aimAngle = 0;
			gunbob = gunBob;
			gunbobIdle = gunBobIdle;
			Stance = Stance;
			currentState = currentState;
			bWS = bWS;
			recoilAnim = recoilAnim;
			walkSpeedSpring = walkSpeedSpring;
			aimHeadOffset = aimHeadOffset;
			AnimRot = Anim.Rot:Update(dt);
			AnimPos = Anim.Pos;
			camCF = camCF;
			resetSway = function()
				swaySpring.g = V3()
			end,
			swayCF = swaySpring;
			MotionVector = MotionVector;
			initialStockType = CurrentItem.stockType;
			isPlayingAnim = function()
				return CurrentItem:IsPlayingAnim();
			end,
			crawlAlpha = crawlAlpha;
			CameraAng = _G.CameraAng;
			setCamCF = function(cCF)
				camCF = cCF;
			end,
			setAnimPos = function(v3)
				Anim.Pos = v3
			end,
			setAnimRot = function(v3)
				Anim.Rot.g = v3
			end,
			humanRotation = function()
				local pc = workspace.CurrentCamera.CFrame
				if Humanoid.MoveDirection.X == 0 then
					return 0
				else
					return 	pc.RightVector:Dot(Humanoid.MoveDirection)
				end
			end,
			stockIndex = CurrentItem.stockIndex;
			stockFoldIndex =  _G.stockFIndex or CurrentItem.stockIndex;
			setIdleAng = function(val)
				idleAng = val
			end,
			idleAng = idleAng;
			walkAnimName = walkAnim;
			humanDirection = Humanoid.MoveDirection;
		};
		animTab.aimAngle = 0 do
			animTab.NVGOffset = NVGOffset
			animTab.aimAngle = aimAngle
			if CurrentItem.Value then
				animTab.NVG = CurrentItem.Value:GetAttribute("NVGSight");
			else
				animTab.NVG = false
			end
		end
		if CurrentItem.Value then
			local basePos = WeaponUtils:GetBasePose(CurrentItem.Value)
			if (not CurrentItem.Aimed) and (not colTweenDB) and (not Humanoid.Sit) and features("getFeature", "Collisions") then
				colTweenDB = true
				local res, hit, lerp = MH:GetCollisionData(player)
				if res and hit.CanCollide and (not CurrentItem:IsPlayingAnim()) and (CharState.currentState:lower() ~= "running") and Humanoid.MoveDirection.Magnitude <= 0 then
					local lcf = Lerps.CFrame(CurrentItem:getArmPos(basePos,"left"), CurrentItem:getArmPos("running","left"), lerp)
					local rcf = Lerps.CFrame(CurrentItem:getArmPos(basePos,"right"), CurrentItem:getArmPos("running","right"), lerp)
					local gcf = Lerps.CFrame(CurrentItem:getArmPos(basePos,"grip"), CurrentItem:getArmPos("running","grip"), lerp)
					tween("Joint", ViewModel.LWeld, false, lcf, getAlpha("Sharp"), 0.1)
					tween("Joint", ViewModel.RWeld, false, rcf, getAlpha("Sharp"), 0.1)
					tween("Joint", ViewModel.Grips[ViewModel.Grips.Current], false, gcf, getAlpha("Sharp"), 0.1)
					FastWait(0.1)
				end
				colTweenDB = false
			end
			if ViewModel.animWeld then
				local args = {}
				args[1] = dt
				args[2] = "General"
				if not Humanoid.Sit then
					local animC0, animC1 = WeaponUtils:GetAnimCF(CurrentItem.Value, animTab, unpack(args))
					ViewModel.animWeld.C0 = animC0
					ViewModel.animWeld.C1 = animC1	
				end
			end
		elseif ViewModel.animWeld then
			local args = {}
			args[1] = dt
			args[2] = "General"
			if not Humanoid.Sit then
				local animC0, animC1 = ClientSettings.defaultAnimCF(animTab, unpack(args))
				ViewModel.animWeld.C0 = animC0
				ViewModel.animWeld.C1 = animC1	
			end 
		end
	end;	

	CharState = setmetatable(CharState, {
		__index = function(self,k)
			local key = k:lower()
			if key == "stance" then
				return Stance
			elseif key == "currentstate" then
				return currentState
			elseif key == "stanceblacklist" then
				return disabledStances
			elseif key == "stancetrans" then
				return stanceTrans
			elseif key == "lean" then
				return Lean
			elseif key == "motionvector" then
				return MotionVector
			elseif key == "movedirection" then
				return Humanoid.MoveDirection
			elseif key == "lastpos" then
				return lastPos
			elseif key == "pdist" then
				return pDist
			else
				return nil;
			end
		end;
		__newindex  = function(self,k,v)
			local key = k:lower()
			if key == "walkspeed"  then
				walkSpeedSpring.g = v
			elseif  key == "crawlcamrot" then
				crawlCamRot = v
			elseif key == "bws" then
				bWS = v;
			elseif key == "motionvector" then
				MotionVector = v
			elseif key == "stance" then
				Stance = v 
			elseif key == "grounded" then
				onGround = v
			--[[elseif key == "currentstate" then
				currentState = v
				if CurrentItem.Value then
					CharState:chooseWalkAnim()
				end]]--
			elseif key == "lastpos" then
				lastPos = v
			elseif key == "pdist" then
				pDist = v;
			elseif key == "stancesway" then
				stanceSway = v
			elseif key == "stanceblacklist" then
				disabledStances = v
			elseif key == "leananim" then
				leanAnim = v;
			elseif key == "lean" then
				Lean = v
			elseif key == "leananim" then
				return leanAnim
			elseif key == "aimangle" then
				aimAngle = v
			end
		end
	})
end
-----
do
	local item = nil;
	local S = nil;
	local newMag = false;
	local Animations = {};
	local Lasers = {}; 
	local stockType = nil;
	local AttachmentMods = Resources:LoadConfiguration("AttachmentModules")	
	CurrentItem = setmetatable({
		IsPlayingAnim = function(self)
			return false
		end,
		getArmPos = function(self,pose,arm,invert)
			local pos = self:getPose(pose)[arm:lower()]
			local extraOffset = CF.RAW()
			local result = pos
			return result			
		end;
		getPose = function(self,poseN)
			if poses[poseN] then
				return poses[poseN]:GetAllPositions()
			end
			return nil
		end;
		LoadAnim = function(self,Item)
			Animations = {};
			poses = {};
			if S.poses then
				for _, pose in ipairs(S.poses) do
					poses[pose.Name] = pose;
				end
			end
			local anims =  require(Item.ANIMATIONS);
			local anims2 = require(Resources:GetCustomAnim("Global"))
			local anims4
			if _G.GameMode == "Campaign" then
				anims4 = require(Resources:GetCustomAnim("CampaignAnims"))
			end
			for name, anim in pairs(anims) do
				Animations[name] = anim
			end
			for name, anim in pairs(anims2) do
				Animations[name] = anim
			end
			if anims4 then
				for name, anim in pairs(anims4) do
					Animations[name] = anim
				end
			end

			if S.defaultAttachment then
				for _, anim3 in ipairs(S.defaultAttachments) do
					local anims3 = Resources:GetGunAttachment(anim3)
					if anims3 then
						anims3= anims3:FindFirstChild("ANIMATIONS") 
						if anims3 then
							anims3 = require(anims3)
							for name, anim in pairs(anims3) do
								Animations[name] = anim
							end								
						end
					end
				end
			end

			for k, v in (AttachmentMods.Slots) do
				local anims3 = item:GetAttribute(v.."Anims")
				if anims3 then
					anims3 = Resources:GetGunAttachment(anims3)
					if anims3 then
						anims3= anims3:FindFirstChild("ANIMATIONS") 
						if anims3 then
							anims3 = require(anims3)
							print(anims3)
							for name, anim in pairs(anims3) do
								if self:isAnimBlacklisted(name) then
									continue
								end
								Animations[name] = anim
							end								
						end
					end
				end
				local anims3 = item:GetAttribute(v.."Poses")
				if anims3 then
					anims3 = Resources:GetGunAttachment(anims3)
					if anims3:FindFirstChild("POSES") then
						for _, v in ipairs(require(anims3.POSES)) do
							poses[v.Name] = v
						end
					end
				end

			end
		end;
		PrepareItem = function(self)
			--[[
			if WeaponUtils:HasItemCapability(item, "Healer") then
				if _G.HM then
					_G.HM:GetModule("MedicalExaminer"):PopulateKit()
				end
			end
			if WeaponUtils:HasItemCapability(item, "Builder") then
				_G.HM:SetupBuilder()
				InputComp.ToggleMouseControl(true, false)

			end
			if WeaponUtils:HasItemCapability(item, "HandSwitch") then
				if S then
					Hand = S.defaultHand
					_G.HM:PerformCMAction("ShowHand", Hand)
				end
			end
			if WeaponUtils:HasItemCapability(item, "Cartridge") then
				self:setupCartridge()
			end
			if WeaponUtils:HasItemCapability(item, "FireMode") then
				FiringSystem = FSys.new();
				for i, v in ipairs(S.selectFireSettings.Modes) do
					FiringSystem:addFireMode(v,v:upper())
				end
				self:HandleExtraFireModes()
				if S.selectFireSettings.ignore then
					for i, v in pairs(S.selectFireSettings.ignore) do
						FiringSystem:addIgnoredMode(v)
					end
				end
				FiringSystem:sort(S)
				FiringSystem:showMode(S.burstSettings.Amount)
				self:HandleFireModeAppearance()
			end
			if WeaponUtils:HasItemCapability(item, "ScopeADS") or  WeaponUtils:HasItemCapability(item, "ADS") then
				CurrentItem.AimData.Entries = {};
				for _, part in ipairs(CurrentItem.Value:GetChildren()) do
					if part:IsA("BasePart") then
						if part.Name == "AimPart" then
							if part:FindFirstChild("AimOrder") then
								CurrentItem.AimData.Entries[part.AimOrder.Value] = part
							end
						end
					end
				end	
			end
			if WeaponUtils:HasItemCapability(item, "ScopeADS") then
				_G.HM:PerformCMAction("SetScopeProperty", "Time", S.aimSettings and S.aimSettings.Time or 0.3)
			end
			]]--
			WeaponUtils:RunHook(item, "PreLoad", self, {
				tween = tween;
				getAlpha = getAlpha;
				ViewModel = ViewModel;
				Character = Character;
				S = S;
			})
		end,
		Equip = function(self)
			--table.clear(Lasers)
			if not item then
				return
			end
			if WeaponUtils:HasItemCapability(item, "Recoil") then
				--self:CalculateRecoil()
			end
			if WeaponUtils:HasItemCapability(item, "Lasers") then
				Lasers = {};
				runAsync(function()
					for _, p in ipairs(item:GetChildren()) do
						if p:IsA("BasePart") then
							if p.Name == ("Laser") then
								if p:FindFirstChild("AimOrder") then
									Lasers[p.AimOrder.Value] = p;
								end
							end
						end
					end
				end)
			end
			if item:FindFirstChild("Barrel") then
				barrelColor = item.Barrel.Color
				if S.barrelOverheat then
					item.Barrel.Color = Lerps.Color3(barrelColor,BrickColor.new("Bright red").Color,item:GetAttribute("Heat") or 0)
				end
			end
			fireRate = S.roundsPerMin
			if not item:FindFirstChild("Magazine")  then
				if item:FindFirstChild("Rounds") then
					if (((#item.Rounds:GetChildren() <= 0) and (item:GetAttribute("AmmoInd") or item:GetAttribute("Ammo")) > 0)) or S.reloadSettings.has2Methods then
						if Animations["Equip"]   then
							self:PlayAnimation("Equip",true)
						end
					end
				elseif Animations["Equip"] and WeaponUtils:HasEnoughMags(player, item)  then
					self:PlayAnimation("Equip",true)
				end
			elseif  S.forceEquip then 
				if Animations["Equip"] then
					self:PlayAnimation("Equip",true)
				end
			end
			if Animations["AttachmentEquip"] then
				self:PlayAnimation("AttachmentEquip",true)
			end
			if Animations["StorageEquip"] then
				self:PlayAnimation("StorageEquip",true)
			end	
			--[[if InputComp.CurrentIScheme ~= "Gunner" and WeaponUtils:HasItemCapability(item, "ScopeADS")	then
				self:InitSight() 
			end]]--

			self:SignalEquipped()

		end;
	},{
		__index = function(self, k)
			local key = k:lower()
			if key == "settings" then
				return S
			elseif key == "value" then
				return item 
			elseif key == "stocktype" then
				return stockType 
			end
		end,
		__newindex = function(self, k, v)
			local key = k:lower()
			if key == "value" then
				item = v 
				if item then
					--if item.Type.Value == "Gun" or item.Type.Value == "Launcher" then
						--AimPart.Current = 1;
						--AimPart.Entries = {}
						--G.gunRecoilSpring.f = 8
						--AimChanged:Fire(Aimed)
					--end
				else
					--AimPart.Current = 1;
					--Aimed = false;
					--AimChanged:Fire(Aimed)
					--table.clear(Main);
					--Main = {};
					--currentMainIndex = 1;
					--currentLaserIndex = 0;
					newMag = false
					--scopeSetting = nil;
				end
			elseif key == "settings" then
				S = v
			end
		end,
	})
end
-----
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
		CharState:runAnimCF(dt)
		CharState.pDist = (CharacterParts.HRP and (CharState.pDist + (CharState.lastPos - CharacterParts.HRP.CFrame.p).magnitude) or 0)
		CharState.lastPos = CharacterParts.HRP.CFrame.p
	end)
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
local changePlayerTrans = Resources:LoadLibrary("changePlayerTrans")({
	modifiers = {
		regular = function(P, Trans, IgnoreL)
			local PD = P:GetDescendants()
			local pl = {}
			for i, v in ipairs(PD) do
				if v:IsA("BasePart") then
					if ((not v.Name:find("Glove")) and (not v:FindFirstChild("ArmPart")) and (not game.CollectionService:HasTag(v,"FArm")))  or v.Name == "Torso" then

						if (not  ((v:IsDescendantOf(CurrentItem.Value) and (not v.Parent.Name:find("_Holster"))) or isIgnored(v, IgnoreL)))  then
							table.insert(pl,v)
						elseif not CurrentItem.Value  then
							table.insert(pl,v)		
						end
					end
				end
			end
			for i, v in ipairs(pl) do
				local ig = false
				if v:IsA("BasePart") and v.Name ~= "LimbCollider" then
					task.spawn(function()
						v[Humanoid.SeatPart ~= nil and "Transparency" or "LocalTransparencyModifier"] = Trans
						v.CastShadow = false
					end)
				end
			end
		end;
		spectate = function(P, Trans)
			local PD = P:GetDescendants()
			local pl = {}
			for i, v in ipairs(PD) do
				if v:IsA("BasePart") then
					if ((not v.Name:find("Glove")) and (not v:FindFirstChild("ArmPart")) and (not game.CollectionService:HasTag(v,"FArm")))  or v.Name == "Torso" then

						if (not  ((v:IsDescendantOf(CurrentItem.Value) and (not v.Parent.Name:find("_Holster")))))  then
							table.insert(pl,v)
						elseif not CurrentItem.Value  then
							table.insert(pl,v)		
						end
					end
				end
			end
			for i, v in ipairs(pl) do
				local ig = false
				if v:IsA("BasePart") and v.Name ~= "LimbCollider" then
					task.spawn(function()
						v[Humanoid.SeatPart ~= nil and "Transparency" or "LocalTransparencyModifier"] = Trans
						v.CastShadow = false

					end)
				end
			end
		end;
		partlist  = function(LS, Trans, IgnoreL)
			local PD = LS
			if PD then
				for i, v in ipairs(PD) do
					if not v.Parent then continue end
					if v.Parent:FindFirstChild("HoldPart") or isIgnored(v, IgnoreL) then
						table.remove(PD,i)
					end
				end
				for i, v in ipairs(PD) do
					local ig = false
					if v:IsA("BasePart") and v.Name ~= "LimbCollider" and v.Parent then
						if IgnoreL then
							ig = isIgnored(v, IgnoreL)
						end
						if not ig and not v.Parent:FindFirstChild("HoldPart") then
							task.spawn(function()
								v[Humanoid.SeatPart ~= nil and "Transparency" or "LocalTransparencyModifier"] = Trans
								v.CastShadow = false
							end)
						end
					end
				end
			end
		end; 
	}
})
do 
	function getAlphaName(alpha)
		local compName ="";
		for  n, EnumName in ipairs(Enumeration.EasingFunction:GetEnumerationItems()) do
			if alpha == EnumName.Value then
				compName = EnumName.Name
				break
			end
		end				


		return compName
	end
	local tween = Resources:GetComponent("Tweener")
	tween:addTweenFunction("Joint", function(Joint,newC0,newC1,Alpha,Duration,isBlade,ignoreRepl,action)
		if not Joint then return end
		if typeof(Alpha) == "string" then 
			Alpha = getAlpha(Alpha)
		end
		task.spawn(function()
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
do
	local tween = Resources:GetComponent("Tweener")
	player.CharacterAdded:Connect(function(ch)
		Character = ch
		Humanoid = Character:WaitForChild("Humanoid", 20)
		CharacterParts.Torso = Character:WaitForChild("Torso",200)
		CharacterParts.Head = ch:WaitForChild("Head", 20)
		CharacterParts.HRP = Character.PrimaryPart
		CharacterJoints.Root = CharacterParts.HRP:WaitForChild("RootJoint",200)
		CharacterJoints.Neck = CharacterParts.Torso:WaitForChild("Neck",200)
		CharacterJoints.Hips.Left = CharacterParts.Torso:WaitForChild("Left Hip",200)
		CharacterJoints.Hips.Right = CharacterParts.Torso:WaitForChild("Right Hip",200)
		CharacterJoints.Shoulders.Left = CharacterParts.Torso:WaitForChild("Left Shoulder",200)
		CharacterJoints.Shoulders.Right = CharacterParts.Torso:WaitForChild("Right Shoulder",200)
		player.CameraMode = Enum.CameraMode.LockFirstPerson
		InputComp.ToggleMouseControl(false, InputComp.Platform ~= "Touch")
		CharacterParts.ASM = Resources:LoadLibrary("AnimateHelper")(Character)
		Humanoid:SetStateEnabled(Enum.HumanoidStateType.Swimming,false)
		CameraService:setCamMode("FirstPerson", CharacterParts.Head)
		ViewModel.Shadow = PseudoInstance.new("CharacterShadow",Character,player,{ViewModel.gunIgnore});
		ViewModel.Shadow:InitShadow()
		table.insert(Connections,Character.ChildAdded:Connect(function(item)
			if item:IsA("Model") then
				if item:FindFirstChild("Type") then
					ItemEquipped:Fire(item)
				end
			end
		end))
		table.insert(Connections, ItemEquipped:Connect(function(item)
			local itemReady = false
			if item then
				if item:FindFirstChild("Type") then
					CurrentItem.Type = item.Type.Value

					if CurrentItem.Type  ~= "Binoculars" then
						CameraService.setFOV(if Components.Settings then Components.Settings:GetGlobal("fov") else 70)
					else
						CameraService.setFOV(80)
					end
					local scheme = WeaponUtils:GetInputScheme(item)
					if scheme then
						if UIS.TouchEnabled then
							InputComp.HideScheme(InputComp.CurrentIScheme)
						end
						InputComp.CurrentIScheme = (#tostring(scheme) > 0) and scheme or nil 

						itemReady = (InputComp.CurrentIScheme ~= nil)
					end
					--if item then
					--_G.HM.Context = item;
					--else
					--_G.HM.Context = nil;
					--end
				end
			end
			if itemReady then
				CurrentItem.Value = item;
				CurrentItem.Settings = require(item.SETTINGS)
				CurrentItem:LoadAnim(CurrentItem.Value)
				local basePos = WeaponUtils:GetBasePose(CurrentItem.Value)
				local equipSettings = CurrentItem.Settings.equipSettings
				if WeaponUtils:HasItemCapability(CurrentItem.Value,"Cartridge") then
					if (not Resources:GetFlagValue("LookReady")) and player:GetAttribute("ArmoredUnit") then
						repeat
							task.wait()
						until
						_G.GunReady
					end
				end
				CurrentItem:PrepareItem()
				task.spawn(function()
					tween("Joint",ViewModel.LWeld, false, CurrentItem:getArmPos(basePos,"Left"), getAlpha("Standard"), if equipSettings then equipSettings.Time else 0.3)
					tween("Joint",ViewModel.RWeld, false, CurrentItem:getArmPos(basePos,"Right"), getAlpha("Standard"), if equipSettings then equipSettings.Time else 0.3)
					tween("Joint",ViewModel.Grips.Right, false, CurrentItem:getArmPos(basePos,"Grip"), getAlpha("Standard"), if equipSettings then equipSettings.Time else 0.3)
					CurrentItem:Equip()
				end)	
			end
		end))
		startRenders()
		table.insert(Connections,Humanoid.StateChanged:Connect(function(old,new)
			InputComp.CharacterController.State = (new)
		end))
		table.insert(Connections, Humanoid.Died:Connect(function()
			RemoteService.send("Server","ResetViewModel",{
				gunIgnore = ViewModel.gunIgnore;
				Shoulders = CharacterJoints.Shoulders;
				LArm = CharacterParts.LArm;
				RArm = CharacterParts.RArm;
				LWeld = ViewModel.LWeld;
				RWeld = ViewModel.RWeld;
				Grips = ViewModel.Grips;
			})
		end))
		InputComp.CharacterController:Enable(true)
	end)
	player.DescendantRemoving:Connect(function(c)
		if c == Character then
			if (not c.Parent) then --or c.Parent == workspace.CorpseIgnore then

				for i, conn in Connections do
					if typeof(conn) == "RBXScriptConnection" then
						conn:Disconnect()
						Connections[i] = nil
					end
				end

				--removeElement(Ignore,Character);


				for _, pluginObj in ClientPlugins do
					if pluginObj.OnCharacterRemoving then
						pluginObj.OnCharacterRemoving({
							CharacterJanitor = Jan_Char;
							RS = RunService;
							ViewModel = ViewModel;
							taskSpawn = runAsync;
							CharState = CharState;
							RemoteService = RemoteService;
							DepthOfField = game.Lighting.ItemDepth;
							ClientSettings = ClientSettings;
						}, Components)
					end

				end

				table.clear(Connections)
				InputComp.CharacterController:Enable(false)
			end
		end
	end)
end
----- Keybinds ------
local Jan = Janitor.new()
local function UpdateGeneralKeys()
	local basicMode = {
		"ADS";
		"Stance";
		"Sprint";
		"Orders";
		"Exit";
		"Menu";	
	};
	for k, stance in ClientSettings.Stances do
		if  AndList({stance.Enabled;stance.HasAction;}) then
			table.insert(basicMode, k)	
		end
	end
	InputComp.SetupGeneralIScheme({
		{
			"Basic";
			basicMode;
		},
		{
			"Specials";
			{

				"Trait";
				"CallMedic";
				"SpotContact";
			}

		}
	})	
	for k, stance in ClientSettings.Stances do
		if  AndList({stance.Enabled;stance.HasAction;}) then
			InputComp.RegisterSchemeAction("General",k,{stance.Input or InputComp:GetBindCode("Core",k)},false,function(input,gp)
				if stance.OnActivate then
					stance.OnActivate(input,gp, {
						Humanoid = Humanoid;
						CharState = CharState;
						CurrentItem = CurrentItem;
						InputComp = InputComp;
						Components = Components;
						setStanceDir = function(dir)
							stanceDir = dir
						end,
						WeaponUtils = WeaponUtils;
					})
				end
			end,true,1)		
		end
	end
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
	for _, pl in ClientPlugins do
		if pl.DefineGeneralInput then
			pl.DefineGeneralInput({
				Events = EventUtils;
				CharState  = CharState;
				
			}, Components)
		end
	end	
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
				PseudoInstance = PseudoInstance;
				CFFAxA = CF.FAxA;
				CollectionService = game:GetService("CollectionService");
				addComponent = function(name, component)
					Resources:AddComponent(name, component)
					return Resources:GetComponent(name)
				end,
				RenderEngine = RenderEngine;
				Janitor = Janitor;
				CharacterParts = CharacterParts;
				Player = player;
				getAlpha = getAlpha;
				Tween = Tween;
				Angle = AUtils;
				RemoteService = RemoteService;
				PlayerScripts = script.Parent;
				RunService = RunService;
				RayUtils = RayUtils;
				changePlayerTrans = changePlayerTrans;
			}, Components)
		end
	end
end