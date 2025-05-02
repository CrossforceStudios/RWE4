local Magazine = {}
Magazine.__index = Magazine
local CF = CFrame.new
local RunService = game:GetService("RunService")
local Resources = require(game.ReplicatedStorage.Resources)
local RemoteService =	Resources:LoadLibrary("RemoteService")
local PseudoInstance = Resources:LoadLibrary("PseudoInstance")
local inList = Resources:LoadLibrary("inList")
local Cartridges = Resources:LoadConfiguration("Cartridge")
local Joint = Resources:LoadLibrary("Joint")
local FastWait = Resources:LoadLibrary("FastWait")
local FastDelay = Resources:LoadLibrary("FastDelay")
local GaugeTypes = Resources:LoadConfiguration("GaugeTypes")
local MS = Resources:LoadConfiguration("MagSprings")
function Magazine.new(...)
	local mag  = {}
	local args = {...}
	mag.Name = args[1]
	mag.Title =  args[2]
	mag.CartridgeName = args[3]
	mag.Size = args[4]
	mag.MaxCount = args[5]
	mag.Penalty = args[6]
	mag.isBeltFed = args[7] or  false
	mag.isClip = args[8] or false
	mag.individual = args[9] or false
	mag.isGrenade = args[10] or false
	mag.revealRounds = args[11] or false
	mag.springOperated = args[12] or false
	mag.hollowPoint = args[13] or false
	mag.GaugeIndex = args[14] or false;
	mag.ExtraData = args[15] or {};
	return setmetatable(mag,Magazine)
end

function Magazine:GetInventoryInfo()
	local c = Cartridges[self.CartridgeName]
	if c and self.GaugeIndex then
		c:SetupGauge(self.GaugeIndex)
	end
	
	if not c then
		return {
			Name = self.Name;
			Title =  self.Title;
			Type = "Resource";
			StartingAmt = self.MaxCount;
			Max = if self.isGrenade then  20 else self.MaxCount;
			Category = if self.isGrenade then "Grenades" else "Magazines";
			Unit = "All";
			Droppable = true;
			Pinnable = false;
			Weight = 1;
			Desc = self.Title;
		};
	end
	return {
		Name = self.Name;
		Title =  self.Title;
		Type = "Resource";
		StartingAmt = self.MaxCount;
		Max = if self.isGrenade then  20 else self.MaxCount;
		Category = if self.isGrenade then "Grenades" else "Magazines";
		Unit = "All";
		Droppable = true;
		Pinnable = false;
		Weight = 1;
		Desc = self.Title .. ("(uses %s)"):format(c.Title);
	};
end

function Magazine:getRound(unanchor)
	local setupCartridge
	if self.GaugeIndex then
		setupCartridge = Cartridges[self.CartridgeName];
		if setupCartridge then
			setupCartridge:SetupGauge(self.GaugeIndex)
		end
	end
	local roundN = self.GaugeIndex and setupCartridge:GetShotName(self.GaugeIndex) or self.CartridgeName
	if self.hollowPoint then
		roundN = roundN .. "Hollow"
	elseif self.isBeltFed then
		roundN = roundN .. "Linked"
	end
	local function isWinged(v)
		return (not v.Name:match("Wing(%d+)")) and (not v.Name:match("WingHinge(%d+)"))
	end
	local round = Resources:GetFullCartridge(roundN)
	if round then
		round = round:Clone()
		for _, v in ipairs(round:GetDescendants()) do
			if v ~= round.PrimaryPart and isWinged(v) and v:IsA("BasePart") then
				local w = Instance.new("Motor6D")
				w.Name = "RoundWeld"
				w.Part0 = round.PrimaryPart
				w.Part1 = v
				w.C0 = round.PrimaryPart.CFrame:toObjectSpace(v.CFrame)
				w.Parent = round.PrimaryPart
				v.Anchored = false
			elseif v.Name:find("WingHinge") then
				local n = v.Name:match("WingHinge(%d+)")
				if n then
					local w = Joint("Assemble",round:FindFirstChild("WingEffector"..n),v,CF(),"WingHingeMotor"..n)
					v.Anchored = false
				end
			elseif v.Name:find("Wing") then
				local n = v.Name:match("Wing(%d+)")
				if n then
					local w = Joint("Assemble",round:FindFirstChild("WingHinge"..n),v,CF(),"WingHingeAttachment"..n)
					v.Anchored = false
				end
			end
		end
		round.PrimaryPart.Anchored = not unanchor
	end
	return round
end

function Magazine:assembleCurvedSpring(mag)
	if mag then
		for _, part in mag.SpringSections:GetDescendants() do
			if part:IsA("BasePart") then
				local j = Joint("Assemble",mag.PrimaryPart,part,CF(),"SpringJoint")
				j.Parent = part
				part.Anchored = false
			end
		end
	end
