local RNG = Random.new()
local Resources = require(game.ReplicatedStorage.Resources)
return function(ai: Model)
    if not Resources:FindGlobalFeature("HatFling") then
        return false
    end
	local Head: BasePart = ai:FindFirstChild("Head")
	if Head then
		local helmet, helmetJoint 
		helmet = Head:FindFirstChild("Helmet")
		helmetJoint = Head:FindFirstChild("HelmetJoint")
		if helmet and helmetJoint then
			helmetJoint.Value:Destroy()
			local hPart: BasePart? = helmet.Value.PrimaryPart
			if hPart then
				local vec = RNG:NextUnitVector()
				hPart:ApplyImpulseAtPosition(Vector3.new(vec.X,2,vec.Z) * RNG:NextInteger(75,100), hPart.CFrame.Position + Vector3.new(vec.X,2,vec.Z))
				return true
			end
		end
	end
	return false
end