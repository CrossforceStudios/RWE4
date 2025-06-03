return {
	CrawlingSide = function(X, moveDirection, moveSpeed)
		return {
			leftArm = CFrame.Angles(
				0,
				math.rad(90),
				math.rad(-10)
			) * CFrame.new(
				math.sin(moveDirection) * (math.sin(X * 6) / 4) - 0.2,
				math.cos(moveDirection) * (math.sin(X * 6) / 2) - 0.1,
				math.max(math.cos(X * 6) / 4, 0) - 0.1
			) * CFrame.Angles(
				-math.max(math.cos(X * 6) / 4, 0),
				0,
				0
			);
			leftLeg = CFrame.new(
				math.sin(moveDirection) * (-math.sin(X * 6) / 4) - 0.2,
				math.cos(moveDirection) * (math.sin(X * 6) / 2) + 0.3,
				math.max(math.cos(X * 6) / 4, 0) - 0.1
			):inverse() * CFrame.Angles(
			0,
			0,
			-math.rad(15) - math.cos(moveDirection) * (math.rad(15) * math.sin(X * 6))
			);
			rightArm = CFrame.Angles(
				0,
				math.rad(-90),
				math.rad(10)
			) * CFrame.new(
				math.sin(moveDirection) * (-math.sin(X * 6) / 4) + 0.2,
				math.cos(moveDirection) * (-math.sin(X * 6) / 5) - 0.2,
				math.max(math.cos((X + math.rad(30)) * 6) / 10, 0) - 0.1
			) * CFrame.Angles(
				-math.max(math.cos((X + math.rad(30)) * 6) / 10, 0),
				0,
				0
			);
			rightLeg = CFrame.new(
				math.sin(moveDirection) * (math.sin(X * 6) / 4) + 0.2,
				math.cos(moveDirection) * (-math.sin(X * 6) / 2) + 0.3,
				math.max(math.cos((X + math.rad(30)) * 6) / 4, 0) - 0.1
			):inverse() * CFrame.Angles(
			0,
			0,
			math.rad(15) - math.cos(moveDirection) * (math.rad(15) * math.sin(X * 6))
			);
			Grip = CFrame.Angles(
				math.max(math.cos((X + math.rad(30)) * 6) / 7, 0),
				math.rad(5),
				0
			);
			Camera = 1.5 * math.rad(math.cos((X + math.rad(30)) * 6)) + math.rad(0.5); --This is what the roll of the camera will be when you're crawling
		}
	end;
	
	CrawlingGradual = function(X, moveDirection, moveSpeed)
		return {
			leftArm = CFrame.Angles(
				0,
				math.rad(90),
				math.rad(-10)
			) * CFrame.new(
				math.sin(moveDirection) * (-math.sin(X * 3) / 3) - 0.2,
				math.cos(moveDirection) * (-math.sin(X * 3) / 3) + .2,
				math.max(math.cos(X * 3) / 3, 0) + 0.25
			) * CFrame.Angles(
				0,
				0,
				0
			);
			leftLeg = CFrame.new(
				math.sin(moveDirection) * (-math.sin(X * 6) / 4) - 0.2,
				math.cos(moveDirection) * (math.sin(X * 6) / 2) + 0.3,
				math.max(math.cos(X * 6) / 4, 0) - 0.1
			):inverse() * CFrame.Angles(
			0,
			0,
			-math.rad(15) - math.cos(moveDirection) * (math.rad(15) * math.sin(X * 6))
			);
			rightArm = CFrame.Angles(
				0,
				math.rad(-90),
				math.rad(10)
			) * CFrame.new(
				math.sin(moveDirection) * (-math.sin(X * 6) / 3) + 0.2,
				math.cos(moveDirection) * (-math.sin(X * 3) / 3) - 0.2,
				math.max(math.cos((X + math.rad(30)) * 3) / 3, 0) - 0.1
			) * CFrame.Angles(
				0,
				0,
				0
			);
			rightLeg = CFrame.new(
				math.sin(moveDirection) * (math.sin(X * 6) / 4) + 0.2,
				math.cos(moveDirection) * (-math.sin(X * 6) / 2) + 0.3,
				math.max(math.cos((X + math.rad(30)) * 6) / 4, 0) - 0.1
			):inverse() * CFrame.Angles(
			0,
			0,
			math.rad(15) - math.cos(moveDirection) * (math.rad(15) * math.sin(X * 6))
			);
			Grip = CFrame.Angles(
				math.rad(-75) + math.max(math.cos(X * 3) / 3, 0),
				math.rad(5),
				0
			);
			Camera = 1.5 * math.rad(math.cos((X + math.rad(30)) * 6)) + math.rad(0.5); --This is what the roll of the camera will be when you're crawling
		}
	end;
	
	
	CrawlingGradualCrate = function(X, moveDirection, moveSpeed)
		return {
			leftArm = CFrame.Angles(
				0,
				math.rad(90),
				math.rad(-10)
			) * CFrame.new(
				math.sin(moveDirection) * (-math.sin(X * 3) / 3) - 0.2,
				math.cos(moveDirection) * (-math.sin(X * 3) / 3) + .2,
				math.max(math.cos(X * 3) / 3, 0) + 0.25
			) * CFrame.Angles(
				0,
				0,
				0
			);
			leftLeg = CFrame.new(
				math.sin(moveDirection) * (-math.sin(X * 6) / 4) - 0.2,
				math.cos(moveDirection) * (math.sin(X * 6) / 2) + 0.3,
				math.max(math.cos(X * 6) / 4, 0) - 0.1
			):inverse() * CFrame.Angles(
			0,
			0,
			-math.rad(15) - math.cos(moveDirection) * (math.rad(15) * math.sin(X * 6))
			);
			rightArm = CFrame.Angles(
				0,
				math.rad(-90),
				math.rad(10)
			) * CFrame.new(
				math.sin(moveDirection) * (-math.sin(X * 6) / 3),
				math.cos(moveDirection) * (-math.sin(X * 3) / 3) - 0.2,
				math.max(math.cos((X + math.rad(30)) * 3) / 3, 0) - 0.1
			) * CFrame.Angles(
				0,
				0,
				0
			);
			rightLeg = CFrame.new(
				math.sin(moveDirection) * (math.sin(X * 6) / 4) + 0.2,
				math.cos(moveDirection) * (-math.sin(X * 6) / 2) + 0.3,
				math.max(math.cos((X + math.rad(30)) * 6) / 4, 0) - 0.1
			):inverse() * CFrame.Angles(
			0,
			0,
			math.rad(15) - math.cos(moveDirection) * (math.rad(15) * math.sin(X * 6))
			);
			Grip = CFrame.Angles(
				0,
				math.max(math.cos(X * 3) / 3, 0),
				math.rad(90)
			);
			Camera = 1.5 * math.rad(math.cos((X + math.rad(30)) * 6)) + math.rad(0.5); --This is what the roll of the camera will be when you're crawling
		}
	end;
	
	CrawlingStandard = function(X, moveDirection, moveSpeed)
		return {
			leftArm = CFrame.Angles(
				0,
				math.rad(90),
				math.rad(-10)
			) * CFrame.new(
				math.sin(moveDirection) * (math.sin(X * 6) / 4) - 0.2,
				math.cos(moveDirection) * (math.sin(X * 6) / 2) - 0.1,
				math.max(math.cos(X * 6) / 4, 0) - 0.1
			) * CFrame.Angles(
				-math.max(math.cos(X * 6) / 4, 0),
				0,
				0
			);
			leftLeg = CFrame.new(
				math.sin(moveDirection) * (-math.sin(X * 6) / 4) - 0.2,
				math.cos(moveDirection) * (math.sin(X * 6) / 2) + 0.3,
				math.max(math.cos(X * 6) / 4, 0) - 0.1
			):inverse() * CFrame.Angles(
			0,
			0,
			-math.rad(15) - math.cos(moveDirection) * (math.rad(15) * math.sin(X * 6))
			);
			rightArm = CFrame.Angles(
				0,
				math.rad(-5),
				math.rad(10)
			) * CFrame.new(
				math.sin(moveDirection) * (-math.sin(X * 6) / 4) + 0.2,
				math.cos(moveDirection) * (-math.sin(X * 6) / 5) - 0.2,
				math.max(math.cos((X + math.rad(30)) * 6) / 10, 0) - 0.1
			) * CFrame.Angles(
				-math.max(math.cos((X + math.rad(30)) * 6) / 10, 0),
				0,
				0
			);
			rightLeg = CFrame.new(
				math.sin(moveDirection) * (math.sin(X * 6) / 4) + 0.2,
				math.cos(moveDirection) * (-math.sin(X * 6) / 2) + 0.3,
				math.max(math.cos((X + math.rad(30)) * 6) / 4, 0) - 0.1
			):inverse() * CFrame.Angles(
			0,
			0,
			math.rad(15) - math.cos(moveDirection) * (math.rad(15) * math.sin(X * 6))
			);
			Grip = CFrame.Angles(
				math.max(math.cos((X + math.rad(30)) * 6) / 7, 0),
				math.rad(5),
				0
			);
			Camera = 1.5 * math.rad(math.cos((X + math.rad(30)) * 6)) + math.rad(0.5); --This is what the roll of the camera will be when you're crawling
		}
	end;
	
	CrawlingBipod = function(X, moveDirection, moveSpeed, isBipodOn)
		if isBipodOn then
			return {
				leftArm = CFrame.Angles(
					0,
					math.rad(90),
					math.rad(-10)
				) * CFrame.new(
					math.sin(moveDirection) * (math.sin(X * 6) / 4) - 0.2,
					math.cos(moveDirection) * (math.sin(X * 6) / 2) - 0.1,
					math.max(math.cos(X * 6) / 4, 0) - 0.1
				) * CFrame.Angles(
					-math.max(math.cos(X * 6) / 4, 0),
					0,
					0
				);
				leftLeg = CFrame.new(
					math.sin(moveDirection) * (-math.sin(X * 6) / 4) - 0.2,
					math.cos(moveDirection) * (math.sin(X * 6) / 2) + 0.3,
					math.max(math.cos(X * 6) / 4, 0) - 0.1
				):inverse() * CFrame.Angles(
				0,
				0,
				-math.rad(15) - math.cos(moveDirection) * (math.rad(15) * math.sin(X * 6))
				);
				rightArm = CFrame.Angles(
					0,
					math.rad(-5),
					math.rad(10)
				) * CFrame.new(
					math.sin(moveDirection) * (-math.sin(X * 6) / 4) + 0.2,
					math.cos(moveDirection) * (-math.sin(X * 6) / 5) - 0.2,
					math.max(math.cos((X + math.rad(30)) * 6) / 10, 0) - 0.1
				) * CFrame.Angles(
					-math.max(math.cos((X + math.rad(30)) * 6) / 10, 0),
					0,
					0
				);
				rightLeg = CFrame.new(
					math.sin(moveDirection) * (math.sin(X * 6) / 4) + 0.2,
					math.cos(moveDirection) * (-math.sin(X * 6) / 2) + 0.3,
					math.max(math.cos((X + math.rad(30)) * 6) / 4, 0) - 0.1
				):inverse() * CFrame.Angles(
				0,
				0,
				math.rad(15) - math.cos(moveDirection) * (math.rad(15) * math.sin(X * 6))
				);
				Grip = CFrame.Angles(
					math.max(math.cos((X + math.rad(30)) * 6) / 7, 0),
					math.rad(5),
					0
				);
				Camera = 1.5 * math.rad(math.cos((X + math.rad(30)) * 6)) + math.rad(0.5); --This is what the roll of the camera will be when you're crawling
			}
		end
		return {
			leftArm = CFrame.Angles(
				0,
				math.rad(90),
				math.rad(-10)
			) * CFrame.new(
				math.sin(moveDirection) * (math.sin(X * 6) / 4) - 0.2,
				math.cos(moveDirection) * (math.sin(X * 6) / 2) - 0.1,
				math.max(math.cos(X * 6) / 4, 0) - 0.1
			) * CFrame.Angles(
				-math.max(math.cos(X * 6) / 4, 0),
				0,
				0
			);
			leftLeg = CFrame.new(
				math.sin(moveDirection) * (-math.sin(X * 6) / 4) - 0.2,
				math.cos(moveDirection) * (math.sin(X * 6) / 2) + 0.3,
				math.max(math.cos(X * 6) / 4, 0) - 0.1
			):inverse() * CFrame.Angles(
			0,
			0,
			-math.rad(15) - math.cos(moveDirection) * (math.rad(15) * math.sin(X * 6))
			);
			rightArm = CFrame.Angles(
				0,
				math.rad(-90),
				math.rad(10)
			) * CFrame.new(
				math.sin(moveDirection) * (-math.sin(X * 6) / 4) + 0.2,
				math.cos(moveDirection) * (-math.sin(X * 6) / 5) - 0.2,
				math.max(math.cos((X + math.rad(30)) * 6) / 10, 0) - 0.1
			) * CFrame.Angles(
				-math.max(math.cos((X + math.rad(30)) * 6) / 10, 0),
				0,
				0
			);
			rightLeg = CFrame.new(
				math.sin(moveDirection) * (math.sin(X * 6) / 4) + 0.2,
				math.cos(moveDirection) * (-math.sin(X * 6) / 2) + 0.3,
				math.max(math.cos((X + math.rad(30)) * 6) / 4, 0) - 0.1
			):inverse() * CFrame.Angles(
			0,
			0,
			math.rad(15) - math.cos(moveDirection) * (math.rad(15) * math.sin(X * 6))
			);
			Grip = CFrame.Angles(
				math.max(math.cos((X + math.rad(30)) * 6) / 7, 0),
				math.rad(5),
				0
			);
			Camera = 1.5 * math.rad(math.cos((X + math.rad(30)) * 6)) + math.rad(0.5); --This is what the roll of the camera will be when you're crawling
		}
	end;
}