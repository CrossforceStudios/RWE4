local Resources = require(game.ReplicatedStorage.Resources)
return {
	OnCharacterRemoving = function(Props,Components)	
	--[[	Props.CharacterJanitor:Remove("RenderAnims")
		Props.CharacterJanitor:Remove("RenderTrans")
		Props.CharacterJanitor:Remove("CrouchWalk")
		if _G.SkydiveHandle then _G.SkydiveHandle:Destroy() _G.SkydiveHandle = nil end
		Props.CharState.Stance = 0;
]]--
	end,
	Init = function(Props,Components)
		local OutfitPlugin = {};
		local armMaker = {}
		do
			local function createFakeArm(plr,...)
				if plr:IsA("Model") then 
					return
				end
				if plr.Character:FindFirstChild("FakeArms") then return end 
				repeat Props.RunService.Heartbeat:Wait()  until plr.Character:FindFirstChild("Left Arm")
				if plr == Props.Player then
					Props.ViewModelGet().armModel = Instance.new("Model")
					Props.ViewModelGet().armModel.Name = "FakeArms"
					Props.ViewModelGet().armModel.Parent = Props.Player.Character
					Props.ViewModelGet().FHum = Instance.new("Humanoid")
					Props.ViewModelGet().FHum.RequiresNeck = false
					Props.ViewModelGet().FHum.BreakJointsOnDeath = false
					Props.ViewModelGet().FHum.MaxHealth = 0
					Props.ViewModelGet().FHum.Health = 0;
					Props.ViewModelGet().FHum.Parent = Props.ViewModelGet().armModel
				else
					for _, v in ipairs({plr.Character:FindFirstChild("Left Arm");plr.Character:FindFirstChild("Right Arm");}) do
						if v:FindFirstChild("FakeArmAttachment") then
							v.FakeArmAttachment:Destroy()
						end
					end
					return 
				end
				if not  plr.Character.FakeArms:FindFirstChild("FHumanoid") then 
					local FHum = Instance.new("Humanoid")
					FHum.Name = "FHumanoid"
					FHum.RequiresNeck = false
					FHum.BreakJointsOnDeath = false
					FHum.MaxHealth = 0
					FHum.Health = 0;
					FHum.Parent = plr.Character.FakeArms
					FHum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
					plr.Character:FindFirstChild("Shirt"):Clone().Parent = plr.Character.FakeArms
				end
				for _, v in ipairs({plr.Character:FindFirstChild("Left Arm");plr.Character:FindFirstChild("Right Arm");}) do
					v.Transparency = 1
					local armClone = v:Clone()
					armClone.Transparency = 0
					armClone.Size = Vector3.new(0.8,2 + v.FakeArmAttachment.Position.Y,0.8)
					armClone.Name = v.Name
					armClone.CFrame = v.CFrame * CFrame.new(v.FakeArmAttachment.Position)
					armClone.Parent = plr.Character.FakeArms
					game.CollectionService:AddTag(armClone,"FArm")

					local aWeld = Instance.new("Motor6D")
					aWeld.Part0 = v
					aWeld.Name = "FAWeld";
					aWeld.Part1 = armClone
					aWeld.C0 = v.CFrame:toObjectSpace(armClone.CFrame)
					aWeld.C1 = CFrame.new()
					aWeld.Parent = v
				end
				return plr.Character.FakeArms
			end

			function armMaker:makeArms(player2,Vars,returnModel)
				return createFakeArm(player2)				
			end	




		end
		
		function OutfitPlugin:makeArms(player2)
			return armMaker:makeArms(player2)

		end

		function OutfitPlugin:applyOutfit(player2)
			--[[if Props.Player == player2 and not Props.ClientSettings.RenderOutfit then return end
			local outfit
			if player2:IsA("Model") then
				local hum2 = player2:WaitForChild("Human",200)


				if hum2:GetAttribute("HumanoidType") then
					if hum2:GetAttribute("HumanoidType") == "Zombie" then
						local team = player2:GetAttribute("ZombieTeam")
						if team then
							team = game.Teams:FindFirstChild(team)
							outfit = team.TeamOutfits:FindFirstChild(workspace:GetAttribute("Climate") or "Urban")
							if outfit then
								outfit = require(outfit:FindFirstChild(player2:GetAttribute("ZombieUnit")))
							end
						end
					end
				else
					local BOT = require(player2:WaitForChild("BOT",20))
					if BOT then
						outfit = BOT.Team.TeamOutfits:FindFirstChild(workspace:GetAttribute("Climate") or "Urban")
						if outfit then
							outfit = require(outfit:FindFirstChild(BOT.Unit))
						end

					end
				end

				local animator = Instance.new("Animator")
				animator.Parent = player2:FindFirstChildOfClass("Humanoid")
			elseif player2:IsA("Player") then
				outfit = player2.Team.TeamOutfits:FindFirstChild(workspace:GetAttribute("Climate") or "Urban")
				if outfit then
					outfit = require(outfit:FindFirstChild(player2:GetAttribute("Unit")))
				end
			end
			if outfit then
				outfit = outfit(player2)
				local char 
				if player2:IsA("Model") then
					player2:WaitForChild("Human",200)
					player2:WaitForChild("Head",200)
					player2:WaitForChild("Left Arm",200)
					player2:WaitForChild("Right Arm",200)
					player2:WaitForChild("Torso",200)
					player2:WaitForChild("Left Leg",200)
					player2:WaitForChild("Right Leg",200)
				else
					player2.Character:WaitForChild("Humanoid",200)
					player2.Character:WaitForChild("Head",200)
					player2.Character:WaitForChild("Left Arm",200)
					player2.Character:WaitForChild("Right Arm",200)
					player2.Character:WaitForChild("Torso",200)
					player2.Character:WaitForChild("Left Leg",200)
					player2.Character:WaitForChild("Right Leg",200)
				end
				]]--
				OutfitPlugin:makeArms(player2)
				--outfit:Apply(player2:IsA("Model") and player2 or player2.Character )
				Components.AnimBucket:setOrigFace(player2:IsA("Model") and player2 or player2.Character)
				--[[if _G.GameMode == "Campaign" then
					if player2 == game.Players:GetPlayers()[1] then
						local getMainCharacter = Resources:LoadLibrary("getMainCharacter")
						local char = getMainCharacter(player2:GetAttribute("CampaignName"))
						if char then
							local faceState = char.Face
							if faceState then
								Resources:GetComponent("AnimBucket"):setFace(player2.Character, faceState)
							end
						end
					end
				end
				outfit:Destroy()
				outfit = nil;]]--
			--end
		end

		pcall(function()
			for _, plr in ipairs(game.Players:GetPlayers()) do
				if plr == Props.Player then continue end
				if plr.Character then
					OutfitPlugin:applyOutfit(plr)
				end
			end
			game.Players.PlayerAdded:Connect(function(player2)
				player2.CharacterAdded:Connect(function()
					OutfitPlugin:applyOutfit(player2) 
				end)
			end)

			for _, player3  in ipairs(game.Players:GetPlayers()) do
				player3.CharacterAdded:Connect(function()
					OutfitPlugin:applyOutfit(player3) 
				end)
			end

			workspace.Mobs.ChildAdded:Connect(function(c)
				OutfitPlugin:applyOutfit(c)
			end)
			
			for _, m in ipairs(workspace.Mobs:GetChildren()) do
				OutfitPlugin:applyOutfit(m)
			end
		end)
		
		Resources:AddComponent("Outfit", OutfitPlugin)
		
		
		
	end,

}