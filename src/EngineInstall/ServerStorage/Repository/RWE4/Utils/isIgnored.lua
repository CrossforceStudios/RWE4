return function(Obj, Table)
	for _,v in ipairs(Table) do
		if Obj == v or Obj:IsDescendantOf(v) then
			return true
		end
	end
	return false
end