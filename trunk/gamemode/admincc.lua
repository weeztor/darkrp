local function ccValueCommand(ply, cmd, args)
	local valuecmd = ValueCmds[cmd]

	if not valuecmd then return end

	if #args < 1 or not tonumber(args[1]) then
		if ply:EntIndex() == 0 then
			print(cmd .. " = " .. tostring(GetConVarNumber(valuecmd.var)))
		else
			ply:PrintMessage(2, cmd .. " = " .. tostring(GetConVarNumber(valuecmd.var)))
		end
		return
	end

	if ply:EntIndex() ~= 0 and not ply:HasPriv(ADMIN) then
		ply:PrintMessage(2, string.format(LANGUAGE.need_admin, cmd))
		return
	end

	local amount = math.floor(tonumber(args[1]))
	if amount == GetConVarNumber(valuecmd.var) then return end
	RunConsoleCommand(valuecmd.var, amount)
	DB.SaveSetting(valuecmd.var, amount)

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

local function ccToggleCommand(ply, cmd, args)
	local togglecmd = ToggleCmds[cmd]

	if not togglecmd then return end

	if #args < 1 or not tonumber(args[1]) then
		if ply:EntIndex() == 0 then
			print(cmd .. " = " .. GetConVarNumber(togglecmd.var))
		else
			ply:PrintMessage(2, cmd .. " = " .. GetConVarNumber(togglecmd.var))
		end

		return
	end

	if (ply:EntIndex() ~= 0 and not DB.HasPriv(ply, ADMIN)) or (togglecmd.superadmin and not ply:IsSuperAdmin()) then
		ply:PrintMessage(2, string.format(LANGUAGE.need_sadmin, cmd))
		return
	end

	local toggle = tonumber(args[1])
	if toggle == GetConVarNumber(togglecmd.var) then return end

	if not toggle or (toggle ~= 1 and toggle ~= 0) then
		if ply:EntIndex() == 0 then
			print(string.format(LANGUAGE.invalid_x, "argument", "1/0"))
		else
			ply:PrintMessage(2, string.format(LANGUAGE.invalid_x, "argument", "1/0"))
		end
		return
	end

	RunConsoleCommand(togglecmd.var, toggle)
	DB.SaveSetting(togglecmd.var, toggle)

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

if not ConVarExists("rp_language") then
	CreateConVar("rp_language", "english", {FCVAR_REPLICATED, FCVAR_ARCHIVE, FCVAR_NOTIFY})	
end

LANGUAGE = rp_languages[GetConVarString("rp_language")]
if not LANGUAGE then
	LANGUAGE = rp_languages["english"]--now hope people don't remove the english language ._.
end



local function ccDoorOwn(ply, cmd, args)
	if ply:EntIndex() == 0 then
		return
	end

	if not ply:HasPriv(ADMIN) then
		ply:PrintMessage(2, string.format(LANGUAGE.need_admin, "rp_own"))
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

local function ccDoorUnOwn(ply, cmd, args)
	if ply:EntIndex() == 0 then
		return
	end

	if not ply:HasPriv(ADMIN) then
		ply:PrintMessage(2, string.format(LANGUAGE.need_admin, "rp_unown"))
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

local function ccAddOwner(ply, cmd, args)
	if ply:EntIndex() == 0 then
		return
	end

	if not ply:HasPriv(ADMIN) then
		ply:PrintMessage(2, string.format(LANGUAGE.need_admin, "rp_addowner"))
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
				ply:PrintMessage(2, string.format(LANGUAGE.rp_addowner_already_owns_door))
			end
		else
			trace.Entity:Own(target)
		end
	else
		ply:PrintMessage(2, string.format(LANGUAGE.could_not_find, "player: "..tostring(args)))
	end
	DB.Log(ply:SteamName().." ("..ply:SteamID()..") force-added a door owner with rp_addowner" )
end
concommand.Add("rp_addowner", ccAddOwner)

local function ccRemoveOwner(ply, cmd, args)
	if ply:EntIndex() == 0 then
		return
	end

	if not ply:HasPriv(ADMIN) then
		ply:PrintMessage(2,  string.format(LANGUAGE.need_admin, "rp_removeowner"))
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
		ply:PrintMessage(2, string.format(LANGUAGE.could_not_find, "player: "..tostring(args)))
	end
	DB.Log(ply:SteamName().." ("..ply:SteamID()..") force-removed a door owner with rp_removeowner" )
