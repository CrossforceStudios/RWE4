local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Resources = require(ReplicatedStorage:WaitForChild("Resources"))
local Promise = Resources:LoadLibrary("Promise")
local RemoteService = Resources:LoadLibrary("RemoteService")
local FireAnimSequence = {};

local function getFireBehavior(rate,boltSettings,bolts,item,hammerRot,tweenFunc,alpha,alpha2,carryHandleAngle,hammerReset,actionType,ammo,clipSize,cylinder,chKick,chRot)
    return Promise.resolve({
        fireRate = rate;
        staticFire = boltSettings.staticFire or false;
        BoltWelds = bolts or {};
        springOperated = boltSettings.hasSpring or false;
        carryHandle = ((item:FindFirstChild("CarryHandleEffector")) and item:FindFirstChild("CarryHandleEffector"):FindFirstChild("CarryHandleHinge") or false);
        hammer = ((item:FindFirstChild("HammerEffector")) and item:FindFirstChild("HammerEffector"):FindFirstChild("HammerHinge") or false);
        alpha1 = alpha;
        alpha2 = alpha2;
        tween = tweenFunc;
        hammerReset = hammerReset;
        hammerRot = hammerRot;
        boltTime = (boltSettings.Time and boltSettings.Time or ((60/rate)/2));
        boltSettingsKick = boltSettings.Kick or Vector3.new();
        boltSettingsRot = boltSettings.Rot or Vector3.new();
        Reciprocation = boltSettings.Reciprocation or Vector3.new();
        springDimensions = boltSettings.Dimensions;
        carryHandleAngle = carryHandleAngle or false;
        striker = boltSettings.strikerOffset or false;
        actionType = actionType;
		ammo = ammo;
		clipSize = clipSize;
		closeOnRelease = boltSettings.closeBolt or false;
		cylinder = cylinder;
		chBoltKick = chKick;
		chBoltRot = chRot;
    })
end

local function doHammer(info)
    return Promise.new(function(resolve, reject, onCancel)
        
        if info.staticFire then
            reject(info)
        end;
        if info.hammer and info.hammerRot then
            info.tween("Joint",info.hammer,false,CFrame.Angles(unpack(info.hammerRot)),info.alpha1,info.boltTime)
            resolve(info)
        else
            reject(info)
        end
    end)
end

local function doHammerEnd(info)
    return Promise.new(function(resolve, reject, onCancel)
        
        if info.staticFire then
            reject(info)
        end;
        if info.hammer and info.hammerRot then

            info.tween("Joint",info.hammer,false,CFrame.Angles(unpack(info.hammerReset or {0,0,0})),info.alpha1,info.boltTime)
            resolve(info)
        else
            reject(info)
        end
    end)
end

local function doMainBoltEnd(info)
    return Promise.new(function(resolve, reject, onCancel)
 
        if info.staticFire then
            reject(info)
        end;

        if info.BoltWelds["Main"] then
            if (info.actionType == "SemiAuto" and info.ammo <= 0) or (info.closeOnRelease and info.ammo <= 0) then
                info.tween("Bolt","Main",info.boltSettingsKick,info.boltSettingsRot,info.alpha1,info.boltTime)
            else
				info.tween("Bolt","Main",Vector3.new(),Vector3.new(),info.alpha1,info.boltTime)
				if info.BoltWelds["ChargingHandle"] and (info.chBoltKick) then
					info.tween("Bolt","ChargingHandle",Vector3.new(),Vector3.new(),info.alpha1,info.boltTime)
				end
            end
            resolve(info)
        else
            reject(info)
        end
    end)
end



local function doMainBolt(info)
    return Promise.new(function(resolve, reject, onCancel)
        
        if info.staticFire then
            reject(info)
        end;

        if info.BoltWelds["Main"] then
            
			info.tween("Bolt","Main",info.boltSettingsKick,info.boltSettingsRot,info.alpha1,info.boltTime)
			if info.BoltWelds["ChargingHandle"] and (info.chBoltKick) then
				info.tween("Bolt","ChargingHandle",info.chBoltKick,info.chBoltRot,info.alpha1,info.boltTime)
			end
            resolve(info)
        else
            reject(info)
        end
    end)
end

local function doReciprocator(info)
    return Promise.new(function(resolve, reject, onCancel)
   
        if info.staticFire then
            reject(info)
        end;

        if info.BoltWelds["Reciprocator"] and info.Reciprocation then
            info.tween("Bolt","Reciprocator",info.Reciprocation.Kick,info.Reciprocation.Rot,info.alpha1,info.boltTime)
            resolve(info)
        else
            reject(info)
        end
    end)
end


