local Resources = require(game.ReplicatedStorage.Resources)
local TextService = game:GetService("TextService")
local RunService = game:GetService("RunService")
local Janitor = Resources:LoadLibrary("Janitor")
local TICK = tick
if not _G.RJanitor then
	_G.RJanitor = Janitor.new()
end
if not _G.ReadyPlayers then
	_G.ReadyPlayers = {};
end
local network = {
	Send = Resources:GetRemoteEvent("Send");
	Fetch =  Resources:GetRemoteFunction("Fetch");
	Bounce =  Resources:GetRemoteEvent("Bounce");
	BounceU =  Resources:GetUnreliableRemoteEvent("Bounce");
	Listeners = Resources:GetRemoteFunction("GetListeners");
	SendU = Resources:GetUnreliableRemoteEvent("Send");
	SendListeners = Resources:GetRemoteEvent("SendListeners");
	ModelSpecifics = {
		Client = Resources:GetBindableFunction("GetClientListeners",10);
		Server = Resources:GetBindableFunction("GetServerListeners",10);
		ClientU = Resources:GetBindableFunction("GetClientUDPListeners",10);
		ServerU = Resources:GetBindableFunction("GetServerUDPListeners",10);
	};
	Queue = {};
	TickDiscs		= {};
	Pings			= {};
	PingRate		= 1;
	LastPing		= TICK();
	Players = {};
	ReservedWords = {
		"PING";
		"ClientReady";
	};

}
network.isReady = function(player)
	return _G.ReadyPlayers[player]
end

network.isReservedListener = function(lName)
	for _, v in ipairs(network.ReservedWords) do
		if v == lName then
			return true
		end
	end
	return false
end
function AddEvents(Listeners,ModelType)
	for name , v in pairs(Listeners.Send[ModelType]) do
		network.RemoteListeners["Send"][ModelType][name] = v
	end
	for name , v in pairs(Listeners.Fetch[ModelType]) do
		network.RemoteListeners["Fetch"][ModelType][name] = v
	end
	for name , v in pairs(Listeners.Bounce[ModelType]) do
		network.RemoteListeners["Bounce"][ModelType][name] = v
	end
end
function AddUEvents(Listeners,ModelType)
	for name , v in pairs(Listeners.Send[ModelType]) do
		network.RemoteUListeners["Send"][ModelType][name] = v
	end
	for name , v in pairs(Listeners.Bounce[ModelType]) do
		network.RemoteUListeners["Bounce"][ModelType][name] = v
	end
end

if network.RemoteListeners == nil then
	network.RemoteListeners =	{
		Send = {
			Client = {

			};
			Server = {
				["ClientReady"] = function(player)
					_G.ReadyPlayers[player] = true;
				end;	
			}
		};
		Fetch = {
			Client = {

			};
			Server = {

			};

		};
		Bounce = {
			Client = {

			};
			Server = {

			};

		};
	}

end
if network.RemoteUListeners == nil then
	network.RemoteUListeners =	{
		Send = {
			Client = {

			};
			Server = {
					
			}
		};
		Bounce = {
			Client = {

			};
			Server = {

			};

		};
	}

end
local function getTextObject(message, fromPlayerId)
	local textObject
	local success, errorMessage = pcall(function()
		textObject = TextService:FilterStringAsync(message, fromPlayerId)
	end)
	if success then
		return textObject
	elseif errorMessage then
		print("Error generating TextFilterResult:", errorMessage)
	end
	return false
end

local function getFilteredMessage(textObject)
	local filteredMessage
	local success, errorMessage = pcall(function()
		filteredMessage = textObject:GetNonChatStringForBroadcastAsync()
	end)
	if success then
		return filteredMessage
	elseif errorMessage then
		print("Error filtering message:", errorMessage)
	end
	return false
end

network.send = function(modelType,...)
	if modelType == "Server" then
		local args = {...}
		network.Send:FireServer(unpack(args))
	elseif modelType == "Client" then
		local args = {...}
		local player = args[1]
		table.remove(args,1)
		network.Send:FireClient(player,unpack(args))	
	end
end

network.sendU = function(modelType,...)
	if modelType == "Server" then
		local args = {...}
		network.SendU:FireServer(unpack(args))
	elseif modelType == "Client" then
		local args = {...}
		local player = args[1]
		table.remove(args,1)
		network.SendU:FireClient(player,unpack(args))	
	end
end

network.WaitForReady = function()
	repeat RunService.Heartbeat:Wait() until #_G.RemoteListeners > 0
end

network.listen = function(modelType,actionType,...)
	local args = {...}
	if args then
		if network.RemoteListeners[actionType][modelType] then
			if network.isReservedListener(args[1]:upper()) then error(string.upper(args[1]) .. " is a reserved listener. Next time, don't use this.") return end
			if typeof(args[2]) ~= "function" then error("RemoteService.listen must use a function in order to deal with the request") return end
			print("Setting Listener: ".. args[1] .. "...")
			network.RemoteListeners[actionType][modelType][args[1]] = args[2]
		end
	end
