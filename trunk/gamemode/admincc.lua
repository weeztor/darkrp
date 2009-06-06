-- Player Priviliges
ADMIN = 0			-- DarkRP Admin
MAYOR = 1			-- Can become Mayor without a vote (Uses /mayor)
CP = 2					-- Can become CP without a vote (Uses /cp)
TOOL = 3				-- Always spawns with the toolgun
PHYS = 4				-- Always spawns with the physgun
PROP = 5			-- Can always spawn props (unless jailed)

function ccValueCommand(ply, cmd, args)
	local valuecmd = ValueCmds[cmd]

	if not valuecmd then return end

	if #args < 1 or not tonumber(args[1]) then
		if valuecmd.global then
			if ply:EntIndex() == 0 then
				print(cmd .. " = " .. tostring(GetGlobalInt(valuecmd.var)))
			else
				ply:PrintMessage(2, cmd .. " = " .. tostring(GetGlobalInt(valuecmd.var)))
			end
		else
			if ply:EntIndex() == 0 then
				print(cmd .. " = " .. tostring(CfgVars[valuecmd.var]))
			else
				ply:PrintMessage(2, cmd .. " = " .. tostring(CfgVars[valuecmd.var]))
			end
		end
		return
	end

	if ply:EntIndex() ~= 0 and not ply:HasPriv(ADMIN) then
		ply:PrintMessage(2, "You need admin privileges in order to be able to set this command.")
		return
	end

	local amount = math.floor(tonumber(args[1]))
	if amount == GetGlobalInt(valuecmd.var) then return end
	if valuecmd.global then
		DB.SaveGlobal(valuecmd.var, amount)
	else
		DB.SaveSetting(valuecmd.var, amount)
	end

	local nick = ""

	if ply:EntIndex() == 0 then
		nick = "Console"
	else
		nick = ply:Nick()
	end

	NotifyAll(0, 4, nick .. " set " .. cmd .. " to " .. amount)
	if ply.SteamName then
		DB.Log(ply:SteamName().." ("..ply:SteamID()..") set "..cmd.." to "..amount )
	else
		DB.Log("Console set "..cmd.." to "..amount )
	end
end

function ccToggleCommand(ply, cmd, args)
	local togglecmd = ToggleCmds[cmd]

	if not togglecmd then return end

	if #args < 1 or not tonumber(args[1]) then
		if togglecmd.global then
			if ply:EntIndex() == 0 then
				print(cmd .. " = " .. GetGlobalInt(togglecmd.var))
			else
				ply:PrintMessage(2, cmd .. " = " .. GetGlobalInt(togglecmd.var))
			end
		else
			if ply:EntIndex() == 0 then
				print(cmd .. " = " .. tostring(CfgVars[togglecmd.var]))
			else
				ply:PrintMessage(2, cmd .. " = " .. tostring(CfgVars[togglecmd.var]))
			end
		end
		return
	end

	if (ply:EntIndex() ~= 0 and not DB.HasPriv(ply, ADMIN)) or (togglecmd.superadmin and not ply:IsSuperAdmin()) then
		ply:PrintMessage(2, "(Super)/Admin only!")
		return
	end

	local toggle = tonumber(args[1])
	if toggle == GetGlobalInt(togglecmd.var) then return end

	if not toggle or (toggle ~= 1 and toggle ~= 0) then
		if ply:EntIndex() == 0 then
			print("Invalid number; must be 1 or 0.")
		else
			ply:PrintMessage(2, "Invalid number; must be 1 or 0.")
		end
		return
	end

	if togglecmd.global then
		DB.SaveGlobal(togglecmd.var, toggle)
	else
		DB.SaveSetting(togglecmd.var, toggle)
	end

	local nick = ""

	if ply:EntIndex() == 0 then
		nick = "Console"
	else
		nick = ply:Nick()
	end

	NotifyAll(0, 3, nick .. " set " .. cmd .. " to " .. toggle)
	if ply.SteamName then
		DB.Log(ply:SteamName().." ("..ply:SteamID()..") set "..cmd.." to "..toggle )
	else
		DB.Log("Console set "..cmd.." to "..toggle )
	end
end

