local function createViewModel(plr, c, torso, armC0, gMH)
	local ViewM
	local RArm = c:FindFirstChild("Right Arm")
	local LArm = c:FindFirstChild("Left Arm")
	if gMH then
		gMH(LArm,RArm)
	end
	local animator = Instance.new("Animator")
	animator.Parent = c:WaitForChild("Humanoid",200)
	local gunIgnore = Instance.new("Model")
	gunIgnore.Name = "gunIgnore_"..plr.Name
	gunIgnore.Parent = workspace.ignoreModel


	local torso = c.Torso
	local playerFolder = Instance.new("Model")
	playerFolder.Name = "playerFolder"
	playerFolder.Parent = gunIgnore

	c.Humanoid.AutoRotate = false

	local Shoulders = {
		Right = torso:FindFirstChild("Right Shoulder");
		Left = torso:FindFirstChild("Left Shoulder")
	};

	Shoulders.Right.Part1 = nil
	Shoulders.Left.Part1 = nil

	local headBase = Instance.new("Part")
	headBase.Transparency = 1
	headBase.Name = "headBase"
	headBase.CanCollide = false
	headBase.FormFactor = Enum.FormFactor.Custom
	headBase.Size = Vector3.new(0.2, 0.2, 0.2)
	headBase.BottomSurface = Enum.SurfaceType.Smooth
	headBase.TopSurface = Enum.SurfaceType.Smooth
	headBase.Parent = playerFolder
	headBase:SetNetworkOwner(plr)

	local headWeld = Instance.new("Motor6D")
	headWeld.Part0 = torso
	headWeld.Part1 = headBase
	headWeld.C0 = CFrame.new(0, 1.5, 0)
	headWeld.Parent = torso



	local headWeld2 = Instance.new("Weld")
	headWeld2.Part0 = headBase
	headWeld2.Part1 = c.Head
	headWeld2.Parent = headBase

	local animBase = Instance.new("Part")
	animBase.Transparency = 1
	animBase.Name = "animBase"
	animBase.CanCollide = false
	animBase.FormFactor = Enum.FormFactor.Custom
	animBase.Size = Vector3.new(0.2, 0.2, 0.2)
	animBase.BottomSurface = Enum.SurfaceType.Smooth
	animBase.TopSurface = Enum.SurfaceType.Smooth
	animBase.Parent = playerFolder
	animBase:SetNetworkOwner(plr)

	local animWeld = Instance.new("Motor6D")
	animWeld.Name = "animWeld"
	animWeld.Part0 = animBase
	animWeld.Part1 = headBase
	animWeld.Parent = animBase

	local armBase = Instance.new("Part")
	armBase.Transparency = 1
	armBase.Name = "ArmBase"
	armBase.CanCollide = false
	armBase.FormFactor = Enum.FormFactor.Custom
	armBase.Size = Vector3.new(0.2, 0.2, 0.2)
	armBase.BottomSurface = Enum.SurfaceType.Smooth
	armBase.TopSurface = Enum.SurfaceType.Smooth
	armBase.Parent = playerFolder
	armBase:SetNetworkOwner(plr)

	local ABWeld =Instance.new("Motor6D")
	ABWeld.Part0 = armBase
	ABWeld.Part1 = animBase
	ABWeld.Name = "ABWeld"
	ABWeld.Parent = armBase


	local LArmBase = Instance.new("Part")
	LArmBase.Transparency = 1
	LArmBase.Name = "LArmBase"
	LArmBase.CanCollide = false
	LArmBase.FormFactor = Enum.FormFactor.Custom
	LArmBase.Size = Vector3.new(0.2, 0.2, 0.2)
	LArmBase.BottomSurface = Enum.SurfaceType.Smooth
	LArmBase.TopSurface = Enum.SurfaceType.Smooth
	LArmBase.Parent = playerFolder
	LArmBase:SetNetworkOwner(plr)

	local RArmBase = Instance.new("Part")
	RArmBase.Transparency = 1
	RArmBase.Name = "RArmBase"
	RArmBase.CanCollide = false
	RArmBase.FormFactor = Enum.FormFactor.Custom
	RArmBase.Size = Vector3.new(0.2, 0.2, 0.2)
	RArmBase.BottomSurface = Enum.SurfaceType.Smooth
	RArmBase.TopSurface = Enum.SurfaceType.Smooth
	RArmBase.Parent = playerFolder
	RArmBase:SetNetworkOwner(plr)

	local LWeld =  Instance.new("Motor6D") 
	LWeld.C0 = armC0[1]
	LWeld.C1 = CFrame.new()
	LWeld.Name = "LWeld"
	LWeld.Part0 = armBase	
	LWeld.Part1 = LArmBase
	LWeld.Parent = armBase 

	local RWeld = Instance.new("Motor6D") 
	RWeld.Name = "RWeld"
	RWeld.Part0 = armBase
	RWeld.Part1 = RArmBase
	RWeld.C0 = armC0[2]
	RWeld.C1 = CFrame.new()
	RWeld.Parent = armBase

	local LWeld2 = Instance.new("Motor6D")
	LWeld2.Name = "LWeld"
	LWeld2.Part0 = LArmBase
	LWeld2.Part1 = LArm
	LWeld2.Parent = LArmBase


	local RWeld2 = Instance.new("Motor6D")
	RWeld2.Name = "RWeld"
	RWeld2.Part0 = RArmBase
	RWeld2.Part1 = RArm
	RWeld2.Parent = RArmBase

	LArm.Size = Vector3.new(0.8,2,0.8)
	RArm.Size = Vector3.new(0.8,2,0.8)

	ViewM = {
		headBase = headBase;
		headWeld = headWeld;
		headWeld2 = headWeld2;
		armBase = armBase;
		animWeld = animWeld;
		ABWeld = ABWeld;
		LWeld = LWeld;
		RWeld = RWeld;
		LWeld2 = LWeld2;
		RWeld2 = RWeld2;
		playerFolder = playerFolder;
		gunIgnore = gunIgnore;
	}

	local Grip = Instance.new("Motor6D")
	Grip.Name = "RightGrip"
	Grip.C0 = CFrame.new(0, -1, 0) * CFrame.Angles(-0.5 * math.pi, 0, 0)
	Grip.Part0 = RArm
	Grip.Parent = RArm


	local Grip2 = Instance.new("Motor6D")
	Grip2.Name = "LeftGrip"
	Grip2.Part0 = LArm
	Grip2.Parent = LArm

	return ViewM, {Grip,Grip2}
end
return createViewModel