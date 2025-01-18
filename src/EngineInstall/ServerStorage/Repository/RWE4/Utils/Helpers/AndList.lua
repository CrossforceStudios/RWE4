local evalAndListCondition = function(boolList)
	local result  = true;
	for _, cond in ipairs(boolList) do
		result = result and cond;
	end
	return result;
end;
return evalAndListCondition