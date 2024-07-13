
return function(API, InputComponent)

	local Players = API.Players
	local RunService = API.RunService
	local Tween = API.Tween
	local Color = API.Resources:LoadLibrary("Color")
	local Typer = API.Typer
	local Enumeration = API.Enumeration
	local PseudoInstance = API.PseudoInstance
	local fastSpawn = API.fastSpawn 
	local Rippler = API.Resources:LoadLibrary("Rippler")

	-- Elevations
	local RAISED_BASE_ELEVATION = 3
	local RAISED_ELEVATION = 8








	local Touch = Enum.UserInputType.Touch


	local SuperJoystick =  PseudoInstance:Register("SuperJoystick", {
		Internals = {
			"thumbstickFrame";
			"stick";
			"direction";
			"center";
			"moveTouchObject";
			"ripple";
			InputInFrame = function(self, inputObject: InputObject)
				local frameCornerTopLeft: Vector2 = self.thumbstickFrame.AbsolutePosition
				local frameCornerBottomRight = frameCornerTopLeft + self.thumbstickFrame.AbsoluteSize
				local inputPosition = inputObject.Position
				if inputPosition.X >= frameCornerTopLeft.X and inputPosition.Y >= frameCornerTopLeft.Y then
					if inputPosition.X <= frameCornerBottomRight.X and inputPosition.Y <= frameCornerBottomRight.Y then
						return true
					end
				end
				return false
			end;
			Modes = {
				
			};
			SchemeModes = {};
			"isMoving";
			"usesCurrentScheme";
			tapCount = 0;
			timing = 0;
		};
		
		Properties = {
			UI = Typer.OptionalInstanceWhichIsAGuiObject;
			Deadzone = Typer.Number;
			Value = Typer.Vector2;
			ModeIndex = Typer.Number;
		};
		
		Events = {
			"ActionTriggered";
			"AxisChanged";
			"ModeChanged";
		};
		
		Methods = {
			IsInMotion = function(self)
				local mode = self.Modes[self.ModeIndex]
				if mode and (not self.usesCurrentScheme) then
					if mode.Type == "Movement" then
						return true
					end
				end
				return false
			end,
			SetupScheme = function(self)
				local scheme = InputComponent.InputSchemes[InputComponent.CurrentIScheme]
				if scheme and scheme.SJActions then
					self.SchemeModes = scheme.SJActions
				end
			end,
			SetModes = function(self, modes)
			
				if #self.Modes <= 0 then
					self:GetPropertyChangedSignal("ModeIndex"):Connect(function()
						if self.usesCurrentScheme then
							if #self.SchemeModes > 0 then
								if self.UI.ModeTitle.TextTransparency >= 1 then
									Tween(self.UI.ModeTitle, "TextTransparency", 0, "Standard", 0.75, false)
								end
								local oldTitle = self.SchemeModes[self.ModeIndex].Title
								self.UI.ModeTitle.Text = self.SchemeModes[self.ModeIndex].Title 
								task.wait(4)
								if oldTitle == self.UI.ModeTitle.Text then
									Tween(self.UI.ModeTitle, "TextTransparency", 1, "Standard", 0.75, false)
								end
							end
							return
						end
						if self.UI.ModeTitle.TextTransparency >= 1 then
							Tween(self.UI.ModeTitle, "TextTransparency", 0, "Standard", 0.75, false)
						end
						local oldTitle = self.Modes[self.ModeIndex].Title
						self.UI.ModeTitle.Text = self.Modes[self.ModeIndex].Title 
						task.wait(4)
						if oldTitle == self.UI.ModeTitle.Text then
							Tween(self.UI.ModeTitle, "TextTransparency", 1, "Standard", 0.75, false)
						end
					end)
				end
				self.Modes = modes;
				self.ModeIndex = 1
			end,
			GetMode = function(self)
				if self.usesCurrentScheme then 
					return self.SchemeModes[self.ModeIndex]
				end
				return self.Modes[self.ModeIndex]
			end,
			ForceSchemeMode = function(self,modeIndex)
				self.usesCurrentScheme = true
				if not modeIndex then
					modeIndex = 1
				end
				self.ModeIndex = modeIndex
			end,
			ResetScheme = function(self)
				self.usesCurrentScheme = false
				self.ModeIndex = 1
			end,
			ProcessInput = function(self,i,g)
				if i == self.moveTouchObject then
					if not self.isMoving  then
						self.isMoving = true
					end
					self.center  = Vector2.new(self.thumbstickFrame.AbsolutePosition.x + self.thumbstickFrame.AbsoluteSize.x/2,
						self.thumbstickFrame.AbsolutePosition.y + self.thumbstickFrame.AbsoluteSize.y/2)
					local direction = Vector2.new(i.Position.X - self.center.x, i.Position.Y - self.center.y)
					local relativePosition = Vector2.new(i.Position.X - self.center.x, i.Position.Y - self.center.Y)
					local length = relativePosition.magnitude
					local maxLength = self.thumbstickFrame.AbsoluteSize.x/2
					length = math.min(length, maxLength)
					relativePosition = relativePosition.unit * length
					self.stick.Position = UDim2.new(0.5, relativePosition.x, .5, relativePosition.y)
					local value = Vector2.new((i.Position.X - self.center.x) / (self.thumbstickFrame.AbsoluteSize.X/2) , (i.Position.Y - self.center.Y) / (self.thumbstickFrame.AbsoluteSize.Y/2))
					local inputAxisMagnitude = value.magnitude
					if inputAxisMagnitude < self.Deadzone then
						value = Vector2.new()
					else
						value = value.unit * ((inputAxisMagnitude - self.Deadzone) / (1 - self.Deadzone))
						-- NOTE: Making currentMoveVector a unit vector will cause the player to instantly go max speed
						-- must check for zero length vector is using unit
						value = -Vector2.new(math.clamp(value.x, -1, 1), math.clamp(value.y, -1, 1))
					end
					self.Value = value
					if self:GetMode().Type == "Movement" and self:GetMode().Title ~= "Movement" then
						self.AxisChanged:Fire(self:GetMode().Title, self.Value)
					end
					return true
				end
				return false
			end,
			ProcessInputStart = function(self,i)
				if self.moveTouchObject or i.UserInputType ~= Enum.UserInputType.Touch
					or i.UserInputState ~= Enum.UserInputState.Begin then
					return false
				end

				if not self:InputInFrame(i) then
					return false
				end

				self.moveTouchObject = i
				self.center = Vector2.new(self.thumbstickFrame.AbsolutePosition.x, self.thumbstickFrame.AbsolutePosition.y)
				return true
			end,
			ProcessInputEnd = function(self, i, g)
				if i == self.moveTouchObject then
					self.stick.Position = UDim2.new(0.5, 0, 0.5, 0)
					if self:GetMode().Type == "AxisAction" then
						for _, mode in pairs(self:GetMode().Actions) do
							if mode.Range.Min <= self.Value[mode.Axis] and mode.Range.Max >= self.Value[mode.Axis] then
								if math.abs(self.Value[mode.Axis]) > math.abs(self.Value[mode.OppositeAxis]) then
									self.ActionTriggered:Fire(mode.Name, i, self.usesCurrentScheme)
									break;
								end
							end
						end
					elseif self:GetMode().Type == "AimAction" then
						local mode = self:GetMode()
						if mode.Range.Min <= self.Value[mode.Axis] and mode.Range.Max >= self.Value[mode.Axis] then
							if mode.OnActive then
								mode.OnActive()
							end
						end
					end
					self.moveTouchObject = nil
					self.isMoving = false
					self.Value = Vector2.new()
				end
			end,
			Tick = function(self,dt)
				if self.tapCount > 0 then
					self.timing += dt 
					if self.timing >= 0.75 then
						self.timing = 0
						self.ModeIndex = self.tapCount
						self.ModeChanged:Fire(self.Modes[self.ModeIndex])
						self.tapCount = 0;
					end
				end
				if _G.MovementDisabled then
					self.Value = Vector2.zero
					game.Players.LocalPlayer:Move(Vector3.zero)
				end
			end,
		};
		
		
		Init = function(self, ui: GuiObject)
			self.Deadzone = .05
			self:superinit()
			
			self.Value = Vector2.new()
			self.UI = ui;
			self.ripple = PseudoInstance.new("Rippler")
			self.thumbstickFrame = ui:FindFirstChild("JoystickBack")
			self.stick =  self.thumbstickFrame:FindFirstChild("Stick")
			self.ripple.Container = self.stick
			self.Janitor:Add(self.stick.TouchTap:Connect(function(tp)
				if (not self.moveTouchObject) and (not self.isMoving) then
					self.tapCount += 1
					fastSpawn(function() self.ripple:Ripple() end)
					self.timing = 0;
				end
			end),"Disconnect")
			self.Janitor:Add(self.UI.ResetBar.TouchSwipe:Connect(function(swipeDir)
				if swipeDir ~= Enum.SwipeDirection.Down then
					return
				end
				self.usesCurrentScheme = not self.usesCurrentScheme
			end),"Disconnect")
			self.Janitor:Add(self.UI.ResetBar.TouchTap:Connect(function()
				self.ModeIndex = 1
			end),"Disconnect")
		end,
	})
	InputComponent.SetupJoystick = function(ui, generalModes)
		InputComponent.Joystick = PseudoInstance.new("SuperJoystick", ui)
		if generalModes then
			InputComponent.Joystick:SetModes(generalModes)
		end
	end
	InputComponent.AddInputPlugin(Enumeration.InputPluginType.TouchMoved, function(i,g)
		if InputComponent.Joystick then
			return InputComponent.Joystick:ProcessInput(i,g)
		end
	end)
	InputComponent.AddInputPlugin(Enumeration.InputPluginType.TouchStarted, function(i,g)
		if InputComponent.Joystick then
			return InputComponent.Joystick:ProcessInputStart(i,g)
		end
	end)
	InputComponent.AddInputPlugin(Enumeration.InputPluginType.TouchEnd, function(i,g)
		if InputComponent.Joystick then
			return InputComponent.Joystick:ProcessInputEnd(i,g)
		end
	end)
	InputComponent.AddInputPlugin(Enumeration.InputPluginType.Render, function(dt)
		if InputComponent.Joystick then
			InputComponent.Joystick:Tick(dt)
		end
	end)
	
	InputComponent.ForceSJScheme = function(modeIndex)
		InputComponent.Joystick:ForceSchemeMode(modeIndex)
	end
	
	InputComponent.ResetSJScheme = function(modeIndex)
		InputComponent.Joystick:ResetScheme()
	end
	
	InputComponent.WorldTapped = API.Signal.new()
	InputComponent.TWFilter = {}
	InputComponent.AddInputPlugin(Enumeration.InputPluginType.TapInWorld, function(pos, g)
		local r 
		if pos then
			r = workspace.CurrentCamera:ViewportPointToRay(pos.X,pos.Y,10)
			r = Ray.new(r.Origin,r.Direction * 1000)

		end
		local cf = CFrame.new()
		if r then
			local ry = API.RayUtils:LineCastExclusive(r.Origin,r.Direction,{
				FilterList = InputComponent.TWFilter;
				IgnoreWater = true;
			})
			if ry then
				cf = CFrame.new(ry.Position, ry.Position + r.Unit.Direction)
			else
				cf = CFrame.new(r.Origin + (r.Direction * 1000), (r.Origin + (r.Direction * 1000)) + r.Unit.Direction)
			end
			InputComponent.WorldTapped:Fire(cf)

		end
	end)
	
	return {
		Name = "SuperJoystick";
		SubComp = SuperJoystick;
	}
end
