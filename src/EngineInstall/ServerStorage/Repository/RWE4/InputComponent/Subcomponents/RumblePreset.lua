return function(API, InputComponent)

	local RumblePreset
	do



	end
	RumblePreset = API.PseudoInstance:Register("RumblePreset",{
		Internals = {
			"Effect";
		};

		Methods = {
			Customize = function(self, waveForms)
				local effect : HapticEffect = self.Effect
				if effect then
					if effect:IsA("HapticEffect") then
						if effect.Type == Enum.HapticEffectType.Custom then
							effect:SetWaveformKeys(waveForms)
						end
					end
				end
			end,
			Play = function(self)
				local effect : HapticEffect = self.Effect
				if effect then
					if effect:IsA("HapticEffect") then
						effect:Play()
					end
				end
			end,
			Stop = function(self)
				local effect : HapticEffect = self.Effect
				if effect then
					if effect:IsA("HapticEffect") then
						effect:Stop()
					end
				end
			end,
			SetType = function(self, hapType)
				local effect : HapticEffect = self.Effect
				if effect then
					if effect:IsA("HapticEffect") then
						effect.Type = hapType
					end
				end
			end,
		};

		Events = {

		};

		Properties = {
			Desired = API.Typer.Vector3;
		};

		Init = function(self, label, gamepad, desired, typeOfEffect, parent)
			self:superinit()
			self.Name = label
			self.Desired = desired
			self.Effect = Instance.new("HapticEffect") do
				self.Effect.Name = "RumbleEffect"
				self.Effect.Position = desired
				self.Effect.Type = typeOfEffect or Enum.HapticEffectType.GameplayCollision
				self.Effect.Parent = parent or game.Players.LocalPlayer
				self.Janitor:Add(self:GetPropertyChangedSignal("Parent"):Connect(function()
					self.Effect.Parent = self.Parent
				end), "Disconnect")
				self.Janitor:Add(self:GetPropertyChangedSignal("Desired"):Connect(function()
					self.Effect.Position = self.Desired
				end), "Disconnect")
			end
		end;
	})
	InputComponent.RumblePresets = {
		["Recoil"] = API.PseudoInstance.new("RumblePreset","Recoil",Enum.UserInputType.Gamepad1,Vector3.new(0.5,0,0));
		["Recoil2"] = API.PseudoInstance.new("RumblePreset","Recoil2",Enum.UserInputType.Gamepad1,Vector3.new(0,-0.5,0));
		["GripRecoil"] = API.PseudoInstance.new("RumblePreset","GripRecoil",Enum.UserInputType.Gamepad1,Vector3.new(0,-0.5,0));
		["Explosion"] = API.PseudoInstance.new("RumblePreset","Explosion",Enum.UserInputType.Gamepad1,Vector3.new(0,0,0),Enum.HapticEffectType.GameplayExplosion);

	};
	function InputComponent.PlayRumble(name)
		if InputComponent.RumblePresets[name] then
			InputComponent.RumblePresets[name]:Play()
		end
	end
	function InputComponent.StopRumble(name)
		if InputComponent.RumblePresets[name] then
			InputComponent.RumblePresets[name]:Stop()
		end
	end
	return {
		Name = "RumblePreset";
		SubComp = RumblePreset;
	}	
end