return {
    AnimIds = {
		idle = 	{	
			{ id = "rbxassetid://180435571", weight = 9, priority = Enum.AnimationPriority.Core; },
			{ id = "rbxassetid://180435792", weight = 1, priority = Enum.AnimationPriority.Core; }
		},
		walk = 	{ 	
			{ id = "rbxassetid://18862520248", weight = 10, priority = Enum.AnimationPriority.Core; } 

		}, 
		run = 	{ 
			{ id = "rbxassetid://18862738744", weight = 10, priority = Enum.AnimationPriority.Core; aipriority = Enum.AnimationPriority.Idle; } 
		},
		
		jump = 	{
			{ id = "rbxassetid://125750702", weight = 10, priority = Enum.AnimationPriority.Core; } 
		}, 
		fall = 	{
			{ id = "rbxassetid://180436148", weight = 10, priority = Enum.AnimationPriority.Core; } 
		}, 
		sit = 	{
			{ id = "rbxassetid://178130996", weight = 10, priority = Enum.AnimationPriority.Core; } 
		},	
		toolnone = {
			{ id = "rbxassetid://182393478", weight = 10, priority = Enum.AnimationPriority.Idle; } 
		},
	};
	Events = {
		"MapReady";
	};
}