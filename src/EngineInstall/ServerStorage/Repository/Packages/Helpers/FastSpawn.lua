-- Spawns a new thread without waiting one step
-- @documentation https://rostrap.github.io/Libraries/Helper/FastSpawn/
-- @source https://raw.githubusercontent.com/RoStrap/Helper/master/FastSpawn.lua
-- @rostrap FastSpawn
-- Fastest implementation I know of
-- @author Validark
-- Modified to save memory
local RunService = game:GetService("RunService")

local function FastSpawn(callback, ...)
	local args = table.pack(...)
	local hb
	hb = RunService.Heartbeat:Connect(function()
		hb:Disconnect()
		hb = nil
		callback(table.unpack(args, 1, args.n))
	end)
end

return FastSpawn
