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

end