end

function Magazine:GetSpringType(newSpringType)
	local springType = self.springOperated
	if self.GaugeIndex then
		springType = newSpringType or self.springOperated
	end
	if not springType then
		return nil
	end
	return MS[springType]
end


function Magazine:getMag(unanchor,owner,switchToCompass)
	local setupCartridge
	if self.GaugeIndex then
		setupCartridge = Cartridges[self.CartridgeName];
		if setupCartridge then
			setupCartridge:SetupGauge(self.GaugeIndex)
		end
	end
	local mag
	if owner then
		if owner:IsA("Player") and RunService:IsServer() then
			mag = owner.Character.Magazines:FindFirstChild(self.Name)
		end
	end
	if not mag then
		mag = Resources:GetMag(((self.GaugeIndex and (GaugeTypes[self.Name])))  and setupCartridge:GetShotName(self.GaugeIndex) or self.Name)
	end
	if mag then 
		if switchToCompass then
			mag.PrimaryPart = mag.MagCompass
		end
		if self.isGrenade then
			mag = mag:Clone()
			if RunService:IsClient() then
				mag.Parent = workspace.CurrentCamera
			elseif owner:IsA("Model") then
				mag.Parent = owner
			end
			for _, part in ipairs(mag:GetChildren()) do
				if part:IsA("BasePart") and part.Name ~= "NPoint" then
					if self.isBeltFed and (part.Name:Find("BP")) then

					else
						local partW = Instance.new("Motor6D")
						partW.Name = "NadeWeld"
						partW.C0 = mag.NPoint.CFrame:ToObjectSpace(part.CFrame)
						partW.C1 = CF()
						partW.Part0 = mag.NPoint
						partW.Part1 = part
						partW.Parent = mag.NPoint
						part.Anchored = false						
					end
				end
			end
			mag.NPoint.Anchored = (not unanchor)
		else
			if not mag.Parent:GetAttribute("HoldsMags") then
				mag = mag:Clone()
			else
				mag.MagJoint.Value:Destroy()
			end
			if RunService:IsClient() then
				mag.Parent = workspace.CurrentCamera
			end
			local function isSpringPart(v)
				if self.springOperated then
					return (not inList(v.Name,{
						"SpringPiston";
					})) and not v.Name:find("SpringLeg")
				end
				return true
			end
			local function isWinged(v)
				return (not v.Name:match("Wing(%d+)")) and (not v.Name:match("WingHinge(%d+)"))
			end			
			if not mag:FindFirstChild("Point") then return nil end
			local springType = self:GetSpringType()
			if springType then
				if springType.Type == "Curved" then
					self:assembleCurvedSpring(mag)
					mag:SetAttribute("SpringApplied", true)
				end
			else
				if mag:FindFirstChild("Springs") then
					for _, springPart in ipairs(mag.Springs:GetChildren()) do
						for _, sp in ipairs(springPart:GetChildren()) do
							if sp ~= springPart.PrimaryPart then
								local w = Joint("Assemble",springPart.PrimaryPart,sp,CF(),"SpringPartJoint")
								sp.Anchored = false
							end
						end
						local w = Joint("Assemble",mag.MagSpringBase,springPart.PrimaryPart,CF(),"SpringJoint")
						springPart.PrimaryPart.Anchored = false
					end
				end
			end

			for _, part in ipairs(mag:GetChildren()) do
				if part:IsA("BasePart") then
					if self.GaugeIndex and part.Name == "Pellets" and part:IsA("Folder") then
						for _, part2 in ipairs(part:GetChildren()) do
							if part2:IsA("BasePart") and part2.Name == "Pellet" then
								local w = Joint("AssembleParent",mag.PrimaryPart,part2,CF(),part2,"PelletJoint")
							end
						end
						continue
					end
					if part.Name ~= "Point" and isSpringPart(part) and isWinged(part) then
						local partW = Joint("Assemble",mag.Point,part,CF(),"MagWeld")
						part.Anchored = false
					elseif not isSpringPart(part) then
						if part.Name:find("SpringLeg") then
							local springLegLabel = part.Name:match("SpringLeg(%a+)")
							if springLegLabel then
								local springLegWeld = Joint("AssembleParent",mag.SpringBase,part,CF(),mag.SpringJoints,("SpringLJoint"..springLegLabel))
								local originalSize = Instance.new("Vector3Value")
								originalSize.Name = "OriginalSize"
								originalSize.Value = part.Size
								originalSize.Parent = part
								part.Anchored = false

							end
						elseif part.Name == "SpringPiston" then
							local springPistonWeld = Joint("AssembleParent",mag.SpringBase,part,CF(),mag.SpringJoints,"SpringPistonJoint")
							part.Anchored = false
						end
					elseif part.Name:find("WingHinge") then
						local n = part.Name:match("WingHinge(%d+)")
						if n then
							local w = Joint("Assemble",mag:FindFirstChild("WingEffector"..n),part,CF(),"WingHingeMotor"..n)
							part.Anchored = false
						end
					elseif part.Name:find("Wing") then
						local n = part.Name:match("Wing(%d+)")
						if n then
							local w = Joint("Assemble",mag:FindFirstChild("WingHinge"..n),part,CF(),"WingHingeAttachment"..n)
							part.Anchored = false
						end
					end						

				end
			end
			if self.isClip then
				local Rounds = Instance.new("Folder")
				Rounds.Name = "RoundTemp"
				Rounds.Parent = mag
				for i = 1, self.Size do
					local clip = self:getRound(unanchor)
					if clip then
						clip.Name = "Round" .. i
						if mag:FindFirstChild("BP" .. i) then
							local w = Instance.new("Motor6D")
							w.Name = "RoundAttachment"
							w.Part0 = mag:FindFirstChild("BP"..i)
							w.Part1 = clip.PrimaryPart
							w.C0 = CF()
							w.Parent = w.Part1
							clip.Parent = Rounds
						end
					end
				end
			elseif self.isBeltFed then
				local Rounds = mag.Rounds
				for i = 1, mag.StartingRounds.Value do
					local link = mag:FindFirstChild("BP"..i)
					local link2 = mag:FindFirstChild("BP"..(i + 1))
					local link3 = mag:FindFirstChild("LBP"..i)
					local constraint
					local endCF
					if link and i == mag.StartingRounds.Value then
						endCF = link.CFrame
					end
					if  link and link2 and (not link3) then
						if link:FindFirstChild("AttachL") then
							link.AttachL.CFrame = CFrame.new(0,-link.Size.Y/2,0)
						end
						if link:FindFirstChild("AttachR") then
							link.AttachR.CFrame = CFrame.new(0,link.Size.Y/2,0)
						end
						constraint = Instance.new("CylindricalConstraint")
						constraint.Name = "BeltConstraint"..(i)	
						constraint.Attachment0 = link:FindFirstChild("AttachL")
						constraint.Attachment1 = link2:FindFirstChild("AttachR") 
						constraint.LimitsEnabled = true
						constraint.ActuatorType = Enum.ActuatorType.Servo
						constraint.ServoMaxTorque = 0
						constraint.ServoMaxForce = 0.1
						constraint.LowerAngle = -5
						constraint.Enabled = true	
						constraint.UpperAngle = 5
						constraint.LowerLimit, constraint.UpperLimit = -0.05,0.2
						constraint.Parent = mag.RoundJoints

					end	
					local clip = self:getRound(unanchor)
					if clip then
						clip.Name = "Round" .. i
						clip:SetPrimaryPartCFrame(link.CFrame)
						if mag:FindFirstChild("BP" .. i) then
							local w = Instance.new("Motor6D")
							w.Name = "BeltBulletLink"
							w.Part0 = link
							w.Part1 = clip.PrimaryPart
							w.C0 = link.CFrame:ToObjectSpace(clip.PrimaryPart.CFrame)
							w.Parent = w.Part1
							clip.Parent = Rounds
						end
					end
					if link2 and i ~= 1 then
						link.Anchored = false
						link.CanCollide = true
					end
				end
			else
				if self.revealRounds  then
					for i = 1, self.Size do
						local clip = self:getRound(unanchor)
						if clip then
							clip.Name = "Round" .. i
							if mag:FindFirstChild("BP" .. i) then
								if unanchor then
									local w = Instance.new("Motor6D")
									w.Name = "RoundAttachment"
									w.Part0 = mag:FindFirstChild("BP"..i)
									w.Part1 = clip.PrimaryPart
									w.C0 = CF()
									w.Parent = w.Part1									
								else
									clip:SetPrimaryPartCFrame(mag:FindFirstChild("BP"..i).CFrame)
								end
								clip.Parent = mag.Rounds
							end
						end
					end
				end
			end
			mag.Point.Anchored = (not unanchor)
		end
	end
	return mag
