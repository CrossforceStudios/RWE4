-- The core resource manager and library loader for RoStrap
-- @rostrap Resources
-- It is designed to increase organization and streamline the retrieval and networking of resources.
-- @documentation https://rostrap.github.io/Resources/
-- @source https://github.com/RoStrap/Resources/
-- @author Validark

local RunService = game:GetService("RunService")

local Metatable = {}
local Resources = setmetatable({}, Metatable)
local Caches = {} -- All cached data within Resources is accessible through Resources:GetLocalTable()

local Instance_new, type, require = Instance.new, type, require
local LocalResourcesLocation

local SERVER_SIDE = RunService:IsServer()
local UNINSTANTIABLE_INSTANCES = setmetatable({
	Folder = false; RemoteEvent = false; BindableEvent = false;
	RemoteFunction = false; BindableFunction = false; Library = true;
}, {
	__index = function(self, InstanceType)
		local Instantiable, GeneratedInstance = pcall(Instance_new, InstanceType)
		local Uninstantiable

		if Instantiable and GeneratedInstance then
			GeneratedInstance:Destroy()
			Uninstantiable = false
		else
			Uninstantiable = true
		end

		self[InstanceType] = Uninstantiable
		return Uninstantiable
	end;
})

function Resources:GetLocalTable(TableName) -- Returns a cached table by TableName, generating if non-existant
	TableName = self ~= Resources and self or TableName
	local Table = Caches[TableName]

	if not Table then
		Table = {}
		Caches[TableName] = Table
	end

	return Table
end

local function GetFirstChild(Folder, InstanceName, InstanceType)
	local Object = Folder:FindFirstChild(InstanceName)

	if not Object then
		if UNINSTANTIABLE_INSTANCES[InstanceType] then return nil end
		Object = Instance_new(InstanceType)
		Object.Name = InstanceName
		Object.Parent = Folder
	end

	return Object
end

