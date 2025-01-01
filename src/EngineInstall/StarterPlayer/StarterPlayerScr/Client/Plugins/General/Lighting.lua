local Resources = require(game.ReplicatedStorage.Resources)
local WindShake = Resources:LoadLibrary("WindShake")
local Rain = Resources:LoadLibrary("Rain")
local windObj 
return {
	OnCharacterRemoving = function(Props,Components)	
		Components.Lighting:RemoveNVG()
		Props.DepthOfField.Enabled = false
	end,
	Init = function(Props,Components)
		Components.Lighting:LoadLightingFilter("Tactical")
		local Enumeration = Props.Enumeration
		local lightTimeChanged = Components.Lighting:SetupDayCycleChange(Props.Events:GetEvent("MapReady"))
		local lightStageGrid = Components.Lighting:InitGrid()
		local ClientSettings = Props.ClientSettings
		WindShake:Init()
		windObj = {
			WindSpeed = Props.Lerps.number(25,35,0.75);
			WindDirection = Props.V3(-1,0,Props.RNG:NextNumber(0.1,1));
			WindPower = 0.25;
		}
		local factor = 0
		workspace:GetPropertyChangedSignal("GlobalWind"):Connect(function()
			windObj = {
				WindSpeed = 25;
				WindDirection = workspace.GlobalWind;
				WindPower = factor;
			};
			WindShake:UpdateAllObjectSettings(windObj)	
			WindShake:Resume()
		end)
		Components.Lighting.CloudCoverChanged:Connect(function()
			factor = 0
			if Components.Lighting.Clouds:GetAttribute("CloudState") ~= "Cumulonimbus" and Components.Lighting.Clouds:GetAttribute("CloudState") ~= "Nimbus" then
				factor = 0 
			elseif Components.Lighting.Clouds:GetAttribute("CloudState") ~= "Cumulonimbus" then
				factor = 0.5 + (Props.Lerps.inverseNumber(0.75,0.825,Components.Lighting.Clouds.Cover) * 0.125)
			else
				factor = 1
			end
			local t = Props.RNG:NextInteger(6,10)

			if factor > 0 then
				repeat
					task.wait()
				until
				math.abs(Components.Lighting.Clouds.Density - Components.Lighting.Clouds:GetAttribute("CloudDensity")) <= 0.15 and math.abs(Components.Lighting.Clouds.Cover - Components.Lighting.Clouds:GetAttribute("CloudCover")) <= 0.15
				local c = workspace:GetAttribute("Climate")
				if c then
					if c == "Alpine" then
						Rain:SetStraightTexture("rbxassetid://8163218169")
						Rain:SetTopDownTexture("rbxassetid://8163218169")
						Rain:SetSplashTexture("")
						Rain:SetStraightSize(NumberSequence.new(1))
						Rain:SetSpeedRatio(0.01, TweenInfo.new(t))
						Rain:SetIntensityRatio(0.2, TweenInfo.new(t))
						Rain:SetLightEmission(1, TweenInfo.new(t))

					else
						Rain:SetStraightTexture("rbxassetid://1822883048")
						Rain:SetTopDownTexture("rbxassetid://1822856633")
						Rain:SetSplashTexture("rbxassetid://1822856633")
						Rain:SetStraightSize(NumberSequence.new(10))
						Rain:SetSpeedRatio(factor, TweenInfo.new(t))
						Rain:SetIntensityRatio(factor, TweenInfo.new(t))
						Rain:SetLightEmission(0.05, TweenInfo.new(t))

					end
				end
				Rain:Enable(TweenInfo.new(t + 2))
			else
				Rain:Disable(TweenInfo.new(t + 2))
			end



		end)		
		Components.Lighting.LightningEffectRequested:Connect(function(s,a,l,t)
			Components.Sounds:Create(s,a.WorldCFrame,false,{
				SoundGroup = (Components.Sounds:GetSoundCat("Game_FX"));
			})
			t.AncestryChanged:Wait()
			l:Destroy()
		end)
		local Components = Resources:GetLocalTable("Components")
		Components.Lighting:SetSunlightEnabled(Components.Lighting:GetCurrentTimeOfDay() == "Day")
		Components.Lighting:StartWeatherClient()
		Components.Lighting:ChangeVolumetricTransparency(ClientSettings.VolumeLighting.Transparency)		
		Components.Lighting:ChangeVolumetricSpacing(ClientSettings.VolumeLighting.LayerSpacing)		
		Components.Lighting:ChangeVolumetricLayers(ClientSettings.VolumeLighting.Depth)		
		Components.Lighting:ChangeVolumetricProperty("RenderMethod", Enumeration.VolumetricRenderMethod[ClientSettings.VolumeLighting.RenderMethod].Value)		
		Components.Lighting:ChangeVolumetricProperty("LightEmission", ClientSettings.VolumeLighting.LightEmission)	
		if Resources:FindGlobalFeature("LightingSync") then
			repeat task.wait()
			until Components.Settings.Settings
		end
		
	end,
	OnMapReady = function(Props,Components)
		local map = Props.Map
		if map then
			WindShake:Pause()
			local man = require(map.Manifest)
			if man.IsCove then
				Components.Lighting:ForceCove()
			end
			local list = {
				map.ReverbAreas;
			}
			if map:FindFirstChild("MapCamera") then
				table.insert(list, map:FindFirstChild("MapCamera"))
			end
			if 	map:FindFirstChild("LandmarkZones") then
				table.insert(list, map:FindFirstChild("LandmarkZones"))
			end
			if map:FindFirstChild("MapCenter") then
				table.insert(list, map:FindFirstChild("MapCenter"))
			end
			Rain:SetCollisionMode(Rain.CollisionMode.Blacklist, list)
			local man = require(map.Manifest)
			if man then
				local objs = man.WindObjects 
				if objs then
					for _, v in ipairs(objs) do
						if v then
							for _, v2 in ipairs(v:GetDescendants()) do
								if v2:IsA("BasePart") then
									if table.find(Props.ClientSettings.WindObjectNames, v2.Name) then
										WindShake:AddObjectShake(v2,windObj)
									end
								end
							end
						end
					end
				end
			end
			WindShake:Resume()

		end
	end,
}