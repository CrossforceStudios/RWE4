local Resources = require(game.ReplicatedStorage.Resources)
local Lerps = Resources:LoadLibrary("Lerps")
local RNG = Random.new()
local RAND = function(Min, Max)
	return Lerps.number(Min, Max, RNG:NextNumber(0,1))
end

return RAND