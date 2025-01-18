return {
	OnCharacterRemoving = function(Props,Components)	
		Props.RS:UnbindFromRenderStep("UpdateSound");
		task.delay(8, function()
			Components.Sound:UnmuffleSounds("Game_FX", "Standard", 0.5)
		end)
	end,
}