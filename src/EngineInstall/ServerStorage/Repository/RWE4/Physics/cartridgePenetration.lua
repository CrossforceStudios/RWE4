local CollectionService = game:GetService("CollectionService")
return function(c,o)
	local function linePlaneIntersect(u,P0,n,V0)
		local w = V0-P0
		local SI = n:Dot(w.Unit)/n:Dot(u.Unit)
		return (SI >= 0 and SI <= 1),(P0 + u*SI)
	end
	local maxRicochetAngle = math.cos(math.rad(70))
	return function(cast, raycastI, vel, bullet, origin)
		if o.h or o.e or (not raycastI) then
			return false, c.Penetration, (vel), 0.2,  false, 0
		else
			local h, p, n = raycastI.Instance, raycastI.Position, raycastI.Normal
			local m = raycastI.Material
			local dir = cast.UserData.Direction;
			local dist = cast.StateInfo.DistanceCovered;
			local ori = origin;
			local vb = h:FindFirstAncestor("Body")  or h:FindFirstAncestor("Doors") or h:FindFirstAncestor("Hull") or h:FindFirstAncestor("Cannon") or h:FindFirstAncestor("Controls") or h:FindFirstAncestor("Wheels")
			if vb then
				if (vb.Parent:FindFirstChild("IsTank")) or h.Parent:FindFirstChild("IsTank") then
					return c.Penetration >= 0.75 or c.IsAntiMateriel, c.Penetration, vel, 0.2, not c.IsAntiMateriel, PhysicalProperties.new(m).Density
				end
			end
			if m == Enum.Material.Water then
				return false, c.Penetration,  vel, 0, false
			end
			if CollectionService:HasTag(h, "Damageable") then
				return c.Penetration > 0.4, c.Penetration, vel, 0.2, false, PhysicalProperties.new(m).Density
			end
			--Get surface normals of the part
			local x,y,z,
			a,b,c2,
			d,e,f,
			g,h2,i = h.CFrame:components()
			local nn1 = Vector3.new(a,d,g).unit
			local nn2 = Vector3.new(b,e,h2).unit
			local nn3 = Vector3.new(c2,f,i).unit
			local n2 = {nn1;nn2;nn3;-nn1;-nn2;-nn3}
			local pos = {h.Position + n2[1] * (h.Size.x/2);h.Position + n2[2] * (h.Size.y/2);h.Position + n2[3] * (h.Size.z/2);h.Position + n2[4] * (h.Size.x/2);h.Position + n2[5] * (h.Size.y/2);h.Position + n2[6] * (h.Size.z/2)}
			local density = PhysicalProperties.new(m).Density
			
			
			local distance,outnormal = c.Range,Vector3.new(0,0,1)
			
			do
				for i = 1, #n2 do
					local norm = n2[i]
					if norm then
						if norm:Dot(vel) >= 0 then
							local intersect, coord = linePlaneIntersect(dir.Unit,ori,norm,pos[i])
							local mag = (coord - p).Magnitude
							if intersect and mag < distance then
								distance, outnormal = mag, norm
							end	
						end
					end
				end
			end
			local newBDist = dist + distance
			local outOfRange = (newBDist > c.Range)
			local vel2 = (vel.unit*math.min((1/c.Range)*distance*density/c.Penetration,vel.Magnitude)) * 10
			local dot = n:Dot(vel.unit)
			dot = dot * (20 / density) * (vel.magnitude / c.Velocity * (3/4))
			
			local richochet = (math.abs(dot) <= maxRicochetAngle)
			
			local res =  (((vel.magnitude - vel2.magnitude) >= math.clamp((vel.Magnitude / 100),20,100)) and (not outOfRange))
			if res ~= nil then
				richochet = (c.Penetration <= 0.2)
			end
			if h:IsA("Terrain") then
				res = false
				richochet = false
			end
			return res, c.Penetration,  vel.Unit * (vel.magnitude - vel2.magnitude),distance,richochet,density
		end
	end
end