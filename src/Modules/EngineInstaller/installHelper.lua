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

end