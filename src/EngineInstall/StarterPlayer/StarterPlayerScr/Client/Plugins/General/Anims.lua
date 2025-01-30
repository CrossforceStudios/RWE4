local Resources = require(game.ReplicatedStorage.Resources)
return {
	OnCharacterRemoving = function(Props,Components)	
		Props.CharacterJanitor:Remove("RenderAnims")
		Props.CharacterJanitor:Remove("RenderTrans")
		Props.CharacterJanitor:Remove("CrouchWalk")
		if _G.SkydiveHandle then _G.SkydiveHandle:Destroy() _G.SkydiveHandle = nil end
		Props.CharState.Stance = 0;

	end,
	Init = function(Props,Components)
		local AnimB
		task.spawn(function()
			AnimB = Props.PseudoInstance.new("AnimBucket")
			Resources:AddComponent("AnimBucket", AnimB)
			local ragdollSounds = Props.PlayerScripts.Ragdoll:GetChildren()
			local ragdollSoundsL = Props.PlayerScripts.RagdollLimb:GetChildren()
			local function RunRagdoll(charH,isUnconscious)
				local char = charH.Parent
				local Head, HRP, LArm, RArm , LLeg, RLeg = char.Head, char.Torso, char:FindFirstChild("Left Arm"), char:FindFirstChild("Right Arm"), char:FindFirstChild("Left Leg"), char:FindFirstChild("Right Leg")	
				local charHJan = Props.Janitor.new()
				local Humanoid2 = char:FindFirstChildOfClass("Humanoid")
				local anim = Humanoid2:FindFirstChildWhichIsA("Animator")
				local soundDebounce = false
				local soundDebounceTorso = false
				for _, part in ipairs(charH:GetDescendants()) do
					if part:IsA("BasePart") and part.Name == "LimbCollider" then
						charHJan:Add(part.Touched:Connect(function(p)
							if p and p:IsDescendantOf(charH) and (not soundDebounce) then
								soundDebounce = true
								local rs = ragdollSoundsL[Props.RNG:NextInteger(1,#ragdollSoundsL)]
								local sound = Instance.new("Sound")
								sound.SoundId = rs.SoundId
								sound.Parent = part
								sound.Volume = rs.Volume * (math.floor(part.Velocity/14))
								sound.EmitterSize 	= sound.Volume * (math.floor(part.Velocity/12)) * 50
								if sound.Volume >= 6 then
									sound.Volume = sound.Volume / 2
								end
								sound.SoundGroup = Components.Sound:GetSoundCat("Game_FX")
								sound:Play()
								task.delay(sound.TimeLength, function()
									sound:Destroy()
									soundDebounce = false
								end)
							end
						end))
					elseif part.Name == "Torso" then
						charHJan:Add(part.Touched:Connect(function(p)
							if p and p:IsDescendantOf(charH) and Humanoid2.FloorMaterial == Enum.Material.Air and (not soundDebounceTorso) then
								soundDebounceTorso = true
								local rs = ragdollSounds[Props.RNG:NextInteger(1,#ragdollSounds)]
								local sound = Instance.new("Sound")
								sound.SoundId = rs.SoundId
								sound.Parent = part
								sound.Volume = rs.Volume * (math.floor(part.Velocity/14))
								sound.EmitterSize 	= sound.Volume * (math.floor(part.Velocity/12)) * 50
								if sound.Volume >= 6 then
									sound.Volume = sound.Volume /2
								end
								sound.SoundGroup = Components.Sound:GetSoundCat("Game_FX")
								sound:Play()
								task.delay(sound.TimeLength, function()
									sound:Destroy()
									soundDebounceTorso = false
								end)
							end
						end))

					end

				end
				if anim  then

					anim:ApplyJointVelocities({HRP:FindFirstChild("Neck");HRP:FindFirstChild("Right Shoulder");HRP:FindFirstChild("Left Shoulder");HRP:FindFirstChild("Right Hip");HRP:FindFirstChild("Left Hip")})
					Humanoid2:ChangeState("Ragdoll")		
					if AnimB:getAnimHelper(char) then
						AnimB:getAnimHelper(char):StopAnims()
					end
				end
				Humanoid2:ChangeState("Physics")
				local vel = Props.RNG:NextUnitVector()

				if char == Props.Player.Character then
					local vel = Head.Velocity
					Components.Camera:setCamMode("FirstPersonDead")
					Components.Camera.CurrentCamMode.Subject = Head
					if not isUnconscious then Props.RunService:UnbindFromRenderStep("UpdateCamAng") end
					task.spawn(function()
						repeat
							local cameraCFrame = Components.Camera.CFrame

							local velocity = Head.Velocity

							local dVelocity = velocity - vel
							if dVelocity.Magnitude >= 0 then
								Components.Camera:ShakeTrip(cameraCFrame:vectorToObjectSpace(-0.1*cameraCFrame.lookVector:Cross(dVelocity)))
							end
							do						
								for _, hiddenArm in ipairs({"L","R"}) do
									local ViewModelArm = LArm
									if (ViewModelArm) then
										local changeTrans = 0 
										local changeList = ViewModelArm:GetConnectedParts()
										table.insert(changeList,LArm)
										Props.changePlayerTrans("partlist",changeList,changeTrans,{Props.Player.Character})
									end
								end
							end				
							Props.RunService.Heartbeat:Wait()
						until
						not char.Parent
						charHJan:Destroy()
					end)
				end	
				Humanoid2:ChangeState("Physics")
			end
			
			workspace.CorpseIgnore.ChildAdded:Connect(function(char)
				if char:FindFirstChild("Head") then
					--AnimB:setFace(char, "Dead")
					RunRagdoll(char.Head,false) 
				end
			end)
			
			game.CollectionService:GetInstanceAddedSignal("Unconscious"):Connect(function(charH)
				AnimB:setFace(charH.Parent, "Down")
				RunRagdoll(charH,true)
			end)
			
			Props.RemoteService.listenU("Client", "Bounce",  "SetCharFace", function(char, state)
				AnimB:setFace(char, state)
			end)



			game.CollectionService:GetInstanceRemovedSignal("Unconscious"):Connect(function(char)
				local Humanoid2 = char
				if char.Parent.Parent then
					AnimB:setFace(char.Parent, "Idle")
					Humanoid2:ChangeState("Ragdoll")
					if char == Props.Player.Character then
						Props.CharState:changeStance("Prone",false,true)
					end

				end
			end)
		end)
		
		
		
	end,

}