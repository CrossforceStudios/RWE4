local Furniture = {};
Furniture.__index = Furniture;
local RunService = game:GetService("RunService")
local Resources = require(game.ReplicatedStorage.Resources)
local RemoteService =	Resources:LoadLibrary("RemoteService")
local PseudoInstance = Resources:LoadLibrary("PseudoInstance")

local inList = function(v,l)
	for _, v2 in pairs(l) do
		if v == v2 then
			return true
		end
	end
	return false
end

function Furniture.new(...)
	local furniture = {}
	local args = {...}
	furniture.Name = args[1]
	furniture.Title = args[2]
	furniture.ApprovedItems = args[3];
	furniture.Appearance = args[4]
	furniture.Type = args[5]
	return setmetatable(furniture, Furniture)
end


function Furniture.createRecord(typeC,c)
	local cT = {}
	if typeC == "Color" then
		cT.Type = "Color3Value";
		cT.Value = c.Color;
		cT.Name = "OriginalColor"
	elseif typeC == "Material" then
		cT.Type = "IntValue"
		cT.Name = "OriginalMaterial"
		cT.Value = c.Material.Value;
	elseif typeC == "Reflectance" then 
		cT.Type = "NumberValue"
		cT.Name = "OriginalReflectance"
		cT.Value = c.Reflectance
	elseif typeC == "Transparency" then
		cT.Type = "NumberValue"
		cT.Name = "OriginalTransparency"
		cT.Value = c.Reflectance
	elseif typeC == "UsePartColor" then 
		cT.Type = "BoolValue"
		cT.Name = "OriginalUsePartColor"
		cT.Value = c.UsePartColor
	end	
	if cT.Type then
		local cV = Instance.new(cT.Type)
		cV.Name = cT.Name
		cV.Value = cT.Value
		cV.Parent = c
		return cV
	end	
	return nil;
end

function Furniture:Apply(weapon: Model,cosm)
	if inList(weapon.Name,self.ApprovedItems) or cosm then
		for _, w in ipairs(weapon:GetDescendants()) do
			for n, app in pairs(self.Appearance) do
				if w.Name == n and w:IsA("BasePart") then
					if app.Texture and w.Transparency ~= 1 then
						for _, side in app.Sides do
							local tex = Instance.new("Texture")
							tex.Name = "FurnitureTexture"
							tex.Texture = app.Texture
							tex.Parent = w
							tex.StudsPerTileU = 1
							tex.StudsPerTileV = 1
							tex.Face = Enum.NormalId[side]
						end
					end
					if app.Color then
						local c1 = Furniture.createRecord("Color",w)	
						if w:IsA("UnionOperation") and (not w.UsePartColor) then
							local c = Furniture.createRecord("UsePartColor",w)								
							w.UsePartColor = true
						end
						w.Color = app.Color;

						print("Color")
					end
					if app.Material then
						local phyProps = w.CustomPhysicalProperties
						local c2 = Furniture.createRecord("Material",w)		
						w.Material = app.Material
						w.CustomPhysicalProperties = phyProps
						if app.Reflectance then
							local c = Furniture.createRecord("Reflectance",w)								
							w.Reflectance = app.Reflectance
							if app.Transparency then
								local c = Furniture.createRecord("Reflectance",w)
								w.Transparency = app.Transparency
							end
						end
					end
					w:SetAttribute("FurnitureName", self.Type)
				end
			end
		end
	end
end

function Furniture.Clear(weapon, fName)

	for _, w in ipairs(weapon:GetDescendants()) do
		if w:GetAttribute("FurnitureType") ~= fName then
			continue
		end
		if w:FindFirstChild("OriginalUsePartColor") then
			w.UsePartColor = w.OriginalUsePartColor.Value
			w.OriginalUsePartColor:Destroy()
		end
		if w:FindFirstChild("OriginalColor") then
			w.Color = w.OriginalColor.Value
			w.OriginalColor:Destroy()
		end
		if w:FindFirstChild("OriginalMaterial") then
			w.Material = w.OriginalMaterial.Value
			w.OriginalMaterial:Destroy()
		end				
		if w:FindFirstChild("OriginalReflectance") then
			w.Reflectance = w.OriginalReflectance.Value
			w.OriginalReflectance:Destroy()
		end	
		if w:FindFirstChild("OriginalTransparency") then
			w.Transparency = w.OriginalTransparency.Value
			w.OriginalTransparency:Destroy()
		end	
		if w:FindFirstChild("FurnitureTexture") then
			for _, tex in w:GetChildren() do
				if tex:IsA("Texture") and tex.Name == "FurnitureTexture" then
					tex:Destroy()
				end
			end
		end	
	end
end

function Furniture:UpdateUIClient(weaponImage, weapon, ...)
	Furniture.Clear(weapon, self.Name)
	Furniture.Clear(weaponImage, self.Name)
	self:Apply(weaponImage,true)
	if RunService:IsClient() then
		if self.Type == "Furniture" then
			RemoteService.fetch("Server","ChangeFurniture",weapon,self.Name)
		else
			RemoteService.fetch("Server","ChangeAlloy",weapon,self.Name)				
		end
	end
end;



return Furniture