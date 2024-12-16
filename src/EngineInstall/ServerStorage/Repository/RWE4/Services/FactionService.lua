local FactionService = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Resources = require(ReplicatedStorage:WaitForChild("Resources"))
local CollectionService = game:GetService("CollectionService")
local Teams = game:GetService("Teams")
local Players = game:GetService("Players")
local WPF = Resources:LoadLibrary("WeightedProbabilityFunction")
local RemoteService = Resources:LoadLibrary("RemoteService")
local Table = Resources:LoadLibrary("Table")
local Janitor = Resources:LoadLibrary("Janitor")
local FastSpawn = Resources:LoadLibrary("FastSpawn")
local TeamManifest = Resources:LoadConfiguration("TeamManifest")

local RunService = game:GetService("RunService")

FactionService.Janitor = Janitor.new()
FactionService.FriendQueue = {};
function FactionService:GetUsualTeams()
	local teams = {}
	for _, team in pairs(Teams:GetTeams()) do
		if team.Name ~= "NonParticipant" then
			teams[#teams+1] = team
		end
	end		
	return teams
end
function FactionService:GetTeamSize()
	local pCount = #Players:GetPlayers()
	if pCount > 5 then
		local teamRes = {}
		local teams = self:GetUsualTeams()
		for _, team in ipairs(teams) do
			teamRes[team] = 0;
		end
		
		local res = math.ceil(pCount/#teams)
		for team, _ in pairs(teamRes) do
			teamRes[team.Name] = res
		end
		local res2 = pCount % #teams
		if res2 > 0 then
			teamRes[teams[#teams].Name] = res2
		end
		return teamRes
	else
		local teamRes = {}
		local teams = {}
		for _, team in ipairs(Teams:GetTeams()) do
			if team.Name ~= "NonParticipant" then
				teamRes[team.Name] = 10;
				teams[#teams+1] = team
			end
		end		
		return teamRes
	end
end

function FactionService:RegisterFaction(factionQueue,team)
	local teamData = team
	teamData:SetAttribute("PlayerCount",factionQueue[team])
end

function FactionService:SelectFaction(player,team)
	local data = team
	if data then
		local teamQueue = data:GetAttribute("PlayerCount") 
		if teamQueue then
			if teamQueue > 0 then
				player.Team = team
				data:SetAttribute("PlayerCount",data:GetAttribute("PlayerCount") - 1)
			end
		else
			player.Team = team
			data:SetAttribute("PlayerCount",data:GetAttribute("PlayerCount") - 1)
		end
		
	end
end

function FactionService:GetPlayerCount(team)
	local data = team
	if data then
		return data:GetAttribute("PlayerCount")
	end
	return nil
end

-- When players join the game, determine the correct team to join
function FactionService:AutoAssignPlayerInit(player, group)
	-- Check if the player belongs in a group and the group isn't larger than a fair team size
	if group and #group < game.Players.MaxPlayers / 2 then
		player.Team = group[1].Team
	else
		if #game.Players:GetPlayers() >= game.Players.MaxPlayers/2 then
			local teams = Resources:GetLocalTable("UsableTeams")
			table.sort(teams, function(a, b) return #a:GetPlayers() < #b:GetPlayers() end)
			player.Team = teams[1]
		else
			repeat RunService.Heartbeat:Wait() until RemoteService.isReady(player)
			if player:GetAttribute("Spectate") then
				print("Spectator found")
				RemoteService.send("Client",player,"EnableSpectate")
				return
			end
			local res = FactionService:PromptForTeamInd(player,Resources:GetLocalTable("UsableTeams"))
		
		end
	end
end

function FactionService:MergeFriends(groups)
	-- Add other group members to the first group
	for i = 2, #groups do
		for _, user in pairs(FactionService.FriendQueue[groups[i]]) do
			table.insert(FactionService.FriendQueue[groups[1]], user)
		end
		-- Remove leftover groups that were merged
		table.remove(FactionService.FriendQueue, groups[i])
	end
 
	return groups[1]
end

function FactionService:IndexFriends(player)
	local mutualGroups = {}
 
	-- Iterate through friend groups
	for groupIndex, group in pairs(FactionService.FriendQueue) do
		-- Iterate through friends found in groups
		for _, user in ipairs(group) do
			-- Group mutual friends together
			if player:IsFriendsWith(user.UserId) then
				if (mutualGroups[group] == nil) then
					table.insert(mutualGroups, groupIndex)
				end
			end
		end
	end
 
	if #mutualGroups > 0 then
		local groupIndex = mutualGroups[1]
 
		-- If the player has multiple groups of friends playing, merge into one group
		if #mutualGroups > 1 then
			groupIndex = FactionService:MergeFriends(mutualGroups)
		end
 
		table.insert(FactionService.FriendQueue[groupIndex], player)
		FactionService:AutoAssignPlayerInit(player, FactionService.FriendQueue[groupIndex])
	else
		table.insert(FactionService.FriendQueue, {player})
		FactionService:AutoAssignPlayerInit(player)
	end
end

function FactionService:RemoveFromFQueue(player)
	-- Loop through the friend groups to find the player
	for groupIndex, group in pairs(self.FriendQueue) do
		for userIndex, user in ipairs(group) do
			if user.Name == player.Name then
				-- Remove them from whatever group they exist in
				self.FriendQueue[groupIndex][userIndex] = nil
				-- If the group is empty, remove it
				if #self.FriendQueue[groupIndex] == 0 then
					self.FriendQueue[groupIndex] = nil
				end
			end
		end
	end
end

function isUniqueRep(color)
	for _, t in ipairs(game.Teams:GetTeams()) do
		if game.Players:FindFirstChild(t.Name) then
			if t.TeamColor == color then
				return false
			end
		end
	end
	return true
end

function FactionService:InitializeAllegiances(ffa,team)
	
	if not ffa then
		if #CollectionService:GetTags(team) >= 3 then
			return 
		end
		local data = team:FindFirstChild("FactionConfig")
		if data then
			data = require(data)
			local alleigiances = data.Allegiances
			if alleigiances then
				for _, allegiance in ipairs(alleigiances) do
					CollectionService:AddTag(team,allegiance)
				end
				table.insert(Resources:GetLocalTable("UsableTeams"),team)
			end
		end
	else
		for _, player in ipairs (Players:GetPlayers()) do
			if not game.Teams:FindFirstChild(player.Name) then
				local team = Instance.new("Team")
				team.Name = player.Name
				team.AutoAssignable = false
				
				repeat
					team.TeamColor = BrickColor.Random()
					RunService.Heartbeat:Wait()
				until
					isUniqueRep(team.TeamColor)
				team.Parent = game.Teams
				game.CollectionService:AddTag(team,"FFA")
				
				player.Team = team
				FactionService.Janitor:Add(team,"Destroy",player)
				FactionService.Janitor:Add(game.Players.PlayerRemoving:Connect(function(plr)
					if plr == player then
						FactionService.Janitor:Remove(player)
					end
				end),"Disconnect")
				player.Team = team
			end
			
		end
		FactionService.Janitor:Add(game.Players.PlayerAdded:Connect(function(player)
				if not game.Teams:FindFirstChild(player.Name) then
					local team = Instance.new("Team")
					team.Name = player.Name
					team.AutoAssignable = false
					
					repeat
						team.TeamColor = BrickColor.Random()
						RunService.Heartbeat:Wait()
					until
						isUniqueRep(team.TeamColor)
					team.Parent = game.Teams
					game.CollectionService:AddTag(team,"FFA")
					
					player.Team = team
					FactionService.Janitor:Add(team,"Destroy",player)
					FactionService.Janitor:Add(game.Players.PlayerRemoving:Connect(function(plr)
						if plr == player then
							FactionService.Janitor:Remove(player)
						end
					end),"Disconnect")
					player.Team = team
				end
			end))
	end	
end

function FactionService:CreateAIFFATeam(ai)
			local team = Instance.new("Team")
			team.Name = ai.Name..math.floor(math.random(1,1000))
			team.AutoAssignable = false
			repeat
				team.TeamColor = BrickColor.Random()
				RunService.Heartbeat:Wait()
			until
				isUniqueRep(team.TeamColor)
			team.Parent = game.Teams
			game.CollectionService:AddTag(team,"FFA")			
			ai.BOT.Team.Value = team
			FactionService.Janitor:Add(team)
end

function FactionService:ClearFFATeams()
	FactionService.Janitor:Cleanup()
end
FactionService.FactionMemberCache = Resources:GetLocalTable("FactionMemberConfig")
FactionService.CurrentAllegiances = Resources:GetLocalTable("CurrentAllegiances")

function FactionService:AddToCache(member)
	local team 
	if member:IsA("Player") then
		team = member.Team
	elseif member:IsA("Model") then
		local BOT = member:FindFirstChild("BOT")
		if BOT then
			BOT = require(BOT)
		else
			return
		end
		if BOT then
			team = BOT.Team
		end
	end
	if team then
		if CollectionService:HasTag(FactionService.CurrentAllegiances.Attacking) then
			FactionService.FactionMemberCache[CollectionService:GetTags(member)[1]] = FactionService.CurrentAllegiances.Attacking
		elseif CollectionService:HasTag(FactionService.CurrentAllegiances.Defending) then
			FactionService.FactionMemberCache[CollectionService:GetTags(member)[1]] = FactionService.CurrentAllegiances.Defending
		end
	end
end

FactionService.AvailableAttackingAllegiances = {
	"OpFor";
}

FactionService.AvailableDefendingAllegiances = {
	"BluFor";
}

local AttackingTable = {}
local DefendingTable = {}
FactionService.AttackingAllegiance = nil;
FactionService.DefendingAllegiance = nil;
for i, v in pairs(FactionService.AvailableAttackingAllegiances) do
	AttackingTable[v] = 1;
end
for i, v in pairs(FactionService.AvailableDefendingAllegiances) do
	DefendingTable[v] = 1;
end
FactionService.AttackingAllegiance = WPF.new(AttackingTable)
FactionService.DefendingAllegiance = WPF.new(DefendingTable)
FactionService.PrimaryAllegiance = WPF.new({
	[FactionService.AttackingAllegiance] = 0.5;
	[FactionService.DefendingAllegiance] = 0.5;
})

local opposingAllegiances = TeamManifest.OppositeAlliances

local directNemeses = TeamManifest.Nemeses
function FactionService:GetAdversaries()
	return directNemeses
end
function FactionService:GetFighters()
	local faction = FactionService.PrimaryAllegiance()
	if faction then
		return faction,opposingAllegiances[faction],faction .. " VS " .. opposingAllegiances[faction]
	end
	return nil
end
function FactionService:GetAllegianceColors(teams)
	local faction1, faction2
	for _, team in pairs(teams) do
		if CollectionService:HasTag(team,"Good") then
			faction1 = team
			break
		end
	end
	for _, team in pairs(teams) do
		if CollectionService:HasTag(team,"Evil") then
			faction2 = team
			break
		end
	end	
	return {
		["Good"] = faction1.TeamColor;
		["Evil"] = faction2.TeamColor;
	}
end
function FactionService:IsCompatibleTeam(team1,team2)
	return CollectionService:HasTag(team2,CollectionService:GetTags(team1)[1])
end
function FactionService:IsEnemy(plr,human)
	local p2 = game.Players:GetPlayerFromCharacter(human.Parent)
	if (not p2) then
		if human.Parent:FindFirstChild("BOT") then
			local team = require(human.Parent.BOT).Team
			if not directNemeses[team] then
				return plr.Team ~= team 			
			else
				return not CollectionService:HasTag(plr.Team,CollectionService:GetTags(team)[1])
			end
		end
	end
	if not p2 then
		return false
	end
	if p2.Team then
		local team = p2.Team
			if game.CollectionService:HasTag(team,"FFA") then
				if plr.Team ~= team then
					return true
				else
								
				end
			else
				if not CollectionService:HasTag(plr.Team,CollectionService:GetTags(team)[1]) then
									return true
				end	
			end
		return false
	end
	return false
end
function FactionService:startServer()
	RemoteService.listen("Server","Send","PickTeam", function(player, team)
		if player.Team == game.Teams.NonParticipant then
			if team.Name ~= "NonParticipant" then
				if table.find(Resources:GetLocalTable("UsableTeams"),team) then
					player.Team = team
				end
			end
		end
	end)
end

function FactionService:PromptForTeam(teams)
	
	RemoteService.bounce("Client","ShowProgress","WAITING FOR TEAMS...")
	for _, plr in ipairs(Players:GetPlayers()) do
		local limits = FactionService:GetTeamSize()
		repeat RunService.Heartbeat:Wait() until RemoteService.isReady(plr)
		RemoteService.send("Client",plr,"ChooseTeam",teams,limits)
		repeat RunService.Heartbeat:Wait() until RemoteService.isReady(plr)
	end
	for _, plr in ipairs(Players:GetPlayers()) do
		repeat RunService.Heartbeat:Wait() until table.find(Resources:GetLocalTable("UsableTeams"),plr.Team)
	end
end

function FactionService:PromptForTeamInd(player,teams)
	if player:GetAttribute("Spectate") then
		return false
	end
	local limits = FactionService:GetTeamSize()
	local teamPlayers = {}
	repeat RunService.Heartbeat:Wait() until RemoteService.isReady(player)
	RemoteService.send("Client",player,"ChooseTeam",teams,limits)
	repeat RunService.Heartbeat:Wait() until table.find(Resources:GetLocalTable("UsableTeams"),player.Team)
	if workspace.CurrentMap.Value then
		RemoteService.send("Client",player,"MapReadyInd",workspace.CurrentMap.Value)
	end
	return true
end

function FactionService:AllocatePlayer(player)
	if not game.Teams:FindFirstChild(player.Name) then
	local team = Instance.new("Team")
			team.Name = player.Name
			team.AutoAssignable = false
			
			repeat
				team.TeamColor = BrickColor.Random()
				RunService.Heartbeat:Wait()
			until
				isUniqueRep(team.TeamColor)
			team.Parent = game.Teams
			game.CollectionService:AddTag(team,"FFA")
			
			player.Team = team
			FactionService.Janitor:Add(team)
	end
end
return FactionService