local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Resources = require(ReplicatedStorage:WaitForChild("Resources"))
local PseudoInstance = Resources:LoadLibrary("PseudoInstance")
local Typer = Resources:LoadLibrary("Typer")
local FastDelay = Resources:LoadLibrary("FastDelay")
local Lerps = Resources:LoadLibrary("Lerps")
local Joint = Resources:LoadLibrary("Joint")
local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")
local SoundService = game:GetService("SoundService")
local SoundSys = Resources:LoadLibrary("SoundSystem")
local Make = Resources:LoadLibrary("Make")
local Table = Resources:LoadLibrary("Table")
local fastSpawn = Resources:LoadLibrary("FastSpawn")
local SeriesM = Resources:LoadLibrary("SeriesMath")
local WaterS = Resources:LoadLibrary("Water")
local StatusSounds = Resources:LoadConfiguration("StatusSounds")
local lp = Players.LocalPlayer
local footprintsFolder = lp.PlayerScripts:FindFirstChild("Footprints") 

local SFX = {
	Died = 0;
	Running = 1;
	Swimming = 2;
	Climbing = 3,
	Jumping = 4;
	GettingUp = 5;
	FreeFalling = 6;
	FallingDown = 7;
	Landing = 8;
	Splash = 9;
	Stance = 10;
	Calm = 11;
	Fear = 11;

}

local LoopedSounds = {
	Climbing = true,
	FreeFalling = true,
	Running = true,	
}

local decay = {
	["Sand"] = 2,
	["Snow"] = 5,
}

local WaterSound = {"rbxassetid://130778103",1.6,.4,true};

local RNG = Random.new()

local function CreateNewSound(name, id, looped, pitch, parent)
	local sound = Make("Sound"){
		SoundId = id;
		Name = name;
		Archivable = false;
		Pitch = pitch;
		Looped = looped;
		EmitterSize = 50;
		SoundGroup = SoundService.SettingSounds.Game_FX;
		Volume = 0.65;
		Parent = parent;
	}
	CollectionService:AddTag(sound,"RemotelyPlayable")
	return sound
