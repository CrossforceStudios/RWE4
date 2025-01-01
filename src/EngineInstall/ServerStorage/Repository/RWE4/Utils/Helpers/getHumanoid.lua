local function getHumanoid(part,times)
	local parent, hum = part, nil
	parent = parent.Parent
	if parent  and times < 3 then
		if parent:FindFirstChildOfClass("Humanoid") then
			hum = parent:FindFirstChildOfClass("Humanoid")
		else
			times = times + 1
			hum = getHumanoid(parent,times)
		end
	else
		return nil
	end
	return hum
end	

return getHumanoid