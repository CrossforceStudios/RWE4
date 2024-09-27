return function(RWE4,Plugin,EditorLibraries,Libraries,loader,RBLXGUI,EI)
	local imUI = RBLXGUI.PluginWidget.new({
		ID = "InteractionManager_RWE4";
		Enabled = false;
		Title = "RWE4 Interaction Manager";
		DockState = Enum.InitialDockState.Float;
	}, dwi)
	local pageCreate = RBLXGUI.Page.new({
		Name = "CREATE";
		Open = true;
	}, imUI)
	local pageManager = RBLXGUI.Page.new({
		Name = "MANAGE";
		Open = false;
	}, imUI)

	do
		local uiListLayout = Instance.new("UIListLayout")
		uiListLayout.Padding = UDim.new(0,5)
		uiListLayout.Parent = pageCreate.Content
		uiListLayout.HorizontalFlex = "Fill";
		uiListLayout.VerticalFlex = "SpaceAround";
		uiListLayout.SortOrder = "LayoutOrder"
	end
	local creationFormContent = {} do
		creationFormContent.Name = RBLXGUI.Labeled.new({
			Text = "Name";
			InputSize = UDim.new(1,-12);
			Objects = RBLXGUI.InputField.new({
					Font = Enum.Font.GothamMedium;
					Value = "Example";
			});
		}, pageCreate.Content);
		creationFormContent.Description = RBLXGUI.Labeled.new({
			Text = "Description";
			InputSize = UDim.new(1,-12);
			Objects = RBLXGUI.InputField.new({
					Font = Enum.Font.GothamMedium;
					Value = "Example interaction";
			});
		}, pageCreate.Content);
		creationFormContent.ActionType = RBLXGUI.Labeled.new({
			Text = "Action Type";
			InputSize = UDim.new(1,-12);
			Objects = RBLXGUI.InputField.new({
					Font = Enum.Font.GothamMedium;
					CurrentItem = "Press";
					Items = {
						{
							Name = "Press";
							Value = "Press";
						};
						{
							Name = "Hold";
							Value = "Hold";
						}
					}

			});
		}, pageCreate.Content);
		creationFormContent.ActivationDistance = RBLXGUI.Labeled.new({
			Text = "Distance";
			InputSize = UDim.new(1,-12);
			Objects = RBLXGUI.Slider.new({
					Font = Enum.Font.GothamMedium;
					Increment = 1;
					Min = 5;
					Max = 100;
					Value = 10;
			});
		}, pageCreate.Content);
		creationFormContent.Submit = RBLXGUI.Button.new({
			Text = "CREATE";
			ButtonSize = UDim.new(1,0);
		}, pageCreate.Content);
		local size = creationFormContent.Submit.ButtonFrame.Size;
		creationFormContent.Submit.ButtonFrame.Size = UDim2.new(size.X.Scale,size.X.Offset, 0.1, 0)
		creationFormContent.Submit:Clicked(function()
			local list = {
				creationFormContent.Name.Object.Value;
				creationFormContent.Description.Object.Value;
				creationFormContent.ActionType.Object.Value;
				creationFormContent.ActivationDistance.Object.Value;
			};
			if game.ReplicatedStorage:FindFirstChild("Resources") then
				local temp = RWE4:getTemplatedSource("InteractionTemplate", list);
				temp.Name = creationFormContent.Name.Object.Value
				temp.Parent = game.ReplicatedStorage.Resources.Interactions
				RWE4:OpenScript(temp)
			end
		end)
	end

    local function openIntManager(selection)
		imUI.Content.Enabled = true
		if not selection then
		end
    end

    return {
		Title = "Interaction Manager";
		Icon = "rbxassetid://5568203747";
		OnSelect = function()
			openIntManager(game.Selection:Get()[1])
		end;
	}
end
