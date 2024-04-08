return function(RWE4,Plugin,EditorLibraries,Libraries,loader)

	local dwi = DockWidgetPluginGuiInfo.new(
		Enum.InitialDockState.Float, -- Widget will be initialized in floating panel
		false, -- Widget will be initially enabled
		true, -- Don't override the previous enabled state
		350, -- Default width of the floating window
		250, -- Default height of the floating window
		350, -- Minimum width of the floating window (optional)
		250 -- Minimum height of the floating window (optional)
	)
	local installerUI = Plugin:CreateDockWidgetPluginGui("InstallerUI_RWE4", dwi)
	installerUI.Title = "RWE4 Installer"
    local function openInstaller()
		installerUI.Enabled = true
    end
    return {
		Title = "Install RWE4";
		Icon = "rbxassetid://2778270261";
		OnSelect = function()
			openInstaller()
		end;
	}
end
