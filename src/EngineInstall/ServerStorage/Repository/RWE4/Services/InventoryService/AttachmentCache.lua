local AttachmentCache = {}
local Resources = require(game.ReplicatedStorage.Resources)
local AttachmentModules = Resources:LoadConfiguration("AttachmentModules");

function AttachmentCache.new(...)
	local attCache = {}
	local args = {...}
	attCache.Attachments = {

	}
	for _, v in ipairs(AttachmentModules.Slots) do
		attCache.Attachments[v] = false;
	end
	attCache.Weapon = args[1]

	return setmetatable(attCache,AttachmentCache)
end
function AttachmentCache:__index(k)
	local attachments = rawget(self,"Attachments")
	if attachments[k] then
		return attachments[k]	
	end
end
function AttachmentCache:__call(action,...)
	if action == "addAttachment" then
		local args = {...}
		if typeof(args[2]) == "table" and typeof(args[1]) == "string" then
			local v = args[2]
			if v.Name and v.Active ~= nil then
				print(v.Name)
				self.Attachments[args[1]] = v
			end
		else
			self.Attachments[args[1]] = nil
		end
	elseif action == "setAttachmentProp" then
		local args = {...}
		if typeof(args[2]) == "string" and typeof(args[1]) == "string" then
			local att = args[2]
			local v = args[3]
			self.Attachments[args[1]][att] = v
		end		
	elseif action == "setAttachmentOptions" then
		local args = {...}
		if typeof(args[1]) == "string" and typeof(args[2]) == "number" and typeof(args[3]) == "number"  then
			local v = {};
			for i = 2, #args do
				table.insert(v, args[i])
			end
			self.Attachments[args[1]].Options = v
		end		
	end
end
return AttachmentCache