end

function Magazine:FillAmmoCrate(crate)
	for i = 1,  crate.Count.Value do
		local mag = self:getMag(true,false,false)
		local ca = crate:FindFirstChild("MP"..i)
		mag:SetPrimaryPartCFrame(ca.CFrame + Vector3.new(ca.Size.X/2,0,ca.Size.Z/2))
		local mW = Instance.new("Motor6D")
		mW.Name = "MagWeld"
		mW.Part0 =  crate:FindFirstChild("MP"..i)
		mW.Part1 = mag.PrimaryPart
		mW.C0 = crate:FindFirstChild("MP"..i).CFrame:toObjectSpace(mag.PrimaryPart.CFrame)
		mW.C1 = CFrame.new()
		mW.Parent = crate:FindFirstChild("MP"..i)
		mag.Parent = crate.Mags
	end
end

function Magazine:SetMagCount(item, amount)
	if item then
		if item:GetAttribute("Mags") then
			item:SetAttribute("Mags",amount)
			if item:GetAttribute("Mags") <= 0 then
				item:SetAttribute("Ammo",0) 
			end
		end
	end
end

function Magazine:UpdateMetadata(item, unitO, IS, player, c)
	local S = require(item.SETTINGS)
	item:SetAttribute("MagType",self.Name)
	if self.GaugeIndex then
		item:SetAttribute("GaugeIndex",self.GaugeIndex)
	end
	if S.reloadSettings.has2Methods then
		if self.isClip then
			local r = item:FindFirstChild("FakeRounds")
			if r then
				r.Name = "Rounds"
			end
		else
			local r = item:FindFirstChild("Rounds")
			if r then
				r.Name = "FakeRounds"
			end
		end
	end
	if (not item:GetAttribute("MagReady")) then
		item:SetAttribute("Fresh",(not item:GetAttribute("Mags")))
		item:SetAttribute("ClipSize",S.shotCapacity or self.Size)
		if not self.individual then
			item:SetAttribute("Ammo",self.Size)
		else
			item:SetAttribute("Ammo",0)				
			item:SetAttribute("AmmoInd",(S.shotCapacity or self.Size) * (S.maxShotCount or self.MaxCount))
		end
		item:SetAttribute("Penalty",0)
		if unitO then
			item:SetAttribute("UnitPenalty",unitO.SpeedPenalty)
		end
		if item:GetAttribute("Fresh") then
			for _, mag in c.Magazines:GetChildren() do
				if mag.Name == item:GetAttribute("MagType") then
					local mec = item:GetAttribute("Mags") or 0
					mec += 1
					item:SetAttribute("Mags", mec)
				end
			end
			local mec = item:GetAttribute("Mags") or (self.MaxCount * 2)
			if #c.Magazines:GetChildren() > 0 or (not player) then
				item:SetAttribute("Mags", mec - self.MaxCount)
			end
			if not item:GetAttribute("Mags") then
				item:SetAttribute("Mags", self.MaxCount)
			elseif item:GetAttribute("Mags") <= 0 then
				item:SetAttribute("Mags", self.MaxCount)
			end
		end
		if item:FindFirstChild("GunType") then
			if IS.WeaponSet.IsRifle(item.GunType.Value) then
				item:SetAttribute("Mags", math.clamp(item:GetAttribute("Mags"),1,20))
			else
				item:SetAttribute("Mags", math.clamp(item:GetAttribute("Mags"),1,20))
			end
		elseif item:FindFirstChild("LauncherType") then
			if item.LauncherType.Value ~= "Disposable" then
				item:SetAttribute("Mags", math.clamp(self.MaxCount,1,20))
			else
				item:SetAttribute("Mags", 0)

			end
		end		
		item:SetAttribute("MaxMags",self.MaxCount)
		item:SetAttribute("MagReady", true)
		item:SetAttribute("ClipSize",S.shotCapacity or self.Size)
	end
	if item:GetAttribute("AmmoInd") then
		item:SetAttribute("Mags",math.floor(item:GetAttribute("AmmoInd")/item:GetAttribute("ClipSize")))
	end
