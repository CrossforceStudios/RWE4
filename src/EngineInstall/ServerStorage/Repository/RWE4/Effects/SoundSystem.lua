-- Services
local RunService	= game:GetService("RunService")

if not RunService:IsClient() then
	error("Sound System is to be run on the client. Use RemoteEvents to have the client create the sound.")
end
local Resources = require(game.ReplicatedStorage.Resources)
local SoundService = game:GetService("SoundService")
local FastDelay = Resources:LoadLibrary("FastDelay")
local Zone = Resources:LoadLibrary("Zone")
local Tween = Resources:LoadLibrary("Tween")
local fastSpawn = Resources:LoadLibrary("FastSpawn")
local EventUtils = Resources:LoadLibrary("EventUtils")

-- Localize maths for optimization
local acos,cos,pi	= math.acos,math.cos,math.pi
local v3,cf			= Vector3.new,CFrame.new
local dot			= v3().Dot
local newInst,getType	= Instance.new,typeof


-- Camera setup
local Camera	= workspace.CurrentCamera


-- Setup system
local SoundSystem		= {}
SoundSystem.Zones = {};
local CurrentObjects	= {}
local Zones
local MaxDist = 500;

function SoundSystem:GetSoundCat(catName)
	return SoundService.SettingSounds:FindFirstChild(catName)
end

fastSpawn(function()
	repeat RunService.Heartbeat:Wait() until EventUtils:GetEvent("MapReady")
	local conn
	EventUtils:ConnectEvent("MapReady",function(map)
		if conn then
			conn:Disconnect()
			conn = nil
		end
		print("Map: ", map)

		if map then
			if map:FindFirstChild("Manifest") then
				local man = require(map.Manifest)
				Zones = {};
				SoundService.AmbientReverb = man.DefaultReverb or Enum.ReverbType.NoReverb
				for _, part in ipairs(map.ReverbAreas:GetChildren()) do
					if not part:IsA("BasePart") then
						continue
					end
					SoundSystem.Zones[part] = Enum.ReverbType[part.Name]
					Zones[part] = Zone.new(part)
					Zones[part].localPlayerEntered:Connect(function()
						SoundService.AmbientReverb = SoundSystem.Zones[part]
					end)
					Zones[part].localPlayerExited:Connect(function()
						local zone3 = nil
						for part2, zone2 in pairs(Zones) do
							if zone2:findLocalPlayer() then
								zone3 = zone2
								break;
							end
						end
						if not zone3 then
							SoundService.AmbientReverb = man.DefaultReverb
						end
					end)
				end
				conn = map.ReverbAreas.ChildAdded:Connect(function(part)
					SoundSystem.Zones[part] = Enum.ReverbType[part.Name]
					Zones[part] = Zone.new(part)
					Zones[part].localPlayerEntered:Connect(function()
						SoundService.AmbientReverb = SoundSystem.Zones[part]
					end)
					Zones[part].localPlayerExited:Connect(function()
						local zone3 = nil
						for part2, zone2 in pairs(Zones) do
							if zone2:findLocalPlayer() then
								zone3 = zone2
								break;
							end
						end
						if not zone3 then
							SoundService.AmbientReverb = man.DefaultReverb
						end
					end)
				end)
				MaxDist = map:GetExtentsSize().Magnitude
			end
		end
	end)

end)

local player = game.Players.LocalPlayer
local musicObject = player:FindFirstChild("MusicStream")
local musicConn
if not musicObject then
	musicObject = Instance.new("Sound")
	musicObject.Name = "MusicStream"
	musicObject.SoundGroup = SoundSystem:GetSoundCat("Game_OST")
	musicObject.Parent = player
end

local songs = {};

export type CampaignSong = {
	Id: string;
	Title: string;
	SongRange: NumberRange;
	Volume: number;
}

function SoundSystem:RegisterSong(name: string, props: CampaignSong)
	songs[name] = props
end


function SoundSystem:PlayMusic(name, looped)
	local song: CampaignSong | nil = songs[name]
	if song then
		musicObject.SoundId = song.Id
		musicObject.TimePosition = song.SongRange.Min
		musicObject.Volume = song.Volume
		musicObject.Looped = looped or false
		local timePos = musicObject.TimePosition
		musicObject:Play()
		musicConn = RunService.Heartbeat:Connect(function(dt)
			timePos += dt
			if timePos >= song.SongRange.Max then
				musicObject:Stop()
				musicConn:Disconnect()
				musicConn = nil
				if musicObject.Looped then
					SoundSystem:PlayMusic(name, looped)
				end
			end
		end)
	end
