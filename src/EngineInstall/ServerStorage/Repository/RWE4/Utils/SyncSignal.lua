--!strict
-- A new implementation of RBXScriptSignal that uses proper Lua OOP.
-- This was explicitly made to transport other OOP objects.
-- I would be using BindableEvents, but they don't like cyclic tables (part of OOP objects with __index)

local SignalStatic = {}
SignalStatic.__index = SignalStatic
local ConnectionStatic = {}
ConnectionStatic.__index = ConnectionStatic

export type Signal = {
	Connections: {[number]: Connection}
}

export type Connection = {
	Signal: Signal?,
	Delegate: any,
	Index: number	
}

-- Format params: methodName, ctorName
local ERR_NOT_INSTANCE = "Cannot statically invoke method '%s' - It is an instance method. Call it on an instance of this class created via %s"

function SignalStatic.new(): Signal
	return setmetatable({
		Connections = {}
	}, SignalStatic)
end

local function NewConnection(sig: Signal, func: any): Connection 
	return setmetatable({
		Signal = sig,
		Delegate = func,
		Index = -1
	}, ConnectionStatic)
end

function SignalStatic:Connect(func)
	assert(getmetatable(self) == SignalStatic, ERR_NOT_INSTANCE:format("Connect", "Signal.new()"))
	local connection = NewConnection(self, func)
	connection.Index = #self.Connections + 1
	table.insert(self.Connections, connection.Index, connection)
	return connection
end

function SignalStatic:Fire(...)
	assert(getmetatable(self) == SignalStatic, ERR_NOT_INSTANCE:format("Fire", "Signal.new()"))
	local args = table.pack(...)
	local allCons = self.Connections
	for index = 1, #allCons do
		local connection = allCons[index]
		if connection.Delegate ~= nil then
			-- Catch case for disposed signals.
			coroutine.wrap(function ()
				connection.Delegate(table.unpack(args))
			end)()
		end
	end
end

function SignalStatic:FireSync(...)
	assert(getmetatable(self) == SignalStatic, ERR_NOT_INSTANCE:format("Fire", "Signal.new()"))
	local args = table.pack(...)
	local allCons = self.Connections
	for index = 1, #allCons do
		local connection = allCons[index]
		if connection.Delegate ~= nil then
			-- Catch case for disposed signals.
			connection.Delegate(table.unpack(args))
		end
	end
end

function SignalStatic:Dispose()
	assert(getmetatable(self) == SignalStatic, ERR_NOT_INSTANCE:format("Dispose", "Signal.new()"))
	local allCons = self.Connections
	for index = 1, #allCons do
		allCons[index]:Disconnect()
	end
	self.Connections = {}
	setmetatable(self, nil)
end

function ConnectionStatic:Disconnect()
	assert(getmetatable(self) == ConnectionStatic, ERR_NOT_INSTANCE:format("Disconnect", "private function NewConnection()"))
	table.remove(self.Signal.Connections, self.Index)
	self.SignalStatic = nil
	self.Delegate = nil
	self.Index = -1
	setmetatable(self, nil)
end

return SignalStatic