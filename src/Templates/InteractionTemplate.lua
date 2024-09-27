return [[
    return {
        Name = "%s";
        Context = "Interaction";
        Description = "%s";
        KeyContext = "Regular";
        ActionType = "%s";
        ActionBuilder = function(object)
            return ("Do"):upper()
        end;
        CreationCondition = function(object)
            return object.Name == "Example";
        end;
        ObjectBuilder = function(object)
            return ("This"):upper()
        end,
        PlayerCondition = function(player,object)
            return true
        end;
        Location = function() return workspace.CurrentMap.Value:FindFirstChild("Example",true); end;
        ActivationDistance = %d;
    }
]]