function Metatable:__index(MethodName)
	if type(MethodName) ~= "string" then error("[Resources] Attempt to index Resources with invalid key: string expected, got " .. typeof(MethodName), 2) end
	if MethodName:sub(1, 3) ~= "Get" and MethodName:sub(1,3) ~= "All" and MethodName:sub(1, 3) ~= "Ptr" then error("[Resources] Methods should begin with \"Get\"", 2) end
	local InstanceType = MethodName:sub(4)

	-- Set CacheName to ["RemoteEvent" .. "s"], or ["Librar" .. "ies"]
	local a, b = string.byte(InstanceType, -2, -1) -- this is a simple gimmick but works well enough for all Roblox ClassNames :D
	local CacheName = b == 121 and a ~= 97 and a ~= 101 and a ~= 105 and a ~= 111 and a ~= 117 and InstanceType:sub(1, -2) .. "ies" or InstanceType .. "s"
	local IsLocal = InstanceType:sub(1, 5) == "Local"
	local Cache, Folder, FolderGetter -- Function Constants

	if IsLocal then -- Determine whether a method is local
		InstanceType = InstanceType:sub(6)

		if InstanceType == "Folder" then
			FolderGetter = function() return GetFirstChild(LocalResourcesLocation, "Resources", "Folder") end
		else
			FolderGetter = Resources.GetLocalFolder
		end
	else
		if InstanceType == "Folder" then
			FolderGetter = function() return script end
		else
			FolderGetter = Resources.GetFolder
		end
	end

	local function AllFunction(this, InstanceName)
		local instances = {}
		if not Folder then
			Cache = Caches[CacheName]
			Folder = FolderGetter(IsLocal and CacheName:sub(6) or CacheName)

			if not Cache then
				Cache = Folder:GetChildren() -- Cache children of Folder into Table
				Caches[CacheName] = Cache

				for i = 1, #Cache do
					local Child = Cache[i]
					table.insert(instances,Child)
					Cache[i] = nil
				end
			else
				instances = Cache
			end
		end
		return instances
	end

	local function GetFunction(this, InstanceName)
		InstanceName = this ~= self and this or InstanceName
		if type(InstanceName) ~= "string" then error("[Resources] " .. MethodName .. " expected a string parameter, got " .. typeof(InstanceName), 2) end

		if not Folder then
			Cache = Caches[CacheName]
			Folder = FolderGetter(IsLocal and CacheName:sub(6) or CacheName)

			if not Cache then
				Cache = Folder:GetChildren() -- Cache children of Folder into Table
				Caches[CacheName] = Cache

				for i = 1, #Cache do
					local Child = Cache[i]
					Cache[Child.Name] = Child
					Cache[i] = nil
				end
			end
		end

		local Object = Cache[InstanceName]

		if not Object then
			if SERVER_SIDE or IsLocal then
				Object = GetFirstChild(Folder, InstanceName, InstanceType)
			else
				Object = Folder:WaitForChild(InstanceName, 5)

				if not Object then
					local Caller = getfenv(0).script

					if Caller and Caller.Parent and Caller.Parent.Parent == script then
						warn("[Resources] Make sure a Script in ServerScriptService calls `Resources:LoadLibrary(\"" .. Caller.Name .. "\")`")
					else
						warn("[Resources] Make sure a Script in ServerScriptService calls `require(ReplicatedStorage:WaitForChild(\"Resources\"))`")
					end

					Object = Folder:WaitForChild(InstanceName)
				end
			end

			Cache[InstanceName] = Object
		end

		return Object
	end

	local function GetPtrFunction(this, InstanceName)
		InstanceName = this ~= self and this or InstanceName
		if type(InstanceName) ~= "string" then error("[Resources] " .. MethodName .. " expected a string parameter, got " .. typeof(InstanceName), 2) end

		if not Folder then
			Cache = Caches[CacheName]
			Folder = FolderGetter(IsLocal and CacheName:sub(6) or CacheName)

			if not Cache then
				Cache = Folder:GetChildren() -- Cache children of Folder into Table
				Caches[CacheName] = Cache

				for i = 1, #Cache do
					local Child = Cache[i]
					Cache[Child.Name] = Child
					Cache[i] = nil
				end
			end
		end

		local Object = Cache[InstanceName]

		if not Object then
			if SERVER_SIDE or IsLocal then
				Object = GetFirstChild(Folder, InstanceName, InstanceType)
			else
				Object = Folder:FindFirstChild(InstanceName)

				if not Object then
					local Caller = getfenv(0).script

					if Caller and Caller.Parent and Caller.Parent.Parent == script then
						warn("[Resources] Make sure a Script in ServerScriptService calls `Resources:LoadLibrary(\"" .. Caller.Name .. "\")`")
					else
						warn("[Resources] Make sure a Script in ServerScriptService calls `require(ReplicatedStorage:WaitForChild(\"Resources\"))`")
					end

					Object = Folder:FindFirstChild(InstanceName)
				end
			end

			Cache[InstanceName] = Object
		end

		return Object
	end

	Resources[MethodName] = MethodName:sub(1,3)== "Ptr" and GetPtrFunction or (MethodName:sub(1,3) == "Get" and GetFunction or AllFunction)
	return MethodName:sub(1,3)== "Ptr" and GetPtrFunction or (MethodName:sub(1,3) == "Get" and GetFunction or AllFunction)
end

if not SERVER_SIDE then
	local LocalPlayer repeat LocalPlayer = game:GetService("Players").LocalPlayer until LocalPlayer or not RunService.Heartbeat:Wait()
	repeat LocalResourcesLocation = LocalPlayer:FindFirstChildOfClass("PlayerScripts") until LocalResourcesLocation or not RunService.Heartbeat:Wait()
