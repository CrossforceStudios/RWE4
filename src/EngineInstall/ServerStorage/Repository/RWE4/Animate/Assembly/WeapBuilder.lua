local WeapBuilder = {}
local Resources = require(game.ReplicatedStorage.Resources)
local inList = Resources:LoadLibrary("inList")
local evalAndListCondition = Resources:LoadLibrary("AndList")
local CollectionService = game:GetService("CollectionService")
local SMT = setmetatable
function WeapBuilder.new(...)
    local args = {...}
    local Type = args[1]
    local WeldedParts = args[2]
    local Weapon = nil;
    local S = nil;
    local LMGPartList = {
        "LidHinge";
        "Lid";
        "LidPart";
        "LidPartMainSight";
        "LidPartMainReticle";
        "LidLeverEffector";
        "LidLeverHinge";
        "LidLever";
        
    }
    local MedpackOpeners = {
        "CaseHinge";
        "CaseLid";
        "CaseLidPart";	
    }
    local LMGFeedPartPartList = {
        "FeedingTrayHinge";
        "FeedingTray";
        "FeedingLatch";
    }
        
    local RevolverPartList = {
        "EjectionRod";
        "CarouselCylinder";
        "CylinderHinge";
        "CylinderUnitHinge";
        "DumpPart";
        "EjectionRodSlide";
    };
    local HammerPartList = {
        "Hammer";
        "HammerHinge";
        "HammerPart";
    };
    local AdjustableSightParts = {
        "MainSightHinge";
        "MainSightTurntable";
        "MainSightLeaf";
        "MainSightLeafPart"
    }
    local BeltFeedParts = {
        "BeltFeed";
        "BeltFeedHinge";
    }
    local PumpActionShotgunPartList = {
        "Pump";
    }
    local StockParts = {
        "StockMain";
        "Stock";
        "StockPart";
        "SlideStock";
        "AltStockSlide";
        "SlideStockPart";
        "CheekRest";
    }
    local BipodPartList = {
        "BipodYHinge";
        "BipodLeftHinge";
        "RightBipodHinge";
        "LeftBipodPart";
        "BipodLeftEffector";
        "BipodRightEffector";
        "RightBipodPart";
        "BipodMountPart";
    };
    local BipodPartList2 = {
        "RightBipodHinge";
        "LeftBipodPart";
        "RightBipodPart";
        "LeftBipodHinge";
        "RightBipodLeg";
        "LeftBipodLeg";
    };		
    local monopodParts = {
        "Monopod";
    };		
    local grenadeParts = {
        "Lever";
        "SafetyPin";
    }
    local SelectFireParts = {
        "FireModeSwitch";	
        "SelectorHinge";
        "SafetyHinge";
        "SafetySwitch";
        "SafetySwitchTab";
        "SelectFireTab";
    }
    local TriggerParts = {
        "TriggerHinge";
        "TriggerSear";
        "Trigger";	
    }
    local EjectionCoverParts = {
        "CoverHinge";
        "EjectionCover";
    }
    local PaddleReleaseParts = {
        "PaddleReleaseHinge";
        "PaddleRelease";
    }
    local ReceiverParts = {
        "Receiver";
        "ReceiverHinge";
    };
    local GateParts = {
        "GateHinge";
        "LoadingGate";
    };
    local CarryHandleParts = {
        "CarryHandleHinge";
        "CarryHandle";
        "CarryHandlePart";
    }		
    local BarrelSwapParts = {
         "BarrelSwapHinge";
         "BarrelSwapLever";
}
local BarrelReleaseParts = {
    "BarrelReleaseHinge";
    "BarrelRelease";
}
local EjectorParts = {
    "EjectorBottom";
    "EjectorTop";
};
local BayonetBladeParts = {
    "BayonetHinge";
    "BayonetBlade";
    "BayonetPart";
};
local FAParts = {
    "ForwardAssistButton";
};

local function isFAPart(v)
    return (Weapon:FindFirstChild("ForwardAssistBase") and not inList(v.Name,FAParts)) or (not Weapon:FindFirstChild("ForwardAssistBase"))
