

return function(Params, Args)
	local RemoteService = Params.RemoteService
	local S = Params.Settings;
	local CF = Params.CF
	local ABS = Params.ABS
	local COS = Params.COS
	local SIN = Params.SIN;
	local RNG = Params.RNG;
	
	local item = Params.Item
	
	Params.calibrateFireRateFromHeat()
	
	local rpm =  Params.getFireRate()

	local list = S.fireSequence;
	local listEnd = S.fireSequenceEnd;
	local fr = math.clamp((60/rpm),60/2000,0.2)
	
	local basePos = Params.getBasePose()
	
	local gC1 = Params.getGripC1(basePos)
	
	local continuousActions = Params.getContinuousActions()
	
	local times = Args[1]
	local gunMode = Args[2]
	
	Params.Cycle(times, function(i)
		local cycleReady = false
		if times and times >= 2 then
			Params.setCurrentIndex(i)
		end
		
		Params.startSequence(list, rpm)
			:andThen(function(info)
				local fp = Params.getFirePort()
				if not fp then
					return info
				end
				Params.spawnMuzzleFlash(fp, fr)
				fp = Params.getCurrentPort()
				if not fp then
					return info
				end
				Params.fireProjectileWeapon(fp)
				Params.incrementPort()
				if S.barrelOverheat then
					RemoteService.sendU("Server","AddHeat",item)
					Params.updateBarrelColor()
					if item:GetAttribute("Heat") >= 1 then
						if RNG:NextInteger(0,1) == 1 and item:GetAttribute("Ammo") > 0 then
							Params.Delay(fr * RNG:NextNumber(1,3), function()
								Params.fireAgain("Gun", times)	
							end)	
						end							
					end
				end
				return info	
			end, print)
			:andThen(function(info)
				if Params.hasNoBarrels() then
					return info 
				end
				if gunMode then
					return info 
				end
				Params.spawnBlast(fr)	
				return info
			end, print)
			:andThen(function(info)
				if gunMode then
					return info 
				end
				local recoilT, camRecoilRot, sideRecoilAlpha = Params.getRecoil()
				local ts = tick() - Params.lastRecoil()
				_G.sideRecoilAlpha = sideRecoilAlpha
				
				if not S.recoilSettings.gripRecoil then
					Params.spawnRecoil(recoilT, camRecoilRot, fr)
					_G.RumbleRecoil = 100 * recoilT.Rot.Y
					Params.spawnRecoilRumble("GripRecoil")
					Params.spawnRecoilRumble("Recoil")
				else
					local rec = recoilT.Rot
					local g = Params.getCurrentGrip()
					local gC1F = gC1 * CF.ANG(-ABS((rec.Y)), 0, 0) * CF.RAW(0, -COS(ABS((rec.Y))) * 0.01, -SIN(ABS((rec.Y))) * 0.01)
					Params.tweenJoint(g, false, gC1F, ("Smooth"), fr * 2.5)
					Params.spawnRecoilOverride(recoilT, rec/2, camRecoilRot, fr)
					_G.RumbleRecoil = 100 * rec.Y
					Params.spawnRecoilRumble("GripRecoil")
					Params.spawnRecoilRumble("Recoil")
				end
				return info
			end, print)
			:andThen(function(info)
				if gunMode then
					return info 
				end
				local frHalf = math.min(fr * 0.5,0.025)
				Params.SimpleDelay((frHalf * 2) + (1/60),function()
					Params.stopRecoilRumble("GripRecoil")
					Params.stopRecoilRumble("Recoil")
				end)
				Params.SimpleDelay(frHalf + (1/60),function()
					if S.recoilSettings.gripRecoil then
						local g = Params.getCurrentGrip()
						local gC1F = gC1 
						Params.tweenJoint(g, false, Params.getGripC1(), "Smooth", fr * 2.5)
					end
					Params.stopRecoil(fr)
					Params.stopRecoilRumble("GripRecoil")
					Params.stopRecoilRumble("Recoil")
					Params.endSequence(listEnd, rpm)
					Params.Wait(fr)

					if Params.Item:GetAttribute("Ammo") <= 0 then
						Params.lockOpenBolt()
					end
				end)
				return info
			end, print)
			:andThen(function(info)
				if gunMode then
					return info 
				end
				Params.increaseShotCount()
				local shotCount = Params.getShotCount()
				Params.transformSideRecoil((shotCount % 2) + 1, _G.sideRecoilAlpha)
				return info
			end, print)
			:andThen(function(info)
				if gunMode then
					return info 
				end
				if ((not table.find(continuousActions,S.actionType)) 
					or (S.reloadSettings.cycleRounds and table.find(S.reloadSettings.cycleRounds,item:GetAttribute("MagType")))) 
					and item.Type.Value == "Gun" then
					if S.actionType == "Bolt" then
						repeat task.wait() until Params.isAimedOut();
					else
						Params.unAim()
						repeat task.wait() until Params.isAimedOut();
					end
					Params.startBoltCycle()
					Params.playAnim("Cocking")
					Params.stopBoltCycle()
				elseif item.Type.Value =="Gun" then
					Params.openEjectionCover()
				end

			end, print)
			:andThen(function(info)
				if gunMode then
					return info 
				end
				if Params.hasAnimation("StorageLoad") then
					if #item.Rounds:GetChildren() <= 1 and #item.StoredRounds:GetChildren() > 0 then	
						Params.playAnim("StorageLoad")
					end
				end
				if item then
					if item.Type.Value == "Launcher" then
						if item.LauncherType.Value == "Disposable" then
							task.delay(S.removalTime, function()
								Params.playAnim("Dispose", false)
							end)
						end
					end
				end
				cycleReady = true
				return info
			end)
			repeat task.wait() until cycleReady
	end)
	
end