end
concommand.Add("rp_removeowner", ccRemoveOwner)

local function ccLock(ply, cmd, args)
	if ply:EntIndex() == 0 then
		return
	end

	if not ply:HasPriv(ADMIN) then
		ply:PrintMessage(2,  string.format(LANGUAGE.need_admin, "rp_lock"))
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

local function ccUnLock(ply, cmd, args)
	if ply:EntIndex() == 0 then
		return
	end

	if not ply:HasPriv(ADMIN) then
		ply:PrintMessage(2,  string.format(LANGUAGE.need_admin, "rp_unlock"))
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

local function ccTell(ply, cmd, args)
	if not args[1] then return end
	if ply:EntIndex() ~= 0 and not ply:HasPriv(ADMIN) then
		ply:PrintMessage(2,  string.format(LANGUAGE.need_admin, "rp_tell"))
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
			print(string.format(LANGUAGE.could_not_find, "player: "..tostring(args[1])))
		else
			ply:PrintMessage(2, string.format(LANGUAGE.could_not_find, "player: "..tostring(args[1])))
		end
	end
end
concommand.Add("rp_tell", ccTell)

local function ccTellAll(ply, cmd, args)
	if not args[1] then return end
	if ply:EntIndex() ~= 0 and not ply:HasPriv(ADMIN) then
		ply:PrintMessage(2, string.format(LANGUAGE.need_admin, "rp_tellall"))
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

local function ccRemoveLetters(ply, cmd, args)
	if ply:EntIndex() ~= 0 and not ply:HasPriv(ADMIN) then
		ply:PrintMessage(2, string.format(LANGUAGE.need_admin, "rp_removeletters"))
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

local function ccArrest(ply, cmd, args)
	if not args[1] then return end
	if ply:EntIndex() ~= 0 and not ply:HasPriv(ADMIN) then
		ply:PrintMessage(2, string.format(LANGUAGE.need_admin, "rp_arrest"))
		return
	end

	if DB.CountJailPos() == 0 then
		if ply:EntIndex() == 0 then
			print(LANGUAGE.no_jail_pos)
		else
			ply:PrintMessage(2, LANGUAGE.no_jail_pos)
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
			print(string.format(LANGUAGE.could_not_find, "player: "..tostring(args[1])))
		else
			ply:PrintMessage(2, string.format(LANGUAGE.could_not_find, "player: "..tostring(args[1])))
		end
	end
	
end
concommand.Add("rp_arrest", ccArrest)

local function ccUnarrest(ply, cmd, args)
	if not args[1] then return end
	if ply:EntIndex() ~= 0 and not ply:HasPriv(ADMIN) then
		ply:PrintMessage(2, string.format(LANGUAGE.need_admin, "rp_unarrest"))
		return
	end

	local target = FindPlayer(args[1])

	if target then
		target:Unarrest()
		if not target:Alive() then v:Spawn() end
		
		if ply:EntIndex() == 0 then
			DB.Log("Console force-unarrested "..target:SteamName())
		else
			DB.Log(ply:SteamName().." ("..ply:SteamID()..") force-unarrested "..target:SteamName() )
		end
	else
		if ply:EntIndex() == 0 then
			print(string.format(LANGUAGE.could_not_find, "player: "..tostring(args[1])))
		else
			ply:PrintMessage(2, string.format(LANGUAGE.could_not_find, "player: "..tostring(args[1])))
		end
		return
	end
	
end
concommand.Add("rp_unarrest", ccUnarrest)

local function ccSetMoney(ply, cmd, args)
	if not args[1] then return end
	if ply:EntIndex() ~= 0 and not ply:IsSuperAdmin() then
		ply:PrintMessage(2, string.format(LANGUAGE.need_sadmin, "rp_setmoney"))
		return
	end

	local amount = math.floor(tonumber(args[2]))

	if not amount then
		if ply:EntIndex() == 0 then
			print(string.format(LANGUAGE.invalid_x, "argument", args[2]))
		else
			ply:PrintMessage(2, string.format(LANGUAGE.invalid_x, "argument", args[2]))
		end 
		return
	end

	local target = FindPlayer(args[1])

	if target then
		local nick = ""
		target:SetDarkRPVar("money", amount)
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

