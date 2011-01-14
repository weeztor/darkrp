--Immunity
cvars.AddChangeCallback("_FAdmin_immunity", function(Cvar, Previous, New)
	FAdmin.SetGlobalSetting("Immunity", (tonumber(New) == 1 and true) or false)
end)

sql.Query("CREATE TABLE IF NOT EXISTS FADMIN_GROUPS('NAME' TEXT NOT NULL PRIMARY KEY, 'ADMIN_ACCESS' INTEGER NOT NULL, 'PRIVS' TEXT);")

local SavedGroups = sql.Query("SELECT * FROM FADMIN_GROUPS")
if SavedGroups then
	for k,v in pairs(SavedGroups) do
		if v.PRIVS == "NULL" then v.PRIVS = nil else v.PRIVS = string.Explode(";", v.PRIVS) end
		//FAdmin.Access.AddGroup(v.NAME, v.ADMIN_ACCESS, v.PRIVS)
		FAdmin.Access.Groups[v.NAME] = {ADMIN = tonumber(v.ADMIN_ACCESS), PRIVS = v.PRIVS or {}}
	end
end

sql.Query("CREATE TABLE IF NOT EXISTS FAdmin_PlayerGroups('steamid' TEXT NOT NULL, 'groupname' TEXT NOT NULL, PRIMARY KEY('steamid'));") 
function FAdmin.Access.PlayerSetGroup(ply, group)
	if not FAdmin.Access.Groups[group] then return end
	ply:SetUserGroup(group)
	local already_there = sql.QueryValue("SELECT groupname FROM FAdmin_PlayerGroups WHERE steamid = "..sql.SQLStr(ply:SteamID())..";")

	if already_there == group then return
	elseif already_there then
		sql.Query( "UPDATE FAdmin_PlayerGroups SET groupname = "..sql.SQLStr(group).." WHERE steamid = "..sql.SQLStr(ply:SteamID())..";")
	else
		sql.Query( "INSERT INTO FAdmin_PlayerGroups VALUES("..sql.SQLStr(ply:SteamID())..", "..sql.SQLStr(group)..");")
	end
end

function FAdmin.Access.SetRoot(ply, cmd, args) -- FAdmin setroot player
	if not FAdmin.Access.PlayerHasPrivilege(ply, "SetAccess") then FAdmin.Messages.SendMessage(ply, 5, "No access!") return end
	
	local targets = FAdmin.FindPlayer(args[1])
	if not targets or #targets == 1 and not ValidEntity(targets[1]) then
		FAdmin.Messages.SendMessage(ply, 1, "Player not found")
		return
	end
	
	for _, target in pairs(targets) do
		if ValidEntity(target) then
			FAdmin.Access.PlayerSetGroup(target, "root_user")
			if ULib and ULib.ucl and ULib.ucl.groups and ULib.ucl.groups["root_user"] then --Add to ULX' root user
				ULib.ucl.addUser(target:SteamID(), nil, nil, "root_user")
			end
			FAdmin.Messages.SendMessage(ply, 2, "User set to root!")
		end
	end
end

local nosend = {"user", "admin", "superadmin", "root_user", "noaccess"}
local function SendCustomGroups(ply)
	for k,v in pairs(FAdmin.Access.Groups) do
		if not table.HasValue(nosend, k) then
			SendUserMessage("FADMIN_SendGroups", ply, k, v.ADMIN)
			local privs = {}
			local SendAmount = 1
			privs[SendAmount] = ""
			for k,v in pairs(v.PRIVS) do
				if string.len(privs[SendAmount]) > 200 then
					SendAmount = SendAmount + 1
					privs[SendAmount] = ""
				end
				privs[SendAmount] = privs[SendAmount].. ((privs[SendAmount] ~= "" and ";") or "")..v
			end
			for i = 1, SendAmount do
				SendUserMessage("FAdmin_SendPrivs", ply, k, privs[SendAmount])
			end
		end
	end
end

