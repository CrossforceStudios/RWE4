return function(RWE4,Plugin,EditorLibraries,Libraries,loader,RBLXGUI,EI)
	local imUI = RBLXGUI.PluginWidget.new({
		ID = "InteractionManager_RWE4";
		Enabled = false;
		Title = "RWE4 Interaction Manager";
		DockState = Enum.InitialDockState.Float;
	}, dwi)
	local pageCreate = RBLXGUI.Page.new({
		Name = "CREATE/EDIT";
		Open = true;
	}, imUI)
	local pageManager = RBLXGUI.Page.new({
		Name = "MANAGE";
		Open = false;
	}, imUI)

    local function openIntManager(selection)
		imUI.Content.Enabled = true
    end

    return {
		Title = "Interaction Manager";
		Icon = "rbxassetid://5568203747";
		OnSelect = function()
			openIntManager(game.Selection:Get()[1])
		end;
	}
end