function ccDoorOwn(ply, cmd, args)
	if ply:EntIndex() == 0 then
		return
	end

	if not ply:HasPriv(ADMIN) then
		ply:PrintMessage(2, "You need admin privileges in order to be able to own a door.")
		return
	end

	local trace = ply:GetEyeTrace()

	if not ValidEntity(trace.Entity) or not trace.Entity:IsOwnable() or ply:EyePos():Distance(trace.Entity:GetPos()) > 200 then
		return
	end

	trace.Entity:Fire("unlock", "", 0)
	trace.Entity:UnOwn()
	trace.Entity:Own(ply)
	DB.Log(ply:SteamName().." ("..ply:SteamID()..") force-owned a door with rp_own" )
end
concommand.Add("rp_own", ccDoorOwn)

function ccDoorUnOwn(ply, cmd, args)
	if ply:EntIndex() == 0 then
		return
	end

	if not ply:HasPriv(ADMIN) then
		ply:PrintMessage(2, "You're not an admin!")
		return
	end

	local trace = ply:GetEyeTrace()

	if not ValidEntity(trace.Entity) or not trace.Entity:IsOwnable() or ply:EyePos():Distance(trace.Entity:GetPos()) > 200 then
		return
	end

	trace.Entity:Fire("unlock", "", 0)
	trace.Entity:UnOwn()
	DB.Log(ply:SteamName().." ("..ply:SteamID()..") force-unowned a door with rp_unown" )
end
concommand.Add("rp_unown", ccDoorUnOwn)

function ccAddOwner(ply, cmd, args)
	if ply:EntIndex() == 0 then
		return
	end

	if not ply:HasPriv(ADMIN) then
		ply:PrintMessage(2, "You're not an admin!")
		return
	end

	local trace = ply:GetEyeTrace()

	if not ValidEntity(trace.Entity) or not trace.Entity:IsOwnable() or ply:EyePos():Distance(trace.Entity:GetPos()) > 200 then
		return
	end

	target = FindPlayer(args[1])

	if target then
		if trace.Entity:IsOwned() then
			if not trace.Entity:OwnedBy(target) and not trace.Entity:AllowedToOwn(target) then
				trace.Entity:AddAllowed(target)
			else
				ply:PrintMessage(2, "Player already owns (or is already allowed to own) this door!")
			end
		else
			trace.Entity:Own(target)
		end
	else
		ply:PrintMessage(2, "Could not find player: " .. args)
	end
	DB.Log(ply:SteamName().." ("..ply:SteamID()..") force-added a door owner with rp_addowner" )
end
concommand.Add("rp_addowner", ccAddOwner)

function ccRemoveOwner(ply, cmd, args)
	if ply:EntIndex() == 0 then
		return
	end

	if not ply:HasPriv(ADMIN) then
		ply:PrintMessage(2, "You're not an admin!")
		return
	end

	local trace = ply:GetEyeTrace()

	if not ValidEntity(trace.Entity) or not trace.Entity:IsOwnable() or ply:EyePos():Distance(trace.Entity:GetPos()) > 200 then
		return
	end

	target = FindPlayer(args[1])

	if target then
		if trace.Entity:AllowedToOwn(target) then
			trace.Entity:RemoveAllowed(target)
		end

		if trace.Entity:OwnedBy(target) then
			trace.Entity:RemoveOwner(target)
		end
	else
		ply:PrintMessage(2, "Could not find player: " .. args)
	end
	DB.Log(ply:SteamName().." ("..ply:SteamID()..") force-removed a door owner with rp_removeowner" )
end
concommand.Add("rp_removeowner", ccRemoveOwner)

function ccLock(ply, cmd, args)
	if ply:EntIndex() == 0 then
		return
	end

	if not ply:HasPriv(ADMIN) then
		ply:PrintMessage(2, "You're not an admin!")
		return
	end

	local trace = ply:GetEyeTrace()

	if not ValidEntity(trace.Entity) or not trace.Entity:IsOwnable() or ply:EyePos():Distance(trace.Entity:GetPos()) > 200 then
		return
	end

	ply:PrintMessage(2, "Locked.")

	trace.Entity:Fire("lock", "", 0)
	DB.Log(ply:SteamName().." ("..ply:SteamID()..") force-locked a door with rp_lock" )
end
concommand.Add("rp_lock", ccLock)

