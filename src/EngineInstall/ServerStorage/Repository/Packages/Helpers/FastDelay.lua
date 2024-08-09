-- Spawns a new thread without waiting one step
-- @documentation https://rostrap.github.io/Libraries/Helper/FastSpawn/
-- @source https://raw.githubusercontent.com/RoStrap/Helper/master/FastSpawn.lua
-- @rostrap FastSpawn
-- Fastest implementation I know of
-- @author Validark
local RunService = game:GetService("RunService")

local function FastSpawn(t, callback, incrCallback, ...)
	local args = table.pack(...)
	local executeTime = (tick() + t)
	local hb
	local dtt = 0
	local inter = 1;
	hb = RunService.Heartbeat:Connect(function(dt)
		dtt = dtt + dt
		if dtt >= inter then
			dtt = 0
			if incrCallback then inter = incrCallback(inter) or 1 end
		end
		if (tick() >= executeTime) then
			hb:Disconnect()
			hb = nil
			callback(table.unpack(args, 1, args.n))
		end
	end)
	return hb
end

return FastSpawn