else
	LocalResourcesLocation = game:GetService("ServerStorage")
	local LibraryRepository = LocalResourcesLocation:FindFirstChild("Repository") or game:GetService("ServerScriptService"):FindFirstChild("Repository")

	local function CacheLibrary(Storage, Library, StorageName)
		if Storage[Library.Name] then
			error("[Resources] Duplicate " .. StorageName .. " Found:\n\t"
				.. Storage[Library.Name]:GetFullName() .. " and \n\t"
				.. Library:GetFullName()
				.. "\nOvershadowing is only permitted when a server-only library overshadows a replicated library"
				, 0)
		else
			Storage[Library.Name] = Library
		end
	end

	if LibraryRepository then
		-- If Folder `Repository` exists, move all Libraries over to ReplicatedStorage
		-- unless if they have "Server" in their name or in the name of a parent folder

		local ServerLibraries = {}
		local ReplicatedLibraries = Resources:GetLocalTable("Libraries")
		local FoldersToHandle = {}
		local FolderChildren, ExclusivelyServer = LibraryRepository:GetChildren(), false

		while FolderChildren do
			FoldersToHandle[FolderChildren] = nil

			for i = 1, #FolderChildren do
				local Child = FolderChildren[i]
				local ClassName = Child.ClassName
				local ServerOnly = ExclusivelyServer or (Child.Name:find("Server", 1, true) and true or false)

				if ClassName == "ModuleScript" then
					if ServerOnly then
						Child.Parent = Resources:GetLocalFolder("Libraries")
						CacheLibrary(ServerLibraries, Child, "ServerLibraries")
					else
						-- ModuleScripts which are not descendants of ServerOnly folders and do not have "Server" in name should be moved to Libraries
						--	if there are descendants of the ModuleScript with "Server" in the name, we should copy the original for use on the server
						--	and replicate a version with everything with "Server" in the name deleted

						local ModuleDescendants = Child:GetDescendants()
						local TemplateObject

						-- Iterate through the ModuleScript's Descendants, deleting those with "Server" in the Name

						for j = 1, #ModuleDescendants do
							local Descendant = ModuleDescendants[j]

							if Descendant.Name:find("Server", 1, true) then
								if not TemplateObject then -- Before the first deletion, clone Child
									TemplateObject = Child:Clone()
								end

								Descendant:Destroy()
							end
						end

						if TemplateObject then -- If we want to replicate an object with Server descendants, move the server-version to LocalLibraries
							TemplateObject.Parent = Resources:GetLocalFolder("Libraries")
							CacheLibrary(ServerLibraries, TemplateObject, "ServerLibraries")
						end

						Child.Parent = Resources:GetFolder("Libraries") -- Replicate Child which may have had things deleted
						CacheLibrary(ReplicatedLibraries, Child, "ReplicatedLibraries")
					end
				elseif ClassName == "Folder" then
					FoldersToHandle[Child:GetChildren()] = ServerOnly
				elseif ClassName == "PackageLink" then

				else
					error("[Resources] Instances within your Repository must be either a ModuleScript or a Folder, found: " .. ClassName .. " " .. Child:GetFullName(), 0)
				end
			end
			FolderChildren, ExclusivelyServer = next(FoldersToHandle)
		end

		for Name, Library in next, ServerLibraries do
			ReplicatedLibraries[Name] = Library
		end

		LibraryRepository:Destroy()
	end
end

local LoadedLibraries = Resources:GetLocalTable("LoadedLibraries")
local CurrentlyLoading = {} -- This is a hash which LoadLibrary uses as a kind of linked-list history of [Script who Loaded] -> Library

function Resources:LoadLibrary(LibraryName)
	LibraryName = self ~= Resources and self or LibraryName
	local Data = LoadedLibraries[LibraryName]

	if Data == nil then
		local Caller = getfenv(0).script or {Name = "Command bar"} -- If called from command bar, use table as a reference (never concatenated)
		local Library = Resources:GetLibrary(LibraryName)

		CurrentlyLoading[Caller] = Library

		-- Check to see if this case occurs:
		-- Library -> Stuff1 -> Stuff2 -> Library

		-- WHERE CurrentlyLoading[Library] is Stuff1
		-- and CurrentlyLoading[Stuff1] is Stuff2
		-- and CurrentlyLoading[Stuff2] is Library

		local Current = Library
		local Count = 0

		while Current do
			Count = Count + 1
			Current = CurrentlyLoading[Current]

			if Current == Library then
				local String = Current.Name -- Get the string traceback

				for _ = 1, Count do
					Current = CurrentlyLoading[Current]
					String = String .. " -> " .. Current.Name
				end

				error("[Resources] Circular dependency chain detected: " .. String)
			end
		end

		Data = require(Library)

		if CurrentlyLoading[Caller] == Library then -- Thread-safe cleanup!
			CurrentlyLoading[Caller] = nil
		end

		if Data == nil then
			error("[Resources] " .. LibraryName .. " must return a non-nil value. Return false instead.")
		end

		LoadedLibraries[LibraryName] = Data -- Cache by name for subsequent calls
	end

	return Data