function ccUnLock(ply, cmd, args)
	if ply:EntIndex() == 0 then
		return
	end

	if not ply:HasPriv(ADMIN) then
		ply:PrintMessage(2, "You're not an admin!")
		return
	end

	local trace = ply:GetEyeTrace()

	if not ValidEntity(trace.Entity) or not trace.Entity:IsOwnable() or ply:EyePos():Distance(trace.Entity:GetPos()) > 200 then
		return
	end

	ply:PrintMessage(2, "Unlocked.")
	trace.Entity:Fire("unlock", "", 0)
	DB.Log(ply:SteamName().." ("..ply:SteamID()..") force-unlocked a door with rp_unlock" )
end
concommand.Add("rp_unlock", ccUnLock)

function ccTell(ply, cmd, args)
	if ply:EntIndex() ~= 0 and not ply:HasPriv(ADMIN) then
		ply:PrintMessage(2, "You're not an admin!")
		return
	end

	local target = FindPlayer(args[1])

	if target then
		local msg = ""

		for n = 2, #args do
			msg = msg .. args[n] .. " "
		end

		umsg.Start("AdminTell", target)
			umsg.String(msg)
		umsg.End()
		
		if ply:EntIndex() == 0 then
			DB.Log("Console did rp_tell \""..msg .. "\" on "..target:SteamName() )
		else
			DB.Log(ply:SteamName().." ("..ply:SteamID()..") did rp_tell \""..msg .. "\" on "..target:SteamName() )
		end
	else
		if ply:EntIndex() == 0 then
			print("Could not find player: " .. args[1])
		else
			ply:PrintMessage(2, "Could not find player: " .. args[1])
		end
	end
	
end
concommand.Add("rp_tell", ccTell)

function ccTellAll(ply, cmd, args)
	if ply:EntIndex() ~= 0 and not ply:HasPriv(ADMIN) then
		ply:PrintMessage(2, "You're not an admin!")
		return
	end

	for k,v in pairs(player.GetAll()) do
		local msg = ""

		for n = 1, #args do
			msg = msg .. args[n] .. " "
		end

		umsg.Start("AdminTell", v)
			umsg.String(msg)
		umsg.End()
		
		if ply:EntIndex() == 0 then
			DB.Log("Console did rp_tellall \""..msg .. "\"" )
		else
			DB.Log(ply:SteamName().." ("..ply:SteamID()..") did rp_tellall \""..msg .. "\"" )
		end
	end
end
concommand.Add("rp_tellall", ccTellAll)

function ccRemoveLetters(ply, cmd, args)
	if ply:EntIndex() ~= 0 and not ply:HasPriv(ADMIN) then
		ply:PrintMessage(2, "You're not an admin!")
		return
	end

	local target = FindPlayer(args[1])

	if target then
		for k, v in pairs(ents.FindByClass("letter")) do
			if v.SID == target.SID then v:Remove() end
		end
	else
		-- Remove ALL letters
		for k, v in pairs(ents.FindByClass("letter")) do
			v:Remove()
		end
	end
	
	if ply:EntIndex() == 0 then
		DB.Log("Console force-removed all letters" )
	else
		DB.Log(ply:SteamName().." ("..ply:SteamID()..") force-removed all letters" )
	end
end
concommand.Add("rp_removeletters", ccRemoveLetters)

function ccPayDayTime(ply, cmd, args)
	if ply:EntIndex() ~= 0 and not ply:IsAdmin() and not ply:IsSuperAdmin() then
		ply:PrintMessage(2, "You're not a server admin")
		return
	end

	local amount = math.floor(tonumber(args[1]))

	if not amount then return end

	DB.SaveSetting("paydelay", amount)

	for k, v in pairs(player.GetAll()) do
		v:UpdateJob(v:GetNWString("job"))
	end

	if ply:EntIndex() == 0 then
		nick = "Console"
	else
		nick = ply:Nick()
	end

	NotifyAll(0, 3, nick .. " set rp_paydaytime to " .. amount)
	
	if ply:EntIndex() == 0 then
		DB.Log("Console changed the paydaytime to "..amount )
	else
		DB.Log(ply:SteamName().." ("..ply:SteamID()..") changed the paydaytime to "..amount )
	end
end
concommand.Add("rp_paydaytime", ccPayDayTime)

