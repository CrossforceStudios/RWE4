-- Spawns a new thread without waiting one step
-- @documentation https://rostrap.github.io/Libraries/Helper/FastSpawn/
-- @source https://raw.githubusercontent.com/RoStrap/Helper/master/FastSpawn.lua
-- @rostrap FastSpawn
-- Fastest implementation I know of
-- @author Validark
local RunService = game:GetService("RunService")

local function FastSpawn(t, callback, ...)
	local args = table.pack(...)
	local executeTime = (tick() + t)
	local hb
	local dtt = 0
	hb = RunService.Heartbeat:Connect(function(dt)
		if (tick() >= executeTime) then
			hb:Disconnect()
			hb = nil
			callback(table.unpack(args, 1, args.n))
		end
	end)
	return hb
end

return FastSpawn
