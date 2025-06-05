local Resources = require(game:GetService("ReplicatedStorage"):WaitForChild("Resources",200))
local FastWait = Resources:LoadLibrary("FastWait")
return {
	["Gun"] = function(CharState,CurrentItem,ViewModel,tween,getAlpha,S,armC0)
		if (CharState.currentState == "Running")  then
			tween("Joint",ViewModel.LWeld, armC0[1], CurrentItem:getArmPos("running","Left"), getAlpha("OutSine"), S.aimSettings.Speed)
			tween("Joint",ViewModel.RWeld, armC0[2], CurrentItem:getArmPos("running","Right"), getAlpha("OutSine"), 0.4)
			tween("Joint",ViewModel.Grips.Right, false, CurrentItem:getArmPos("running","Grip"), getAlpha("OutSine"), 0.4)
		else
			tween("Joint",ViewModel.LWeld, armC0[1], CurrentItem:getArmPos("unAimed","Left"), getAlpha("OutSine"), S.aimSettings.Speed)
			tween("Joint",ViewModel.RWeld, armC0[2], CurrentItem:getArmPos("unAimed","Right"), getAlpha("OutSine"), 0.4)
			tween("Joint",ViewModel.Grips.Right, false, CurrentItem:getArmPos("unAimed","Grip"), getAlpha("OutSine"), 0.4)
		end
		FastWait(0.4)
	end,
}