end

local LoadedItemConfig = Resources:GetLocalTable("LoadedItemConfigs")
function Resources:LoadItemConfig(ItemName)
	ItemName = self ~= Resources and self or ItemName
	local Data = LoadedItemConfig[ItemName]

	if Data == nil then
		local Caller = getfenv(0).script or {Name = "Command bar"} -- If called from command bar, use table as a reference (never concatenated)
		local Config = Resources:GetItem(ItemName)

		CurrentlyLoading[Caller] = Config

		-- Check to see if this case occurs:
		-- Library -> Stuff1 -> Stuff2 -> Library

		-- WHERE CurrentlyLoading[Library] is Stuff1
		-- and CurrentlyLoading[Stuff1] is Stuff2
		-- and CurrentlyLoading[Stuff2] is Library

		local Current = Config
		local Count = 0

		while Current do
			Count = Count + 1
			Current = CurrentlyLoading[Current]

			if Current == Config then
				local String = Current.Name -- Get the string traceback

				for _ = 1, Count do
					Current = CurrentlyLoading[Current]
					String = String .. " -> " .. Current.Name
				end

				error("[Resources] Circular configuration dependency chain detected: " .. String)
			end
		end

		Data = require(Config.SETTINGS)

		if CurrentlyLoading[Caller] == Config then -- Thread-safe cleanup!
			CurrentlyLoading[Caller] = nil
		end

		if Data == nil then
			error("[Resources] " .. Config .. " must return a non-nil value. Return false instead.")
		end

		LoadedItemConfig[ItemName] = Data -- Cache by name for subsequent calls
	end

	return Data
end

local LoadedConfigs = Resources:GetLocalTable("LoadedConfigurations")
function Resources:LoadConfiguration(ConfigName)
	ConfigName = self ~= Resources and self or ConfigName
	local Data = LoadedConfigs[ConfigName]

	if Data == nil then
		local Caller = getfenv(0).script or {Name = "Command bar"} -- If called from command bar, use table as a reference (never concatenated)
		local Config = Resources:GetConfiguration(ConfigName)

		CurrentlyLoading[Caller] = Config

		-- Check to see if this case occurs:
		-- Library -> Stuff1 -> Stuff2 -> Library

		-- WHERE CurrentlyLoading[Library] is Stuff1
		-- and CurrentlyLoading[Stuff1] is Stuff2
		-- and CurrentlyLoading[Stuff2] is Library

		local Current = Config
		local Count = 0

		while Current do
			Count = Count + 1
			Current = CurrentlyLoading[Current]

			if Current == Config then
				local String = Current.Name -- Get the string traceback

				for _ = 1, Count do
					Current = CurrentlyLoading[Current]
					String = String .. " -> " .. Current.Name
				end

				error("[Resources] Circular configuration dependency chain detected: " .. String)
			end
		end

		Data = require(Config)

		if CurrentlyLoading[Caller] == Config then -- Thread-safe cleanup!
			CurrentlyLoading[Caller] = nil
		end

		if Data == nil then
			error("[Resources] " .. Config .. " must return a non-nil value. Return false instead.")
		end

		LoadedConfigs[ConfigName] = Data -- Cache by name for subsequent calls
	end

	return Data
end
local Spritesheet = {}
do
	local Sprite = {}
	Sprite.ClassName = "Sprite"
	Sprite.__index = Sprite

	function Sprite.new(data)
		assert(data.Texture)
		assert(data.Size)
		assert(data.Position)
		assert(data.Name)

		local self = setmetatable(data, Sprite)

		return self
	end

	function Sprite:Style(gui,useSize)
		if useSize then
			gui.Size = UDim2.new(0, self.Size.X, 0, self.Size.Y)
		end
		gui.Image = self.Texture
		gui.ImageRectOffset = self.Position
		gui.ImageRectSize = self.Size
		gui.BackgroundTransparency = 1
		gui.BorderSizePixel = 0
		return gui
	end

	function Sprite:Get(instanceType,size)
		local gui = Instance.new(instanceType)
		gui.Name = self.Name
		gui.BackgroundTransparency = 1
		gui.BorderSizePixel = 1
		if size then
			gui.Size = size
		end

		self:Style(gui)

		return gui
	end

	Spritesheet.__index = Spritesheet

	function Spritesheet.new(texture)
		local self = setmetatable({}, Spritesheet)

		self._texture = texture or error("no texture")
		self._sprites = {}

		return self
	end

	function Spritesheet:GetPreloadAssetId()
		return self._texture
	end

	function Spritesheet:AddSprite(index, position, size)
		assert(not self._sprites[index])

		local sprite = Sprite.new({
			Texture = self._texture;
			Position = position;
			Size = size;
			Name = tostring(index);
		})

		self._sprites[index] = sprite
	end

	function Spritesheet:GetSprite(index)
		if not index then
			warn("[Spritesheet.GetSprite] - Image name cannot be nil")
			return nil
		end

		local sprite = self._sprites[index]
		if sprite then
			return sprite
		end

		if typeof(index) == "EnumItem" then
			sprite = self._sprites[index.Name]
		end

		return sprite
	end

	function Spritesheet:HasSprite(index)
		return self:GetSprite(index) ~= nil
	end


