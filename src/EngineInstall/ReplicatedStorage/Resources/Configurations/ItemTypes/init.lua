local Resources = require(game.ReplicatedStorage.Resources)
local PseudoInstance = Resources:LoadLibrary("PseudoInstance") 
local CartridgeList = Resources:LoadConfiguration("Cartridge") 
local Attachment = Resources:LoadLibrary("Attachment")
local AttachmentsList = Resources:LoadConfiguration("Attachment")

local ch = require(script.CommonHooks)
local SMOKE_NADE_COLOR_NAMES = {"Bright red";BrickColor.White().Name;"Bright orange";"Bright yellow";"Bright green";"Bright blue";"Dark indigo";"Bright violet";}
local LERP_IDLE_THRESH = 0.15
local PRE_ASSEMBLE_SLOTS = {
	"Optics",
	"Barrel",
	"Underbarrel",
	"Other",
}
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
				"Aggregate";
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
				OnServerEquip = function(api, mApi)
					local item = api.Item
					local plr = mApi.Player
					for _, v in (item:GetDescendants()) do
						if v:IsA("BasePart") and not v:FindFirstAncestor("Magazine") then
							v.Anchored = true
						end
					end
					if not mApi.furnitures[item.Name] then
						mApi.furnitures[item.Name] = {
							furniture = "";
							alloy = "";
						}
					end		
					if mApi.AttachmentLibrary[item.Name] then
						for  _, slot2 in PRE_ASSEMBLE_SLOTS do
							local attObj = AttachmentsList[mApi.AttachmentLibrary[item.Name][slot2].Name]
							if attObj then
								Attachment.ClearWeaponSlot(item, plr, slot2, attObj.Type)
							end
						end
					end
					local boltWelds do
						local assembler = PseudoInstance.new("GunAssembler")
						assembler:Assemble(item, {
							attachments = mApi.AttachmentLibrary[item.Name];
							furniture = mApi.furnitures[item.Name].furniture;
							alloy = mApi.furnitures[item.Name].alloy;									
							player = plr;
						})
						boltWelds = assembler.BoltWelds 
						assembler:Destroy()
						assembler = nil
					end
					mApi.RemoteService.send("Client",plr,"SetupBolts",boltWelds,item)
					item.HoldPart.Anchored = false
					item.HoldPart.CanCollide = true

					pcall(function()
						local SET = require(item.SETTINGS)
						mApi.Grips.Right.Part1 = item.HoldPart
						mApi.Grips.Right.C1 = SET.equipSettings.GripC1
						if item:FindFirstChild("DmgPoint",true) and item.Type.Value == "Gun" then
							print("Bayonet Detected")
							mApi.setBayonet(item, mApi.Melee:AddWeaponS(item,plr))
						end
					end)
					if not item:GetAttribute("FireMode") then
						local S = require(item.SETTINGS)
						item:SetAttribute("FireMode", S.defaultMode:upper())
					end
					--local unitO = PseudoInstance.new(plr:GetAttribute("Unit"))
					local S = require(item.SETTINGS)
					if not mApi.MagazineLibrary[item.Name] then
						local UsableMags = S.reloadSettings
						if UsableMags then
							UsableMags = UsableMags.usableMags
							if UsableMags then
								mApi.setMagazine(plr, item, UsableMags[1])
							end
						end
					end
					local mag = mApi.MagazinesList[mApi.MagazineLibrary[item.Name]]
					--local unit = plr:GetAttribute("Unit")
					--local unitO = PseudoInstance.new(unit)
					mag:UpdateMetadata(item,unitO,mApi.InventoryService,plr,mApi.Character)
					if item:FindFirstChild("Grenade") then
						mag:reassembleGrenade(item)
					end
					if S.reloadSettings.attachMagOnServer then
						local mag2 = mag:getMag(true)
						if mag2 then
							mag:Apply(item,mag2)
						end
					end
				mApi.Character:SetAttribute("walkPenalty",item:GetAttribute("Penalty") + (item:GetAttribute("UnitPenalty") or 0))
					mApi.Janitor:Add(item:GetAttributeChangedSignal("Penalty"):Connect(function()
						mApi.Character:SetAttribute("walkPenalty",item:GetAttribute("Penalty") + (item:GetAttribute("UnitPenalty") or 0))
					end),"Disconnect",plr.Name.."WalkPenCon")
					do
						local SET = require(item.SETTINGS)
						if SET then
							if SET.barrelOverheat then
								item:SetAttribute("Heat",0)
							end
						end
					end

					if mApi.AttachmentLibrary[item.Name] then
						for k, v in pairs(mApi.AttachmentLibrary[item.Name]) do
							if v.Name ~= "" then
								local att = Resources:GetGunAttachment(v.Name)
								if att then
									local anims = att:FindFirstChild("ANIMATIONS")
									if anims then
										item:SetAttribute(k.."Anims",anims.Parent.Name)
									elseif att:FindFirstChild("POSES") then
										item:SetAttribute(k.."Poses",att.Name)
									end
								end
								local att2 = AttachmentsList[v.Name]
								if att2 then
									if att2.Type:find("Laser") then
										item:SetAttribute("LaserIndex", 0)	
										game.CollectionService:AddTag(item,"LasersOn")
										item:SetAttribute("LaserType", att2.ExtraData.LaserType or "Regular");
									end
								end
							end
						end
						if mApi.AttachmentLibrary[item.Name].Underbarrel.Name then
							local atName = mApi.AttachmentLibrary[item.Name].Underbarrel.Name
							if atName then
								local att = AttachmentsList[atName]
								if att then
									if att.Type == "GrenadeLauncher" then
										if not item:GetAttribute("Grenades") then
											for i = 1, 8 * (unitO.UnderslungGM or 1) do
												--_G.Inventories[plr]:AddItem(att.ExtraData.Caliber)
											end

											item:SetAttribute("Grenades",8 * (unitO.UnderslungGM or 1))
											item:SetAttribute("GrenadesReady",true)
											item:SetAttribute("CurrentGrenade",att.ExtraData.Caliber)

										end
									end
								end
							end
						end
					end
					for _, vp in  item:GetChildren() do
						if vp:FindFirstChild("FireSound") then
							local c = mApi.Cartridges[mag.CartridgeName]
							vp.FireSound.SoundGroup = game.SoundService.SettingSounds.Game_FX
							vp.FireSound.RollOffMinDistance = (c.Range / 10) + 1
							vp.FireSound.RollOffMaxDistance = (c.Range / 10) + 1
							if vp:FindFirstChild("EchoSound") then
								vp.EchoSound.SoundGroup = game.SoundService.SettingSounds.Game_FX
								vp.EchoSound.RollOffMaxDistance = c.Range * 2
								vp.EchoSound.RollOffMinDistance = (c.Range / 5)
							end
						end	
					end
					local itemSettings = require(item.SETTINGS)

					item.FOV.Value = itemSettings.aimSettings.InFOV
					if mApi.AttachmentLibrary[item.Name] then
						local OpticsAttachment = mApi.AttachmentLibrary[item.Name]["Optics"].Name
						if (#OpticsAttachment > 0) then
							local att = AttachmentsList[OpticsAttachment] 
							item.FOV.Value = att.ExtraData.FOV or itemSettings.aimSettings.InFOV

							--local uiReady = mApi.RemoteService.fetch("Client",plr,"WaitForHC")
							--mApi.RemoteService.send("Client",plr,"SetScopeId",att.ExtraData.Scope)
						else
							item.FOV.Value = itemSettings.aimSettings.InFOV
							--mApi.RemoteService.send("Client",plr,"SetScopeId","")
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
				"Aggregate";
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
				OnServerEquip = function(api, mApi)
					local item = api.Item
					local plr = mApi.Player
					for _, v in (item:GetDescendants()) do
						if v:IsA("BasePart") and not v:FindFirstAncestor("Magazine") then
							v.Anchored = true
						end
					end
					if not mApi.furnitures[item.Name] then
						mApi.furnitures[item.Name] = {
							furniture = "";
							alloy = "";
						}
					end		
					if mApi.AttachmentLibrary[item.Name] then
						for  _, slot2 in PRE_ASSEMBLE_SLOTS do
							local attObj = AttachmentsList[mApi.AttachmentLibrary[item.Name][slot2].Name]
							if attObj then
								Attachment.ClearWeaponSlot(item, plr, slot2, attObj.Type)
							end
						end
					end
					local boltWelds do
						local assembler = PseudoInstance.new("GunAssembler")
						assembler:Assemble(item, {
							attachments = mApi.AttachmentLibrary[item.Name];
							furniture = mApi.furnitures[item.Name].furniture;
							alloy = mApi.furnitures[item.Name].alloy;									
							player = plr;
						})
						boltWelds = assembler.BoltWelds 
						assembler:Destroy()
						assembler = nil
					end
					mApi.RemoteService.send("Client",plr,"SetupBolts",boltWelds,item)
					item.HoldPart.Anchored = false
					item.HoldPart.CanCollide = true

					pcall(function()
						local SET = require(item.SETTINGS)
						mApi.Grips.Right.Part1 = item.HoldPart
						mApi.Grips.Right.C1 = SET.equipSettings.GripC1
						if item:FindFirstChild("DmgPoint",true) and item.Type.Value == "Gun" then
							print("Bayonet Detected")
							mApi.setBayonet(item, mApi.Melee:AddWeaponS(item,plr))
						end
					end)
					if not item:GetAttribute("FireMode") then
						local S = require(item.SETTINGS)
						item:SetAttribute("FireMode", S.defaultMode:upper())
					end
					local unitO = PseudoInstance.new(plr:GetAttribute("Unit"))
					if item.LauncherType.Value == "Grenade" then
						if not item:GetAttribute("GrenadeSet") then
							item:SetAttribute("GrenadeSet", true)
							local S = require(item.SETTINGS)
							item:SetAttribute("CurrentGrenade", S.reloadSettings.usableGrenade)
							item:SetAttribute("Grenades", 20)
							item:SetAttribute("MagType", item:GetAttribute("CurrentGrenade"))
							item:SetAttribute("GrenadesReady",true)

						end
						if item:FindFirstChild("Grenade") then
							item:SetAttribute("GrenadesReady",true)
						end 
					else
						local mag = mApi.MagazinesList[api.MagazineLibrary[item.Name]]
						local S = require(item.SETTINGS)
						local unit = plr:GetAttribute("Unit")
						local unitO = PseudoInstance.new(unit)
						if item:FindFirstChild("Grenade") then
							mag:reassembleGrenade(item)
						end
						mag:UpdateMetadata(item,unitO,mApi.InventoryService,plr,mApi.Character)

						if S.reloadSettings.attachMagOnServer then
							local mag2 = mag:getMag(true)
							if mag2 then
								mag:Apply(item,mag2,plr)
							end
						end
						mApi.Character:SetAttribute("walkPenalty",item:GetAttribute("Penalty") + item:GetAttribute("UnitPenalty"))
						mApi.Janitor:Add(item:GetAttributeChangedSignal("Penalty"):Connect(function()
							mApi.Character:SetAttribute("walkPenalty",item:GetAttribute("Penalty") + item:GetAttribute("UnitPenalty"))
						end),"Disconnect",plr.Name.."WalkPenCon")
						do
							local SET = require(item.SETTINGS)
							if SET then
								if SET.barrelOverheat then
									item:SetAttribute("Heat",0)
								end
							end
						end
						if mApi.AttachmentLibrary[item.Name] then
							for k, v in pairs(mApi.AttachmentLibrary[item.Name]) do
								if v.Name ~= "" then
									local att = Resources:GetGunAttachment(v.Name)
									if att then
										local anims = att:FindFirstChild("ANIMATIONS")
										if anims then
											item:SetAttribute(k.."Anims",anims.Parent.Name)
										elseif att:FindFirstChild("POSES") then
											item:SetAttribute(k.."Poses",att.Name)
										end
									end
									local att2 = AttachmentsList[v.Name]
									if att2 then
										if att2.Type:find("Laser") then
											item:SetAttribute("LaserIndex", 0)	
											game.CollectionService:AddTag(item,"LasersOn")
											item:SetAttribute("LaserType", att2.ExtraData.LaserType or "Regular");
										end
									end
								end
							end
							if mApi.AttachmentLibrary[item.Name].Underbarrel.Name then
								local atName = mApi.AttachmentLibrary[item.Name].Underbarrel.Name
								if atName then
									local att = AttachmentsList[atName]
									if att then
										if att.Type == "GrenadeLauncher" then
											if not item:GetAttribute("Grenades") then
												for i = 1, 8 * (unitO.UnderslungGM or 1) do
													_G.Inventories[plr]:AddItem(att.ExtraData.Caliber)
												end
												item:SetAttribute("Grenades",8 * (unitO.UnderslungGM or 1))
												item:SetAttribute("GrenadesReady",true)
												item:SetAttribute("CurrentGrenade",att.ExtraData.Caliber)

											end
										end
									end
								end
							end
						end
						for _, vp in  item:GetChildren() do
							if vp:FindFirstChild("FireSound") then
								vp.FireSound.SoundGroup = game.SoundService.SettingSounds.Game_FX
								vp.EchoSound.SoundGroup = game.SoundService.SettingSounds.Game_FX
								local c = mApi.Cartridges[mag.CartridgeName]
								vp.FireSound.RollOffMinDistance = (c.Range / 20) + 1
								vp.FireSound.RollOffMaxDistance = (c.Range / 10) + 1
								vp.EchoSound.RollOffMaxDistance = c.Range * 2
								vp.EchoSound.RollOffMinDistance = (c.Range / 10) + 1
							end	
						end
					end
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
				OnServerEquip =  function(api, mApi)
					local item = api.Item
					local plr = mApi.Player
					do
						local assembler = PseudoInstance.new("BladeAssembler")
						assembler:Assemble(item, {
						})
						assembler:Destroy()
						assembler = nil
					end
					item.HoldPart.Anchored = false
					item.HoldPart.CanCollide = true
					local _, err = pcall(function()
						local SET = require(item.SETTINGS)
						mApi.Grips.Right.Part1 = item.HoldPart
						mApi.Grips.Right.C1 = SET.equipSettings.GripC1
					end)
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
				OnServerEquip =  function(api, mApi)
					local item = api.Item
					local plr = mApi.Player
					do
						local assembler = PseudoInstance.new("GrenadeAssembler")
						assembler:Assemble(item, {
						})
						assembler:Destroy()
						assembler = nil
					end
					item.HoldPart.Anchored = false
					item.HoldPart.CanCollide = true
					local _, err = pcall(function()
						local SET = require(item.SETTINGS)
						mApi.Grips.Right.Part1 = item.HoldPart
						mApi.Grips.Right.C1 = SET.equipSettings.GripC1
					end)
				end,
			};
			Projectile = {

			};
		};
    };
};

return itemTypes;