end

local exemptProps = {
	Echo = true;
	Silenced  = true;
};
local AmbZones = {}
function SoundSystem:ClearAmbience()
	for k, v in pairs(AmbZones) do
		v:destroy()
		AmbZones[k] = nil
	end
end
local buttons = {};

function SoundSystem:StartButtonClient(sound: Sound, soundMan)
	game.CollectionService:GetInstanceAddedSignal("SoundBtn"):Connect(function(instance)
		buttons[instance] = instance.Activated:Connect(function()
			if instance:GetAttribute("SoundType") then
				sound.SoundId = "rbxassetid://" .. soundMan[instance:GetAttribute("SoundType")]
			else
				sound.SoundId = "rbxassetid://9119720940"
			end
			sound.SoundGroup = SoundSystem:GetSoundCat("UI_FX")
			sound:Play()
		end)
	end)
	game.CollectionService:GetInstanceRemovedSignal("SoundBtn"):Connect(function(instance)
		buttons[instance]:Disconnect()
		buttons[instance] = nil;
	end)
end
function SoundSystem:MuffleSounds(soundCat, unmuffle, tween, alpha, duration)
	local ss =  self:GetSoundCat(soundCat)
	local equalizer = Instance.new("EqualizerSoundEffect")
	equalizer.Name = "FlashMuffle"
	equalizer.Parent = ss
	local oso = Instance.new("NumberValue")
	oso.Value = ss.Volume
	oso.Name = "OriginalVolume"
	oso.Parent =  ss
	if tween then
		Tween(ss,"Volume",0.1,alpha or "Standard",duration or 2.7,false)
		Tween(equalizer,"MidGain",-80,alpha or "Standard",duration or 2.7,false)
		Tween(equalizer,"HighGain",-80,alpha or "Standard",duration or 2.7,false)
		Tween(equalizer,"LowGain",0,alpha or "Standard",duration or 2.7,false):Wait()

	end
	equalizer.HighGain = -80
	equalizer.MidGain = -80
	equalizer.LowGain = 0
	ss.Volume = 0.1
	local function unmuffle()
		self:UnmuffleSounds()
	end
	if unmuffle then
		fastSpawn(unmuffle)
	end
end
function SoundSystem:UnmuffleSounds(sc, alpha, duration)
	local ss = self:GetSoundCat("Game_FX")
	local equalizer = ss:FindFirstChild("FlashMuffle")
	if  equalizer then
		if ss:FindFirstChild("OriginalVolume") then
			Tween(ss,"Volume",ss.OriginalVolume.Value,alpha or "Standard",duration or 2.7,false)
		end
		Tween(equalizer,"MidGain",equalizer.MidGain + (160 * 0.5),alpha or "Standard",duration or 2.7,false)
		Tween(equalizer,"HighGain",equalizer.HighGain + (160 * 0.5),alpha or "Standard",duration or 2.7,false):Wait()
		equalizer:Destroy()
		equalizer = nil;
		if ss:FindFirstChild("OriginalVolume") then
			ss.OriginalVolume:Destroy()
		end
	end
end
function SoundSystem:AddAmbience(map, ClientSettings)
	if map.ReverbAreas:FindFirstChild("Ambience") then
		for _, v in map.ReverbAreas.Ambience:GetChildren() do
			if v:IsA("BasePart") then
				if ClientSettings.Sounds[v.Name] then
					local sound  = Instance.new("Sound")
					sound.Name = "AmbientSound"
					sound.SoundId = ClientSettings.Sounds[v.Name].Id
					sound.Volume = 0
					if ClientSettings.Sounds[v.Name].Pitch then
						sound.PlaybackSpeed  = ClientSettings.Sounds[v.Name].Pitch
					end
					sound.SoundGroup = self:GetSoundCat("Game_FX")
					sound.RollOffMinDistance =  v.Size.Magnitude / 10
					sound.RollOffMaxDistance = v.Size.Magnitude / (ClientSettings.Sounds[v.Name].Factor or 1)
					sound.Parent = v
					sound.Looped = ClientSettings.Sounds[v.Name].Delay == nil
					local DelayConn
					if not v:GetAttribute("Universal") then
						AmbZones[v] = Zone.new(v)
						AmbZones[v].localPlayerEntered:Connect(function()
							sound:Play()
							if ClientSettings.Sounds[v.Name].Delay then
								DelayConn = sound.Ended:Connect(function()
									task.wait(ClientSettings.Sounds[v.Name].Delay)
									sound:Play()
								end)
							end
							if ClientSettings.Sounds[v.Name].Volume then
								Tween(sound, "Volume", ClientSettings.Sounds[v.Name].Volume, "Smooth", 3, true)
							end
						end)
						AmbZones[v].localPlayerExited:Connect(function()
							Tween(sound, "Volume", 0, "Smooth", 3, true, function(s)
								if s ~= Enum.TweenStatus.Completed then
									return
								end
								if DelayConn then
									DelayConn:Disconnect()
									DelayConn = nil
								end
								sound:Stop()

							end)
						end)
					else
						sound.Volume = ClientSettings.Sounds[v.Name].Volume
						sound.RollOffMinDistance =  ClientSettings.Sounds[v.Name].Range.Min
						sound.RollOffMaxDistance =  ClientSettings.Sounds[v.Name].Range.Max

						sound:Play()
					end
				end
			end
		end
	end
