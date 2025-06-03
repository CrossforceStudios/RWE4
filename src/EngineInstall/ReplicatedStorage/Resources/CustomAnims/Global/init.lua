local function FromAxisAngle(x, y, z)
	if not y then
		x, y, z = x.X, x.Y, x.Z
	end
	local m = (x * x + y * y + z * z) ^ 0.5
	if m > 1e-5 then
		local si = math.sin(m / 2) / m
		return CFrame.new(0, 0, 0, si * x, si * y, si * z, math.cos(m / 2))
	else
		return CFrame.new()
	end
end
local Animations = {
	
	
	
	
	Surrender = function(S)
		local animSpeed = 0.5
		local wait = S.FastWait
		return {
			function()
				S:tweenJoint(S.LWeld, false, S.CF(0.3, 0, 0.15) * S.CFANG(S.RAD(-75),0,0), S:getAlpha("Standard"), 0.3 * animSpeed)
				wait(0.15 * animSpeed)
			end,
			function()
				S:tweenJoint(S.RWeld, false, S.CF(-0.3, 0, 0.15) * S.CFANG(S.RAD(-75),0,0), S:getAlpha("Standard"), 0.3 * animSpeed)
				wait(0.3 * animSpeed)
			end,
			function()
				S:signalSurrender();
				wait(7)
			end,
		}
	end;
	
	
	
	
	

	

	
	SpotDefendShip = function(S)
		local animSpeed = 0.5
		local wait = S.FastWait
		return {
			function()
				S:tweenJoint(S.LWeld,nil,S.CF(0.05,1.45,-1.4)*S.CFANG(S.RAD(-49),S.RAD(-16),S.RAD(-8)), S:getAlpha"OutSine",0.6 * animSpeed);
				wait(animSpeed * 0.65)
			end;
			function()
				S:tweenJoint(S.LWeld,nil,S.CF(0.15,1.25,-1.3)*S.CFANG(S.RAD(4),S.RAD(-19),S.RAD(-5)), S:getAlpha"OutSine",0.5 * animSpeed);
				wait(animSpeed * 0.5)
			end;
			function()
				S:tweenJoint(S.LWeld,nil,S.CF(-0.6,1.45,0)*S.CFANG(S.RAD(0),S.RAD(0),S.RAD(0)), S:getAlpha"OutSine",0.6 * animSpeed);
				wait(animSpeed * 0.65)
			end;
			function()
				S:tweenJoint(S.LWeld,nil,S.CF(-0.6,1.45,0)*S.CFANG(S.RAD(-30),S.RAD(0),S.RAD(0)), S:getAlpha"OutSine",0.6 * animSpeed);
				wait(animSpeed * 0.65)
			end;
			function()
				--S:castAction("State","DefendShip",S:getMousePos())
			end;
		};
	end;

	
	
	Parkour = function(S)
--			unAimedC1 = {
--		leftArm = CF(-0.7, 2, -.8) * CFANG(RAD(-10), 0, RAD(-30));
--		rightArm = CF(0.4, 0.25, -0.3) * CFANG(0, 0, RAD(25));
--		Grip = CFANG(0, RAD(25), 0);
--	};
		local wait = S.FastWait
		local animSpeed = 0.5
		return {
			function()
					S:tweenJoint(S.LWeld, nil, S.LC1U,  S:getAlpha("OutSine"), 0.1 * animSpeed)
					S:tweenJoint(S.RWeld, nil, S.RC1U,  S:getAlpha("OutSine"), 0.1 * animSpeed)
					S:tweenJoint(S.Grip,nil,S.iGripC1,  S:getAlpha("OutSine"), 0.1 * animSpeed)
					wait(0.1 * animSpeed)
			end;
			
			function()
				S:tweenJoint(S.LWeld,false,S.CF(-0.7,0.9,-.8) * S.CFANG(S.RAD(45),0,S.RAD(-10)),S:getAlpha"OutSine",0.1)
				S:tweenJoint(S.RWeld,false,S.CF(0.4, 0.25,-0.3) * S.CFANG(S.RAD(-0),S.RAD(0),S.RAD(25)),S:getAlpha"OutSine",0.1)
			
				wait(0.1)
			end;
			function()
				S:addVaultForce();
				wait(0.45);	
			end;
		};
	end;
	
	
	
	WalkRifle = function(a, r, speed, vel, pDist, dt)
		local dist = pDist * math.rad(360) * .75
		vel = -vel
		local d, s = tick()*4, 2*(1-a)
		return CFrame.new(
			r * math.sin(dist/8-1) * a * 2 * speed/196,
			3.25 *a * math.sin(dist/4) * speed/512,
			(r/2) * math.sin(dist/8-1) * a * 2 * speed/196 
		) *
			CFrame.new(math.cos(d/8)*(vel.Unit.X * s)/64,-math.sin(d/4)*s/64,math.sin(d/16)*(vel.Unit.Z * s)/128)
	end;
	
	WalkPistol = function(a, r, speed, vel, pDist, dt)
		local dist = pDist * math.rad(360) * .75
		vel = -vel
		local d, s = dist, speed
		local w = Vector3.new((r * math.sin(d / 4 - 1) / 256 + r * (math.sin(d / 64) - r * vel.Z / 4) / 512),(r * math.cos(d / 128) / 128 - r * math.cos(d / 8) / 256),  (r * math.sin(d / 8) / 128 + r * vel.X / 1024)) 
		return CFrame.new(
			r * math.sin(dist/8-1) * speed/196,
			1.25 * a * math.sin(dist/4) * speed/512,
			0
		) * CFrame.Angles(w.X * s/20 * math.rad(180),w.Y * s/20 * math.rad(180),w.Z * s/20 * math.rad(180))
			
	end;
	
	WalkRifle2 = function(a, r, speed, vel, pDist, dt)
		local dist = pDist * math.rad(360) * .75
		vel = -vel
		local d, s = dist, speed
		local w = Vector3.new(-(r * math.sin(d / 4 - 1) / 512 + r * (math.sin(d / 64) - r * vel.Z / 2) / 512),-(r * math.cos(d / 64) / 64 - r * math.cos(d / 8) / 128),  (r * math.sin(d / 8) / 128 + r * vel.X / 1024)) 
		return CFrame.new(
			r * math.sin(dist/6-1) * speed/512,
			1.25 * a * math.sin(dist/4) * speed/256,
			0
		) * CFrame.Angles(w.X * s/20 * math.rad(180),w.Y * s/20 * math.rad(180),w.Z * s/20 * math.rad(180))
	end;
}

local function addAnims(scriptObject: ModuleScript)
	local anims = require(scriptObject)
	if anims then
		for k, anim in anims do
			if typeof(anim) == "function" then
				Animations[k] = anim
			end
		end
	end
end
--- Add More Anim Sets here.
addAnims(script.Movement)
addAnims(script.Crawling)

return Animations