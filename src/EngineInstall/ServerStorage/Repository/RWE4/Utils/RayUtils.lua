
local RayUtils = {};

export type LineCastOptions = {
	FilterList: {Instance};
	IgnoreWater: boolean?;
};

function RayUtils:LineCastExclusive(origin: Vector3, direction: Vector3, options: LineCastOptions) : RaycastResult
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude;
	params.IgnoreWater =  options.IgnoreWater or false;
	params.FilterDescendantsInstances = options.FilterList;
	return workspace:Raycast(origin, direction, params)
end

function RayUtils:RayCastRay(RayCastData: Ray, Ignore: {Instance})
	local rp = RaycastParams.new()
	rp.FilterType = Enum.RaycastFilterType.Exclude
	rp.FilterDescendantsInstances = Ignore
	local HitResult = workspace:Raycast(RayCastData.Origin, RayCastData.Direction, rp)


	if HitResult and not HitResult.Instance.CanCollide then
		table.insert(Ignore, HitResult.Instance)
		local NewRayCastData = Ray.new(HitResult.Position, RayCastData.Direction)
		return self:RayCastRay(NewRayCastData)
	end

	return HitResult.Instance, HitResult.Position
end

return RayUtils