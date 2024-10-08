local FLOOR = math.floor
local Round = function(Num, toNearest)
	return FLOOR(Num / (toNearest or 1) + 0.5) * (toNearest or 1)
end
return Round