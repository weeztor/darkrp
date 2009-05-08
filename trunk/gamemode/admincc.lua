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

	if #args < 1 then
		if valuecmd.global then
			if ply:EntIndex() == 0 then
				print(cmd .. " = " .. GetGlobalInt(valuecmd.var))
			else
				ply:PrintMessage(2, cmd .. " = " .. GetGlobalInt(valuecmd.var))
			end
		else
			if ply:EntIndex() == 0 then
				print(cmd .. " = " .. CfgVars[valuecmd.var])
			else
				ply:PrintMessage(2, cmd .. " = " .. CfgVars[valuecmd.var])
			end
		end
		return
	end

	if ply:EntIndex() ~= 0 and not ply:HasPriv(ADMIN) then
		ply:PrintMessage(2, "You're not an admin")
		return
	end

	local amount = math.floor(tonumber(args[1]))

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
end

function ccToggleCommand(ply, cmd, args)
	local togglecmd = ToggleCmds[cmd]

	if not togglecmd then return end

	if #args < 1 then
		if togglecmd.global then
			if ply:EntIndex() == 0 then
				print(cmd .. " = " .. GetGlobalInt(togglecmd.var))
			else
				ply:PrintMessage(2, cmd .. " = " .. GetGlobalInt(togglecmd.var))
			end
		else
			if ply:EntIndex() == 0 then
				print(cmd .. " = " .. CfgVars[togglecmd.var])
			else
				ply:PrintMessage(2, cmd .. " = " .. CfgVars[togglecmd.var])
			end
		end
		return
	end

	if (ply:EntIndex() ~= 0 and not DB.HasPriv(ply, ADMIN)) or (togglecmd.superadmin and not ply:IsSuperAdmin()) then
		ply:PrintMessage(2, "(Super)/Admin only!")
		return
	end

	local toggle = tonumber(args[1])

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
end

function ccDoorOwn(ply, cmd, args)
	if ply:EntIndex() == 0 then
		return
	end

	if not ply:HasPriv(ADMIN) then
		ply:PrintMessage(2, "You're not an admin")
		return
	end

	local trace = ply:GetEyeTrace()

	if not ValidEntity(trace.Entity) or not trace.Entity:IsOwnable() or ply:EyePos():Distance(trace.Entity:GetPos()) > 200 then
		return
	end

	trace.Entity:Fire("unlock", "", 0)
	trace.Entity:UnOwn()
	trace.Entity:Own(ply)
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
	else
		if ply:EntIndex() == 0 then
			print("Could not find player: " .. args[1])
		else
			ply:PrintMessage(2, "Could not find player: " .. args[1])
		end
	end
end
concommand.Add("rp_tell", ccTell)

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
end
concommand.Add("rp_paydaytime", ccPayDayTime)

function ccArrest(ply, cmd, args)
	if ply:EntIndex() ~= 0 and not ply:HasPriv(ADMIN) then
		ply:PrintMessage(2, "You're not an admin")
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

function ccMayor(ply, cmd, args)
	if ply:EntIndex() ~= 0 and not ply:HasPriv(ADMIN) then
		ply:PrintMessage(2, "You're not an admin!")
		return
	end

	local target = FindPlayer(args[1])

	if target then
		target:ChangeTeam(TEAM_MAYOR)
		local nick = ""

		if ply:EntIndex() ~= 0 then
			nick = ply:Nick()
		else
			nick = "Console"
		end

		target:PrintMessage(2, nick .. " made you Mayor!")
	else
		if ply:EntIndex() == 0 then
			print("Could not find player: " .. args[1])
		else
			ply:PrintMessage(2, "Could not find player: " .. args[1])
		end
		return
	end
end
concommand.Add("rp_mayor", ccMayor)

function ccCPChief(ply, cmd, args)
	if ply:EntIndex() ~= 0 and not ply:HasPriv(ADMIN) then
		ply:PrintMessage(2, "You're not an admin!")
		return
	end

	local target = FindPlayer(args[1])

	if target then
		local nick = ""

		if ply:EntIndex() ~= 0 then
			nick = ply:Nick()
		else
			nick = "Console"
		end

		target:ChangeTeam(TEAM_POLICE)
		target:ChangeTeam(TEAM_CHIEF)
		target:PrintMessage(2, nick .. " made you a CP Chief!")
	else
		print("Could not find player: " .. args[1])
		return
	end
end
concommand.Add("rp_cpchief", ccCPChief)
concommand.Add("rp_chief", ccCPChief)

function ccCP(ply, cmd, args)
	if ply:EntIndex() ~= 0 and not ply:HasPriv(ADMIN) then
		ply:PrintMessage(2, "You're not an admin!")
		return
	end

	local target = FindPlayer(args[1])

	if target then
		target:ChangeTeam(TEAM_POLICE)

		if ply:EntIndex() ~= 0 then
			nick = ply:Nick()
		else
			nick = "Console"
		end

		target:PrintMessage(2, nick .. " made you a CP!")
	else
		if ply:EntIndex() == 0 then
			print("Could not find player: " .. args[1])
		else
			ply:PrintMessage(2, "Could not find player: " .. args[1])
		end
		return
	end
