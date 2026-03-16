local FiringSystem = {}
local Resources = require(game.ReplicatedStorage.Resources)
FiringSystem.ModeTypes = Resources:LoadConfiguration("Firemode")
local RunService = game:GetService("RunService")
FiringSystem.ModeActivityColors = {
	Off = Color3.fromRGB(89, 89, 89);
	On = Color3.fromRGB(255, 255, 255);
}
local inList = Resources:LoadLibrary("inList")
local INSERT = table.insert

function FiringSystem.new(...)
	local args = {...}
	local Modes = {}
	local FiringModeTypes = nil;
	local currentMode = 1;
	local enabled = true;
	local ignoredModes = {};
	local function getModeWithName(mode)
		for _, v in ipairs(Modes) do
			if v.Name == mode then
				return v
			end
		end
		return nil;
	end
	local firingSystem = {
		switchTo = function(self,modeName,ui,burst)
			for i, mode in ipairs(Modes) do
				print(mode.Name, modeName)
				if mode.Name == modeName then
						currentMode = i;
						self:showMode(burst)
						return true
				end
			end
			return false
		end;
		changeMode = function(self, burst)
			repeat
				currentMode = currentMode + 1;
				if currentMode > #Modes then
					currentMode = 1;
				end
				RunService.Heartbeat:Wait()
			until
				not self:isIgnoredMode(Modes[currentMode].Name)
			if RunService:IsClient() then self:showMode(burst) end
		end;
		hasMode = function(self, modeName)
			for i, mode in ipairs(Modes) do
				if mode.Name == modeName then
					return true
				end
			end
			return false
		end,
		addFireMode = function(self,modeName,modeInd)
			local modeData = {
				Name = modeName;
				Indicator = modeInd;
			};
			INSERT(Modes,modeData);
		end;
		addIgnoredMode = function(self,modeName)
			local modeData = getModeWithName(modeName)
			if modeData then
				INSERT(ignoredModes,modeName)
			end
		end;
		isIgnoredMode = function(self,modeName)
			return inList(modeName,ignoredModes)
		end;
		showMode = function(_, burst)
			--_G.HM:PerformCMAction("SetFireMode", Modes[currentMode].Name, Modes[currentMode].Indicator, burst)
		end;
		clearModes = function(self)
			Modes = {};
		end;
		sort = function(self,S)
			 for i , v in ipairs(Modes) do
				if v.Name == S.defaultMode then
					currentMode = i
				end
			end
		end;
		runMode = function(self,API,...)
			FiringSystem.ModeTypes[self.currentMode.Name:upper()](API,...)
		end;
		getPrev = function(_)
			local cm = currentMode - 1
			if cm < 1 then
				cm = #Modes
			end
			return Modes[cm]
		end;
		getNext = function(_)
			local cm = currentMode + 1
			if cm > #Modes then
				cm = 1
			end
			return Modes[cm]
		end		
	};
	local fm =  setmetatable(firingSystem,{
		__index = function(self,k)
			local key = k:lower()
			if key == "modelist" then
				return Modes
			elseif key == "currentmodenum" then
				return currentMode
			elseif key == "currentmode" then
				return Modes[currentMode]
			elseif key == "length" then
				return #Modes
			elseif key == "enabled" then
				return enabled
			elseif key == "ignoredmodes" then
				return ignoredModes
			end
		end;
		__newindex = function(self,k,v)
			local key = k:lower()
		end
	})
	return fm
end
return FiringSystem