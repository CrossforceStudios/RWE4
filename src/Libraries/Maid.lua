local Maid = {}

function Maid.new()
	local self = { Tasks = {} }
	setmetatable(self, Maid)
	
	return self
end

--

function Maid:__index(key)
	if Maid[key] ~= nil then
		return Maid[key]
	end
	
	return self.Tasks[key]
end

function Maid:__newindex(key, task)
	if Maid[key] ~= nil then
		error(string.format("'%s' is reserved", tostring(key)), 2)
	end
	
	local oldTask = self.Tasks[key]
	if oldTask == task then
		return
	end
	
	self.Tasks[key] = task
	
	if oldTask then
		CleanupTask(oldTask)
	end
end


function Maid:AddTask(...)
	for _,task in pairs({...}) do
		self.Tasks[#self.Tasks + 1] = task
	end
end

function Maid:Cleanup()
	local key, task = next(self.Tasks)
	
	while task ~= nil do
		self.Tasks[key] = nil
		CleanupTask(task)
		
		key, task = next(self.Tasks)
	end
end

--

local CleanupBindable = Instance.new("BindableEvent")
local WaitingCleanupThread = nil
local CurrentCleanupTask = nil

function MaidCleanup() -- Named this way for stack traces
	local thread = coroutine.running()
	
	while WaitingCleanupThread == nil do
		WaitingCleanupThread = thread
		CleanupBindable.Event:Wait()
		WaitingCleanupThread = nil
		
		local task = CurrentCleanupTask
		CurrentCleanupTask = nil
		
		if typeof(task) == "function" then
			task()
		elseif typeof(task) == "table" and task.Destroy then
			task:Destroy()
		end
	end
end

function CleanupTask(task)
	if typeof(task) == "RBXScriptConnection" then
		task:Disconnect()
		
	elseif typeof(task) == "Instance" then
		pcall(function() task:Destroy() end) -- Handle parent locked and robloxlocked instances
	
	elseif typeof(task) == "function" or typeof(task) == "table" then
		if not WaitingCleanupThread then
			coroutine.resume(coroutine.create(MaidCleanup))
		end
		
		CurrentCleanupTask = task
		CleanupBindable:Fire()
	end
end

--

return Maid