local Resources = require(game.ReplicatedStorage.Resources)
return {
	
	Init = function(Props,Components)
		local makeHole
		do
			Components.FeatureCheck("setFeature","Impacts", Resources:FindGlobalFeature("Impacts"))
			local Client = script.Parent.Parent.Parent
			local HitMaterials = Props.ClientSettings.HitMaterials;
			local matGroups = Props.ClientSettings.MaterialGroups;
			local function getMaterialGroup(M)
				local material = M
				for k, list in pairs(matGroups) do 
					if (table.find(list,material.Name)) then
						return k
					end
				end
				return nil
			end
			local Hole = Instance.new("Part")
			Hole.CanCollide = false
			Hole.Size = Vector3.new(0.2,0.2,0.2)
			Hole.Transparency = 1;
			Hole.Anchored = true
			local blood ={}
			local BDE = Resources:LoadLibrary("BloodEngine")
			local bde = BDE.new({
				Decals = false
			})
			local function makeBlood(H,P,N, meleeSound)
				if Components.FeatureCheck("getFeature","Blood") then

					if not H then return end
					if not blood[H] then
						blood[H] = true
						local surfaceCF = CFrame.new(P, P + N)
						local Hole2 = Instance.new("Attachment")
						Hole2.Parent = workspace.Terrain
						Hole2.CFrame = surfaceCF
						local Blood = Resources:GetEffect("Blood"):Clone()
						Blood.Name = "Blood"
						Blood.EmissionDirection = "Front"
						Blood.Parent = Hole2
						Blood.Acceleration += surfaceCF.LookVector.Unit
						Blood:Emit(6)
						Components.Sound:Create(Props.Make "Sound" {
							SoundId =  if meleeSound then "rbxassetid://3739362156" else "rbxassetid://1565725028"
						},CFrame.new(P, P + N),false,{
							SoundGroup = (Components.Sound:GetSoundCat("Game_FX"));
						})
						task.delay(0.05, function()
							local IgnoreList2 = table.clone(Props.Ignore())
							for _, m in workspace.Mobs:GetChildren() do
								table.insert(IgnoreList2, m)
							end
							for _, ra in workspace.CurrentMap.Value.ReverbAreas:GetChildren() do
								table.insert(IgnoreList2, ra)
							end
							bde:UpdateSettings({
								Filter = IgnoreList2;
							})
							bde:Emit(H, H.CFrame:VectorToWorldSpace(-N), 12)
						end)
						task.delay(0.3,function()
							Hole2:Destroy()
						end)
						task.wait(0.3)
						blood[H] = false
					end
				end
			end
			local function createHoleRaw(H,P,N,M,D,hitH,cartName)
				local surfaceCF = CFrame.new(P,P + N)
				if Components.FeatureCheck("getFeature","Impacts") then

					if not H then return end
					if H.Transparency >= 1 then return end
					if (not H.CanCollide) then return end
					----------------------------------------------------------------------------------
					--Creating the bullet hole--------------------------------------------------------
					----------------------------------------------------------------------------------
					local mat = getMaterialGroup(M)		
					if not mat then return end

					local Hole2 = Hole:Clone()
					local HoleUI = Instance.new("SurfaceGui") 
					HoleUI.Face = "Front"
					local HoleUI2 = Instance.new("ImageLabel")
					HoleUI2.BackgroundTransparency = 1
					do
						local holeMat = Props.ClientSettings.HoleTypes[M]
						if not holeMat then
							return;
						end
						HoleUI2.Image = "rbxassetid://" .. holeMat[Props.RNG:NextInteger(1,#holeMat)]
					end
					HoleUI.Parent = Hole2
					HoleUI2.Size = UDim2.fromScale(1,1) 
					HoleUI2.Parent = HoleUI
					HoleUI2.ImageColor3 = H.BrickColor.Color
					HoleUI2.ClipsDescendants = true
					Hole2.Parent = workspace.HoleStorage
					if cartName then
						local spitz = Resources:GetSpitzer(cartName).PrimaryPart
						Hole2.Size = Vector3.new(spitz.Size.X,spitz.Size.Y,0.2) * 2
					else
						Hole.Size = Vector3.new(0.2, 0.2, 0.2);
					end	
					Hole2.CFrame = surfaceCF
					if (not H.Anchored) and (not game.PhysicsService:CollisionGroupContainsPart("Wheel",H)) then
						local WC = Instance.new("WeldConstraint")
						WC.Part0 = H
						WC.Part1 = Hole2
						WC.Parent = Hole2
						WC.Enabled = true
						Hole2.Anchored = false	
					end

					do

					end
					local function spawnEffect()
						local HitSound = (game.CollectionService:HasTag(H,"Tank") and mat == "Metal") and Client.Tank:FindFirstChild("Pen") or Client:FindFirstChild(mat)
						if HitSound and (not  (game.CollectionService:HasTag(H,"Tank") and mat == "Metal")) then 
							HitSound = HitSound:FindFirstChild("Sound" .. Props.RNG:NextInteger(1,#HitSound:GetChildren()))
						end
						if HitSound then
							HitSound = HitSound:Clone()
						end

						HitSound.Name = "HitSound"
						HitSound.SoundGroup = Components.Sound:GetSoundCat("Game_FX")
						HitSound.Parent = Hole2
						HitSound:Play()
						local function destroyHitSound()
							HitSound:Destroy()
							HitSound = nil;
						end
						task.delay(1,destroyHitSound)
						if  mat then
							local Particles = Resources:GetEffect(mat.."Spark"):Clone()
							if Particles:FindFirstChild("Normalize").Value then
								Particles.Color = ColorSequence.new(H.Color)
							end
							if mat == "Water" then
								local color = workspace.Terrain.WaterColor
								color = Color3.new(color.r * 2, color.g * 2, color.b * 2)
								Particles.Color = ColorSequence.new(color)
								local Velocity = 1000 
								if Props.Cartridges[cartName] then
									Velocity = Props.Cartridges[cartName].Velocity
								end
								Particles.Acceleration = N * (Velocity/100)
								Particles:Emit(Particles.Rate)

							end
							Particles.Parent = Hole2					
							Particles:Emit(8)
							local function destroyParticles()						
								Particles:Destroy()
								Particles = nil;
							end
							task.delay(Particles.Lifetime.Max * 1.125,destroyParticles)		
						end
					end

					task.spawn(spawnEffect)
					local function DestroyHole()
						if Hole2:FindFirstChildOfClass("WeldConstraint") then
							Hole2:FindFirstChildOfClass("WeldConstraint"):Destroy()
						end
						Hole2:Destroy()
						Hole2 = nil;
					end
					task.spawn(spawnEffect)
					task.delay(1.5,DestroyHole)
				end


			end
			local function createHoleRemote(H,P,N,M,D,humanoidFound,cartName)
				createHoleRaw(H,P,N,M,D,humanoidFound,cartName)
			end
			makeHole = setmetatable({

			},{
				__index = function(self,k)
					if k == "Remote" then
						return createHoleRemote
					elseif k == "Raw" then
						return function(H,P,N,M,D,humanoidFound, cartName)
							Props.RemoteService.sendU("Server","bulletImpact",H, P, N, M, D, humanoidFound, cartName)
						end
					end
				end;
				__call = function(self,mode,...)
					if self[mode] then
						self[mode](...)
					end
				end
			})
			Props.RemoteService.listenU("Client","Bounce","ShowImpactFromPoint",function(H,P,N,M,D,humanoidFound,cartName)
				makeHole("Remote",H,P,N,M,D,humanoidFound,cartName)
			end)
			Props.RemoteService.listenU("Client","Bounce","Bleed",function(H,P,N,meleeSound)
				makeBlood(H,P,N,meleeSound)
			end)
			local fires = {}
			local fireIndices = {}
			game.CollectionService:GetInstanceAddedSignal("Flammable"):Connect(function(part)
				if part:IsA("BasePart") then
					local pf = Props.PseudoInstance.new("ParticleFire")
					pf.CFrame = part.CFrame
					pf.Parent = part
					pf.Enabled = true
					fires[#fires+1] = pf
					fireIndices[part] = #fires
				end
			end)
			game.CollectionService:GetInstanceRemovedSignal("Flammable"):Connect(function(part)
				if part:IsA("BasePart") and fireIndices[part] then
					local pf = fires[fireIndices[part]]
					pf:Destroy()
					fires[fireIndices[part]] = nil;
					fireIndices[part] = nil;
				end
			end)
			Props.RunService.Heartbeat:Connect(function(dt)
				for p, i in ipairs(fireIndices) do
					if p:IsA("BasePart") then
						local pf = fires[fireIndices[p]]
						pf.CFrame = p.CFrame
					end
				end
			end)
		end
	end,
}