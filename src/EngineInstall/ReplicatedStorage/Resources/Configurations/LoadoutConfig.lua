return {
	Slots = {
		"Primary";
		"Secondary";
		"Grenade";
		"Launcher";
		"Melee";
	};
	PostValidators = {
		["Primary"] = function(item)
			if item:FindFirstChild("GunType") then
				return not table.find({
					"Pistol";
					"MachinePistol";
					"Revolver";
					"RCP";
				}, item.GunType.Value)
			end
		end,
		["Secondary"] = function(item)
			if item:FindFirstChild("GunType") then
				return table.find({
					"Pistol";
					"MachinePistol";
					"Revolver";
					"RCP";
				}, item.GunType.Value)
			end
		end,
		["Grenade"] = function(item)
			return item:FindFirstChild("GrenadeType")
		end,
		["Launcher"] =  function(item)
			return item:FindFirstChild("LauncherType")
		end,
		["Melee"] =  function(item)
			return item:FindFirstChild("MeleeType")
		end,
	};
	SelectValidators = {
		["Primary"] = function(item,awt)
			if item.Type.Value == "Gun" then
				if table.find(awt,item.GunType.Value) then
					return true
				end
			end
			return false
		end,
		["Secondary"] = function(item,awt)
			if item.Type.Value == "Gun" then
				if table.find(awt,item.GunType.Value) then
					return true
				end
			end
			return false
		end,
		["Grenade"] = function(item,awt)
			if item.Type.Value == "Grenade" then
				if table.find(awt,item.GrenadeType.Value) then
					return true
				end
			end
			return false
		end,
		["Launcher"] = function(item,awt)
			if item.Type.Value == "Launcher" then
				if table.find(awt,item.LauncherType.Value) then
					return true
				end
			end
			return false
		end,
		["Melee"] = function(item,awt)
			if item.Type.Value == "Melee" then
				return true
			end
			return false
		end,
	}
}