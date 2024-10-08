
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

return RayUtils