-- Spawns a new thread without waiting one step
-- @documentation https://rostrap.github.io/Libraries/Helper/FastSpawn/
-- @source https://raw.githubusercontent.com/RoStrap/Helper/master/FastSpawn.lua
-- @rostrap FastSpawn
-- Fastest implementation I know of
-- @author Validark
-- Modified to save memory
local RunService = game:GetService("RunService")
local function FunctionWrapper(t)
	local t2 = 0
	while  t2 < (t or (1/60)) do
		t2 = t2 + RunService.Heartbeat:Wait()
	end
	return t2
end

local function FastSpawn(t)
   return FunctionWrapper(t)
end

return FastSpawn