end
concommand.Add("rp_cp", ccCP)

function ccCitizen(ply, cmd, args)
	if ply:EntIndex() ~= 0 and not ply:HasPriv(ADMIN) then
		ply:PrintMessage(2, "You're not an admin!")
		return
	end

	local target = FindPlayer(args[1])

	if target then
		target:ChangeTeam(TEAM_CITIZEN)

		if ply:EntIndex() ~= 0 then
			nick = ply:Nick()
		else
			nick = "Console"
		end

		target:PrintMessage(2, nick .. " made you a Citizen!")
	else
		if ply:EntIndex() == 0 then
			print("Could not find player: " .. args[1])
		else
			ply:PrintMessage(2, "Could not find player: " .. args[1])
		end
		return
	end
end
concommand.Add("rp_citizen", ccCitizen)

function ccCook(ply, cmd, args)
	if ply:EntIndex() ~= 0 and not ply:HasPriv(ADMIN) then
		ply:PrintMessage(2, "You're not an admin!")
		return
	end

	local target = FindPlayer(args[1])

	if target then
		target:ChangeTeam(TEAM_COOK)

		if ply:EntIndex() ~= 0 then
			nick = ply:Nick()
		else
			nick = "Console"
		end

		target:PrintMessage(2, nick .. " made you a cook!")
	else
		if ply:EntIndex() == 0 then
			print("Could not find player: " .. args[1])
		else
			ply:PrintMessage(2, "Could not find player: " .. args[1])
		end
		return
	end
end
concommand.Add("rp_cook", ccCook)

function ccMedic(ply, cmd, args)
	if ply:EntIndex() ~= 0 and not ply:HasPriv(ADMIN) then
		ply:PrintMessage(2, "You're not an admin!")
		return
	end

	local target = FindPlayer(args[1])

	if target then
		target:ChangeTeam(TEAM_MEDIC)

		if ply:EntIndex() ~= 0 then
			nick = ply:Nick()
		else
			nick = "Console"
		end

		target:PrintMessage(2, nick .. " made you a medic!")
	else
		if ply:EntIndex() == 0 then
			print("Could not find player: " .. args[1])
		else
			ply:PrintMessage(2, "Could not find player: " .. args[1])
		end
		return
	end
end
concommand.Add("rp_medic", ccMedic)

function ccGundealer(ply, cmd, args)
	if ply:EntIndex() ~= 0 and not ply:HasPriv(ADMIN) then
		ply:PrintMessage(2, "You're not an admin!")
		return
	end

	local target = FindPlayer(args[1])

	if target then
		target:ChangeTeam(TEAM_GUN)

		if ply:EntIndex() ~= 0 then
			nick = ply:Nick()
		else
			nick = "Console"
		end

		target:PrintMessage(2, nick .. " made you a gundealer!")
	else
		if ply:EntIndex() == 0 then
			print("Could not find player: " .. args[1])
		else
			ply:PrintMessage(2, "Could not find player: " .. args[1])
		end
		return
	end
end
concommand.Add("rp_gundealer", ccGundealer)

function ccmobboss(ply, cmd, args)
	if ply:EntIndex() ~= 0 and not ply:HasPriv(ADMIN) then
		ply:PrintMessage(2, "You're not an admin!")
		return
	end

	local target = FindPlayer(args[1])

	if target then
		target:ChangeTeam(TEAM_MOB)

		if ply:EntIndex() ~= 0 then
			nick = ply:Nick()
		else
			nick = "Console"
		end

		target:PrintMessage(2, nick .. " made you a mobboss!")
	else
		if ply:EntIndex() == 0 then
			print("Could not find player: " .. args[1])
		else
			ply:PrintMessage(2, "Could not find player: " .. args[1])
		end
		return
	end
end
concommand.Add("rp_mobboss", ccmobboss)

function ccgangster(ply, cmd, args)
	if ply:EntIndex() ~= 0 and not ply:HasPriv(ADMIN) then
		ply:PrintMessage(2, "You're not an admin!")
		return
	end

	local target = FindPlayer(args[1])

	if target then
		target:ChangeTeam(TEAM_GANG)

		if ply:EntIndex() ~= 0 then
			nick = ply:Nick()
		else
			nick = "Console"
		end

		target:PrintMessage(2, nick .. " made you a gangster!")
	else
		if ply:EntIndex() == 0 then
			print("Could not find player: " .. args[1])
		else
			ply:PrintMessage(2, "Could not find player: " .. args[1])
		end
		return
	end
