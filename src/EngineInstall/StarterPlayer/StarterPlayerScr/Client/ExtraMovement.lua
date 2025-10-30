local function getCrawlFrame(CurrentItem, CharState, bipod)
	local cAnim do
		local cString = if typeof(CurrentItem.Settings.stanceSettings.crawlAnimation) == "string" then 
			CurrentItem.Settings.stanceSettings.crawlAnimation else ""
		cAnim = CurrentItem.Animations["Crawling" .. cString]
		if not cAnim then
			cAnim = CurrentItem.Animations.Crawling
		end
	end
	return cAnim(CharState.crawlAng, CharState.moveAng, CharState.walkSpeed, bipod)
end
local function getDiveFrame(CurrentItem, CharState, bipod)
	return CurrentItem.Animations.Skydiving(CharState.crawlAng, CharState.moveAng, CharState.walkSpeed, bipod)
end
local function getClimbFrame(CurrentItem, CharState)
	return CurrentItem.Animations.Climbing(CharState.crawlAng, CharState.moveDirection.Z, _G.ClimbState and _G.ClimbState.ClimbObj:GetAttribute("RungSize") or 2)
end
local function getCrouchWalkFrame(CurrentItem, CharState)
	return CurrentItem.Animations.CrouchWalking(CharState.crawlAng, CharState.moveDirection.Z)
end
local function getSwimFrame(CurrentItem, CharState)
	return CurrentItem.Animations.Swimming(CharState.crawlAng, CharState.moveAng, CharState.walkSpeed)
