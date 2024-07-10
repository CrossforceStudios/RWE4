local CF = CFrame.new
local CFANG = CFrame.Angles
return function()
	return {
		name = "FirstPerson";
		sensitivity = 0.3;
		smoothness = 0.05;
		zPerspective = Vector3.new(0,0,0);
		getCF = function(self,...)
			
			return CF(self.Subject.CFrame.p)  * CFANG(0,self.cameraPerspective.X + self.offset.X,0) * CFANG(self.cameraPerspective.Y + self.offset.Y,0,0) *  CFANG(0,0,self.offset.Z) * CF(0,0,0.5) * CF(0,0,self.zPerspective.Z) 
		end;
	}
end