function ccArrest(ply, cmd, args)
	if ply:EntIndex() ~= 0 and not ply:HasPriv(ADMIN) then
		ply:PrintMessage(2, "You need admin privileges in order to be able to arrest someone through rp_arrest.")
		return
	end

	if DB.CountJailPos() == 0 then
		if ply:EntIndex() == 0 then
			print("No jail positions yet!\n")
		else
			ply:PrintMessage(2, "No jail positions yet!")
		end
		return
	end

	local target = FindPlayer(args[1])
	if target then
		local length = tonumber(args[2])
		if length then
			target:Arrest(length)
		else
			target:Arrest()
		end
		
		if ply:EntIndex() == 0 then
			DB.Log("Console force-arrested "..target:SteamName())
		else
			DB.Log(ply:SteamName().." ("..ply:SteamID()..") force-arrested "..target:SteamName() )
		end
	else
		if ply:EntIndex() == 0 then
			print("Could not find player: " .. args[1])
		else
			ply:PrintMessage(2, "Could not find player: " .. args[1])
		end
	end
	
end
concommand.Add("rp_arrest", ccArrest)

function ccUnarrest(ply, cmd, args)
	if ply:EntIndex() ~= 0 and not ply:HasPriv(ADMIN) then
		ply:PrintMessage(2, "You're not an admin!")
		return
	end

	local target = FindPlayer(args[1])

	if target then
		target:Unarrest()
		
		if ply:EntIndex() == 0 then
			DB.Log("Console force-unarrested "..target:SteamName())
		else
			DB.Log(ply:SteamName().." ("..ply:SteamID()..") force-unarrested "..target:SteamName() )
		end
	else
		if ply:EntIndex() == 0 then
			print("Could not find player: " .. args[1])
		else
			ply:PrintMessage(2, "Could not find player: " .. args[1])
		end
		return
	end
	
end
concommand.Add("rp_unarrest", ccUnarrest)

function ccKickBan(ply, cmd, args)
	if ply:EntIndex() ~= 0 and not ply:HasPriv(ADMIN) then
		ply:PrintMessage(2, "You're not an admin!")
		return
	end

	local target = FindPlayer(args[1])

	if target then
		if not args[2] then
			args[2] = 0
		end

		if (target:HasPriv(ADMIN) or target:IsAdmin() or target:IsSuperAdmin()) and (not ply:IsAdmin() or not ply:IsSuperAdmin()) then
			ply:PrintMessage(2, "Normal RP admins can not kick or ban another admin!")
			return
		end

		game.ConsoleCommand("banid " .. args[2] .. " " .. target:UserID() .. "\n")
		game.ConsoleCommand("kickid " .. target:UserID() .. " \"Kicked and Banned by "..ply:Nick().."\"\n")
		if ply:EntIndex() == 0 then
			DB.Log("Console kicked and banned "..target:SteamName() )
		else
			DB.Log(ply:SteamName().." ("..ply:SteamID()..") kicked and banned "..target:SteamName() )
		end
	else
		if ply:EntIndex() == 0 then
			print("Could not find player: " .. args[1])
		else
			ply:PrintMessage(2, "Could not find player: " .. args[1])
		end
		return
	end
end
concommand.Add("rp_kickban", ccKickBan)

function ccKick(ply, cmd, args)
	if ply:EntIndex() ~= 0 and not ply:HasPriv(ADMIN) then
		ply:PrintMessage(2, "You're not an admin!")
		return
	end

	local target = FindPlayer(args[1])

	if target then
		if (target:HasPriv(ADMIN) or target:IsAdmin() or target:IsSuperAdmin()) and (not ply:IsAdmin() or not ply:IsSuperAdmin()) then
			ply:PrintMessage(2, "Normal RP admins can not kick or ban another admin!")
			return
		end

		local reason = ""

		if args[2] then
			for n = 2, #args do
				reason = reason .. args[n]
				reason = reason .. " "
			end
		end

		game.ConsoleCommand("kickid " .. target:UserID() .. " \"" .. reason..": " ..ply:Nick().. "\"\n")
		if ply:EntIndex() == 0 then
			DB.Log("Console kicked "..target:SteamName() )
		else
			DB.Log(ply:SteamName().." ("..ply:SteamID()..") kicked "..target:SteamName() )
		end
	else
		if ply:EntIndex() == 0 then
			print("Could not find player: " .. args[1])
		else
			ply:PrintMessage(2, "Could not find player: " .. args[1])
		end
		return
	end
end
concommand.Add("rp_kick", ccKick)

