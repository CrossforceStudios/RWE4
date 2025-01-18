local evalOrListCondition = function(boolList)
	local result  = false;
	for _, cond in ipairs(boolList) do
		result = result or cond;
	end
	return result;
end;
return evalOrListCondition