end

function Magazine.HasMag(player,magName)
	local result  = false
	local list = player.Carry:GetChildren()
	local w2 = player.Character:FindFirstChild("GunType",true)
	if w2 then
		w2 = w2.Parent
		if w2 then
			table.insert(list,w2)
		end
	end
	for _, w in ipairs(list) do
		if w.Type.Value == "Gun" or w.Type.Value == "Launcher" then
			if w:FindFirstChild("SETTINGS") then
				local s = require(w.SETTINGS)
				if s.reloadSettings.usableMags then
					if inList(magName,s.reloadSettings.usableMags) then
						result =  w
						break;
					end
				end
			end
		end
	end

	return result;
end

function Magazine.Detach(item,mode)
	if not mode then
		local magPoint = item:FindFirstChild("MagPoint")
		local beltPoint = item:FindFirstChild("BeltPoint")
		if beltPoint then
			beltPoint = beltPoint:FindFirstChild("BeltAttachment")
			if beltPoint then
				beltPoint:Destroy()
			end
		end
		if magPoint then
			local mA = magPoint:FindFirstChild("MagazineAttachment")
			if mA then
				mA:Destroy()
				local mag = item:FindFirstChild("Magazine") 
				if mag then
					mag.Name  = mag.Name .. "_Detached";
				end
				mag.Parent = workspace.MagIgnore
				item:SetAttribute("Penalty",0)

				return true
			end
		end
		if item:FindFirstChild("Rounds") then
			item.Rounds:ClearAllChildren()
		end		
	elseif mode == "Nade" then
		local magPoint = item:FindFirstChild("NadeIPoint")
		if magPoint then
			local nA = magPoint:FindFirstChild("GrenadeAttachment")
			if nA then
				nA:Destroy()
				local mag = item:FindFirstChild("CurrentGrenade") or item:FindFirstChild("Grenade")
				if mag then
					mag:Destroy()
				end
			end
		end
	end

	return false
