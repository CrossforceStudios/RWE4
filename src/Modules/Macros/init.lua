return function(RWE4,Plugin,EditorLibraries,Libraries,loader,RBLXGUI,EI)

    local control = {};
    control.UI = nil;
    control.
    function control:CreateWidget()
        local ui = RBLXGUI.PluginWidget.new({
            ID = "RWE4_Macros";
            Enabled = false;
            Title = "RWE4: Macros";
            DockState = Enum.InitialDockState.Left;
        }, dwi)
        ui.WidgetObject:BindToClose(function()
            self:deactivate()
        end)
        self.UI = ui

    end

    function control:Init()

    end

    function control:deactivate()
        if not self.Initiated then
            return
        end
        
        if not self.Active then
            return
        end
        
        self.Active = false
        self.Widget.Enabled = false
        self.RefreshButton.Enabled = false
        self.WidgetButton:SetActive(false)
    end

    return {
		Title = "Macros";
		Icon = "rbxassetid://17210895174";
		OnSelect = function()
            if RWE4.CurrentModule == script.Name then
                return	
            end
		    control:Init()	
		end;
	}

end