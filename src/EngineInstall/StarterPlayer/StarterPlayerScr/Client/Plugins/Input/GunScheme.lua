return {
	SchemeName = "Gun";
	GetInitialSchemeData = function(Props, Components)
		return {
			{
				{
					"Basic";
					{
						"selectFire";
						"Reload";
					};
				};
				{
					"Tactical";
					{
						"Cycle";
						"cycleSights";
						"ToggleBipod";
						"In";
						"Out";
						"Zoom";
						"MenuG";
						"ToggleAttachment";
					};	
				};
				{
					"Cosmetic";
					{
						"Inspect";
						"AdjustSights";	
						"AdjustStock";	
						"ElevationUp";
						"ElevationDown";

					};
				};
			};
			{Enum.UserInputType.MouseButton1,Enum.UserInputType.MouseButton3,Enum.KeyCode.ButtonR2};
			function(i,g)
				Props.WeaponUtils:PerformActivation(Props.Player, Props.CurrentItem.Value, {
					CurrentItem = Props.CurrentItem;
					InputComp = Components.Input;
					tween  = Props.TweenSystem;
					Humanoid = Props.Humanoid();
					Character = Props.Character();
					CharState = Props.CharState;
					FastWait = task.wait;
					CF = Props.CF;
					getAlpha = Props.getAlpha;
					RAD = Props.RAD;
					input = i;
				})
			end;
			false;
		};

	end,
	OnSetupScheme = function(Props, Components)
		local InputComp = Components.Input
		local WeaponUtils = Props.WeaponUtils;
		local CurrentItem = Props.CurrentItem;
		local player = Props.Player;
		local CharState = Props.CharState;
		local function openGunMenu()
			local menu2 = {
				["Adjust Sight"] = function()
					CurrentItem:AdjustSight(false);
				end;
				["Adjust Stock"] = function()
					if  CurrentItem.StockType == "Hybrid" then
						InputComp.PromptMenu({
							["Fold"] = function()
								CurrentItem:PlayAnimation("AdjustStockFold",false)
								CurrentItem:ChangeStockRecoil("Folding")

							end;
							["Collapse"] = function()
								CurrentItem:PlayAnimation("AdjustStock",false)
								CurrentItem:ChangeStockRecoil("Telescopic")

							end;
						})
					else
						CurrentItem:PlayAnimation("AdjustStock",false)	
						CurrentItem:ChangeStockRecoil(CurrentItem.Settings.stockType)
					end 
				end,
				["Decock Pistol"] = function()
					CurrentItem:PlayAnimation("Decock",true)
				end,
				["Change Barrel"] = function()
					if CurrentItem:HasAnim("BarrelChange") then
						CurrentItem:PlayAnimation("BarrelChange",true)
					end
				end;

			};
			for _, Plugin in Props.ClientPlugins do
				if Plugin.OnGunMenuOpened then
					menu2 = Plugin.OnGunMenuOpened({
						Menu = menu2;
						Character = Props.Character();
						Humanoid = Props.Humanoid();
						Vehicle = nil;
					}, Components)
				end
			end


			InputComp.PromptPCMenu(menu2)
		end
		InputComp.RegisterSJSchemeModes("Gun", {
			{
				Type = "AxisAction";
				Title = "Sights";
				Actions = {
					Up = {
						Name = "NextSight";
						Range = NumberRange.new(.5, 1);
						Axis = "Y";
						OppositeAxis = "X";
					};
					Down = {
						Name = "PrevSight";
						Range = NumberRange.new(-1, -.5);
						Axis = "Y";
						OppositeAxis = "X";
					};
				};
			}
		})
		InputComp.RegisterSchemeAction("Gun","ToggleAttachment",{InputComp:GetBindCode("Gun","ToggleAttachment")},false,function(input,gp)
			if not (CharState.MoveEnabled) then return end
			local AD = CurrentItem:GetAdapters("KeyDown")
			WeaponUtils:PerformInputAction(player, CurrentItem.Value, "ToggleAttachment", {
				CurrentItem = CurrentItem;
				Adapter = AD;

			})
		end,true,2)
		InputComp.RegisterSchemeAction("Gun","ToggleBipod",{InputComp:GetBindCode("Gun","ToggleBipod")},false,function(input,gp)
			if not (CharState.MoveEnabled) then return end	
			WeaponUtils:PerformInputAction(player, CurrentItem.Value, "ToggleBipod", {
				CurrentItem = CurrentItem;

			})
		end,true,2)
		InputComp.RegisterSchemeAction("Gun","selectFire",{InputComp:GetBindCode("Gun","selectFire")},false,function(input,gp)
			WeaponUtils:PerformInputAction(player, CurrentItem.Value, "selectFire", {
				CurrentItem = CurrentItem;
				ZoomModeEnabled = Props.ZoomModeEnabled or false;
				RemoteService = Props.RemoteService;
				Character = Props.Character();
				tween = Props.TweenSystem;
				CharState = CharState;
				ViewModel = Props.ViewModel;
				CF = Props.CF;
				getAlpha = Props.getAlpha;
				armC0 = Props.armC0;
				RAD = Props.RAD;
				runAsync = task.spawn;
				FastWait = task.wait;
			})
		end,true,1)
		InputComp.RegisterSchemeAction("Gun","In",{InputComp:GetBindCode("Gun","In")},false,function(input,gp)
			if not (CharState.MoveEnabled) then return end	
			WeaponUtils:PerformInputAction(player, CurrentItem.Value, "ZoomIn", {
				CurrentItem = CurrentItem;
				InputComp = InputComp;
			}, input)
		end,true,2)	
		InputComp.RegisterSchemeAction("Gun","Zoom",{InputComp:GetBindCode("Gun","Zoom")},false,function(input,gp)
			if not (CharState.MoveEnabled) then return end	
			WeaponUtils:PerformInputAction(player, CurrentItem.Value, "ZoomUniversal", {
				CurrentItem = CurrentItem;
				InputComp = InputComp;
				ZoomModeEnabled = Props.ZoomModeEnabled or false;
			}, input)
		end,true,2)	
		InputComp.RegisterSchemeAction("Gun","ElevationUp", {InputComp:GetBindCode("Gun","ElevationUp");},false,function(input, gp)
			if not (CharState.MoveEnabled) then return end		
			WeaponUtils:PerformInputAction(player, CurrentItem.Value, "ElevationUp", {
				CurrentItem = CurrentItem;
				InputComp = InputComp;
				ZoomModeEnabled = Props.ZoomModeEnabled or false;
			}, input)
		end,true,3)	
		InputComp.RegisterSchemeAction("Gun","ElevationDown", {InputComp:GetBindCode("Gun","ElevationDown");},false,function(input, gp)
			if not (CharState.MoveEnabled) then return end	
			WeaponUtils:PerformInputAction(player, CurrentItem.Value, "ElevationDown", {
				CurrentItem = CurrentItem;
				InputComp = InputComp;
				ZoomModeEnabled = Props.ZoomModeEnabled or false;
			}, input)
		end,true,3)	
		InputComp.RegisterSchemeAction("Gun","Out",{InputComp:GetBindCode("Gun","Out")},false,function(input,gp)
			if not (CharState.MoveEnabled) then return end	
			WeaponUtils:PerformInputAction(player, CurrentItem.Value, "ZoomOut", {
				CurrentItem = CurrentItem;
				InputComp = InputComp;
			}, input)

		end,true,2)	
		InputComp.RegisterSchemeAction("Gun","AdjustSights",{InputComp:GetBindCode("Gun","AdjustSights");},false,function(input,gp)
			if not (CharState.MoveEnabled) then return end			
			WeaponUtils:PerformInputAction(player, CurrentItem.Value, "AdjustSights", {
				CurrentItem = CurrentItem;
				InputComp = InputComp;
			}, input)
		end,true,3)
		InputComp.RegisterSchemeAction("Gun","AdjustStock",{Enum.KeyCode.PageDown;},false,function(input,gp)
			if not (CharState.MoveEnabled) then return end
			WeaponUtils:PerformInputAction(player, CurrentItem.Value, "AdjustStock", {
				CurrentItem = CurrentItem;
				InputComp = InputComp;
			}, input)

		end,true,3)
		InputComp.RegisterSchemeAction("Gun","MenuG",{Enum.KeyCode.ButtonSelect;},false,function(input,gp)
			if not (CharState.MoveEnabled) then return end			
			if CurrentItem.Equipped then
				openGunMenu()
			end
		end,true,2)
		InputComp.RegisterSchemeAction("Gun","Reload",{InputComp:GetBindCode("Gun","Reload")},false,function(input,gp)
			if not (CharState.MoveEnabled) then return end		
			WeaponUtils:PerformInputAction(player, CurrentItem.Value, "Reload", {
				CurrentItem = CurrentItem;
				InputComp = InputComp;
				CharState = CharState;
			}, input)

		end,true,1)
		InputComp.RegisterSchemeAction("Gun","Inspect",{InputComp:GetBindCode("Gun","Inspect")},false,function(input,gp)
			WeaponUtils:PerformInputAction(player, CurrentItem.Value, "Inspect", {
				CurrentItem = CurrentItem;
				InputComp = InputComp;
				CharState = CharState;
			}, input)

		end,true,3)


		InputComp.RegisterSchemeAction("Gun","cycleSights",{InputComp:GetBindCode("Gun","cycleSights")},false,function(input,gp)
			if not (CharState.MoveEnabled) then return end			
			WeaponUtils:PerformInputAction(player, CurrentItem.Value, "cycleSights", {
				CurrentItem = CurrentItem;
				InputComp = InputComp;
				CharState = CharState;
				FastWait = task.wait;
			}, input)
		end,true,2)	
		do
			InputComp.RegisterSchemeContext("Gun", "Reload")
			InputComp.RegisterSchemeContextMode("Gun","Reload", 1,  "Ammo", {})
			InputComp.RegisterSchemeContextMode("Gun","Reload", 2,  "Bolt", {})
			InputComp.RegisterSchemeContextAction("Gun","Reload","GhostLoad", InputComp:GetBindCode("Animated", "GhostLoad"), 1)
			InputComp.RegisterSchemeContextAction("Gun","Reload","ForwardAssist", InputComp:GetBindCode("Animated", "ForwardAssist"), 2)
			InputComp.RegisterSchemeContextAction("Gun","Reload","BoltRelease", InputComp:GetBindCode("Animated", "BoltRelease"), 2)
			InputComp.RegisterSchemeContextAction("Gun","Reload","MagazineRelease", InputComp:GetBindCode("Animated", "MagazineRelease"), 1)
			InputComp.RegisterSchemeContextAction("Gun","Reload","Cancel", InputComp:GetBindCode("Animated", "Cancel"), 1)
			InputComp.RegisterSchemeContext("Gun", "ReloadAltIndividual")
			InputComp.RegisterSchemeContextMode("Gun","ReloadAltIndividual", 1,  "Ammo", {})
			InputComp.RegisterSchemeContextMode("Gun","ReloadAltIndividual", 2,  "Bolt", {})
			InputComp.RegisterSchemeContextAction("Gun","ReloadAltIndividual","ForwardAssist", InputComp:GetBindCode("Animated", "ForwardAssist"), 2)
			InputComp.RegisterSchemeContextAction("Gun","ReloadAltIndividual","BoltRelease", InputComp:GetBindCode("Animated", "BoltRelease"), 2)
			InputComp.RegisterSchemeContextAction("Gun","ReloadAltIndividual","Cancel", InputComp:GetBindCode("Animated", "Cancel"), 1)
		end
	end,
}