function ccSetMoney(ply, cmd, args)
	if ply:EntIndex() ~= 0 and not ply:IsSuperAdmin() then
		ply:PrintMessage(2, "You're not a super admin!")
		return
	end

	local amount = math.floor(tonumber(args[2]))

	if not amount then
		if ply:EntIndex() == 0 then
			print("Invalid amount of money: " .. args[2])
		else
			ply:PrintMessage(2, "Invalid amount of money: " .. args[2])
		end
		return
	end

	local target = FindPlayer(args[1])

	if target then
		local nick = ""
		target:SetNWInt("money", amount)
		DB.StoreMoney(target, amount)

		if ply:EntIndex() == 0 then
			print("Set " .. target:Nick() .. "'s money to: " .. CUR .. amount)
			nick = "Console"
		else
			ply:PrintMessage(2, "Set " .. target:Nick() .. "'s money to: " .. CUR .. amount)
			nick = ply:Nick()
		end
		target:PrintMessage(2, nick .. " set your money to: " .. CUR .. amount)
		if ply:EntIndex() == 0 then
			DB.Log("Console set "..target:SteamName().."'s money to "..CUR..amount )
		else
			DB.Log(ply:SteamName().." ("..ply:SteamID()..") set "..target:SteamName().."'s money to "..CUR..amount)
		end
	else
		if ply:EntIndex() == 0 then
			print("Could not find player: " .. args[1])
		else
			ply:PrintMessage(2, "Could not find player: " .. args[1])
		end
		return
	end
end
concommand.Add("rp_setmoney", ccSetMoney)

function ccSetSalary(ply, cmd, args)
	if ply:EntIndex() ~= 0 and not ply:IsSuperAdmin() then
		ply:PrintMessage(2, "You're not a super admin!")
		return
	end

	local amount = math.floor(tonumber(args[2]))

	if not amount or amount < 0 then
		if ply:EntIndex() == 0 then
			print("Invalid Salary: " .. args[2])
		else
			ply:PrintMessage(2, "Invalid Salary: " .. args[2])
		end
		return
	end

	if amount > 150 then
		if ply:EntIndex() == 0 then
			print("Salary must be below " .. CUR .. "150")
		else
			ply:PrintMessage(2, "Salary must be less than or equal to " .. CUR .. "150")
		end
		return
	end

	local target = FindPlayer(args[1])

	if target then
		local nick = ""
		DB.StoreSalary(target, amount)
		target:SetNWInt("salary", amount)
		if ply:EntIndex() == 0 then
			print("Set " .. target:Nick() .. "'s Salary to: " .. CUR .. amount)
			nick = "Console"
		else
			ply:PrintMessage(2, "Set " .. target:Nick() .. "'s Salary to: " .. CUR .. amount)
			nick = ply:Nick()
		end
		target:PrintMessage(2, nick .. " set your Salary to: " .. CUR .. amount)
		if ply:EntIndex() == 0 then
			DB.Log("Console set "..target:SteamName().."'s salary to "..CUR..amount )
		else
			DB.Log(ply:SteamName().." ("..ply:SteamID()..") set "..target:SteamName().."'s salary to "..CUR..amount)
		end
	else
		if ply:EntIndex() == 0 then
			print("Could not find player: " .. args[1])
		else
			ply:PrintMessage(2, "Could not find player: " .. args[1])
		end
		return
	end
end
concommand.Add("rp_setsalary", ccSetSalary)

