return function(API, InputComponent)

	local LoadoutInputScheme
	API.Enumeration.LoadoutDataFormat = {
		"Incremental";
		"Individual";
	}
	LoadoutInputScheme = API.PseudoInstance:Register("LoadoutInputScheme",{
		Internals = {
			Modes = {};	
			ProcessLoadoutNumber = function(self, input)
				local datum = self.Data[input.KeyCode]
				if datum then
					self:IndexChangedFire(datum)
				end
			end,
			Deactivate = function(self, input, gp)
				self.Deactivated:Fire(input, gp)
			end;
		};
		
		Methods = {
			Activate = function(self,input,gp)
				assert(API.Typer.InstanceOfClassInputObject(input), "[InputComponent 2]: input must be an InputObject.")
				assert(API.Typer.Boolean(gp), "[InputComponent 2]: gameProcessing must be an InputObject.")
				if not gp then
					self:ProcessLoadoutNumber(input)
					
				end
			end;
			Connect = function(self, f)
				assert(API.Typer.Function(f), "[InputComponent 2]: f must be a function.")
				self.IndexChanged:Connect(f)
			end,
			IndexChangedFire = function(self, index)
				self.IndexChanged:Fire(index)
			end,
		};
		
		Events = {
			"Activated";
			"Deactivated";
			"IndexChanged";
		};
		
		Properties = {
			Data = API.Typer.Table;
			AvailableOptions = API.Typer.OptionalFunction;
			UserInputType = API.Typer.EnumOfTypeUserInputType;
			KeyCode = API.Typer.OptionalEnumOfTypeKeyCode;
			Max = API.Typer.PositiveInteger;
			Index = API.Typer.PositiveInteger;
			DataFormat = API.Typer.EnumerationOfTypeLoadoutDataFormat;
		};
		
		Init = function(self, uit, changeType,data,keyCode,max,opts)
			self:superinit()
			self.UserInputType = uit or Enum.UserInputType.Keyboard
			self.DataFormat = changeType or "Individual";
			self.KeyCode = keyCode or nil
			self.Index = 1;
			self.Max = max or 7;
			self.Data = data;
			self.AvailableOptions = opts or function() return {} end;
		end;
	})
	InputComponent.LoadoutSchemes = {};
	InputComponent.AddInputPlugin(API.Enumeration.InputPluginType.Began, function(io,gp)
		if not gp then
			if not gp then
				local loadoutProcessed = false
				for name, loadoutAxis in pairs(InputComponent.LoadoutSchemes) do
					if loadoutAxis.UserInputType == io.UserInputType then
						if loadoutAxis.DataFormat.Name == "Individual" then					
							if io.UserInputType.Name:find("Gamepad")  then
								if io.KeyCode == loadoutAxis.KeyCode and (not  API.Resources:GetFlagValue("MenuOpen")) then 
									if API.Resources:GetFlagValue("LoadoutPrompted") then
										return false
									end
									local choices, choiceTab = loadoutAxis.AvailableOptions()
									API.Resources:SetFlag("LoadoutPrompted", true)
									local choice = _G.HM:PromptLoadout(choiceTab,#choices)
									if choice then
										loadoutAxis:IndexChangedFire(table.find(choices,choice))
									end
									loadoutProcessed = true
									return loadoutProcessed
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
			if not API.UIS:IsKeyDown(Enum.KeyCode.RightShift) then
				local loadoutProcessed = false
				for name, loadoutAxis in pairs(InputComponent.LoadoutSchemes) do
					if loadoutAxis.UserInputType == io.UserInputType then
						if loadoutAxis.DataFormat.Name == "Incremental"   then
							if io.KeyCode == loadoutAxis.KeyCode then 
								loadoutAxis.Index = loadoutAxis.Index + 1
								if loadoutAxis.Index > loadoutAxis.Max then
									loadoutAxis.Index = 1;
								end
								loadoutAxis:IndexChangedFire(loadoutAxis.Index)
								loadoutProcessed = true
							end
						elseif loadoutAxis.DataFormat.Name == "Individual" then
							if io.UserInputType == Enum.UserInputType.Keyboard then
								local index = loadoutAxis.Data[io.KeyCode]
								if index then
									loadoutAxis.Index = index
									loadoutAxis:IndexChangedFire(loadoutAxis.Index)
									loadoutProcessed = true
								end
							end
						end
					end
				end

			end
		end
		
	end)
	function InputComponent.AddLoadoutScheme(name,...)
		InputComponent.LoadoutSchemes[name] = API.PseudoInstance.new("LoadoutInputScheme",...)
		return InputComponent.LoadoutSchemes[name].IndexChanged
	end
	local buttonLoadout = nil
	local buttonLoadoutConn = nil
	function InputComponent.SetLoadoutButton(button: GuiButton)
		if buttonLoadout then
			buttonLoadoutConn:Disconnect()
			buttonLoadoutConn = nil
		end
		buttonLoadout = button 
		buttonLoadoutConn = buttonLoadout.Activated:Connect(function(io)
			if API.Resources:GetFlagValue("LoadoutPrompted") then
				return
			end
			local loadoutProcessed
			for name, loadoutAxis in pairs(InputComponent.LoadoutSchemes) do
				if loadoutAxis.UserInputType == io.UserInputType then
					local choices, choiceTab = loadoutAxis.AvailableOptions()
					local choice = _G.HM:PromptLoadout(choiceTab,#choices,true)
					if choice then
						if choice == "Fist" then
							loadoutAxis:IndexChangedFire(10)
						else
							loadoutAxis:IndexChangedFire(table.find(choices,choice))
						end
					end
					loadoutProcessed = true
					return loadoutProcessed
				end
			end
		end)
		
	end

	return {
		Name = "LoadoutInputScheme";
		SubComp = LoadoutInputScheme;
	}	
end