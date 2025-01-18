local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local PhysicsService = game:GetService("PhysicsService")
local Lighting = game:GetService("Lighting")
local Resources = require(ReplicatedStorage:WaitForChild("Resources",10))
-- Setup your flags here
Resources:SetupFlags({

})
-- Necessary Modules
local Players = game:GetService("Players")
local RemoteService = Resources:LoadLibrary("RemoteService")
local EventSystem = Resources:LoadLibrary("EventUtils")
local createViewModel = Resources:LoadLibrary("createViewModel")
local FactionService = Resources:LoadLibrary("FactionService")
local PhotoSiris = Resources:LoadLibrary("PhotoSiris")
local FastDelay = Resources:LoadLibrary("FastDelay")

-- Event System
local ServerSettings = require(script.Parent.ServerSettings)
for _, event in ServerSettings.Events do
    EventSystem:AddEvent(event)
end
-- Arm C0 Values
local armC0 = {
	CFrame.new(-1.5, 0, 0) * CFrame.Angles(math.rad(90), 0, 0);
	CFrame.new(1.5, 0, 0) * CFrame.Angles(math.rad(90), 0, 0);
}
-- Other values
local Grips = {};
local gunIgnores = {};
local animWelds = {};
------

for _, pair in ServerSettings.CollisionPairs do
	if pair[1] == "Default" or pair[2] == "Default" then
		if PhysicsService:IsCollisionGroupRegistered(pair[1]) and PhysicsService:IsCollisionGroupRegistered(pair[2]) then
			PhysicsService:CollisionGroupSetCollidable(pair[1], pair[2], pair[3])
		else
			if pair[1] == "Default" then
				PhysicsService:RegisterCollisionGroup(pair[2])
			else
				PhysicsService:RegisterCollisionGroup(pair[1])
			end
			PhysicsService:CollisionGroupSetCollidable(pair[1], pair[2], pair[3])
		end
	else
		if PhysicsService:IsCollisionGroupRegistered(pair[1]) and PhysicsService:IsCollisionGroupRegistered(pair[2]) then
			PhysicsService:CollisionGroupSetCollidable(pair[1], pair[2], pair[3])
		else
			PhysicsService:RegisterCollisionGroup(pair[1])
			PhysicsService:RegisterCollisionGroup(pair[2])
			PhysicsService:CollisionGroupSetCollidable(pair[1], pair[2], pair[3])
		end
	end
end
-----
function runInit(plr: Player)
	plr.CharacterAdded:Connect(function(c)
		local head = c:WaitForChild("Head",200)
		local torso  = c:WaitForChild("Torso",200)
		local ViewM do
			local RArm = c:FindFirstChild("Right Arm")
			local LArm = c:FindFirstChild("Left Arm")
			local ViewM2, gripTab = createViewModel(plr, c, torso, armC0, gMH)
			head:SetNetworkOwner(plr)
			torso:SetNetworkOwner(plr)
			ViewM = ViewM2
			LArm.Size = Vector3.new(0.8,2,0.8)
			RArm.Size = Vector3.new(0.8,2,0.8)
			Grips[plr] = {
				Right = gripTab[1];
				Left = gripTab[2];
			}
			gunIgnores[plr] = ViewM.gunIgnore;
			animWelds[plr.Name] = ViewM.animWeld;	
			task.delay(0.5, function()
				RemoteService.send("Client",plr,"SetPartsClient", ViewM)
				RemoteService.send("Client",plr,"SetGripsClient",gripTab)
			end)
		end
	end)
	task.delay(10, function()
		if true then
			plr:LoadCharacter()
		end
	end)
end
EventSystem:ConnectEvent("PlayerAdded", runInit)
-----
RemoteService.listen("Server","Send","SetJointC0",function(player,Joint,JC0,set)
	pcall(function() if Joint then 	if  Joint.Part0 then  if (Joint.Part0:GetNetworkOwner() == player or table.find(jointIgnore,Joint.Name)) then	   Joint.C0 = JC0  end end end end)
end)
RemoteService.listen("Server","Send","SetJointC1",function(player,Joint,JC1,set)
	pcall(function() if Joint then if Joint.Part1 then if (Joint.Part1:GetNetworkOwner() == player or table.find(jointIgnore,Joint.Name)) then Joint.C1 = JC1   end end end end)
end)
RemoteService.listen("Server","Send","SetAJointC0",function(player,Joint,JC0)
	pcall(function()
		if Joint then
			if Joint.Part0 then
				if Joint.Part0:GetNetworkOwner() == player and Joint.Name == "animWeld" then 
					Joint.C0 = JC0
				end
			end
		end
	end)
end)
RemoteService.listenU("Server","Send","SignalTween",function(player,Joint,newC0,newC1,aName,Duration)
	if Joint then
		RemoteService.bounceOthersU("Client",player,"TweenJoint",Joint,newC0,newC1,aName,Duration)
		FastDelay(Duration,function()
			if newC0 then
				Joint.C0 = newC0
			end
			if newC1 then
				Joint.C1 = newC1
			end
		end)	
	end

end)
RemoteService.listen("Server","Send","SetAJointC1",function(player,Joint,JC1)
	pcall(function()
		if Joint then
			if Joint.Part1 then
				if Joint.Part1:GetNetworkOwner() == player and Joint.Name == "animWeld" then 
					Joint.C1 = JC1
				end
			end
		end
	end)
end)
-----
Players.PlayerAdded:Connect(function(plr)
	EventSystem:FireEvent("PlayerAdded", plr)
end)
FactionService:startServer()
-----
print(Resources:FindGlobalFeature("DayNightCycle"))
if Resources:FindGlobalFeature("DayNightCycle") then
	PhotoSiris:SetupClock(Lighting.ClockTime)
	PhotoSiris:StartCycle()
end