local function ccSetSalary(ply, cmd, args)
	if not args[1] then return end
	if ply:EntIndex() ~= 0 and not ply:IsSuperAdmin() then
		ply:PrintMessage(2, string.format(LANGUAGE.need_sadmin, "rp_setsalary"))
		return
	end

	local amount = math.floor(tonumber(args[2]))

	if not amount or amount < 0 then
		if ply:EntIndex() == 0 then
			print(string.format(LANGUAGE.invalid_x, "argument", args[2]))
		else 
			ply:PrintMessage(2, string.format(LANGUAGE.invalid_x, "argument", args[2]))
		end
		return
	end

	if amount > 150 then
		if ply:EntIndex() == 0 then
			print(string.format(LANGUAGE.invalid_x, "argument", args[2].." (<150)"))
		else
			ply:PrintMessage(2, string.format(LANGUAGE.invalid_x, "argument", args[2].." (<150)"))
		end
		return
	end

	local target = FindPlayer(args[1])

	if target then
		local nick = ""
		DB.StoreSalary(target, amount)
		target:SetDarkRPVar("salary", amount)
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
			print(string.format(LANGUAGE.could_not_find, "player: "..tostring(args[1])))
		else 
			ply:PrintMessage(2, string.format(LANGUAGE.could_not_find, "player: "..tostring(args[1])))
		end
		return
	end
end
concommand.Add("rp_setsalary", ccSetSalary)

local function ccGrantPriv(ply, cmd, args)
	if ply:EntIndex() ~= 0 and not ply:IsSuperAdmin() then
		ply:PrintMessage(2, string.format(LANGUAGE.need_sadmin, "rp_grantpriv"))
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
			print(string.format(LANGUAGE.could_not_find, "player: "..tostring(args[1])))
		else
			ply:PrintMessage(2, string.format(LANGUAGE.could_not_find, "player: "..tostring(args[1])))
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
		DB.GrantPriv(target, PTOOL)
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

local function ccRevokePriv(ply, cmd, args)
	if ply:EntIndex() ~= 0 and not ply:IsSuperAdmin() then
		ply:PrintMessage(2, string.format(LANGUAGE.need_sadmin, "rp_revokepriv"))
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
			print(string.format(LANGUAGE.could_not_find, "player: "..tostring(args[1])))
		else
			ply:PrintMessage(2, string.format(LANGUAGE.could_not_find, "player: "..tostring(args[1])))
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
		DB.RevokePriv(target, PTOOL)
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

local function ccSWEPSpawn(ply, cmd, args)
	if GetConVarNumber("adminsweps") == 1 then
		if ply:EntIndex() ~= 0 and not ply:HasPriv(ADMIN) then
			Notify(ply, 1, 5, string.format(LANGUAGE.need_admin, "gm_giveswep"))
			return
		end
	end
	CCGiveSWEP(ply, cmd, args)
	DB.Log(ply:SteamName().." ("..ply:SteamID()..") spawned SWEP "..args[1] )
end
concommand.Add("gm_giveswep", ccSWEPSpawn)

local function ccSWEPGive(ply, cmd, args)
	if GetConVarNumber("adminsweps") == 1 then
		if ply:EntIndex() ~= 0 and not ply:HasPriv(ADMIN) then
			Notify(ply, 1, 5, string.format(LANGUAGE.need_admin, "gm_spawnswep"))
			return
		end
	end
	CCSpawnSWEP(ply, cmd, args)
	DB.Log(ply:SteamName().." ("..ply:SteamID()..") spawned SWEP "..args[1] )
end
concommand.Add("gm_spawnswep", ccSWEPGive)

local function ccSENTSPawn(ply, cmd, args)
	if GetConVarNumber("adminsents") == 1 then
		if ply:EntIndex() ~= 0 and not ply:HasPriv(ADMIN) then
			Notify(ply, 1, 2, string.format(LANGUAGE.need_admin, "gm_spawnsent"))
			return
		end
	end
	CCSpawnSENT(ply, cmd, args)
	DB.Log(ply:SteamName().." ("..ply:SteamID()..") spawned SENT "..args[1] )
end
concommand.Add("gm_spawnsent", ccSENTSPawn)
