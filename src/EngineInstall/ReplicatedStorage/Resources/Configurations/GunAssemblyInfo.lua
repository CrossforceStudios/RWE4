-- Configures necessary joints for weapons to function.
return {
	Specials = {
		{
			PartName = "Bolt";
			Condition = function(item: Model,part: BasePart,  Settings: any)
				return part:FindFirstChild("BoltRole") 
			end,
			OnAssemble = function(item: Model,part: BasePart,join,addBolt,Settings,findBolt)
				part.Anchored = true
				part.CanCollide = false
				local be = item:FindFirstChild("BoltEffector")
				local role = part.BoltRole.Value
				if be then
					do
						for _, v in item:GetChildren() do
							if v.Name == "BoltEffector" then
								if v:FindFirstChild("BoltRole") then
									if v.BoltRole.Value == role then
										be = v
										break
									end
								end
							end
						end
					end
				end
				addBolt(part,item.SlidePart,be)	
			end,
		};
		{
			PartName = "MainSight";
			Condition = function(item: Model, part: BasePart, Settings: any)
				return Settings.boltSettings.weldMainSight
			end,
			OnAssemble = function(item: Model, part: BasePart,join,addBolt,Settings,findBolt)
					local sightWeld = join("Assemble",findBolt(item,"Main"),part,CFrame.new(),"SightWeld")
					part.Anchored = false
			end,
		};
		{
			PartName = "NightDot";
			Condition = function(item: Model, part: BasePart, Settings: any)
				return Settings.boltSettings.weldMainSight
			end,
			OnAssemble = function(item: Model, part: BasePart,join,addBolt,Settings,findBolt)
				local sightWeld = join("Assemble",findBolt(item,"Main"),part,CFrame.new(),"SightWeld")
				part.Anchored = false
			end,
		};
		{
			PartName = "FrontPost";
			Condition = function(item: Model, part: BasePart, Settings: any)
				return Settings.boltSettings.weldMainSight
			end,
			OnAssemble = function(item: Model, part: BasePart,join,addBolt,Settings,findBolt)
				local sightWeld = join("Assemble",findBolt(item,"Main"),part,CFrame.new(),"SightWeld")
				part.Anchored = false
			end,
		};
		{
			PartName = "BoltEffector";
			Condition = function(item: Model, part: BasePart,  Settings: any)
				return true;
			end,
			OnAssemble = function(item: Model, part: BasePart, join, addBolt, Settings, findBolt)
				part.Anchored = true
				local w = join("Assemble",item.SlidePart,part,CFrame.new(),"BoltEWeld")					
				part.Anchored = false
			end,
		};
		{
			PartName = "BoltSpring";
			Condition = function(item: Model, part: BasePart,  Settings: any)
				return true;
			end,
			OnAssemble = function(item: Model, part: BasePart, join, addBolt, Settings, findBolt)
				part.Anchored = true
				local originalSize = Instance.new("Vector3Value")
				originalSize.Name = "OriginalSize"
				originalSize.Value = part.Size
				originalSize.Parent = part
				local w = join("AssembleParent",item:FindFirstChild("BoltSpringSlide") or item:FindFirstChild("SlidePart"),part,CFrame.new(),part,"SpringPistonJoint")					
				part.Anchored = false	
			end,
		};
		{
			PartName = "BoltPart";
			Condition = function(item: Model, part: BasePart,  Settings: any)
				return part:FindFirstChild("BoltRole");
			end,
			OnAssemble = function(item: Model, part: BasePart, join, addBolt, Settings, findBolt)
				part.CanCollide = false
				local weld = join("Assemble",findBolt(item,part.BoltRole.Value),part,CFrame.new(),"BoltAttachment")					
				part.Anchored = false
			end,
		};
		{
			PartName = "BoltFiringPin";
			Condition = function(item: Model, part: BasePart,  Settings: any)
				return part:FindFirstChild("BoltRole");
			end,
			OnAssemble = function(item: Model, part: BasePart, join, addBolt, Settings, findBolt)
				part.CanCollide = false
				local weld = join("Assemble",findBolt(item,part.BoltRole.Value),part,CFrame.new(),"BoltPinSlide")					
				part.Anchored = false
			end,
		};
		{
			PartName = "BoltHead";
			Condition = function(item: Model, part: BasePart,  Settings: any)
				return part:FindFirstChild("BoltRole");
			end,
			OnAssemble = function(item: Model, part: BasePart, join, addBolt, Settings, findBolt)
				part.CanCollide = false
				local weld = join("Assemble",findBolt(item,part.BoltRole.Value),part,CFrame.new(),"BoltHeadSlide")					
				part.Anchored = false
			end,
		};
		{
			PartName = "LidPart";
			Condition = function(item: Model, part: BasePart,  Settings: any, subType: string)
				return table.find({"GPMG";"LMG";"SAW";}, subType)
			end,
			OnAssemble = function(item: Model, part: BasePart, join, addBolt, Settings, findBolt)
				part.CanCollide = false
				local weld = join("Assemble",item.Lid,part,CFrame.new(),"LidAttachment")					
				part.Anchored = false
			end,
		};
		{
			PartName = "LidPartMainSight";
			Condition = function(item: Model, part: BasePart,  Settings: any, subType: string)
				return table.find({"GPMG";"LMG";"SAW";}, subType)
			end,
			OnAssemble = function(item: Model, part: BasePart, join, addBolt, Settings, findBolt)
				part.CanCollide = false
				local weld = join("Assemble",item.Lid,part,CFrame.new(),"LidAttachment")					
				part.Anchored = false
			end,
		};
		{
			PartName = "LidPartMainReticle";
			Condition = function(item: Model, part: BasePart,  Settings: any, subType: string)
				return table.find({"GPMG";"LMG";"SAW";}, subType)
			end,
			OnAssemble = function(item: Model, part: BasePart, join, addBolt, Settings, findBolt)
				part.CanCollide = false
				local weld = join("Assemble",item.LidPartMainSight,part,CFrame.new(),"LidAttachment")					
				part.Anchored = false
			end,
		};
		{
			PartName = "FeedingTrayHinge";
			Condition = function(item: Model, part: BasePart,  Settings: any,  subType: string)
				return table.find({"GPMG";"LMG";"SAW";},  subType)
			end,
			OnAssemble = function(item: Model, part: BasePart, join, addBolt, Settings, findBolt)
				part.CanCollide = false
				local weld = join("Assemble",item.FeedingTrayEffector,part,CFrame.new(),"FeedHinge")					
				part.Anchored = false
			end,
		};
		{
			PartName = "FeedingTray";
			Condition = function(item: Model, part: BasePart,  Settings: any,  subType: string)
				return table.find({"GPMG";"LMG";"SAW";}, subType)
			end,
			OnAssemble = function(item: Model, part: BasePart, join, addBolt, Settings, findBolt)
				part.CanCollide = false
				local weld = join("Assemble",item.FeedingTrayHinge,part,CFrame.new(),"FeedTrayAttachment")					
				part.Anchored = false
			end,
		};
		{
			PartName = "FeedLatch";
			Condition = function(item: Model, part: BasePart,  Settings: any,  subType: string)
				return table.find({"GPMG";"LMG";"SAW";}, subType)
			end,
			OnAssemble = function(item: Model, part: BasePart, join, addBolt, Settings, findBolt)
				part.CanCollide = false
				local weld = join("Assemble",item.FeedingTray,part,CFrame.new(),"FeedTrayAttachment")					
				part.Anchored = false
			end,
		};
		{
			PartName = "LidLeverEffector";
			Condition = function(item: Model, part: BasePart,  Settings: any,  subType: string)
				return table.find({"GPMG";"LMG";"SAW";}, subType)
			end,
			OnAssemble = function(item: Model, part: BasePart, join, addBolt, Settings, findBolt)
				part.CanCollide = false
				local weld = join("Assemble",item.Lid,part,CFrame.new(),"LREAttachment")					
				part.Anchored = false
			end,
		};
		{
			PartName = "LidLeverHinge";
			Condition = function(item: Model, part: BasePart,  Settings: any,  subType: string)
				return table.find({"GPMG";"LMG";"SAW";}, subType)
			end,
			OnAssemble = function(item: Model, part: BasePart, join, addBolt, Settings, findBolt)
				part.CanCollide = false
				local weld = join("Assemble",item.LidLeverEffector,part,CFrame.new(),"LidReleaseHinge")					
				part.Anchored = false
			end,
		};
		{
			PartName = "LidLever";
			Condition = function(item: Model, part: BasePart,  Settings: any,  subType: string)
				return table.find({"GPMG";"LMG";"SAW";}, subType)
			end,
			OnAssemble = function(item: Model, part: BasePart, join, addBolt, Settings, findBolt)
				part.CanCollide = false
				local weld = join("Assemble",item.LidLeverHinge,part,CFrame.new(),"LidReleaseAttachment")					
				part.Anchored = false
			end,
		};
		{
			PartName = "LidHinge";
			Condition = function(item: Model, part: BasePart,  Settings: any,  subType: string)
				return table.find({"GPMG";"LMG";"SAW";}, subType)
			end,
			OnAssemble = function(item: Model, part: BasePart, join, addBolt, Settings, findBolt)
				part.CanCollide = false
				local weld = join("Assemble",item.LidEffector,part,CFrame.new(),"LidHinge")					
				part.Anchored = false
			end,
		};
		{
			PartName = "Lid";
			Condition = function(item: Model, part: BasePart,  Settings: any,  subType: string)
				return table.find({"GPMG";"LMG";"SAW";}, subType)
			end,
			OnAssemble = function(item: Model, part: BasePart, join, addBolt, Settings, findBolt)
				part.CanCollide = false
				local weld = join("Assemble",item.LidHinge,part,CFrame.new(),"LidAttachment")					
				part.Anchored = false
			end,
		};
		{
			PartName = "BipodMountPart";
			Condition = function(item: Model, part: BasePart,  Settings: any)
				return item:FindFirstChild("BipodMain")
			end,
			OnAssemble = function(item: Model, part: BasePart, join, addBolt, Settings, findBolt)
				part.CanCollide = false
				local weld = join("Assemble",item.BipodMain,part,CFrame.new(),"MountWeld")					
				part.Anchored = false
			end,
		};
		{
			PartName = "BipodYHinge";
			Condition = function(item: Model, part: BasePart,  Settings: any)
				return item:FindFirstChild("BipodMain")
			end,
			OnAssemble = function(item: Model, part: BasePart, join, addBolt, Settings, findBolt)
				local YHinge = join("Assemble",item.BipodMain,part,CFrame.Angles(Settings.bipodSwingX or 0,(Settings.bipodSwingY or math.rad(75)),0),"BipodVertHinge")
				part.Anchored = false
			end,
		};
		{
			PartName = "BipodHinge";
			Condition = function(item: Model, part: BasePart,  Settings: any)
				return item:FindFirstChild("BipodEffector")
			end,
			OnAssemble = function(item: Model, part: BasePart, join, addBolt, Settings, findBolt)
				local YHinge = join("Assemble",item.BipodEffector,part,CFrame.Angles(0,(Settings.bipodSwingY or math.rad(75)),0),"BipodHinge")
				part.Anchored = false
			end,
		};
		{
			PartName = "BipodPart";
			Condition = function(item: Model, part: BasePart,  Settings: any)
				return item:FindFirstChild("BipodYHinge")
			end,
			OnAssemble = function(item: Model, part: BasePart, join, addBolt, Settings, findBolt)
				local YHinge = join("Assemble",item.BipodYHinge,part,CFrame.Angles(0,(Settings.bipodSwingY or math.rad(75)),0),"BipodHinge")
				part.Anchored = false
			end,
		};
		{
			PartName = "Bipod";
			Condition = function(item: Model, part: BasePart,  Settings: any)
				return item:FindFirstChild("BipodHinge")
			end,
			OnAssemble = function(item: Model, part: BasePart, join, addBolt, Settings, findBolt)
				local YHinge = join("Assemble",item.BipodHinge,part,CFrame.new(),"BipodAttachment")
				part.Anchored = false
			end,
		};
		{
			PartName = "LeftBipodPart";
			Condition = function(item: Model, part: BasePart,  Settings: any)
				return item:FindFirstChild("BipodMain")
			end,
			OnAssemble = function(item: Model, part: BasePart, join, addBolt, Settings, findBolt)
				local YHinge = join("Assemble",item.BipodLeftHinge,part,CFrame.new(),"BipodLegWeld")
				part.Anchored = false

			end,
		};
		{
			PartName = "BipodLeftEffector";
			Condition = function(item: Model, part: BasePart,  Settings: any)
				return item:FindFirstChild("BipodMain")
			end,
			OnAssemble = function(item: Model, part: BasePart, join, addBolt, Settings, findBolt)
				local YHinge = join("Assemble",item.BipodYHinge,part,CFrame.new(),"BipodLeftEffectorWeld")
				part.Anchored = false
			end,
		};
		{
			PartName = "BipodLeftHinge";
			Condition = function(item: Model, part: BasePart,  Settings: any)
				return item:FindFirstChild("BipodMain")
			end,
			OnAssemble = function(item: Model, part: BasePart, join, addBolt, Settings, findBolt)
				local YHinge = join("Assemble",item.BipodLeftEffector,part,CFrame.new(),"BipodLeftWeld")
				part.Anchored = false
			end,
		};
		{
			PartName = "RightBipodPart";
			Condition = function(item: Model, part: BasePart,  Settings: any)
				return item:FindFirstChild("BipodMain")
			end,
			OnAssemble = function(item: Model, part: BasePart, join, addBolt, Settings, findBolt)
				local YHinge = join("Assemble",item.RightBipodHinge,part,CFrame.new(),"BipodLegWeld")
				part.Anchored = false
			end,
		};
		{
			PartName = "BipodRightEffector";
			Condition = function(item: Model, part: BasePart,  Settings: any)
				return item:FindFirstChild("BipodMain")
			end,
			OnAssemble = function(item: Model, part: BasePart, join, addBolt, Settings, findBolt)
				local YHinge = join("Assemble",item.BipodYHinge,part,CFrame.new(),"BipodRightEffectorWeld")
				part.Anchored = false
				
			end,
		};
		{
			PartName = "RightBipodHinge";
			Condition = function(item: Model, part: BasePart,  Settings: any)
				return item:FindFirstChild("BipodMain")
			end,
			OnAssemble = function(item: Model, part: BasePart, join, addBolt, Settings, findBolt)
				local YHinge = join("Assemble",item.BipodRightEffector,part,CFrame.new(),"BipodRightWeld")
				part.Anchored = false
			end,
		};
		{
			PartName = "RightBipodLeg";
			Condition = function(item: Model, part: BasePart,  Settings: any)
				return item:FindFirstChild("RightBipodEffector")
			end,
			OnAssemble = function(item: Model, part: BasePart, join, addBolt, Settings, findBolt)
				local YHinge = join("Assemble",item.RightBipodHinge,part,CFrame.new(),"BipodLegWeld")
				part.Anchored = false
			end,
		};
		{
			PartName = "LeftBipodHinge";
			Condition = function(item: Model, part: BasePart,  Settings: any)
				return item:FindFirstChild("LeftBipodEffector")
			end,
			OnAssemble = function(item: Model, part: BasePart, join, addBolt, Settings, findBolt)
				local YHinge = join("Assemble",item.LeftBipodEffector,part,CFrame.new(),"BipodLeftWeld")
				part.Anchored = false
			end,
		};
		{
			PartName = "LeftBipodPart";
			Condition = function(item: Model, part: BasePart,  Settings: any)
				return item:FindFirstChild("LeftBipodLeg")
			end,
			OnAssemble = function(item: Model, part: BasePart, join, addBolt, Settings, findBolt)
				local YHinge = join("Assemble",item.LeftBipodLeg,part,CFrame.new(),"BipodLegWeld")
				part.Anchored = false
			end,
		};
		{
			PartName = "RightBipodPart";
			Condition = function(item: Model, part: BasePart,  Settings: any)
				return item:FindFirstChild("RightBipodLeg")
			end,
			OnAssemble = function(item: Model, part: BasePart, join, addBolt, Settings, findBolt)
				local YHinge = join("Assemble",item.RightBipodLeg,part,CFrame.new(),"BipodLegW")
				part.Anchored = false
			end,
		};
		{
			PartName = "LeftBipodLeg";
			Condition = function(item: Model, part: BasePart,  Settings: any)
				return item:FindFirstChild("LeftBipodEffector")
			end,
			OnAssemble = function(item: Model, part: BasePart, join, addBolt, Settings, findBolt)
				local YHinge = join("Assemble",item.LeftBipodHinge,part,CFrame.new(),"BipodLegW")
				part.Anchored = false
			end,
		};
		{
			PartName = "RightBipodHinge";
			Condition = function(item: Model, part: BasePart,  Settings: any)
				return item:FindFirstChild("RightBipodEffector")
			end,
			OnAssemble = function(item: Model, part: BasePart, join, addBolt, Settings, findBolt)
				local YHinge = join("Assemble",item.RightBipodEffector,part,CFrame.new(),"BipodRightWeld")
				part.Anchored = false
			end,
		};
		{
			PartName = "Pump";
			Condition = function(item: Model, part: BasePart,  Settings: any)
				return true
			end,
			OnAssemble = function(item: Model, part: BasePart, join, addBolt, Settings, findBolt)
				local YHinge = join("Assemble",item.PumpPart,part,CFrame.new(),"PumpSlide")
				part.Anchored = false
			end,
		};
		{
			PartName = "CylinderHinge";
			Condition = function(item: Model, part: BasePart,  Settings: any,  subType: string)
				return subType == "Revolver"
			end,
			OnAssemble = function(item: Model, part: BasePart, join, addBolt, Settings, findBolt)
				local YHinge = join("Assemble",item.CylinderEffector,part,CFrame.new(),"CylinderHingeMotor")
				part.Anchored = false
			end,
		};
		{
			PartName = "CarouselCylinder";
			Condition = function(item: Model, part: BasePart,  Settings: any,  subType: string)
				return subType == "Revolver"
			end,
			OnAssemble = function(item: Model, part: BasePart, join, addBolt, Settings, findBolt)
				local YHinge = join("Assemble",item.CylinderHinge,part,CFrame.new(),"CylinderAttachment")
				part.Anchored = false
			end,
		};
		{
			PartName = "CylinderUnitHinge";
			Condition = function(item: Model, part: BasePart,  Settings: any,  subType: string)
				return subType == "Revolver"
			end,
			OnAssemble = function(item: Model, part: BasePart, join, addBolt, Settings, findBolt)
				local YHinge = join("Assemble",item.CylinderUnitEffector,part,CFrame.new(),"CylinderUHingeMotor")
				part.Anchored = false
			end,
		};
		{
			PartName = "EjectionRodSlide";
			Condition = function(item: Model, part: BasePart,  Settings: any,  subType: string)
				return subType == "Revolver"
			end,
			OnAssemble = function(item: Model, part: BasePart, join, addBolt, Settings, findBolt)
				local YHinge = join("Assemble",item.CarouselCylinder,part,CFrame.new(),"EjectionRodWeld")
				part.Anchored = false
			end,
		};
		{
			PartName = "EjectionRod";
			Condition = function(item: Model, part: BasePart,  Settings: any,  subType: string)
				return subType == "Revolver"
			end,
			OnAssemble = function(item: Model, part: BasePart, join, addBolt, Settings, findBolt)
				local YHinge = join("Assemble",item.EjectionRodSlide,part,CFrame.new(),"EjectionRodWeld")
				part.Anchored = false
			end,
		};
		{
			PartName = "BayonetHinge";
			Condition = function(item: Model, part: BasePart,  Settings: any)
				return true
			end,
			OnAssemble = function(item: Model, part: BasePart, join, addBolt, Settings, findBolt)
				local YHinge = join("Assemble",item.BayonetEffector,part,CFrame.new(),"BayonetHingeMotor")
				part.Anchored = false
			end,
		};
		{
			PartName = "BayonetBlade";
			Condition = function(item: Model, part: BasePart,  Settings: any)
				return item:FindFirstChild("BayonetHinge")
			end,
			OnAssemble = function(item: Model, part: BasePart, join, addBolt, Settings, findBolt)
				local YHinge = join("Assemble",item.BayonetHinge,part,CFrame.new(),"BayonetAttachment")
				part.Anchored = false
			end,
		};
		{
			PartName = "BayonetPart";
			Condition = function(item: Model, part: BasePart,  Settings: any)
				return item:FindFirstChild("BayonetHinge")
			end,
			OnAssemble = function(item: Model, part: BasePart, join, addBolt, Settings, findBolt)
				local YHinge = join("Assemble",item.BayonetBlade,part,CFrame.new(),"BayonetBAttachment")
				part.Anchored = false
			end,
		};
		{
			PartName = "ForwardAssistButton";
			Condition = function(item: Model, part: BasePart,  Settings: any)
				return item:FindFirstChild("ForwardAssistBase")
			end,
			OnAssemble = function(item: Model, part: BasePart, join, addBolt, Settings, findBolt)
				local YHinge = join("Assemble",item.ForwardAssistBase,part,CFrame.new(),"FASlide")
				part.Anchored = false
			end,
		};
		{
			PartName = "StockMain";
			Condition = function(item: Model, part: BasePart,  Settings: any)
				return Settings.initialStockType == "Folding"
			end,
			OnAssemble = function(item: Model, part: BasePart, join, addBolt, Settings, findBolt)
				local YHinge = join("Assemble",item.StockHinge,part,CFrame.new(),"StockFoldHinge")
				part.Anchored = false
			end,
		};
		{
			PartName = "StockMain";
			Condition = function(item: Model, part: BasePart,  Settings: any)
				return Settings.initialStockType == "Hybrid"
			end,
			OnAssemble = function(item: Model, part: BasePart, join, addBolt, Settings, findBolt)
				local YHinge = join("Assemble",item.StockHinge,part,CFrame.new(),"StockFoldHinge")
				part.Anchored = false
			end,
		};
		{
			PartName = "Stock";
			Condition = function(item: Model, part: BasePart,  Settings: any)
				return Settings.initialStockType == "Telescopic"
			end,
			OnAssemble = function(item: Model, part: BasePart, join, addBolt, Settings, findBolt)
				local YHinge = join("Assemble",item.StockSlide,part,CFrame.new(),"StockWeld")
				part.Anchored = false
			end,
		};
		{
			PartName = "Stock";
			Condition = function(item: Model, part: BasePart,  Settings: any)
				return Settings.initialStockType == "Folding"
			end,
			OnAssemble = function(item: Model, part: BasePart, join, addBolt, Settings, findBolt)
				local YHinge = join("Assemble",item.StockMain,part,CFrame.new(),"StockWeld")
				part.Anchored = false
				part.CanCollide = true
				return true
			end,
		};
		{
			PartName = "Stock";
			Condition = function(item: Model, part: BasePart,  Settings: any)
				return Settings.initialStockType == "Hybrid"
			end,
			OnAssemble = function(item: Model, part: BasePart, join, addBolt, Settings, findBolt)
				local YHinge = join("Assemble",item.StockMain,part,CFrame.new(),"StockWeld")
				part.Anchored = false
				part.CanCollide = true
				return true
			end,
		};
		{
			PartName = "StockPart";
			Condition = function(item: Model, part: BasePart,  Settings: any)
				return Settings.initialStockType
			end,
			OnAssemble = function(item: Model, part: BasePart, join, addBolt, Settings, findBolt)
				local YHinge = join("Assemble",item:FindFirstChild("Stock"),part,CFrame.new(),"StockAttachment")
				part.Anchored = false
				part.CanCollide = true
				return true
			end,
		};
		{
			PartName = "SlideStock";
			Condition = function(item: Model, part: BasePart,  Settings: any)
				return Settings.initialStockType and item:FindFirstChild("AltStockSlide")
			end,
			OnAssemble = function(item: Model, part: BasePart, join, addBolt, Settings, findBolt)
				local YHinge = join("Assemble",item.AltStockSlide,part,CFrame.new(),"StockWeld")
				part.Anchored = false
				part.CanCollide = true
			end,
		};
		{
			PartName = "SlideStockPart";
			Condition = function(item: Model, part: BasePart,  Settings: any)
				return Settings.initialStockType and item:FindFirstChild("AltStockSlide")
			end,
			OnAssemble = function(item: Model, part: BasePart, join, addBolt, Settings, findBolt)
				local YHinge = join("Assemble",item.SlideStock,part,CFrame.new(),"StockAttachment")
				part.Anchored = false
				part.CanCollide = true
			end,
		};
		{
			PartName = "AltStockSlide";
			Condition = function(item: Model, part: BasePart,  Settings: any)
				return Settings.initialStockType == "Hybrid" and item:FindFirstChild("Stock")
			end,
			OnAssemble = function(item: Model, part: BasePart, join, addBolt, Settings, findBolt)
				local YHinge = join("Assemble",item.Stock,part,CFrame.new(),"StockWeld")
				part.Anchored = false
				part.CanCollide = true
			end,
		};
		
		{
			PartName = "MainSightHinge";
			Condition = function(item: Model, part: BasePart,  Settings: any)
				return item:FindFirstChild("MainSightEffector");
			end,
			OnAssemble = function(item: Model, part: BasePart, join, addBolt, Settings, findBolt)
				local YHinge = join("Assemble",item.MainSightEffector,part,CFrame.new(),"SightHinge")
				part.Anchored = false
			end,
		};
		{
			PartName = "MainSightLeaf";
			Condition = function(item: Model, part: BasePart,  Settings: any)
				return item:FindFirstChild("MainSightHinge");
			end,
			OnAssemble = function(item: Model, part: BasePart, join, addBolt, Settings, findBolt)
				local YHinge = join("Assemble",item.MainSightHinge,part,CFrame.new(),"SightAttachment")
				part.Anchored = false
			end,
		};
		{
			PartName = "MainSightLeafCylinder";
			Condition = function(item: Model, part: BasePart,  Settings: any)
				return Settings.sightAdjustmentType == "Leaf"
			end,
			OnAssemble = function(item: Model, part: BasePart, join, addBolt, Settings, findBolt)
				local YHinge = join("Assemble",item.MainSightLeaf,part,CFrame.new(),"SightCylinderSlide")
				part.Anchored = false
			end,
		};
		{
			PartName = "MainSightLeafPart";
			Condition = function(item: Model, part: BasePart,  Settings: any)
				return true
			end,
			OnAssemble = function(item: Model, part: BasePart, join, addBolt, Settings, findBolt)
				local YHinge = join("Assemble",item.MainSightLeaf,part,CFrame.new(),"SightLeafAttachment")
				part.Anchored = false
			end,
		};
		{
			PartName = "MainSightTurntable";
			Condition = function(item: Model, part: BasePart,  Settings: any)
				return true
			end,
			OnAssemble = function(item: Model, part: BasePart, join, addBolt, Settings, findBolt)
				local YHinge = join("Assemble",item.MainSightHinge,part,CFrame.new(),"SightAttachment")
				part.Anchored = false
			end,
		};
		{
			PartName = "Monopod";
			Condition = function(item: Model, part: BasePart,  Settings: any)
				return true
			end,
			OnAssemble = function(item: Model, part: BasePart, join, addBolt, Settings, findBolt)
				local YHinge = join("Assemble",item.MonopodSlide,part,CFrame.new(),"MonopodSlide")
				part.Anchored = false
			end,
		};
		{
			PartName = "BeltFeedHinge";
			Condition = function(item: Model, part: BasePart,  Settings: any)
				return true
			end,
			OnAssemble = function(item: Model, part: BasePart, join, addBolt, Settings, findBolt)
				local YHinge = join("Assemble",item.BeltFeedEffector,part,CFrame.new(),"BeltFeedHinge")
				part.Anchored = false
			end,
		};
		{
			PartName = "BeltFeed";
			Condition = function(item: Model, part: BasePart,  Settings: any)
				return true
			end,
			OnAssemble = function(item: Model, part: BasePart, join, addBolt, Settings, findBolt)
				local YHinge = join("Assemble",item.BeltFeedHinge,part,CFrame.new(),"BeltFeedAttachment")
				part.Anchored = false
			end,
		};
		{
			PartName = "AimPart";
			Condition = function(item: Model, part: BasePart,  Settings: any)
				return part:FindFirstChild("Part0V")
			end,
			OnAssemble = function(item: Model, part: BasePart, join, addBolt, Settings, findBolt)
				local AimPartWeld = join("Assemble",part.Part0V.Value,part,CFrame.new(),"AimPartWeld")
				part.Anchored = false
			end,
		};
		{
			PartName = "FireModeSwitch";
			Condition = function(item: Model, part: BasePart,  Settings: any)
				return true
			end,
			OnAssemble = function(item: Model, part: BasePart, join, addBolt, Settings, findBolt)
				local AimPartWeld = join("Assemble",item.SelectorHinge,part,CFrame.new(),"SelectorAttachment")
				part.Anchored = false
			end,
		};
		{
			PartName = "SelectorHinge";
			Condition = function(item: Model, part: BasePart,  Settings: any)
				return true
			end,
			OnAssemble = function(item: Model, part: BasePart, join, addBolt, Settings, findBolt)
				local AimPartWeld = join("Assemble",item.SelectorEffector,part,CFrame.new(),"SelectorHinge")
				part.Anchored = false
			end,
		};
		{
			PartName = "SelectFireTab";
			Condition = function(item: Model, part: BasePart,  Settings: any)
				return true
			end,
			OnAssemble = function(item: Model, part: BasePart, join, addBolt, Settings, findBolt)
				local AimPartWeld = join("Assemble",item.SelectFireTabSlide,part,CFrame.new(),"SelectorSlide")
				part.Anchored = false
			end,
		};
		{
			PartName = "SafetyHinge";
			Condition = function(item: Model, part: BasePart,  Settings: any)
				return true
			end,
			OnAssemble = function(item: Model, part: BasePart, join, addBolt, Settings, findBolt)
				local AimPartWeld = join("Assemble",item.SafetyEffector,part,CFrame.new(),"SafetyHinge")
				part.Anchored = false
			end,
		};
		{
			PartName = "SafetySwitch";
			Condition = function(item: Model, part: BasePart,  Settings: any)
				return true
			end,
			OnAssemble = function(item: Model, part: BasePart, join, addBolt, Settings, findBolt)
				local AimPartWeld = join("Assemble",item.SafetyHinge,part,CFrame.new(),"SelectorAttachment")
				part.Anchored = false
			end,
		};
		{
			PartName = "SafetySwitchTab";
			Condition = function(item: Model, part: BasePart,  Settings: any)
				return true
			end,
			OnAssemble = function(item: Model, part: BasePart, join, addBolt, Settings, findBolt)
				local AimPartWeld = join("Assemble",item.SafetySlide,part,CFrame.new(),"SafetySlider")
				part.Anchored = false
			end,
		};
		{
			PartName = "EjectionCover";
			Condition = function(item: Model, part: BasePart,  Settings: any)
				return true
			end,
			OnAssemble = function(item: Model, part: BasePart, join, addBolt, Settings, findBolt)
				local AimPartWeld = join("Assemble",item.CoverHinge,part,CFrame.new(),"CoverAttachment")
				part.Anchored = false
			end,
		};
		{
			PartName = "EjectorTop";
			Condition = function(item: Model, part: BasePart,  Settings: any)
				return true
			end,
			OnAssemble = function(item: Model, part: BasePart, join, addBolt, Settings, findBolt)
				local AimPartWeld = join("Assemble",item.EjectorSlide,part,CFrame.new(),"ETopSlide")
				part.Anchored = false
			end,
		};
		{
			PartName = "EjectorBottom";
			Condition = function(item: Model, part: BasePart,  Settings: any)
				return true
			end,
			OnAssemble = function(item: Model, part: BasePart, join, addBolt, Settings, findBolt)
				local AimPartWeld = join("Assemble",item.EjectorSlide,part,CFrame.new(),"EBottomSlide")
				part.Anchored = false
			end,
		};
		{
			PartName = "CoverHinge";
			Condition = function(item: Model, part: BasePart,  Settings: any)
				return true
			end,
			OnAssemble = function(item: Model, part: BasePart, join, addBolt, Settings, findBolt)
				local AimPartWeld = join("Assemble",item.CoverEffector,part,CFrame.new(),"CoverHinge")
				part.Anchored = false
			end,
		};
		{
			PartName = "CheekRest";
			Condition = function(item: Model, part: BasePart,  Settings: any)
				return item:FindFirstChild("StockSlide")
			end,
			OnAssemble = function(item: Model, part: BasePart, join, addBolt, Settings, findBolt)
				local AimPartWeld = join("Assemble",item.StockSlide,part,CFrame.new(),"CheekRestSlide")
				part.Anchored = false
			end,
		};
		{
			PartName = "HammerHinge";
			Condition = function(item: Model, part: BasePart,  Settings: any, subType: string?)
				return 	((subType == "Revolver") or Settings.usesHammer)

			end,
			OnAssemble = function(item: Model, part: BasePart, join, addBolt, Settings, findBolt)
				local AimPartWeld = join("Assemble",item.HammerEffector,part,CFrame.new(),"HammerHinge")
				part.Anchored = false
			end,
		};
		{
			PartName = "Hammer";
			Condition = function(item: Model, part: BasePart,  Settings: any, subType: string?)
				return 	((subType == "Revolver") or Settings.usesHammer)

			end,
			OnAssemble = function(item: Model, part: BasePart, join, addBolt, Settings, findBolt)
				local AimPartWeld = join("Assemble",item.HammerHinge,part,CFrame.new(),"HammerAttachment")
				part.Anchored = false
			end,
		};
		{
			PartName = "HammerPart";
			Condition = function(item: Model, part: BasePart,  Settings: any, subType: string?)
				return 	((subType == "Revolver") or Settings.usesHammer)

			end,
			OnAssemble = function(item: Model, part: BasePart, join, addBolt, Settings, findBolt)
				local AimPartWeld = join("Assemble",item.Hammer,part,CFrame.new(),"HammerAttachment")
				part.Anchored = false
			end,
		};
		{
			PartName = "TriggerHinge";
			Condition = function(item: Model, part: BasePart,  Settings: any)
				return 	item:FindFirstChild("TriggerHinge")

			end,
			OnAssemble = function(item: Model, part: BasePart, join, addBolt, Settings, findBolt)
				local AimPartWeld = join("Assemble",item.TriggerEffector,part,CFrame.new(),"TriggerHinge")
				part.Anchored = false
			end,
		};
		{
			PartName = "Trigger";
			Condition = function(item: Model, part: BasePart,  Settings: any)
				return 	item:FindFirstChild("TriggerHinge")

			end,
			OnAssemble = function(item: Model, part: BasePart, join, addBolt, Settings, findBolt)
				local AimPartWeld = join("Assemble",item.TriggerHinge,part,CFrame.new(),"TriggerAttachment")
				part.Anchored = false
			end,
		};
		{
			PartName = "TriggerSear";
			Condition = function(item: Model, part: BasePart,  Settings: any)
				return 	item:FindFirstChild("TriggerHinge")

			end,
			OnAssemble = function(item: Model, part: BasePart, join, addBolt, Settings, findBolt)
				local AimPartWeld = join("Assemble",item.TriggerHinge,part,CFrame.new(),"SearAttachment")
				part.Anchored = false
			end,
		};
		{
			PartName = "PaddleReleaseHinge";
			Condition = function(item: Model, part: BasePart,  Settings: any)
				return 	item:FindFirstChild("PaddleReleaseHinge")

			end,
			OnAssemble = function(item: Model, part: BasePart, join, addBolt, Settings, findBolt)
				local AimPartWeld = join("Assemble",item.PaddleReleaseEffector,part,CFrame.new(),"PaddleReleaseHinge")
				part.Anchored = false
			end,
		};
		{
			PartName = "SlideReleaseHinge";
			Condition = function(item: Model, part: BasePart,  Settings: any)
				return 	item:FindFirstChild("SlideReleaseEffector")

			end,
			OnAssemble = function(item: Model, part: BasePart, join, addBolt, Settings, findBolt)
				local AimPartWeld = join("Assemble",item.SlideReleaseEffector,part,CFrame.new(),"SlideReleaseHinge")
				part.Anchored = false
			end,
		};
		{
			PartName = "PaddleRelease";
			Condition = function(item: Model, part: BasePart,  Settings: any)
				return 	item:FindFirstChild("PaddleReleaseHinge")

			end,
			OnAssemble = function(item: Model, part: BasePart, join, addBolt, Settings, findBolt)
				local AimPartWeld = join("Assemble",item.PaddleReleaseHinge,part,CFrame.new(),"PaddleReleaseAttachment")
				part.Anchored = false
			end,
		};
		{
			PartName = "ReceiverHinge";
			Condition = function(item: Model, part: BasePart,  Settings: any)
				return 	item:FindFirstChild("ReceiverHinge")

			end,
			OnAssemble = function(item: Model, part: BasePart, join, addBolt, Settings, findBolt)
				local AimPartWeld = join("Assemble",item.ReceiverEffector,part,CFrame.new(),"ReceiverHinge")
				part.Anchored = false
			end,
		};
		{
			PartName = "Receiver";
			Condition = function(item: Model, part: BasePart,  Settings: any)
				return 	item:FindFirstChild("ReceiverHinge")

			end,
			OnAssemble = function(item: Model, part: BasePart, join, addBolt, Settings, findBolt)
				local AimPartWeld = join("Assemble",item.ReceiverHinge,part,CFrame.new(),"ReceiverAttachment")
				part.Anchored = false
			end,
		};
		{
			PartName = "ReceiverPart";
			Condition = function(item: Model, part: BasePart,  Settings: any)
				return 	item:FindFirstChild("Receiver")

			end,
			OnAssemble = function(item: Model, part: BasePart, join, addBolt, Settings, findBolt)
				local AimPartWeld = join("Assemble",item.Receiver,part,CFrame.new(),"ReceiverPartAttachment")
				part.Anchored = false
			end,
		};
		{
			PartName = "CarryHandleHinge";
			Condition = function(item: Model, part: BasePart,  Settings: any)
				return true

			end,
			OnAssemble = function(item: Model, part: BasePart, join, addBolt, Settings, findBolt)
				local AimPartWeld = join("Assemble",item.CarryHandleEffector,part,CFrame.new(),"CarryHandleHinge")
				part.Anchored = false
			end,
		};
		{
			PartName = "CarryHandle";
			Condition = function(item: Model, part: BasePart,  Settings: any)
				return item:FindFirstChild("CarryHandleHinge")

			end,
			OnAssemble = function(item: Model, part: BasePart, join, addBolt, Settings, findBolt)
				local AimPartWeld = join("Assemble",item.CarryHandleHinge,part,CFrame.new(),"CarryHandleAttachment")
				part.Anchored = false
			end,
		};
		{
			PartName = "CarryHandlePart";
			Condition = function(item: Model, part: BasePart,  Settings: any)
				return item:FindFirstChild("CarryHandleHinge")

			end,
			OnAssemble = function(item: Model, part: BasePart, join, addBolt, Settings, findBolt)
				local AimPartWeld = join("Assemble",item.CarryHandle,part,CFrame.new(),"CarryHandleAttachment")
				part.Anchored = false
			end,
		};
		{
			PartName = "BarrelSwapHinge";
			Condition = function(item: Model, part: BasePart,  Settings: any)
				return true
			end,
			OnAssemble = function(item: Model, part: BasePart, join, addBolt, Settings, findBolt)
				local AimPartWeld = join("Assemble",item.BarrelSwapEffector,part,CFrame.new(),"BarrelSwapHinge")
				part.Anchored = false
			end,
		};
		{
			PartName = "BarrelSwapLever";
			Condition = function(item: Model, part: BasePart,  Settings: any)
				return item:FindFirstChild("BarrelSwapEffector")
			end,
			OnAssemble = function(item: Model, part: BasePart, join, addBolt, Settings, findBolt)
				local AimPartWeld = join("Assemble",item.BarrelSwapHinge,part,CFrame.new(),"BarrelSwapAttachment")
				part.Anchored = false
			end,
		};
		{
			PartName = "SlideLock";
			Condition = function(item: Model, part: BasePart,  Settings: any)
				return item:FindFirstChild("SlidePart")
			end,
			OnAssemble = function(item: Model, part: BasePart, join, addBolt, Settings, findBolt)
				local AimPartWeld = join("Assemble",item.SlidePart,part,CFrame.new(),"SlideLockSlide")
				part.Anchored = false
			end,
		};
		{
			PartName = "BarrelReleaseHinge";
			Condition = function(item: Model, part: BasePart,  Settings: any)
				return true
			end,
			OnAssemble = function(item: Model, part: BasePart, join, addBolt, Settings, findBolt)
				local AimPartWeld = join("Assemble",item.BarrelReleaseEffector,part,CFrame.new(),"BarrelReleaseHinge")
				part.Anchored = false
			end,
		};
		{
			PartName = "BarrelRelease";
			Condition = function(item: Model, part: BasePart,  Settings: any)
				return true
			end,
			OnAssemble = function(item: Model, part: BasePart, join, addBolt, Settings, findBolt)
				local AimPartWeld = join("Assemble",item.BarrelReleaseHinge,part,CFrame.new(),"BarrelReleaseAttachment")
				part.Anchored = false
			end,
		};
		{
			PartName = "LoadingGate";
			Condition = function(item: Model, part: BasePart,  Settings: any)
				return true
			end,
			OnAssemble = function(item: Model, part: BasePart, join, addBolt, Settings, findBolt)
				local AimPartWeld = join("Assemble",item.GateHinge,part,CFrame.new(),"GateAttachment")
				part.Anchored = false
			end,
		};
		{
			PartName = "GateHinge";
			Condition = function(item: Model, part: BasePart,  Settings: any)
				return true
			end,
			OnAssemble = function(item: Model, part: BasePart, join, addBolt, Settings, findBolt)
				local AimPartWeld = join("Assemble",item.GateEffector,part,CFrame.new(),"GateHinge")
				part.Anchored = false
			end,
		};
		{
			PartName = "ReleaseLeverHinge";
			Condition = function(item: Model, part: BasePart,  Settings: any)
				return 	item:FindFirstChild("ReleaseLeverHinge")
			end,
			OnAssemble = function(item: Model, part: BasePart, join, addBolt, Settings, findBolt)
				local AimPartWeld = join("Assemble",item.ReleaseLeverEffector,part,CFrame.new(),"ReleaseLeverHinge")
				part.Anchored = false
			end,
		};
		{
			PartName = "ReleaseLever";
			Condition = function(item: Model, part: BasePart,  Settings: any)
				return 	item:FindFirstChild("ReleaseLeverHinge")
			end,
			OnAssemble = function(item: Model, part: BasePart, join, addBolt, Settings, findBolt)
				local AimPartWeld = join("Assemble",item.ReleaseLeverHinge,part,CFrame.new(),"ReleaseLeverAttachment")
				part.Anchored = false
			end,
		};
		{
			PartName = "MagazineRelease";
			Condition = function(item: Model, part: BasePart,  Settings: any)
				return item:FindFirstChild("MagazineReleaseSlide")
			end,
			OnAssemble = function(item: Model, part: BasePart, join, addBolt, Settings, findBolt)
				local AimPartWeld = join("Assemble",item.MagazineReleaseSlide,part,CFrame.new(),"ReleaseLeverAttachment")
				part.Anchored = false
			end,
		};
		{
			PartName = "AccessDoorHinge";
			Condition = function(item: Model, part: BasePart,  Settings: any)
				return item:FindFirstChild("AccessDoorEffector")
			end,
			OnAssemble = function(item: Model, part: BasePart, join, addBolt, Settings, findBolt)
				local AimPartWeld = join("Assemble",item.AccessDoorEffector,part,CFrame.new(),"AccessDoorHinge")
				part.Anchored = false
			end,
		};
		{
			PartName = "AccessDoor";
			Condition = function(item: Model, part: BasePart,  Settings: any)
				return item:FindFirstChild("AccessDoorHinge")
			end,
			OnAssemble = function(item: Model, part: BasePart, join, addBolt, Settings, findBolt)
				local AimPartWeld = join("Assemble",item.AccessDoorHinge,part,CFrame.new(),"AccessDoorAttachment")
				part.Anchored = false
			end,
		};
		{
			PartName = "NadeBarrel";
			Condition = function(item: Model, part: BasePart,  Settings: any)
				if not item:FindFirstChild("LauncherType") then
					return false
				end
				return item.LauncherType.Value == "Grenade"
			end,
			OnAssemble = function(item: Model, part: BasePart, join, addBolt, Settings, findBolt)
				local w = join("Assemble",item:FindFirstChild("NadeBarrelHinge"),part,CFrame.new(),"GBAttachment")
				part.Parent = item
				part.Anchored = false
			end,
		};
		{
			PartName = "NadeBarrelHinge";
			Condition = function(item: Model, part: BasePart,  Settings: any)
				if not item:FindFirstChild("LauncherType") then
					return false
				end
				return item.LauncherType.Value == "Grenade"
			end,
			OnAssemble = function(item: Model, part: BasePart, join, addBolt, Settings, findBolt)
				local w = join("Assemble",item:FindFirstChild("NadeBarrelEffector"),part,CFrame.new(),"GBHinge")
				part.Parent = item
				part.Anchored = false

			end,
		};
		{
			PartName = "NadeIPoint";
			Condition = function(item: Model, part: BasePart,  Settings: any)
				if not item:FindFirstChild("LauncherType") then
					return false
				end
				return item.LauncherType.Value == "Grenade"
			end,
			OnAssemble = function(item: Model, part: BasePart, join, addBolt, Settings, findBolt)
				local w = join("Assemble",item:FindFirstChild("NadeBarrel"),part,CFrame.new(),"GBPAttachment")
				part.Parent = item
				part.Anchored = false

			end,
		};
		{
			PartName = "NadePoint";
			Condition = function(item: Model, part: BasePart,  Settings: any)
				if not item:FindFirstChild("LauncherType") then
					return false
				end
				return item.LauncherType.Value == "Grenade"
			end,
			OnAssemble = function(item: Model, part: BasePart, join, addBolt, Settings, findBolt)
				local w = join("Assemble",item:FindFirstChild("NadeBarrel"),part,CFrame.new(),"GBPAttachment2")
				part.Parent = item
				part.Anchored = false

			end,
		};
	};

	
}