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
loadLibraryFrom("Editor","StudioWidgets")
--- end Libs
RWE4.Toolbar = Plugin:CreateToolbar("RW Engine 4")
RWE4.Buttons = {};
function RWE4:addButton(name, title, desc, icon)
	RWE4.Buttons[name] = RWE4.Toolbar:CreateButton(title, desc, icon)
end
function RWE4:addClickHandler(name, handler)
	local b = RWE4.Buttons[name] 
	if b then
		b.Click:Connect(handler)
	end
end

do
	RWE4.ModulesWindowData = DockWidgetPluginGuiInfo.new(
		Enum.InitialDockState.Float,
		false,
		true,
		350,
		350,
		300,
		300
	)
	RWE4.ModuleWindow = Plugin:CreateDockWidgetPluginGui("RWE4_ModuleWindow", RWE4.ModulesWindowData)
	RWE4.ModuleWindow.Title = "RWE4 [Main Menu]";
	RWE4:addButton("StartRWE4", "Start RWE4 (Editor)", "Sets up the editor (this plugin) for the first time, then opens the main menu.", "rbxassetid://2778270261")
	RWE4:addClickHandler("StartRWE4", function()
		print("[RWE4]: Starting RW Engine...")
		RWE4.ModuleWindow.Enabled = true
	end)
end