end
local LoadedInteractions = Resources:GetLocalTable("LoadedInteractions")
local CurrentlyLoadingInteractions = {} -- This is a hash which LoadInteraction uses as a kind of linked-list history of [Script who Loaded] -> Interaction

function Resources:LoadInteraction(IntName)
	IntName = self ~= Resources and self or IntName
	local Data = LoadedInteractions[IntName]

	if Data == nil then
		local Caller = getfenv(0).script or {Name = "Command bar"} -- If called from command bar, use table as a reference (never concatenated)
		local Interaction = Resources:GetInteraction(IntName)

		CurrentlyLoadingInteractions[Caller] = Interaction

		-- Check to see if this case occurs:
		-- Library -> Stuff1 -> Stuff2 -> Library

		-- WHERE CurrentlyLoading[Library] is Stuff1
		-- and CurrentlyLoading[Stuff1] is Stuff2
		-- and CurrentlyLoading[Stuff2] is Library

		local Current = Interaction
		local Count = 0

		while Current do
			Count = Count + 1
			Current = CurrentlyLoadingInteractions[Current]

			if Current == Interaction then
				local String = Current.Name -- Get the string traceback

				for _ = 1, Count do
					Current = CurrentlyLoadingInteractions[Current]
					String = String .. " -> " .. Current.Name
				end

				error("[Resources] Circular dependency chain detected: " .. String)
			end
		end

		Data = require(Interaction)

		if CurrentlyLoadingInteractions[Caller] == Interaction then -- Thread-safe cleanup!
			CurrentlyLoadingInteractions[Caller] = nil
		end

		if Data == nil then
			error("[Resources] " .. IntName .. " must return a non-nil value. Return false instead.")
		end

		LoadedInteractions[IntName] = Data -- Cache by name for subsequent calls
	end

	return Data
end
if script:FindFirstChild("Campaigns") then 
	local LoadedCampaigns = Resources:GetLocalTable("LoadedCampaigns")
	local CurrentlyLoadingCampaigns = {} -- This is a hash which LoadInteraction uses as a kind of linked-list history of [Script who Loaded] -> Interaction

	function Resources:LoadCampaign(CampName)
		CampName = self ~= Resources and self or CampName
		local Data = LoadedCampaigns[CampName]

		if Data == nil then
			local Caller = getfenv(0).script or {Name = "Command bar"} -- If called from command bar, use table as a reference (never concatenated)
			local Campaign = Resources:GetCampaign(CampName)

			CurrentlyLoadingCampaigns[Caller] = Campaign

			-- Check to see if this case occurs:
			-- Library -> Stuff1 -> Stuff2 -> Library

			-- WHERE CurrentlyLoading[Library] is Stuff1
			-- and CurrentlyLoading[Stuff1] is Stuff2
			-- and CurrentlyLoading[Stuff2] is Library

			local Current = Campaign
			local Count = 0

			while Current do
				Count = Count + 1
				Current = CurrentlyLoadingCampaigns[Current]

				if Current == Campaign then
					local String = Current.Name -- Get the string traceback

					for _ = 1, Count do
						Current = CurrentlyLoadingCampaigns[Current]
						String = String .. " -> " .. Current.Name
					end

					error("[Resources] Circular dependency chain detected: " .. String)
				end
			end

			Data = require(Campaign)

			if CurrentlyLoadingCampaigns[Caller] == Campaign then -- Thread-safe cleanup!
				CurrentlyLoadingCampaigns[Caller] = nil
			end

			if Data == nil then
				error("[Resources] " .. CampName .. " must return a non-nil value. Return false instead.")
			end

			LoadedCampaigns[CampName] = Data -- Cache by name for subsequent calls
		end

		return Data
	end
