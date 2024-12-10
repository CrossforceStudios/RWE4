local UtilService = {}
local ATAN = math.atan
local ATAN2 = math.atan2
UtilService.getYawPitch =  function(Cf)
	local LV = Cf.lookVector
	local Yaw = ATAN2(LV.x, -LV.z)
	local Pitch = ATAN(LV.y / ((LV.x ^ 2) + (LV.z ^ 2)^0.5))
	return Yaw, Pitch
end
UtilService.getYawPitchAI =  function(Cf)
	local LV = Cf.lookVector
	local Yaw = ATAN2(LV.unit.x, -LV.unit.z)
	local Pitch = -math.asin(LV.unit.y)
	return Yaw, Pitch
end
UtilService.restrictAngle = function(angle)
	if angle < -math.pi then
		return angle + math.pi*2
	elseif angle > math.pi then
		return angle - math.pi*2
	else
		return angle
	end
end
UtilService.getYawPitchFromVector =  function(LV)
	local Yaw = ATAN2(LV.x, -LV.z)
	local Pitch = ATAN(LV.y / ((LV.x ^ 2) + (LV.z ^ 2)^0.5))
	return Yaw, Pitch
end
function UtilService.lookAt(target, eye)
    local forwardVector = (eye - target).Unit
    local upVector = Vector3.new(0, 1, 0)
    -- You have to remember the right hand rule or google search to get this right
    local rightVector = forwardVector:Cross(upVector)
    local upVector2 = rightVector:Cross(forwardVector)
 
    return CFrame.fromMatrix(eye, rightVector, upVector2)
end
function UtilService.AngleBetween(vector1, vector2)
	return math.acos(math.clamp(vector1.Unit:Dot(vector2.Unit), -1, 1))
end


function UtilService.AngleBetweenSigned(vector1, vector2, axisVector)
	local angle = UtilService.AngleBetween(vector1, vector2)
	return angle * math.sign(axisVector:Dot(vector1:Cross(vector2)))
end
local seen_dist = 200
function UtilService.CanSee(subject, viewer, fov)
	if (not subject) or (not viewer) then return false end
	local sh = subject
	local vh = viewer:findFirstChild("Head")
	if (not sh) or (not vh) then return false end
	local vec = sh.Position - vh.Position
	local isInFOV = (math.acos(vec:Dot(vh.CFrame.lookVector)) <= math.rad(fov or 80))
	if (isInFOV) and (vec.magnitude < seen_dist) then
		local params = RaycastParams.new()
		params.CollisionGroup = "Player"
		params.FilterDescendantsInstances = {viewer;}
		params.IgnoreWater = true;
		params.FilterType = Enum.RaycastFilterType.Blacklist;
		local por = workspace:Raycast(vh.Position,vec.Unit*seen_dist,params)
		if por then
			return por.Instance:IsDescendantOf(subject)
		else
			return true
		end
	end
	return isInFOV
end
function UtilService.CanSeeNoRay(subject, viewer, fov)
	if (not subject) or (not viewer) then return false end
	local sh = subject
	local vh = viewer:findFirstChild("Head")
	if (not sh) or (not vh) then return false end
	local vec = sh.Position - vh.Position
	local isInFOV = (math.acos(vec.Unit:Dot(vh.CFrame.lookVector.Unit)) <= math.rad(fov or 90))
	if (isInFOV) and (vec.magnitude < seen_dist) then
		return true
	end
	return false
end
return UtilService