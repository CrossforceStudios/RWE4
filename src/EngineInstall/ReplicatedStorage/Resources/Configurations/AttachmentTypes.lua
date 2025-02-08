return {
	["Optics"] = {
		Slot = "Optics";
		Init = function(att,args)
			att.BlackScope =  args[7] or false
		end,
		processOriginal = function(att,delete,weapon,Settings,sightRange,sightRange2)
			for i=1,#delete do
				if (delete[i].Name=="AimPart" and not delete[i]:FindFirstChild("Stay")) then
					if delete[i]:FindFirstChild("AimOrder") then
						if delete[i].AimOrder.Value == sightRange or (((sightRange > sightRange2) and (delete[i].AimOrder.Value < sightRange)) and delete[i]:GetAttribute("SightSlot") == att.Type) then
							delete[i].Name = "AimPart_Old";
						end
					end
				elseif (delete[i].Name=="AimPart" and Settings.noKeepSight ) then
					if delete[i]:FindFirstChild("AimOrder") then
						if table.find(Settings.noKeepSight, att.Name) then
							delete[i].Name = "AimPart_Old";
						end
					end
				elseif delete[i].Name == "ScopeRet" then
					delete[i].Name = "ScopeRet_Old"
				elseif delete[i].Name == "OpticBlock" and att.ExtraData.HasOpticBlock then
					delete[i].Transparency = 1;
				elseif (delete[i].Name:find("MainSight") or delete[i].Name:find("LidPartMainSight") or delete[i].Name:find("LidPartMainReticle")) and (not delete[i]:FindFirstChild("Stay")) then
					if not Settings.mainSightIsKept then
						if delete[i].Transparency ~= 0 then
							local OrigTrans = Instance.new("NumberValue")
							OrigTrans.Name = "OriginalTrans" 
							OrigTrans.Value = delete[i].Transparency
							OrigTrans.Parent = delete[i]
						end						
						delete[i].Transparency = 1
						if delete[i]:FindFirstChildOfClass("Decal") then
							delete[i]:FindFirstChildOfClass("Decal").Transparency = 1
						end
						if delete[i]:FindFirstChildOfClass("Texture") then
							for _, texture in ipairs(delete[i]:GetChildren()) do
								if texture:IsA("Texture") then
									texture.Transparency = delete[i].Transparency
								end
							end
						end	
					end
				end
			end
			if att.ExtraData.FOV then
				weapon.FOV.Value = att.ExtraData.FOV
			end
		end,
		OnClearSlot = function(weapon,slot,cName)
			for _, part in (weapon:GetChildren()) do
				if (part:FindFirstChild("AttachmentJointRef") and part:HasTag(slot)) or part:HasTag("Rail_" .. cName) then
					part:Destroy()
				elseif part.Name:find("MainSight") then
					if part.Name == "MainSightEffector" then
						continue
					end
					if part.Name == "MainSightHinge" and part.Transparency == 1 then
						continue
					end
					if part.Name == "MainSightTurntable" and part.Transparency == 1 then
						continue
					end
					if part:GetAttribute("Hide") then
						continue
					end
					part.Transparency = part:FindFirstChild("OriginalTrans") and part.OriginalTrans.Value or 0
					if part.Name == "MainSightGlass" then
						part.Transparency = 0.75
					end
					if part:FindFirstChildOfClass("Decal") then
						part:FindFirstChildOfClass("Decal").Transparency = 1
					end
				elseif part.Name == "AimPart_Old" then
					part.Name = "AimPart"
				elseif part.Name == "FrontLensCap"  and game.CollectionService:HasTag(part,slot) then
					part:Destroy()
				elseif part.Name == "FrontLensHinge"  and game.CollectionService:HasTag(part,slot) then
					part:Destroy()	
				elseif part.Name == "FrontLensEffector"  and game.CollectionService:HasTag(part,slot) then
					part:Destroy()	
				elseif (part.Name == "AimPart" or part.Name == "ScopeRet") and game.CollectionService:HasTag(part,slot) then
					part:Destroy()
				end
			end
			
		end,
	};
	["LaserOptics"] = {
		Slot = "Optics";
		processOriginal = function(att,delete,weapon,Settings,sightRange,sightRange2)
			for i=1,#delete do
				if (delete[i].Name=="AimPart" and not delete[i]:FindFirstChild("Stay")) then
					if delete[i]:FindFirstChild("AimOrder") then
						if delete[i].AimOrder.Value == sightRange or (((sightRange > sightRange2) and (delete[i].AimOrder.Value < sightRange))  and delete[i]:GetAttribute("SightSlot") == att.Type) then
							delete[i].Name = "AimPart_Old";
						end
					end
				elseif delete[i].Name == "ScopeRet" then
					delete[i].Name = "ScopeRet_Old"
				elseif delete[i].Name:find("MainSight") or delete[i].Name:find("LidPartMainSight") or delete[i].Name:find("LidPartMainReticle") then
					if not Settings.mainSightIsKept then
						if delete[i].Transparency ~= 0 then
							local OrigTrans = Instance.new("NumberValue")
							OrigTrans.Name = "OriginalTrans" 
							OrigTrans.Value = delete[i].Transparency
							OrigTrans.Parent = delete[i]
						end						
						delete[i].Transparency = 1
						if delete[i]:FindFirstChildOfClass("Decal") then
							delete[i]:FindFirstChildOfClass("Decal").Transparency = 1
						end
					end
				end
			end
			if att.ExtraData.FOV then
				weapon.FOV.Value = att.ExtraData.FOV
			end
			for i=1,#delete do
				if (delete[i].Name=="Laser" and not delete[i]:FindFirstChild("Stay")) then
					delete[i]:Destroy()
				end
			end			
		end,
		OnClearSlot = function(weapon,slot,cName)
			for _, part in ipairs(weapon:GetChildren()) do
				if (part:FindFirstChild("AttachmentJointRef") and part:HasTag(slot)) or part:HasTag("Rail_" .. cName) then
					part:Destroy()
				elseif part.Name:find("MainSight") then
					if part.Name == "MainSightEffector" then
						continue
					end
					if part.Name == "MainSightHinge" and part.Transparency == 1 then
						continue
					end
					if part.Name == "MainSightTurntable" and part.Transparency == 1 then
						continue
					end
					if part:GetAttribute("Hide") then
						continue
					end
					part.Transparency = part:FindFirstChild("OriginalTrans") and part.OriginalTrans.Value or 0
					if part.Name == "MainSightGlass" then
						part.Transparency = 0.75
					end
					if part:FindFirstChildOfClass("Decal") then
						part:FindFirstChildOfClass("Decal").Transparency = 1
					end
				elseif part.Name == "AimPart_Old" then
					part.Name = "AimPart"
				elseif part.Name == "FrontLensCap"  and game.CollectionService:HasTag(part,slot) then
					part:Destroy()
				elseif part.Name == "FrontLensHinge"  and game.CollectionService:HasTag(part,slot) then
					part:Destroy()	
				elseif part.Name == "FrontLensEffector"  and game.CollectionService:HasTag(part,slot) then
					part:Destroy()	
				elseif (part.Name == "AimPart" or part.Name == "ScopeRet") and game.CollectionService:HasTag(part,slot) then
					part:Destroy()
				end
			end

		end,
	};
	["Laser"] = {
		Slot = function(att)
			return att.ExtraData.UsesLeft and "Left" or (att.ExtraData.UsesRight and "Right" or  "Underbarrel")
		end,
		processOriginal = function(att,delete,weapon,Settings,sightRange,sightRange2)
			for i=1,#delete do
				if (delete[i].Name=="Laser" and not delete[i]:FindFirstChild("Stay")) then
					delete[i]:Destroy()
				end
				if (delete[i].Name == "UnderbarrelCover") then
					delete[i].Transparency = 1
				end
			end	
		end,
		postAttach = function(Gun,att)
			
		end,
		OnClearSlot = function(weapon,slot,cName)
			for _, part in ipairs(weapon:GetChildren()) do
				if (part:FindFirstChild("AttachmentJointRef") and part:HasTag(slot)) or part:HasTag("Rail_" .. cName) then
					part:Destroy()
				end
			end

		end,
	};
	["Flashlight"] = {
		Slot = function(att)
			return att.ExtraData.UsesLeft and "Left" or (att.ExtraData.UsesRight and "Right" or  "Underbarrel")
		end,
		processOriginal = function(att,delete,weapon,Settings,sightRange,sightRange2)
			for i=1,#delete do
				if (delete[i].Name=="Flashlight" and not delete[i]:FindFirstChild("Stay")) then
					delete[i]:Destroy()
				end
				if (delete[i].Name == "UnderbarrelCover") then
					delete[i].Transparency = 1
				end					
			end	
		end,
		OnClearSlot = function(weapon,slot,cName)
			for _, part in ipairs(weapon:GetChildren()) do
				if (part:FindFirstChild("AttachmentJointRef") and part:HasTag(slot)) or part:HasTag("Rail_" .. cName) then
					part:Destroy()
				elseif part.Name == "UnderbarrelCover" then
					part.Transparency = 0
				end
			end

		end,
	};
	["Bayonet"] = {
		Slot = "Barrel";
		processOriginal = function(att,delete,weapon,Settings,sightRange,sightRange2)
			
		end,
		OnClearSlot = function(weapon,slot,cName)
			for _, part in ipairs(weapon:GetChildren()) do
				if (part:FindFirstChild("AttachmentJointRef") and part:HasTag(slot)) or part:HasTag("Rail_" .. cName) then
					part:Destroy()
				elseif part.Name == "BayonetBlade"  and game.CollectionService:HasTag(part,slot) then
					part:Destroy()		
				end
			end

		end,
	};
	["GrenadeLauncher"] = {
		Slot = function(att)
			return att.ExtraData.UsesLeft and "Left" or (att.ExtraData.UsesRight and "Right" or  "Underbarrel")
		end,
		processOriginal = function(att,delete,weapon,Settings,sightRange,sightRange2)
			for i=1,#delete do
				if (delete[i].Name=="Main") then
					if delete[i]:FindFirstChild("BarrelIndex") then
						if delete[i].BarrelIndex.Value == 2 then
							delete[i].Name = "Main_Old"
						end
					end
				end
				if (delete[i].Name == "UnderbarrelCover") then
					delete[i].Transparency = 1
				end
				if (delete[i].Name:find("Handguard") and att.ExtraData.Handguard) then
					delete[i].Transparency = 1
				end

				if (delete[i].Name=="HandguardPart" and  att.ExtraData.Handguard and not delete[i]:FindFirstChild("Stay")) then
					delete[i].Name = "HandguardPart_Old"
					delete[i].Transparency = 1
				end
				if (delete[i].Name=="LeftRail" and  att.ExtraData.Handguard  and not delete[i]:FindFirstChild("Stay")) then
					delete[i].Name = "LeftRail_Old"
					delete[i].Transparency = 1
				end
				if (delete[i].Name=="BottomRail" and  att.ExtraData.Handguard  and not delete[i]:FindFirstChild("Stay")) then
					delete[i].Name = "BottomRail_Old"
					delete[i].Transparency = 1
				end
				if (delete[i].Name=="RightRail" and  att.ExtraData.Handguard   and not delete[i]:FindFirstChild("Stay")) then
					delete[i].Name = "RightRail_Old"
					delete[i].Transparency = 1
				end
			end
		end,
		OnClearSlot = function(weapon,slot,cName)
			for _, part in ipairs(weapon:GetChildren()) do
				if (part:FindFirstChild("AttachmentJointRef") and part:HasTag(slot)) or part:HasTag("Rail_" .. cName) then
					part:Destroy()
				elseif part.Name == "Handguard" then
					part.Transparency = 0
				elseif part.Name=="HandguardPart_Old"  then
					part.Name = "HandguardPart"
					part.Transparency = 0
				elseif part.Name == "LeftRail_Old"  then
					part.Name = "LeftRail"
					part.Transparency = 0
				elseif part.Name=="BottomRail_Old" then
					part.Name = "BottomRail"
					part.Transparency = 0
				elseif part.Name=="RightRail_Old"  then
					part.Name = "RightRail"
					part.Transparency = 0
				elseif part.Name == "UnderbarrelCover" then
					part.Transparency = 0
				end
			end
		end,
	};
	["LaserLight"] = {
		Slot = function(att)
			return att.ExtraData.UsesLeft and "Left" or (att.ExtraData.UsesRight and "Right" or  "Underbarrel")
		end,
		processOriginal = function(att,delete,weapon,Settings,sightRange,sightRange2)
			for i=1,#delete do
				if (delete[i].Name=="Flashlight" and not delete[i]:FindFirstChild("Stay")) then
					delete[i]:Destroy()
				elseif (delete[i].Name=="Laser" and not delete[i]:FindFirstChild("Stay")) then
					delete[i]:Destroy()
				end
				if (delete[i].Name == "UnderbarrelCover") then
					delete[i].Transparency = 1
				end					
			end	
		end,	
		OnClearSlot = function(weapon,slot,cName)
			for _, part in ipairs(weapon:GetChildren()) do
				if (part:FindFirstChild("AttachmentJointRef") and part:HasTag(slot)) or part:HasTag("Rail_" .. cName) then
					part:Destroy()
				elseif part.Name == "Handguard" then
					part.Transparency = 0
				elseif part.Name=="HandguardPart_Old"  then
					part.Name = "HandguardPart"
					part.Transparency = 0
				elseif part.Name == "UnderbarrelCover" then
					part.Transparency = 0
				end
			end
		end,
	};
	["Suppressor"] = {
		Slot = "Barrel";
		processOriginal = function(att,delete,weapon,Settings,sightRange,sightRange2,model)
			for i=1,#delete do
				if (delete[i].Name=="Main" and not delete[i]:FindFirstChild("Stay")) then
					if delete[i]:FindFirstChild("BarrelIndex") then
						if delete[i].BarrelIndex.Value == 1 then
							delete[i].Name = "Main_Old"
							model.Main.FireSound.SoundId = delete[i].FireSound.SoundId
							model.Main.FireSound.PlaybackSpeed = delete[i].FireSound.PlaybackSpeed + 4
						end
					end
				end
			end
		end,
		OnClearSlot = function(weapon,slot,cName)
			for _, part in ipairs(weapon:GetChildren()) do
				if (part:FindFirstChild("AttachmentJointRef") and part:HasTag(slot)) or part:HasTag("Rail_" .. cName) then
					part:Destroy()
				elseif part.Name == "Main_Old" then
					part.Name = "Main"
				end
			end
		end,
	};
	["FlashHider"] = {
		Slot = "Barrel";
		processOriginal = function(att,delete,weapon,Settings,sightRange,sightRange2,model)
			for i=1,#delete do
				if (delete[i].Name=="Main" and not delete[i]:FindFirstChild("Stay")) then
					if delete[i]:FindFirstChild("BarrelIndex") then
						if delete[i].BarrelIndex.Value == 1 then
							delete[i].Name = "Main_Old"
						end
					end
				end
				if (delete[i].Name=="Muzzle" and (not delete[i]:FindFirstChild("Stay"))) then
					delete[i].Transparency = 1
					delete[i].Name = "Muzzle_Old"
				end
			end
		end,
		OnClearSlot = function(weapon,slot,cName)
			for _, part in ipairs(weapon:GetChildren()) do
				if (part:FindFirstChild("AttachmentJointRef") and part:HasTag(slot)) or part:HasTag("Rail_" .. cName) then
					part:Destroy()
				elseif part.Name == "Main_Old" then
					part.Name = "Main"
				elseif part.Name == "Muzzle_Old"  then
					part.Name = "Muzzle"		
					part.Transparency = 0
				end
			end
		end,
	};
	["Compensator"] = {
		Slot = "Barrel";
		processOriginal = function(att,delete,weapon,Settings,sightRange,sightRange2,model)
			for i=1,#delete do
				if (delete[i].Name=="Main" and not delete[i]:FindFirstChild("Stay")) then
					if delete[i]:FindFirstChild("BarrelIndex") then
						if delete[i].BarrelIndex.Value == 1 then
							delete[i].Name = "Main_Old"
						end
					end
				end
				if (delete[i].Name=="Muzzle" and (not delete[i]:FindFirstChild("Stay"))) then
					delete[i].Transparency = 1
					delete[i].Name = "Muzzle_Old"
				end
			end
		end,
		OnClearSlot = function(weapon,slot,cName)
			for _, part in ipairs(weapon:GetChildren()) do
				if (part:FindFirstChild("AttachmentJointRef") and part:HasTag(slot)) or part:HasTag("Rail_" .. cName) then
					part:Destroy()
				elseif part.Name == "Main_Old" then
					part.Name = "Main"
				elseif part.Name == "MainMuzzle_Old"  then
					part.Name = "MainMuzzle"		
					part.Transparency = 0
				elseif part.Name == "Muzzle_Old"  then
					part.Name = "Muzzle"		
					part.Transparency = 0
				end
			end
		end,
	};
	["Barrel"] = {
		Slot = "Barrel";
		processOriginal = function(att,delete,weapon,Settings,sightRange,sightRange2,model)
			for i=1,#delete do
				if (delete[i].Name=="Main" and not delete[i]:FindFirstChild("Stay")) then
					if delete[i]:FindFirstChild("BarrelIndex") then
						if delete[i].BarrelIndex.Value == 1 then
							delete[i].Name = "Main_Old"
						end
					end
				end
				if (delete[i].Name=="MainBarrel" and (not delete[i]:FindFirstChild("Stay"))) then
					delete[i].Transparency = 1
					delete[i].Name = "MainBarrel_Old"
				end
				if (delete[i].Name=="Muzzle" and (not delete[i]:FindFirstChild("Stay"))) then
					delete[i].Transparency = 1
					delete[i].Name = "Muzzle_Old"
				end
				if (delete[i].Name=="MainBarrelPart" and (not delete[i]:FindFirstChild("Stay"))) then
					delete[i].Transparency = 1
					delete[i].Name = "MainBarrelPart_Old"
				end
			end
		end,
		OnClearSlot = function(weapon,slot,cName)
			for _, part in (weapon:GetChildren()) do
				if (part:FindFirstChild("AttachmentJointRef") and part:HasTag(slot)) or part:HasTag("Rail_" .. cName) then
					part:Destroy()
					
				elseif part.Name == "Main_Old" then
					part.Name = "Main"
				elseif part.Name == "MainMuzzle_Old"  then
					part.Name = "MainMuzzle"		
					part.Transparency = 0
				elseif part.Name == "Muzzle_Old"  then
					part.Name = "Muzzle"		
					part.Transparency = 0
				elseif part.Name == "MainBarrelPart_Old"  then
					part.Name = "MainBarrelPart"		
					part.Transparency = 0
				elseif part.Name == "Barrel"  and game.CollectionService:HasTag(part,slot) then
					part:Destroy()	
				end
			end
		end,
	};
	["BarrelSight"] = {
		Slot = "Barrel";
		processOriginal = function(att,delete,weapon,Settings,sightRange,sightRange2,model)
			for i=1,#delete do
				if (delete[i].Name=="Main" and not delete[i]:FindFirstChild("Stay")) then
					if delete[i]:FindFirstChild("BarrelIndex") then
						if delete[i].BarrelIndex.Value == 1 then
							delete[i].Name = "Main_Old"
						end
					end
				end
				if (delete[i].Name=="MainBarrel" and (not delete[i]:FindFirstChild("Stay"))) then
					delete[i].Transparency = 1
					delete[i].Name = "MainBarrel_Old"
				elseif (delete[i].Name=="MainBarrelPart" and (not delete[i]:FindFirstChild("Stay"))) then
					delete[i].Transparency = 1
					delete[i].Name = "MainBarrelPart_Old"
				elseif (delete[i].Name=="Muzzle" and (not delete[i]:FindFirstChild("Stay"))) then
					delete[i].Transparency = 1
					delete[i].Name = "Muzzle_Old"

				elseif delete[i].Name:find("MainSight")   then
					if not model:FindFirstChild(delete[i].Name) then
						continue
					end
					if not Settings.mainSightIsKept then
						if delete[i].Transparency ~= 0 then
							local OrigTrans = Instance.new("NumberValue")
							OrigTrans.Name = "OriginalTrans" 
							OrigTrans.Value = delete[i].Transparency
							OrigTrans.Parent = delete[i]
						end						
						delete[i].Transparency = 1
						if delete[i]:FindFirstChildOfClass("Decal") then
							delete[i]:FindFirstChildOfClass("Decal").Transparency = 1
						end
					end
				end
			end				
		end,
		OnClearSlot = function(weapon,slot,cName)
			for _, part in (weapon:GetChildren()) do
				if (part:FindFirstChild("AttachmentJointRef") and part:HasTag(slot)) or part:HasTag("Rail_" .. cName) then
					part:Destroy()
				elseif part.Name:find("MainSight") then
					if part.Name == "MainSightEffector" then
						continue
					end
					if part.Name == "MainSightHinge" and part.Transparency == 1 then
						continue
					end
					if part.Name == "MainSightTurntable" and part.Transparency == 1 then
						continue
					end
					if part:GetAttribute("Hide") then
						continue
					end
					part.Transparency = part:FindFirstChild("OriginalTrans") and part.OriginalTrans.Value or 0
					if part.Name == "MainSightGlass" then
						part.Transparency = 0.75
					end
					if part:FindFirstChildOfClass("Decal") then
						part:FindFirstChildOfClass("Decal").Transparency = 1
					end
				elseif part.Name == "Main_Old" then
					part.Name = "Main"
				elseif part.Name == "MainMuzzle_Old"  then
					part.Name = "MainMuzzle"		
					part.Transparency = 0
				elseif part.Name == "Muzzle_Old"  then
					part.Name = "Muzzle"		
					part.Transparency = 0
				elseif part.Name == "MainBarrelPart_Old"  then
					part.Name = "MainBarrelPart"		
					part.Transparency = 0
				end
			end
		end,
	};
	["Bipod"] = {
		Slot = "Other";
		OnClearSlot = function(weapon,slot,cName)
			for _, part in (weapon:GetChildren()) do
				if (part:FindFirstChild("AttachmentJointRef") and part:HasTag(slot)) or part:HasTag("Rail_" .. cName) then
					part:Destroy()
				end
			end
		end,
	};
	["Grip"] = {
		Slot = function(att)
			return att.ExtraData.UsesLeft and "Left" or (att.ExtraData.UsesRight and "Right" or  "Other")
		end,
		processOriginal = function(att,delete,weapon,Settings,sightRange,sightRange2,model)
			for i=1,#delete do
				if (delete[i].Name=="LeftGrip" and not delete[i]:FindFirstChild("Stay")) then
					delete[i].Name = "LeftGrip_Old";
				end
				if (delete[i].Name=="Foregrip" and not delete[i]:FindFirstChild("Stay")) then
					delete[i].Name = "Foregrip_Old";
					delete[i].Transparency = 1
				end					
				if (delete[i].Name == "UnderbarrelCover") then
					delete[i].Transparency = 1
				end
			end
		end,
		OnClearSlot = function(weapon,slot,cName)
			for _, part in (weapon:GetChildren()) do
				if (part:FindFirstChild("AttachmentPart") and part:HasTag(slot)) or part:HasTag("Rail_" .. cName) then
					part:Destroy()
				elseif part.Name == "LeftGrip"  and game.CollectionService:HasTag(part,slot) then
					part:Destroy()
				elseif part.Name == "Foregrip_Old"  then
					part.Name = "Foregrip"	
					part.Transparency = 0
				elseif part.Name == "UnderbarrelCover" then
					part.Transparency = 0
				end
			end
		end,
	};
	["AmmoCounter"] = {
		Slot = function(att)
			return att.ExtraData.UsesLeft and "Left" or (att.ExtraData.UsesRight and "Right" or  "Other")
		end,
		OnClearSlot = function(weapon,slot,cName)
			for _, part in (weapon:GetChildren()) do
				if (part:FindFirstChild("AttachmentJointRef") and part:HasTag(slot)) or part:HasTag("Rail_" .. cName) then
					part:Destroy()
				end
			end
		end,
	};
	
}
