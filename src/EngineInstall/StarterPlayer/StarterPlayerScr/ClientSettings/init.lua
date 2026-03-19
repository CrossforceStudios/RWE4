local CF = {
	RAW = CFrame.new;
	ANG = CFrame.Angles;
};
local RAD = math.rad
local ClientSettings = {
	-- Replace the run and walk anims with your own.
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
	Loadout = {
		Slots = {"Primary";"Secondary";"Grenade";"Launcher";"Melee";};
		Keys = {
			[Enum.KeyCode.One] = 1;
			[Enum.KeyCode.Two] = 2;
			[Enum.KeyCode.Three] = 3;
			[Enum.KeyCode.Four] = 4;
			[Enum.KeyCode.Five] = 5;
		};
		OnChange = function(UIS, x, Character)
			
		end,
	};
	Weapon = {
		ContinuousActions =  {
			"Gas";
			"SemiAuto";
			"Double";
		};
	};
	-- Replace the run, climb, idle and walk anims with your own.
	HumanoidAnimIds = {
		Zombie = {
			idle = 	{	
				{ id = "rbxassetid://104211669242100", weight = 10, priority = Enum.AnimationPriority.Core; },
			},
			walk = 	{ 	
				{ id = "rbxassetid://73132666350881", weight = 10, priority = Enum.AnimationPriority.Core; } 

			}, 
			run = 	{ 
				{ id = "rbxassetid://18862738744", weight = 10, priority = Enum.AnimationPriority.Core; } 
			},

			jump = 	{
				{ id = "rbxassetid://94392460546583", weight = 10, priority = Enum.AnimationPriority.Core; } 
			}, 
			fall = 	{
				{ id = "rbxassetid://94718030947140", weight = 10, priority = Enum.AnimationPriority.Core; } 
			}, 
			sit = 	{
				{ id = "rbxassetid://178130996", weight = 10, priority = Enum.AnimationPriority.Core; } 
			},	
			toolnone = {
				{ id = "rbxassetid://182393478", weight = 10, priority = Enum.AnimationPriority.Idle; } 
			},
			climb = {
				{ id = "rbxassetid://101128262619969", weight = 10, priority = Enum.AnimationPriority.Core; }
			}
		}
		
	};
	-- default cframe animation used when weapons aren't equipped.
	defaultAnimCF = function(animTab,dt)
		local aC0, aC1 = animTab.CF.RAW() * animTab.CF.ANG(animTab.AnimRot.X * animTab.stanceSway,animTab.AnimRot.Y * animTab.stanceSway,animTab.AnimRot.Z * animTab.stanceSway) * animTab.CF.RAW(animTab.AnimPos.X * animTab.stanceSway,animTab.COS(animTab.CameraAng.Y) * animTab.AnimPos.Y * animTab.stanceSway,animTab.SIN(animTab.CameraAng.Y) * animTab.AnimPos.Z * animTab.stanceSway), animTab.CF.ANG(-animTab.CameraAng.Y * animTab.crawlAlpha / 90, 0, 0) * animTab.CF.RAW(0,-1,0);
		if (animTab.currentState == "Running" or animTab.currentState == "Walking") and not animTab.Aimed then
			local wsp = animTab.walkSpeedSpring.p
			aC0 = aC0 * animTab.gunbob(animTab.walkAnimName ,.25 *  wsp/animTab.bWS,.5 * wsp/animTab.bWS,dt)
		elseif not animTab.Aimed and (not animTab.isPlayingAnim()) then
			local idleAng2 = animTab.idleAng + animTab.RAD(105 * dt) * animTab.stanceSway							
			aC0 = aC0 * animTab.Lerps.CFrame(animTab.CF.RAW(),animTab.gunbobIdle(idleAng2,dt),0.15)

			animTab.setIdleAng(idleAng2)	
		end
		return aC0, aC1
	end;
	-- this animation plays when nothing is happening.
	IdleAnimation = function(a, dt)
		return CFrame.new(
			math.sin(a / 2) / 35,
			math.sin(a * 5 / 4) / 35,
			math.sin(a * 3 / 4) / 35
		)
	end;
	DefaultKeys = {
		Sprint = Enum.KeyCode.LeftShift;
	};
	Anims = {
		CancelCache = {
			["Reload"] = false;
			["Inspecting"] = false;
			["Cocking"] = false;
			["Parkour"] = false;
			["Spot"] = false;
			["Nading"] = false;
			["Throwing"] = false;
			["DropAmmo"] = false;
			["Equip"] = false;
			["AttachmentEquip"] = false;
			["Surrender"] = false;
			["SelectFire"] = false;

		};
		NonCancellable = {
			"Cocking";
		}
	};
	WalkAnimTypes = {
		["Assault"] = "WalkRifle2";

	};
	RunAnimTypes = {
		["Assault"] = "WalkRifle";
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
	HitMaterials = {
		Enum.Material.Plastic;
		Enum.Material.Slate;
		Enum.Material.Concrete;
		Enum.Material.CorrodedMetal;
		Enum.Material.DiamondPlate;
		Enum.Material.Foil;
		Enum.Material.Marble;
		Enum.Material.Granite;
		Enum.Material.Brick;
		Enum.Material.Grass;
		Enum.Material.Pebble;
		Enum.Material.SmoothPlastic;
		Enum.Material.Metal;
		Enum.Material.Cobblestone;
		Enum.Material.Asphalt;
		Enum.Material.Fabric;
		Enum.Material.CrackedLava;
		Enum.Material.Glacier;
		Enum.Material.Glass;
		Enum.Material.Ground;
		Enum.Material.Ice;
		Enum.Material.LeafyGrass;
		Enum.Material.Mud;
		Enum.Material.Rock;
		Enum.Material.Pavement;
		Enum.Material.Sand;
		Enum.Material.Sandstone;
		Enum.Material.Snow;
		Enum.Material.Water;
		Enum.Material.Wood;
		Enum.Material.WoodPlanks;

	};
	MaterialGroups = {
		["Rock"] = {"Concrete";"Rock";"Slate";"Brick";"Marble";"Granite";"Cobblestone";"Asphalt";"CrackedLava";"Pavement";};
		["Dirt"] = {"Grass";"Sand";"Mud";"LeafyGrass";"Limestone";"Sandstone";"Salt";"Pebble";"Snow";"Ground";};
		["Metal"] = {"CorrodedMetal";"DiamondPlate";"Metal";"Foil";};
		["Wood"] = {"Wood";"WoodPlanks";};
		["Plastic"] = {"Plastic";"SmoothPlastic";};
		["Ice"] = {"Ice";"Glacier";"Neon";};
		["Water"] = {"Water";};
	};
	HoleTypes = {
		[Enum.Material.Asphalt] = {4117566130;4117568052;4117568791;4117571119;4117572104;};
		[Enum.Material.Basalt] = {4123587259;4123587587;4123589997;};
		[Enum.Material.Brick] = {4123587259;4123587587;4123589997;};
		[Enum.Material.Cobblestone] = {4123587259;4123587587;4123589997;};
		[Enum.Material.Concrete] = {4123587259;4123587587;4123589997;};
		[Enum.Material.CorrodedMetal] = {4117518488;4117519514;4117520130;};
		[Enum.Material.CrackedLava] = {64291977;64291961;};
		[Enum.Material.DiamondPlate] = {4123588366;4123588772;4123589209;4123587935;4123589649;};
		[Enum.Material.Fabric] = {64291977;64291961};
		[Enum.Material.Foil] = {64291977;64291961};
		[Enum.Material.Glacier] = {64291977;64291961};
		[Enum.Material.Glass] = {4117258050;4117259227;4117269028;4117270097;4117272383;4117274048;4117276630;4117278966;};
		[Enum.Material.Granite] = {64291977;64291961};
		[Enum.Material.Grass] = {64291977;64291961};
		[Enum.Material.Ground] = {64291977;64291961;};
		[Enum.Material.Ice] = {4117258050;4117259227;4117269028;4117270097;4117272383;4117274048;4117276630;4117278966;};
		[Enum.Material.LeafyGrass] = {64291977;64291961};
		[Enum.Material.Marble] = {64291977;64291961};
		[Enum.Material.Metal] = {4117520130;4117520130;4117518488;};
		[Enum.Material.Mud] = {64291977;64291961};
		[Enum.Material.Pavement] = {4123587259;4123587587;4123589997;};
		[Enum.Material.Pebble] = {64291977;64291961};
		[Enum.Material.Plastic] = {64291977;64291961};
		[Enum.Material.Rock] = {4123587259;4123587587;4123589997;};
		[Enum.Material.Sand] = {64291977;64291961};
		[Enum.Material.Sandstone] = {64291977;64291961};
		[Enum.Material.Slate] = {4123587259;4123587587;4123589997;};
		[Enum.Material.SmoothPlastic] = {64291977;64291961};
		[Enum.Material.Snow] = {64291977;64291961};
		[Enum.Material.Wood] = {4117162425;4117163329;4117162967;4117163813;4117164277;};
		[Enum.Material.WoodPlanks] = {4117162425;4117163329;4117162967;4117163813;4117164277;};
		[Enum.Material.Water] = {4671887658;4671888012;4671888241;4671888474;4671888745;};

	};
	LeanAngle = math.rad(15);
	MovementMap = {
		[Enum.PlayerActions.CharacterForward] = Enum.KeyCode.W;
		[Enum.PlayerActions.CharacterBackward] = Enum.KeyCode.S;
		[Enum.PlayerActions.CharacterLeft] = Enum.KeyCode.A;
		[Enum.PlayerActions.CharacterRight] = Enum.KeyCode.D;
		[Enum.PlayerActions.CharacterJump] = {Enum.KeyCode.Space;Enum.KeyCode.ButtonA};
	};	
	CamOffsets ={
		["Gun"] = "gun";
		["Launcher"] = "gun";
	};	
}

ClientSettings.AnimAPI = require(script.AnimAPI)
ClientSettings.getTotalCamOffset = function(props)
	local CameraStateObj, CharStateObj, CurrentItemObj = props.CameraState, props.CharState, props.CurrentItem
	local Lerps = props.Lerps
	local getTotalCamOffset = {
		grenade = function(dt)
			return Vector3.new(), Vector3.new()
		end;
		gun = function(dt)
			local CameraState = CameraStateObj()
			local CharState = CharStateObj()
			local pc = workspace.CurrentCamera.CFrame
			local dir = Lerps.number(CharState.BaseAnim.Rot.p.Z, 0, 0.25)
			return CameraState.camOffsets.guiScope.Rot +  CameraState.camOffsets.Reload.Rot + CameraState.camRecoilSpring.p + Vector3.new(0, 0, (7.5*dt) * dir), Vector3.new()
		end;
		ammoBox = function(dt)
			return Vector3.new(), Vector3.new()
		end;
		binoculars = function(dt)
			local CurrentItem = CurrentItemObj()
			local FOVAmount = workspace.CurrentCamera.FieldOfView
			return Vector3.new(0,0,0), CurrentItem.Aimed and  Vector3.new(0,0,-(80 - FOVAmount) * 15) or Vector3.new()
		end;
		medicine = function(dt)
			return Vector3.new(), Vector3.new()
		end;
		lampetmine = function(dt)
			return Vector3.new(), Vector3.new()
		end;
		melee = function(dt)
			local CameraState = CameraStateObj()
			return CameraState.camOffsets.guiScope.Rot +  CameraState.camOffsets.Reload.Rot + CameraState.camRecoilSpring.p, Vector3.new()
		end;
		crate = function(dt)
			return Vector3.new(), Vector3.new()
		end;

	}
	return getTotalCamOffset
end
return ClientSettings