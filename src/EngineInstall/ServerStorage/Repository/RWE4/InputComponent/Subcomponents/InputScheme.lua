return function(API, InputComponent)

	local InputScheme
	API.Enumeration.InputObjectType = {
		"Axis";
		"Action";
		"ContextAction";
	}
	InputComponent.UsableButtons = {};
	InputComponent.ModeChanged = API.Signal.new()

	InputScheme = API.PseudoInstance:Register("InputScheme",{
		Internals = {

			_registers = {
				[API.Enumeration.InputObjectType.Action] = function(self, name, inputCodes, hold, onRun, existing, mode)
					if existing then
						if mode then
							if  table.find(self.Modes[mode].Actions,name) then
								self.ActionsLibrary[name] = {
									onRun = onRun;
									hold = hold;
									actionInputs = inputCodes;
								}
							end
						end
					else
						if mode then
							if  not table.find(self.Modes[mode].Actions,name) then
								self.ActionsLibrary[name] = {
									onRun = onRun;
									hold = hold;
									actionInputs = inputCodes;
								}					
								table.insert(self.Modes[mode].Actions,name)
							end
						end
					end	
				end;
				[API.Enumeration.InputObjectType.ContextAction] = function(self, cName, name, inputCode, mode)
						if mode then
							if  not table.find(self.Contexts[cName].Modes[mode].Actions,name) then				
								table.insert(self.Contexts[cName].Modes[mode].Actions,{name;inputCode;})
							end
						end
				end;
				[API.Enumeration.InputObjectType.Axis] = function(self, name, uit, dataType, keyCode, polled, rotMode)
					self.Axes[name] = API.PseudoInstance.new("InputAxis",uit,dataType,keyCode,polled,rotMode)
					self.Axes[name].Name = name
					return self.Axes[name].AxisChanged
				end
			};
			Deactivate = function(self, input, gp)
				self.Deactivated:Fire(input, gp)
			end;
		};

		Methods = {
			SwitchContext = function(self, context)
				self.Context = context;
			end,
			AddMode = function(self, mode, name, actions)
				assert(API.Typer.PositiveInteger(mode), "[InputComponent 2]: Mode Index must be an integer.")
				assert(API.Typer.String(name), "[InputComponent 2]: Mode Name must be a string.")
				table.insert(self.Modes,mode,{
					Name = name;
					Actions = actions or {};
				})
			end;
			IsContextualActionPressed = function(self, actionName)
				local context = self.Contexts[self.Context]
				if context then
					if InputComponent.Platform == "Gamepad" then
						local mode = context.Modes[self.Index]
						if mode then
							local actioni do
								for i, action in mode.Actions do
									if action[1] == actionName then
										actioni = i
										break;
									end
								end
							end
							if actioni then
								return InputComponent:IsInputDown(mode.Actions[actioni][2])
							end
						end
					else
						local actionsMode, actionIndex do
							for _, mode2 in context.Modes do
								for i, action in mode2.Actions do
									if action[1] == actionName then
										actionsMode = mode2
										actionIndex = i
										break;
									end
								end
								if actionsMode then
									break
								end
							end
						end
						if actionsMode then
							local actioni = actionsMode.Actions[actionIndex]
							if actioni then
								return InputComponent:IsInputDown(actioni[2])
							end
						end
					end
				end
				return false
			end,
			AddContext = function(self, name)
				assert(API.Typer.String(name), "[InputComponent 2]: Mode Name must be a string.")
				self.Contexts[name] = {
					Name = name;
					Modes = {};
				};
			end,
			AddContextMode = function(self, contextName, mode, name, actions)
				assert(API.Typer.PositiveInteger(mode), "[InputComponent 2]: Mode Index must be an integer.")
				assert(API.Typer.String(name), "[InputComponent 2]: Mode Name must be a string.")
				assert(API.Typer.Table(self.Contexts[contextName]), "[InputComponent 2]: Context must exist.")
				table.insert(self.Contexts[contextName].Modes,mode,{
					Name = name;
					Actions = actions or {};
				})
			end;
			Register = function(self, inputObjectType, ...)
				if self._registers[inputObjectType] then
					return self._registers[inputObjectType](self,...)
				end
			end;
			RegisterContextualAction = function(self, ...)
				self:Register(API.Enumeration.InputObjectType.ContextAction, ...)
			end;
			RegisterAction = function(self, ...)
				self:Register(API.Enumeration.InputObjectType.Action, ...)
			end;
			IsContextual = function(self)
				return self.Context ~= nil;
			end,
			RegisterActionButton = function(self, actionName, button: GuiButton)
				API.CollectionService:AddTag(button, self.Name)
				button:SetAttribute("Action", actionName)
				return button.Activated:Connect(function(i,c)
					if i.UserInputState == Enum.UserInputState.End then
						if i.UserInputType == Enum.UserInputType.Touch then
							self:Run(actionName, i, false)
						end
					end
				end)
			end;
			RegisterPureActionButton = function(self, actionName, button: GuiButton)
				API.CollectionService:AddTag(button, self.Name)
				button:SetAttribute("Action", actionName)
				return button.Activated:Connect(function(i,c)
					if i.UserInputState == Enum.UserInputState.End then
						if i.UserInputType == Enum.UserInputType.Touch and InputComponent.CurrentIScheme == self.Name then
							self:Run(actionName, i, false)
						end
					end
				end)
			end;
			RegisterPureActionButtonDT = function(self, actionName, button: GuiButton)
				API.CollectionService:AddTag(button, self.Name)
				button:SetAttribute("Action", actionName)
				return button.Activated:Connect(function(i,c)
					if i.UserInputState == Enum.UserInputState.End and c >= 2 then
						if i.UserInputType == Enum.UserInputType.Touch and InputComponent.CurrentIScheme == self.Name then
							self:Run(actionName, i, false)
						end
					end
				end)
			end;
			RegisterActionButtonDT = function(self, actionName, button: GuiButton)
				API.CollectionService:AddTag(button, self.Name)
				button:SetAttribute("Action", actionName)
				return button.Activated:Connect(function(i,c)
					if i.UserInputState == Enum.UserInputState.End and c >= 2 then
						if i.UserInputType == Enum.UserInputType.Touch  then
							self:Run(actionName, i, false)
						end
					end
				end)
			end;
			RegisterJoystickAction = function(self, actionName)
				return InputComponent.Joystick.ActionTriggered:Connect(function(n,i,uS)
					if uS then
						if InputComponent.CurrentIScheme ~= self.Name then
							return
						end
					end
					if n == actionName then
						self:Run(actionName, i, false)
					end
				end)
			end;
			RegisterSJModes = function(self, modes)
				self.SJActions = modes;
			end,
			AddAxis = function(self, ...)
				return self:Register(API.Enumeration.InputObjectType.Axis, ...)
			end;
			Activate = function(self,input,gp)
				assert(API.Typer.InstanceOfClassInputObject(input), "[InputComponent 2]: input must be an InputObject.")
				assert(API.Typer.Boolean(gp), "[InputComponent 2]: gameProcessing must be an InputObject.")
				self.Activated:Fire(input,gp)
				self.ActivationCallback(input,gp)
				self:Deactivate(input,gp)
			end;
			GetModeName = function(self)
				if self:IsContextual() then
					return self.Contexts[self.Context].Modes[self.Index].Name
				end
				return self.Modes[self.Index].Name
			end;
			MatchesInput = function(self, inputArray, input, hold)
				local result = true;
				for i, inputCode in ipairs(inputArray) do
					local hCon = false
					if hold then
						hCon =  InputComponent:IsInputDown(input.KeyCode) or InputComponent:IsInputDown(input.UserInputType)
					end
					local condition = ((input.KeyCode == inputCode or input.UserInputType == inputCode) or hCon)
					result = result and condition
					if not result then
						return result
					end
				end
				return result
			end;
			IsPartOfMode = function(self, action)
				return table.find(self.Modes[self.Index].Actions, action)
			end;
			ResetMode = function(self)
				self.Index = 1
			end;
			PrevMode = function(self)
				self.Index = math.clamp(self.Index-1,1,#self.Modes)
			end;
			NextMode = function(self)
				self.Index = math.clamp(self.Index+1,1,#self.Modes)
			end;
			Run = function(self, actionName, input, gp)
				local cond = true
				if API.UIS.GamepadEnabled and #API.UIS:GetConnectedGamepads() > 0 then
					cond = self:IsPartOfMode(actionName)
				end
				if cond then
					local actionEntry = self.ActionsLibrary[actionName] 
					if actionEntry then
						actionEntry.onRun(input,gp)
					end
				end;

			end;
			UnsetContext = function(self)
				self.Context = nil;
			end,
		};

		Events = {
			"Activated";
			"Deactivated";
		};

		Properties = {
			ActivationCodes = API.Typer.OptionalTableOrBoolean;
			ActivationCallback = API.Typer.OptionalFunction;
			ActionsLibrary = API.Typer.OptionalTable;
			Axes = API.Typer.OptionalTable;
			Index = API.Typer.PositiveInteger;
			Active = API.Typer.Boolean;
			Modes = API.Typer.OptionalTable;
			SJActions = API.Typer.OptionalTable;
			Contexts = API.Typer.OptionalTable;
			Context = API.Typer.OptionalString;
		};

		Init = function(self, ...)
			self:superinit()
			local args = {...}
			self.Modes = {};	
			for i, item in ipairs(args[1]) do
				self:AddMode(i,item[1],item[2] or {})
			end;
			self.Contexts = {};
			self.Index = 1
			self.ActionsLibrary = {};
			self.Axes = {};
			self.Active = false
			self.ActivationCodes = args[2] 
			if not self.ActivationCodes then
				self.ActivationCodes = {Enum.UserInputType.MouseButton1,Enum.KeyCode.ButtonR2}
			end
			self.ActivationCallback = args[3] or function(input,gp) end;
			
		end;
	})
	InputComponent.SchemeJan = API.Janitor.new()
	InputComponent.InputSchemes.General = API.PseudoInstance.new("InputScheme",{

	},false,false)
	InputComponent.RegisterSchemeAction = function(schemeName,...)
		InputComponent.InputSchemes[schemeName]:RegisterAction(...)
	end
	InputComponent.IsMode = function(schemeName,mode)
		return InputComponent.InputSchemes[schemeName].Index == mode
	end
	InputComponent.IsContextPressed = function(schemeName, actionName)
		return InputComponent.InputSchemes[schemeName]:IsContextualActionPressed(actionName)
	end
	InputComponent.GetCModeTitle = function(schemeName)
		return InputComponent.InputSchemes[schemeName].Modes[InputComponent.GetSchemeMode(schemeName)].Name
	end
	InputComponent.IsInContext = function()
		return InputComponent.InputSchemes[InputComponent.CurrentIScheme]:IsInContext()
	end
	InputComponent.SetContextForScheme = function(schemeName, context)
		InputComponent.InputSchemes[schemeName].Context = context
	end
	InputComponent.RegisterSchemeContext = function(schemeName,cn)
		InputComponent.InputSchemes[schemeName]:AddContext(cn)
	end
	InputComponent.RegisterSchemeContextMode = function(schemeName,cn,mode,name,actions)
		InputComponent.InputSchemes[schemeName]:AddContextMode(cn, mode, name, actions)
	end
	InputComponent.RegisterSchemeContextAction = function(schemeName, cName, name, inputCode, mode)
		InputComponent.InputSchemes[schemeName]:RegisterContextualAction(cName, name, inputCode, mode)
	end
	InputComponent.ListenForModeChanged = function(f)
		return InputComponent.ModeChanged:Connect(f)
	end
	InputComponent.RegisterSchemeActionButtonDT = function(schemeName,...)
		return InputComponent.InputSchemes[schemeName]:RegisterActionButtonDT(...)
	end
	InputComponent.RegisterSchemePAButtonDT = function(schemeName,...)
		return InputComponent.InputSchemes[schemeName]:RegisterPureActionButtonDT(...)
	end
	InputComponent.RegisterSchemeActionButton = function(schemeName,...)
		return InputComponent.InputSchemes[schemeName]:RegisterActionButton(...)
	end
	InputComponent.RegisterPAButton = function(schemeName, ...)
		return InputComponent.InputSchemes[schemeName]:RegisterPureActionButton(...)
	end
	
	InputComponent.RegisterSchemeJoystickAction = function(schemeName,...)
		return InputComponent.InputSchemes[schemeName]:RegisterJoystickAction(...)
	end
	InputComponent.RegisterSchemeAxis = function(schemeName,...)
		local axis =  InputComponent.InputSchemes[schemeName]:AddAxis(...)
		return axis
	end
	InputComponent.RegisterSJSchemeModes = function(schemeName,modes)
		InputComponent.InputSchemes[schemeName]:RegisterSJModes(modes)
	end
	InputComponent.AddInputScheme = function(schemeName,...)
		InputComponent.InputSchemes[schemeName] = API.PseudoInstance.new("InputScheme",...)
		InputComponent.InputSchemes[schemeName].Name = schemeName
		InputComponent.SchemeJan:Add(InputComponent.InputSchemes[schemeName]:GetPropertyChangedSignal("Index"):Connect(function()
			InputComponent.ModeChanged:Fire(schemeName, InputComponent.InputSchemes[schemeName].Index)
		end), "Disconnect", schemeName)
	end
	InputComponent.SetActivationCodes = function(schemeName,codes)
		InputComponent.InputSchemes[schemeName].ActivationCodes  = codes
	end
	InputComponent.SetActivationCB = function(schemeName, callback)
		InputComponent.InputSchemes[schemeName].ActivationCallback = callback
	end
	InputComponent.ResetSchemeMode = function(schemeName)
		 InputComponent.InputSchemes[schemeName]:ResetMode()
	end
	InputComponent.GetSchemeMode = function(schemeName)
		return InputComponent.InputSchemes[schemeName].Index;
	end
	InputComponent.IsMultiModed = function(schemeName,callback)
		if not InputComponent.InputSchemes[schemeName] then
			return false
		end
		local modes = InputComponent.InputSchemes[schemeName].Modes
		local c = 0
		for i, v in ipairs(modes) do
			if v then
				c += 1;
			end
		end
		return c > 1
	end
	InputComponent.IsActive = function()
		local iSch =  InputComponent.InputSchemes[InputComponent.CurrentIScheme]
		if iSch then
			return iSch.Active
		end
		return false
	end;
	function InputComponent.ResetGeneralScheme(modes)
		InputComponent.InputSchemes["General"] = API.PseudoInstance.new("InputScheme",modes)
		InputComponent.InputSchemes["General"].Name = "General"

	end
	function InputComponent.SetupGeneralIScheme(modes)
		InputComponent.InputSchemes["General"] =  API.PseudoInstance.new("InputScheme",modes)
		InputComponent.InputSchemes["General"].Name = "General"
		local finalize = false
		InputComponent.AddInputScheme("Toolbox",{
			{"Basic";{
				"Rotate";
				"Cancel";
				"RaiseObject";
				"LowerObject";
			}};	
		},{Enum.UserInputType.MouseButton1;Enum.KeyCode.ButtonR2;},function(i,gp)
			local Sessions = API.Resources:GetLocalTable("Sessions");
			if Sessions.Current and not finalize then
				finalize = true
				Sessions.Current:Finalize()
				finalize = false	
			end
		end)
	end
	InputComponent.ExtraModeOn = false

	function InputComponent.RemoveInputScheme(schemeName)
		if schemeName == "General" then return end
		InputComponent.InputSchemes[schemeName] = nil
		InputComponent.SchemeJan:Remove(schemeName)
		if schemeName == InputComponent.CurrentIScheme then
			InputComponent.CurrentIScheme = "General"
		end
	end
	function InputComponent.HideScheme(schemeName)
		local buttons = API.CollectionService:GetTagged(schemeName)
		if schemeName == "General" then
			return
		end
		for _, button in ipairs(buttons) do
			if button.Parent.Name ~= "MobileButtons" then
				continue
			end
			
			button.Visible = false
			local i = table.find(InputComponent.UsableButtons, button)
			if i then
				table.remove(InputComponent.UsableButtons, i)
			end
		end
		
	end
	function InputComponent.ShowScheme(schemeName)
		local buttons = API.CollectionService:GetTagged(schemeName)
		if schemeName == "General" then
			return
		end
		for _, button in ipairs(buttons) do
			if button.Parent.Name ~= "MobileButtons" then
				continue
			end
			button.Visible = true
			table.insert(InputComponent.UsableButtons, button)
		end
	end
	function InputComponent.ShowGeneralAction(actionName)
		local buttons = API.CollectionService:GetTagged("General")
		local par 
		for _, button in ipairs(buttons) do
			par = button.Parent
			if button.Parent.Name ~= "MobileButtons" then
				continue
			end
			
			if button:GetAttribute("Action") == actionName then
				button.Visible = true
				table.insert(InputComponent.UsableButtons, button)
				return
			end
		end
		par.LeadButton.Visible = _G.IsLeader()
		par.LoadoutButton.Visible = true

	end
	function InputComponent.HideGeneralAction(actionName)
		local buttons = API.CollectionService:GetTagged("General")
		local par 
		for _, button in ipairs(buttons) do
			par = button.Parent
			if button.Parent.Name ~= "MobileButtons" then
				continue
			end
			if button.Name == "LeadButton" and _G.IsLeader() then
				continue
			end
			if button:GetAttribute("Action") == actionName then
				button.Visible = false
				local i = table.find(InputComponent.UsableButtons, button)
				if i then
					table.remove(InputComponent.UsableButtons, i)
				end
				return
			end
		end
		par.LeadButton.Visible = _G.IsLeader()
		par.LoadoutButton.Visible = true
	end
	local activateButton, activateConn, activateConn2
	
	function InputComponent.SetActivateButton(button: GuiButton)
		if activateButton then
			activateConn:Disconnect()
			activateConn2:Disconnect()
			activateConn = nil
		end
		activateButton = button
		activateConn = activateButton.InputBegan:Connect(function(io)
			local gScheme = InputComponent.InputSchemes["General"]
			if gScheme.Name == InputComponent.CurrentIScheme then
				return false
			end

			local iSch = InputComponent.InputSchemes[InputComponent.CurrentIScheme] 
			if iSch then
				if io.UserInputType == Enum.UserInputType.Touch then
					iSch.Active = true
					API.fastSpawn(function() iSch:Activate(io,false)	end)
					return false
				end
			end
		end)
		activateConn2 = activateButton.InputEnded:Connect(function(io)
			local gScheme = InputComponent.InputSchemes["General"]
			if gScheme.Name == InputComponent.CurrentIScheme then
				return false
			end
			local iSch = InputComponent.InputSchemes[InputComponent.CurrentIScheme] 
			if iSch then
				if io.UserInputType == Enum.UserInputType.Touch then
					iSch.Active = false
					return false
				end
			end
		end)
	end
	
	InputComponent.AddInputPlugin(API.Enumeration.InputPluginType.Began, function(io,gp)
		if not gp then
			if io.UserInputType.Name:find("MouseButton") then
				InputComponent.Pressed[io.UserInputType] = true
				InputComponent.Held[io.UserInputType] = tick()
				return false 
			end
			InputComponent.Pressed[io.KeyCode] = true
			InputComponent.Held[io.KeyCode] = tick()
		end
		return false
	end)
	InputComponent.AddInputPlugin(API.Enumeration.InputPluginType.Began, function(io,gp)
		if not gp then
			local gScheme = InputComponent.InputSchemes["General"]
			if gScheme.Name == InputComponent.CurrentIScheme then
				return false
			end

			local iSch = InputComponent.InputSchemes[InputComponent.CurrentIScheme] 
			if iSch then
				if API.inList(io.KeyCode,iSch.ActivationCodes) or API.inList(io.UserInputType,iSch.ActivationCodes) then
					iSch.Active = true
					API.fastSpawn(function() iSch:Activate(io,gp)	end)
					return false
				end
			end
		end
		return false
	end)
	InputComponent.AddInputPlugin(API.Enumeration.InputPluginType.Ended, function(io,gp)
		if not gp then
			local gScheme = InputComponent.InputSchemes["General"]
			if gScheme.Name == InputComponent.CurrentIScheme then
				return false
			end
			local iSch = InputComponent.InputSchemes[InputComponent.CurrentIScheme] 
			if iSch then
				if API.inList(io.KeyCode,iSch.ActivationCodes) or API.inList(io.UserInputType,iSch.ActivationCodes) then
					iSch.Active = false
					return false
				end
			end
		end
		return false
	end)
	InputComponent.AddInputPlugin(API.Enumeration.InputPluginType.Began, function(io,gp)
		if not gp then
			local iSch = InputComponent.InputSchemes["General"]
			if iSch then
				if API.inList(io.KeyCode,iSch.ActivationCodes) or API.inList(io.UserInputType,iSch.ActivationCodes) then
					iSch.Active = true
					API.fastSpawn(function()iSch:Activate(io,gp)	end)
					return false
				end
			end
		end
		return false
	end)
	InputComponent.AddInputPlugin(API.Enumeration.InputPluginType.Ended, function(io,gp)
		if not gp then
			local iSch = InputComponent.InputSchemes["General"]
			if iSch then
				if API.inList(io.KeyCode,iSch.ActivationCodes) or API.inList(io.UserInputType,iSch.ActivationCodes) then
					iSch.Active = false
					return false
				end
			end
		end
		return false
	end)
	InputComponent.AddInputPlugin(API.Enumeration.InputPluginType.Ended, function(io,gp)
		if not gp then
			if io.UserInputType.Name:find("MouseButton") then
				InputComponent.Pressed[io.UserInputType] = false
				if InputComponent.Held[io.UserInputType] then
					InputComponent.Held[io.UserInputType] = tick() - InputComponent.Held[io.UserInputType] 
				end
				return false 
			end
			InputComponent.Pressed[io.KeyCode] = false
			if InputComponent.Held[io.KeyCode] then
				InputComponent.Held[io.KeyCode] = tick() - InputComponent.Held[io.KeyCode] 
			end
		end
		return false
	end)
	InputComponent.AddInputPlugin(API.Enumeration.InputPluginType.Ended, function(io,gp)
		if not gp then
			local gScheme = InputComponent.InputSchemes["General"]
			if gScheme.Name == InputComponent.CurrentIScheme then
				return false
			end
			local iSch = InputComponent.InputSchemes[InputComponent.CurrentIScheme] 
			if iSch and InputComponent.CurrentIScheme and InputComponent.CurrentIScheme ~= "None" then
				if not InputComponent.ExtraModeOn then
					if io.UserInputType == Enum.UserInputType.Keyboard or io.UserInputType == InputComponent:GetActiveGamepad() then
						for aName, actionData in pairs(iSch.ActionsLibrary) do
							local cond = true
							if API.UIS.GamepadEnabled and #API.UIS:GetConnectedGamepads() > 0 then
								cond = iSch:IsPartOfMode(aName)
							end
							if cond  then
								if iSch:MatchesInput(actionData.actionInputs,io,actionData.hold) then
									iSch:Run(aName,io,gp)
									return false
								end
							end
						end
					elseif io.UserInputType.Name:find("MouseButton") then
						for aName, actionData in pairs(iSch.ActionsLibrary) do
							if iSch:IsPartOfMode(aName) then
								if iSch:MatchesInput(actionData.actionInputs,io,actionData.hold) then
									iSch:Run(aName,io,gp)
									return false
								end
							end
						end
					end
				end
			end
		end
		return false
	end)
	InputComponent.AddInputPlugin(API.Enumeration.InputPluginType.Ended, function(io,gp)
		if not gp then
			local iSch = InputComponent.InputSchemes["General"]
			if iSch and InputComponent.CurrentIScheme and InputComponent.CurrentIScheme ~= "None" then
				if io.UserInputType == Enum.UserInputType.Keyboard or io.UserInputType == InputComponent:GetActiveGamepad() then
					if io.KeyCode ~= Enum.KeyCode.DPadDown then
						for aName, actionData in pairs(iSch.ActionsLibrary) do
							local cond = true
							if API.UIS.GamepadEnabled and #API.UIS:GetConnectedGamepads() > 0 then
								cond = iSch:IsPartOfMode(aName)
							end
							if cond  then
								if iSch:MatchesInput(actionData.actionInputs,io,actionData.hold) then

									iSch:Run(aName,io,gp)
									if InputComponent.ExtraModeOn then
										InputComponent.ExtraModeOn = false
										InputComponent.InputSchemes.General.Index = 1;
									end
									return true
								end
							end
						end
					else
						if InputComponent.InputSchemes[InputComponent.CurrentIScheme].Index <= 1 and tostring(_G.CurrentUI) == "HUD" then
							InputComponent.ExtraModeOn = not InputComponent.ExtraModeOn 
							print("Extra Mode: ", InputComponent.ExtraModeOn)
							return true
						end
					end
				elseif io.UserInputType.Name:find("MouseButton") then
					for aName, actionData in pairs(iSch.ActionsLibrary) do
						if iSch:IsPartOfMode(aName) then
							if iSch:MatchesInput(actionData.actionInputs,io,actionData.hold) then

								iSch:Run(aName,io,gp)
								if InputComponent.ExtraModeOn then
									InputComponent.ExtraModeOn = false
									InputComponent.InputSchemes.General.Index = 1;
								end
								return true
							end
						end
					end
				end
			end
		end
		return false
	end)
	InputComponent.AddInputPlugin(API.Enumeration.InputPluginType.Ended, function(io,gp)
		if (not gp) and _G.CurrentUI then
			if _G.CurrentUI.Name == "HUD" then
				if io.KeyCode == Enum.KeyCode.DPadUp then
					if not InputComponent.ExtraModeOn then
						InputComponent.InputSchemes[InputComponent.CurrentIScheme]:NextMode()
					else
						InputComponent.InputSchemes.General:NextMode()
					end
					return true
				elseif io.KeyCode == Enum.KeyCode.DPadDown then
					if not InputComponent.ExtraModeOn then
						InputComponent.InputSchemes[InputComponent.CurrentIScheme]:PrevMode()
					else
						InputComponent.InputSchemes.General:PrevMode()
					end
					return true
				end
			end
		end
		return false
	end)

	return {
		Name = "InputScheme";
		SubComp = InputScheme
	}	
end