end
function SoundSystem:Create(sound, Target, Looped, opts, play)
	local TargetType

	--------------------------
	-- Sanity checks
	--------------------------

	if not sound or getType(sound) ~= "Instance"  then -- Must exist, be a string, and have numbers
		error("Invalid sound: ".. tostring(sound))
	end
	if Target then -- Must exist
		TargetType = getType(Target)
		if TargetType ~= "Instance" and TargetType ~= "Vector3" and TargetType ~= "CFrame" then -- Must be valid type
			error("Invalid Target: ".. tostring(Target))
		end
	else
		error("Invalid Target: ".. tostring(Target))
	end
	Looped = Looped or false

	--------------------------
	-- Object creation
	--------------------------

	local Emitter	= newInst("Attachment")
	--Emitter.Visible	= true

	if TargetType == "Instance" and Target.Position then
		-- Sound follows object
		RunService.Stepped:Connect(function()
			Emitter.WorldPosition	= Target.Position
		end)

	elseif TargetType == "Vector3" then
		-- Sound in static position
		Emitter.WorldPosition	= Target

	elseif TargetType == "CFrame" then
		-- Sound in static position
		Emitter.WorldPosition	= Target.Position

	end
	local Sound	
	if not play then
		Sound = sound:Clone()
		Sound.Name = "Emission";
		if opts then
			for k, v in pairs(opts) do
				if v and (not exemptProps[k]) then
					Sound[k] = v;
				end
			end
		end
	else
		Sound = sound
	end		
	local Equalizer
	Equalizer	= newInst("EqualizerSoundEffect")
	Equalizer.LowGain	= 0
	Equalizer.MidGain	= 0
	Equalizer.HighGain	= 0
	Equalizer.Name = "EqMain"
	local Reverb
	if opts.Echo then
		Reverb	= newInst("ReverbSoundEffect")
		Reverb.Enabled = false
	end	
	local sOVal = Instance.new("ObjectValue")
	sOVal.Value = sound.Parent
	sOVal.Name = "SoundObject"
	sOVal.Parent = Emitter
	--------------------------
	-- Effect controller
	--------------------------
	if play then
		Emitter:Destroy()
		Emitter = Sound.Parent
	end
	CurrentObjects[#CurrentObjects+1] = Emitter
	if not Looped then
		local currentObjI = #CurrentObjects
		Sound.Ended:Connect(function()
			table.remove(CurrentObjects,currentObjI)
			if not play then Emitter:Destroy() end
			Emitter = nil;
			Sound = nil;
		end)
	end

	--------------------------
	-- Finalization
	--------------------------
	--
	if not play then
		Equalizer.Parent	= Sound	
		if Reverb then
			Reverb.Parent = Sound;
		end	
		Sound.Parent		= Emitter
		Emitter.Parent		= workspace.Terrain		
	end
	FastDelay(2/60,function()
		Sound.Playing = true
		Sound = nil;
	end)
	Equalizer = nil;


	return Emitter
end



function SoundSystem:FireMuzzleSounds(main,cf,options,sub)
	do
		local mainSounds = {};
		local _, Listener = SoundService:GetListener()

		if Listener then
			if Listener:IsA("BasePart") then
				Listener = Listener.CFrame
			end
		else
			Listener = Camera.CFrame
		end	
		local dist = math.min(options.Range or 300, (Listener.Position - main.Position).Magnitude)

		for _, fireSound in ipairs(main:GetChildren()) do
			if fireSound.Name == "FireSound" and (dist <= (options.Range or 300) / 5)  then 
				if fireSound:FindFirstChild("SoundOrder") then
					mainSounds[fireSound.SoundOrder.Value] = fireSound
				else
					table.insert(mainSounds,fireSound)
				end
			elseif fireSound.Name == "EchoSound" and (dist > (options.Range or 300) / 5)   then 
				if fireSound:FindFirstChild("SoundOrder") then
					mainSounds[fireSound.SoundOrder.Value] = fireSound
				else
					table.insert(mainSounds,fireSound)
				end
			elseif options.Tank and fireSound.Name == "ExitSound" then
				mainSounds[#mainSounds + 1] = fireSound;
			end
		end

		for _, fireSound in ipairs(mainSounds) do
			local opts = options or {
				Start = 0;	
			}
			local distance = math.min(fireSound.RollOffMaxDistance, (Listener.Position - main.Position).Magnitude)

			SoundSystem:Create(fireSound,main.CFrame.p,false,{
				TimePosition = opts.Start or 0;
				SoundGroup = (sub and SoundService.WaterEffects or self:GetSoundCat("Game_FX"));
				PlaybackSpeed = fireSound.PlaybackSpeed;
				Volume = fireSound.Volume,
				RollOffMaxDistance = fireSound.RollOffMaxDistance or 1024,
				RollOffMinDistance = fireSound.RollOffMinDistance or 128,
				Silenced = options.Suppressed;
				Echo = (not sub) and (distance > fireSound.RollOffMaxDistance/100);
			},false)

		end
	end
end

--------------------------
-- 3D-Effect management
--------------------------
local function positionInPart(part, position)
	local extents = part.Size / 2
	local offset = part.CFrame:pointToObjectSpace(position)
	return offset.x < extents.x
		and offset.y < extents.y
		and offset.z < extents.z
end

local currentSeat = nil;

function SoundSystem:SetVehicleSeat(seat: Seat?)
	currentSeat = seat;
end


local reverbType = SoundService.AmbientReverb
local dReverbType = reverbType
if not _G.SoundConnection  then 
	_G.SoundConnection = RunService.Heartbeat:Connect(function()
		local _, Listener = SoundService:GetListener()

		if Listener then
			if Listener:IsA("BasePart") then
				Listener = Listener.CFrame
			end
		else
			Listener = Camera.CFrame
		end	
		for i, Emitter in ipairs(CurrentObjects) do
			if Emitter:FindFirstChild("Emission") then
				local eq = Emitter.Emission:FindFirstChild("EqMain") 
				local rev = Emitter.Emission:FindFirstChildOfClass("ReverbSoundEffect")
				local  distance = math.min(Emitter.Emission.RollOffMaxDistance, (Listener.Position - Emitter.Position).Magnitude) 
				if (rev and eq) and Emitter.Emission.IsPlaying then

					if distance > Emitter.Emission.RollOffMinDistance then
						rev.DryLevel = 0;
						rev.WetLevel = (distance/Emitter.Emission.RollOffMaxDistance) * -20
						rev.Enabled = true;

					end
				end
				local vehicle = currentSeat
				if vehicle then
					if vehicle.Name == "DriveSeat" or  (vehicle.Name:find("Gunner") and vehicle.Name:find("Seat")) then
						vehicle = vehicle.Parent
					elseif vehicle:FindFirstAncestor("PassengerSeats") then
						vehicle = vehicle.Parent.Parent.Parent			
					end	
					if vehicle then
						local soundObject = Emitter:FindFirstChild("SoundObject")
						local soundObj = soundObject.Value
						if soundObj then
							if (not soundObj:IsDescendantOf(vehicle)) and (not currentSeat.Name:find("Gunner")) then
								eq.HighGain = -25
								eq.MidGain = -25
								eq.LowGain = 0;
								eq.Priority = 0;
								return
							end
						end
					end
				end

				if eq and Emitter.Emission.IsPlaying then

					local Facing = Listener.LookVector
					local Vector = (Emitter.Position - Listener.Position).Unit

					--Remove Y so up/down doesn't matter
					Facing	= v3(Facing.X,0,Facing.Z)
					Vector	= v3(Vector.X,0,Vector.Z)

					local Angle = acos(dot(Facing,Vector)/(Facing.magnitude*Vector.magnitude))

					eq.HighGain = -(25 * ((Angle/pi)^2))
					if rev and rev.Enabled then
						eq.MidGain = (distance/MaxDist) * 5
						eq.LowGain = (distance/MaxDist) * -15
					end
				end

			end
		end

	end)
end
return SoundSystem
