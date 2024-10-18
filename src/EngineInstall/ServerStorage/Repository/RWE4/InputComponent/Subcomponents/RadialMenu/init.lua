return function(API, InputComponent)
	local Graph =  API.Resources:LoadLibrary("Graph")
	local RadialMenu = {};
	local RADIUS = Vector2.new(.15,.2)
	local MAX_OPTIONS = 8
	local ANGLE_OFFSET = 90
	local menuItems = {}
	local menuGrph = Graph.new(API.Enumeration.GraphType.OneWay)
	local optionsT = nil;
	local defaultT = nil;
	local startNode = {};
	local GuiService = game:GetService("GuiService")
	RadialMenu.RadialUI = nil;
	function RadialMenu:addMenuItem(name, angle, range, indexValue, radius)
		local newItem = {}
		local label = (InputComponent.Platform == "Keyboard" and script.SectionButton or script.SectionButtonConsole) :Clone()
		label.Label.Text = name:upper()
		label.Name = name
		local angleRadians = math.rad(ANGLE_OFFSET + angle)
		label.AnchorPoint = Vector2.new(0.5,0.5)
		label.Position = UDim2.new(.5 + radius.X * math.cos(angleRadians), 0,
			.5 - radius.Y * math.sin(angleRadians), 0)
		label.Parent = self.RadialUI
		newItem.Label = label
		newItem.Vector = Vector2.new(math.cos(angleRadians), -math.sin(angleRadians))
		newItem.Range = range
		newItem.Value = indexValue
		table.insert(menuItems, newItem)
	end
	function RadialMenu:deselectMenu(forceDestroy)
		self.RadialUI:ClearAllChildren()
		for i, menu in pairs(menuItems) do
			if menu.Label then
				menu.Label:Destroy()
			end
			menuItems[i] = nil;
		end
		menuItems = {}
		if forceDestroy then
			optionsT = nil;
			menuGrph = Graph.new(API.Enumeration.GraphType.OneWay)
		end
		if forceDestroy then API.Resources:SetFlag("MenuOpen", false) end
		local isMouseUnlocked =  (_G.CurrentUI ~= RadialMenu.RadialUI.Parent) 
		InputComponent.ToggleMouseControl(not isMouseUnlocked, not isMouseUnlocked)
		GuiService.SelectedObject = nil;
	end
	function RadialMenu:deselectMenuPC(forceDestroy)
		local ui = _G.HM.UI.OptionsPalette.Options.Container
		for i, menu in pairs(menuItems) do
			if menu.Label then
				menu.Label:Destroy()
			end
			menuItems[i] = nil;
		end
		menuItems = {}
		if forceDestroy then
			optionsT = nil;
			menuGrph = Graph.new(API.Enumeration.GraphType.OneWay)
		end
		if forceDestroy then API.Resources:SetFlag("MenuOpen", false) end
		ui.Parent.Visible = false
		ui.Parent.Parent.OptionTip.Visible = false

		local isMouseUnlocked = (_G.CurrentUI ~= RadialMenu.RadialUI.Parent) 
		InputComponent.ToggleMouseControl(not isMouseUnlocked, not isMouseUnlocked)

	end
	RadialMenu.InteractionSelected = API.Signal.new()
	function RadialMenu:addMenuItemPC(name, indexValue)
		local newItem = {}
		local ui = _G.HM.UI.OptionsPalette.Options.Container
		local label = API.Resources:GetUITemplate("OptionButton"):Clone()
		label.Symbol.Text = indexValue
		label.Name = "Item" .. name
		label:SetAttribute("Title", name)
		label.Parent = ui
		label:SetAttribute("OptionIndex", indexValue)
		newItem.Label = label
		newItem.Value = indexValue
		table.insert(menuItems, newItem)
	end
	function RadialMenu:selectNodePC(node)
		self:deselectMenuPC(false)
		local neighbors = menuGrph:Neighbors(node)
		local SelectedObject
		if neighbors then
			local i = 1
			local ui = _G.HM.UI.OptionsPalette.Options.Container

			MAX_OPTIONS = #(neighbors)
			for _, node2 in (neighbors) do
				if node2 then
					local name
					for k, options in (node == startNode and optionsT or node) do
						if options == node2 then
							name = k
							break;
						end
					end

					if name then
						self:addMenuItemPC(name,#menuItems+1)	
						local currentI = #menuItems
						menuItems[i].Action = function()
							if typeof(node2) == "function" then
								node2()
								self.InteractionSelected:Fire(name)
								self:deselectMenuPC(true)
							elseif typeof(node2) == "table" then
								self:selectNodePC(node2)
							end;
						end
					end
					i = i + 1
				end
			end
			if i >= 3 then
				ui.Parent.Size = UDim2.new(0.18, 0, 0.1, 0)
			else
				ui.Parent.Size = UDim2.new(0.05, 0, 0.1, 0)
			end
			local currentIndex = 1;
			SelectedObject = menuItems[1].Label
			ui.OrderLayout:JumpTo(SelectedObject)
			local function onThumbstickMoved(actionName, inputState, inputObject)
				if inputObject.KeyCode == Enum.KeyCode.DPadRight then
					ui.OrderLayout:Next()
				else	if inputObject.KeyCode == Enum.KeyCode.DPadLeft then
						ui.OrderLayout:Previous()
					elseif inputObject.UserInputType == Enum.UserInputType.MouseWheel then
						if inputObject.Position.Z > 0 then
							ui.OrderLayout:Next()
						elseif inputObject.Position.Z < 0 then
							ui.OrderLayout:Previous()
						end
					end
				end
				currentIndex = ui.OrderLayout.CurrentPage:GetAttribute("OptionIndex")
				ui.Parent.Parent.OptionTip.Text = ui.OrderLayout.CurrentPage:GetAttribute("Title")

				for i, m in ipairs(menuItems) do
					m.Label.Use.BackgroundColor3 = if i == currentIndex then Color3.fromRGB(255,232,126) else Color3.fromRGB(240,240,240)
				end


				return Enum.ContextActionResult.Sink

			end
			API.ContextActionService:BindAction("CycleMenuGP",function(a,s,i)
				onThumbstickMoved(a,s,i)
				return Enum.ContextActionResult.Sink
			end,false,Enum.KeyCode.DPadRight,Enum.KeyCode.DPadLeft, Enum.UserInputType.MouseWheel)
			API.ContextActionService:BindAction("SelectMenuItem",function(a,s,i)
				if s == Enum.UserInputState.End then
					if menuItems[currentIndex] then menuItems[currentIndex].Action() end
					API.FastDelay(1/60,function()
						API.ContextActionService:UnbindAction("CycleMenu")
						API.ContextActionService:UnbindAction("SelectMenuItem")
					end)
					return Enum.ContextActionResult.Sink
				end
			end,false,Enum.KeyCode.Return)
			for i, m in ipairs(menuItems) do
				m.Label.Use.BackgroundColor3 = if i == currentIndex then Color3.fromRGB(255,232,126) else Color3.fromRGB(240,240,240)
			end
			ui.Parent.Visible = true
			ui.Parent.Parent.OptionTip.Visible = true
			ui.Parent.Parent.OptionTip.Text = ui.OrderLayout.CurrentPage:GetAttribute("Title")

		end
	end
	function RadialMenu:selectNode(node,loadoutObj,r)
		self:deselectMenu(false)
		local avO, avT
		if loadoutObj then
			avO, avT = loadoutObj.AvailableOptions()
		end
		local neighbors = menuGrph:Neighbors(node)

		if neighbors then
			local i = 1
			MAX_OPTIONS = #(neighbors)
			for _, node2 in ipairs(neighbors) do
				if node2 then
					local name
					for k, options in pairs(node == startNode and optionsT or node) do
						if options == node2 then
							name = k
							break;
						end
					end

					if name then
						self:addMenuItem(name, (360 / MAX_OPTIONS) * (i - 1), 360 / MAX_OPTIONS,avO and table.find(avO,name) or #menuItems+1,r)	
						local currentI = #menuItems
						menuItems[i].Label.Activated:Connect(function(io)
							if typeof(node2) == "function" then
								node2()
								self.InteractionSelected:Fire(name)
								self:deselectMenu(true)
							elseif typeof(node2) == "table" then
								self:selectNode(node2,false,r)
							end
						end)
						menuItems[i].Action = function()
							if typeof(node2) == "function" then
								node2()
								self.InteractionSelected:Fire(name)
								self:deselectMenu(true)
							elseif typeof(node2) == "table" then
								self:selectNode(node2,false,r)
							end;
						end
					end
					i = i + 1
				end
			end
			if InputComponent.Platform == "Keyboard" then
				local tab = {};
				for i, menuItem in ipairs(menuItems) do
					if menuItems[i+1] then
						menuItems[i].Label.NextSelectionRight = menuItems[i+1].Label
					end
					if menuItems[i-1] then
						menuItems[i].Label.NextSelectionLeft = menuItems[i-1].Label
					end
				end
				GuiService:AddSelectionTuple("RadialMenu",unpack(menuItems))
				GuiService.SelectedObject = menuItems[1].Label
			end
			if InputComponent.Platform == "Gamepad" then
				local currentIndex = 1;
				if not loadoutObj then
					for i, menuItem in ipairs(menuItems) do
						if menuItems[i+1] then
							menuItems[i].Label.NextSelectionRight = menuItems[i+1].Label
						end
						if menuItems[i-1] then
							menuItems[i].Label.NextSelectionLeft = menuItems[i-1].Label
						end
					end
					GuiService:AddSelectionTuple("RadialMenu",unpack(menuItems))
					GuiService.SelectedObject = menuItems[1].Label
					return
				end
				for i, menuI in ipairs(menuItems) do
					InputComponent.StyleControlImage(menuI.Label.Selector,"ButtonY","Dark","XboxOne")
				end
				local function getButtonFromVector(vector)
					for i = 1, #menuItems do
						local item = menuItems[i]
						local dotProduct = vector.X * item.Vector.X + vector.Y * item.Vector.Y
						local angle = math.acos(dotProduct / vector.magnitude)
						if angle <= math.rad(item.Range) / 2 then
							currentIndex = i
							return item.Label
						end
					end
					return nil
				end

				local function onThumbstickMoved(actionName, inputState, inputObject)
					-- Make sure the thumbstick was moved past the deadzone
					if inputObject.Position.magnitude >= InputComponent.Deadzone then
						-- Calculate the angle based on the position of the thumbstick
						local selectedButton = getButtonFromVector(inputObject.Position)
						print(selectedButton)
					end
					for i, m in ipairs(menuItems) do
						m.Label.Selector.Visible = i == currentIndex
					end
				end
				API.ContextActionService:BindAction("CycleMenu",function(a,s,i)
					local cond = true
					if loadoutObj then
						cond = cond and InputComponent:IsInputDown(loadoutObj.KeyCode)
					end
					if cond then
						onThumbstickMoved(a,s,i)
					end
					return Enum.ContextActionResult.Sink
				end,false,Enum.KeyCode.Thumbstick1)
				API.ContextActionService:BindAction("SelectMenuItem",function(a,s,i)
					if s == Enum.UserInputState.End then
						if menuItems[currentIndex] then menuItems[currentIndex].Action() end
						API.FastDelay(1/60,function()
							API.ContextActionService:UnbindAction("CycleMenu")
							API.ContextActionService:UnbindAction("SelectMenuItem")
						end)
						return Enum.ContextActionResult.Sink
					end
				end,false,loadoutObj and loadoutObj.KeyCode or Enum.KeyCode.ButtonY)
				for i, m in ipairs(menuItems) do
					m.Label.Selector.Visible = i == currentIndex
				end
			end
		end
	end
	function RadialMenu:setupOptions(options,menuKey)
		for key, option in pairs(options) do
			menuGrph:AddVertex(option)
			if menuKey then
				menuGrph:Connect(menuKey,option)
			end
			if typeof(option) == "table" then
				self:setupOptions(option,option)
			end
		end
	end
	function RadialMenu:openPCMenu(graphTB)
		if typeof(graphTB) == "table" then
			API.Resources:SetFlag("MenuOpen", true)
			optionsT = graphTB 
			startNode = {}
			menuGrph:AddVertex(startNode)
			self:setupOptions(optionsT,startNode)
			API.UIS.MouseBehavior = Enum.MouseBehavior.Default
			self:selectNodePC(startNode)
		end
	end
	function RadialMenu:openGraphMenu(graphTB,loadoutObj)
		if typeof(graphTB) == "table" then
			API.Resources:SetFlag("MenuOpen", true)
			optionsT = graphTB 
			startNode = {}
			menuGrph:AddVertex(startNode)
			self:setupOptions(optionsT,startNode)
			API.UIS.MouseBehavior = Enum.MouseBehavior.Default
			local r = RADIUS 
			if InputComponent.Platform == "Gamepad" then
				r *= 1.25
			end

			self:selectNode(startNode,loadoutObj,r)
		end
	end
	function InputComponent.SetDefaultMenu(graphTB)
		defaultT = graphTB
	end
	function InputComponent.OpenMenu(graphTB,loadoutObj)
		RadialMenu.openPCMenu(graphTB,loadoutObj)
	end
	function InputComponent.SetRadialUI(ui)
		RadialMenu.RadialUI = ui
	end
	InputComponent.InteractionSelected = RadialMenu.InteractionSelected;
	function InputComponent.PromptMenu(graphTB,loadoutObj)
		RadialMenu:openGraphMenu(graphTB,loadoutObj)
		local result = InputComponent.InteractionSelected:Wait()
		return result
	end
	function InputComponent.PromptPCMenu(graphTB)
		RadialMenu:openPCMenu(graphTB)
		local result = InputComponent.InteractionSelected:Wait()
		return result
	end
	local defToggle = false
	InputComponent.AddInputPlugin(API.Enumeration.InputPluginType.Ended, function(io,gp)
		if not gp then
			if io.KeyCode == Enum.KeyCode.LeftAlt then
				defToggle = not defToggle
				if defToggle then
					if RadialMenu.RadialUI then
						if #RadialMenu.RadialUI:GetChildren() > 0  then
							RadialMenu:deselectMenu(true)
							RadialMenu.InteractionSelected:Fire(nil)
						end	
						RadialMenu:openGraphMenu(defaultT)
						API.UIS.MouseBehavior = Enum.MouseBehavior.Default
					end
				else
					if RadialMenu.RadialUI then
						if #RadialMenu.RadialUI:GetChildren() > 0  then
							RadialMenu:deselectMenu(true)
							RadialMenu.InteractionSelected:Fire(nil)
							GuiService:RemoveSelectionGroup("RadialMenu")
						end	
					end
					API.UIS.MouseBehavior = Enum.MouseBehavior.LockCenter
				end
			elseif io.KeyCode == Enum.KeyCode.ButtonSelect then
				defToggle = not defToggle
				if defToggle then
					if #RadialMenu.RadialUI:GetChildren() <= 0 then
						if optionsT then
							RadialMenu:deselectMenu(true)
							RadialMenu.InteractionSelected:Fire(nil)
						end
						RadialMenu:openGraphMenu(defaultT)
					end
				else
					if #RadialMenu.RadialUI:GetChildren() > 0  then
						RadialMenu:deselectMenu(true)
						RadialMenu.InteractionSelected:Fire(nil)
						GuiService:RemoveSelectionGroup("RadialMenu")
					end
				end
			end
		end
	end)
	return {
		Name = "RadialMenu";
		SubComp = RadialMenu;
	}	
end