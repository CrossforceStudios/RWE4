local CPose = {};

CPose.__index = CPose

function CPose.new(name,cf)
	local cp = {};
	cp.Name = name;
	cp.CFrames = {}
	for n, v in pairs(cf) do
		cp.CFrames[n] = v;
	end
	return setmetatable(cp,CPose)
end

function CPose:__call(poseSection)
	return self.CFrames[poseSection]
end

function CPose:GetAllPositions()
	return self.CFrames
end

return CPose