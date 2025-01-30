local Resources = require(game.ReplicatedStorage.Resources)
local changePlayerTransFunc = function(opts)
	local modifierList = {};
	local cpt = setmetatable({
		addModifier = function(self, name: string, modifier)
			if typeof(modifier) ~= "function" then
				return
			end
			modifierList[name] = modifier
		end,
		
	},{
		__index = function(self, k)
			warn ("changePlayerTrans is readonly.")
		end,
		__newindex = function(self, k, v)
			warn ("changePlayerTrans is readonly.")
		end,
		__call = function(self, modifier: string, part: Instance | {BasePart}, ...)
			if modifierList[modifier] then
				modifierList[modifier](part,...)
			end
		end,
	})
	if opts.modifiers then
		for k, v in pairs(opts.modifiers) do
			if typeof(v) == "function" then
				cpt:addModifier(k,v)
			end
		end
	end
	return cpt
end
return changePlayerTransFunc