end


 
return PseudoInstance:Register("SoundBox",{
	Internals = {
		Sounds = {};
		Head = {};
		stanceTable = {};
		HorizontalSpeed = function(self, Head)
			local hVel = Head.Velocity + Vector3.new(0,-Head.Velocity.Y,0)
			return hVel.magnitude	
		end;
		VerticalSpeed = function(self, head)
			return math.abs(head.Velocity.Y)
		end;
		Play = function(self, sound)	
			if sound.TimePosition ~= 0 then
				sound.TimePosition = 0
			end
			if not sound.IsPlaying then
				sound.Playing = true
			end
		end;
		Pause = function(self, sound)
			if sound and sound.IsPlaying then
				sound.Playing = false
			end
		end;
		Resume = function(self, sound)
			if not sound.IsPlaying then
				sound.Playing = true
			end
		end;
		Stop = function(self, sound)
			if sound.IsPlaying then
				sound.Playing = false
			end
			if sound.TimePosition ~= 0 then
				sound.TimePosition = 0
			end
		end;
		playerSoundList = Players:GetPlayers();
		playingLoopedSounds = {};
		activeState = {};
		fallSpeed = {};
		dead = {};
		currentSpeed = {};
		stateUpdateHandler = {

			[Enum.HumanoidStateType.RunningNoPhysics] = function(self ,plr, speed)
				self.StateUpdated:Fire(Enum.HumanoidStateType.Running, plr, speed)
			end;

			[Enum.HumanoidStateType.Running] = function(self, plr, speed)	
				local sound = self.Sounds[plr][SFX.Running]
				self:stopPlayingLoopedSoundsExcept(plr,sound)
			end;

			[Enum.HumanoidStateType.Swimming] = function(self, plr, speed)
				local threshold = speed
				local hum = plr.Character:FindFirstChildOfClass("Humanoid")
				do
					local sound = self.Sounds[plr][SFX.Swimming]
					if not hum then sound.Playing = false return end
					sound.SoundId = WaterSound[1]
					sound.Pitch = (self.currentSpeed[plr]/14) * (WaterSound[2])
					sound.Volume = WaterSound[3]
					self:stopPlayingLoopedSoundsExcept(plr,sound)
					sound.Playing = hum:GetState() == Enum.HumanoidStateType.Swimming
					self:setSoundInPlayingLoopedSounds(plr,sound)
				end
			end;

			[Enum.HumanoidStateType.Climbing] = function(self, plr, speed)
				local sound = self.Sounds[plr][SFX.Climbing]
				sound.Playing = speed ~= nil and math.abs(speed) > 0.1
				self:stopPlayingLoopedSoundsExcept(plr,sound)
				self:setSoundInPlayingLoopedSounds(plr,sound)
			end;

			[Enum.HumanoidStateType.Jumping] = function(self, plr)
				if self.activeState[plr] == Enum.HumanoidStateType.Jumping then
					return
				end		
				self:stopPlayingLoopedSoundsExcept(plr)
				local humanoid = (plr:IsA("Player") and  plr.Character or plr):FindFirstChildOfClass("Humanoid")
				if not humanoid then
					return
				end
				local sound =  self.Sounds[plr][SFX.Jumping]
				if sound then
					local s2 = self.JumpSounds.Jump:FindFirstChild(humanoid.FloorMaterial.Name)
					if s2 then
						sound.SoundId = s2.SoundId 			
						sound.Volume = s2.Volume 
						sound.EmitterSize = s2.Volume * 25
						self:Play(sound)
					end
					
				end
				
			end;

			[Enum.HumanoidStateType.GettingUp] = function(self, plr2)
				self:stopPlayingLoopedSoundsExcept(plr2)
				local sound = self.Sounds[plr2][SFX.GettingUp]
				self:Play(sound)
			end;

			[Enum.HumanoidStateType.Freefall] = function(self, plr2)
				if self.activeState[plr2] == Enum.HumanoidStateType.Freefall then
					return
				end
				local sound = self.Sounds[plr2][SFX.FreeFalling]
				sound.Volume = 0
				self:stopPlayingLoopedSoundsExcept(plr2)

				self.fallSpeed[plr2] = math.max(self.fallSpeed[plr2], math.abs(self.Head[plr2].Velocity.y))
			end;

			[Enum.HumanoidStateType.FallingDown] = function(self, plr2)
				self:stopPlayingLoopedSoundsExcept(plr2)
			end;

			[Enum.HumanoidStateType.Landed] = function(self, plr2)
				self:stopPlayingLoopedSoundsExcept(plr2)
				if self:VerticalSpeed(self.Head[plr2]) > 37.5 then
					local landingSound = self.Sounds[plr2][SFX.Landing]
					local humanoid =  (plr2:IsA("Player") and  plr2.Character or plr2):FindFirstChildOfClass("Humanoid")
					if not humanoid then
						return
					end
					local FloorMaterial = humanoid.FloorMaterial
					if WaterS:IsSubmergedPart(humanoid.Parent:FindFirstChild("Right Leg")) or WaterS:IsSubmergedPart(humanoid.Parent:FindFirstChild("Left Leg")) then
						FloorMaterial = Enum.Material.Water
					end
					local s2 = self.JumpSounds.Land:FindFirstChild(FloorMaterial.Name)
					if s2 then
						landingSound.SoundId = s2.SoundId
						landingSound.PlaybackSpeed = s2.PlaybackSpeed
						landingSound.Volume = math.clamp(
							SeriesM:YForLineGivenXAndTwoPts(
								self:VerticalSpeed(self.Head[plr2]), 
								25, 0, 
								50, 1),
								0,1
							)
						
						landingSound.Playing = true		
					end
				end
			end;

			[Enum.HumanoidStateType.Seated] = function(self, plr2)
				self:stopPlayingLoopedSoundsExcept(plr2)
			end;	
		};
		stateRemap = {
			RunningNoPhysics = "Running";	
		};
		loopedSoundUpdaters = {
			[SFX.Climbing] = function(self, c, plr2, sound, stepDeltaSeconds)
				sound.Playing = c.PrimaryPart.Velocity.Magnitude > 0.1
			end,

			[SFX.FreeFalling] = function(self, c, plr2, sound,  stepDeltaSeconds)
				if c.PrimaryPart.Velocity.Magnitude > 75 then
					sound.Volume = math.clamp(sound.Volume + 0.9*stepDeltaSeconds, 0, 1)
				else
					sound.Volume = 0
				end
			end,


			[SFX.Running] = function(self, c, plr2, sound, stepDeltaSeconds)
				local humanoid = c:FindFirstChildOfClass("Humanoid")
				local FloorMaterial = humanoid.FloorMaterial
				
				if FloorMaterial == Enum.Material.Air then 
					sound.Playing = false
					return
				end
				local vel = c.PrimaryPart.Velocity
				if math.abs(vel.Y) >= 1 then 
					sound.Playing = false
					return
				end
				if WaterS:IsSubmergedPart(c:FindFirstChild("Right Leg")) or WaterS:IsSubmergedPart(c:FindFirstChild("Left Leg")) then
					FloorMaterial = Enum.Material.Water
				end
				sound.SoundId = self.RunningSounds:FindFirstChild(FloorMaterial.Name).SoundId 			
				sound.Volume = self.RunningSounds:FindFirstChild(FloorMaterial.Name).Volume  * (vel.Magnitude/14) 
				sound.Looped = true
				sound.EmitterSize = self.RunningSounds:WaitForChild(FloorMaterial.Name).Volume * (vel.Magnitude/14) * 50
				sound.Playing = vel.Magnitude > 0.5
				if sound.Playing then
					sound.PlaybackSpeed = self.RunningSounds:FindFirstChild(FloorMaterial.Name).PlaybackSpeed  * (vel.Magnitude/18) 
					sound.PlaybackSpeed = sound.PlaybackSpeed - ((sound.PlaybackSpeed*0.9)*stepDeltaSeconds)
				end					
				
			end,
		}
	};
	
	Properties = {
		RunningSounds = Typer.OptionalInstanceOfClassFolder;
		DeathSounds = Typer.OptionalInstanceOfClassFolder;
		JumpSounds = Typer.OptionalInstanceOfClassFolder;

	};
	
	Events = {
		"StateUpdated";
	};
	
	Methods = {
		RemovePlayer = function(self, plr)
			self.Janitor:Remove(plr.Name.."StateChanged")
			self.Janitor:Remove(plr.Name.."CharAdd")
			self.Janitor:Remove(plr.Name.."CharRemoved")
			self.Janitor:Remove(plr.Name.."Running")
			self.Janitor:Remove(plr.Name.."Running")
			for _, v in pairs(self.Sounds[plr]) do
				self.Janitor:Remove(plr.Name.."Sound"..v.Name)
			end
			--table.clear(Sounds[plr2])
			self.Sounds[plr] = {};
			self.playingLoopedSounds[plr] = nil;
			self.activeState[plr] = nil;
			self.fallSpeed[plr] = nil;
			self.currentSpeed[plr] = nil;
		end,
		setSoundInPlayingLoopedSounds = function(self, plr,sound)
			for i=1, #self.playingLoopedSounds[plr] do
				if self.playingLoopedSounds[plr][i] == sound then
					return
				end
			end	
			table.insert(self.playingLoopedSounds[plr],sound)
		end;
		stopPlayingLoopedSoundsExcept= function(self, plr,except)
			for i=#self.playingLoopedSounds[plr],1,-1 do
				if self.playingLoopedSounds[plr][i] ~= except then
					self:Pause(self.playingLoopedSounds[plr][i])	
					Table.QuickRemove(self.playingLoopedSounds[plr],i)
				end
			end
		end;
		Die = function(self, plr)
			if plr:IsA("Model") then
				if plr:GetAttribute("Headshot") then
					return
				end
				if CollectionService:HasTag(plr,"Fainted") then
					return
				end
				if workspace:GetAttribute("GameOver") then
					return
				end
				local Head = plr.Head
				local att = Instance.new("Attachment")
				att.CFrame = Head.CFrame 
				att.Parent = workspace.Terrain
				local ds = self.DeathSounds:GetChildren()
				local sound = ds[RNG:NextInteger(1,#ds)]:Clone()
				sound.PlaybackSpeed += RNG:NextNumber(-0.1,0.1)
				self:stopPlayingLoopedSoundsExcept(plr,sound)
				sound.RollOffMaxDistance = 256
				sound.RollOffMinDistance = 64
				sound.Parent = att
				sound:Play()
				sound.Ended:Connect(function()
					att:Destroy()
				end)
			elseif not self.dead[plr] then
				self.dead[plr] = true
				if plr.Character:GetAttribute("Headshot") then
					return
				end
				if CollectionService:HasTag(plr.Character,"Fainted") then
					return
				end
				if workspace:GetAttribute("GameOver") then
					return
				end
				local Head = plr.Character.Head
				local att = Instance.new("Attachment")
				att.CFrame = Head.CFrame 
				att.Parent = workspace.Terrain
				local ds = self.DeathSounds:GetChildren()
				local sound = ds[RNG:NextInteger(1,#ds)]:Clone()
				sound.PlaybackSpeed += RNG:NextNumber(-0.05,0.05)
				self:stopPlayingLoopedSoundsExcept(plr,sound)
				sound.RollOffMaxDistance = 256
				sound.RollOffMinDistance = 64
				sound.Parent = att
				sound.Playing = true
				task.delay(sound.TimeLength, function()
					sound:Destroy()
					att:Destroy()
				end)
				if plr:IsA("Player") then
					self.dead[plr] = false
				end
			end
		end,
		Setup = function(self)
			for _, plr in ipairs(self.playerSoundList) do
				fastSpawn(function() self:AddPlayer(plr) end)
			end
			for _, mob in ipairs(workspace.Mobs:GetChildren()) do
				fastSpawn(function() self:AddMob(mob) end)
			end
			self.Janitor:Add(workspace.Mobs.ChildAdded:Connect(function(mob)
				self:AddMob(mob)
			end))
			self.Janitor:Add(Players.PlayerAdded:Connect(function(plr)
				self:AddPlayer(plr)
				table.insert(self.playerSoundList, plr)
			end))
			self.Janitor:Add(Players.PlayerRemoving:Connect(function(plr)
				self:RemovePlayer(plr)
				table.remove(self.playerSoundList, table.find(self.playerSoundList, plr))

			end))
			self.Janitor:Add(self.StateUpdated:Connect(function(state,plr,speed)
				if plr:IsA("Model") then
					if plr.Human.FloorMaterial == Enum.Material.Air then
						return
					end
					if state == Enum.HumanoidStateType.Swimming  then 
						self.stateUpdateHandler[Enum.HumanoidStateType.Swimming](self,plr,speed)
						return
					end
					if self.stateUpdateHandler[state] ~= nil then
						if (state == Enum.HumanoidStateType.Running 
							or state == Enum.HumanoidStateType.Climbing
							or state == Enum.HumanoidStateType.Swimming
							or state == Enum.HumanoidStateType.RunningNoPhysics)  then
							self.stateUpdateHandler[state](self,plr,speed)
						else
							self.stateUpdateHandler[state](self,plr)
						end
					end
					self.activeState[plr] = state
					return
				end
				if plr.Character:GetAttribute("Silent") then
					return
				end
				if plr.Character:GetAttribute("Status") == "Swimming" then 
					self.stateUpdateHandler[Enum.HumanoidStateType.Swimming](self,plr,speed)
					return
				end
				if state == Enum.HumanoidStateType.Swimming  then 
					self.stateUpdateHandler[Enum.HumanoidStateType.Swimming](self,plr,speed)
					return
				end
				if self.stateUpdateHandler[state] ~= nil then
					if (state == Enum.HumanoidStateType.Running 
						or state == Enum.HumanoidStateType.Climbing
						or state == Enum.HumanoidStateType.Swimming
						or state == Enum.HumanoidStateType.RunningNoPhysics) then
						self.stateUpdateHandler[state](self,plr,speed)
					else
						self.stateUpdateHandler[state](self,plr)
					end
				end
				self.activeState[plr] = state
			end),"Disconnect")
		end,
		Update = function(self, c, plr2, stepDeltaSeconds)
			if c and self.Sounds[plr2] then
				if c.PrimaryPart then
					local hum = c:FindFirstChildOfClass("Humanoid")
					if hum then
						if hum:GetState() == Enum.HumanoidStateType.Swimming then 
							local updater = self.loopedSoundUpdaters[SFX.Swimming]
							local sound = self.Sounds[plr2][SFX.Swimming]
							if sound and updater then
								updater(self, c, plr2, sound, stepDeltaSeconds)
							end
							return
						elseif c:GetAttribute("Status") == "Climbing" then
							local sound = self.Sounds[plr2][SFX.Climbing]
							local speed = c.PrimaryPart.Velocity.Magnitude
							sound.Playing = speed ~= nil and math.abs(speed) > 0.1
							self:stopPlayingLoopedSoundsExcept(plr2,sound)
							self:setSoundInPlayingLoopedSounds(plr2,sound)
						elseif c:GetAttribute("Status") == Enum.HumanoidStateType.Swimming.Name then 
							local updater = self.loopedSoundUpdaters[SFX.Swimming]
							local sound = self.Sounds[plr2][SFX.Swimming]
							if sound and updater then
								updater(self, c, plr2, sound, stepDeltaSeconds)
							end
							return
						end
						self.activeState[plr2], self.currentSpeed[plr2] = hum:GetState(), c.PrimaryPart.Velocity.Magnitude;
						local stateName = self.stateRemap[self.activeState[plr2].Name] or self.activeState[plr2].Name
						local digit = SFX[stateName]
						local updater = self.loopedSoundUpdaters[digit]
						local sound = self.Sounds[plr2][digit]
						if updater and sound then
							updater(self, c, plr2, sound, stepDeltaSeconds)
						end
					end

				end
			end
		end;
		UpdateAll = function(self, stepDeltaSeconds)
			for _, plr2 in ipairs(Players:GetPlayers()) do
				if plr2.Character then
					self:Update(plr2.Character, plr2, stepDeltaSeconds)
				end
			end
			for _, v in ipairs(workspace.Mobs:GetChildren()) do
				if v:IsA("Model") then
					self:Update(v, v, stepDeltaSeconds)
					
				end
			end	
		end,
		SetStanceSounds = function(self, stanceTable)
			self.stanceTable = stanceTable
		end,
		AddMob = function(self, mob)
			self.playingLoopedSounds[mob] = {};
			self.activeState[mob] = false;
			self.fallSpeed[mob] = 0;
			self.currentSpeed[mob] = 0;
			self.Sounds[mob] = {}
			local Figure = mob
			self.Head[mob] = Figure:WaitForChild("Head")
			local head = self.Head[mob]
			CreateNewSound("GettingUp", "rbxasset://sounds/action_get_up.mp3", false, 1, head)
			CreateNewSound("FreeFalling", "rbxasset://sounds/action_falling.mp3", true, 1, head)
			CreateNewSound("Jumping", "rbxassetid://130778269", false, 1, head)
			CreateNewSound("Landing", "rbxasset://sounds/action_jump_land.mp3", false, 1, head)
			CreateNewSound("Splash", "rbxasset://sounds/impact_water.mp3", false, 1, head)
			CreateNewSound("Running", "", true, 1.85, head)
			CreateNewSound("Swimming", "rbxasset://sounds/action_swim.mp3", true, 3, head)
			CreateNewSound("Climbing", "rbxassetid://9113814820", true, 1, head)

			self.Sounds[mob][SFX.Running] = 		self.Head[mob]:WaitForChild("Running")
			self.Sounds[mob][SFX.Swimming] = 	self.Head[mob]:WaitForChild("Swimming")
			self.Sounds[mob][SFX.Climbing] = 	self.Head[mob]:WaitForChild("Climbing")
			self.Sounds[mob][SFX.Jumping] = 		self.Head[mob]:WaitForChild("Jumping")
			self.Sounds[mob][SFX.GettingUp] = 	self.Head[mob]:WaitForChild("GettingUp")
			self.Sounds[mob][SFX.FreeFalling] = 	self.Head[mob]:WaitForChild("FreeFalling")
			self.Sounds[mob][SFX.Landing] = 		self.Head[mob]:WaitForChild("Landing")
			self.Sounds[mob][SFX.Splash] = 		self.Head[mob]:WaitForChild("Splash")
			script.StatusSound:Clone().Parent = mob.Head
			self.Sounds[mob][SFX.Climbing].Volume =  4.5
			mob:WaitForChild("Human",20)
			local vel = 0;
			local mi = table.find(workspace.Mobs:GetChildren(),mob)
			self.Janitor:Add(mob.Human.Running:Connect(function(a)
				local vel2 = mob.PrimaryPart.Velocity
				if math.abs(vel2.Y) >= 1 then 
					self.Sounds[mob][SFX.Running].Playing = false
					return
				end
				self.Sounds[mob][SFX.Running].PlaybackSpeed 	= self.RunningSounds:WaitForChild(mob.Human.FloorMaterial.Name).PlaybackSpeed * (a/18) * (math.random(30,50)/40)					
				self.Sounds[mob][SFX.Running].Volume 		= self.RunningSounds:WaitForChild(mob.Human.FloorMaterial.Name).Volume * (vel/14)
				self.Sounds[mob][SFX.Running].EmitterSize 	= self.RunningSounds:WaitForChild(mob.Human.FloorMaterial.Name).Volume * (vel/14) * 50
				vel = a
			end),"Disconnect",mi.."Running")
			self.Janitor:Add(self.Sounds[mob][SFX.Running].DidLoop:Connect(function()
				local FloorMaterial = mob.Human.FloorMaterial
				if FloorMaterial and footprintsFolder then
					local footprint = footprintsFolder:FindFirstChild(FloorMaterial.Name)
					if footprint then
						footprint = footprint:Clone()
						footprint:PivotTo(mob.PrimaryPart.CFrame * CFrame.new(0, -(mob.PrimaryPart.Size.Y * 1.5), 0) * CFrame.new(0, -footprint.PrimaryPart.Size.Y, 0))
						footprint.Parent = workspace.HoleStorage
						game.Debris:AddItem(footprint, decay[FloorMaterial.Name] or 3)
					end
				end
			end),"Disconnect")
			self.Janitor:Add(mob.Human.StateChanged:connect(function(old, new)
				local speed
				if new == Enum.HumanoidStateType.Swimming then
					speed = (mob.Human.WalkSpeed * 0.1)
				elseif new == Enum.HumanoidStateType.Running then
					
				end
				self.StateUpdated:Fire(new,mob,speed)
			end),"Disconnect", mi .. "StateChanged")
			self.Janitor:Add(mob:GetAttributeChangedSignal("Status"):Connect(function()
				if mob:GetAttribute("Status") then
					if mob:GetAttribute("Status") == "Climbing" then
						self.Sounds[mob][SFX.Climbing]:Play()
						return
					end
					if StatusSounds[mob:GetAttribute("Status")] then
						local list = StatusSounds[mob:GetAttribute("Status")]
						if #list > 0 then
							mob.Head.StatusSound.SoundId = "rbxassetid://" .. list[RNG:NextInteger(1,#list)]
							mob.Head.StatusSound:Play()
							if mob:GetAttribute("Status") == "Burning" then
								task.delay(mob.Head.StatusSound.TimeLength, function()
									mob.Head.StatusSound:Stop()
								end)
							end
						end
					end
				else
					self.Sounds[mob][SFX.Climbing]:Stop()
				end
			end), "Disconnect")
			for _, v in pairs(self.Sounds[mob]) do
				self.Janitor:Add(v,"Destroy",mi.."Sound"..v.Name)
			end
			self.Janitor:Add(mob.Human.Died:Connect(function(h)
				if not mob:GetAttribute("Status") then
					self:Die(mob)
				else
					mob.Head.StatusSound.Looped = false
				end
			end),"Disconnect")
			self.Janitor:Add(mob.Human.Died:Connect(function()
				
				self.Janitor:Remove(mi.."StateChanged")
				self.Janitor:Remove(mi.."Running")
				self.Janitor:Remove(mi.."Running")
				for _, v in pairs(self.Sounds[mob]) do
					self.Janitor:Remove(mi.."Sound"..v.Name)
				end
				--table.clear(Sounds[plr2])
				self.Sounds[mob] = {};
			end),"Disconnect",mi.."CharRemoved")
		end,
		AddPlayer = function(self, plr)
			self.playingLoopedSounds[plr] = {};
			self.activeState[plr] = false;
			self.fallSpeed[plr] = 0;
			self.currentSpeed[plr] = 0;
			self.Sounds[plr] = {}
			self.Janitor:Add(plr.CharacterAdded:Connect(function(c)
				local Figure = c
				self.Head[plr] = Figure:WaitForChild("Head",20)
				local head = self.Head[plr]
				CreateNewSound("GettingUp", "rbxasset://sounds/action_get_up.mp3", false, 1, head)
				CreateNewSound("FreeFalling", "rbxasset://sounds/action_falling.mp3", true, 1, head)
				CreateNewSound("Jumping", "rbxassetid://130778269", false, 1, head)
				CreateNewSound("Landing", "rbxasset://sounds/action_jump_land.mp3", false, 1, head)
				CreateNewSound("Splash", "rbxasset://sounds/impact_water.mp3", false, 1, head)
				CreateNewSound("Running", "", true, 1.85, head)
				CreateNewSound("Swimming", "rbxasset://sounds/action_swim.mp3", true, 3, head)
				CreateNewSound("Climbing", "rbxassetid://9113814820", true, 1, head)
				CreateNewSound("Stance", "", false, 1, head)


				self.Sounds[plr][SFX.Running] = 		self.Head[plr]:WaitForChild("Running")
				self.Sounds[plr][SFX.Swimming] = 	self.Head[plr]:WaitForChild("Swimming")
				self.Sounds[plr][SFX.Climbing] = 	self.Head[plr]:WaitForChild("Climbing")
				self.Sounds[plr][SFX.Jumping] = 		self.Head[plr]:WaitForChild("Jumping")
				self.Sounds[plr][SFX.GettingUp] = 	self.Head[plr]:WaitForChild("GettingUp")
				self.Sounds[plr][SFX.FreeFalling] = 	self.Head[plr]:WaitForChild("FreeFalling")
				self.Sounds[plr][SFX.Landing] = 		self.Head[plr]:WaitForChild("Landing")
				self.Sounds[plr][SFX.Splash] = 		self.Head[plr]:WaitForChild("Splash")
				self.Sounds[plr][SFX.Stance] = 		self.Head[plr]:WaitForChild("Stance")
				script.StatusSound:Clone().Parent = c.Head
				self.Sounds[plr][SFX.Climbing].Volume =  4.5
				c:WaitForChild("Humanoid",20)
				local vel = 0;
				self.Janitor:Add(c.Humanoid.Running:Connect(function(a)
					if plr == Players.LocalPlayer  then return end
					if c.Humanoid.FloorMaterial == Enum.Material.Air then
						return
					end
					self.Sounds[plr][SFX.Running].PlaybackSpeed 	= self.RunningSounds:WaitForChild(c.Humanoid.FloorMaterial.Name).PlaybackSpeed * (a/18) * (math.random(30,50)/40)					
					self.Sounds[plr][SFX.Running].Volume 		= self.RunningSounds:WaitForChild(c.Humanoid.FloorMaterial.Name).Volume * (vel/14)
					self.Sounds[plr][SFX.Running].EmitterSize 	= self.RunningSounds:WaitForChild(c.Humanoid.FloorMaterial.Name).Volume * (vel/14) * 50
					vel = a
				end),"Disconnect",plr.Name.."Running")
				self.Janitor:Add(c.Humanoid.StateChanged:connect(function(old, new)
					local speed
					if new == Enum.HumanoidStateType.Swimming then
						speed = (c.Humanoid.WalkSpeed * 0.1)
					elseif new == Enum.HumanoidStateType.Dead then
						return
					end
					self.StateUpdated:Fire(new,plr,speed)
				end),"Disconnect",plr.Name .. "StateChanged")
				if Resources:FindGlobalFeature("Footprints") then
					self.Janitor:Add(self.Sounds[plr][SFX.Running].DidLoop:Connect(function()
						local FloorMaterial = c.Humanoid.FloorMaterial
						if FloorMaterial and footprintsFolder then
							local footprint = footprintsFolder:FindFirstChild(FloorMaterial.Name)
							if footprint then
								footprint = footprint:Clone()
								footprint:PivotTo(c.PrimaryPart.CFrame * CFrame.new(0, -(c.PrimaryPart.Size.Y * 1.5), 0) * CFrame.new(0, -footprint.PrimaryPart.Size.Y, 0))
								footprint.Parent = workspace.HoleStorage
								game.Debris:AddItem(footprint, decay[FloorMaterial.Name] or 3)
							end
						end
					end),"Disconnect")
				end
				for _, v in pairs(self.Sounds[plr]) do
					self.Janitor:Add(v,"Destroy",plr.Name.."Sound"..v.Name)
				end
				self.Janitor:Add(c:GetAttributeChangedSignal("Status"):Connect(function()
					if c:GetAttribute("Status") then
						if c:GetAttribute("Status") == "Climbing" then
							self.Sounds[plr][SFX.Climbing]:Play()
							return
						end
						if StatusSounds[c:GetAttribute("Status")] then
							local list = StatusSounds[c:GetAttribute("Status")]
							if #list > 0 then
								c.Head.StatusSound.SoundId = "rbxassetid://" .. list[RNG:NextInteger(1,#list)]
								c.Head.StatusSound:Play()
							end
						end
					else
						self.Sounds[plr][SFX.Climbing]:Stop()

					end
				end), "Disconnect")
				self.Janitor:Add(plr.Character.Humanoid.Died:Connect(function(h)
					if not c:GetAttribute("Status") then
						self:Die(plr)
					else
						c.Head.StatusSound.Looped = false
					end
				end),"Disconnect")
				self.Janitor:Add(plr.Character:GetAttributeChangedSignal("Stance"):Connect(function()
					local sound = self.Sounds[plr][SFX.Stance]
					sound.SoundId = self.stanceTable[plr.Character:GetAttribute("Stance")][1]
					sound.Volume = self.stanceTable[plr.Character:GetAttribute("Stance")][2]
					sound:Play()
				end),"Disconnect",plr.Name .. "Stance")
			end),"Disconnect",plr.Name .. "CharAdd")
			
			self.Janitor:Add(plr.CharacterRemoving:Connect(function()
				self.Janitor:Remove(plr.Name.."StateChanged")
				self.Janitor:Remove(plr.Name.."Running")
				self.Janitor:Remove(plr.Name.."Stance")

				for _, v in pairs(self.Sounds[plr]) do
					self.Janitor:Remove(plr.Name.."Sound"..v.Name)
				end
				--table.clear(Sounds[plr2])
				self.Sounds[plr] = {};
			end),"Disconnect",plr.Name.."CharRemoved")
		end,
	};
	
	Init = function(self, fs , ds, js)
		self:superinit()
		self.RunningSounds = fs;
		self.DeathSounds = ds;
		self.JumpSounds = js;

	end,
	
})