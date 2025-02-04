
return function(CurrentItemState)
	local Item = CurrentItemState.ItemAPI.Value
	local S = CurrentItemState.ItemAPI.Settings
	local stockIndex = CurrentItemState.ItemAPI.stockIndex
	local sightIndex = CurrentItemState.sightIndex
	local FiringSystem = CurrentItemState.FiringSystem
	local Type = CurrentItemState.ItemAPI.Type
	local CharacterParts = CurrentItemState.CharacterParts
	local currentVehicle = CurrentItemState.currentVehicle
	local ViewModel = CurrentItemState.ViewModel
	local stockType = CurrentItemState.ItemAPI.stockType
	local newMag = CurrentItemState.newMag
	local AttributeUtils = CurrentItemState.AttributeUtils
	local player = CurrentItemState.Player
	return {
		Functions = {
			COS = math.cos;
			SIN = math.sin;
			RAD = math.rad;
			CF = CFrame.new;
			CFANG = CFrame.Angles;
			V3 = Vector3.new;
			FastWait = task.wait;
			FastDelay = task.delay;
			FastSpawn = CurrentItemState.FastSpawn;
		};
		Constants = {
			LC0 = CurrentItemState.armC0[1];
			RC0 = CurrentItemState.armC0[2];
			Player = CurrentItemState.Player;
			Cam = CurrentItemState.Camera;
		};
		Variables = {
			Aimed = function()
				return CurrentItemState.ItemAPI.Aimed;
			end,
			nadeType = function()
				return S.nadeType
			end,
			magType = function()
				return Item:GetAttribute("MagType")
			end,
			TurnSight = function()
				if Item:FindFirstChild("MainSightEffector") then
					return Item.MainSightEffector:FindFirstChild("SightHinge")
				end
			end,
			SightCylinder = function()
				if Item:FindFirstChild("MainSightLeafCylinder") then	
					return  Item.MainSightLeaf:FindFirstChild("SightCylinderSlide")
				end
			end;
			magPoint = function()
				return  Item:FindFirstChild("MagPoint") 			
			end;
			attachmentEmpty = function()
				return (not Item:GetAttribute("GrenadesReady"))
			end;
			ammoDiff = function()
				return Item:GetAttribute("ClipSize") - (Item:GetAttribute("Ammo"));	
			end;
			ClipSize = function()
				return Item:GetAttribute("ClipSize")
			end,
			stockIndex = function()
				return stockIndex	
			end;
			sightIndex = function()
				return sightIndex	
			end;
			trueEmpty = function()
				return Item:GetAttribute("Ammo") <= 0;	
			end;
			empty = function()
				return CurrentItemState.ammoInClip() <= 0; 
			end;
			nearEmpty = function()
				return CurrentItemState.ammoInClip() <= 1; 
			end;
			prevFireModeText = function()
				return FiringSystem:getPrev().Indicator:upper()								
			end;
			fireModeText = function()

				return FiringSystem.currentMode.Indicator:upper()

			end;
			nextFireModeText = function()
				return FiringSystem:getNext().Indicator:upper()	

			end;
			selectFireAngle = function()
				return S.selectFireSettings.Angles[FiringSystem:getNext().Indicator:upper()]

			end;
			fireMode = function()
				return FiringSystem.currentModeNum;
			end;
			prevSelectFireAngle = function()
				return S.selectFireSettings.Angles[FiringSystem:getPrev().Indicator:upper()]
			end;
			receiverHinge = function()
				if Item:FindFirstChild("ReceiverEffector") then
					return Item.ReceiverEffector:FindFirstChild("ReceiverHinge")
				end	
			end;
			slideRelease = function()
				if Item:FindFirstChild("SlideReleaseEffector") then
					return Item.SlideReleaseEffector:FindFirstChild("SlideReleaseHinge")
				end

			end;
			paddleReleaseHinge = function()
				if Item:FindFirstChild("PaddleReleaseEffector") then
					return Item.PaddleReleaseEffector:FindFirstChild("PaddleReleaseHinge")
				end

			end;
			hammerHinge = function()
				if Item:FindFirstChild("HammerEffector") then
					return Item.HammerEffector:FindFirstChild("HammerHinge")
				end
			end;
			safetySlider = function()
				if Item:FindFirstChild("SafetySlide") then
					return Item.SafetySlide:FindFirstChild("SafetySlider")
				end
			end;
			selectFireTab = function()
				if Item:FindFirstChild("SelectFireTabSlide") then
					return Item.SelectFireTabSlide:FindFirstChild("SelectorSlide")
				end
			end;
			grenadeCover = function()
				if Type == "Crate" then
					if Item:FindFirstChild("CoverSlide") then
						return Item.CoverSlide:FindFirstChild("CoverSlideWeld")
					end
				end
			end;
			safetyHinge = function()
				if Item:FindFirstChild("SafetyEffector") then
					return Item.SafetyEffector:FindFirstChild("SafetyHinge")
				end

			end;
			selectFireHinge = function()
				if Item:FindFirstChild("SelectorEffector") then
					return Item.SelectorEffector:FindFirstChild("SelectorHinge")
				end
			end;
			nadeIPoint = function()
				if Item:FindFirstChild("NadeIPoint") then
					return Item.NadeIPoint
				end	

			end;
			nadePoint = function()
				if Item:FindFirstChild("NadePoint") then
					return Item.NadePoint
				end
			end;
			ForwardAssist = function()
				if Item:FindFirstChild("ForwardAssistBase") then
					return Item.ForwardAssistBase:FindFirstChild("FASlide")
				end
				return nil;
			end,
			accessDoorHinge = function()
				if Item:FindFirstChild("AccessDoorEffector") then
					return Item.AccessDoorEffector:FindFirstChild("AccessDoorHinge")
				end	

			end;
			nadeBarrelHinge = function()
				if Item:FindFirstChild("GBHinge",true) then
					return Item:FindFirstChild("GBHinge",true)
				end	

			end;
			barrelReleaseLever = function()
				if Item:FindFirstChild("BarrelReleaseEffector") then
					return Item.BarrelReleaseEffector:FindFirstChild("BarrelReleaseHinge")
				end	
			end;
			nadeAttachment = function()
				if Item:FindFirstChild("GrenadeAttachment",true) then
					return Item:FindFirstChild("GrenadeAttachment",true)
				end		
			end;
			magVisible = function()
				if Item:FindFirstChild("Rounds") then
					return #Item.Rounds:GetChildren() >= Item:GetAttribute("ClipSize")
				end
				return Item:FindFirstChild("Magazine")	

			end;
			lGrenadeDmg = function()
				return  S.grenadeSettings.Lethal.damage;
			end;
			explosiveType = function()
				return S.grenadeSettings.Type;
			end;
			boltExtents = function()
				return S.boltSettings and S.boltSettings.Kick  or nil;
			end;
			gThrowVel = function()
				return S.grenadeSettings.throwVelocity;	
			end;
			blast = function()
				return {
					Pressure = S.grenadeSettings.Pressure;
					Radius =  S.grenadeSettings.Radius;
				}

			end;
			coverHinge = function()
				local coverHinge = Item:FindFirstChild("CoverEffector") 
				if coverHinge then
					coverHinge = coverHinge:FindFirstChild("CoverHinge")	
					return coverHinge
				end	
			end;
			newMag = function()
				return newMag
			end;
			Item = function()
				return Item;
			end,
			FRArm = function()
				return CharacterParts.RArm
			end;
			FLArm = function()
				return CharacterParts.LArm
			end;
			shellStorage = function(animName,args,animApi)
				if Item:FindFirstChild("ShellStorage") then
					local results = {};
					for i, v in ipairs(Item.ShellStorage:GetChildren()) do
						if v.Name:find("StoragePoint") then
							local tab = {
								Slot = v;
								Point = Item.ShellStorage:FindFirstChild("Slot"..(#results+1));
								Pos = function(offset)
									return animApi:getGrippingPos("left",v,offset or CFrame.new(-0.375,-0.5,0.25));
								end
							}
							table.insert(results,tab)
						end		
					end
					return results
				end			
			end;
			Vehicle = function(animName,args,animApi)
				local ve = currentVehicle
				local tab = {}
				if ve then
					ve = currentVehicle.Vehicle
				end
				if ve then
					tab.THandle = ve.Controls:FindFirstChild("Transmission")
					if tab.THandle then
						tab.THandle = tab.THandle:FindFirstChild("TransmissionHandle")
						tab.THandleJoint = ve:FindFirstChild("TransmissionSlide")
					end
				end
				tab.Gear = currentVehicle.CurrentGear
				return tab
			end,
			slc1 = function()
				local basePos = CurrentItemState.WeaponUtils:GetBasePose(Item)
				return CurrentItemState.ItemAPI.Aimed and CurrentItemState.ItemAPI:getArmPos("aimed","Right") or  CurrentItemState.ItemAPI:getArmPos(basePos,"Right")
			end;
			sLC1 = function()
				local basePos = CurrentItemState.WeaponUtils:GetBasePose(Item)
				return CurrentItemState.ItemAPI.Aimed and CurrentItemState.ItemAPI:getArmPos("aimed","Right") or  CurrentItemState.ItemAPI:getArmPos(basePos,"Right")
			end;
			aimed = function()
				return CurrentItemState.ItemAPI.Aimed
			end;
			LArm = function()
				return CharacterParts.LArm
			end;
			pumpSlide = function()
				if Item:FindFirstChild("PumpPart") then
					return Item.PumpPart:FindFirstChild("PumpSlide")
				end
				return nil
			end;
			PumpSlide = function()
				if Item:FindFirstChild("PumpPart") then
					return Item.PumpPart:FindFirstChild("PumpSlide")
				end
				return nil
			end;
			headCF = function()
				return CharacterParts.Head.CFrame
			end;
			RArm = function()
				return CharacterParts.RArm;
			end;
			LC1U = function()
				local basePos = CurrentItemState.WeaponUtils:GetBasePose(Item)
				return (if basePos then CurrentItemState.ItemAPI:getArmPos(basePos,"Left") else CFrame.new())
			end;
			RC1U = function()
				local basePos = CurrentItemState.WeaponUtils:GetBasePose(Item)
				return (if basePos then CurrentItemState.ItemAPI:getArmPos(basePos,"Right") else CFrame.new())
			end;
			LC1A = function()
				return CurrentItemState.poses["aimed"] and   CurrentItemState.ItemAPI:getArmPos("aimed","Left") or CFrame.new()	
			end;
			RC1A = function()
				return CurrentItemState.poses["aimed"] and   CurrentItemState.ItemAPI:getArmPos("aimed","Right") or CFrame.new()	
			end;
			LWeld = function()
				return CurrentItemState.ViewModel.LWeld
			end;
			LLW = function()
				return CurrentItemState.CharacterJoints.Hips.Left
			end;
			RLW = function()
				return CurrentItemState.CharacterJoints.Hips.Right
			end;
			nadeBreach = function()
				if Type == "Gun" then
					if Item:FindFirstChild("SlidePart") then
						return Item.SlidePart:FindFirstChild("GrenadeBreach");
					end
				end
			end;
			carousel = function()
				if Item:FindFirstChild("GunType") then
					if Item.GunType.Value == "Revolver" then
						return Item:FindFirstChild("CarouselCylinder")
					end
				end
				return nil	
			end;
			Carousel = function()
				if Item:FindFirstChild("GunType") then
					if Item.GunType.Value == "Revolver" then
						return Item:FindFirstChild("CarouselCylinder")
					end
				end
				return nil	
			end;
			grenadeEffect= function()
				return {
					Radius = S.grenadeSettings.detonationSettings.effectRadius;
					Time = S.grenadeSettings.detonationSettings.effectTime;
				}
			end;
			cylHingeU = function()
				if Item:FindFirstChild("GunType") then
					if Item.GunType.Value == "Revolver" then
						return Item:FindFirstChild("CylinderUHingeMotor",true)
					end
				end
				return nil;
			end;
			cylinderH = function()
				if Item:FindFirstChild("GunType") then
					if Item.GunType.Value == "Revolver" then
						return Item:FindFirstChild("CylinderHinge")
					end
				end
				return nil
			end;
			CylinderH = function()
				if Item:FindFirstChild("GunType") then
					if Item.GunType.Value == "Revolver" then
						return Item:FindFirstChild("CylinderHinge")
					end
				end
				return nil
			end;					
			cylHinge = function()
				if Item:FindFirstChild("GunType") then	
					if Item.GunType.Value == "Revolver" then
						return Item:FindFirstChild("CylinderHingeMotor",true)
					end
				end
				return nil
			end;
			CylHinge = function()
				if Item:FindFirstChild("GunType") then	
					if Item.GunType.Value == "Revolver" then
						return Item:FindFirstChild("CylinderHingeMotor",true)
					end
				end
				return nil
			end;
			CylHingeU = function()
				if Item:FindFirstChild("GunType") then
					if Item.GunType.Value == "Revolver" then
						return Item:FindFirstChild("CylinderUHingeMotor",true)
					end
				end
				return nil;
			end;
			grenadeType = function()
				if Type == "Grenade" then
					return S.grenadeMetaType
				end
				return nil 
			end;
			nadeSelHinge = function()
				if Type == "Gun" then
					if Item:FindFirstChild("GSelectorEffector") then
						return Item.GSelectorEffector:FindFirstChild("GSelectorHinge");
					end
				end	
			end;
			Handle = function()
				return Item:FindFirstChild("HoldPart");
			end;
			RWeld = function()
				return ViewModel.RWeld
			end;
			iGripC1 = function()
				local basePos = CurrentItemState.WeaponUtils:GetBasePose(Item)
				return (if basePos then  CurrentItemState.ItemAPI:getArmPos(basePos,"Grip") else CFrame.new())
			end;
			LWeld2 = function()
				return ViewModel.LWeld2
			end;
			RWeld2 = function()
				return ViewModel.RWeld2
			end;
			Grip = function()
				return ViewModel.Grips[ViewModel.Grips.Current]	
			end;
			LGrip = function()
				return ViewModel.Grips.Left
			end;
			RGrip = function()
				return ViewModel.Grips.Right
			end;
			Torso = function()
				return CharacterParts.Torso;
			end;
			gunIgnore = function()
				return ViewModel.gunIgnore
			end;
			TopEjector = function()
				return Item:FindFirstChild("ETopSlide",true)
			end;
			BottomEjector = function()
				return Item:FindFirstChild("EBottomSlide",true)
			end;
			bipodHinge = function()
				local result
				if Item:FindFirstChild("BipodMain") then
					result = Item.BipodMain:FindFirstChild("BipodVertHinge")
				end				
				return result	
			end;
			vaultTarget = function(animName,args)
				if animName == "Parkour" then
					return args[1];
				end
				return nil
			end;				
			bipodLegs = function(animName,args)
				local legs = {}
				if Item:FindFirstChild("BipodLeftEffector") then
					legs[1] = Item.BipodLeftEffector:FindFirstChild("BipodLeftWeld")
				elseif Item:FindFirstChild("LeftBipodEffector") then
					legs[1] = Item.LeftBipodEffector:FindFirstChild("BipodLeftWeld")									
				end
				if Item:FindFirstChild("BipodRightEffector") then
					legs[2] = Item.BipodRightEffector:FindFirstChild("BipodRightWeld")
				elseif Item:FindFirstChild("RightBipodEffector") then
					legs[2] = Item.RightBipodEffector:FindFirstChild("BipodRightWeld")									
				end		
				return legs
			end;
			bayonetHinge = function(animName,args)
				return Item:FindFirstChild("BayonetHingeMotor",true)
			end,
			bfHinge = function(animName,args)
				if Item:FindFirstChild("BeltFeedEffector") then
					return Item.BeltFeedEffector:FindFirstChild("BeltFeedHinge")
				end
			end;
			stockSlide = function(animName)
				if stockType then
					if stockType == "Folding" then
						local hingePart = Item:FindFirstChild("StockHinge")
						if hingePart then
							return hingePart:FindFirstChild("StockFoldHinge")
						end
					elseif stockType == "Telescopic" then
						local hingePart = Item:FindFirstChild("StockSlide")
						if hingePart then
							return hingePart:FindFirstChild("StockWeld")
						end
					elseif stockType == "Hybrid" then
						if animName == "AdjustStockFold" then
							local hingePart = Item:FindFirstChild("StockHinge")
							if hingePart then
								return hingePart:FindFirstChild("StockFoldHinge")
							end
						else
							local hingePart = Item:FindFirstChild("AltStockSlide")
							if hingePart then
								return hingePart:FindFirstChild("StockWeld")
							end
						end
					end
					return nil
				end
				return nil	
			end;
			StockSlide = function(animName)
				if stockType then
					if stockType == "Folding" then
						local hingePart = Item:FindFirstChild("StockHinge")
						if hingePart then
							return hingePart:FindFirstChild("StockFoldHinge")
						end
					elseif stockType == "Telescopic" then
						local hingePart = Item:FindFirstChild("StockSlide")
						if hingePart then
							return hingePart:FindFirstChild("StockWeld")
						end
					elseif stockType == "Hybrid" then
						if animName == "AdjustStockFold" then
							local hingePart = Item:FindFirstChild("StockHinge")
							if hingePart then
								return hingePart:FindFirstChild("StockFoldHinge")
							end
						else
							local hingePart = Item:FindFirstChild("AltStockSlide")
							if hingePart then
								return hingePart:FindFirstChild("StockWeld")
							end
						end
					end
					return nil
				end
				return nil	
			end;
			monopod = function()
				local MS = Item:FindFirstChild("MonopodSlide")
				if MS then
					return MS:FindFirstChild("MonopodSlide")
				end
			end;
			barrelSwapLever = function()
				local MS = Item:FindFirstChild("BarrelSwapEffector")
				if MS then
					return MS:FindFirstChild("BarrelSwapHinge")
				end
			end;
			feedingTray = function()
				local MS = Item:FindFirstChild("FeedingTrayEffector")
				if MS then
					return MS:FindFirstChild("FeedHinge")
				end	
			end;
			magazineSlide  = function()
				if Item:FindFirstChild("MagazineReleaseSlide") then
					return 	Item:FindFirstChild("MagazineReleaseSlide"):FindFirstChild("MagRSlide")
				end		
			end;
			dbrhinge = function()
				return Item.BarrelReleaseEffector:FindFirstChild("BarrelReleaseHinge");																														
			end;
			DBRHinge = function()
				return Item.BarrelReleaseEffector:FindFirstChild("BarrelReleaseHinge");																														
			end;
			lidhinge = function()
				if Type == "Gun" then
					if S.reloadSettings.feedType == "Belt" then
						return Item.LidEffector:FindFirstChild("LidHinge");
					end
				elseif Type == "Medicine" then
					if Item:FindFirstChild("CaseEffector") then
						if Item.CaseEffector:FindFirstChild("LidHinge") then
							return Item.CaseEffector:FindFirstChild("LidHinge")
						end
					end
				end
				return nil
			end;
			LidHinge = function()
				if Type == "Gun" then
					if S.reloadSettings.feedType == "Belt" then
						return Item.LidEffector:FindFirstChild("LidHinge");
					end
				elseif Type == "Medicine" then
					if Item:FindFirstChild("CaseEffector") then
						if Item.CaseEffector:FindFirstChild("LidHinge") then
							return Item.CaseEffector:FindFirstChild("LidHinge")
						end
					end
				end
				return nil
			end;
			BarrelHinge = function()
				if Type == "Gun" then
					if Item:FindFirstChild("BarrelEffector") then
						return Item.BarrelEffector:FindFirstChild("BarrelHinge");
					end
				end
				return nil
			end;
			detonationSlide = function()
				if Item:FindFirstChild("SlideJoint",true) then
					return Item:FindFirstChild("SlideJoint",true)
				end
			end;
		};
		TimeVariables = {
			reloadTime = function()
				local timeReload =  {
					Loaded = S.reloadSettings and S.reloadSettings.Times.Loaded or nil;
					Empty = S.reloadSettings and S.reloadSettings.Times.Empty or nil;
				}
				if timeReload.Loaded and timeReload.Empty then
					timeReload.Loaded -= AttributeUtils.getReloadTimeDeficit(player)
					timeReload.Loaded = math.clamp(timeReload.Loaded, 1, S.reloadSettings.Times.Loaded)
					timeReload.Empty -= AttributeUtils.getReloadTimeDeficit(player)
					timeReload.Empty = math.clamp(timeReload.Empty, 1, S.reloadSettings.Times.Empty)
				end
				return timeReload
			end;
			dropTime = function()
				return S.dropTime;
			end;
			inspectTime = function()
				return S.inspectTime or nil;
			end;
			equipTime = function()
				return S.equipSettings.Time;
			end;	
			detTime = function()
				return S.grenadeSettings.detonationSettings.Time;
			end;
			aimSpeed = function()
				return S.aimSettings.Speed;	
			end;
			selectFireSpeed = function()
				return S.selectFireSettings.animSpeed;
			end;	
		};
		
	}
end