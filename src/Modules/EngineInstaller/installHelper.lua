return function(ei)
    print("Installing RWE4...")
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

    local ChangeHistoryService = game:GetService("ChangeHistoryService") do
        ChangeHistoryService:SetWaypoint("Install RWE4 Framework")
    end
end