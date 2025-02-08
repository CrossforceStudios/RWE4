local Resources = require(game.ReplicatedStorage.Resources)
local PseudoInstance = Resources:LoadLibrary("PseudoInstance") 
local CartridgeList = Resources:LoadConfiguration("Cartridge") 

local ch = require(script.CommonHooks)
local SMOKE_NADE_COLOR_NAMES = {"Bright red";BrickColor.White().Name;"Bright orange";"Bright yellow";"Bright green";"Bright blue";"Dark indigo";"Bright violet";}
local LERP_IDLE_THRESH = 0.15
local gunAC0 = nil
local db = {
	["Melee"] = false;
};

local itemTypes = {
	Types = {
		["Gun"] = {
			Name = "Gun";

			Capabilities = {
				"FireMode";
				"Cartridge";
				"ScopeADS";
				"TrackAmmo";
				"Recoil";
				"Lasers";
				"UsesAction";
				"AcceptsAttachments";
				"AITrigger";
			};
			SubTypeName = "Gun";
			HUD = { 
				InitContext = function(hudObj)
					local obj = PseudoInstance.new("GunCM")
					obj:Setup(hudObj.UI.gunUI)
					return obj
				end,
			};
			Animation = {
				poseName = "unAimed";
				animCF = function(animTab,...)
					local args = {...}
					local t = args[2];
					local dt = args[1]
					if t == "General" then
						local sCF			

						local set = false;
						if animTab.CurrentItemValue then
							if animTab.CurrentItemValue:FindFirstChild("Stock") then
								if (not animTab.CurrentItemValue:FindFirstChild("StockHinge")) and (not animTab.CurrentItemValue:FindFirstChild("StockSlide")) then
									animTab.resetSway()
									set = true
								end
							end
							if animTab.CurrentItemValue:FindFirstChild("StockButt") then
								if (not animTab.CurrentItemValue:FindFirstChild("StockHinge")) and (not animTab.CurrentItemValue:FindFirstChild("StockSlide")) then
									animTab.resetSway()
									set = true

								end
							end
							if (animTab.initialStockType == "Telescopic" and animTab.stockIndex > 1) or (animTab.initialStockType == "Hybrid" and (animTab.stockIndex > 1 or animTab.stockFoldIndex <= 1)) or ((animTab.stockIndex <= 1 and animTab.initialStockType == "Folding"))  then
								animTab.resetSway()
								set = true
							end
							if animTab.Aimed then
								animTab.resetSway()
								set = true

							end
						end
						if (not animTab.stanceTrans) and (not set) then
							animTab.swayCF.g = Vector3.new(animTab.MotionVector.X,animTab.MotionVector.Y,0)
						end
						if not animTab.Aimed then
							animTab.setAnimRot(if math.abs(animTab.humanRotation()) > 0 then Vector3.new(
								0,
								0,
								((5*dt) * (animTab.humanRotation()))) else Vector3.new())
						else
							animTab.setAnimRot(Vector3.new())
						end
						local aC0, aC1 = animTab.CF.RAW(animTab.aimHeadOffset,0,0) * animTab.CF.ANG(0, 0, -animTab.aimAngle/(math.pi * 2)) * animTab.CF.ANG(
						(animTab.gunRecoilSpring.p.X + animTab.AnimRot.X)* animTab.stanceSway ,
						(animTab.gunRecoilSpring.p.Y +  animTab.AnimRot.Y)* animTab.stanceSway ,
						(animTab.gunRecoilSpring.p.Z + animTab.AnimRot.Z) * animTab.stanceSway 
						) * animTab.CF.RAW( 
							(animTab.recoilAnim.Pos.X + animTab.AnimPos.X) * animTab.stanceSway ,
							(animTab.recoilAnim.Pos.Y + animTab.AnimPos.Y)* animTab.stanceSway ,
							(animTab.recoilAnim.Pos.Z + animTab.AnimPos.Z) * animTab.stanceSway 
						) * animTab.CF.ANG((-math.rad(animTab.swayCF.p.Y/18) * 5), (-math.rad(animTab.swayCF.p.X/18) * 5), (math.rad(animTab.swayCF.p.X/18) * 5)),
						animTab.CF.ANG(-animTab.CameraAng.Y * animTab.crawlAlpha / 90, 0, 0) * animTab.CF.RAW(animTab.aimHeadOffset,-1,0) ---CF.ANG(COS(CameraAng.Y) * (animTab.gunRecoilSpring.p.X + Anim.Rot.X) * stanceSway,(animTab.gunRecoilSpring.p.Y + Anim.Rot.Y) * stanceSway, (animTab.gunRecoilSpring.p.Z + Anim.Rot.Z) * stanceSway) * CF.RAW((recoilAnim.Pos.X + Anim.Pos.X) * stanceSway,COS(CameraAng.Y) * (recoilAnim.Pos.Y + Anim.Pos.Y) * stanceSway,SIN(CameraAng.Y) * (recoilAnim.Pos.Z + Anim.Pos.Z) * stanceSway),CF.RAW(aimHeadOffset, -1, 0);
				--[[if leanAnim.Rot ~= 0 and (CurrentItem.Aimed  or CurrentItem.Aiming)  then
					aC0 = aC0 * aC0:toObjectSpace(CF.RAW(aimHeadOffset, 0, 0))
				end]]--
						if not gunAC0 then
							gunAC0 = aC0
						end
						if animTab.humanDirection.Magnitude > 0 then
							if animTab.Stance ~= 3  then
								local wsp = animTab.walkSpeedSpring.p
								aC0 = aC0 * animTab.gunbob(animTab.walkAnimName , (if animTab.Aimed then .01 else .25 )*  wsp/animTab.bWS, (if animTab.Aimed then .1 else .5) * wsp/animTab.bWS,dt)
							end
						elseif animTab.Aimed and (not animTab.isPlayingAnim()) and animTab.Stance < 2 and (not animTab.stanceTrans) then
							local newAC0 = aC0
							aC0 = gunAC0
							gunAC0 = newAC0
						elseif (not animTab.Aimed) and (not animTab.isPlayingAnim()) and animTab.Stance < 2 and (not animTab.stanceTrans) then
							local idleAng2 = animTab.idleAng + animTab.RAD(105 * dt) * animTab.stanceSway
							aC0 = aC0 * animTab.Lerps.CFrame(animTab.CF.RAW(),animTab.gunbobIdle(idleAng2,dt),LERP_IDLE_THRESH)

							animTab.setIdleAng(idleAng2)
						end
						if animTab.NVG  and animTab.NVGOffset then
							aC0 *= animTab.NVGOffset
						end
						return  aC0, aC1
					end
				end;
			};
			Actions = {
				AddBarrelHeat = ch.AddBarrelHeat;
			};
			Statistics = {
				["RPM"] = {
					Title = "Fire Rate";
					Process = function(item, sett, api)
						return sett.roundsPerMin
					end,
				};
				["Cartridge"] = {
					Title = "Main Projectile";
					Process = function(item, sett, api)
						local MagList = api.MagList
						local Cartridges = api.Cartridges
						local mag = MagList[sett.reloadSettings.usableMags[1]]
						return Cartridges[mag.CartridgeName].Title
					end,
				};
				["MuzzleVelocity"] = {
					Title = "Muzzle Velocity";
					Process = function(item, sett, api)
						local MagList = api.MagList
						local Cartridges = api.Cartridges
						local mag = MagList[sett.reloadSettings.usableMags[1]]
						local cart = Cartridges[mag.CartridgeName]
						if item:GetAttribute("GaugeIndex") then
							cart:SetupGauge(item:GetAttribute("GaugeIndex"))
						end
						if sett.bulletSettings then
							cart:SetupBarrel(sett.bulletSettings, item)
						end
						local velocity = math.floor(cart.Velocity)
						return velocity .. " studs/s"
					end,
				};
				["Range"] = {
					Title = "Maximum Range";
					Process = function(item, sett, api)
						local MagList = api.MagList
						local Cartridges = api.Cartridges
						local mag = MagList[sett.reloadSettings.usableMags[1]]
						local cart = Cartridges[mag.CartridgeName]
						if item:GetAttribute("GaugeIndex") then
							cart:SetupGauge(item:GetAttribute("GaugeIndex"))
						end
						if sett.bulletSettings then
							cart:SetupBarrel(sett.bulletSettings, item)
						end
						local range = math.floor(cart.Range)
						return range .. " studs"
					end,
				};
				["BDrop"] = {
					Title = "Bullet Drop";
					Process = function(item, sett, api)
						local MagList = api.MagList
						local Cartridges = api.Cartridges
						local mag = MagList[sett.reloadSettings.usableMags[1]]
						local accel = Cartridges[mag.CartridgeName].Acceleration
						if sett.bulletSettings.RangeModifier then
							accel = accel +  sett.bulletSettings.AccelerationModifier
						end
						return accel .. " studs/s" .. utf8.char(178)
					end,
				};
				["BlackScope"] = {
					Title = "Scoped (Initially) ?";
					Process = function(item, sett, api)
						return sett.guiScope and "YES" or "NO"	
					end,
				};
				["Firemodes"] = {
					Title = "Fire Modes";
					Process = function(item, sett, api)
						local fmString = ""
						for i, fireMode in ipairs(sett.selectFireSettings.Modes) do
							if fireMode then
								fmString = fmString .. fireMode
								if i < #sett.selectFireSettings.Modes then
									fmString = fmString .. ", "
								end
							end
						end
						return fmString	
					end,
				};
				
			};
			Input = {
				Scheme = "Gun";
				Actions = {
					ToggleAttachment = ch.ToggleAttachmentKey;
					ToggleBipod = function(player, item, api, ...)
						local CurrentItem = api.CurrentItem;
						if CurrentItem.Value then
							if not CurrentItem:IsPlayingAnim() then
								CurrentItem:deployBipod()
							end
						end
					end,
					ZoomIn = ch.ZoomIn;
					selectFire = ch.selectFire;
					ZoomUniversal = ch.ZoomUniversal;
					ElevationUp = ch.ElevationUp;
					ElevationDown = ch.ElevationDown;
					ZoomOut = ch.ZoomOut;
					AdjustSights = ch.AdjustSights;
					AdjustStock = ch.AdjustStock;
					Reload = ch.Reload;
					Inspect = ch.Inspect;
					cycleSights = ch.cycleSights;
				};
				Activate = function(player, item, api, ...)
					local CurrentItem = api.CurrentItem;
					local InputComp = api.InputComp;
					local tween = api.tween;
					local Humanoid = api.Humanoid;
					local Character = api.Character;
					local CharState = api.CharState;
					local FastWait = api.FastWait;
					local getAlpha = api.getAlpha;
					local RAD = api.RAD;
					local CF = api.CF;
					local i = api.input;

					if not CurrentItem.FiringSystem then return end
					if not CurrentItem.Value then return end
					if not (CharState.MoveEnabled) then return end			
					if Humanoid.Health <= 0 or Character:IsDescendantOf(workspace.CorpseIgnore) then
						return
					end
					if CurrentItem.Equipped then
						if (not CurrentItem:IsPlayingAnim()) and CharState.currentState ~= "Running" then
							CurrentItem:enableLinks()

							if CurrentItem.Value:FindFirstChild("TriggerEffector") then
								if CurrentItem.Value.TriggerEffector:FindFirstChild("TriggerHinge") then

									tween("Joint",CurrentItem.Value.TriggerEffector.TriggerHinge,nil,CF.ANG(RAD(-30),0,0),getAlpha("Deceleration"),0.05)
									FastWait(0.05)
								end
							end
							if CurrentItem.Value:GetAttribute("Ammo") <= 0 and (not CurrentItem.Value:GetAttribute("Clicked")) then
								if (CurrentItem.Settings.animSounds["Click"]) then
									CurrentItem.Value:SetAttribute("Clicked", true)
									CurrentItem:playSound("Click")
								end
								return
							end
							CurrentItem.FiringSystem:runMode(CurrentItem.firingApi,(i.UserInputType == Enum.UserInputType.MouseButton3 or (InputComp.GetSchemeMode("Gun") == 2 and InputComp:IsInputDown(Enum.KeyCode.ButtonR3))) and CurrentItem.Settings.workingBarrels or 1)
							if CurrentItem.Value:FindFirstChild("TriggerEffector") then
								if CurrentItem.Value.TriggerEffector:FindFirstChild("TriggerHinge") then
									tween("Joint",CurrentItem.Value.TriggerEffector.TriggerHinge,nil,CF.ANG(0,RAD(0),0),getAlpha("Deceleration"),0.05)
									FastWait(0.05)											
								end		
							end	
							CurrentItem:disableLinks()

						end
					end
				end,
			};
			AsyncActions = {
				CreateLaserDot = ch.CreateLaserDot;
				CreateMagazine = ch.CreateMagazine;
				CreateCartridge = ch.CreateCartridge;
				DetachNadeMag = ch.DetachNadeMag;
				DetachRound = ch.DetachRound;
				DetachMag = ch.DetachMag;
				AttachMag = ch.AttachMag;
			};
			Hooks = {
				PreLoad = function(api, mApi)

				end,
				SetupStats = function(api, mApi)

				end,
				CanDisplayTier = function(api, mApi)
					local tier = mApi.Tier
					if mApi.Settings.acceptedSlots then
						return (not table.find(mApi.OddTiers, tier.ClassName)) 
							and ((table.find(mApi.Settings.acceptedSlots, tier.Name))
								or
								(tier.Name == "Magazines" or tier.Name == "Furnitures" or tier.Name == "Alloys")
							)
						
					end
					return (not table.find(mApi.OddTiers, tier.ClassName))
				end,
				Equip = function(api, mApi)

					mApi.tween("Joint",mApi.ViewModel.LWeld,false,api:getArmPos("unAimed","Left"), mApi.getAlpha("OutSine"), mApi.S.equipSettings.Time)
					mApi.tween("Joint",mApi.ViewModel.RWeld, false,api:getArmPos("unAimed","Right"), mApi.getAlpha("OutSine"), mApi.S.equipSettings.Time)
					mApi.tween("Joint",mApi.ViewModel.Grips.Right, false, api:getArmPos("unAimed","Grip"), mApi.getAlpha("OutSine"), mApi.S.equipSettings.Time)
				end,
				Aimed = function(api, mApi)
					local partlist = {
						mApi.ViewModel.armModel;
						mApi.ViewModel.playerFolder;
					}
					_G.HM:PerformCMAction("RunScopeJob", "ToggleWithItems", true, partlist)
					for _, v in ipairs(mApi.Character:GetDescendants()) do
						if v ~= v:FindFirstAncestorOfClass("Model").PrimaryPart then
							if v:IsA("BasePart") then
								v.LocalTransparencyModifier = 1
							elseif v:IsA("RopeConstraint") then
								v.Visible = false	
							end
						end
					end
				end,
				PreUnAim = function(api, mApi)
					_G.HM:PerformCMAction("RunScopeJob", "ToggleWithItems", false, {
						mApi.ViewModel.armModel;
						mApi.ViewModel.playerFolder;
						api.Value;
						api.Value:FindFirstChild("Magazine");
						api.Value:FindFirstChild("MagPoint");
					})
					for _, v in ipairs(mApi.Character:GetDescendants()) do
						if v ~= v:FindFirstAncestorOfClass("Model").PrimaryPart then
							if v:IsA("BasePart") then
								if (not v:IsDescendantOf(mApi.Character)) and (not v:IsDescendantOf(api.Value)) then
									v.LocalTransparencyModifier = 0
								elseif (v:FindFirstChild("ArmPart"))  then
									v.LocalTransparencyModifier = 0
								elseif (v:IsDescendantOf(mApi.Character:FindFirstChild("FakeArms"))) then
									v.LocalTransparencyModifier = 0
								end
							elseif v:IsA("RopeConstraint") then
								v.Visible = true	
							end
						end
					end
				end,
				Unaimed = function(api, mApi)
					_G.HM:PerformCMAction("RunScopeJob", "ToggleWithItems", false, {
						mApi.ViewModel.armModel;
						mApi.ViewModel.playerFolder;
						api.Value;
					})
					_G.HM:SetContextUIEnabled(true)
				end,
				PostDisplay = function(api, mApi)
					local AttachmentMods = mApi.AttachmentMods
					local RemoteService = mApi.RemoteService
					local AttachmentsList = mApi.AttachmentsList
					local CF = mApi.CF
					for _, slot in ipairs(AttachmentMods.Slots) do
						local attachmentStub = RemoteService.fetch("Server","GetAttachmentSlot",api.Item.Name,slot)
						if attachmentStub then
							local attachmentStub2 = api:GetAttachmentFromCache(api.Item,slot) 
							if not attachmentStub2 then
								attachmentStub2 = {
									Name = attachmentStub.Name;
									Slot = slot;
									CFrame = CFrame.new();
								};
								api:SetAttachmentSlotCC(api.Item, attachmentStub2, slot, attachmentStub.CFrame)
							end
							if typeof(attachmentStub) == "table" then
								attachmentStub = attachmentStub.Name
							end
							if attachmentStub == "" then continue end
							local newAttachment = AttachmentsList[attachmentStub]
							newAttachment:AddWeapon(api.Item.Name,CF(),nil)
							if ((not api.Item:FindFirstChild("Lid")) or newAttachment.Slot ~= "Optics")  then
								newAttachment:Apply(api.LoadoutImage.Object3D,"HoldPart")
							elseif api.Item:FindFirstChild("Lid") then
								newAttachment:Apply(api.LoadoutImage.Object3D,"Lid")
							end
						end
					end
					if api.Item.GunType.Value == "Pistol" or api.Item.GunType.Value == "MachinePistol"  or api.Item.GunType.Value == "Revolver" then	
						for _, part in ipairs(api.LoadoutImage.Object3D:GetChildren()) do
							if part.Name == "AimPart" then
								part:Destroy() 
							end
						end 
					end
					api:DisplayTierTitle("Optics", api.Item)
				end,
			};
		};
		["Launcher"] = {
			Name = "Launcher";
			SubTypeName = "Launcher";
			Capabilities = {
				"FireMode";
				"Cartridge";
				"ScopeADS";
				"TrackAmmo";
				"Recoil";
				"Lasers";
				"AcceptsAttachments";
				"DistanceDamage";
				"Dispose";
				"AITrigger";
			};
			HUD = { 
				InitContext = function(hudObj)
					local obj = PseudoInstance.new("GunCM")
					obj:Setup(hudObj.UI.gunUI)
					return obj
				end,
			};
			SubTypeData = {
				["Grenade"] = {
					ClipName = "GrenadeCount";
				};
			};
			Animation = {
				poseName = "unAimed";
				animCF = function(animTab,...)
					local args = {...}
					local t = args[2];
					local dt = args[1]
					if t == "General" then
						local sCF			

						local set = false;
						if animTab.CurrentItemValue then
							if animTab.CurrentItemValue:FindFirstChild("Stock") then
								if (not animTab.CurrentItemValue:FindFirstChild("StockHinge")) and (not animTab.CurrentItemValue:FindFirstChild("StockSlide")) then
									animTab.resetSway()
									set = true
								end
							end
							if animTab.CurrentItemValue:FindFirstChild("StockButt") then
								if (not animTab.CurrentItemValue:FindFirstChild("StockHinge")) and (not animTab.CurrentItemValue:FindFirstChild("StockSlide")) then
									animTab.resetSway()
									set = true

								end
							end
							if (animTab.initialStockType == "Telescopic" and animTab.stockIndex > 1) or (animTab.initialStockType == "Hybrid" and (animTab.stockIndex > 1 or animTab.stockFoldIndex <= 1)) or ((animTab.stockIndex <= 1 and animTab.initialStockType == "Folding"))  then
								animTab.resetSway()
								set = true
							end
							if animTab.Aimed then
								animTab.resetSway()
								set = true

							end
						end
						if (not animTab.stanceTrans) and (not set) then
							animTab.swayCF.g = Vector3.new(animTab.MotionVector.X,animTab.MotionVector.Y,0)
						end
						if not animTab.Aimed then
							animTab.setAnimRot(if math.abs(animTab.humanRotation()) > 0 then Vector3.new(
								0,
								0,
								((5*dt) * (animTab.humanRotation()))) else Vector3.new())
						else
							animTab.setAnimRot(Vector3.new())
						end
						local aC0, aC1 = animTab.CF.RAW(animTab.aimHeadOffset,0,0) * animTab.CF.ANG(0, 0, -animTab.aimAngle/(math.pi * 2)) * animTab.CF.ANG(
						(animTab.gunRecoilSpring.p.X + animTab.AnimRot.X)* animTab.stanceSway ,
						(animTab.gunRecoilSpring.p.Y +  animTab.AnimRot.Y)* animTab.stanceSway ,
						(animTab.gunRecoilSpring.p.Z + animTab.AnimRot.Z) * animTab.stanceSway 
						) * animTab.CF.RAW( 
							(animTab.recoilAnim.Pos.X + animTab.AnimPos.X) * animTab.stanceSway ,
							(animTab.recoilAnim.Pos.Y + animTab.AnimPos.Y)* animTab.stanceSway ,
							(animTab.recoilAnim.Pos.Z + animTab.AnimPos.Z) * animTab.stanceSway 
						) * animTab.CF.ANG((-math.rad(animTab.swayCF.p.Y/18) * 5), (-math.rad(animTab.swayCF.p.X/18) * 5), (math.rad(animTab.swayCF.p.X/18) * 5)),
						animTab.CF.ANG(-animTab.CameraAng.Y * animTab.crawlAlpha / 90, 0, 0) * animTab.CF.RAW(animTab.aimHeadOffset,-1,0) ---CF.ANG(COS(CameraAng.Y) * (animTab.gunRecoilSpring.p.X + Anim.Rot.X) * stanceSway,(animTab.gunRecoilSpring.p.Y + Anim.Rot.Y) * stanceSway, (animTab.gunRecoilSpring.p.Z + Anim.Rot.Z) * stanceSway) * CF.RAW((recoilAnim.Pos.X + Anim.Pos.X) * stanceSway,COS(CameraAng.Y) * (recoilAnim.Pos.Y + Anim.Pos.Y) * stanceSway,SIN(CameraAng.Y) * (recoilAnim.Pos.Z + Anim.Pos.Z) * stanceSway),CF.RAW(aimHeadOffset, -1, 0);
				--[[if leanAnim.Rot ~= 0 and (CurrentItem.Aimed  or CurrentItem.Aiming)  then
					aC0 = aC0 * aC0:toObjectSpace(CF.RAW(aimHeadOffset, 0, 0))
				end]]--
						if not gunAC0 then
							gunAC0 = aC0
						end
						if animTab.humanDirection.Magnitude > 0 then
							if animTab.Stance ~= 3  then
								local wsp = animTab.walkSpeedSpring.p
								aC0 = aC0 * animTab.gunbob(animTab.walkAnimName , (if animTab.Aimed then .01 else .25 )*  wsp/animTab.bWS, (if animTab.Aimed then .1 else .5) * wsp/animTab.bWS,dt)
							end
						elseif animTab.Aimed and (not animTab.isPlayingAnim()) and animTab.Stance < 2 and (not animTab.stanceTrans) then
							local newAC0 = aC0
							aC0 = gunAC0
							gunAC0 = newAC0
						elseif (not animTab.Aimed) and (not animTab.isPlayingAnim()) and animTab.Stance < 2 and (not animTab.stanceTrans) then
							local idleAng2 = animTab.idleAng + animTab.RAD(105 * dt) * animTab.stanceSway
							aC0 = aC0 * animTab.Lerps.CFrame(animTab.CF.RAW(),animTab.gunbobIdle(idleAng2,dt),LERP_IDLE_THRESH)

							animTab.setIdleAng(idleAng2)	
						end
						if animTab.NVG  and animTab.NVGOffset then
							aC0 *= animTab.NVGOffset
						end
						return  aC0, aC1
					end
				end;
			};
			Actions = {
				AddBarrelHeat = ch.AddBarrelHeat;
				Toss = ch.Toss;
			};
			Statistics = {
				["Cartridge"] = {
					Title = "Main Projectile";
					Process = function(item, sett, api)
						local MagList = api.MagList
						local Cartridges = api.Cartridges
						if sett.reloadSettings.usableGrenade then
							local cart = Cartridges[sett.reloadSettings.usableGrenade]
							if item:GetAttribute("GaugeIndex") then
								cart:SetupGauge(item:GetAttribute("GaugeIndex"))
							end
							return cart.Title
						else
							local mag = MagList[sett.reloadSettings.usableMags[1]]
							local cart = Cartridges[mag.CartridgeName]
							if item:GetAttribute("GaugeIndex") then
								cart:SetupGauge(item:GetAttribute("GaugeIndex"))
							end
							return cart.Title

						end
					end,
				};
				["MuzzleVelocity"] = {
					Title = "Projectile Speed";
					Process = function(item, sett, api)
						local MagList = api.MagList
						local Cartridges = api.Cartridges
						
						if sett.reloadSettings.usableGrenade then
							local cart = Cartridges[sett.reloadSettings.usableGrenade]
							if item:GetAttribute("GaugeIndex") then
								cart:SetupGauge(item:GetAttribute("GaugeIndex"))
							end
							if sett.bulletSettings then
								cart:SetupBarrel(sett.bulletSettings, item)
							end
							local velocity = math.floor(cart.Velocity)
							return velocity .. " studs/s"
						else
							local mag = MagList[sett.reloadSettings.usableMags[1]]
							local cart = Cartridges[mag.CartridgeName]
							if item:GetAttribute("GaugeIndex") then
								cart:SetupGauge(item:GetAttribute("GaugeIndex"))
							end
							if sett.bulletSettings then
								cart:SetupBarrel(sett.bulletSettings, item)
							end
							local velocity = math.floor(cart.Velocity)
							return velocity .. " studs/s"
						end
						
						
					end,
				};
				["Range"] = {
					Title = "Maximum Range";
					Process = function(item, sett, api)
						local MagList = api.MagList
						local Cartridges = api.Cartridges
						if sett.reloadSettings.usableGrenade then
							local cart = Cartridges[sett.reloadSettings.usableGrenade]
							if item:GetAttribute("GaugeIndex") then
								cart:SetupGauge(item:GetAttribute("GaugeIndex"))
							end
							local range = math.floor(cart.Range)
							return range .. " studs"
						else
							local mag = MagList[sett.reloadSettings.usableMags[1]]
							local cart = Cartridges[mag.CartridgeName]
							if item:GetAttribute("GaugeIndex") then
								cart:SetupGauge(item:GetAttribute("GaugeIndex"))
							end
							local range = math.floor(cart.Range)
							return range .. " studs"
						end
					end,
				};
				["ExplosiveRadius"] = {
					Title = "Blast Radius";
					Process = function(item, sett, api)
						local MagList = api.MagList
						local Cartridges = api.Cartridges
						local ED = api.Explosives
						if sett.reloadSettings.usableGrenade then
							local cart = Cartridges[sett.reloadSettings.usableGrenade]
							if item:GetAttribute("GaugeIndex") then
								cart:SetupGauge(item:GetAttribute("GaugeIndex"))
							end
							local radius = math.floor(ED[cart.Name].Radius)
							return radius .. " studs"
						else
							local mag = MagList[sett.reloadSettings.usableMags[1]]
							local cart = Cartridges[mag.CartridgeName]
							if item:GetAttribute("GaugeIndex") then
								cart:SetupGauge(item:GetAttribute("GaugeIndex"))
							end
							local radius = math.floor(ED[cart.Name].Radius)
							return radius .. " studs"
						end
						
					end,
				};
			};
			Input = {
				Scheme = "Gun";
				Actions = {
					ToggleAttachment = ch.ToggleAttachmentKey;
					selectFire = ch.selectFire;
					ZoomIn = ch.ZoomIn;
					ZoomUniversal = ch.ZoomUniversal;
					ElevationUp = ch.ElevationUp;
					ElevationDown = ch.ElevationDown;
					ZoomOut = ch.ZoomOut;
					AdjustSights = ch.AdjustSights;
					AdjustStock = ch.AdjustStock;
					Reload = ch.Reload;
					Inspect = ch.Inspect;
					cycleSights = ch.cycleSights;
				};
				Activate = function(player, item, api, ...)
					local CurrentItem = api.CurrentItem;
					local InputComp = api.InputComp;
					local tween = api.tween;
					local Humanoid = api.Humanoid;
					local Character = api.Character;
					local CharState = api.CharState;
					local FastWait = api.FastWait;
					local getAlpha = api.getAlpha;
					local RAD = api.RAD;
					local i = api.input;
					local CF = api.CF;

					if not CurrentItem.FiringSystem then return end
					if not CurrentItem.Value then return end
					if not (CharState.MoveEnabled) then return end			
					if Humanoid.Health <= 0 or Character:IsDescendantOf(workspace.CorpseIgnore) then
						return
					end
					if CurrentItem.Equipped then
						if (not CurrentItem:IsPlayingAnim()) and CharState.currentState ~= "Running" then
							CurrentItem:enableLinks()

							if CurrentItem.Value:FindFirstChild("TriggerEffector") then
								if CurrentItem.Value.TriggerEffector:FindFirstChild("TriggerHinge") then

									tween("Joint",CurrentItem.Value.TriggerEffector.TriggerHinge,nil,CF.ANG(RAD(-30),0,0),getAlpha("Deceleration"),0.05)
									FastWait(0.05)
								end
							end
							if CurrentItem.Value:GetAttribute("Ammo") then
								if CurrentItem.Value:GetAttribute("Ammo") <= 0 and (not CurrentItem.Value:GetAttribute("Clicked")) then
									if (CurrentItem.Settings.animSounds["Click"]) then
										CurrentItem.Value:SetAttribute("Clicked", true)
										CurrentItem:playSound("Click")
									end
									return
								end
							elseif CurrentItem.Value:GetAttribute("Grenades") then
								if (not CurrentItem.Value:FindFirstChild("Grenade")) and (not CurrentItem.Value:GetAttribute("Clicked")) then
									if (CurrentItem.Settings.animSounds["Click"]) then
										CurrentItem.Value:SetAttribute("Clicked", true)
										CurrentItem:playSound("Click")
									end
									return
								end
							end
							
							CurrentItem.FiringSystem:runMode(CurrentItem.firingApi,(i.UserInputType == Enum.UserInputType.MouseButton3 or (InputComp.GetSchemeMode("Gun") == 2 and InputComp:IsInputDown(Enum.KeyCode.ButtonR3))) and CurrentItem.Settings.workingBarrels or 1)
							if CurrentItem.Value:FindFirstChild("TriggerEffector") then
								if CurrentItem.Value.TriggerEffector:FindFirstChild("TriggerHinge") then
									tween("Joint",CurrentItem.Value.TriggerEffector.TriggerHinge,nil,CF.ANG(0,RAD(0),0),getAlpha("Deceleration"),0.05)
									FastWait(0.05)											
								end		
							end	
							CurrentItem:disableLinks()
						end
					end
				end,
			};
			AsyncActions = {
				CreateLaserDot = ch.CreateLaserDot;
				CreateMagazine = ch.CreateMagazine;
				CreateCartridge = ch.CreateCartridge;
				DetachNadeMag = ch.DetachNadeMag;
				DetachRound = ch.DetachRound;
				DetachMag = ch.DetachMag;
				AttachMag = ch.AttachMag;
			};
			Hooks = {
				PreLoad = function(api, mApi)

				end,
				PreDisplay = function(api, mApi)
					if api.Item.LauncherType.Value == "Grenade" then	
						for _, part in ipairs(api.LoadoutImage.Object3D:GetChildren()) do
							if part.Name == "AimPart" then
								part:Destroy() 
							end
						end 
					end
				end,
				CanDisplayTier = function(api, mApi)
					local tier = mApi.Tier
					if mApi.Settings.acceptedSlots then
						return (not table.find(mApi.OddTiers, tier.ClassName)) 
							and ((table.find(mApi.Settings.acceptedSlots, tier.Name))
								or
								(tier.Name == "Magazines" or tier.Name == "Furnitures" or tier.Name == "Alloys")
							)

					end
					return (not table.find(mApi.OddTiers, tier.ClassName))
				end,
				Equip = function(api, mApi)
					if api.Value.LauncherType.Value == "Grenade" then
						api.Value:SetAttribute("ClipSize", 1)

					end
					mApi.tween("Joint",mApi.ViewModel.LWeld,false,api:getArmPos("unAimed","Left"), mApi.getAlpha("OutSine"), mApi.S.equipSettings.Time)
					mApi.tween("Joint",mApi.ViewModel.RWeld, false,api:getArmPos("unAimed","Right"), mApi.getAlpha("OutSine"), mApi.S.equipSettings.Time)
					mApi.tween("Joint",mApi.ViewModel.Grips.Right, false, api:getArmPos("unAimed","Grip"), mApi.getAlpha("OutSine"), mApi.S.equipSettings.Time)
				end,
				Aimed = function(api, mApi)
					local partlist = {
						mApi.ViewModel.armModel;
						mApi.ViewModel.playerFolder;
					}
					_G.HM:PerformCMAction("RunScopeJob", "ToggleWithItems", true, partlist)
					for _, v in ipairs(mApi.Character:GetDescendants()) do
						if v ~= v:FindFirstAncestorOfClass("Model").PrimaryPart then
							if v:IsA("BasePart") then
								v.LocalTransparencyModifier = 1
							elseif v:IsA("RopeConstraint") then
								v.Visible = false	
							end
						end
					end
				end,
				PostDisplay = function(api, mApi)
					local AttachmentMods = mApi.AttachmentMods
					local RemoteService = mApi.RemoteService
					local AttachmentsList = mApi.AttachmentsList
					local CF = mApi.CF
					for _, slot in ipairs(AttachmentMods.Slots) do
						local attachmentStub = RemoteService.fetch("Server","GetAttachmentSlot",api.Item.Name,slot)
						if attachmentStub then
							local attachmentStub2 = api:GetAttachmentFromCache(api.Item,slot) 
							if not attachmentStub2 then
								attachmentStub2 = {
									Name = attachmentStub.Name;
									Slot = slot;
									CFrame = CFrame.new();
								};
								api:SetAttachmentSlotCC(api.Item, attachmentStub2, slot, attachmentStub.CFrame)
							end
							if typeof(attachmentStub) == "table" then
								attachmentStub = attachmentStub.Name
							end
							if attachmentStub == "" then continue end
							local newAttachment = AttachmentsList[attachmentStub]
							newAttachment:AddWeapon(api.Item.Name,CF(),nil)
							if ((not api.Item:FindFirstChild("Lid")) or newAttachment.Slot ~= "Optics")  then
								newAttachment:Apply(api.LoadoutImage.Object3D,"HoldPart")
							elseif api.Item:FindFirstChild("Lid") then
								newAttachment:Apply(api.LoadoutImage.Object3D,"Lid")
							end
						end
					end
					if api.Item.LauncherType.Value == "Pistol" or api.Item.LauncherType.Value == "MachinePistol"  or api.Item.LauncherType.Value == "Revolver" then	
						for _, part in ipairs(api.LoadoutImage.Object3D:GetChildren()) do
							if part.Name == "AimPart" then
								part:Destroy() 
							end
						end 
					end
				end,
				PreUnAim = function(api, mApi)
					_G.HM:PerformCMAction("RunScopeJob", "ToggleWithItems", false, {
						mApi.ViewModel.armModel;
						mApi.ViewModel.playerFolder;
						api.Value;
						api.Value:FindFirstChild("Magazine");
						api.Value:FindFirstChild("MagPoint");
					})

					for _, v in ipairs(mApi.Character:GetDescendants()) do
						if v ~= v:FindFirstAncestorOfClass("Model").PrimaryPart then
							if v:IsA("BasePart") then
								if (not v:IsDescendantOf(mApi.Character)) and (not v:IsDescendantOf(api.Value)) then
									v.LocalTransparencyModifier = 0
								elseif (v:FindFirstChild("ArmPart"))  then
									v.LocalTransparencyModifier = 0
								elseif (v:IsDescendantOf(mApi.Character:FindFirstChild("FakeArms"))) then
									v.LocalTransparencyModifier = 0
								end
							elseif v:IsA("RopeConstraint") then
								v.Visible = true	
							end
						end
					end
				end,
				Unaimed = function(api, mApi)
					_G.HM:PerformCMAction("RunScopeJob", "ToggleWithItems", false, {
						mApi.ViewModel.armModel;
						mApi.ViewModel.playerFolder;
						api.Value;
					})
					_G.HM:SetContextUIEnabled(true)
				end,
				SpecialReload = function(api, mApi)
					api:PlayAnimation("Reload",true)
					mApi.animCancel:Reset("Reload")

					api.Value:SetAttribute("Clicked", false)
					api:ResetShotCount()
				end,
			};
			Projectile = {

			};
		};
		["Melee"] = {
			Name = "Melee";
			SubTypeName = "Melee";
			HUD = { 
				InitContext = function(hudObj)
					local obj = PseudoInstance.new("MeleeCM")
					obj:Setup(hudObj.UI.meleeUI)
					return obj
				end,
			};
			Animation = {
				poseName = "stance";
				animCF = function(animTab,dt,...)
					local aC0, aC1 = animTab.CF.RAW(animTab.aimHeadOffset,0,0) * animTab.CF.ANG(
					(animTab.gunRecoilSpring.p.X + animTab.AnimRot.X)* animTab.stanceSway ,
					( animTab.gunRecoilSpring.p.Y +  animTab.AnimRot.Y)* animTab.stanceSway ,
					( animTab.gunRecoilSpring.p.Z + animTab.AnimRot.Z) * animTab.stanceSway 
					) * animTab.CF.RAW( 
						(animTab.recoilAnim.Pos.X + animTab.AnimPos.X) * animTab.stanceSway ,
						(animTab.recoilAnim.Pos.Y + animTab.AnimPos.Y)* animTab.stanceSway ,
						(animTab.recoilAnim.Pos.Z + animTab.AnimPos.Z) * animTab.stanceSway 
					),animTab.CF.ANG(-animTab.CameraAng.Y * animTab.crawlAlpha / 90, 0, 0) * animTab.CF.RAW(0,-1,0);
					if (animTab.currentState == "Running" or animTab.currentState == "Walking") and not animTab.Aimed then
						local wsp = animTab.walkSpeedSpring.p
						aC0 = aC0 * animTab.gunbob(animTab.walkAnimName ,.25 *  wsp/animTab.bWS,.5 * wsp/animTab.bWS,dt)
					elseif not animTab.Aimed and (not animTab.isPlayingAnim()) then
						local idleAng2 = animTab.idleAng + animTab.RAD(105 * dt) * animTab.stanceSway
						aC0 = aC0 * animTab.Lerps.CFrame(animTab.CF.RAW(),animTab.gunbobIdle(idleAng2,dt),LERP_IDLE_THRESH)

						animTab.setIdleAng(idleAng2)
					end
					return aC0, aC1
				end;	
			};
			Capabilities = {
				"HandSwitch";
				"IdleEquip";
				"MainMelee";
				"AITrigger";

			};
			Input = {
				Scheme = "Melee";
				Activate = function(player, item, api, ...)
					local CurrentItem = api.CurrentItem
					local input = api.input
					if CurrentItem.Equipped then
						
							if input.UserInputType == Enum.UserInputType.MouseButton1 or input.KeyCode == Enum.KeyCode.ButtonL2 then
								CurrentItem:makeAMove(CurrentItem.Settings.leftMove or "SlashLeft")
							elseif input.UserInputType == Enum.UserInputType.MouseButton2 or input.KeyCode == Enum.KeyCode.ButtonR2 then
								CurrentItem:makeAMove("SlashRight")	
							elseif input.UserInputType == Enum.UserInputType.MouseButton3 or input.KeyCode == Enum.KeyCode.ButtonL3 then
								CurrentItem:makeAMove(CurrentItem.Settings.leftMove or "SlashForward")
							elseif input.UserInputType == Enum.UserInputType.Touch then
								CurrentItem:makeAMove(CurrentItem.Settings.leftMove or "SlashLeft")
							end						
					end
				end,
			};
			Hooks = {
				PreLoad = function(api, mApi)
					api:OverridePos("stance1H", "stance")
				end,
				CanDisplayTier = function(api, mApi)
					return false
				end,
			};
		};
		["Grenade"] = {
			Name = "Grenade";
			SubTypeName = "Grenade";
			Statistics = {
				["ExplosiveRadius"] = {
					Title = "Blast Radius";
					Process = function(item, sett, api)
						local radius = math.floor(sett.grenadeSettings.Radius)
						return radius .. " studs"
					end,
				};
				["DetType"] = {
					Title = "Detonation Type";
					Process = function(item, sett, api)
						return sett.detMode:upper()
					end,
				};
				["FuseTimer"] = {
					Title = "Fuse Time";
					Process = function(item, sett, api)
						local t = math.floor(sett.grenadeSettings.detonationSettings.Time)
						return if sett.detMode == "fuse" then t .. "s" else "N/A"
					end,
				};
			};
			Input = {
				Scheme = "Grenade";
				Activate =  function(player, item, api, ...)
					local CurrentItem = api.CurrentItem
					local RemoteService = api.RemoteService
					local runAsync = api.runAsync;
					local loadoutCache = api.loadoutCache;
					local ViewModel = api.ViewModel;
					local tween = api.tween;
					local getAlpha = api.getAlpha;
					if CurrentItem.Equipped then
						if not api.Throwing then
							api.setThrowing(true)
							CurrentItem:PlayAnimation("Throwing",false);
							RemoteService.send("Server","DiscardNade",CurrentItem.Value)
							runAsync(function()
								local nextWeapon = loadoutCache.Loadout[2]
								RemoteService.send("Server","UnequipItems")
								local newS = Resources:LoadItemConfig(nextWeapon.Name)
								tween("Joint",ViewModel.LWeld,false,newS.equipSettings.leftArmC1,getAlpha("Standard"),0.2)
								tween("Joint",ViewModel.RWeld,false,newS.equipSettings.rightArmC1,getAlpha("Standard"),0.2)										
								RemoteService.send("Server","EquipItem",nextWeapon)
							end)									
							api.setThrowing(false)
						end
					end
				end,
			};
			Animation = {
				poseName = "regular";
				animCF = function(animTab,dt)
					local aC0, aC1 = animTab.CF.RAW(), animTab.CF.ANG(-animTab.CameraAng.Y * animTab.crawlAlpha / 90, 0, 0) * animTab.CF.RAW(0,-1,0);
					if (animTab.currentState == "Running" or animTab.currentState == "Walking") and not animTab.Aimed then
						local wsp = animTab.walkSpeedSpring.p
						aC0 = aC0 * animTab.gunbob(animTab.walkAnimName ,.25 *  wsp/animTab.bWS,.5 * wsp/animTab.bWS,dt)
					elseif not animTab.Aimed and (not animTab.isPlayingAnim()) then
						local idleAng2 = animTab.idleAng + animTab.RAD(105 * dt) * animTab.stanceSway
						aC0 = aC0 * animTab.Lerps.CFrame(animTab.CF.RAW(),animTab.gunbobIdle(idleAng2,dt),LERP_IDLE_THRESH)

						animTab.setIdleAng(idleAng2)
					end
					return aC0, aC1
				end;
			};
			Actions = {
				ChangeSmokeColor = function(player, grenade, api, color)
					if grenade then
						if grenade:FindFirstChild("GrenadeType") then
							if grenade.GrenadeType.Value ~= "Smoke" then
								return
							end
							local S = require(grenade.SETTINGS)
							if S.canCustomizeColor then
								local cv = SMOKE_NADE_COLOR_NAMES
								if S.smokeValues then
									table.clear(cv)
									for i, val in S.smokeValues do 
										table.insert(cv, i, val.Name)
									end
								end
								if table.find(cv, color) then
									if not workspace:FindFirstChild(player.Name) then
										api.changeGrenadeColor(grenade, BrickColor.new(color))
									end
								end
							end
						end
					end
				end,
			};
			Capabilities = {
				"Stored";
				"AITossable";
			};
			Hooks = {
				PreLoad = function(api, mApi)

				end,
				PostDisplay = function(api, mApi)
					local RunService = mApi.RunService
					api.LoadoutImage:SetDepthMultiplier(1.5)
				end,
				CanDisplayTier = function(api, mApi)
					local tier = mApi.Tier
					return tier.ClassName == "GrenadeTier" 
				end,
			};
			Projectile = {

			};
		};
    };
};

return itemTypes;