local Resources = require(game.ReplicatedStorage.Resources)
local EventUtils = Resources:LoadLibrary("EventUtils")

local CommonHooks = {};

CommonHooks.CreateLaserDot =  function(player, item, api, color)
	local item = api.PlayerLoadouts[player].CurrentWeapon
	if item then
		if item:GetAttribute("LaserIndex") then
			local laserDot = Instance.new("Part")
			laserDot.Transparency = 0
			laserDot.Name = "laserDot"
			laserDot.Material = Enum.Material.Neon
			laserDot.Anchored = false
			laserDot.Shape = Enum.PartType.Ball
			laserDot.Color  = color
			laserDot.CanCollide = false
			laserDot.Size = Vector3.new(0.1, 0.1, 0.1)
			laserDot:SetNetworkOwner(player)
			laserDot.Anchored = true
			return laserDot
		end
	end
end

CommonHooks.CreateMagazine = function(player, item, api, magType)
	local mag = api.MagazinesList[magType]
	if mag then
		mag = mag:getMag(true, player)
		mag.Parent = player
	end
	return mag
end

CommonHooks.Toss = function(player, item, api, waitTime)
	local c do
		if player:IsA("Player") then
			c = player.Character 
		else
			c = player
		end
	end
	if item.Parent == c then
		waitTime = math.clamp(waitTime or 2, 2, 5)
		c["Right Arm"].RightGrip.Part1 = nil
		item.Parent = workspace.LootIgnore
		for _, v in item:GetDescendants() do
			if v:IsA("BasePart") then
				if v:CanSetNetworkOwnership() then
					v.CanCollide = true
					v:SetNetworkOwner(nil)
				end
			end
		end
		local m = 0
		for _, v in item:GetDescendants() do
			if v:IsA("BasePart") then
				if v.Transparency ~= 1 then
					m += v.Mass
				end
			end
		end
		item:SetPrimaryPartCFrame(item:GetPivot() + (c.PrimaryPart.CFrame.LookVector))
		item.PrimaryPart:ApplyImpulse(c.PrimaryPart.CFrame.LookVector.Unit * ((m/7) * 1000))
		task.delay(waitTime * 0.25, function()
			api.RemoteService.bounceU("Client","PlayItemSound", item, "Drop",1 ,1)
		end)
		task.delay(waitTime * 1.5, function()
			item:Destroy()
		end)
		if player:IsA("Player") then
			api.RemoteService.send("Client",player,"InitLoadoutData", api.PlayerLoadouts[player].CurrentItems)
			api.RemoteService.send("Client",player,"EquipWeaponClient",2,true)
		end
		
	end
end

CommonHooks.CreateCartridge = function(player, item, api, magType)
	local mag = api.MagazinesList[magType]
	if mag then
		mag = mag:getRound(true)
		mag.Parent = player
	end
	return mag
end

CommonHooks.AddBarrelHeat = function(player, item, api)
	if not item then return end
	local S = require(item.SETTINGS)
	if S then
		if S.barrelOverheat then
			if item:GetAttribute("Heat") then
				item:SetAttribute("Heat",item:GetAttribute("Heat") + S.overheatAmt)
			end
		end
	end
end

CommonHooks.DetachNadeMag = function(player, item, api)
	return api.MagazineAPI.Detach(item,"Nade")
end

CommonHooks.DetachRound = function(player, item, api, round, index)
	local res =  api.MagazineAPI.DetachRound(item, index)
	if res and item:GetAttribute("AmmoInd") then
		local mt = api.MagazinesList[item:GetAttribute("MagType")]
		if mt then
			local c = api.Cartridges[mt.CartridgeName]
			if c then
				if mt.GaugeIndex then
					c:SetupGauge(mt.GaugeIndex)
				end
				_G.Inventories[player]:RemoveItem(c.Name)
			end
		end
	end
	return res
end

CommonHooks.DetachMag = function(player, item, api)
	return api.MagazineAPI.Detach(item)
end

CommonHooks.AttachMag = function(player, item, api, mag)
	if item:FindFirstChild("Type") then
		if item:FindFirstChild("MagPoint") then
			local S = require(item.SETTINGS)
			local magObj = api.MagazinesList[api.MagazineLibraries[player][item.Name]]
			if magObj then
				magObj:Apply(item,mag,player,S.reloadSettings.magOffsets)
			end
		end
	end
end

CommonHooks.ToggleAttachmentKey = function(player, item, api, ...)
	local CurrentItem = api.CurrentItem
	if CurrentItem.Value then
		CurrentItem.currentAttachment += 1;
		if CurrentItem.currentAttachment > #api.Adapter then
			CurrentItem.currentAttachment = 1;
		end
		local adapter = api.Adapter[CurrentItem.currentAttachment]
		if adapter and adapter.OnRun then
			adapter.OnRun(adapter,CurrentItem:getAdapterAPI());
		end	
	end