function ccGrantPriv(ply, cmd, args)
	if ply:EntIndex() ~= 0 and not ply:IsSuperAdmin() then
		ply:PrintMessage(2, "You're not a super admin!")
		return
	end
	local PLAYER = ""
	if ply:EntIndex() == 0 then
		PLAYER = "console"
	else
		PLAYER = ply:Nick()
	end
	
	if not args[1] then
		ply:PrintMessage(2, "rp_grant <player> <privilege> Grant a player a privilege\nThese privileges are available:\ntool\nadmin\nphys\nprop\nmayor\ncp")
		return
	end

	local target = FindPlayer(args[1])
	if not target then
		if ply:EntIndex() == 0 then
			print("Could not find player: " .. args[2])
		else
			ply:PrintMessage(2, "Could not find player: " .. args[2])
		end
		return
	end

	if not args[2] then
		ply:PrintMessage(2, target:Nick() .. " has these privileges:")
		for i=0, 5, 1 do
			ply:PrintMessage(2, tostring(DB.Priv2Text(i)).. "        "..tostring(target:HasPriv(i)))
		end
		return
	end
	
	if args[2] == "tool" then
		DB.GrantPriv(target, TOOL)
		NotifyAll( 1, 3, PLAYER .. " has granted "..target:Nick().." toolgun priveleges.")
		if ply:EntIndex() == 0 then
			DB.Log("Console has granted "..target:Nick().." toolgun priveleges." )
		else
			DB.Log(ply:SteamName().." ("..ply:SteamID()..") has granted "..target:Nick().." toolgun priveleges." )
		end
	elseif args[2] == "admin" then
		DB.GrantPriv(target, ADMIN)
		NotifyAll( 1, 3, PLAYER .. " has granted "..target:Nick().." admin priveleges.")
		if ply:EntIndex() == 0 then
			DB.Log("Console has granted "..target:Nick().." admin priveleges." )
		else
			DB.Log(ply:SteamName().." ("..ply:SteamID()..") has granted "..target:Nick().." admin priveleges." )
		end
	elseif args[2] == "phys" then
		DB.GrantPriv(target, PHYS)
		NotifyAll( 1, 3, PLAYER .. " has granted "..target:Nick().." physgun priveleges.")
		if ply:EntIndex() == 0 then
			DB.Log("Console has granted "..target:Nick().." physgun priveleges." )
		else
			DB.Log(ply:SteamName().." ("..ply:SteamID()..") has granted "..target:Nick().." physgun priveleges." )
		end
	elseif args[2] == "prop" then
		DB.GrantPriv(target, PROP)
		NotifyAll( 1, 3, PLAYER .. " has granted "..target:Nick().." prop spawn priveleges.")
		if ply:EntIndex() == 0 then
			DB.Log("Console has granted "..target:Nick().." prop spawn priveleges." )
		else
			DB.Log(ply:SteamName().." ("..ply:SteamID()..") has granted "..target:Nick().." prop spawn priveleges." )
		end
	elseif args[2] == "mayor" then
		DB.GrantPriv(target, MAYOR)
		NotifyAll( 1, 3, PLAYER .. " has granted "..target:Nick().." /mayor priveleges.")
		if ply:EntIndex() == 0 then
			DB.Log("Console has granted "..target:Nick().." mayor priveleges." )
		else
			DB.Log(ply:SteamName().." ("..ply:SteamID()..") has granted "..target:Nick().." mayor priveleges." )
		end
	elseif args[2] == "cp" then
		DB.GrantPriv(target, CP)
		NotifyAll( 1, 3, PLAYER .. " has granted "..target:Nick().." /cp priveleges.")
		if ply:EntIndex() == 0 then
			DB.Log("Console has granted "..target:Nick().." CP priveleges." )
		else
			DB.Log(ply:SteamName().." ("..ply:SteamID()..") has granted "..target:Nick().." CP priveleges." )
		end
	else
		if ply:EntIndex() == 0 then
			print("There is not a " .. args[2] .. " privilege!")
		else
			ply:PrintMessage(2, "There is not a " .. args[2] .. " privilege!")
		end
	end
end
concommand.Add("rp_grant", ccGrantPriv)

