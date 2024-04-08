local Plugin = plugin
local RWE4 = {};
local Libraries = {};
local EditorLibraries = {};
local function loadLibraryFrom(mode: string, name: string)
	local lib 
	if mode == "Editor" then
		if not EditorLibraries[name] then
			lib = require(script.Libraries:FindFirstChild(name))
		else
			lib = EditorLibraries[name]
		end
	end
	if not EditorLibraries[name] then
		EditorLibraries[name] = lib;
	end
	return lib
end
--- Libs
local SW = loadLibraryFrom("Editor","StudioWidgets")
local Maid = loadLibraryFrom("Editor","Maid")
local Signal = loadLibraryFrom("Editor","Signal")

--- end Libs
RWE4.Toolbar = Plugin:CreateToolbar("RW Engine 4")
RWE4.Buttons = {};
RWE4.Maid = Maid.new()
function RWE4:addButton(name, title, desc, icon)
	RWE4.Buttons[name] = RWE4.Toolbar:CreateButton(title, desc, icon)
end
function RWE4:addClickHandler(name, handler)
	local b = RWE4.Buttons[name] 
	if b then
		b.Click:Connect(handler)
	end
end

--- Themes
RWE4.ThemeChanged = Signal.new()
RWE4.Maid:AddTask(settings().Studio.ThemeChanged:Connect(function()
	 local theme = settings().Studio.Theme
	 RWE4.ThemeChanged:Fire(theme)
end))
do
	local titles = {};
	RWE4.ModulesWindowData = DockWidgetPluginGuiInfo.new(
		Enum.InitialDockState.Float,
		false,
		false,
		400,
		400,
		400,
		400
	)
	RWE4.ModuleWindow = Plugin:CreateDockWidgetPluginGui("RWE4_ModuleWindow", RWE4.ModulesWindowData)
	RWE4.ModuleWindow.Title = "RWE4 [Main Menu]";
	local function createModuleFrame(window)
		local ScrollWindow = SW.VerticalScrollingGridFrame.new("rwe4Modules_",Color3.fromRGB(25,25,25))
		ScrollWindow:GetSectionFrame().Parent  = window
		ScrollWindow:GetSectionFrame().BackgroundTransparency = 0
		RWE4.Maid:AddTask(RWE4.ThemeChanged:Connect(function(th)
			ScrollWindow:GetSectionFrame().BackgroundColor3 = th:GetColor(Enum.StudioStyleGuideColor.ViewPortBackground)
		end))
		ScrollWindow:GetSectionFrame().BackgroundColor3 = settings().Studio.Theme:GetColor(Enum.StudioStyleGuideColor.ViewPortBackground)

		return ScrollWindow:GetContentsFrame()
	end
	local grid = createModuleFrame(RWE4.ModuleWindow)
	RWE4:addButton("StartRWE4", "Start RWE4 (Editor)", "Sets up the editor (this plugin) for the first time, then opens the main menu.", "rbxassetid://2778270261")
	RWE4:addClickHandler("StartRWE4", function()
		print("[RWE4]: Starting RW Engine...")
		for i, model in ipairs(script.Modules:GetChildren()) do
			print(("[RWE4]: Initializing %s module..."):format(model.Name))
	
			local data = require(model)(RWE4,EditorLibraries,Libraries,loadLibraryFrom)
			if data then
				local button = SW.ImageButtonWithText.new(model.Name,
					i,
					data.Icon or "rbxassetid://2778270261",
					data.Title,
					UDim2.fromScale(0.2,0.2),
					UDim2.new(0.8,0,0.8,0),
					UDim2.fromScale(.1,.1),
					UDim2.fromScale(1,0.1),
					UDim2.fromScale(0,0.9)
				)
				button:GetButton().Parent = grid
				RWE4.Maid:AddTask(button:GetButton().Activated:Connect(function(i)
					if data.OnSelect then
						data.OnSelect(i)
					end
				end))
				if data.Unload then
					moduleUnloaders[#moduleUnloaders+1] = {
						Name = data.Title;
						Delegate = data.Unload;
					}
				end
				titles[model.Name] = data.Title;
				if data.UsesSettings then
					getComponent("SettingsUI"):AddModule(model.Name,data)
				end
				if model:FindFirstChild("HelpEntries")  and #model.HelpEntries:GetChildren() > 0 then
					print(("Help Documentation found for %s."):format(model.Name))
					print(("Loading help docs..."))
	
					for  _, helpMod in ipairs(model.HelpEntries:GetChildren()) do
						print(("Adding help entry %s..."):format(helpMod.Name))
						help:addHelpEntry(model.Name,helpMod)
					end	
				end
			end
		end
		print("[RWE4]: Modules and Engine Loaded...")
		RWE4.ModuleWindow.Enabled = true
	end)
end