end

network.listenU = function(modelType,actionType,...)
	local args = {...}
	if args then
		if network.RemoteUListeners[actionType][modelType] then
			if network.isReservedListener(args[1]:upper()) then error(string.upper(args[1]) .. " is a reserved (unreliable) listener. Next time, don't use this.") return end
			if typeof(args[2]) ~= "function" then error("RemoteService.listenU must use a function in order to deal with the request") return end
			print("Setting Unreliable Listener: ".. args[1] .. "...")
			network.RemoteUListeners[actionType][modelType][args[1]] = args[2]
		end
	end
end


network.startClient = function()
	_G.RJanitor:Remove("ClientSend")
	_G.RJanitor:Remove("ClientBounce")	
	_G.RJanitor:Remove("ClientSendU")
	_G.RJanitor:Remove("ClientBounceU")	 
	_G.RJanitor:Add(network.Send.OnClientEvent:Connect(function(...)
		local args = {...}
		if args then
			if network.RemoteListeners["Send"]["Client"][args[1]] then
				local method = args[1]
				table.remove(args,1)

				network.RemoteListeners["Send"]["Client"][method](unpack(args))
			end
		end
	end),"Disconnect","ClientSend")
	network.Fetch.OnClientInvoke = function(...)
		local args = {...}
		if args then
			if network.RemoteListeners["Fetch"]["Client"][args[1]] then
				local method = args[1]

				table.remove(args,1)
				return network.RemoteListeners["Fetch"]["Client"][method](unpack(args))
			end
		end
	end
	_G.RJanitor:Add(network.Bounce.OnClientEvent:Connect(function(...)
		local args = {...}
		if args then
			if network.RemoteListeners["Bounce"]["Client"][args[1]] then
				local method = args[1]
				table.remove(args,1)

				network.RemoteListeners["Bounce"]["Client"][method](unpack(args))
			end
		end
	end),"Disconnect","ClientBounce")
	_G.RJanitor:Add(network.SendU.OnClientEvent:Connect(function(...)
		local args = {...}
		if args then
			if network.RemoteUListeners["Send"]["Client"][args[1]] then
				local method = args[1]
				table.remove(args,1)

				network.RemoteUListeners["Send"]["Client"][method](unpack(args))
			end
		end
	end),"Disconnect","ClientSendU")
	_G.RJanitor:Add(network.BounceU.OnClientEvent:Connect(function(...)
		local args = {...}
		if args then
			if network.RemoteUListeners["Bounce"]["Client"][args[1]] then
				local method = args[1]
				table.remove(args,1)

				network.RemoteUListeners["Bounce"]["Client"][method](unpack(args))
			end
		end
	end),"Disconnect","ClientBounceU")
end

network.startServer = function()
	_G.RJanitor:Remove("ServerSend")
	_G.RJanitor:Remove("ServerBounce")
	_G.RJanitor:Remove("ServerUSend")
	_G.RJanitor:Remove("ServerUBounce")
	_G.RJanitor:Add(network.Send.OnServerEvent:Connect(function(player,...)
		local args = {...}
		if args then
			if network.RemoteListeners["Send"]["Server"][args[1]] then
				local method = args[1]
				table.remove(args,1)
				network.RemoteListeners["Send"]["Server"][method](player,unpack(args))
			end
		end
	end),"Disconnect","ServerSend")
	network.Fetch.OnServerInvoke = function(player,...)
		local args = {...}
		if args then
			if network.RemoteListeners["Fetch"]["Server"][args[1]] then
				local method = args[1]
				table.remove(args,1)

				return network.RemoteListeners["Fetch"]["Server"][method](player,unpack(args))
			end
		end
	end
	_G.RJanitor:Add(network.Bounce.OnServerEvent:Connect(function(player,...)
		local args = {...}
		if args then
			if network.RemoteListeners["Bounce"]["Server"][args[1]] then
				local method = args[1]
				table.remove(args,1)
				print("Bounce-ServerSide")

				network.RemoteListeners["Bounce"]["Server"][method](player,unpack(args))
			end
		end
	end),"Disconnect","ServerBounce")
	_G.RJanitor:Add(network.BounceU.OnServerEvent:Connect(function(player,...)
		local args = {...}
		if args then
			if network.RemoteUListeners["Bounce"]["Server"][args[1]] then
				local method = args[1]
				table.remove(args,1)
				print("Bounce-ServerSide-U")

				network.RemoteUListeners["Bounce"]["Server"][method](player,unpack(args))
			end
		end
	end),"Disconnect","ServerBounceU")
	_G.RJanitor:Add(network.SendU.OnServerEvent:Connect(function(player,...)
		local args = {...}
		if args then
			if network.RemoteUListeners["Send"]["Server"][args[1]] then
				local method = args[1]
				table.remove(args,1)
				network.RemoteUListeners["Send"]["Server"][method](player,unpack(args))
			end
		end
	end),"Disconnect","ServerSendU")