end
return {
	crawl = {
		Name = "crawl";
		Run = function(API, tdt, dt,  bipod)
			local crawlAnim = getCrawlFrame(API.CurrentItem, API.CharState, bipod)
			API.tween("Joint",API.ViewModel.RWeld,false,crawlAnim.rightArm,API.getAlpha("Smoother"),dt * 10.5)
			API.tween("Joint",API.ViewModel.LWeld,false,crawlAnim.leftArm,API.getAlpha("Smoother"),dt * 10.5)
			API.tween("Joint",API.CharacterJoints.Hips.Left,false,API.stanceCF.leg.C1.Prone[1] * crawlAnim.leftLeg,API.getAlpha("Smoother"),dt * 10.5)
			API.tween("Joint",API.CharacterJoints.Hips.Right,false,API.stanceCF.leg.C1.Prone[2] * crawlAnim.rightLeg,API.getAlpha("Smoother"),dt * 10.5)
			API.tween("Joint",API.ViewModel.Grips.Right,false,crawlAnim.Grip,API.getAlpha("Smoother"),dt * 10.5)
			API.CharState.crawlCamRot = crawlAnim.Camera
			API.CharState.crawlAng = API.CharState.crawlAng + 0.5 * math.rad(105 * dt) * (API.CharacterParts.HRP.Velocity * Vector3.new(1, 0, 1)).magnitude * (1/3)
		end;
		Start = function(API, bipod)
			local tempCrawlAnim = getCrawlFrame(API.CurrentItem, API.CharState, bipod) 
			local startCamRot = API.CharState.crawlCamRot
			local t0 = tick()
			API.Tween.new(0.3, API.getAlpha("Smoother"), "crawlCam", false, function(x)
				API.CharState.crawlCamRot = API.Lerps.number(startCamRot, tempCrawlAnim.Camera, x)
			end)
			API.tween("Joint",API.CharacterJoints.Hips.Left,false,API.stanceCF.leg.C1.Prone[1] *tempCrawlAnim.leftLeg,API.getAlpha("Smoother"),0.3)
			API.tween("Joint",API.CharacterJoints.Hips.Right,false,API.stanceCF.leg.C1.Prone[2] *tempCrawlAnim.rightLeg,API.getAlpha("Smoother"),0.3)
			API.tween("Joint",API.ViewModel.LWeld, false, tempCrawlAnim.leftArm, API.getAlpha("Smoother"), 0.3)
			API.tween("Joint",API.ViewModel.RWeld, false, tempCrawlAnim.rightArm, API.getAlpha("Smoother"), 0.3)
			API.tween("Joint",API.ViewModel.Grips.Right, false, tempCrawlAnim.Grip, API.getAlpha("Smoother"), 0.3)
			API.FastWait(0.3)
		end,
		InCondition = function(CurrentItem, CharState, MotionTransition, Character, Water)
			return CharState.currentState == "Crawling" and (not MotionTransition) and  CurrentItem.Value and (not Water:IsSubmergedPart(Character.PrimaryPart))
		end,
		Active = function(CurrentItem, CharState)
			return CharState.currentState == "Crawling" and CharState.Stance == 2
		end,
		OutCondition = function(CurrentItem, CharState, MotionTransition)
			return CurrentItem.Value
		end
	};
	swim = {
		Name = "swim";
		Run = function(API, tdt, dt)
			local crawlAnim = getSwimFrame(API.CurrentItem, API.CharState)
			API.tween("Joint",API.ViewModel.RWeld,false,crawlAnim.rightArm,API.getAlpha(crawlAnim.Easing or "Smoother"),dt * 20.5)
			API.tween("Joint",API.ViewModel.LWeld,false,crawlAnim.leftArm,API.getAlpha(crawlAnim.Easing or "Smoother"),dt * 20.5)
			API.tween("Joint",API.CharacterJoints.Hips.Left,false,API.stanceCF.leg.C1.Prone[1] * crawlAnim.leftLeg,API.getAlpha(crawlAnim.Easing or "Smoother"),dt * 20.5)
			API.tween("Joint",API.CharacterJoints.Hips.Right,false,API.stanceCF.leg.C1.Prone[2] * crawlAnim.rightLeg,API.getAlpha(crawlAnim.Easing or "Smoother"),dt * 20.5)
			API.tween("Joint",API.ViewModel.Grips.Right,false,crawlAnim.Grip,API.getAlpha(crawlAnim.Easing or "Smoother"),dt * 20.5)
			API.CharState.crawlCamRot = crawlAnim.Camera
			API.CharState.crawlAng = API.CharState.crawlAng + 0.5 * math.rad(105 * dt) * (API.CharacterParts.HRP.Velocity).Magnitude * 0.75
		end;
		Start = function(API)
			local tempCrawlAnim = getSwimFrame(API.CurrentItem, API.CharState) 
			local startCamRot = API.CharState.crawlCamRot
			local t0 = tick()
			API.Tween.new(0.3, API.getAlpha(tempCrawlAnim.Easing or "Smoother"), "crawlCam", false, function(x)
				API.CharState.crawlCamRot = API.Lerps.number(startCamRot, tempCrawlAnim.Camera, x)
			end)
			API.tween("Joint",API.CharacterJoints.Hips.Left,false,API.stanceCF.leg.C1.Prone[1] *tempCrawlAnim.leftLeg,API.getAlpha(tempCrawlAnim.Easing or "Smoother"),0.3)
			API.tween("Joint",API.CharacterJoints.Hips.Right,false,API.stanceCF.leg.C1.Prone[2] *tempCrawlAnim.rightLeg,API.getAlpha(tempCrawlAnim.Easing or "Smoother"),0.3)
			API.tween("Joint",API.ViewModel.LWeld, false, tempCrawlAnim.leftArm, API.getAlpha(tempCrawlAnim.Easing or "Smoother"), 0.3)
			API.tween("Joint",API.ViewModel.RWeld, false, tempCrawlAnim.rightArm, API.getAlpha(tempCrawlAnim.Easing or "Smoother"), 0.3)
			API.tween("Joint",API.ViewModel.Grips.Right, false, tempCrawlAnim.Grip, API.getAlpha(tempCrawlAnim.Easing or "Smoother"), 0.3)
			API.FastWait(0.3)
		end,
		InCondition = function(CurrentItem, CharState, MotionTransition, Character)
			return CharState.currentState == "Swimming" and (not MotionTransition)
		end,
		Active = function(CurrentItem, CharState, Character)
			return CharState.currentState == "Swimming"
		end,
		OutCondition = function(CurrentItem, CharState, MotionTransition, Character)
			return CharState.currentState ~= "Swimming" 
		end,
		Rate = 0.75;
	};
	dive = {
		Name = "dive";
		Run = function(API, tdt, dt)
			local crawlAnim = getDiveFrame(API.CurrentItem, API.CharState)
			API.tween("Joint",API.ViewModel.RWeld,false,crawlAnim.rightArm,API.getAlpha("Smoother"),dt * 10.5)
			API.tween("Joint",API.ViewModel.LWeld,false,crawlAnim.leftArm,API.getAlpha("Smoother"),dt * 10.5)
			API.tween("Joint",API.CharacterJoints.Hips.Left,false,API.stanceCF.leg.C1.Prone[1] * crawlAnim.leftLeg,API.getAlpha("Smoother"),dt * 10.5)
			API.tween("Joint",API.CharacterJoints.Hips.Right,false,API.stanceCF.leg.C1.Prone[2] * crawlAnim.rightLeg,API.getAlpha("Smoother"),dt * 10.5)
			API.tween("Joint",API.ViewModel.Grips.Right,false,crawlAnim.Grip,API.getAlpha("Smoother"),dt * 10.5)
			API.CharState.crawlCamRot = crawlAnim.Camera
			API.CharState.crawlAng = API.CharState.crawlAng + 0.5 * math.rad(105 * dt) * (API.CharacterParts.HRP.Velocity * Vector3.new(1, 0, 1)).magnitude * (1/3)
		end;
		Start = function(API)
			local tempCrawlAnim = getDiveFrame(API.CurrentItem, API.CharState) 
			local startCamRot = API.CharState.crawlCamRot
			local t0 = tick()
			API.Tween.new(0.3, API.getAlpha("Smoother"), "crawlCam", false, function(x)
				API.CharState.crawlCamRot = API.Lerps.number(startCamRot, tempCrawlAnim.Camera, x)
			end)
			API.tween("Joint",API.CharacterJoints.Hips.Left,false,API.stanceCF.leg.C1.Prone[1] *tempCrawlAnim.leftLeg,API.getAlpha("Smoother"),0.3)
			API.tween("Joint",API.CharacterJoints.Hips.Right,false,API.stanceCF.leg.C1.Prone[2] *tempCrawlAnim.rightLeg,API.getAlpha("Smoother"),0.3)
			API.tween("Joint",API.ViewModel.LWeld, false, tempCrawlAnim.leftArm, API.getAlpha("Smoother"), 0.3)
			API.tween("Joint",API.ViewModel.RWeld, false, tempCrawlAnim.rightArm, API.getAlpha("Smoother"), 0.3)
			API.tween("Joint",API.ViewModel.Grips.Right, false, tempCrawlAnim.Grip, API.getAlpha("Smoother"), 0.3)
			API.FastWait(0.3)
		end,
		InCondition = function(CurrentItem, CharState, MotionTransition)
			return CharState.currentState == "Diving" and (not MotionTransition)
		end,
		Active = function(CurrentItem, CharState)
			return CharState.currentState == "Diving" and CharState.Stance == 2
		end,
		OutCondition = function(CurrentItem, CharState, MotionTransition)
			return true
		end,
	};
	climb = {
		Name = "climb";
		Run = function(API, tdt, dt)
			local crawlAnim = getClimbFrame(API.CurrentItem, API.CharState)
			API.tween("Joint",API.ViewModel.RWeld,false,crawlAnim.rightArm,API.getAlpha("Smoother"),dt * 10.5)
			API.tween("Joint",API.ViewModel.LWeld,false,crawlAnim.leftArm,API.getAlpha("Smoother"),dt * 10.5)
			API.tween("Joint",API.CharacterJoints.Hips.Left,false,API.stanceCF.leg.C1.Stand[1] * crawlAnim.leftLeg,API.getAlpha("Smoother"),dt * 10.5)
			API.tween("Joint",API.CharacterJoints.Hips.Right,false,API.stanceCF.leg.C1.Stand[2] * crawlAnim.rightLeg,API.getAlpha("Smoother"),dt * 10.5)
			API.tween("Joint",API.ViewModel.Grips.Right,false,crawlAnim.Grip,API.getAlpha("Smoother"),dt * 10.5)
			API.CharState.crawlCamRot = crawlAnim.Camera
			API.CharState.crawlAng = API.CharState.crawlAng + 0.5 * math.rad(105 * dt) * (API.CharacterParts.HRP.Velocity * Vector3.new(1, 1, 0)).magnitude * (1/3)
		end;
		Start = function(API)
			local tempCrawlAnim = getClimbFrame(API.CurrentItem, API.CharState) 
			local startCamRot = API.CharState.crawlCamRot
			local t0 = tick()
			API.Tween.new(0.3, API.getAlpha("Smoother"), "crawlCam", false, function(x)
				API.CharState.crawlCamRot = API.Lerps.number(startCamRot, tempCrawlAnim.Camera, x)
			end)
			API.tween("Joint",API.CharacterJoints.Hips.Left,false,API.stanceCF.leg.C1.Stand[1] *tempCrawlAnim.leftLeg,API.getAlpha("Smoother"),0.3)
			API.tween("Joint",API.CharacterJoints.Hips.Right,false,API.stanceCF.leg.C1.Stand[2] *tempCrawlAnim.rightLeg,API.getAlpha("Smoother"),0.3)
			API.tween("Joint",API.ViewModel.LWeld, false, tempCrawlAnim.leftArm, API.getAlpha("Smoother"), 0.3)
			API.tween("Joint",API.ViewModel.RWeld, false, tempCrawlAnim.rightArm, API.getAlpha("Smoother"), 0.3)
			API.tween("Joint",API.ViewModel.Grips.Right, false, tempCrawlAnim.Grip, API.getAlpha("Smoother"), 0.3)
			API.FastWait(0.3)
		end,
		End = function(API)
			local tempCrawlAnim = getClimbFrame(API.CurrentItem, API.CharState) 
			local startCamRot = API.CharState.crawlCamRot
			local t0 = tick()
			API.Tween.new(0.3, API.getAlpha("Smoother"), "crawlCam", false, function(x)
				API.CharState.crawlCamRot = API.Lerps.number(startCamRot, tempCrawlAnim.Camera, x)
			end)
			API.tween("Joint",API.CharacterJoints.Hips.Left,false,API.stanceCF.leg.C1.Stand[1] *tempCrawlAnim.leftLeg,API.getAlpha("Smoother"),0.3)
			API.tween("Joint",API.CharacterJoints.Hips.Right,false,API.stanceCF.leg.C1.Stand[2] *tempCrawlAnim.rightLeg,API.getAlpha("Smoother"),0.3)
			API.tween("Joint",API.ViewModel.LWeld, false, tempCrawlAnim.leftArm, API.getAlpha("Smoother"), 0.3)
			API.tween("Joint",API.ViewModel.RWeld, false, tempCrawlAnim.rightArm, API.getAlpha("Smoother"), 0.3)
			API.tween("Joint",API.ViewModel.Grips.Right, false, tempCrawlAnim.Grip, API.getAlpha("Smoother"), 0.3)
			API.FastWait(0.3)
		end,
		InCondition = function(CurrentItem, CharState, MotionTransition)
			return CharState.currentState == "Climbing" and (not MotionTransition) and (CharState.moveDirection.Z ~= 0 or CharState.moveDirection.X ~= 0)
		end,
		Active = function(CurrentItem, CharState)
			return CharState.currentState == "Climbing" and CharState.Stance == 0 and (CharState.moveDirection.Z ~= 0 or CharState.moveDirection.X ~= 0)
		end,
		OutCondition = function(CurrentItem, CharState, MotionTransition)
			return (not _G.ClimbState) or (CharState.moveDirection.Z == 0 and CharState.moveDirection.X == 0)
		end,
	};
	crouchwalk = {
		Name = "crouchwalk";
		Run = function(API, tdt, dt)
			if tdt == 0 then
				local crawlAnim = getCrouchWalkFrame(API.CurrentItem, API.CharState)
				API.tween("Joint",API.CharacterJoints.Hips.Left,false,API.stanceCF.leg.C1.Crouch[1] * crawlAnim.leftLeg,API.getAlpha("Smoother"),0.2)
				API.tween("Joint",API.CharacterJoints.Hips.Right,false,API.stanceCF.leg.C1.Crouch[2] * crawlAnim.rightLeg,API.getAlpha("Smoother"),0.2)
				API.CharState.crawlAng += 1	
			end
		end;
		Start = function(API)
			local tempCrawlAnim = getCrouchWalkFrame(API.CurrentItem, API.CharState) 
			API.tween("Joint",API.CharacterJoints.Hips.Left,false,API.stanceCF.leg.C1.Crouch[1] * tempCrawlAnim.leftLeg,API.getAlpha("Smoother"),0.2)
			API.tween("Joint",API.CharacterJoints.Hips.Right,false,API.stanceCF.leg.C1.Crouch[2] * tempCrawlAnim.rightLeg,API.getAlpha("Smoother"),0.2)
			API.FastWait(0.2)
		end,
		End = function(API)
			local tempCrawlAnim = getCrouchWalkFrame(API.CurrentItem, API.CharState) 
			API.tween("Joint",API.CharacterJoints.Hips.Left,false,API.stanceCF.leg.C1.Crouch[1] * tempCrawlAnim.leftLeg,API.getAlpha("Smoother"),0.2)
			API.tween("Joint",API.CharacterJoints.Hips.Right,false,API.stanceCF.leg.C1.Crouch[2] * tempCrawlAnim.rightLeg,API.getAlpha("Smoother"),0.2)
			API.FastWait(0.2)
		end,
		InCondition = function(CurrentItem, CharState, MotionTransition)
			return CharState.currentState == "CWalking" and (not MotionTransition) and (CharState.moveDirection.Z ~= 0 and CharState.moveDirection.X ~= 0)
		end,
		Active = function(CurrentItem, CharState)
			return CharState.currentState == "CWalking" and CharState.Stance == 1 and (CharState.moveDirection.Z ~= 0 and CharState.moveDirection.X ~= 0)
		end,
		OutCondition = function(CurrentItem, CharState, MotionTransition)
			return CharState.currentState ~= "CWalking" or (CharState.moveDirection.Z == 0 or CharState.moveDirection.X == 0)
		end,
		CanCancelAnim = function()
			return false
		end,
		Rate = 0.2;
	}
}