function FAdmin.Access.SetAccess(ply, cmd, args) -- FAdmin SetAccess <player> groupname [new_groupadmin, new_groupprivs]
	if not FAdmin.Access.PlayerHasPrivilege(ply, "SetAccess") then FAdmin.Messages.SendMessage(ply, 5, "No access!") return end
	
	local targets = FAdmin.FindPlayer(args[1])
	if #targets == 1 and not ValidEntity(targets[1]) then
		FAdmin.Messages.SendMessage(ply, 1, "Player not found")
		return
	end
	
	if not args[2] or (not FAdmin.Access.Groups[args[2]] and not tonumber(args[3])) then
		FAdmin.Messages.SendMessage(ply, 1, "Group not found")
		return
	elseif args[2] and not FAdmin.Access.Groups[args[2]] and tonumber(args[3]) then
		local Privs = table.Copy(args)
		Privs[1], Privs[2], Privs[3] = nil, nil, nil, nil
		Privs = table.ClearKeys(Privs)
		
		FAdmin.Access.AddGroup(args[2], tonumber(args[3]), Privs)-- Add new group
		FAdmin.Messages.SendMessage(ply, 2, "Group created")
		SendCustomGroups()
	end
	
	for _, target in pairs(targets) do
		if ValidEntity(target) then
			FAdmin.Access.PlayerSetGroup(target, args[2])
			FAdmin.Messages.SendMessage(ply, 2, "User access set!")
		end
	end
end

--hooks and stuff

hook.Add("PlayerInitialSpawn", "FAdmin_SetAccess", function(ply)
	local Group = sql.QueryValue("SELECT groupname FROM FAdmin_PlayerGroups WHERE steamid = "..sql.SQLStr(ply:SteamID())..";")
	if Group then
		ply:SetUserGroup(Group)
		
		if FAdmin.Access.Groups[Group] then
			ply:FAdmin_SetGlobal("FAdmin_admin", FAdmin.Access.Groups[Group].ADMIN_ACCESS)
			
			for k,v in pairs(FAdmin.Access.Groups[Group].PRIVS) do
				SendUserMessage("FADMIN_RetrievePrivs", ply, tostring(v))
			end
		end
	end
	SendCustomGroups(ply)
end)

local function SetImmunity(ply, cmd, args)
	if not FAdmin.Access.PlayerHasPrivilege(ply, "SetAccess") then FAdmin.Messages.SendMessage(ply, 5, "No access!") return end -- SetAccess privilege because they can handle immunity settings
	if not args[1] then FAdmin.Messages.SendMessage(ply, 5, "Invalid argument!") return end
	RunConsoleCommand("_FAdmin_immunity", args[1])
	FAdmin.Messages.SendMessage(ply, 4, "turned " .. ((tonumber(args[1]) == 1 and "on") or "off") .. " admin immunity!")
end

FAdmin.StartHooks["Access"] = function() --Run all functions that depend on other plugins
	FAdmin.Commands.AddCommand("setroot", FAdmin.Access.SetRoot)
	FAdmin.Commands.AddCommand("setaccess", FAdmin.Access.SetAccess)
	
	FAdmin.Commands.AddCommand("immunity", SetImmunity)
	
	FAdmin.SetGlobalSetting("Immunity", (GetConVarNumber("_FAdmin_immunity") == 1 and true) or false)
end

concommand.Add("_FAdmin_SendUserGroups", function(ply)
	for k,v in SortedPairsByMemberValue(FAdmin.Access.Groups, "ADMIN", true) do
		SendUserMessage("FADMIN_RetrieveGroup", ply, k)
	end
end)

hook.Add("InitPostEntity", "HookIntoULX", function()
	if ULib and ULib.ucl then -- Make the root user have superadmin access in ULX.
		if not ULib.ucl.groups["root_user"] then
			ULib.ucl.addGroup("root_user", nil, "superadmin")
		else
			ULib.ucl.setGroupInheritance("root_user", "superadmin")
		end
	end
end)