local Resources = require(game.ReplicatedStorage.Resources)
local Table2 = Resources:LoadLibrary("Table")
local removeElement  = function(Table, Element) --removes the first instance of Element from Table
	local i = table.find(Table,Element)
	if i then
		table.remove(Table,i)
	end
	return Table
end
return removeElement