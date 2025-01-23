return function(RWE4,Plugin,EditorLibraries,Libraries,loader,RBLXGUI,EI)
    local SelectionService = game:GetService("Selection")
	local UIS = game:GetService("UserInputService")
	local sizeUI = RBLXGUI.PluginWidget.new({
		ID = "ModelResize_RWE4";
		Enabled = false;
		Title = "Resize Model";
		DockState = Enum.InitialDockState.Left;
	}, dwi)
	local pageParamsBasic = RBLXGUI.Page.new({
		Name = "RESIZE OPTIONS";
		Open = true;
	}, sizeUI)
	local basicLayout = script.BasicLayout:Clone()
	basicLayout.Parent = pageParamsBasic.Content
	local pageParamsPresets = RBLXGUI.Page.new({
		Name = "PRESETS";
		Open = false;
	}, sizeUI)
	local RunService = game:GetService("RunService")
	local presetLayout = script.PresetLayout:Clone()
	presetLayout.Parent = pageParamsPresets.Content
	local ANTI_FREEZE_FPS = 10
	local ANTI_FREEZE_WAIT = 1 / ANTI_FREEZE_FPS
    function WaitAFrame(uni)
        if uni then
            wait(1/60)
        end
        if RunService:IsServer() then
            wait(1/30)
        else 
            wait(1/60)
        end
    end

	function getPartBounds(parts)
		local minX, minY, minZ = math.huge, math.huge, math.huge
		local maxX, maxY, maxZ = -math.huge, -math.huge, -math.huge

		local function checkPos(cf)
			if cf.X < minX then
				minX = cf.X
			end

			if cf.Y < minY then
				minY = cf.Y
			end

			if cf.Z < minZ then
				minZ = cf.Z
			end

			if cf.X > maxX then
				maxX = cf.X
			end

			if cf.Y > maxY then
				maxY = cf.Y
			end

			if cf.Z > maxZ then
				maxZ = cf.Z
			end
		end

		for i, part in ipairs(parts) do
			if not part:IsA("PVInstance") then
				continue
			end
			local cf =  part:IsA("Model") and part:GetModelCFrame() or part.CFrame
			local size = part:IsA("Model") and part:GetExtentsSize() or part.Size

			checkPos(cf * CFrame.new(size.X / 2, size.Y / 2, size.Z / 2))
			checkPos(cf * CFrame.new(size.X / -2, size.Y / 2, size.Z / 2))
			checkPos(cf * CFrame.new(size.X / -2, size.Y / -2, size.Z / 2))
			checkPos(cf * CFrame.new(size.X / -2, size.Y / -2, size.Z / -2))
			checkPos(cf * CFrame.new(size.X / 2, size.Y / -2, size.Z / 2))
			checkPos(cf * CFrame.new(size.X / 2, size.Y / -2, size.Z / -2))
			checkPos(cf * CFrame.new(size.X / 2, size.Y / 2, size.Z / -2))
			checkPos(cf * CFrame.new(size.X / -2, size.Y / 2, size.Z / -2))
		end

		return Vector3.new(minX, minY, minZ), Vector3.new(maxX, maxY, maxZ)
	end

    local Vars = {
        targetJoints = {};
        targetMeshes = {};
        lastDragOffset = 0;
        movementOffsetGlobal = Vector3.new();
    }
    do
        Vars.Handles = Instance.new("Handles")
        Vars.Handles.Name = "ResizeHandles"
        Vars.Handles.Color3 = BrickColor.Red().Color;
        Vars.Handles.Style = Enum.HandlesStyle.Resize;
        Vars.Handles.Parent = game.CoreGui
        Vars.HandlePart = script.handlePart:Clone()
        Vars.HandlePart.Archivable = false
        Vars.Handles.Adornee = Vars.HandlePart
        Vars.HandlesStep = RWE4:GetModuleSetting(script.Name,"Step",1)
        Vars.HandlesStep = math.max(0.001,Vars.HandlesStep)
        Vars.DoJoints = RWE4:GetModuleSetting(script.Name,"DoJoints",true)
	    Vars.DoUnions = RWE4:GetModuleSetting(script.Name,"DoUnions",true)
	    Vars.MeshSmall = RWE4:GetModuleSetting(script.Name,"MeshSmall",true)
	    Vars.AntiFreezeEnabled = RWE4:GetModuleSetting(script.Name,"AntiFreezeEnabled",true)
		Vars.Preset = RWE4:GetModuleSetting(script.Name,"Preset",'None')
		Vars.Percent = RWE4:GetModuleSetting(script.Name,"Percent",100)
        Vars.AntiFreezeEnabled = RWE4:GetModuleSetting(script.Name,"AntiFreezeEnabled",true)
        local function calculateChange(face, distance)
            local offset
            local movementOffset

            local min, max = getPartBounds(Vars.target)
            local bounds = max - min

            if face == Enum.NormalId.Right then
                offset = Vector3.new(distance, bounds.y / bounds.x * distance, bounds.z / bounds.x * distance)
                movementOffset = Vector3.new(distance / 2, 0, 0)
            elseif face == Enum.NormalId.Left then
                offset = Vector3.new(distance, bounds.y / bounds.x * distance, bounds.z / bounds.x * distance)
                movementOffset = Vector3.new(distance / -2, 0, 0)
            elseif face == Enum.NormalId.Top then
                offset = Vector3.new(bounds.x / bounds.y * distance, distance, bounds.z / bounds.y * distance)
                movementOffset = Vector3.new(0, distance / 2, 0)
            elseif face == Enum.NormalId.Bottom then
                offset = Vector3.new(bounds.x / bounds.y * distance, distance, bounds.z / bounds.y * distance)
                movementOffset = Vector3.new(0, distance / -2, 0)
            elseif face == Enum.NormalId.Back then
                offset = Vector3.new(bounds.x / bounds.z * distance, bounds.y / bounds.z * distance, distance)
                movementOffset = Vector3.new(0, 0, distance / 2)
            elseif face == Enum.NormalId.Front then
                offset = Vector3.new(bounds.x / bounds.z * distance, bounds.y / bounds.z * distance, distance)
                movementOffset = Vector3.new(0, 0, distance / -2)
            end

            Vars.movementOffsetGlobal  += movementOffset
            return offset, movementOffset
        end
        RWE4:AddConnection(Vars.Handles.MouseDrag:Connect(function(face, distance)
            local step = math.floor(distance / Vars.HandlesStep) * Vars.HandlesStep
            distance = step - Vars.lastDragOffset
    
            if distance ~= 0 then
                local offset, movementOffset = calculateChange(face, distance)
                local min, max = getPartBounds(Vars.target)
                local bounds = max - min
    
                if Vars.AntiFreezeEnabled then
                    --antiFreezeWarning.Visible = true
    
                    local cf = Vars.HandlePart.CFrame
                    Vars.HandlePart.Size  += offset
                    Vars.HandlePart.CFrame = CFrame.new(cf.p + movementOffset) * (cf - cf.p)
                else
                    for i, inst in pairs(Vars.target) do
                        if inst:IsA("JointInstance") then
                            table.insert(Vars.targetJoints, inst)
                        elseif inst:IsA("DataModelMesh") then
                            table.insert(Vars.targetMeshes, inst)
                        end
                    end
                    Vars.Resize(Vars.target, Vars.targetJoints, Vars.targetMeshes, false, (bounds + offset) / bounds, min, max)
    
                    for i, part in ipairs(Vars.target) do
                        part.CFrame = CFrame.new(part.Position + movementOffset) * (part.CFrame - part.CFrame.p)
                    end
    
                end
    
                Vars.lastDragOffset += distance
            end
        end))
        RWE4:AddConnection(Vars.Handles.MouseButton1Down:connect(function()
            Vars.lastDragOffset = 0
            Vars.movementOffsetGlobal = Vector3.new()
    
            if Vars.AntiFreezeEnabled then
                Vars.HandlePart.Transparency = 0.5
    
                local con
                con = UIS.InputEnded:connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        --antiFreezeWarning.Visible = false
    
                        local min, max = getPartBounds(Vars.target)
                        local bounds = max - min
                        Resize(Vars.target, Vars.targetJoints, Vars.targetMeshes, false, Vars.HandlePart.Size / bounds, min, max)
    
                        for i, part in ipairs(Vars.target) do
                            if not part:IsA("BasePart") then
                                continue
                            end
                            part.CFrame = CFrame.new(part.Position + movementOffsetGlobal) * (part.CFrame - part.CFrame.p)
                        end
    
                        
                        rethinkSelection()	
                        Vars.HandlePart.Transparency = 1
                        con:Disconnect()
                    end
                end)
            end
        end))
    end
    function getMesh(part) -- Gets the first mesh found in the part, or creates one if there is none.
		for i, mesh in ipairs(part:GetChildren()) do
			if mesh:IsA("DataModelMesh") then
				return mesh
			end
		end

		local mesh
		pcall(function()
		if part.ClassName == "WedgePart" then
			mesh = Instance.new("SpecialMesh", part)
			mesh.MeshType = "Wedge"
		elseif part.ClassName == "CornerWedgePart" then
			mesh = Instance.new("SpecialMesh", part)
			mesh.MeshType = "CornerWedge"
		elseif part.ClassName == "VehicleSeat" then
			mesh = Instance.new("BlockMesh", part)
		elseif part.ClassName == "Part" then
			if part.Shape == Enum.PartType.Block then
				mesh = Instance.new("BlockMesh", part)
			else
				mesh = Instance.new("SpecialMesh", part)

				if part.Shape == Enum.PartType.Cylinder then
					mesh.MeshType = "Cylinder"
				elseif part.Shape == Enum.PartType.Ball then
					mesh.MeshType = "Sphere"
				else
					warn("Unable to get a SpecialMesh for the shape ", part.Shape)
				end
			end
		elseif part:IsA("PartOperation") then
			warn(part:GetFullName() .. " was not resized correctly, and could not be meshed because it is a PartOperation (CSG part).")
		else
			warn("Could not resize " .. part.ClassName .. ":" .. part:GetFullName() .. ". Size was constrained and a compatible mesh could not be found.")
		end
		end)
		return mesh
	end
    function Resize(parts, joints, meshes, useProgress, percent, min, max)
		local key = tick()
		local rec = RWE4:RecordHistory(script.Name,("Resize_%s"):format(key))

		if not min then
			min, max = getPartBounds(parts)
		end

		local lastWait = tick()
		local center = (min + max) / 2

		local fakeJoints = {}
		
		if useProgress then
			RWE4:ToggleProgress(true)
			RWE4:SetStatus("Collecting Joints...")
			RWE4:SetPercent(0)
		end
		local prog = 0
		
		for i, joint in ipairs(joints) do
			if joint.Part0 and joint.Part1 then
				table.insert(fakeJoints, {joint.ClassName, joint.Parent, joint.Name, joint.Part0, joint.Part1, joint.C0, joint.C1})
			end

			joint:Destroy() -- Make sure that the joint is actually removed, just in case

			if Vars.AntiFreezeEnabled  and tick() - lastWait > ANTI_FREEZE_WAIT then
				WaitAFrame()
				lastWait = tick()
			end
			prog += (0.25) * (1/#joints)
			RWE4:SetPercent(prog)

		end

		local resized = {} -- Avoid resizing the same part more than once
		RWE4:SetStatus("Resizing Parts...")

		for i, part in parts do
			if not resized[part] then
				resized[part] = true
				local anchored = part.Anchored
				part.Anchored = true

				if (not Vars.DoUnions and not part:IsA("PartOperation")) or Vars.DoUnions then
					local dist = part.Position - center
					local rotation = part.CFrame - part.Position
					local size = part.Size * percent -- TODO: Figure out math for part streching
					part.Size = size

					if part.Size ~= size then
						if part:IsA("FormFactorPart") then
							part.FormFactor = "Custom"
							part.Size = size
						end

						if part.Size ~= size then
							if Vars.MeshSmall then
								part.CanCollide = false
							end

							local mesh = getMesh(part)

							if mesh then
								if (mesh:IsA("FileMesh") and mesh.MeshId == "") or not mesh:IsA("FileMesh") then -- Ignore file meshes, which are automatically scaled down later
									mesh.Scale = mesh.Scale * size / part.Size
								end
							end
						end
					end

					part.CFrame = CFrame.new(dist * percent + center) * rotation
				end

				part.Anchored = anchored

				if Vars.AntiFreezeEnabled and tick() - lastWait > ANTI_FREEZE_WAIT then
					WaitAFrame()
					lastWait = tick()
				end
				prog += (0.25) * (1/#(parts))
				RWE4:SetPercent(prog)
			end
		end

		if Vars.DoJoints then
			RWE4:SetStatus("Resizing Joints...")
			for i, joint in (fakeJoints) do
				local class, parent, name, part0, part1, c0, c1 = unpack(joint)
			--[[local rot0 = part0.CFrame - part0.Position
			local rot1 = part1.CFrame - part1.Position]]

				local ji = Instance.new(class)
				ji.Name = name
				ji.Part0 = part0
				ji.Part1 = part1
			--[[ji.C0 = CFrame.new(c0.p * (CFrame.new(percent) * rot0).p) * (c0 - c0.p)
			ji.C1 = CFrame.new(c1.p * (CFrame.new(percent) * rot1).p) * (c1 - c1.p)]]
				ji.C0 = CFrame.new(c0.p * percent) * (c0 - c0.p)
				ji.C1 = CFrame.new(c1.p * percent) * (c1 - c1.p)

				ji.Parent = parent

				if Vars.AntiFreezeEnabled  and tick() - lastWait > ANTI_FREEZE_WAIT then
					WaitAFrame()
					lastWait = tick()
				end
				prog += (0.25) * (1/#(fakeJoints))
				RWE4:SetPercent(prog)
			end
		end
		
		RWE4:SetStatus("Resizing Meshes...")

		for i, mesh in ipairs(meshes) do
			if mesh:IsA("FileMesh") and mesh.MeshId ~= "" and mesh.Parent:IsA("BasePart") then -- Meshes from files are not scaled down with their parents
				mesh.Scale = mesh.Scale * percent
			end
			prog += (0.25) * (1/#(meshes))
			RWE4:SetPercent(prog)
		end
		RWE4:SetStatus("Done.")
		RWE4:SetPercent(1)
		task.wait(2)
		RWE4:ToggleProgress(false)
		rethinkSelection()
		RWE4:CommitRecord(rec)
	end
    do
        local HandlesStepInput = RBLXGUI.Labeled.new({
            Text = "Handles Interval",
            Objects = RBLXGUI.InputField.new({
                Value = Vars.HandlesStep;
            })
        }, pageParamsBasic.Content)
        HandlesStepInput.Object:Changed(function(val)
            Vars.HandlesStep = tonumber(val)
			RWE4:SetModuleSetting(script.Name,"Step",Vars.HandlesStep)
        end)
        local DoJointsCheck = RBLXGUI.Labeled.new({
            Text = "Resize Joints?",
            Objects = RBLXGUI.Checkbox.new({
                Value = Vars.DoJoints;
            })
        }, pageParamsBasic.Content)

        DoJointsCheck.Object:Clicked(function(val)
            Vars.DoJoints = val
			RWE4:SetModuleSetting(script.Name,"DoJoints",Vars.DoJoints)
        end)
        
        local DoUnionsCheck = RBLXGUI.Labeled.new({
            Text = "Resize Unions?",
            Objects = RBLXGUI.Checkbox.new({
                Value = Vars.DoUnions;
            })
        }, pageParamsBasic.Content)

        DoUnionsCheck.Object:Clicked(function(val)
            Vars.DoUnions = val
			RWE4:SetModuleSetting(script.Name,"DoUnions",Vars.DoUnions)
        end)
        local MeshSmallCheck = RBLXGUI.Labeled.new({
            Text = "Mesh Small Parts",
            Objects = RBLXGUI.Checkbox.new({
                Value = Vars.MeshSmall;
            })
        }, pageParamsBasic.Content)

        MeshSmallCheck.Object:Clicked(function(val)
            Vars.MeshSmall = val
			RWE4:SetModuleSetting(script.Name,"MeshSmall",Vars.MeshSmall)
        end)

        local AntiFreezeEnabledCheck = RBLXGUI.Labeled.new({
            Text = "Anti-Freeze Enabled?",
            Objects = RBLXGUI.Checkbox.new({
                Value = Vars.AntiFreezeEnabled;
            })
        }, pageParamsBasic.Content)

        AntiFreezeEnabledCheck.Object:Clicked(function(val)
            Vars.AntiFreezeEnabled = val
			RWE4:SetModuleSetting(script.Name,"AntiFreezeEnabled",Vars.AntiFreezeEnabled)
        end)

        local PercentBox = RBLXGUI.Labeled.new({
            Text = "Resize Scale",
            Objects =  RBLXGUI.InputField.new({
                Value = 100,
             }),
        }, pageParamsPresets.Content)

        PercentBox.Object:Changed(function(val)
            Vars.Percent = tonumber(val)
			RWE4:SetModuleSetting(script.Name,"Percent",Vars.Percent)
        end)

        local PresetChoice = RBLXGUI.Labeled.new({
            Text = "Choose a Preset:",
            Objects = RBLXGUI.InputField.new({
                Placeholder = "Preset"
               
            })
        }, pageParamsPresets.Content)
        
        PresetChoice.Object:AddItems({
            {Value = "None"; Name = 'No Preset';};	
            {Value = "GunMin"; Name = 'Gun Size (5%)';};	
            {Value = "GunMax"; Name = 'Gun Size (x20)';};	
        })
		
        PresetChoice.Object:Changed(function(index)
			if index == 'None' then
				Vars.Preset = 'None'
			elseif index == 'GunMin' then
				Vars.Preset = 'GunMin'
				Vars.Percent = 5
				RWE4:SetModuleSetting(script.Name,"Percent",Vars.Percent)
			elseif index  ==  'GunMax' then
				Vars.Preset = 'GunMax'
				Vars.Percent = 2000
				RWE4:SetModuleSetting(script.Name,"Percent",Vars.Percent)
			end
            PercentBox.Object:SetDisabled(Vars.Preset ~= 'None')			
			RWE4:SetModuleSetting(script.Name,"Preset",Vars.Preset)
		end)

		local RESIZE_BTN = RBLXGUI.Button.new({
            Text = "RESIZE THE SELECTED OBJECT"
        }, pageParamsBasic.Content)
		RESIZE_BTN.ButtonFrame.LayoutOrder = 5
		RESIZE_BTN.ButtonFrame.Size = UDim2.fromScale(1, 0.05)
		RESIZE_BTN:Clicked(function(i)
			if Vars.target then
				Resize(Vars.target, Vars.targetJoints, Vars.targetMeshes, true, Vector3.new(Vars.Percent/100,Vars.Percent/100,Vars.Percent/100))
			end
		end)
    end
    local function openSizer()
		sizeUI.Content.Enabled = true
    end

    local function getDescendants(instances) -- Instances being a table
		local tbl = {}

		local function rec(v)
			for i, inst in v do
				table.insert(tbl, inst)
				rec(inst:GetChildren())
			end
		end

		rec(instances)
		return tbl
	end


   

    function rethinkSelection()
		Vars.target = SelectionService:Get()
		Vars.targetJoints = {}
		Vars.targetMeshes = {}
		local wasUnique = #Vars.target == 1 and Vars.target[1] or nil

		if #Vars.target > 0 then
			local tbl = {}

			for i, inst in ipairs(getDescendants(Vars.target)) do
				if inst:IsA("BasePart") then
					table.insert(tbl, inst)
				elseif inst:IsA("JointInstance") then
					table.insert(Vars.targetJoints, inst)
				elseif inst:IsA("DataModelMesh") then
					table.insert(Vars.targetMeshes, inst)
				end
			end

			Vars.target = tbl
		end

		if #Vars.target == 0 then
			Vars.target = nil
		end

		if Vars.target == nil then
			Vars.HandlePart.Parent = nil
			Vars.Handles.Visible = false
		elseif Vars.Handles.Visible then
			local min, max = getPartBounds(Vars.target)
			Vars.HandlePart.Size = max - min
			Vars.HandlePart.CFrame = CFrame.new((min + max) / 2)
			Vars.HandlePart.Parent = game.Workspace.CurrentCamera
		end
	end

  
    SelectionService.SelectionChanged:Connect(function()
		if RWE4.CurrentModule == script.Name then
			rethinkSelection()			
		end
	end)
    

    

    return {
		Title = "Resize Models";
		Icon = "rbxassetid://204908623";
		OnSelect = function()
            if RWE4.CurrentModule == script.Name then
                rethinkSelection()			
            end
		    openSizer()
		end;
	}
end