end

function Magazine.DetachRound(item,incre)
	if item:FindFirstChild("Rounds") then
		print("Incre:", incre)
		for _, clip in item.Rounds:GetChildren() do
			if clip.Name == "Round"..incre then
				print("Clip Found")
				clip:Destroy()
			end
		end
		return true
	end
	return false
end

function Magazine:ApplyRound(Gun,v,i,mode)
	local r = v or self:getRound()
	if mode == "ShellStorage" then
		r.Parent = Gun.StoredRounds
	else
		r.Parent = Gun.Rounds
	end
	r.Name = "Round"..i
	local set = require(Gun.SETTINGS)
	local MP = Gun:FindFirstChild("MagPoint") 
	if (not MP) or set.reloadSettings.has2Methods then
		MP = Gun:FindFirstChild("MagPointB")
	end
	if MP  then
		local pPart = r.PrimaryPart 
		if pPart then
			local w = Instance.new("Motor6D")
			if MP:IsA("Model") then
				if mode == "ShellStorage" then
					w.Part0 = Gun.ShellStorage:FindFirstChild("Slot" .. i)
				else
					w.Part0 = MP:FindFirstChild("BP" .. i)
				end
				w.Part1 = pPart
				w.C0 = CF()
				w.Parent = self.GaugeIndex and w.Part0 or  pPart
				pPart.Anchored = false
				if Gun:GetAttribute("Ammo") then
					if Gun:GetAttribute("AmmoInd") then
						if Gun:GetAttribute("AmmoInd") <= 0 then
							return
						end
					end 
					Gun:SetAttribute("Ammo", Gun:GetAttribute("Ammo") + 1)
				end					
			end
		end	
	end						
end
function Magazine:ApplyBelt(gun,magModel)
	if self.isBeltFed then

		for _, w in ipairs(magModel.Point:GetChildren()) do
			if w:IsA("JointInstance") then
				if w.Part1 then
					if w.Part1.Name:find("BP") and (not w.Part1.Name:find("L"))   then
						if (not w.Part1.Name:find(magModel.StartingRounds.Value)) then
							w:Destroy()
						end
					end
				end
			end
		end
		if magModel:FindFirstChild("LBP1") then
			local rounds = magModel.Rounds:GetChildren()
			for i, v in ipairs(rounds) do
				if v.PrimaryPart:FindFirstChild("BeltBulletLink") then
					v.PrimaryPart.BeltBulletLink:Destroy()
				end
				do
					local w = Instance.new("Motor6D")
					w.Name = "LinkAttachment"
					w.Part1 = v.PrimaryPart
					w.Part0 = magModel:FindFirstChild("LBP"..i)
					w.C0 = CF()
					w.Parent = w.Part1
				end
			end
			return				
		end
		local MagAttachment = Instance.new("Motor6D")
		MagAttachment.Name = "BeltAttachment";
		MagAttachment.Part0 = gun.BeltPoint
		MagAttachment.Part1 = magModel.BP1
		MagAttachment.C0 = CF(0,0,0)
		MagAttachment.Parent = gun.BeltPoint

		FastDelay(0.2, function()
			for i = 1, #magModel.Rounds:GetChildren() do
				local link = magModel:FindFirstChild("BP"..i)
				if  link then
					if not link:FindFirstChild("LinkAttachment") then
						local la = Instance.new("Motor6D")
						la.Name = "LinkAttachment"
						la.Part0 = magModel.Point
						la.Part1 = link
						la.C0 = magModel.Point.CFrame:ToObjectSpace(link.CFrame)
						la.Parent = link
					end
				end
			end	
			magModel.RoundJoints:ClearAllChildren()
		end)		
	end
