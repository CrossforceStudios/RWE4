local CollectionService = game:GetService("CollectionService")
return {
	{
		Name = "Crawling";
		Condition = function(CharState,CurrentItem,Humanoid,Velocity,InputComp)
			return (CharState.Stance == 2 and CharState.grounded) and Humanoid.WalkSpeed >= CharState:getProneSpeed(CurrentItem.Settings.baseWalkSpeed)  and (Humanoid.MoveDirection.magnitude > 0) and Humanoid:GetAttribute("Status") ~= "Swimming"
		end,
	};
	{
		Name = "Swimming";
		Condition = function(CharState,CurrentItem,Humanoid,Velocity,InputComp)
			return Humanoid:GetAttribute("Status") == "Swimming"
		end,
	};
	{
		Name = "ProneTransition";
		Condition = function(CharState,CurrentItem,Humanoid,Velocity,InputComp)
			return 	((not CharState.grounded) and true or (Velocity.magnitude == 0 or Humanoid.MoveDirection.magnitude == 0) )  and CharState.Stance == 2 and CharState.currentState == "Crawling"
		end,
	};
	{
		Name = "Diving";
		Condition = function(CharState,CurrentItem,Humanoid,Velocity,InputComp)
			return 	((CharState.Stance == 2) and (CollectionService:HasTag(Humanoid.Parent, "Skydive")) and (not Humanoid.Parent:FindFirstChild("Parachute")))
		end,
	};
	{
		Name = "Idling";
		Condition = function(CharState,CurrentItem,Humanoid,Velocity,InputComp)
			return (not _G.ClimbState) and	((not CharState.grounded) and (not CollectionService:HasTag(Humanoid.Parent, "Skydive")) or (Velocity.magnitude == 0 or Humanoid.MoveDirection.magnitude <= 0) )  and CharState.Stance ~= 2
		end,
	};
	{
		Name = "Walking";
		Condition = function(CharState,CurrentItem,Humanoid,Velocity,InputComp)
			--[[
				replace InputComp:IsInputDown("Core", "Sprint") with the following (if you made a keybind system):
				
				InputComp:IsBindDown("Core","Sprint")
			]]--
			return (not _G.ClimbState) and 	((CharState.Stance == 0) and (Velocity.magnitude > 0  and (not InputComp:IsInputDown(Enum.KeyCode.LeftShift))) and CharState.grounded)
		end,
	};
	{
		Name = "Climbing";
		Condition = function(CharState,CurrentItem,Humanoid,Velocity,InputComp)
			return _G.ClimbState ~= nil
		end,
	};
	{
		Name = "CWalking";
		Condition = function(CharState,CurrentItem,Humanoid,Velocity,InputComp)
			return (not _G.ClimbState) and ((CharState.Stance == 1) and (Velocity.magnitude > 0  and (not InputComp:IsBindDown("Core","Sprint"))) and CharState.grounded)
		end,
	};
	{
		Name = "Running";
		Condition = function(CharState,CurrentItem,Humanoid,Velocity,InputComp)
			--[[
				replace InputComp:IsInputDown("Core", "Sprint") with the following (if you made a keybind system):
				
				InputComp:IsBindDown("Core","Sprint")
			]]--
			return (not _G.ClimbState) and ((CharState.Stance == 0) and (Velocity.magnitude > 0 and (InputComp:IsInputDown(Enum.KeyCode.LeftShift))) and CharState.grounded and not CurrentItem.Aimed)
		end,
		PreProcess = function(CharState,CurrentItem,Humanoid,Velocity)
			if CharState.currentState == "Crawling" then
				CharState:changeStance("Stand")
			end			
		end,
	};
}