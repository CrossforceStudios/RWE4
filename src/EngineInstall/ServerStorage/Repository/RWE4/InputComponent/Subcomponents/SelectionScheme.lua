return function(API, InputComponent)

	local SelectionScheme
	SelectionScheme = API.PseudoInstance:Register("SelectionScheme",{
		Internals = {
		};
		
		Methods = {
			MapPreset = function(self, objIndex, navType, corrIndex)
						local obj = self.Objects[objIndex]
						local corrObj = self.Objects[corrIndex]
						if obj and corrObj then
							if navType ==  "Up" or navType == "Down" or navType == "Left" or navType == "Right"  then
								if not self.Map[objIndex] then
									self.Map[objIndex] = {}
								end
								self.Map[objIndex][navType] = corrIndex
							end
						end
			end;
			AddInput = function(self, index, code, action)
						if not self.Inputs[index] then
							self.Inputs[index] = {}
						end
						self.Inputs[index][code] = function()
							action(self)
						end
			end;
			AddObject = function(self, obj)
						if not obj:IsA("GuiObject") then return end
						self.Objects[#self.Objects+1] = obj
						if obj:FindFirstChild("Indicator") then	
					InputComponent.StyleControlImage(obj.Indicator,Enum.KeyCode.ButtonA,"Dark",if InputComponent.isPlayStation() then "Playstation" else "XboxOne")
						end
			end;
			GetSelectedObject = function(self)
						return self.Active and  self.Objects[self.Index] or nil;
			end;
			Select = function(self, index)
						if InputComponent.Platform ~= "Gamepad" then
							return 
						end
						if self.Objects[self.Index] then
							self.Objects[self.Index].Indicator.Visible = false
						end
						if index then
							self.Index = index
						end
						if self.Objects[self.Index] then
							self.Objects[self.Index].Indicator.Visible = true
						end
						if not self.Active then
							self.Active = true
						end	
						self.Janitor:Remove("Select")
						self.Janitor:Add(self.SelectionChanged:Connect(function(i,o)
							self:ShowIndication(i,o)
						end),"Disconnect","Select")
						self.SelectionChanged:Fire(self.Index,self.Objects[self.Index])

			end;
			ShowIndication = function(self, i, o, override)
						for i2, v in pairs(self.Objects) do
							if v:FindFirstChild("Indicator") then
								v.Indicator.Visible = (override) or  not (i2 ~= i)
							end
						end
						if o then
							if o:FindFirstChild("Indicator") then
								o.Indicator.Visible = override or self.Active
							end
						end
			end;
			Deselect = function(self)
						self:ShowIndication(self.Index,self.Objects[self.Index],false)		
						self.Active = false
			end;
			ResetConn = function(self)
				self.Janitor:Remove("Select")
			end,
		};
		
		Events = {
			"SelectionChanged";
		};
		
		Properties = {
			Index = API.Typer.Integer;
			Active = API.Typer.Boolean;
			Map = API.Typer.OptionalTable;
			Objects = API.Typer.OptionalTable;
			Inputs = API.Typer.OptionalTable;

		};
		
		Init = function(self, name, index )
			self:superinit()
			self.Name = name;
			self.Index =  index or 1;
			self.Active = false;
			self.Map = {};
			self.Objects = {};
			self.Inputs = {};

		end;
		
	})


	function InputComponent.AddSelectionScheme(name,...)
		local scheme =  API.PseudoInstance.new("SelectionScheme",name,...)
		InputComponent.SelectionSchemes[name] = scheme
		return scheme
	end		
	function InputComponent.AddObjectToSelection(name,obj)
		local scheme = InputComponent.SelectionSchemes[name]
		scheme:AddObject(obj)
	end
	function InputComponent.MapSelectionObject(name,obj,direction,cI)
		local scheme = InputComponent.SelectionSchemes[name]
		scheme:MapPreset(obj,direction,cI)
	end
	function InputComponent.SelectObject(name,index)
		local scheme = InputComponent.SelectionSchemes[name]
		if scheme then
			if InputComponent.CurrentSelection ~= name then
				InputComponent.CurrentSelection = name
				for n, v in pairs(InputComponent.SelectionSchemes) do
					if n ~= name then
						v:Deselect()
					end
				end
			end
			scheme:Select(index)
		end
	end
	function InputComponent.DeselectObject(name,index)
		local scheme = InputComponent.SelectionSchemes[name]
		if scheme then
			scheme:Deselect()
		end
		InputComponent.CurrentSelection = "None"
	end
	function InputComponent.DeselectAll()
		local scheme = InputComponent.SelectionSchemes[InputComponent.CurrentSelection]
		if scheme then
			InputComponent.PreviousSelection = 	InputComponent.CurrentSelection
			scheme:Deselect()
		end
		InputComponent.CurrentSelection = "None"
	end
	function InputComponent.Reselect(index)
		local scheme = InputComponent.SelectionSchemes[InputComponent.PreviousSelection]
		if scheme then	
			scheme:Select(index)
		end
	end
	function InputComponent.GetSelected(name)
		local scheme = InputComponent.SelectionSchemes[name]
		return scheme:GetSelectedObject()
	end
	function InputComponent.GetSelectActive(name)
		local scheme = InputComponent.SelectionSchemes[name]
		return scheme.Active
	end
	function InputComponent.SetSelectionAction(name,index,code,action)
		local scheme = InputComponent.SelectionSchemes[name]
		scheme:AddInput(index,code,action)
	end
	function InputComponent.ClearSelectionScheme(name)
		local scheme = InputComponent.SelectionSchemes[name]
		scheme.Objects = {}
		scheme.Map = {}
		scheme.Inputs = {}
		scheme:ResetConn()
	end
	function InputComponent.ClearSelectionSchemeL(name)
		local scheme = InputComponent.SelectionSchemes[name]
		if scheme then
			scheme.Objects = {}
			scheme.Map = {}
			scheme.Inputs = {}
		end
	end
	function InputComponent.ListenForSelection(name,listener)
		local scheme = InputComponent.SelectionSchemes[name]
		return scheme.SelectionChanged:Connect(listener)
	end
	local inputK = false
	InputComponent.AddInputPlugin(API.Enumeration.InputPluginType.Ended, function(io,gp)
			local scheme = InputComponent.SelectionSchemes[InputComponent.CurrentSelection]
			if scheme then
				if scheme.Active then
					if io.UserInputType == InputComponent:GetActiveGamepad() then	
						local keyCode = io.KeyCode
						if keyCode.Name:find("DPad") then
							local direction = keyCode.Name:sub(5,#keyCode.Name)
							local nextIndex = scheme.Map[scheme.Index]
							if nextIndex then
								nextIndex = nextIndex[direction]
							end
							if nextIndex then
							
								while not scheme.Objects[nextIndex].Visible or (not scheme.Objects[nextIndex].Parent.Visible) do
									if not scheme.Objects[nextIndex].Visible or (not scheme.Objects[nextIndex].Parent.Visible) then
										print("Next One")
										if scheme.Objects[nextIndex + 1] then
											nextIndex = nextIndex + 1
										elseif nextIndex + 1 > #scheme.Objects then
											nextIndex = 1
										end
									end
									API.RunService.RenderStepped:Wait()
								end
								scheme:Select(nextIndex)
								return true
							end
						elseif scheme.Inputs[scheme.Index] then 
								for code, action in pairs(scheme.Inputs[scheme.Index]) do
									if code == keyCode and not inputK then
										inputK = true
										API.fastSpawn(function() action() end)
										print(inputK)
									end
								end
								if  inputK then
									inputK = false
								end
								return true
						end
					end
				end
			end
	end)
	return {
		Name = "SelectionScheme";
		SubComp = SelectionScheme;
	}	
end