end
    local function isGrenadePart(v)
        return ((Weapon.Type.Value == "Grenade") and not inList(v.Name,grenadeParts) or (Weapon.Type.Value ~= "Grenade"))
    end
    local function isMainSightPart(v)
        return ((S.boltSettings.weldMainSight) and (v.Name ~= "MainSight") or (not S.boltSettings.weldMainSight)) 
    end
    local function isAdjustableSightPart(v)
        return ((S.sightAdjustmentType) and not inList(v.Name,AdjustableSightParts) or (not S.sightAdjustmentType))
    end
    local function isPumpActionShotgunPart(v)
    return (Weapon:FindFirstChild("PumpPart")) and not inList(v.Name,PumpActionShotgunPartList) or (not Weapon:FindFirstChild("PumpPart"))
    end
    local function isRevolverPart(v)
        return (Weapon.GunType.Value == "Revolver" and not inList(v.Name,RevolverPartList)) or (not (Weapon.GunType.Value == "Revolver"))
    end
    local function isLMGPart(v)
        return (inList(Weapon.GunType.Value,{"GPMG";"LMG"}) and (not inList(v.Name,LMGPartList)) or (not inList(Weapon.GunType.Value,{"GPMG";"LMG"})))
    end
    local function isStockPart(v)
        return ((S.initialStockType) and (not inList(v.Name,StockParts)) or (not S.initialStockType))
    end
    local function isBipodPart(v)
        return ((Weapon:FindFirstChild("BipodMain") and not inList(v.Name,BipodPartList)) or (not Weapon:FindFirstChild("BipodMain")))
    end
    local function isBipodPart2(v)
        return ((Weapon:FindFirstChild("LeftBipodEffector") and not inList(v.Name,BipodPartList2)) or (not Weapon:FindFirstChild("LeftBipodEffector")))
    end		
    local function isBeltFeedPart(v)
        return ((Weapon:FindFirstChild("BeltFeed")) and not inList(v.Name,BeltFeedParts) or (not Weapon:FindFirstChild("BeltFeed")))
    end
    local function isMonopodPart(v)
        return (Weapon:FindFirstChild("MonopodSlide") and not inList(v.Name,monopodParts) or (not Weapon:FindFirstChild("MonopodSlide")))
    end		
    local function isEjectionCoverPart(v)
        return (Weapon:FindFirstChild("EjectionCover") and not inList(v.Name,EjectionCoverParts) or (not Weapon:FindFirstChild("EjectionCover")))
    end		
    local function isHammerPart(v)
        return (((Weapon.GunType.Value == "Revolver") or S.usesHammer) and not inList(v.Name,HammerPartList)) or (not ((Weapon.GunType.Value == "Revolver") or S.usesHammer))
    end		
    local function isTriggerPart(v)
        return (((Weapon:FindFirstChild("TriggerHinge"))) and not inList(v.Name,TriggerParts)) or (not ((Weapon:FindFirstChild("TriggerHinge"))))
    end			
    local function isPaddleReleasePart(v)
        return (((Weapon:FindFirstChild("PaddleReleaseHinge"))) and not inList(v.Name,PaddleReleaseParts)) or (not ((Weapon:FindFirstChild("PaddleReleaseHinge"))))
    end		
    local function isReceiverPart(v)
        return (((Weapon:FindFirstChild("ReceiverHinge"))) and not inList(v.Name,ReceiverParts)) or (not ((Weapon:FindFirstChild("ReceiverHinge"))))
    end	
    local function isFeedTrayPart(v)
        return (((Weapon:FindFirstChild("FeedingTrayEffector"))) and not inList(v.Name,LMGFeedPartPartList)) or (not ((Weapon:FindFirstChild("FeedingTrayEffector"))))
    end		
    local function isCarryHandlePart(v)
        return (((Weapon:FindFirstChild("CarryHandleEffector"))) and not inList(v.Name,CarryHandleParts)) or (not ((Weapon:FindFirstChild("CarryHandleEffector"))))
    end		
    local function isBarrelSwapPart(v)
        return (((Weapon:FindFirstChild("BarrelSwapEffector"))) and not inList(v.Name,CarryHandleParts)) or (not ((Weapon:FindFirstChild("BarrelSwapEffector"))))
    end;			
    local function isBarrelReleaseHinge(v)
        return (((Weapon:FindFirstChild("BarrelReleaseHinge"))) and not inList(v.Name, BarrelReleaseParts) or (not (Weapon:FindFirstChild("BarrelReleaseHinge"))))
    end
    local function isGatePart(v)
        return (((Weapon:FindFirstChild("LoadingGate"))) and not inList(v.Name, GateParts) or (not (Weapon:FindFirstChild("LoadingGate"))))
    end		
    local function isEjectorPart(v)
        return (((Weapon:FindFirstChild("EjectorSlide"))) and not inList(v.Name, EjectorParts) or (not (Weapon:FindFirstChild("EjectorSlide"))))
    end	
    local function isBayonetPart(v)
        return (((Weapon:FindFirstChild("BayonetEffector"))) and not inList(v.Name, BayonetBladeParts) or (not (Weapon:FindFirstChild("BayonetEffector"))))
    end	
    return SMT({
        isSpecialPart = function(self,part)
            if Type == "Gun" then
                return evalAndListCondition({
                    (not self:isAttachmentAimPart(part));
                    (part.Name ~= "Bolt");
                    (part.Name ~= "BoltPart");
                    (part.Name ~= "BoltEffector");
                    (part.Name ~= "BoltSpring");
                    (part.Name ~= "BoltHead");
                    (part.Name ~= "BoltFiringPin");
                    (not inList(part.Name,SelectFireParts));
                    isLMGPart(part);
                    isPumpActionShotgunPart(part);
                    isRevolverPart(part);
                    isHammerPart(part);
                    isStockPart(part);
                    isBipodPart(part);
                    isBipodPart2(part);
                    isMainSightPart(part);
                    isBeltFeedPart(part);
                    isAdjustableSightPart(part);
                    isMonopodPart(part);
                    isEjectionCoverPart(part);
                    isTriggerPart(part);
                    isPaddleReleasePart(part);
                    isReceiverPart(part);
                    isFeedTrayPart(part);
                    isCarryHandlePart(part);
                    isBarrelSwapPart(part);
                    isBarrelReleaseHinge(part);
                    isGatePart(part);
                    isEjectorPart(part);
                    isBayonetPart(part);
                })
            elseif Type == "Launcher" then
                return evalAndListCondition({
                    (not self:isAttachmentAimPart(part));
                    (part.Name ~= "Bolt");
                    (part.Name ~= "BoltPart");
                    (part.Name ~= "BoltEffector");
                    (not inList(part.Name,SelectFireParts));
                    isStockPart(part);
                    isBipodPart(part);
                    isMainSightPart(part);
                    isAdjustableSightPart(part);
                    isMonopodPart(part);
                    isEjectionCoverPart(part);
                })
            elseif Type == "Grenade" then
                return evalAndListCondition({
                    isGrenadePart(part)
                })
            elseif Type == "Role" then
                return evalAndListCondition({
                    part.Name ~= "CrateCover";
                    not inList(part.Name,MedpackOpeners);
                })
            elseif Type == "Melee" then
                return true;				
            elseif Type == "Bomb" then
                return part.Name ~= "Slide";
            end
        end;
        isAttachmentAimPart = function(_,part)
                return CollectionService:HasTag(part,"AimPart_Custom")
        end;
    },
    {
        __index = function(self,k)
            local key = k:lower()
            if key == "weldedparts" then
                return WeldedParts;
            elseif key == "type" then
                return Type;
            elseif key == "weapon" then
                return Weapon
            elseif key == "s" then
                return S
            end
        end;
        __newindex = function(self,k,v)
            local key  = k:lower()
            if key == "weapon" then
                Weapon = v
                if Weapon:FindFirstChild("SETTINGS") then
                    S = require(Weapon.SETTINGS)
                end
            end
        end
    })
end
return WeapBuilder