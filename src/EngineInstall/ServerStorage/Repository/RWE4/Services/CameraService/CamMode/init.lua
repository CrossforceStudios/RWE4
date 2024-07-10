local CamMode = {}
local CF = CFrame.new
CamMode.__index = CamMode
local V2 = Vector2.new
local camera = workspace.CurrentCamera
local Resources = require(game.ReplicatedStorage.Resources)
function CamMode.new(name,getCF,sens,smooth,zp,...)
	local mode = {}
	mode.Name = name
	local args = {...}
	mode._getCF = getCF  or function(self,...) return CF() end
	mode.Subject = nil;
	mode.cameraPerspective = args[1] or V2(0,0)
	mode.zPerspective = zp
	mode.sensitivity = sens or 0.3
	mode.smoothness = smooth or 0.05
	mode.extraType  = nil;
	mode.posO = Vector3.new()
	mode.offset = Vector3.new()
	mode.Variables = {};
	return setmetatable(mode,CamMode)
end
function CamMode:getCFrame(...)
	local flags = Resources:GetFlags()
	return self._getCF(self,flags,...)
end
function CamMode.CreateMode(name,...)
	local mode
	local modeScript = script.Modes:FindFirstChild(name) 
	if modeScript then
		if modeScript:IsA("ModuleScript") then
			modeScript = require(modeScript)
			if modeScript then
				mode = modeScript()
				mode = CamMode.new(mode.name,mode.getCF,mode.sensitivity,mode.smoothness,mode.zPerspective,...)
			end
		end
	end
	return mode
end
function CamMode:getOffset(...)
	return self.offset
end
function CamMode:ProcessAxis(axis)
	return (axis * self.sensitivity) * self.smoothness
end
function CamMode:SetFocus(focus)
	camera.Focus = focus
end
function CamMode:GetFocus()
	return camera.Focus
end
function CamMode:__tostring()
	return self.Name
end
return CamMode