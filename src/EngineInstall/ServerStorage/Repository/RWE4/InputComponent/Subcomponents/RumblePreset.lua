return function(API, InputComponent)

	local RumblePreset
	do

	 

	end
	RumblePreset = API.PseudoInstance:Register("RumblePreset",{
		Internals = {
			
		};
		
		Methods = {
			Set = function(self,startVib)
				API.HapticsService:SetMotor(self.Gamepad,self:getMotor(),startVib)
			end;
			Connect = function(self, f)
				assert(API.Typer.Function(f), "[InputComponent 2]: f must be a function.")
				self.IndexChanged:Connect(f)
			end,
			getMotor = function(self)
				local result = self.Fallback
				if API.HapticsService:IsVibrationSupported(self.Gamepad) then
					if API.HapticsService:IsMotorSupported(self.Gamepad,self.Desired) then
						result =  self.Desired
					end
				end
				return result
			end,
		};
		
		Events = {
			
		};
		
		Properties = {
			Fallback = API.Typer.EnumOfTypeVibrationMotor;
			Desired = API.Typer.EnumOfTypeVibrationMotor;
			Gamepad = API.Typer.EnumOfTypeUserInputType;
		};
		
		Init = function(self, label, gamepad, desired, fallback)
			self:superinit()
			self.Name = label
			self.Gamepad = gamepad or Enum.UserInputType.Gamepad1
			self.Desired = desired
			self.Fallback = fallback
		end;
	})
	InputComponent.RumblePresets = {
		["Recoil"] = API.PseudoInstance.new("RumblePreset","Recoil",Enum.UserInputType.Gamepad1,Enum.VibrationMotor.RightTrigger,Enum.VibrationMotor.Large);
		["Recoil2"] = API.PseudoInstance.new("RumblePreset","Recoil2",Enum.UserInputType.Gamepad1,Enum.VibrationMotor.Large,Enum.VibrationMotor.Large);
		["GripRecoil"] = API.PseudoInstance.new("RumblePreset","Recoil",Enum.UserInputType.Gamepad1,Enum.VibrationMotor.Large,Enum.VibrationMotor.Large);
	};
	function InputComponent.SetRumble(name,start)
		if InputComponent.RumblePresets[name] then
			InputComponent.RumblePresets[name]:Set(start)
		end
	end
	return {
		Name = "RumblePreset";
		SubComp = RumblePreset;
	}	
end