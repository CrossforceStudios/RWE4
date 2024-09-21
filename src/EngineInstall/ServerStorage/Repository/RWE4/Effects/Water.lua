local WaterService = {}
local Resources = require(game.ReplicatedStorage.Resources)
local FastWait = Resources:LoadLibrary("FastWait")
local VOXEL_SIZE = Vector3.new(4, 4, 4)
local TERRAIN = workspace.Terrain
local WATER = Enum.Material.Water
local AIR = Enum.Material.Air
local Janitor = Resources:LoadLibrary("Janitor")
local Zone = Resources:LoadLibrary("Zone")

local function createRG3FromPart(part)
	return Region3.new(part.CFrame.p - part.Size/2,part.CFrame.p  + part.Size/2)
end 

local function createWaterInPart(part,res)
	if part:IsA("BasePart") then
		local rg = createRG3FromPart(part)
		TERRAIN:FillBlock(rg.CFrame,part.Size,WATER)
		part.Transparency = 1;
		part.CanCollide = false;
	end 
end

local function clearWaterZones()
		TERRAIN:Clear()
end

function WaterService:Fill(map)
	local mapWaters = map:FindFirstChild("MapWaters")
	if mapWaters then
		local man = map:FindFirstChild("Manifest")
		if man then
			man = require(man)
		end
		if man and man.WaterColor then
			TERRAIN.WaterColor = man.WaterColor;
		end
		for _,  mapWater in ipairs(mapWaters:GetChildren()) do
			local mapRes = 4
			if mapWater:FindFirstChild("Res") then
				mapRes = mapWater.Res.Value
			end
			createWaterInPart(mapWater,mapRes);
			FastWait(0.05)
		end
	end	
end

function WaterService:GetAllZones(map)
	local result = {};
	local mapWaters = map:FindFirstChild("MapWaters")
	if mapWaters then
		local man = map:FindFirstChild("Manifest")
		if man then
			man = require(man)
		end
		if man and man.WaterColor then
			TERRAIN.WaterColor = man.WaterColor;
		end
		for _,  mapWater in ipairs(mapWaters:GetChildren()) do
			local mapRes = 4
			result[mapWater] = Zone.new(mapWater)
		end
	end	
	return result
end

function WaterService:IsSubmergedPart(part)
	local point = part.CFrame.Position
	local cellPos = TERRAIN:WorldToCell(point)
	local regionCorner = TERRAIN:CellCornerToWorld(cellPos.X, cellPos.Y, cellPos.Z)
	local region = Region3.new(regionCorner, regionCorner + Vector3.new(4, 8, 4))
	local material, occupancy = TERRAIN:ReadVoxels(region, 4)

	local material0, occupancy0 = material[1][1][1], occupancy[1][1][1] -- cell containing point
	local material1, occupancy1 = material[1][2][1], occupancy[1][2][1] -- cell above

	if material0 == WATER then
		-- point is in water cell and cell above is not air => we're either completely in water or at the water-solid boundary
		-- so we can safely assume underwater
		if material1 ~= AIR then
			-- Can overestimate water level to be at top of cell
			return true, cellPos.Y * VOXEL_SIZE.Y, false
		end

		-- cell above is air => have to estimate the plane based on occupancy
		local waterHeightCell = occupancy0
		-- cell clamping from mesher
		local waterLevelCell = cellPos.Y + 0.5 + math.max(0, waterHeightCell - 0.5)
		return point.Y / 4 < waterLevelCell, waterLevelCell * VOXEL_SIZE.Y, true
	elseif material1 == WATER then
		-- point is in solid cell and cell above is water => we're at the water-solid boundary
		-- so we can safely assume underwater
		if material0 ~= AIR then
			-- Can overestimate water level to be at top of cell
			-- Adding plus 2 because cell0 is already + 1 above posY
			return true, (cellPos.Y + 1) * VOXEL_SIZE.Y, false
		end

		-- point is in air => have to estimate the plane based on occupancy
		local waterHeightCell = occupancy1
		-- cell clamping from mesher
		local waterLevelCell = (cellPos.Y + 1) - math.min(waterHeightCell, 0.5)
		return point.Y / 4 > waterLevelCell, waterLevelCell * VOXEL_SIZE.Y, true
	end
	return false, 0, false
end

function WaterService:IsSubmerged(char,isSwimming)
	local point = char.Head.CFrame.Position
	if isSwimming then
		point = point - Vector3.new(0,0.5,0)
	end
 	local cellPos = TERRAIN:WorldToCell(point)
    local regionCorner = TERRAIN:CellCornerToWorld(cellPos.X, cellPos.Y, cellPos.Z)
    local region = Region3.new(regionCorner, regionCorner + Vector3.new(4, 8, 4))
    local material, occupancy = TERRAIN:ReadVoxels(region, 4)
    
    local material0, occupancy0 = material[1][1][1], occupancy[1][1][1] -- cell containing point
    local material1, occupancy1 = material[1][2][1], occupancy[1][2][1] -- cell above
    
    if material0 == WATER then
        -- point is in water cell and cell above is not air => we're either completely in water or at the water-solid boundary
        -- so we can safely assume underwater
        if material1 ~= AIR then
            -- Can overestimate water level to be at top of cell
            return true, cellPos.Y * VOXEL_SIZE.Y, false
        end
    
        -- cell above is air => have to estimate the plane based on occupancy
        local waterHeightCell = occupancy0
        -- cell clamping from mesher
        local waterLevelCell = cellPos.Y + 0.5 + math.max(0, waterHeightCell - 0.5)
        return point.Y / 4 < waterLevelCell, waterLevelCell * VOXEL_SIZE.Y, true
    elseif material1 == WATER then
        -- point is in solid cell and cell above is water => we're at the water-solid boundary
        -- so we can safely assume underwater
        if material0 ~= AIR then
            -- Can overestimate water level to be at top of cell
            -- Adding plus 2 because cell0 is already + 1 above posY
            return true, (cellPos.Y + 1) * VOXEL_SIZE.Y, false
        end
    
        -- point is in air => have to estimate the plane based on occupancy
        local waterHeightCell = occupancy1
        -- cell clamping from mesher
        local waterLevelCell = (cellPos.Y + 1) - math.min(waterHeightCell, 0.5)
        return point.Y / 4 > waterLevelCell, waterLevelCell * VOXEL_SIZE.Y, true
    end
    return false, 0, false
end

function WaterService:Clear()
	clearWaterZones()
end
return WaterService