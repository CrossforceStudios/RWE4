local weldHelpers = {
	["Assemble"] = function(p0,p1,c1,name,attOffset)
		local weld
		weld = Instance.new("Motor6D")
		if name then
			weld.Name = name
		end
		weld.C0 = p0.CFrame:toObjectSpace(p1.CFrame)
		if attOffset then
			weld.C0 *= attOffset
		end
		weld.C1 = c1
		weld.Part0 = p0
		weld.Part1 = p1
		weld.Parent = p0
		
		return weld
	end;
	["AssembleC"] = function(p0,p1,c0,c1,name)
		local weld
		weld = Instance.new("Motor6D")
		if name then
			weld.Name = name
		end
		weld.C0 = p0.CFrame:toObjectSpace(p1.CFrame)
		weld.C1 = c1
		weld.Part0 = p0
		weld.Part1 = p1
		weld.Parent = p0
		return weld
	end;
	["AssembleAttachment"] = function(menunode,p1,cfOffset,Offsets,metaItem,name,mainC0,aType,slideCF,wPart)
		local weld
		weld = Instance.new("Motor6D")
		if name then
			weld.Name = name
		end
		local c0 = (wPart or metaItem[(metaItem:FindFirstChild("Lid") and aType == "Optics") and "Lid" or "HoldPart"]).CFrame:toObjectSpace(menunode.CFrame * (cfOffset or Offsets[metaItem.Name]) * (slideCF or CFrame.new()))
		weld.C0 = c0*mainC0
		weld.Part0 = wPart or metaItem:FindFirstChild((metaItem:FindFirstChild("Lid")  and aType == "Optics") and "Lid" or "HoldPart")
		weld.Part1 = p1
		weld.Parent = weld.Part0
		return weld
	end;	
	["AssembleParent"] = function(p0,p1,c1,parent,name)
		local weld
		weld = Instance.new("Motor6D")
		if name then
			weld.Name = name
		end
		weld.C0 = p0.CFrame:toObjectSpace(p1.CFrame)
		weld.C1 = c1
		weld.Part0 = p0
		weld.Part1 = p1
		weld.Parent =parent or  p0
		return weld
	end;	
	["WConstraint"] = function(p0,p1,name)
		local weld 
		weld = Instance.new("WeldConstraint")
		if name then
			weld.Name = name
		end
		weld.Part0 = p0
		weld.Part1 = p1
		weld.Parent = p0
		weld.Enabled = true
		return weld
	end;
	["AssembleSling"] = function(SlingA,SlingB,SlingOpts,item,name)
		local rope
		rope = Instance.new("RopeConstraint")
		if name then
			rope.Name = name
		end
		rope.Attachment0 = SlingA.SlingPoint;
		rope.Attachment1 = SlingB.SlingPoint;
		rope.Length = SlingOpts.Length or 4.25;
		rope.Color = SlingOpts.Color or BrickColor.new("Dirt brown")
		rope.Thickness = SlingOpts.Thickness or 0.05;
		rope.Restitution = 0.5
		rope.Enabled = true
		rope.Parent = item
		rope.Visible = true;
		return rope
	end;
}

return function(wHelper,...)
	local helper = weldHelpers[wHelper]
	if helper then
		return helper(...)
	end
end;