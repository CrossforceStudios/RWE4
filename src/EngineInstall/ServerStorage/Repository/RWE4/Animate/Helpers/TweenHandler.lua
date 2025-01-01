
local function createTweenHandler()
	local tweenCache = {};
	local tCache
	local tweenFuncs = {};
	local tween = setmetatable({
		addTweenFunction = function(self, name, tweenFunc)
			if typeof(tweenFunc) ~= "function" then
				return
			end
			tweenFuncs[name] = tweenFunc
		end,
	}, {
		__call = function(self,tweenType,...)
			if tweenFuncs[tweenType] then
				tweenFuncs[tweenType](...)
			end
		end;
		__index = function(self,k)
			if tweenFuncs[k] then
				return tweenFuncs[k]
			end
		end
	})
	return tween
end
return createTweenHandler