end
function Magazine:ApplyFake(Gun,mag,owner,offsets)
	local magModel =  mag or self:getMag(((not Gun.Parent) or (not Gun.Parent:IsA("ViewportFrame"))) and (not Gun:IsDescendantOf(workspace.CurrentCamera)))
	if not magModel then return end
	if Gun:FindFirstChild("Magazine") and (not self.isGrenade) then
		if ((not Gun:FindFirstChild("Rounds") and (not self.isClip))) then
			Gun.Magazine:Destroy()
		end
	end
	local set = require(Gun:FindFirstChild("SETTINGS") or Resources:GetItem(Gun.Name).SETTINGS)

	local MP = Gun:FindFirstChild("MagPoint") 
	if (not MP) or (set.reloadSettings.has2Methods and magModel.Name:find("Clip")) then
		MP = Gun:FindFirstChild("MagPointB")
	end
	if RunService:IsServer() or Gun.Parent:IsA("ViewportFrame") or Gun:IsDescendantOf(workspace.CurrentCamera) then
		magModel.Parent = Gun
		if Gun.Parent:IsA("ViewportFrame")  then
			if MP:IsA("Model") then
				magModel:SetPrimaryPartCFrame(MP:GetPrimaryPartCFrame())
			elseif MP:IsA("BasePart") then
				magModel:SetPrimaryPartCFrame(MP.CFrame)
			end
		end
		if RunService:IsServer() then
			for _, p in ipairs(magModel:GetDescendants()) do
				if p:IsA("BasePart") then
					if owner  and owner:IsA("Player") then
						p:SetNetworkOwner(owner)
					end
				end
			end
		end
	else
		for _, p in ipairs(magModel:GetDescendants()) do
			if p:IsA("BasePart") then
				if owner  and owner:IsA("Player") then
					p:SetNetworkOwner(owner)
				end
			end
		end
	end
	if MP and magModel.PrimaryPart then
		if MP:IsA("Model") then
			magModel:SetPrimaryPartCFrame(MP:GetPrimaryPartCFrame())
		elseif MP:IsA("BasePart") then
			magModel:SetPrimaryPartCFrame(MP.CFrame)
		end
		if not self.isClip then
			if not self.isGrenade then
				local MagAttachment = Instance.new("Motor6D")
				MagAttachment.Name = "MagazineAttachment";
				MagAttachment.Part0 = MP
				MagAttachment.Part1 = magModel.Point
				MagAttachment.C0 = CF(0,0,0)

				--MagAttachment.C1 = CF()
				MagAttachment.Parent = MP
				if set.reloadSettings.magOffsets then
					if set.reloadSettings.magOffsets[magModel.Name] then
						MagAttachment.C0 *= set.reloadSettings.magOffsets[magModel.Name]
					end
				end
				if RunService:IsServer()  then

				else
					-- TODO: Send Request to Change Ammo IF the mag is valid and the weapon is not cos
				end
				magModel.Name = "Magazine";
				magModel.Parent = Gun
			else
				local MagAttachment = Instance.new("Motor6D")
				MagAttachment.Name = "GrenadeAttachment";
				MagAttachment.Part0 = Gun:FindFirstChild("NadeIPoint")
				MagAttachment.Part1 = magModel.NPoint
				MagAttachment.C0 = CF(0,0,0)
				--MagAttachment.C1 = CF()
				MagAttachment.Parent = Gun:FindFirstChild("NadeIPoint")

				if RunService:IsServer()  then

				else
					-- TODO: Send Request to Change Ammo IF the mag is valid and the weapon is not cos
				end
				magModel.Name = "Grenade";
				magModel.Parent = Gun
			end
		else
			local roundsTemp = magModel:FindFirstChild("RoundTemp")
			if roundsTemp then
				local rounds = roundsTemp:GetChildren()
				table.sort(rounds,function(a,b)
					local ia = a.Name:sub(6)
					local ib = b.Name:sub(6)
					return tonumber(ia) < tonumber(ib)
				end)
				local dest = Gun:FindFirstChild("Rounds") 
				if dest then
					for i, v in ipairs(rounds) do
						if v.Name:find("Round") then
							v.Parent = dest
							local pPart = v.PrimaryPart 
							if pPart then
								local w = pPart:FindFirstChild("RoundAttachment")
								if w and MP:IsA("Model") then
									w.Part0 = MP:FindFirstChild("BP" .. i)
									w.Part1 = pPart
									w.C0 = CF()
								end
							end
						end
					end
					for i = 1, self.Size do
						local BP = magModel:FindFirstChild("BP" .. i)
						if BP then
							BP:Destroy()
						end
					end
					if magModel.PrimaryPart then
						magModel.PrimaryPart:Destroy()
						magModel.PrimaryPart = magModel:FindFirstChild("MagClip")
					end
				end
			end	
		end
	end