end

CommonHooks.ZoomIn = function(player, item, api, input)
	local CurrentItem = api.CurrentItem;
	local InputComp = api.InputComp;
	if CurrentItem.Equipped then
		if (CurrentItem.Aimed)  and (not input.UserInputType.Name:find("Gamepad")) then
			if InputComp:IsInputDown(Enum.KeyCode.RightShift) then
				_G.HM:AddElevation(1)
				return
			end
			CurrentItem:zoomIn()
		end
	end
end

CommonHooks.ZoomOut = function(player, item, api, input)
	local CurrentItem = api.CurrentItem;
	local InputComp = api.InputComp;
	if CurrentItem.Equipped then
		if (CurrentItem.Aimed) and (not input.UserInputType.Name:find("Gamepad")) then
			if InputComp:IsInputDown(Enum.KeyCode.RightShift) then
				_G.HM:AddElevation(-1)
				return
			end
			CurrentItem:zoomOut()
		end
	end
end




CommonHooks.ZoomUniversal = function(player, item, api, input)
	local CurrentItem = api.CurrentItem;
	local InputComp = api.InputComp;
	local ZoomModeEnabled = api.ZoomModeEnabled;

	if CurrentItem.Equipped then
		if (CurrentItem.Aimed) and not ZoomModeEnabled then
			ZoomModeEnabled = true
			local k, _  = InputComp.GamepadButtonChanged:Wait()
			if k == Enum.KeyCode.ButtonL1 then
				CurrentItem:zoomIn()
			elseif k == Enum.KeyCode.ButtonR1 then
				CurrentItem:zoomOut()
			end		
			ZoomModeEnabled = false									
		end
	end
end

CommonHooks.ElevationUp = function(player, item, api, input)
	local CurrentItem = api.CurrentItem;
	if (CurrentItem.Aimed)  and CurrentItem.Equipped then
		_G.HM:AddElevation(0.001)
		return
	end
end

CommonHooks.ElevationDown = function(player, item, api, input)
	local CurrentItem = api.CurrentItem;
	if (CurrentItem.Aimed)  and CurrentItem.Equipped then
		_G.HM:AddElevation(-0.001)
		return
	end
end

CommonHooks.AdjustSights = function(player, item, api, input)
	local CurrentItem = api.CurrentItem;
	if CurrentItem.Equipped then
		CurrentItem:AdjustSight(false);
	end
end

CommonHooks.AdjustStock = function(player, item, api, input)
	local CurrentItem = api.CurrentItem;
	local InputComp = api.InputComp;
	if CurrentItem.Equipped then
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
	end
end

CommonHooks.Reload = function(player, item, api, input)
	local CurrentItem = api.CurrentItem;
	local InputComp = api.InputComp;
	local CharState = api.CharState
	if CurrentItem.Equipped then
		if (not CurrentItem:IsPlayingAnim()) and ( CharState.currentState ~= "Crawling") then
			print("ReloadExtra: ", CurrentItem.Value:GetAttribute("Ammo") == CurrentItem.Value:GetAttribute("ClipSize"))
			if CurrentItem.Value:GetAttribute("Ammo") then
				if CurrentItem.Value:GetAttribute("Ammo") == CurrentItem.Value:GetAttribute("ClipSize") then
					CurrentItem:PlayAnimation("ReloadExtra",true)
				else
					CurrentItem:Reload()
				end
			elseif CurrentItem.Value:FindFirstChild("LauncherType")  then
				if CurrentItem.Value.LauncherType.Value == "Grenade" then
					if not CurrentItem.Value:GetAttribute("GrenadesReady") then
						CurrentItem:Reload()
					end
				end
			end
			
		end
	end
end
CommonHooks.cycleSights = function(player, item, api, input)
	local CurrentItem = api.CurrentItem;
	local InputComp = api.InputComp;
	local FastWait = api.FastWait
	if CurrentItem.Equipped  then
		if CurrentItem.Aimed then
			CurrentItem:NextSight()
			FastWait(CurrentItem.Settings.aimSettings.Speed)
			InputComp.ResetSchemeMode("Gun")
		end
	end
end

CommonHooks.Inspect = function(player, item, api, input)
	local CurrentItem = api.CurrentItem;
	if CurrentItem.Equipped then
		if (not CurrentItem.Aimed) and (not CurrentItem.Inspecting) and (not CurrentItem.Reloading) then
			CurrentItem:Inspect()
		end
	end
end

