--- Globals
local Plugin = plugin
local ScriptEditorService = game:GetService("ScriptEditorService")
----
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
local RBLXGUI = require(script.Libraries.rblxgui.initialize)(plugin, "rblxgui")

--- end Libs
RWE4.Toolbar = Plugin:CreateToolbar("RW Engine 4")
RWE4.Buttons = {};
RWE4.Maid = Maid.new()
RWE4.CurrentModule = "None";
function RWE4:addButton(name, title, desc, icon)
	RWE4.Buttons[name] = RWE4.Toolbar:CreateButton(title, desc, icon)
end
function RWE4:addClickHandler(name, handler)
	local b = RWE4.Buttons[name] 
	if b then
		RWE4.Maid:AddTask(b.Click:Connect(handler))
	end
end
function RWE4:CloneAsset(name)
	local asset = script.CoreAssets:FindFirstChild(name)
	if asset then
		asset = asset:Clone()
		return asset
	end
end;
function RWE4:SetModuleSetting(Module,Key,Value)
	local tab = Plugin:GetSetting(("RWE4_%s"):format(Module))
	if not tab then
		tab = {};
	end
	tab[Key] = Value
	Plugin:SetSetting(("RWE4_%s"):format(Module), tab)
end

function RWE4:GetModuleSetting(Module,Key,Default)
	local tab = Plugin:GetSetting(("RWE4_%s"):format(Module))
	if tab then
		if (not tab[Key]) and Default then
			tab[Key] = Default;
			Plugin:SetSetting(("RWE4_%s"):format(Module), tab)
		end
	
		return tab[Key]
	else
		tab = {};
		tab[Key] = Default
		Plugin:SetSetting(("RWE4_%s"):format(Module), tab)

		return Default
	end
end
function RWE4:getTemplatedSource(templateName, params)
	local templateScript = script.Templates:FindFirstChild(templateName)
	if templateScript then
		if templateScript.Source ~= "" then
			templateScript = templateScript:Clone()
			templateScript.Source = require(templateScript):format(table.unpack(params))
			return templateScript
		end
	end
end;
function RWE4:OpenScript(script2: LuaSourceContainer)
	return ScriptEditorService:OpenScriptDocumentAsync(script2)
end
function RWE4:AddConnection(c)
	return self.Maid:AddTask(c)
end
--- Progress Bar
local PBar
local PROGRESS_OUT = UDim2.fromScale(.5,.9)
local PROGRESS_IN = UDim2.fromScale(.5,1.1)

function RWE4:ToggleProgress(on)
	PBar:TweenPosition(on and PROGRESS_OUT or PROGRESS_IN, Enum.EasingDirection.InOut, Enum.EasingStyle.Back, 1, false)
	wait(1)
end
function RWE4:SetStatus(status)
	if PBar then
		PBar.Status.Text = status:upper()
	end
end
function RWE4:SetPercent(percent)
	if PBar then
		local intPercent = math.floor(percent * 100)
		PBar.ProgressFrame.Fill.Size = UDim2.fromScale(percent,1)
		PBar.ProgressFrame.Progress.Text = ("%i%%"):format(intPercent)
	end
end
--- History 
local ChangeHistoryService = game:GetService("ChangeHistoryService")
function RWE4:RecordHistory(module,key)
	return ChangeHistoryService:TryBeginRecording("RWE4_Change_"..module.."_"..key)
end
function RWE4:CommitRecord(record)
	return ChangeHistoryService:FinishRecording(record, Enum.FinishRecordingOperation.Commit)
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
	RWE4.CoreWorkspace = Instance.new("ScreenGui")
	RWE4.CoreWorkspace.Name = "RWE4CoreWorkspace"
	RWE4.CoreWorkspace.Parent = game.CoreGui
	RWE4.CoreWorkspace.Enabled = true
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
	PBar = script.CoreAssets.ModuleProgress.Progress:Clone()
	PBar.Parent = RWE4.CoreWorkspace
	RWE4:addButton("StartRWE4", "Start RWE4 (Editor)", "Sets up the editor (this plugin) for the first time, then opens the main menu.", "rbxassetid://2778270261")
	RWE4:addClickHandler("StartRWE4", function()
		print("[RWE4]: Starting RW Engine...")
		for i, model in ipairs(script.Modules:GetChildren()) do
			print(("[RWE4]: Initializing %s module..."):format(model.Name))
			local data = require(model)(RWE4,Plugin,EditorLibraries,Libraries,loadLibraryFrom,RBLXGUI,script.EngineInstall)
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
					RWE4.CurrentModule = model.Name
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

	Plugin.Unloading:Connect(function()
		RWE4.CoreWorkspace:Destroy()
	end)
end


