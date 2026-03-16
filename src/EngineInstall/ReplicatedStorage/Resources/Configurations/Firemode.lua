local FireModes = {}
local RunService = game:GetService("RunService")
local Resources = require(game.ReplicatedStorage.Resources)
local FastWait = Resources:LoadLibrary("FastWait")
local FastDelay = Resources:LoadLibrary("FastDelay")

FireModes.AUTO = function(S)
	if not S.canFire then return end
	S.canFire = false 
	S.Firing = true
	local t = (tick() + S.fireRate)
	local connection
	local function stopFire()
		connection:Disconnect()
		connection = nil;
		S.Firing = false
		S.canFire = true
		S:endShake()
	end
	S:startShake()
	connection = RunService.Heartbeat:Connect(function(dt)
		if S.currentFireMode ~= "AUTO" then 
			stopFire()
		end
		if S.Humanoid.Health == 0 then 
			stopFire()

		end
		if S.TrueAmmo > 0 and tick() >= t then
			t = (tick() + S.fireRate)
			S.newMag = false
			S:fire("Gun")
			S:shrinkLink()				
		end
		if not (S.MB1Down) then
			stopFire()

		end
		if S.Reloading then
			stopFire()
		end
		if S.isCrawling then
			stopFire()

		end

	end)		
end

FireModes.SEMI = function(S,...)
	local args = {...}
	pcall(function()
		if (not S.canFire) then return end
		S.canFire = false
		local fireUndo = false
		if  (not S.isCrawling) and S.Humanoid.Health > 0 then
			S.Firing = true
			S:startShake()

			if S.TrueAmmo > 0 then
				S.newMag = false
				S:fire("Gun",table.unpack(args))
				S:shrinkLink()				
			end

			fireUndo = true
			FastDelay((not S.boltAction) and S.fireRate or 0.4,function()
				S.Firing = false
				S.canFire = true
				S:endShake()

			end)
		end

		if not fireUndo then
			S.Firing = false;
			S:endShake()
			S.canFire = true
		end

	end)
end

FireModes.BURST = function(S)
	if (not S.canFire) then return end
	S.canFire = false

	local burstTime = S.fireRate
	if (not S.isCrawling) then
		S.Firing = true
		S:startShake()
		S:doBurst(function()
			if S.Ammo > 0 then
				if S.Humanoid.Health > 0 then
					S.newMag = false
					S:fire("Gun")
					S:shrinkLink()								
				end
			end
		end)
		S:endShake()

	end
	S.canFire = true
end

FireModes.SAFETY = function(S)

end;


return FireModes