CommonHooks.selectFire = function(player, item, api, ...)
	local CurrentItem = api.CurrentItem
	local ZoomModeEnabled = api.ZoomModeEnabled;
	local RemoteService = api.RemoteService;
	local Character = api.Character;
	local tween = api.tween;
	local CharState = api.CharState;
	local V3 = Vector3.new;
	local CF = api.CF;
	local getAlpha = api.getAlpha;
	local ViewModel = api.ViewModel;
	local armC0 = api.armC0;
	local RAD = api.RAD;
	local runAsync = api.runAsync
	local FastWait = api.FastWait;
	local UIS = game:GetService("UserInputService")
	if CurrentItem.FiringSystem and CurrentItem.Value then
		if ZoomModeEnabled then return end
		if CurrentItem.Settings.selectFire and CurrentItem.canSelectFire  then
			if not CurrentItem:IsPlayingAnim() then
				CurrentItem.canSelectFire = false
				if CurrentItem.FiringSystem.currentMode.Name:upper() == "BAYONET" then

					RemoteService.fetch("Server","ToggleBayonetRun")
					local isBayonetOn = Character:GetAttribute("BayonetRun")

					if CurrentItem:HasAnim("BayonetClose") then
						CurrentItem:PlayAnimation("BayonetClose",true)
					end	
					tween("Recoil",isBayonetOn and V3(-0.1,0,0) or V3(),isBayonetOn and V3(0,0,RAD(-12.5)) or V3(),getAlpha("Sharp"),0.05)

				end
				if CurrentItem:HasAnim("SelectFire")   then
					if (not UIS:IsKeyDown(Enum.KeyCode.RightAlt)) then
						CurrentItem:PlayAnimation("SelectFire",((not CurrentItem:HasAnim("SelectFireAttachment")) and (CurrentItem:NextFireMode() ~= "GRENADE") or true))

					elseif CurrentItem:HasAnim("Decock") then
						CurrentItem:PlayAnimation("Decock")
					end
				else
					CurrentItem.FiringSystem:changeMode(CurrentItem.Settings.burstSettings.Amount);
					local speedAlpha = CurrentItem.Settings.selectFireSettings.animSpeed / 0.6
					if (not CurrentItem.Aimed) and (CharState.currentState ~= "Running") and (not CharState.currentState ~= "Crawling") then
						runAsync(function()
							local sequenceTable = {
								function()
									tween("Joint", ViewModel.RWeld2, false, CF.ANG(0, RAD(5), 0), getAlpha("OutSine"), speedAlpha * 0.15)
									tween("Joint",ViewModel.LWeld, armC0[1], CF.RAW(0.1, 1, -0.3) * CF.ANG(RAD(-7), 0, RAD(-65)), getAlpha("Linear"), speedAlpha * 0.15)
									FastWait(speedAlpha * 0.2)
								end;

								function()
									tween("Joint",ViewModel.LWeld, armC0[1], CF.RAW(0.1, 1, -0.3) * CF.ANG(RAD(-10), 0, RAD(-65)), getAlpha("Linear"), speedAlpha * 0.1)
									FastWait(speedAlpha * 0.2)
								end;

								function()
									tween("Joint",ViewModel.RWeld2, false, CF.RAW(), getAlpha("OutSine"), speedAlpha * 0.2)

									tween("Joint",ViewModel.LWeld, armC0[1], CurrentItem:getArmPos("unAimed","Left"), getAlpha("OutSine"),  speedAlpha * 0.2)
									FastWait(speedAlpha * 0.2)
								end;
							}	
							do
								for _, F in ipairs(sequenceTable) do
									if CharState.currentState == "Crawling" or CharState.currentState == "Running" then
										break
									end
									F()
								end
							end
						end)
					end
				end
				if CurrentItem:HasAnim("SelectFireAttachment") and (CurrentItem.FiringSystem.currentMode.Indicator:upper() == "GRENADE" or CurrentItem.FiringSystem.getPrev().Indicator:upper() == "GRENADE") then
					CurrentItem:PlayAnimation("SelectFireAttachment",true)
				end
				if CurrentItem.FiringSystem.currentMode then

					if CurrentItem.FiringSystem.currentMode.Indicator:upper() == "GRENADE" then
						EventUtils:FireEvent("GrenadeSwitch", CurrentItem.Value)

					else
						EventUtils:FireEvent("GrenadeSwitch", false)


					end
				end
				if CurrentItem.FiringSystem.currentMode then
					if CurrentItem.FiringSystem.currentMode.Name:upper() == "BAYONET" then
						if CurrentItem:HasAnim("BayonetOpen") then
							CurrentItem:PlayAnimation("BayonetOpen",true)
						end	
						RemoteService.fetch("Server","ToggleBayonetRun")
						local isBayonetOn = Character:GetAttribute("BayonetRun")
						tween("Recoil",isBayonetOn and V3(-0.1,0,0) or V3(),isBayonetOn and V3(0,0,RAD(-12.5)) or V3(),getAlpha("Sharp"),0.05)
						if CurrentItem.Settings.defaultHand then
							CurrentItem.Hand = CurrentItem.Settings.defaultHand
							_G.HM:PerformCMAction("ShowHand", CurrentItem.Hand)
						end
					end
				end
				CurrentItem.canSelectFire = true
			end
		end
	end

end



return CommonHooks;