function ccRevokePriv(ply, cmd, args)
	if ply:EntIndex() ~= 0 and not ply:IsSuperAdmin() then
		ply:PrintMessage(2, "You're not a super admin!")
		return
	end
	
	local PLAYER = ""
	if ply:EntIndex() == 0 then
		PLAYER = "console"
	else
		PLAYER = ply:Nick()
	end
	
	if not args[1] then
		ply:PrintMessage(2, "rp_revoke <player> <privilege> Revoke a player's privileges\nThese privileges are available:\ntool\nadmin\nphys\nprop\nmayor\ncp")
		return
	end
	
	local target = FindPlayer(args[1])
	if not target then
		if ply:EntIndex() == 0 then
			print("Could not find player: " .. args[2])
		else
			ply:PrintMessage(2, "Could not find player: " .. args[2])
		end
		return
	end
	if not args[2] then
		ply:PrintMessage(2, target:Nick() .. " has these privileges:")
		for i=0, 5, 1 do
			ply:PrintMessage(2, DB.Priv2Text(i).. "        "..tostring(target:HasPriv(i)))
		end
		return
	end
		
	if args[2] == "tool" then
		DB.RevokePriv(target, TOOL)
		NotifyAll( 1, 3, ply:Nick() .. " has revoked "..target:Nick().."'s toolgun priveleges.")
		if ply:EntIndex() == 0 then
			DB.Log("Console has revoked "..target:Nick().." toolgun priveleges." )
		else
			DB.Log(ply:SteamName().." ("..ply:SteamID()..") has revoked "..target:Nick().." toolgun priveleges." )
		end
	elseif args[2] == "admin" then
		DB.RevokePriv(target, ADMIN)
		NotifyAll( 1, 3, PLAYER .. " has revoked "..target:Nick().."'s admin priveleges.")
		if ply:EntIndex() == 0 then
			DB.Log("Console has revoked "..target:Nick().." admin priveleges." )
		else
			DB.Log(ply:SteamName().." ("..ply:SteamID()..") has revoked "..target:Nick().." admin priveleges." )
		end
	elseif args[2] == "phys" then
		DB.RevokePriv(target, PHYS)
		NotifyAll( 1, 3, PLAYER .. " has revoked "..target:Nick().."'s physgun priveleges.")
		if ply:EntIndex() == 0 then
			DB.Log("Console has revoked "..target:Nick().." physgun priveleges." )
		else
			DB.Log(ply:SteamName().." ("..ply:SteamID()..") has revoked "..target:Nick().." physgun priveleges." )
		end
	elseif args[2] == "prop" then
		DB.RevokePriv(target, PROP)
		NotifyAll( 1, 3, PLAYER .. " has revoked "..target:Nick().."'s prop spawn priveleges.")
		if ply:EntIndex() == 0 then
			DB.Log("Console has revoked "..target:Nick().." prop spawn priveleges." )
		else
			DB.Log(ply:SteamName().." ("..ply:SteamID()..") has revoked "..target:Nick().." prop spawn priveleges." )
		end
	elseif args[2] == "mayor" then
		DB.RevokePriv(target, MAYOR)
		NotifyAll( 1, 3, PLAYER .. " has revoked "..target:Nick().."'s /mayor priveleges.")
		if ply:EntIndex() == 0 then
			DB.Log("Console has revoked "..target:Nick().." mayor priveleges." )
		else
			DB.Log(ply:SteamName().." ("..ply:SteamID()..") has revoked "..target:Nick().." mayor priveleges." )
		end
	elseif args[2] == "cp" then
		DB.RevokePriv(target, CP)
		NotifyAll( 1, 3, PLAYER .. " has revoked "..target:Nick().."'s /cp priveleges.")
		if ply:EntIndex() == 0 then
			DB.Log("Console has revoked "..target:Nick().." CP priveleges." )
		else
			DB.Log(ply:SteamName().." ("..ply:SteamID()..") has revoked "..target:Nick().." CP priveleges." )
		end
	else
		if ply:EntIndex() == 0 then
			print("There is not a " .. args[2] .. " privilege!")
		else
			ply:PrintMessage(2, "There is not a " .. args[2] .. " privilege!")
		end
	end
end
concommand.Add("rp_revoke", ccRevokePriv)

function ccSWEPSpawn(ply, cmd, args)
	if CfgVars["adminsweps"] == 1 then
		if ply:EntIndex() ~= 0 and not ply:HasPriv(ADMIN) then
			Notify(ply, 1, 5, "You need admin privileges in order to be able to spawn a SWEP.")
			return
		end
	end
	CCGiveSWEP(ply, cmd, args)
	DB.Log(ply:SteamName().." ("..ply:SteamID()..") spawned SWEP "..args[1] )
end
concommand.Add("gm_giveswep", ccSWEPSpawn)

function ccSWEPGive(ply, cmd, args)
	if CfgVars["adminsweps"] == 1 then
		if ply:EntIndex() ~= 0 and not ply:HasPriv(ADMIN) then
			Notify(ply, 1, 5, "You need admin privileges in order to be able to spawn a SWEP.")
			return
		end
	end
	CCSpawnSWEP(ply, cmd, args)
	DB.Log(ply:SteamName().." ("..ply:SteamID()..") spawned SWEP "..args[1] )
end
concommand.Add("gm_spawnswep", ccSWEPGive)

function ccSENTSPawn(ply, cmd, args)
	if CfgVars["adminsents"] == 1 then
		if ply:EntIndex() ~= 0 and not ply:HasPriv(ADMIN) then
			Notify(ply, 1, 2, "You need admin privileges in order to be able to spawn a SENT.")
			return
		end
	end
	CCSpawnSENT(ply, cmd, args)
	DB.Log(ply:SteamName().." ("..ply:SteamID()..") spawned SENT "..args[1] )
end
concommand.Add("gm_spawnsent", ccSENTSPawn)
