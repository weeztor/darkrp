-- Kicking
local function Kick(ply, cmd, args)
	if not FAdmin.Access.PlayerHasPrivilege(ply, "Kick") then FAdmin.Messages.SendMessage(ply, 5, "No access!")  return end
	--start cancel update execute
	local targets = FAdmin.FindPlayer(args[1])
	if not targets or #targets == 1 and not ValidEntity(targets[1]) then
		FAdmin.Messages.SendMessage(ply, 1, "Player not found")
		return
	end
	local stage = args[2] or ""
	stage = string.lower(stage)
	local stages = {"start", "cancel", "update", "execute"}
	local Reason = args[3] or (not table.HasValue(stages, stage) and stage) or ply.FAdminKickReason
	
	for _, target in pairs(targets) do
		if ValidEntity(target) then
			if stage == "start" then
				SendUserMessage("FAdmin_kick_start", target) -- Tell him he's getting kicked
				target:Lock() -- Make sure he can't remove the hook clientside and keep minging.
				target:KillSilent()
			elseif stage == "cancel" then
				SendUserMessage("FAdmin_kick_cancel", target) -- No I changed my mind, you can stay
				target:UnLock()
				target:Spawn()
				ply.FAdminKickReason = nil
			elseif stage == "update" then -- Update reason text
				if not args[3] then return end
				ply.FAdminKickReason = args[3]
				SendUserMessage("FAdmin_kick_update", target, args[3])
			else//if stage == "execute" or stage == "" then--execute or no stage = kick instantly
				RunConsoleCommand("kickid", target:UserID(), Reason)
				ply.FAdminKickReason = nil
			end
		end
	end
end

local StartBannedUsers = {} -- Prevent rejoining before actual ban occurs
hook.Add("PlayerAuthed", "FAdmin_LeavingBeforeBan", function(ply, SteamID, ...)
	if table.HasValue(StartBannedUsers, SteamID) then
		RunConsoleCommand("kickid", ply:UserID(), "Getting banned")
	end
	return false
end)

-- Banning
local BANS = {}

if file.Exists("FAdmin/Bans.txt") then
	BANS = util.KeyValuesToTable(file.Read("FAdmin/Bans.txt"))
	for k,v in pairs(BANS) do
		if v < os.time() and v ~= 0 then
			BANS[k] = nil
		end
		if v == 0 then
			game.ConsoleCommand("banid 0 "..k.. "\n")
		else
			game.ConsoleCommand("banid ".. (v - os.time())/60 .." " .. k.. "\n")
		end
	end
	file.Write("FAdmin/Bans.txt", util.TableToKeyValues(BANS))
end

timer.Create("FAdminCheckBans", 60, 0, function()
	local changed = false
	for k,v in pairs(BANS) do
		if v < os.time() and v ~= 0 then
			BANS[k] = nil
			changed = true
		end
	end
	
	if changed then
		file.Write("FAdmin/Bans.txt", util.TableToKeyValues(BANS))
	end
end)

local function SaveBan(SteamID, Duration)
	if tonumber(Duration) == 0 then
		BANS[SteamID] = 0
	else
		BANS[SteamID] = os.time() + Duration*60--in minutes, so *60
	end
	
	file.Write("FAdmin/Bans.txt", util.TableToKeyValues(BANS))
end

local function Ban(ply, cmd, args)
	if not args[2] then return end
	if not FAdmin.Access.PlayerHasPrivilege(ply, "Ban") then FAdmin.Messages.SendMessage(ply, 5, "No access!")  return end
	--start cancel update execute
	
	local targets = FAdmin.FindPlayer(args[1])
	if not targets and string.find(args[1], "STEAM_") ~= 1 then
		FAdmin.Messages.SendMessage(ply, 1, "Player not found")
		return
	elseif not targets and string.find(args[1], "STEAM_") == 1 then
		targets = {args[1]}
	end
	
	local stage = string.lower(args[2])
	local Reason = args[4] or ply.FAdminKickReason or ""
	for _, target in pairs(targets) do
		if stage == "start" and type(target) ~= "string" and ValidEntity(target) then
			SendUserMessage("FAdmin_ban_start", target) -- Tell him he's getting banned
			target:Lock() -- Make sure he can't remove the hook clientside and keep minging.
			target:KillSilent()
			table.insert(StartBannedUsers, target:SteamID())
			
		elseif stage == "cancel" then
			if type(target) ~= "string" and ValidEntity(target) then
				SendUserMessage("FAdmin_ban_cancel", target) -- No I changed my mind, you can stay
				target:UnLock()
				target:Spawn()
			else -- If he left and you want to cancel
				for k,v in pairs(StartBannedUsers) do
					if v == args[1] then
						table.remove(StartBannedUsers, k)
					end
				end
			end
		elseif stage == "update" then -- Update reason text
			if not args[4] or type(target) == "string" or not ValidEntity(target) then return end
			ply.FAdminKickReason = args[4]
			umsg.Start("FAdmin_ban_update", target)
				umsg.Long(tonumber(args[3]))
				umsg.String(tostring(args[4]))
			umsg.End()
		else
			local time, Reason = tonumber(args[2]) or 0, Reason or args[3] or ""
			if stage == "execute" then
				time = tonumber(args[3]) or 60 --Default to one hour, not permanent.
				Reason = args[4] or ""
			end
			
			local TimeText = FAdmin.PlayerActions.ConvertBanTime(time)
			if type(target) ~= "string" and  ValidEntity(target) then
				for k,v in pairs(StartBannedUsers) do
					if v == target:SteamID() then
						table.remove(StartBannedUsers, k)
						break
					end
				end
				
				SaveBan(target:SteamID(), time)
				game.ConsoleCommand("banid " .. time.." ".. target:SteamID().."\n") -- Don't use banid in combination with RunConsoleCommand
				RunConsoleCommand("kickid", target:UserID(), " banned for "..TimeText.." "..Reason) -- Also kicks someone if only a steam ID is entered
			else
				for k,v in pairs(StartBannedUsers) do
					if v == args[1] then
						table.remove(StartBannedUsers, k)
						break
					end
				end
				SaveBan(args[1], args[3] or 60) -- Again default to one hour
				RunConsoleCommand("banid", time, args[1])
			end
			ply.FAdminKickReason = nil
		end
	end
end
-- Unbanning
local function UnBan(ply, cmd, args)
	if not FAdmin.Access.PlayerHasPrivilege(ply, "UnBan") then return end
	if not args[1] then return end
	local SteamID = string.upper(args[1])
	
	for k,v in pairs(BANS) do
		if string.upper(k) == SteamID then
			BANS[k] = nil
			break
		end
	end
	
	for k,v in pairs(StartBannedUsers) do
		if string.upper(v) == SteamID then
			StartBannedUsers[k] = nil
			break
		end
	end

	file.Write("FAdmin/Bans.txt", util.TableToKeyValues(BANS))
	game.ConsoleCommand("removeid ".. SteamID .. "\n")
end

-- Commands and privileges
hook.Add("FAdmin_PluginsLoaded", "KickBan", function()
	FAdmin.Commands.AddCommand("kick", Kick)
	FAdmin.Commands.AddCommand("ban", Ban)
	FAdmin.Commands.AddCommand("unban", UnBan)
	
	FAdmin.Access.AddPrivilege("Kick", 2)
	FAdmin.Access.AddPrivilege("Ban", 2)
	FAdmin.Access.AddPrivilege("UnBan", 2)
end)