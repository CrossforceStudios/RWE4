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