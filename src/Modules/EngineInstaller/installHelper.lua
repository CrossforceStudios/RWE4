return function(RWE4, ei)
    print("Installing RWE4...")
    local record = RWE4:RecordHistory("EngineInstaller", "Install")
    local function installService(name, processFunc)
        local folder = ei:FindFirstChild(name)
        if name then
            if game:GetService(name) then
                for _, i in folder:GetChildren() do
                     local i2 = i:Clone()
                     i2.Parent = game:GetService(name)
                     if processFunc then
                        processFunc(i2)
                     end
                end
            end
        end
    end
    
    local function installWorkspaceInsert(insert, parent)
        local folder = insert
        if folder then
            if parent:IsDescendantOf(workspace) then
                folder:Clone().Parent = parent
            end
        end
    end
    

    installService("ReplicatedStorage")
    installService("ServerStorage")
    installService("LocalizationService")
    installService("SoundService")
    installService("ServerScriptService", function(obj)
        if obj.Name == "Main" then
            obj.Disabled  = false
        end
    end)
    installService("StarterPlayer", function(obj)
        if obj.Name == "StarterPlayerScr" then
            for _, i in obj:GetChildren() do
                local i2 = i:Clone()
                if i2.Name == "Client" then
                    i2.Disabled = false
                end
                i2.Parent = game.StarterPlayer.StarterPlayerScripts
           end
           obj:Destroy()
        elseif obj.Name == "StarterCharacterScr" then
            for _, i in obj:GetChildren() do
                local i2 = i:Clone()
                if i2.Name == "Animate" then
                    i2.Disabled = false
                end
                i2.Parent = game.StarterPlayer.StarterCharacterScripts
           end
           obj:Destroy()
        elseif obj.Name == "StarterCharacter" then
            local Neck do
                if not obj.Torso:FindFirstChild("Neck") then
                    Neck = Instance.new("Motor6D")
                    Neck.Name = "Neck"
                    Neck.Part0 = obj.Torso
                    Neck.Part1 = obj.Head
                    Neck.C0 = CFrame.new(0, 1, 0) * CFrame.Angles(-math.rad(90), -math.rad(180), 0)
                    Neck.C1 = CFrame.new(0, -0.5, 0) * CFrame.Angles(-math.rad(90), -math.rad(180), 0)
                    Neck.Parent = obj.Torso
                end
            end
            local LShoulder do
                if not obj.Torso:FindFirstChild("Left Shoulder") then
                    LShoulder = Instance.new("Motor6D")
                    LShoulder.Name = "Left Shoulder"
                    LShoulder.Part0 = obj.Torso
                    LShoulder.Part1 = obj["Left Arm"]
                    LShoulder.C0 = CFrame.new(-1, 0.5, 0) * CFrame.Angles(-math.rad(0), -math.rad(90), 0)
                    LShoulder.C1 = CFrame.new(0.5, 0.5, 0) * CFrame.Angles(-math.rad(0), -math.rad(90), 0)
                    LShoulder.Parent = obj.Torso
                end
            end
            local RShoulder do
                if not obj.Torso:FindFirstChild("Right Shoulder") then
                    RShoulder = Instance.new("Motor6D")
                    RShoulder.Name = "Right Shoulder"
                    RShoulder.Part0 = obj.Torso
                    RShoulder.Part1 = obj["Right Arm"]
                    RShoulder.C0 = CFrame.new(1, 0.5, 0) * CFrame.Angles(-math.rad(0), math.rad(90), 0)
                    RShoulder.C1 = CFrame.new(-0.5, 0.5, 0) * CFrame.Angles(-math.rad(0), math.rad(90), 0)
                    RShoulder.Parent = obj.Torso
                end
            end
            local LHip do
                if not obj.Torso:FindFirstChild("Left Hip") then
                    LHip = Instance.new("Motor6D")
                    LHip.Name = "Left Hip"
                    LHip.Part0 = obj.Torso
                    LHip.Part1 = obj["Left Leg"]
                    LHip.C0 = CFrame.new(-1, -1, 0) * CFrame.Angles(-math.rad(0), -math.rad(90), 0)
                    LHip.C1 = CFrame.new(-0.5, 1, 0) * CFrame.Angles(-math.rad(0), -math.rad(90), 0)
                    LHip.Parent = obj.Torso
                end
            end
            local RHip do
                if not obj.Torso:FindFirstChild("Right Hip") then
                    RHip = Instance.new("Motor6D")
                    RHip.Name = "Right Hip"
                    RHip.Part0 = obj.Torso
                    RHip.Part1 = obj["Right Leg"]
                    RHip.C0 = CFrame.new(1, -1, 0) * CFrame.Angles(-math.rad(0), math.rad(90), 0)
                    RHip.C1 = CFrame.new(0.5, 1, 0) * CFrame.Angles(-math.rad(0), math.rad(90), 0)
                    RHip.Parent = obj.Torso
                end
            end
            local Root do
                if not obj.PrimaryPart:FindFirstChild("RootJoint") then
                    Root = Instance.new("Motor6D")
                    Root.Name = "RootJoint"
                    Root.Part0 = obj.PrimaryPart
                    Root.Part1 = obj.Torso
                    Root.C0 = CFrame.new() * CFrame.Angles(-math.rad(90), -math.rad(180), 0)
                    Root.C1 = CFrame.new() * CFrame.Angles(-math.rad(90), -math.rad(180), 0)
                    Root.Parent = obj.PrimaryPart
                end
            end
        end
    end)
    installService("Workspace")
    local Lighting = game:GetService("Lighting") do
        if Lighting:FindFirstChild("SunRays") then
            Lighting.SunRays.Name = "SunLight"
            Lighting.SunLight.Intensity = 0.06;
            Lighting.SunLight.Spread = 0.1;

            local sunL = Lighting.SunLight:Clone() do
                sunL.Name = "SunLightFar" 
                sunL.Parent = Lighting
                sunL.Intensity =  0.01
            end
        end
        installService("Lighting")
    end

    local Teams = game:GetService("Teams") do
        local t1 = Instance.new("Team")
        t1.Name = "Red Team"
        t1.TeamColor = BrickColor.new("Bright red")
        t1.Parent = Teams
        t1.AutoAssignable = false
        local t2 = Instance.new("Team")
        t2.Name = "Blue Team"
        t2.TeamColor = BrickColor.new("Bright blue")
        t2.Parent = Teams
        t2.AutoAssignable = false
    end

    local Players = game:GetService("Players") do
        Players.CharacterAutoLoads = false
    end

    installWorkspaceInsert(ei.WorkspaceInserts.Terrain.Clouds, workspace.Terrain)

    RWE4:CommitRecord(record)
   
end