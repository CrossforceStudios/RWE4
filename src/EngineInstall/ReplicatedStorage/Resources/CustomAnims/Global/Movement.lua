return {
	
	SwimStart = function(S)
		local wait = S.FastWait
		local swimSpeed = 0.9;
		return {
			function()
				S:tweenJoint(S.LWeld, S.LC0, S.CF(-0.5,0,-0.5) * S.CFANG(0, S.RAD(90), 0), S:getAlpha("OutQuint"), 0.3 * swimSpeed)
				S:tweenJoint(S.RWeld, S.RC0, S.CF(0.5,0,-0.5) * S.CFANG(0, S.RAD(-90), 0), S:getAlpha("OutQuint"), 0.3 * swimSpeed)
				wait(0.3 * swimSpeed)
			end;
			function()
				S.Grip.Part0 = S.Torso
				S.Grip.C1 = S.CF(-1, 0.5, -0.5) * S.CFANG(S.RAD(90),0,0)
			end
		}
	end;

	SwimEnd = function(S)
		local swimSpeed = 0.9;
		return {
			function()
				S.Grip.Part0 = S.RArm
				S.Grip.C1 = S.iGripC1
			end
		}
	end;

	Swimming  = function(X, moveDirection, moveSpeed)
		return {
			leftArm = CFrame.Angles(
				0,
				math.rad(0),
				math.rad(-10)
			) * CFrame.new(
				-0.5,
				0,
				0
			) * CFrame.new(
				math.cos(math.sin(X) * math.rad(15)),
				-math.sin(math.sin(X) * math.rad(15)),
				-math.sin(math.sin(X) * math.rad(15))
			) * CFrame.Angles(
				0,
				-math.sin(X) * math.rad(15),
				0
			);
			leftLeg = CFrame.new(
				(-math.sin(X/60) * 4) - 0.2,
				(math.sin(X/60) * 2) + 0.3,
				math.max(math.cos(X/60) * 4, 0) - 0.1
			):inverse() * CFrame.Angles(
			0,
			0,
			-math.rad(15) * (math.rad(15) * math.sin(X/60))
			);
			rightArm = CFrame.Angles(
				0,
				math.rad(0),
				math.rad(-10)
			) * CFrame.new(
				0.5,
				0,
				0
			) * CFrame.new(
				-math.cos(math.sin(X) * math.rad(15)),
				-math.sin(math.sin(X) * math.rad(15)),
				-math.sin(math.sin(X) * math.rad(15))
			) * CFrame.Angles(
				0,
				math.sin(X) * math.rad(15),
				0
			);
			rightLeg = CFrame.new(
				(math.sin(X/60) * 4) + 0.2,
				(-math.sin(X/60) * 2) + 0.3,
				math.max(math.cos((X + math.rad(30))/60) * 4, 0) - 0.1
			):inverse() * CFrame.Angles(
			0,
			0,
			math.rad(15) * (math.rad(15) * math.sin(X/60))
			);
			Camera = 1.5 * math.rad(math.cos((X + math.rad(30))/60)) + math.rad(0.5); --This is what the roll of the camera will be when you're skydiving
			Easing = "Deceleration";
		}
	end;

	Skydiving  = function(X, moveDirection, moveSpeed)
		return {
			leftArm = CFrame.Angles(
				0,
				math.rad(90),
				math.rad(-10)
			) * CFrame.new(
				-0.5,
				0,
				0
			) * CFrame.new(
				math.cos(math.sin(X/60) * math.rad(15)),
				0,
				-math.sin(math.sin(X/60) * math.rad(15))
			) * CFrame.Angles(
				0,
				0,
				math.sin(X/60) * math.rad(15)
			);
			leftLeg = CFrame.new(
				(-math.sin(X/60) * 4) - 0.2,
				(math.sin(X/60) * 2) + 0.3,
				math.max(math.cos(X/60) * 4, 0) - 0.1
			):inverse() * CFrame.Angles(
			0,
			0,
			-math.rad(15) * (math.rad(15) * math.sin(X/60))
			);
			rightArm = CFrame.Angles(
				0,
				math.rad(-5),
				math.rad(10)
			) * CFrame.new(
				0.5,
				0,
				0
			) * CFrame.new(
				-math.cos(math.sin(X/60) * math.rad(15)),
				0,
				-math.sin(math.sin(X/60) * math.rad(15))
			) * CFrame.Angles(
				0,
				0,
				-math.sin(X/60) * math.rad(15)
			);
			rightLeg = CFrame.new(
				(math.sin(X/60) * 4) + 0.2,
				(-math.sin(X/60) * 2) + 0.3,
				math.max(math.cos((X + math.rad(30))/60) * 4, 0) - 0.1
			):inverse() * CFrame.Angles(
			0,
			0,
			math.rad(15) * (math.rad(15) * math.sin(X/60))
			);
			Camera = 1.5 * math.rad(math.cos((X + math.rad(30))/60)) + math.rad(0.5); --This is what the roll of the camera will be when you're skydiving
		}
	end;

	Climbing = function(X, moveDirection, rungSize)
		return {
			leftArm =
				CFrame.new(
					0,
					.75,
					0	
				) * CFrame.Angles(
				math.rad(-20),
				math.rad(0),
				math.rad(0)
			) * CFrame.new(
				0,
				0,
				math.cos(moveDirection) * (-math.sin(X * 6) / 5) * -rungSize
			) ;
			leftLeg = CFrame.new(
				0,
				math.cos(moveDirection) * (-math.sin(X * 6) / 5) * rungSize + .5,
				0
			);
			rightArm = CFrame.new(
				0,
				.75,
				0	
			) * CFrame.Angles(
				math.rad(-20),
				math.rad(0),
				math.rad(0)
			) * CFrame.new(
				0,
				0,
				math.cos(moveDirection) * (-math.sin(X * 6) / 5) * rungSize
			) ;
			rightLeg = CFrame.new(
				0,
				math.cos(moveDirection) * (-math.sin(X * 6) / 5) * -rungSize - .5,
				0
			);
			Grip = CFrame.new();
			Camera = 1.5 * math.rad(math.cos((X + math.rad(5)) * 6)) + math.rad(0.5); --This is what the roll of the camera will be when you're crawling
		}
	end;

	CrouchWalking = function(X, moveDirection)
		
			return {
				leftLeg = CFrame.Angles(
					0,
					0,
					math.rad(60) * ((X % 2 == 0 and 0 or -1))
				) * CFrame.new(
					0,
					(-0.1) * ((X % 2 == 0 and 0 or -1)),
					0
				);
				rightLeg = CFrame.Angles(
					0,
					0,
					math.rad(60) * ((X % 2 == 0 and 0 or -1))
				) * CFrame.new(
					0,
					(0.1) * ((X % 2 == 0 and 0 or -1)),
					0
				);
			}
		
	end;
	
	
}