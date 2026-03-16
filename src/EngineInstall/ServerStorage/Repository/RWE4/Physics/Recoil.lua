local Recoil = {};
local Resources = require(game.ReplicatedStorage.Resources)
local Accurand = Resources:LoadLibrary("Accurand")
local Lerps = Resources:LoadLibrary("Lerps")
local VEC2 = Vector2.new
local V3 = Vector3.new
local RAD = math.rad
Recoil.__index = Recoil
function Recoil.new(...)
	local r = {};
	r.SideRecoil =  Vector2.new(0,1);
	r.BackRecoil =  Vector2.new(0,1);
	r.UpRecoil =  Vector2.new(0,1);
	r.TiltRecoil =  Vector2.new(0,1);
	r.lastSideRecoil = {0,0};
	return setmetatable(r, Recoil)
end

function Recoil:SetBack(min,max)
	self.BackRecoil =  Vector2.new(min,max);
end

function Recoil:SetSide(left,right)
	self.SideRecoil =  Vector2.new(left,right)
end

function Recoil:SetTilt(left,right)
	self.TiltRecoil =  Vector2.new(left,right)
end

function Recoil:SetUp(min,max)
	self.UpRecoil =  Vector2.new(min,max)
end

function Recoil:Components()
	return self.BackRecoil.X, self.BackRecoil.Y, self.SideRecoil.X, self.SideRecoil.Y, self.UpRecoil.X, self.UpRecoil.Y, self.TiltRecoil.X, self.TiltRecoil.Y
end

function Recoil:ReduceByPercentage(percentage)
	local comp = {self:Components()}
	self.BackRecoil =  Vector2.new(comp[1] * percentage,comp[2] * percentage)
	self.SideRecoil =  Vector2.new(comp[3] * percentage,comp[4] * percentage)
	self.UpRecoil =  Vector2.new(comp[5] * percentage,comp[6] * percentage)
	self.TiltRecoil =  Vector2.new(comp[7] * percentage,comp[8] * percentage)
end

function Recoil:GetSRA()
	local sideRecoilAlpha = 0
	if self.lastSideRecoil[1] < 0 and self.lastSideRecoil[2] < 0 then --This conditional basically makes sure the gun tilt isn't in the same direction for more than 2 shots
		sideRecoilAlpha = Accurand(0, 1, 0.1)
	elseif self.lastSideRecoil[1] > 0 and self.lastSideRecoil[2] > 0 then
		sideRecoilAlpha = Accurand(-1, 0, 0.1)
	else
		sideRecoilAlpha = Accurand(-1, 1, 0.1)
	end
	return sideRecoilAlpha
end

function Recoil:GetActualSideRecoil(srA)
	return Lerps.number(self.SideRecoil.X, self.SideRecoil.Y, srA / 2 + 0.5) --Get the side recoil
end

function Recoil:GetActualTiltRecoil(srA)
	return Lerps.number(self.TiltRecoil.X, self.TiltRecoil.Y, srA / 2 + 0.5) --Get the side recoil
end

function Recoil:GetActualBackRecoil()
	return Accurand(self.BackRecoil.X, self.BackRecoil.Y, 0.01) --Get the kickback recoil
end

function Recoil:GetActualUpRecoil()
	return Accurand(self.UpRecoil.X, self.UpRecoil.Y, 0.01) --Get the up recoil
end

function Recoil:GetRecoilChangeeFromStock(stockType, recoilCoeff, options)
	local recoil = {self.BackRecoil;self.SideRecoil;self.UpRecoil;self.TiltRecoil;}
	if stockType == "Folding" then
		for i, recoilVal in recoil do
			recoil[i] += (recoil[i] * recoilCoeff)
		end
	elseif stockType == "Telescopic" then
		for i, recoilVal in recoil do
			recoil[i] -= (recoil[i] * recoilCoeff)
		end
	end
	self.BackRecoil = recoil[1]
	self.SideRecoil = recoil[2]
	self.UpRecoil = recoil[3]
	self.TiltRecoil = recoil[4]
end

function Recoil:GetGunTransform(Aimed)
	local srA = self:GetSRA()
	local backRecoil = self:GetActualBackRecoil()
	local upRecoil = self:GetActualUpRecoil()
	local sideRecoil = self:GetActualSideRecoil(srA)
	local tiltRecoil = self:GetActualTiltRecoil(srA)
	local gT1 = {
		Pos = V3(
			0,
			0,
			if Aimed then -backRecoil * 1.15 else -backRecoil * 1.25
		);
		Rot = V3(
			-RAD(upRecoil * 10),
			RAD(sideRecoil * 10),
			RAD(tiltRecoil * 10)
		) 
	}
	local gT2 = V3(
		-RAD(sideRecoil * 10),
		RAD(upRecoil * 10),
		0
	)
	return gT1, gT2, srA
end

return Recoil