local function doReciprocatorEnd(info)
    return Promise.new(function(resolve, reject, onCancel)

        if info.staticFire then
            reject(info)
        end;

        if info.BoltWelds["Reciprocator"] and info.Reciprocation then
            info.tween("Bolt","Reciprocator",Vector3.new(),Vector3.new(),info.alpha1,info.boltTime)
            resolve(info)
        else
            reject(info)
        end
    end)
end

local function doSpring(info)
    return Promise.new(function(resolve, reject, onCancel)

        if info.staticFire then
            reject(info)
        end;

        if info.springOperated then
            info.tween("BoltSpring",info.springDimensions.Sections + (info.springDimensions.Sections * (info.springDimensions.Direction/1)),info.springDimensions,info.springDimensions.Sections,info.boltTime)
            resolve(info)
        else
            reject(info)
        end
    end)
end

local function doSpringEnd(info)
    return Promise.new(function(resolve, reject, onCancel)
       
        if info.staticFire then
            reject(info)
        end;

        if info.springOperated then
            info.tween("BoltSpring",info.springDimensions.Sections + 0,info.springDimensions,info.springDimensions.Sections,info.boltTime)
            resolve(info)
        else
            reject(info)
        end
    end)
end

local function doCarryHandle(info)
    return Promise.new(function(resolve, reject, onCancel)
     
        if info.staticFire then
            reject(info)
        end;

        if info.carryHandle and info.carryHandleAngle then
            info.tween("Joint",info.carryHandle,nil,CFrame.Angles(math.rad(info.carryHandleAngle),0,0),info.alpha2,info.boltTime)
            resolve(info)
        else
            reject(info)
        end
    end)
end

local function doCarryHandleEnd(info)
    return Promise.new(function(resolve, reject, onCancel)
    
        if info.staticFire then
            reject(info)
        end;

        if info.carryHandle and info.carryHandleAngle then
            info.tween("Joint",info.carryHandle,nil,CFrame.Angles(0,0,0),info.alpha2,info.boltTime)
            resolve(info)
        else
            reject(info)
        end
    end)
end

local function doCylinderEnd(info)
	return Promise.new(function(resolve, reject, onCancel)

		if info.staticFire then
			reject(info)
		end;
		if info.cylinder then
			info.tween("Joint",info.cylinder.CylinderHingeMotor,nil,CFrame.Angles(
				math.rad(-(360/info.clipSize) * ((info.clipSize - info.ammo) + 1)),
				0,
				0
			),info.alpha2,info.boltTime)
			resolve(info)
		else
			reject(info)
		end
	end)
end

local function doStriker(info)
    return Promise.new(function(resolve, reject, onCancel)

        if not info.staticFire then
            reject(info)
        end;

        if info.striker then
            info.tween("Bolt","Striker",info.striker,Vector3.new(),info.alpha1,info.boltTime * 2)
            resolve(info)
        else
            reject(info)
        end
    end)
end

local function doStrikerEnd(info)
    return Promise.new(function(resolve, reject, onCancel)
    
        if not info.staticFire then
            reject(info)
        end;

        if info.striker then
            info.tween("Bolt","Striker",Vector3.new(),Vector3.new(),info.alpha1,info.boltTime * 2)
            resolve(info)
        else
            reject(info)
        end
    end)
end

local function useWait(waitF)
    return Promise.promisify(waitF)
end



local helpers = {
    hammer = doHammer;
    striker = doStriker;
    carryhandle = doCarryHandle;
    reciprocator = doReciprocator;
    bolt = doMainBolt;
    spring = doSpring;
    hammerend = doHammerEnd;
    strikerend = doStrikerEnd;
    carryhandleend = doCarryHandleEnd;
    reciprocatorend = doReciprocatorEnd;
    boltend = doMainBoltEnd;
    springend = doSpringEnd;

}

function FireAnimSequence:RunFinalSequence(waitF,list,args)
    local waitFunc = useWait(waitF)
    local promise = getFireBehavior(unpack(args))
    promise = promise:andThen(function(info)
        return waitFunc(info.boltTime)
    end)
    for _, v in ipairs(list) do
        local f = helpers[v:lower()];
        if f then
            promise = promise:andThen(f)
        end
    end
    return promise
end


function FireAnimSequence:MuzzleFlash(info, args)
	return Promise.new(function(resolve, reject, onCancel)
		RemoteService.sendU("Server","MuzzleFlashServer",unpack(args))
		resolve(info)
	end)
end

function FireAnimSequence:RunSequence(list,args)
    local promise = getFireBehavior(unpack(args))
    for _, v in ipairs(list) do
        local f = helpers[v:lower()]
        if f then
            promise = promise:andThen(f)
        end
    end
    return promise
end


return FireAnimSequence 
    
