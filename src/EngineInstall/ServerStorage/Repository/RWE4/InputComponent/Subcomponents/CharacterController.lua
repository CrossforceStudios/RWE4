return function(API, InputComponent)

	local CharacterController
	local NONE = Enum.UserInputType.None;
	local function calculateRawMoveVector(cameraRelativeMoveVector, mm)
		local camera = workspace.CurrentCamera
		if not camera then
			return cameraRelativeMoveVector
		end

		local camCF = camera.CFrame
		if API.inList(mm,{"Crawl";"Swim";"Climb"}) then
			return  camCF:VectorToWorldSpace(cameraRelativeMoveVector)
		end

		local c, s
		local _, _, _, R00, R01, R02, _, _, R12, _, _, R22 = camCF:GetComponents()
		if R12 < 1 and R12 > -1 then
			-- X and Z components from back vector.
			c = R22
			s = R02
		else
			-- In this case the camera is looking straight up or straight down.
			-- Use X components from right and up vectors.
			c = R00
			s = -R01*math.sign(R12)
		end
		local norm = math.sqrt(c*c + s*s)
		return Vector3.new(
			(c*cameraRelativeMoveVector.x + s*cameraRelativeMoveVector.z)/norm,
			0,
			(c*cameraRelativeMoveVector.z - s*cameraRelativeMoveVector.x)/norm
		)
	end
	CharacterController = API.PseudoInstance:Register("CharacterController",{
		Internals = {
			Modes = {};	
			isJumping = false;
			MoveVectorD = API.ZERO_VECTOR3;
			moveVectorIsCameraRelative = true;
			movementMode = false;
			Deactivate = function(self, input, gp)
				self.Deactivated:Fire(input, gp)
			end;
			JumpUI = false;
			Enabled = false;
			negative = {
				Enum.PlayerActions.CharacterLeft;
				Enum.PlayerActions.CharacterForward;
			}
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
			SetJumpButton = function(self, ui: GuiButton)
				self.JumpUI = ui
				self.Janitor:Add(self.JumpUI.InputEnded:Connect(function(i)
					if i.UserInputType == Enum.UserInputType.Touch then
						self.JumpRequested = true
						API.FastDelay(0.3, function()
							self.JumpRequested = false
						end)
					end
				end),"Disconnect")
			end,
			Update = function(self, dt,jumpCB)
				if InputComponent.Joystick then
					if InputComponent.Joystick:IsInMotion() then
						local v2 = InputComponent.Joystick.Value
						self.MoveVector = Vector3.new(-v2.X, 0, -v2.Y)
						self.MoveVector = calculateRawMoveVector(self.MoveVector,self.movementMode)
					end
				end
				if API.Resources:GetFlagValue("MovementDisabled") then
					self.MoveVector = Vector3.zero
				end
				self.Player:Move(self.MoveVector)
				jumpCB(self.isJumping)
			end;
			SetInput = function(self, playerAction, input)
				if self.InputMap[playerAction] then
					if not self.InputMap[playerAction][input] then
						self.InputMap[playerAction][input] = true
					end
				end
			end;
			GetMoveAngle = function(self, char)
				if self.Player then
					char = self.Player.Character or char
				end
				if char and char:FindFirstChild("HumanoidRootPart") then
					local mv = char.PrimaryPart.CFrame:vectorToObjectSpace(self.MoveVector)
					return -math.atan2(mv.Z,mv.X) - API.RAD(if API.UIS.TouchEnabled then 0 else 90)
				end
				return -API.RAD(90)
			end;
			IsMoveVectorCameraRelative = function(self)
				return self.moveVectorIsCameraRelative
			end,
			IsCharJumping = function(self)
				return self.isJumping;
			end,
			IsEnabled = function(self)
				return self.Enabled;
			end,
			Enable = function(self, enable)
				if not API.UIS.KeyboardEnabled and (self.Gamepad == NONE) then
					return false
				end
				if enable == self.Enabled then
					-- Module is already in the state being requested. True is returned here since the module will be in the state
					-- expected by the code that follows the Enable() call. This makes more sense than returning false to indicate
					-- no action was necessary. False indicates failure to be in requested/expected state.
					return true
				end
				self.Forward  = 0
				self.Backward = 0
				self.Left = 0
				self.Right = 0
				self.MoveVector = API.ZERO_VECTOR3
				self.JumpRequested = false
				self:UpdateJump()
				self.Enabled = enable
				return true
			end;
			Reset = function(self)
				self.MoveVector = API.ZERO_VECTOR3;
				self.Forward  = 0
				self.Backward = 0
				self.Left = 0
				self.Right = 0
			end,
			UpdateMovement = function(self,char,inputState,mm)
				if API.UIS:GetFocusedTextBox() then
					self:Reset()
					self.Callback(self:GetMoveAngle(char))
					return
				end
				if inputState == Enum.UserInputState.Cancel then
					self:Reset()
					self.Callback(self:GetMoveAngle(char))
					return
				else
					if self.Gamepad == NONE then
						self.MoveVector = Vector3.new((self.Left + self.Right) * (self.State ~= Enum.HumanoidStateType.Swimming and 1 or 0), (self.JumpRequested and self.State == Enum.HumanoidStateType.Swimming and 1 or 0), self.Forward + self.Backward)
					else
						self.MoveVector = self.MoveVectorD
					end
				end
				self.MoveVectorWS = self.MoveVector
				self.movementMode = mm 
				self.MoveVector = calculateRawMoveVector(self.MoveVector,mm)
				if API.Resources:GetFlagValue("MovementDisabled") then
					self.MoveVector = Vector3.zero
				end
				self.Callback(self:GetMoveAngle(char))
			end;
			ProcessAction = function(self, i)
				self.IState = i.UserInputState
				if self.Gamepad == NONE then

					for action, inputs in pairs(self.InputMap) do
						if inputs[i.KeyCode] and action ~= Enum.PlayerActions.CharacterJump then

							self[action.Name:sub(10,#action.Name)] = i.UserInputState.Name ~= "End" and 1 or 0;
							if API.inList(action,self.negative) then
								self[action.Name:sub(10,#action.Name)] = -self[action.Name:sub(10,#action.Name)];
							end
							return true
						elseif  action == Enum.PlayerActions.CharacterJump and inputs[i.KeyCode] then
							self.JumpRequested = self.IState ~= Enum.UserInputState.End
							return true
						end
					end
				else
					local jumpButton 
					for action, inputs in pairs(self.InputMap) do
						if action == Enum.PlayerActions.CharacterJump then
							for code, val in pairs(inputs) do
								if val and InputComponent:ControllerSupports(code) then
									jumpButton = code
									break
								end
							end	
						end
						if jumpButton then
							break
						end
					end
					if i.UserInputState == Enum.UserInputState.Cancel then
						self:Reset()
						return false
					end
					if self.Gamepad ~= i.UserInputType then
						return false
					end
					if (i.KeyCode ~= self.Joystick and (i.KeyCode ~= jumpButton)) then
						return  false 
					elseif i.KeyCode == jumpButton  then 
						self.JumpRequested = self.IState ~= Enum.UserInputState.End
						if self.State == Enum.HumanoidStateType.Swimming then
							API.Resources:SetFlag("isDoneSwimming", true)
							API.FastDelay(10/60,function()
								API.Resources:SetFlag("isDoneSwimming", false)
							end)
						end
						return  true 
					end
					if i.Position.magnitude >= InputComponent.Deadzone then
						self.MoveVectorD  = Vector3.new(i.Position.X, 0, -i.Position.Y)
					else
						self:Reset()
						self.MoveVectorD = API.ZERO_VECTOR3
						return false
					end
				end
				return false
			end;
			UpdateJump = function(self)
				if  API.UIS:GetFocusedTextBox() then
					self.isJumping = false
					return
				end		
				self.isJumping = self.JumpRequested
			end;
		};

		Events = {

		};

		Properties = {
			Jumping = API.Typer.Boolean;
			State = API.Typer.OptionalEnumOfTypeHumanoidStateType;
			Forward = API.Typer.Number;
			Backward = API.Typer.Number;
			Left = API.Typer.Number;
			Right = API.Typer.Number;
			InputMap = API.Typer.OptionalTable;
			Player = API.Typer.OptionalInstanceOfClassPlayer;
			Callback = API.Typer.Function;
			MoveVector = API.Typer.Vector3;
			MoveVectorWS = API.Typer.Vector3;
			MovementState = API.Typer.String;
			Joystick = API.Typer.EnumOfTypeKeyCode;
			Gamepad = API.Typer.EnumOfTypeUserInputType;
			JumpRequested = API.Typer.Boolean;
			IState = API.Typer.OptionalEnumOfTypeUserInputState;
		};

		Init = function(self, plr, stick )
			self:superinit()
			self.MoveVector = API.ZERO_VECTOR3
			self.State = nil;
			self.Forward  = 0
			self.Backward = 0
			self.Left = 0
			self.Right = 0
			self.JumpRequested = false;
			self.InputMap = {
				[Enum.PlayerActions.CharacterForward] = {};
				[Enum.PlayerActions.CharacterBackward] = {};
				[Enum.PlayerActions.CharacterLeft] = {};
				[Enum.PlayerActions.CharacterRight] = {};
				[Enum.PlayerActions.CharacterJump] = {};
			};
			self.Player = plr or API.Players.LocalPlayer
			self.Callback  = function(ang) end
			self.Jumping = true	
			self.Joystick = stick or Enum.KeyCode.Thumbstick1;
			self.Gamepad = InputComponent.GetHighestPriorityGamepad()	
			self.MovementState = "Stand";
			self.IState = nil;
		end;

	})

	function InputComponent.CreateCharacterController()
		return API.PseudoInstance.new("CharacterController",false,Enum.KeyCode.Thumbstick1)
	end

	function InputComponent.SetupCharacter()
		InputComponent.CharacterController = InputComponent.CreateCharacterController()
	end


	function InputComponent.SetupJumpButton(ui: GuiButton)
		InputComponent.CharacterController:SetJumpButton(ui)
	end

	InputComponent.AddInputPlugin(API.Enumeration.InputPluginType.Began, function(io,gp)
		if not gp then
			if InputComponent.CharacterController  then
				if  InputComponent.CharacterController:IsEnabled() then
					InputComponent.CharacterController:ProcessAction(io)
				end
			end
		end
	end)

	InputComponent.AddInputPlugin(API.Enumeration.InputPluginType.Changed, function(io,gp)
		if not gp then
			if InputComponent.CharacterController then
				if  InputComponent.CharacterController:IsEnabled() then
					InputComponent.CharacterController:ProcessAction(io)
				end
			end
		end
	end)

	InputComponent.AddInputPlugin(API.Enumeration.InputPluginType.Ended, function(io,gp)
		if not gp then
			if InputComponent.CharacterController then
				if  InputComponent.CharacterController:IsEnabled() then
					InputComponent.CharacterController:ProcessAction(io)
				end
			end
		end
	end)
	return {
		Name = "CharacterController";
		SubComp = CharacterController;
	}	
end