end

local LoadedSpritesheets = Resources:GetLocalTable("LoadedSpritesheets")
function Resources:LoadSpritesheet(SSName)
	SSName = self ~= Resources and self or SSName
	local Data = LoadedSpritesheets[SSName]

	if Data == nil then
		local Caller = getfenv(0).script or {Name = "Command bar"} -- If called from command bar, use table as a reference (never concatenated)
		local Spritesheet2 = Resources:GetSpritesheet(SSName)

		CurrentlyLoading[Caller] = Spritesheet2

		-- Check to see if this case occurs:
		-- Library -> Stuff1 -> Stuff2 -> Library

		-- WHERE CurrentlyLoading[Library] is Stuff1
		-- and CurrentlyLoading[Stuff1] is Stuff2
		-- and CurrentlyLoading[Stuff2] is Library

		local Current = Spritesheet2
		local Count = 0

		while Current do
			Count = Count + 1
			Current = CurrentlyLoading[Current]

			if Current == Spritesheet2 then
				local String = Current.Name -- Get the string traceback

				for _ = 1, Count do
					Current = CurrentlyLoading[Current]
					String = String .. " -> " .. Current.Name
				end

				error("[Resources] Circular spritesheet dependency chain detected: " .. String)
			end
		end

		Data = require(Spritesheet2)(function(texture)
			return Spritesheet.new(texture)
		end)

		if CurrentlyLoading[Caller] == Spritesheet2 then -- Thread-safe cleanup!
			CurrentlyLoading[Caller] = nil
		end

		if Data == nil then
			error("[Resources] " .. Spritesheet2 .. " must return a non-nil value. Return false instead.")
		end

		LoadedConfigs[SSName] = Data -- Cache by name for subsequent calls
	end

	return Data
end

function Resources:AllLoadedSpritesheets()
	return LoadedSpritesheets
end
local oldtypeof = typeof
function Resources:typeof(objIn: any): string
	local objType = oldtypeof(objIn)
	if objType ~= "table" then return objType end

	-- Could be a custom type if it's a table.
	local meta = getmetatable(objIn)
	if oldtypeof(meta) ~= "table" then return objType end

	-- Has a metatable that's an exposed table.
	local customType: string? = meta["__type"] -- I want to mandate that this is a string.
	if customType == nil then return objType end

	-- Has a type field
	return customType
end
function Resources:SetupFlags(flagTable: {})
	local tbl = self:GetLocalTable("RWE4_FLAGS")
	if tbl then
		for k, v in flagTable do
			if self:typeof(v) == "boolean" then
				tbl[k] = v;		
			end
		end
	end
end
function Resources:GetFlags()
	return self:GetLocalTable("RWE4_FLAGS")
end
function Resources:ToggleFlag(flagName: string)
	local tab = Resources:GetLocalTable("RWE4_FLAGS")
	if tab then
		tab[flagName] = not tab[flagName]
	end
end
function Resources:GetFlagValue(flagName: string)
	local tab = Resources:GetLocalTable("RWE4_FLAGS")
	if tab then
		return tab[flagName]
	end
end
function Resources:SetFlag(flagName: string, val: boolean)
	local tab = Resources:GetLocalTable("RWE4_FLAGS")
	if tab and self:typeof(val) == "boolean" then
		tab[flagName] = val
	end
end
local Loaders = {
	Config = Resources.LoadConfiguration;
	Library = Resources.LoadLibrary;
	Spritesheet = Resources.LoadSpritesheet;
	ItemConfig = Resources.LoadItemConfig
}

Metatable.__call = function(self,dep)
	local pattern = "(%w+)(%/)(%w+)"
	local mode, resource = dep:match(pattern)
	if mode and resource then
		if Loaders[mode] then
			return Loaders[mode](self,resource)
		end
	end
end
return Resources
