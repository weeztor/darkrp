local Whitelist = {"sv_password"} -- Make sure people don't use FAdmin serversetting as easy RCON, only the SBOX commands are allowed
local Settings = KeyValuesToTable(file.Read("../settings/server_settings/gmod.txt")) -- All SBox limits are in here :D

for k, v in SortedPairs(Settings.settings or {}) do
	table.insert(Whitelist, string.lower(k))
end

sql.Query([[CREATE TABLE IF NOT EXISTS FAdmin_ServerSettings(setting STRING NOT NULL PRIMARY KEY, value STRING NOT NULL);]])
for k,v in pairs(Whitelist) do
	cvars.AddChangeCallback(v, function(CVar, oldval, newval)
		local Value = sql.QueryValue([[SELECT value FROM FAdmin_ServerSettings WHERE setting = ]]..sql.SQLStr(v)..";")
		if Value == tostring(newval) then return end
		if not Value then
			sql.Query([[INSERT INTO FAdmin_ServerSettings VALUES(]]..sql.SQLStr(v:lower())..[[, ]]..sql.SQLStr(newval)..");")
		else
			sql.Query([[UPDATE FAdmin_ServerSettings SET value = ]]..sql.SQLStr(newval)..[[ WHERE setting = ]]..sql.SQLStr(v:lower())..[[;]])
		end
	end)
end

hook.Add("InitPostEntity", "FAdmin_Settings", function()
	local Settings = sql.Query("SELECT * FROM FAdmin_ServerSettings;") or {}
	for k,v in pairs(Settings) do
		RunConsoleCommand(v.setting, v.value)
	end
end)

local function ServerSetting(ply, cmd, args)
	if not FAdmin.Access.PlayerHasPrivilege(ply, "ServerSetting") then FAdmin.Messages.SendMessage(ply, 5, "No access!") return end
	if not args[2] or not table.HasValue(Whitelist, string.lower(args[1])) then FAdmin.Messages.SendMessage(ply, 5, "Incorrect argument") return end
	
	local CommandArgs = table.Copy(args)
	CommandArgs[1] = nil
	CommandArgs = table.ClearKeys(CommandArgs)
	RunConsoleCommand(args[1], unpack(CommandArgs))
	FAdmin.Messages.ActionMessage(ply, player.GetAll(), "You have set ".. args[1].. " to ".. unpack(CommandArgs),
	args[1].. " was set to " .. unpack(CommandArgs), "Set ".. args[1].. " to ".. unpack(CommandArgs))
end

FAdmin.StartHooks["ServerSettings"] = function()
	FAdmin.Commands.AddCommand("ServerSetting", ServerSetting)
	
	FAdmin.Access.AddPrivilege("ServerSetting", 2)
end