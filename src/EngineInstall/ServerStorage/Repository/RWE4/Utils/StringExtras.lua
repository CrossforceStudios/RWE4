local SE = {};

function SE:Generate(Count : number)
	local String1 = ""

	for i = 1, Count, 1 do
		local Numbers = tostring(math.random(-9999,9999))
		String1 = String1..Numbers
	end

	return String1
end



return SE