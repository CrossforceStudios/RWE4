local CF = {
	RAW = CFrame.new;
	ANG = CFrame.Angles;
};
local RAD = math.rad
return {
    AnimIds = {
		idle = 	{	
			{ id = "rbxassetid://180435571", weight = 9, priority = Enum.AnimationPriority.Core; },
			{ id = "rbxassetid://180435792", weight = 1, priority = Enum.AnimationPriority.Core; }
		},
		walk = 	{ 	
			{ id = "rbxassetid://180426354", weight = 10, priority = Enum.AnimationPriority.Core; } 

		}, 
		run = 	{ 
			{ id = "rbxassetid://180426354", weight = 10, priority = Enum.AnimationPriority.Core; aipriority = Enum.AnimationPriority.Idle; } 
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
	MobileJoystickAxes = {
		{
			Type = "AxisAction";
			Title = "Stances";
			Actions = {
				LeanLeft = {
					Name = "LeanLeft";
					Range = NumberRange.new(0.1, 1);
					Axis = "X";
					OppositeAxis = "Y";
				};
				LeanRight = {
					Name = "LeanRight";
					Range = NumberRange.new(-1, -0.1);
					Axis = "X";
					OppositeAxis = "Y";

				};
				Prone = {
					Name = "Prone";
					Range = NumberRange.new(-1, -0.5);
					Axis = "Y";
					OppositeAxis = "X";

				};
				Crouch = {
					Name = "Crouch";
					Range = NumberRange.new(-0.5, -0.1);
					Axis = "Y";
					OppositeAxis = "X";

				};
				Stand = {
					Name = "Stand";
					Range = NumberRange.new(0, 1);
					Axis = "Y";
					OppositeAxis = "X";

				};

			}
		}	
	};
	VolumeLighting = {
		Depth = 50;
		LightEmission = 1;
		RenderMethod = "Beams";
		LayerSpacing = 1;
		Transparency = 0.996;
	};
	StanceCF = {
		arm = {
			Stand =  CF.RAW();
			Crouch = CF.RAW(0, 0, -0.05);
			Prone = CF.RAW(0, 0, -0.1);
			ProneBack = CF.RAW(0, -1.025, -0.1);
		};
		head  = {
			Stand = CF.RAW(0, 1.5, 0);
			Crouch = CF.RAW(0, 1.5, 0);
			Prone = CF.RAW(0, 1, 1) * CF.ANG(RAD(90), 0, 0);
			ProneBack = CF.RAW(0, 1, -1) * CF.ANG(RAD(-90), 0, 0);
		};
		HRP = {
			Stand = CF.ANG(RAD(-90), 0, RAD(180));
			Crouch = CF.RAW(0, -1, 0) * CF.ANG(RAD(-90), 0, RAD(180));
			Prone = CF.RAW(0, -2.5, 1) * CF.ANG(RAD(180), 0, RAD(180));
			ProneBack = CF.RAW(0, -2.5, 1) * CF.ANG(RAD(180), 0, RAD(0)) * CF.ANG( 0, RAD(180), RAD(0));

		};
		leg = {
			C0 = {
				Stand = {
					CF.RAW(-1, -1, 0) * CF.ANG(0, RAD(-90), 0);
					CF.RAW(1, -1, 0) * CF.ANG(0, RAD(90), 0);
				};
				Crouch = {
					CF.RAW(-1, -1, 0) * CF.ANG(0, RAD(-90), 0);
					CF.RAW(1, -1, 0) * CF.ANG(RAD(-0), RAD(90), 0);
				};
				Prone = {
					CF.RAW(-1, -1, 0) * CF.ANG(0, RAD(-90), 0);
					CF.RAW(1, -1, 0) * CF.ANG(RAD(0), RAD(90), 0);
				};	
				ProneBack = {
					CF.RAW(-1, -1, 0) * CF.ANG(0, RAD(-90), 0);
					CF.RAW(1, -1, 0) * CF.ANG(RAD(-0), RAD(90), 0);
				};	
			};
			C1 = {
				Stand = {
					CF.RAW(-0.5, 1, 0) * CF.ANG(0, RAD(-90), 0);
					CF.RAW(0.5, 1, 0) * CF.ANG(RAD(0), RAD(90), 0);
				};
				Crouch = {
					CF.RAW(-0.5,0.85,1) * CF.ANG(RAD(15),RAD(-90),RAD(0)) * CF.RAW(-0,-.5,0);
					CF.RAW(0.5, 0.75,0.9) * CF.ANG(RAD(75),RAD(90),0) * CF.RAW(-0,-.5,0);
				};
				Prone = {
					CF.RAW(-0.5, 1, 0) * CF.ANG(0, RAD(-90), 0);
					CF.RAW(0.5, 1, 0) * CF.ANG(RAD(0), RAD(90), RAD(0));
				};
				ProneBack = {
					CF.RAW(-0.5, 1, 0) * CF.ANG(0, RAD(-90), 0);
					CF.RAW(0.5, -1, 0) * CF.ANG(RAD(-0), RAD(90), 0);
				};
			}
		};
	};
	SpecialActions = {
		
	};
	Stances = {
		Stand = {
			Value = 0;
			Enabled = true;
			HasAction = true;
			Input = Enum.UserInputType.Touch;
			OnActivate = function(i, gp, Props)
				if Props.CharState.currentState == "Running" then return end	
				if  Props.Humanoid.Sit then return end
				if _G.HM.Context == "Build" then return end					
				Props.CharState:changeStance("Stand")
				Props.setStanceDir("Down")
				local basePos = Props.WeaponUtils:GetBasePose(Props.CurrentItem.Value)
				if Props.CurrentItem.Value then
					Props.CurrentItem:tweenToBasePose(0.3)
				end
				_G.CharacterStance[Props.Humanoid] = Props.CharState.Stance
			end;
		};
		Crouch = {
			Value = 1;	
			Enabled = true;
			HasAction = true;
			Input = Enum.KeyCode.C;
			OnActivate = function(i, gp, Props)
				if Props.InputComp.CurrentIScheme == "Toolbox" then return end						
				--if not Props.CurrentItem:IsPlayingAnim() then
					if not Props.Humanoid.Sit then
						if Props.CharState.currentState ~= "Running" then 															
							if Props.CharState.Stance ~= 1 then
								if  (not table.find(Props.CharState.StanceBlacklist,"Crouch"))  then
									Props.CharState:changeStance("Crouch")
								end
							else
								Props.CharState:changeStance("Stand")
							end
						end
					end
				--end
				_G.CharacterStance[Props.Humanoid] = Props.CharState.Stance
			end;
		};
		Prone = {
			Value = 2;	
			Enabled = true;
			HasAction = true;
			Input = Enum.KeyCode.X;
			OnActivate = function(i, gp, Props)
				if Props.CharState.currentState == "Running" then return end	
				if  Props.Humanoid.Sit then return end
				--if _G.HM.Context == "Build" then return end					
				if Props.CharState.Stance < 2 then
					if  (not table.find(Props.CharState.StanceBlacklist,"Prone"))  then
						Props.CharState:changeStance("Prone")
						Props.setStanceDir("Up")
					end		
				else
					Props.CharState:changeStance("Stand")
					Props.setStanceDir("Down")
					--[[if Props.CurrentItem.Value then
						Props.CurrentItem:tweenToBasePose(0.3)
					end]]--
				end
				_G.CharacterStance[Props.Humanoid] = Props.CharState.Stance
			end,
		};
	};
	LeanAngle = math.rad(15);
	MovementMap = {
		[Enum.PlayerActions.CharacterForward] = Enum.KeyCode.W;
		[Enum.PlayerActions.CharacterBackward] = Enum.KeyCode.S;
		[Enum.PlayerActions.CharacterLeft] = Enum.KeyCode.A;
		[Enum.PlayerActions.CharacterRight] = Enum.KeyCode.D;
		[Enum.PlayerActions.CharacterJump] = {Enum.KeyCode.Space;Enum.KeyCode.ButtonA};
	};	
}