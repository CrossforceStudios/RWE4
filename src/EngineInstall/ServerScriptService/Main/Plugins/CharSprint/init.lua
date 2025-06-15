local Resources = require(game.ReplicatedStorage.Resources)
return {
	Init = function(Props,Components)
		local function degreesToDot() return math.cos(math.rad(45)) end
		local CharSprint = {} do
			local function recuperate(player: Player,char,isUber)
				local cTween = nil 
				local current = char:GetAttribute("CurrentStamina")
				local sprintStats = char:GetAttribute("Sprinting")
				local val = (12 + (isUber and 8 or 0)) 
				cTween =  Props.Tween.new(val, Props.Enumeration.EasingFunction.Acceleration.Value, "stamina"..player.Name, true, function(x)
					if not char.Parent then
						cTween:Stop()
						return
					end
					char:SetAttribute("CurrentStamina",Props.Lerps.number(current,sprintStats and 0 or 100,x))
					if sprintStats ~= char:GetAttribute("Sprinting") then
						cTween:Stop()
					end
				end)	
				return cTween			
			end
			CharSprint.recuperatePlayer = recuperate
			Props.RemoteService.listen("Server","Fetch","ToggleSprint",function(player: Player,down,isUber)
				if not player then return false end	
				local char = player.Character
				if char then
					if char:GetAttribute("Sprinting") ~= nil then
						local dot  = char.Humanoid.MoveDirection:Dot(char.PrimaryPart.CFrame.LookVector)
						if dot >= degreesToDot()  and (char:GetAttribute("CurrentStamina") > 10) then
							char:SetAttribute("Sprinting",down)
						else
							char:SetAttribute("Sprinting",false)
						end
						local current = char:GetAttribute("CurrentStamina")
						local sprintStats =  char:GetAttribute("Sprinting")
						local cTween
						cTween = Props.Tween.new(12 - (isUber and 8 or 0), Props.Enumeration.EasingFunction.Acceleration.Value, "stamina"..player.Name, true, function(x)
							if not char.Parent then
								cTween:Stop()
								return
							end
							char:SetAttribute("CurrentStamina",Props.Lerps.number(current,sprintStats and 0 or 100,x))
							if sprintStats ~= char:GetAttribute("Sprinting") then
								cTween:Stop()
								Props.fastSpawn(function()
									recuperate(player,char)
								end)
								return 
							end
						end)
						return true
					end
				end
				return false
			end)
			Resources:AddComponent("CharSprint", CharSprint)
		end

	end;
}