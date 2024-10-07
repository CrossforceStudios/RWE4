local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Resources = require(ReplicatedStorage:WaitForChild("Resources",10))
local Players = game:GetService("Players")
local player = Players.LocalPlayer
-- Setup your flags here
Resources:SetupFlags({

})
local Character = nil;
local CharacterParts = {};

_G.CharacterStance = {};
-- Necessary Modules
local RemoteService = Resources:LoadLibrary("RemoteService")
local CameraService = Resources:LoadLibrary("CameraService")
local PseudoInstance = Resources:LoadLibrary("PseudoInstance")

-- Important Client Parts
local RenderEngine = {};
local Connections = {};
--CameraService:startClient()
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
end
function startRenders()
    RenderEngine:AddGeneralRender(function(dt)
		soundUpdate(dt)					
	end)
	RenderEngine:Start()
end
player.CharacterAdded:Connect(function(ch)
    Character = ch
    CharacterParts.Head = ch:WaitForChild("Head", 20)
	player.CameraMode = Enum.CameraMode.LockFirstPerson
	InputComp.ToggleMouseControl(false, InputComp.Platform ~= "Touch")
    --CameraService:setCamMode("FirstPerson", CharacterParts.Head)
    CharacterParts.ASM = Resources:LoadLibrary("AnimateHelper")(Character)
    startRenders()
end)
