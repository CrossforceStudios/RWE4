local function findHumanoidPart(part)
	local result = part
	if part.Parent:FindFirstChildOfClass("Humanoid") then return result end
	if part.Parent:IsA("Tool") then return result end
	if part.Parent:IsA("Model") then
		for _, p in ipairs(part.Parent.PrimaryPart:GetConnectedParts()) do
			if p.Name == "Head" or p.Name == "Torso" or p.Name:find("Arm") or p.Name:find("Leg") then
				result = p;
				break;
			end
		end
	else
		for _, p in ipairs(part.Parent:GetConnectedParts()) do
			if p.Name == "Head" or p.Name == "Torso" or p.Name:find("Arm") or p.Name:find("Leg") then
				result = p;
				break;
			end
		end
	end
	return result
end;
return findHumanoidPart