end

network.fetch = function(modelType,...)
	if modelType == "Server" then
		local args = {...}
		local success, data = pcall(function() return {network.Fetch:InvokeServer(unpack(args))} end)
		if success then
			return unpack(data)
		else
			return nil
		end
	elseif modelType == "Client" then
		local args = {...}
		local args = {...}
		local player = args[1]
		table.remove(args,1)
		local success, data = pcall(function() return {network.Fetch:InvokeClient(player,unpack(args))} end)
		if success then
			return unpack(data)
		else
			return nil
		end

	end
end
network.bounceU = function(modelType,...)
	if modelType == "Server" then
		local args = {...}
		network.BounceU:FireServer(unpack(args))

	elseif modelType == "Client" then
		local args = {...}
		network.BounceU:FireAllClients(unpack(args))	
	end
end
network.bounce = function(modelType,...)
	if modelType == "Server" then
		local args = {...}
		network.Bounce:FireServer(unpack(args))

	elseif modelType == "Client" then
		local args = {...}
		network.Bounce:FireAllClients(unpack(args))	
	end
end
network.bounceTeam = function(modelType,team,...)
	if modelType == "Server" then
		local args = {...}
		network.Bounce:FireServer(unpack(args))
	elseif modelType == "Client" then
		do
			local args = {...}
			for _, p in ipairs(team:GetPlayers()) do
				network.Bounce:FireClient(p,unpack(args))
			end	
		end
	end
end
network.bounceTeamU = function(modelType,team,...)
	if modelType == "Server" then
		local args = {...}
		network.BounceU:FireServer(unpack(args))
	elseif modelType == "Client" then
		do
			local args = {...}
			for _, p in ipairs(team:GetPlayers()) do
				network.BounceU:FireClient(p,unpack(args))
			end	
		end
	end
end
network.bounceOthers = function(modelType,player,...)
	if modelType == "Server" then
		local args = {...}
		network.Bounce:FireServer(unpack(args))
	elseif modelType == "Client" then
		do
			local args = {...}
			for _, p in ipairs(game.Players:GetPlayers()) do
				if p ~= player then
					network.Bounce:FireClient(p,unpack(args))
				end
			end	
		end
	end
end
network.bounceOthersU = function(modelType,player,...)
	if modelType == "Server" then
		local args = {...}
		network.BounceU:FireServer(unpack(args))
	elseif modelType == "Client" then
		do
			local args = {...}
			for _, p in ipairs(game.Players:GetPlayers()) do
				if p ~= player then
					network.BounceU:FireClient(p,unpack(args))
				end
			end	
		end
	end
end
network.bounceOthersTeam = function(modelType,player,team,...)
	if modelType == "Server" then
		local args = {...}
		network.Bounce:FireServer(unpack(args))
	elseif modelType == "Client" then
		do
			local args = {...}
			for _, p in ipairs(game.Players:GetPlayers()) do
				if p ~= player and p.Team == team then
					network.Bounce:FireClient(p,unpack(args))
				end
			end	
		end
	end
end
network.bounceOthersTeamU = function(modelType,player,team,...)
	if modelType == "Server" then
		local args = {...}
		network.BounceU:FireServer(unpack(args))
	elseif modelType == "Client" then
		do
			local args = {...}
			for _, p in ipairs(game.Players:GetPlayers()) do
				if p ~= player and p.Team == team then
					network.BounceU:FireClient(p,unpack(args))
				end
			end	
		end
	end
end
network.filter = function(player,msgType,msg)
	if msg ~= "" then
		if msgType == "Broadcast" then
			-- Filter the incoming message and send the filtered message
			local messageObject = getTextObject(msg, player.UserId)
			local filteredText = ""
			filteredText = getFilteredMessage(messageObject)
			return filteredText
		elseif msgType == "Private" then

		end
	end
end

function network.waitFor(modelType,actionType,funcName)
	local results 
	local event
	if typeof(network[actionType]) == "Instance" then
		if network[actionType]:IsA("RemoteEvent") or network[actionType]:IsA("UnreliableRemoteEvent") then
			event = network[actionType]
			
		else
			return nil
		end
	else
		return nil
	end
	if event:IsA("RemoteEvent") or event:IsA("UnreliableRemoteEvent") then
		repeat 
			local args = {event[modelType == "Server" and "OnServerEvent" or "OnClientEvent"]:Wait()}
			if args[2] == funcName then
				results = {unpack(args,3,#args-1)}
			end
		until
		results ~= nil
	end
	return results
end
function network.WaitForFetch(modelType,funcName,...)
	repeat  RunService.Heartbeat:Wait() until network.fetch(modelType,funcName,...) ~= nil
	return network.fetch(modelType,funcName,...)
end
if RunService:IsClient() then
	network.startClient()
else
	network.startServer()
end
return network
