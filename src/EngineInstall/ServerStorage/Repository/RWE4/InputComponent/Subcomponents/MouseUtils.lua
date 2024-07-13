return function(API, InputComponent)

	local MouseControl = {};

	InputComponent.ToggleMouseControl = function(enabled, lock)
		API.UIS.MouseIconEnabled = enabled
		API.UIS.MouseBehavior = if lock == false or lock == nil then Enum.MouseBehavior.Default else Enum.MouseBehavior.LockCenter 
	end

	return {
		Name = "MouseControl";
		SubComp = MouseControl
	}	
end
