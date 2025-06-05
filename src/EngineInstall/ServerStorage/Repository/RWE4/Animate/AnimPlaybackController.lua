local RunService = game:GetService("RunService")
-- AnimationValues
local Resources = require(game.ReplicatedStorage:WaitForChild("Resources",200))
local PseudoInstance = Resources:LoadLibrary("PseudoInstance")
local Typer = Resources:LoadLibrary("Typer")
local fastSpawn = Resources:LoadLibrary("FastSpawn")	
local APC = PseudoInstance:Register("AnimPlaybackController",{
	Internals = {
		"CancelCache";
		nonCancellable = {};
	};
	
	Properties = {
		CurrentAnim = Typer.AssignSignature(2, Typer.OptionalString , function(self, animName)
			if (not self.CurrentAnim) or (animName == nil) then
				self:rawset("CurrentAnim", animName)
			end
		end)	
	};
	
	Methods = {
		Cancel = function(self)
						if self.CurrentAnim then
							if not table.find(self.nonCancellable,self.CurrentAnim) then
								self.CancelCache[self.CurrentAnim] = true
								self.AnimCancelled:Fire(self.CurrentAnim)
							end
						end
		end;
		Reset = function(self,anim)
			self.CancelCache[anim] = false
			self.CurrentAnim = nil;
		end;
		IsCancelled = function(self,anim)
			return self.CancelCache[anim]
		end
	};
	
	Accessors = {
		Playing = function(self)
			return self.CurrentAnim ~= nil;
		end;
		NonCancellables = function(self)
			return self.nonCancellables
		end
	};
	
	Events = {
		"AnimCancelled";
	};
	
	
	Init = function(self,...)
		local args = table.pack(...)
		
		self.CancelCache = args[1] or {
				["Reload"] = false;
				["Inspecting"] = false;
				["Cocking"] = false;
				["Parkour"] = false;
				["Spot"] = false;
				["Nading"] = false;
				["Throwing"] = false;
				["DropAmmo"] = false;
				["Equip"] = false;
			["SelectFire"] = false;
			["EquipAttachment"] = false;

		};
		
		self.nonCancellable = args[2] or {
			"Cocking";
		};
		
		self:superinit()
	end
})

return APC