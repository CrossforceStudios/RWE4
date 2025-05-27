local AttachmentAdapter = {}
AttachmentAdapter.__index = AttachmentAdapter
function AttachmentAdapter.new(...)
	local atta = {}
	local args = {...}
	atta.CallSign = args[1]
	atta.ExtraData = {}
	
	atta.OnRun = args[2] or  function(self,API)
		
	end;

	return setmetatable(atta,AttachmentAdapter)
end;
function AttachmentAdapter:Run(api)
		self.OnRun(self,api)
end
function AttachmentAdapter:__call(api)
	self:Run(api)
end
return AttachmentAdapter; 