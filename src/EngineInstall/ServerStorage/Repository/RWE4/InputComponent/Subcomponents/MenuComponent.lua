return function(API, InputComponent)
	
	local MenuComponent = {};
	
	MenuComponent.Opened = {};
	MenuComponent.Closed = {};
	
	function InputComponent.AddMenuOpenedCallback(cb)
		if typeof(cb) == "function" then
			table.insert(MenuComponent.Opened, cb)
		end
	end
	
	function InputComponent.AddMenuClosedCallback(cb)
		if typeof(cb) == "function" then
			table.insert(MenuComponent.Closed, cb)
		end
	end
	
	InputComponent.AddInputPlugin(API.Enumeration.InputPluginType.Menu, function(opened)
		for _, func in (if opened then MenuComponent.Opened else MenuComponent.Closed) do
			func()
		end
		return true
	end)
	
	return {
		Name = "MenuComponent";
		SubComp = MenuComponent;
	}	
end