end
concommand.Add("rp_gangster", ccgangster)

for k,v in pairs(RPExtraTeams) do
	concommand.Add("rp_"..v.command, function(ply, cmd, args)
		if (ply:EntIndex() ~= 0 and not ply:HasPriv(ADMIN)) then
			ply:PrintMessage(2, "You're not an admin!")
			return
        end
		
		if v.admin > 1 and not ply:IsSuperAdmin() then
			ply:PrintMessage(2, "You're not a super admin!")
			return
		end
		
		if v.Vote then
			if v.admin == 1 and ply:EntIndex() ~= 0 and not ply:IsSuperAdmin() then
				ply:PrintMessage(2, "You're not a super admin!")
				return
			elseif v.admin > 1 and ply:IsSuperAdmin() and ply:EntIndex() ~= 0 then
				ply:PrintMessage(2, "You cannot make anyone "..v.name.." because voting is on and admin is set to super admin. Make a vote...")
				return
			end
		end
		local target = FindPlayer(args[1])
		
        if (target) then
			target:ChangeTeam(9 + k)
			if (ply:EntIndex() ~= 0) then
				nick = ply:Nick()
			else
				nick = "Console"
			end
			target:PrintMessage(2, nick .. " made you a " .. v.name .. "!")
        else
			if (ply:EntIndex() == 0) then
				print("Could not find player: " .. args[1])
			else
				ply:PrintMessage(2, "Could not find player: " .. args[1])
			end
			return
        end
	end)
end
		

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
			ply:PrintMessage(2, DB.Priv2Text(i).. "        "..tostring(target:HasPriv(i)))
		end
		return
	end
	
	if args[2] == "tool" then
		DB.GrantPriv(target, TOOL)
		NotifyAll( 1, 3, PLAYER .. " has granted "..target:Nick().." toolgun priveleges.")
	elseif args[2] == "admin" then
		DB.GrantPriv(target, ADMIN)
		NotifyAll( 1, 3, PLAYER .. " has granted "..target:Nick().." admin priveleges.")
	elseif args[2] == "phys" then
		DB.GrantPriv(target, PHYS)
		NotifyAll( 1, 3, PLAYER .. " has granted "..target:Nick().." physgun priveleges.")
	elseif args[2] == "prop" then
		DB.GrantPriv(target, PROP)
		NotifyAll( 1, 3, PLAYER .. " has granted "..target:Nick().." prop spawn priveleges.")
	elseif args[2] == "mayor" then
		DB.GrantPriv(target, MAYOR)
		NotifyAll( 1, 3, PLAYER .. " has granted "..target:Nick().." /mayor priveleges.")
	elseif args[2] == "cp" then
		DB.GrantPriv(target, CP)
		NotifyAll( 1, 3, PLAYER .. " has granted "..target:Nick().." /cp priveleges.")
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
	elseif args[2] == "admin" then
		DB.RevokePriv(target, ADMIN)
		NotifyAll( 1, 3, PLAYER .. " has revoked "..target:Nick().."'s admin priveleges.")
	elseif args[2] == "phys" then
		DB.RevokePriv(target, PHYS)
		NotifyAll( 1, 3, PLAYER .. " has revoked "..target:Nick().."'s physgun priveleges.")
	elseif args[2] == "prop" then
		DB.RevokePriv(target, PROP)
		NotifyAll( 1, 3, PLAYER .. " has revoked "..target:Nick().."'s prop spawn priveleges.")
	elseif args[2] == "mayor" then
		DB.RevokePriv(target, MAYOR)
		NotifyAll( 1, 3, PLAYER .. " has revoked "..target:Nick().."'s /mayor priveleges.")
	elseif args[2] == "cp" then
		DB.RevokePriv(target, CP)
		NotifyAll( 1, 3, PLAYER .. " has revoked "..target:Nick().."'s /cp priveleges.")
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
			Notify(ply, 1, 2, "You're not an admin!")
			return
		end
	end
	CCGiveSWEP(ply, cmd, args)
end
concommand.Add("gm_giveswep", ccSWEPSpawn)

function ccSWEPGive(ply, cmd, args)
	if CfgVars["adminsweps"] == 1 then
		if ply:EntIndex() ~= 0 and not ply:HasPriv(ADMIN) then
			Notify(ply, 1, 2, "You're not an admin!")
			return
		end
	end
	CCSpawnSWEP(ply, cmd, args)
end
concommand.Add("gm_spawnswep", ccSWEPGive)

function ccSENTSPawn(ply, cmd, args)
	if CfgVars["adminsents"] == 1 then
		if ply:EntIndex() ~= 0 and not ply:HasPriv(ADMIN) then
			Notify(ply, 1, 2, "You're not an admin!")
			return
		end
	end
	CCSpawnSENT(ply, cmd, args)
end
concommand.Add("gm_spawnsent", ccSENTSPawn)
