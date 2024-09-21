local RunService = game:GetService("RunService")
local Resources = require(game.ReplicatedStorage.Resources)
local Signal = Resources:LoadLibrary("Signal")
local Events = Resources:GetLocalTable("Events")
local EventUtils = {}

function EventUtils:AddEvent(eventName: string)
	Events[eventName] = Signal.new()
end

function EventUtils:ConnectEvent(eventName, func)
	return Events[eventName]:Connect(func)
end

function EventUtils:WaitEvent(eventName)
	return Events[eventName]:Wait()
end

function EventUtils:FireEvent(eventName, ...)
	 Events[eventName]:Fire(...)
end

function EventUtils:GetEvent(eventName)
	return Events[eventName]
end

return EventUtils