return function(API, InputComponent)

	local InputAxis
	API.Enumeration.DataFormat = {
		"Delta";
		"Position";
		"Analog";
		"Rotation";
	}
	API.Enumeration.RotationMode = {
		"Conventional";
		"Custom";
	}
	local iData = {
		[Enum.UserInputType.MouseMovement] = "Position";
		[Enum.UserInputType.MouseWheel] = "Position";
		[Enum.UserInputType.Gamepad1] = "Position";
		[Enum.UserInputType.Keyboard] = "Analog";
		[Enum.UserInputType.MouseButton2] = "Analog";
	}
		do
			local AxesProcessors = {
				["Conventional"] = function(i,a)
				local axisResult = ((i.UserInputType.Name:find("Mouse") or i.UserInputType.Name == "Touch") and (API.VEC2(API.RAD(i.Delta.x), API.RAD(i.Delta.y)) * InputComponent.Sensitivity.mouse * 0.25) or  API.VEC2(i.Position.X, -i.Position.Y))
					local fConst = InputComponent.GetUserSensitivity()
					if (i.UserInputType == InputComponent:GetCurrentGamepad())  then
						if axisResult.magnitude > InputComponent.Deadzone then
							axisResult = API.VEC2(axisResult.X, axisResult.Y)
						else
							axisResult = API.VEC2(0,0)
						end
						axisResult = API.GamepadLinearToCurve(axisResult)
						local current = tick()
						if a.time then
							local elapsedT = (current - a.time) * 10
							a.speed = a.speed + (a.maxSpeed * ((elapsedT*elapsedT)/a.duration))
							if a.speed > a.a then a.speed = a.maxSpeed end

							fConst = fConst * a.speed;
						end
						a.last = axisResult
						a.time = current
					axisResult = API.VEC2(API.RAD(axisResult.X) * fConst ,API.RAD(axisResult.Y) * fConst * 0.65 * UserSettings():GetService("UserGameSettings"):GetCameraYInvertValue()) ;
					end
					a:FireAxisChanged(((i.KeyCode and i.KeyCode ~= Enum.KeyCode.Unknown) and i.KeyCode or i.UserInputType),axisResult)
				end;
			}
		InputAxis = API.PseudoInstance:Register("InputAxis",{
			Internals = {
				"last";
				"lastR";
				"lastV";
				"time";
				a = 6;
				speed = 0;
				maxSpeed = 6;
				duration = 0.7;
				
			};
			
			Events = {
				"AxisChanged"
			};
			
			Properties = {
				UserInputType = API.Typer.EnumOfTypeUserInputType;
				DataFormat = API.Typer.EnumerationOfTypeDataFormat;
				RotationMode = API.Typer.EnumerationOfTypeRotationMode;
				Polled = API.Typer.Boolean;
				KeyCode = API.Typer.OptionalEnumOfTypeKeyCodeOrBoolean;
				
			};
			
			Methods = {
				Process = function(self, input)
					AxesProcessors[self.RotationMode.Name](input, self)
				end;
				
				Connect = function(self, f)
					return self.AxisChanged:Connect(f)
				end;
				
				AddAxisProcessor = function(self, name, f)
					AxesProcessors[name] = f
				end;
				
				FireAxisChanged = function(self, ...)
					self.AxisChanged:Fire(...)
				end,
			};
			
			Init = function(self,uit,dataType,keyCode,polled,rotMode)
				self:superinit()
				self.UserInputType = uit or Enum.UserInputType.MouseMovement
				self.DataFormat = dataType or "Position"
				self.KeyCode = keyCode
				self.RotationMode = rotMode or "Conventional"
				self.Polled = polled or false
			end
			
		})
		
	end
	InputComponent.AddInputPlugin(API.Enumeration.InputPluginType.Began, function(io,gp)
		if not gp then
			local axisProcessed = false
			local iSch = InputComponent.InputSchemes[InputComponent.CurrentIScheme] 
			
			if iSch and iSch.Name ~= "General" then

				if API.inList(io.KeyCode,iSch.ActivationCodes) or API.inList(io.UserInputType,iSch.ActivationCodes) then
					iSch.Active = true
					API.fastSpawn(function()	iSch:Activate(io,gp)	end)
				end
				for name, axis in pairs(iSch.Axes) do
					if axis.Polled then
						continue
					end
					if axis.UserInputType == io.UserInputType then
						if axis.KeyCode == io.KeyCode or  (not axis.KeyCode)  then
							if axis.DataFormat.Name == "Analog" then
								local mousePressed 
								if axis.UserInputType.Name:find("Mouse") then
									mousePressed = API.UIS:IsMouseButtonPressed(axis.UserInputType)
								else
									mousePressed = false
								end
								axis:FireAxisChanged(((io.KeyCode and io.KeyCode ~= Enum.KeyCode.Unknown) and io.KeyCode or io.UserInputType),(API.UIS:IsKeyDown(axis.KeyCode) or API.UIS:IsGamepadButtonDown(axis.UserInputType,axis.KeyCode) or mousePressed) and 1 or 0)
								return true
							elseif axis.DataFormat.Name == "Position" then
								axis:FireAxisChanged(((io.KeyCode and io.KeyCode ~= Enum.KeyCode.Unknown) and io.KeyCode or io.UserInputType),Vector3.new(io[iData[io.UserInputType]].X,io[iData[io.UserInputType]].Y,io[iData[io.UserInputType]].Z))
								return true

							end
						end
					end
				end
			end
		end
		return false

	end)
	InputComponent.AddInputPlugin(API.Enumeration.InputPluginType.Began, function(io,gp)

		local iSch2 = InputComponent.InputSchemes.General
		for name, axis in pairs(iSch2.Axes) do
			if axis.Polled then
				continue
			end
			if axis.UserInputType == io.UserInputType then
				if axis.KeyCode == io.KeyCode or (not axis.KeyCode) then
					if axis.DataFormat.Name == "Analog" then
						local arg1
						if axis.KeyCode then
							if axis.KeyCode.Name ~= "Unknown" then
								arg1 = axis.KeyCode
							else
								arg1 = axis.UserInputType
							end
						else
							arg1 = axis.UserInputType
						end
						local mousePressed 
						if axis.UserInputType.Name:find("Mouse") then
							mousePressed = API.UIS:IsMouseButtonPressed(axis.UserInputType)
						else
							mousePressed = false
						end
						axis:FireAxisChanged(((io.KeyCode and io.KeyCode ~= Enum.KeyCode.Unknown) and io.KeyCode or io.UserInputType),((axis.KeyCode and API.UIS:IsKeyDown(axis.KeyCode)) or API.UIS:IsGamepadButtonDown(axis.UserInputType,axis.KeyCode) or mousePressed) and 1 or 0)
						return true	
					elseif axis.DataFormat.Name == "Position" then
						print('POS')
						axis:FireAxisChanged(((io.KeyCode and io.KeyCode ~= Enum.KeyCode.Unknown) and io.KeyCode or io.UserInputType),Vector3.new(io[iData[io.UserInputType]].X,io[iData[io.UserInputType]].Y,io[iData[io.UserInputType]].Z))
						return true
					end
				end
			end
		end
	end)
	InputComponent.AddInputPlugin(API.Enumeration.InputPluginType.Changed, function(io,gp)
		if InputComponent.InputSchemes[InputComponent.CurrentIScheme] then
			local iSch = InputComponent.InputSchemes[InputComponent.CurrentIScheme]
			if iSch then
				local axisProcessed = false
				if io.UserInputType == Enum.UserInputType.MouseWheel then
						for name, axis in pairs(iSch.Axes) do
							if axis.Polled then
								continue
							end
							if axis.UserInputType == io.UserInputType then
								if axis.KeyCode == io.KeyCode or (not axis.KeyCode) then
									if axis.DataFormat.Name == "Position"  then
										axis:FireAxisChanged(((io.KeyCode and io.KeyCode ~= Enum.KeyCode.Unknown) and io.KeyCode or io.UserInputType),Vector3.new(io[iData[io.UserInputType]].X,io[iData[io.UserInputType]].Y,io[iData[io.UserInputType]].Z))
										axisProcessed = true
									elseif axis.DataFormat.Name == "Rotation" then
										axis:Process(io)
									end
									return true
								end
							end 
						end 
				end
				for name, axis in pairs(iSch.Axes) do
					if axis.Polled then
						continue
					end
					if axis.UserInputType == io.UserInputType then
						if axis.KeyCode == io.KeyCode or (not axis.KeyCode) then
							if axis.DataFormat.Name == "Position"  then
								axis:FireAxisChanged(((io.KeyCode and io.KeyCode ~= Enum.KeyCode.Unknown) and io.KeyCode or io.UserInputType),Vector3.new(io[iData[io.UserInputType]].X,io[iData[io.UserInputType]].Y,io[iData[io.UserInputType]].Z))
								axisProcessed = true
							elseif axis.DataFormat.Name == "Rotation" then
								axis:Process(io)
							end
							return true
						end
					end 
				end
			end
		end
		return false

	end)
	InputComponent.AddInputPlugin(API.Enumeration.InputPluginType.Render, function(dt)
		if InputComponent.InputSchemes[InputComponent.CurrentIScheme] then
			local iSch = InputComponent.InputSchemes[InputComponent.CurrentIScheme]
			if iSch and InputComponent.CurrentIScheme and InputComponent.CurrentIScheme ~= "None" then
				local axisProcessed = false
				for name, axis in pairs(iSch.Axes) do
					if not axis.Polled then
						continue
					end
					local io = InputComponent:GetCurrentGamepadState(axis.KeyCode)
					if not io then
						continue
					end
					if axis.UserInputType == io.UserInputType then
						if axis.KeyCode == io.KeyCode or (not axis.KeyCode) then
							if axis.DataFormat.Name == "Position"  then
								axis:FireAxisChanged(((io.KeyCode and io.KeyCode ~= Enum.KeyCode.Unknown) and io.KeyCode or io.UserInputType),Vector3.new(io[iData[io.UserInputType]].X,io[iData[io.UserInputType]].Y,io[iData[io.UserInputType]].Z))
								axisProcessed = true
							elseif axis.DataFormat.Name == "Rotation" then
								axis:Process(io)
							end
						end
					end 
				end
				return true

			end
		end
		return false
	end)
	InputComponent.AddInputPlugin(API.Enumeration.InputPluginType.Render, function(dt)
		if InputComponent.InputSchemes["General"] then
			local iSch = InputComponent.InputSchemes["General"]
			if iSch and InputComponent.CurrentIScheme and InputComponent.CurrentIScheme ~= "None" then
				local axisProcessed = false
				for name, axis in pairs(iSch.Axes) do
					if not axis.Polled then
						continue
					end
					local io = InputComponent:GetCurrentGamepadState(axis.KeyCode)
					if axis.UserInputType == io.UserInputType then
						if axis.KeyCode == io.KeyCode or (not axis.KeyCode) then
							if axis.DataFormat.Name == "Position"  then
								axis:FireAxisChanged(((io.KeyCode and io.KeyCode ~= Enum.KeyCode.Unknown) and io.KeyCode or io.UserInputType),Vector3.new(io[iData[io.UserInputType]].X,io[iData[io.UserInputType]].Y,io[iData[io.UserInputType]].Z))
								axisProcessed = true
							elseif axis.DataFormat.Name == "Rotation" then
								axis:Process(io)
							end
							return true
						end
					end 
				end
			end
		end
		return false
	end)
	InputComponent.AddInputPlugin(API.Enumeration.InputPluginType.Changed, function(io,gp)
		local iSch2 = InputComponent.InputSchemes.General
		for name, axis in pairs(iSch2.Axes) do
			if axis.Polled then
				continue
			end
			if axis.UserInputType == io.UserInputType then
				local cond = true
				if axis.KeyCode then
					cond = axis.KeyCode == io.KeyCode
				end
				if  cond then
					if axis.DataFormat.Name == "Position" then
						axis:FireAxisChanged(((io.KeyCode and io.KeyCode ~= Enum.KeyCode.Unknown) and io.KeyCode or io.UserInputType),Vector3.new(io[iData[io.UserInputType]].X,io[iData[io.UserInputType]].Y,io[iData[io.UserInputType]].Z))
					elseif axis.DataFormat.Name == "Rotation" then
						axis:Process(io)
					end
					return true

				end
			end

		end	
		return false
	end)
	InputComponent.AddInputPlugin(API.Enumeration.InputPluginType.Ended, function(io,gp)
		local iSch = InputComponent.InputSchemes[InputComponent.CurrentIScheme] 
		if iSch then
			for name, axis in pairs(iSch.Axes) do
				if axis.Polled then
					continue
				end
				if axis.UserInputType == io.UserInputType then
					if axis.KeyCode == io.KeyCode then
						if axis.DataFormat.Name == "Analog" then
							local arg1
							if io.KeyCode then
								if io.KeyCode.Name ~= "Unknown" then
									arg1 = io.KeyCode
								else
									arg1 = io.UserInputType
								end
							else
								arg1 = io.UserInputType
							end
							local mousePressed 
							if axis.UserInputType.Name:find("Mouse") then
								mousePressed = API.UIS:IsMouseButtonPressed(axis.UserInputType)
							else
								mousePressed = false
							end
							axis:FireAxisChanged(((io.KeyCode and io.KeyCode ~= Enum.KeyCode.Unknown) and io.KeyCode or io.UserInputType),(API.UIS:IsKeyDown(axis.KeyCode) or API.UIS:IsGamepadButtonDown(axis.UserInputType,axis.KeyCode) or mousePressed) and 1 or 0)
						elseif axis.DataFormat.Name == "Position" then
							axis:FireAxisChanged(((io.KeyCode and io.KeyCode ~= Enum.KeyCode.Unknown) and io.KeyCode or io.UserInputType),Vector3.new(io[iData[io.UserInputType]].X,io[iData[io.UserInputType]].Y,io[iData[io.UserInputType]].Z))
						end
						return true
					end
				end
			end
		end
		return false
	end)
	InputComponent.AddInputPlugin(API.Enumeration.InputPluginType.Ended, function(io,gp)
		local iSch = InputComponent.InputSchemes["General"] 
		if iSch and InputComponent.CurrentIScheme and InputComponent.CurrentIScheme ~= "None" then
			for name, axis in pairs(iSch.Axes) do
				if axis.Polled then
					continue
				end
				if axis.UserInputType == io.UserInputType then
					if axis.KeyCode == io.KeyCode then
						if axis.DataFormat.Name == "Analog" then
							local arg1
							if io.KeyCode then
								if io.KeyCode.Name ~= "Unknown" then
									arg1 = io.KeyCode
								else
									arg1 = io.UserInputType
								end
							else
								arg1 = io.UserInputType
							end
							local mousePressed 
							if axis.UserInputType.Name:find("Mouse") then
								mousePressed = API.UIS:IsMouseButtonPressed(axis.UserInputType)
							else
								mousePressed = false
							end
							axis:FireAxisChanged(((io.KeyCode and io.KeyCode ~= Enum.KeyCode.Unknown) and io.KeyCode or io.UserInputType),(API.UIS:IsKeyDown(axis.KeyCode) or API.UIS:IsGamepadButtonDown(axis.UserInputType,axis.KeyCode) or mousePressed) and 1 or 0)
						elseif axis.DataFormat.Name == "Position" then
							axis:FireAxisChanged(((io.KeyCode and io.KeyCode ~= Enum.KeyCode.Unknown) and io.KeyCode or io.UserInputType),Vector3.new(io[iData[io.UserInputType]].X,io[iData[io.UserInputType]].Y,io[iData[io.UserInputType]].Z))
						end
						return true
					end
				end
			end
		end
		return false
	end)
		return {
			Name = "InputAxis";
			SubComp = InputAxis
		}	
end
