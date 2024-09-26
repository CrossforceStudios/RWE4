return function(RWE4,Plugin,EditorLibraries,Libraries,loader,RBLXGUI,EI)
	local installRWE4 = require(script.installHelper)
	local installerUI = RBLXGUI.PluginWidget.new({
		ID = "InstallerUI_RWE4";
		Enabled = false;
		Title = "RWE4 Installer";
		DockState = Enum.InitialDockState.Float;
	}, dwi)
	local pageInstall = RBLXGUI.Page.new({
		Name = "INSTALL";
		Open = true;
	}, installerUI)
	local pageUnInstall = RBLXGUI.Page.new({
		Name = "UNINSTALL";
		Open = false;
	}, installerUI)


	local window = RWE4:CloneAsset("InstallerWindow")
	window.Parent = pageInstall.Content
	RWE4.Maid:AddTask(window.InstallButton.Activated:Connect(function()
		installRWE4(EI)
	end))
    local function openInstaller()
		installerUI.Content.Enabled = true
    end
    return {
		Title = "Install RWE4";
		Icon = "rbxassetid://2778270261";
		OnSelect = function()
			openInstaller()
		end;
	}
end