end
function Magazine:Apply(Gun,mag,owner,offsets)
	local magModel =  mag or self:getMag(((not Gun.Parent) or (not Gun.Parent:IsA("ViewportFrame"))) and (not Gun:IsDescendantOf(workspace.CurrentCamera)) and (not Gun:IsDescendantOf(game.ReplicatedStorage.Resources)))
	if not magModel then return end
	if Gun:FindFirstChild("Magazine") and (not self.isGrenade) then
		if ((not Gun:FindFirstChild("Rounds") and (not self.isClip))) then
			Gun.Magazine:Destroy()
		end
	end
	local set = require(Gun:FindFirstChild("SETTINGS") or Resources:GetItem(Gun.Name).SETTINGS)

	local MP = Gun:FindFirstChild("MagPoint") 
	if (not MP) or (set.reloadSettings.has2Methods and magModel.Name:find("Clip")) then
		MP = Gun:FindFirstChild("MagPointB")
	end
	if self.isGrenade then
		MP = Gun:FindFirstChild("NadeIPoint")
	end
	if RunService:IsServer() or Gun.Parent:IsA("ViewportFrame") or Gun:IsDescendantOf(workspace.CurrentCamera) then
		magModel.Parent = Gun
		if Gun.Parent:IsA("ViewportFrame")  then
			if MP:IsA("Model") then
				magModel:PivotTo(MP:GetPivot())
			elseif MP:IsA("BasePart") then
				magModel:PivotTo(MP.CFrame)
			end
		end
		if RunService:IsServer() then
			for _, p in magModel:GetDescendants() do
				if p:IsA("BasePart") then
					if owner  and owner:IsA("Player") then
						p:SetNetworkOwner(owner)
					end
				end
			end
		end
	else
		for _, p in ipairs(magModel:GetDescendants()) do
			if p:IsA("BasePart") then
				if owner  and owner:IsA("Player") then
					p:SetNetworkOwner(owner)
				end
			end
		end
	end
	if MP and magModel.PrimaryPart then
		if MP:IsA("Model") then
			magModel:PivotTo(MP:GetPivot())
		elseif MP:IsA("BasePart") then
			magModel:PivotTo(MP.CFrame)
		end
		if not self.isClip then
			if not self.isGrenade then
				local MagAttachment = Instance.new("Motor6D")
				MagAttachment.Name = "MagazineAttachment";
				MagAttachment.Part0 = MP
				MagAttachment.Part1 = magModel.Point
				MagAttachment.C0 = CF(0,0,0)

				--MagAttachment.C1 = CF()
				MagAttachment.Parent = MP
				if set.reloadSettings.magOffsets then
					if set.reloadSettings.magOffsets[magModel.Name] then
						MagAttachment.C0 *= set.reloadSettings.magOffsets[magModel.Name]
					end
				end
				if RunService:IsServer()  then

				else
					-- TODO: Send Request to Change Ammo IF the mag is valid and the weapon is not cos
				end
				magModel.Name = "Magazine";
				magModel.Parent = Gun
			else
				local MagAttachment = Instance.new("Motor6D")
				MagAttachment.Name = "GrenadeAttachment";
				MagAttachment.Part0 = MP
				MagAttachment.Part1 = magModel.NPoint
				MagAttachment.C0 = CF(0,0,0)
				--MagAttachment.C1 = CF()
				MagAttachment.Parent = Gun:FindFirstChild("NadeIPoint")

				if RunService:IsServer()  then

				else
					-- TODO: Send Request to Change Ammo IF the mag is valid and the weapon is not cos
				end
				magModel.Name = "Grenade";
				magModel.Parent = Gun
			end
		else
			local roundsTemp = magModel:FindFirstChild("RoundTemp")
			if roundsTemp then
				local rounds = roundsTemp:GetChildren()
				table.sort(rounds,function(a,b)
					local ia = a.Name:sub(6)
					local ib = b.Name:sub(6)
					return tonumber(ia) < tonumber(ib)
				end)
				local dest = Gun:FindFirstChild("Rounds") 
				if dest then
					for i, v in ipairs(rounds) do
						if v.Name:find("Round") then
							v.Parent = dest
							local pPart = v.PrimaryPart 
							if pPart then
								local w = pPart:FindFirstChild("RoundAttachment")
								if w and MP:IsA("Model") then
									w.Part0 = MP:FindFirstChild("BP" .. i)
									w.Part1 = pPart
									w.C0 = CF()
								end
							end
						end
					end
					for i = 1, self.Size do
						local BP = magModel:FindFirstChild("BP" .. i)
						if BP then
							BP:Destroy()
						end
					end
					if magModel.PrimaryPart then
						magModel.PrimaryPart:Destroy()
						magModel.PrimaryPart = magModel:FindFirstChild("MagClip")
					end
				end
			end	
		end
	end

	if magModel.Parent == Gun or (Gun:FindFirstChild("Rounds")) then
		if RunService:IsServer() then
			if Gun then
				if owner then
					local ownerValue = Instance.new("ObjectValue")
					ownerValue.Name = "Owner"
					ownerValue.Value = owner:IsA("Player") and owner.Character or owner
					ownerValue.Parent = magModel
				end
				if Gun:FindFirstChild(self.Name) then
					Gun:FindFirstChild(self.Name):Destroy()
				end
				if owner:IsA("Player") then
					local S = require(Gun.SETTINGS)
					if self.Penalty then
						if Gun:FindFirstChild("LauncherType") and Gun:FindFirstChild("NadePoint") then
							Gun:SetAttribute("Penalty",self.Penalty)
						else
							if self.Name ~= S.reloadSettings.usableMags[1] then
								Gun:SetAttribute("Penalty",self.Penalty)
							else
								Gun:SetAttribute("Penalty",0)
							end
						end 
					end
					if not self.isGrenade then
						local owner2 = owner.Character
						if Gun:GetAttribute("Ammo") < Gun:GetAttribute("ClipSize") and (owner2:GetAttribute("Animation") ~= "Inspecting")  then
							if ((not Gun:GetAttribute("Fresh")) and  Gun:GetAttribute("Ammo") > 0 and not ((Gun.GunType.Value == "Revolver") or (S.reloadSettings.alternateReload)))  then
								if owner then 
									if (owner2:GetAttribute("Animation") ~= "Equip")  then
										_G.Inventories[owner]:RemoveItem(if not self.isClip then self.Name else self.CartridgeName)
									end
								end
								local ms = Gun:GetAttribute("Mags")
								Gun:SetAttribute("Mags", (ms - 1))
								Gun:SetAttribute("Ammo", Gun:GetAttribute("ClipSize") + 1)
							elseif Gun:GetAttribute("Ammo") <= 0 then
								if owner then 
									if  (owner2:GetAttribute("Animation") ~= "Equip")  then
										_G.Inventories[owner]:RemoveItem(if not self.isClip then self.Name else self.CartridgeName)
									end
								end
								local ms = Gun:GetAttribute("Mags")
								Gun:SetAttribute("Mags", (ms - 1))
								Gun:SetAttribute("Ammo", Gun:GetAttribute("ClipSize"))
							end
						end		
					else
						if Gun:GetAttribute("CurrentGrenade") then
							if Gun:GetAttribute("Grenades") > 0 then
								if not Gun:GetAttribute("GrenadesReady") then
									Gun:SetAttribute("GrenadesReady",true)
									Gun:SetAttribute("Grenades", Gun:GetAttribute("Grenades") - 1)
								end
							end
						end
					end
				else
					local S = require(Gun.SETTINGS)
					if self.Penalty then
						if Gun:FindFirstChild("LauncherType") and Gun:FindFirstChild("NadePoint") then
							Gun:SetAttribute("Penalty",self.Penalty)
						else
							if self.Name ~= S.reloadSettings.usableMags[1] then
								Gun:SetAttribute("Penalty",self.Penalty)
							else
								Gun:SetAttribute("Penalty",0)
							end
						end 
					end
					if not self.isGrenade then
						local owner2 = owner
						if Gun:GetAttribute("Ammo") < Gun:GetAttribute("ClipSize")   then
							if ((not Gun:GetAttribute("Fresh")) and  Gun:GetAttribute("Ammo") > 0 and not ((Gun.GunType.Value == "Revolver") or (S.reloadSettings.alternateReload)))  then
								local ms = Gun:GetAttribute("Mags")
								Gun:SetAttribute("Mags", (ms - 1))
								Gun:SetAttribute("Ammo", Gun:GetAttribute("ClipSize") + 1)
							elseif Gun:GetAttribute("Ammo") <= 0 then
								local ms = Gun:GetAttribute("Mags")
								Gun:SetAttribute("Mags", (ms - 1))
								Gun:SetAttribute("Ammo", Gun:GetAttribute("ClipSize"))
							end
						end		
					else
						if Gun:GetAttribute("CurrentGrenade") then
							if Gun:GetAttribute("Grenades") > 0 then
								if not Gun:GetAttribute("GrenadesReady") then
									Gun:SetAttribute("GrenadesReady",true)
									Gun:SetAttribute("Grenades", Gun:GetAttribute("Grenades") - 1)
								end
							end
						end
					end
				end
				
			end
		end
	end
end

return Magazine