
return function(API, InputComponent)
	local Interaction
	local PPS = game:GetService('ProximityPromptService')
	local CollectionService = game:GetService('CollectionService')
	local IntJan = API.Janitor.new()
	local RunService = game:GetService("RunService")
	local KBD_INPUT = Enum.KeyCode.I
	local GAMEPAD_INPUT = Enum.KeyCode.ButtonR1
	local function getInteraction(name)
		local interaction = API.Resources:LoadInteraction(name)
		return interaction
	end
	local player = game.Players.LocalPlayer

		do

		API.Enumeration.ActionType = {
			"Hold";
			"Press";
		}
		
		
		Interaction = API.PseudoInstance:Register("Interaction", {
			Internals = {
				"ShowInteraction";
			};
			
			Methods = {
				GetInputCode  = function(self)
					return (self.UserInputType.Name:find("Gamepad")) and GAMEPAD_INPUT or KBD_INPUT
				end;
				GetMessage = function(self)
					return self.ActionBuilder(self.Object), self.ObjectBuilder(self.Object)
				end;
				IsEnabled = function(self)
					if (not self.PlayerCondition) then
						return true
					end
					return (((self.PlayerCondition(player,self.Object or false) or (self.AutoInteraction)) ))
				end
				
			};
			
			Properties = {
				ActionType = API.Typer.EnumerationOfTypeActionType,
				UserInputType = API.Typer.EnumOfTypeUserInputType,
				Object = API.Typer.OptionalInstance,
				Distance = API.Typer.PositiveNumber,
				PlayerCondition = API.Typer.OptionalFunction;
				ActionBuilder = API.Typer.OptionalFunction;
				ObjectBuilder = API.Typer.OptionalFunction;
				ClientInteraction = API.Typer.OptionalFunction;
				CreationCondition = API.Typer.OptionalFunction;
				Style = API.Typer.EnumOfTypeProximityPromptStyle;
				AutoInteraction = API.Typer.OptionalBoolean;
				Duration = API.Typer.OptionalPositiveNumber;
			};
			
			
			
			Init = function(self, data, object)
				self:superinit()
				self.Object = object
				self.ActionType = data.ActionType or "Press"
				self.UserInputType = #API.UIS:GetConnectedGamepads() > 0 and Enum.UserInputType.Gamepad1 or Enum.UserInputType.Keyboard
				self.Distance = data.ActivationDistance or 5;
				self.AutoInteraction = data.IsSelf;
				self.ClientInteraction = data.ClientInt;
				self.ActionBuilder = data.ActionBuilder
				self.ObjectBuilder = data.ObjectBuilder

				self.Duration = data.Duration;
				self.Name = data.Name;
				self.CreationCondition = data.CreationCondition;
				self.PlayerCondition = data.PlayerCondition;
				self.Style = data.Style or Enum.ProximityPromptStyle.Custom
			end
		})
		IntJan:Add(PPS.PromptShown:Connect(function(prompt,inputType)
			local name  =  CollectionService:GetTags(prompt)[1];
			if name then
				local int = _G.Interactions[name]
				int.Object = prompt.Parent
				local action, obj = int:GetMessage()
				prompt.ActionText = action
				prompt.ObjectText = obj
				prompt.Exclusivity = Enum.ProximityPromptExclusivity.OnePerButton
				prompt.Style = int.Style
				if prompt.Style == Enum.ProximityPromptStyle.Custom then
					if InputComponent.Platform == "Touch" then
						_G.HM:ShowInteraction(false,("<TextSize=20><Font=Montserrat>%s %s<Font=/><TextSize=/>"):format(prompt.ActionText,prompt.ObjectText))
					else
						_G.HM:ShowInteraction(InputComponent.Platform == "Gamepad" and GAMEPAD_INPUT or KBD_INPUT,("<Font=Montserrat>%s %s %s<Font=/>"):format(int.ActionType.Name == "Hold" and ("HOLD TO ") or "",prompt.ActionText,prompt.ObjectText))
					end
				end
				InputComponent.CurrentInteraction = int
				InputComponent.CurrentPrompt = prompt
			end
		end),"Disconnect",'showPrompt')
		IntJan:Add(PPS.PromptButtonHoldBegan:Connect(function(prompt,player)
			local name  =  CollectionService:GetTags(prompt)[1];
			print(name)
			if name then
				local int = _G.Interactions[name]
				print(int, " Timer")
				_G.HM:StartIntTimer(int)
			end
		end),"Disconnect",'showPromptTimer')
		IntJan:Add(PPS.PromptButtonHoldEnded:Connect(function(prompt,player)
			local name  =  CollectionService:GetTags(prompt)[1];
			if name then
				local int = _G.Interactions[name]
				print(int)
				_G.HM:EndIntTimer(int)
			end
		end),"Disconnect",'hidePromptTimer')
		IntJan:Add(PPS.PromptTriggered:Connect(function(prompt,player)
			local name  =  CollectionService:GetTags(prompt)[1];
			if name then
				local int = _G.Interactions[name]
					if int:IsEnabled() then
						if int.ClientInteraction then
							int.ClientInteraction(int.Object,player)
						end
						API.RemoteService.fetch("Server","Interact",int.Name,InputComponent.CurrentInteraction.Object)
					end
				end
			
		end),"Disconnect",'TriggerPrompt')
		IntJan:Add(PPS.PromptHidden:Connect(function(prompt)
			local name  =  CollectionService:GetTags(prompt)[1];
			if name then
				local int = _G.Interactions[name]
				InputComponent.CurrentInteraction = nil
				InputComponent.CurrentPrompt = nil
				if prompt.Style == Enum.ProximityPromptStyle.Custom then
					_G.HM:HideInteraction()
				end
			end
		end),"Disconnect",'hidePrompt')
			InputComponent.CurrentInteraction = nil;

			InputComponent.Interacting = false
		end
	InputComponent.InitAllInteractions  = function(intNames)
		if _G.Interactions then
			table.clear(_G.Interactions)
		end
		if _G.IntPrompts then
			for _, p in ipairs(_G.IntPrompts) do
				if p:IsA("ProximityPrompt") then
					p:Destroy()
				end
			end
			table.clear(_G.IntPrompts)
		end
		for i = 1, _G.IntCount or 1 do
			IntJan:Remove("AddInt"..i)
		end
		IntJan:Remove("RenderInt")
		_G.Interactions = {}
		_G.IntPrompts = {}
		_G.IntCount = 0
		for i, name in ipairs(intNames) do
			local intData =  getInteraction(name)
			_G.Interactions[name] = API.PseudoInstance.new("Interaction",intData, nil)
			if intData then
				local loc = intData.Location
				if loc then
					if typeof(loc) == "function" then
						loc = loc()
					end
					if not loc then
						continue
					end
					API.fastSpawn(function()
						for _, v in ipairs(loc:GetDescendants()) do
							if not (intData.CreationCondition(v)) then 
								continue
							end
							local prompt = Instance.new("ProximityPrompt")
							prompt.Name = name.."Prompt"
							CollectionService:AddTag(prompt, name)
							CollectionService:AddTag(prompt, "Prompt")
							prompt.HoldDuration = intData.Duration or 0
							prompt.MaxActivationDistance =  intData.ActivationDistance
							prompt:SetAttribute("Horizontal", intData.Horizontal or false)
							prompt.RequiresLineOfSight = false
							prompt.KeyboardKeyCode = KBD_INPUT
							prompt.GamepadKeyCode = GAMEPAD_INPUT
							prompt.Parent = v 
							prompt.Style = Enum.ProximityPromptStyle.Custom
							table.insert(_G.IntPrompts,prompt)
						end
					end)
					IntJan:Add(loc.DescendantAdded:Connect(function(v)
						if not (intData.CreationCondition(v)) then 
							return
						end
						local prompt = Instance.new("ProximityPrompt")
						prompt.Name = name.."Prompt"
						CollectionService:AddTag(prompt, name)
						CollectionService:AddTag(prompt, "Prompt")
						prompt.HoldDuration = intData.Duration or 0
						prompt:SetAttribute("Horizontal", intData.Horizontal or false)
						prompt.MaxActivationDistance =  intData.ActivationDistance
						prompt.RequiresLineOfSight = false
						prompt.KeyboardKeyCode = KBD_INPUT
						prompt.GamepadKeyCode = GAMEPAD_INPUT
						prompt.Parent = v 
						prompt.Style = Enum.ProximityPromptStyle.Custom
						table.insert(_G.IntPrompts,prompt)
					end),"Disconnect", "AddInt"..i)
					_G.IntCount = i
				end
			end
		end
		IntJan:Add(RunService.Heartbeat:Connect(function(dt)
			for _, prompt in ipairs(CollectionService:GetTagged("Prompt")) do
				local int = _G.Interactions[prompt.Name:sub(1,-7)]
				if int and  prompt.Parent and player.Character then
					int.Object = prompt.Parent
					if not (int.Object:IsA("BasePart") or int.Object:IsA("Model")) then
						continue
					end
					if int.Object:IsA("Model") and (not int.Object.PrimaryPart) then
						continue
					end
					if not player.Character.PrimaryPart then
						continue
					end
					prompt.Enabled = int:IsEnabled()
					if not int.AutoInteraction then
						local dist = ((int.Object:IsA("Model") and int.Object.PrimaryPart.CFrame.p or int.Object.Position) - player.Character:GetPrimaryPartCFrame().p)
						if prompt:GetAttribute("Horizontal") then
							dist = dist * Vector3.new(1,0,1)
						end
						dist = dist.Magnitude
						prompt.Enabled = prompt.Enabled and dist <= prompt.MaxActivationDistance
					end
					if prompt.Enabled then
						break;
					end
				end
			end
		end), "Disconnect", "RenderInt")
	end
	InputComponent.Interacting  = false
		return {
			Name = "Interaction";
			SubComp = Interaction;
		}
end