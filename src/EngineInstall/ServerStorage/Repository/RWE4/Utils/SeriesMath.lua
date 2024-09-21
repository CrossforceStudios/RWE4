
local SeriesM = {};
function SeriesM:Summation(n,i,f)
	i = i or 0
	if typeof(f) == "function" then
		for j = 1, n do
			i = i + f(j)
		end
	end
	return i
end
function SeriesM:ProducttSummation(n,i,f)
	i = i or 0
	if typeof(f) == "function" then
		for j = 1, n do
			i = i * f(j)
		end
	end
	return i
end
function SeriesM:Map(Val, fromLow, fromHigh, toLow, toHigh)
	return (Val - fromLow) * (toHigh - toLow) / (fromHigh - fromLow) + toLow
end
function SeriesM:YForLineGivenXAndTwoPts(x,pt1x,pt1y,pt2x,pt2y)
	--(y - y1)/(x - x1) = m
	local m = (pt1y - pt2y) / (pt1x - pt2x)
	--float b = pt1.y - m * pt1.x;
	local b = (pt1y - m * pt1x)
	return m * x + b
end;
return SeriesM