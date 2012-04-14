local HELP_CATEGORY_ADMINTOGGLE = 5
local HELP_CATEGORY_ADMINCMD = 6

ValueCmds = {}
function AddValueCommand(cmd, cfgvar, default)
	ValueCmds[cmd] = {var = cfgvar, default = default}
	CreateConVar(cfgvar, default, {FCVAR_REPLICATED, FCVAR_SERVER_CAN_EXECUTE})
	if SERVER then
		concommand.Add(cmd, ccValueCommand)
	end
end

ToggleCmds = {}
function AddToggleCommand(cmd, cfgvar, default, superadmin)
	ToggleCmds[cmd] = {var = cfgvar, superadmin = superadmin, default = default}
	CreateConVar(cfgvar, default, {FCVAR_REPLICATED, FCVAR_SERVER_CAN_EXECUTE})
	if SERVER then
		concommand.Add(cmd, ccToggleCommand)
	end
end
CreateConVar("DarkRP_LockDown", 0, {FCVAR_REPLICATED, FCVAR_SERVER_CAN_EXECUTE}) -- Don't save this one!

concommand.Add("rp_commands", function()
	for k, v in SortedPairs(ToggleCmds) do
		print(k)
	end
	for k,v in SortedPairs(ValueCmds) do
		print(k)
	end
end)

if SERVER then
	concommand.Add("rp_ResetAllSettings", function(ply, cmd, args)
		DB.Query("DELETE FROM darkrp_cvars;")
		if ply:EntIndex() ~= 0 and not ply:IsSuperAdmin() then
			Notify(ply, 1, 5, string.format(LANGUAGE.need_sadmin, "rp_resetallsettings"))
			return
		end
		Notify(ply, 0, 4, LANGUAGE.reset_settings)
		local count = 0
		for k,v in pairs(ToggleCmds) do
			count = count + 1
			timer.Simple(count * 0.1, RunConsoleCommand, v.var, v.default)
		end

		for k,v in pairs(ValueCmds) do
			count = count + 1
			timer.Simple(count * 0.1, RunConsoleCommand, v.var, v.default)
		end
	end)
end

-----------------------------------------------------------
-- TOGGLE COMMANDS --
-----------------------------------------------------------
-- Usage of AddToggleCommand
-- (Command name,  Cfg variable name, Default value, Superadmin only)
local DefaultWeapons = {"weapon_physcannon", "weapon_physgun","weapon_crowbar","weapon_stunstick","weapon_pistol","weapon_357","weapon_smg1","weapon_shotgun","weapon_crossbow","weapon_ar2","weapon_bugbait", "weapon_rpg", "gmod_camera", "gmod_tool"}
local Allowedweps = {"weapon_physcannon", "weapon_physgun", "weapon_bugbait", "gmod_tool", "gmod_camera"}
for k,v in pairs(DefaultWeapons) do
	local allowed = 0
	if table.HasValue(Allowedweps, v) then allowed = 1 end
	AddToggleCommand("rp_licenseweapon_"..v, "licenseweapon_"..v, allowed, true)
end
Allowedweps = {"lockpick", "door_ram", "med_kit", "arrest_stick", "unarrest_stick", "keys", "laserpointer", "remotecontroller", "weaponchecker"}
timer.Simple(1, function()
	for k,v in pairs(weapons.GetList()) do
		local allowed = 0
		if table.HasValue(Allowedweps, v.ClassName) then allowed = 1 end
		AddToggleCommand("rp_licenseweapon_"..string.lower(v.ClassName), "licenseweapon_"..string.lower(v.ClassName), allowed, true)
	end
end)


AddToggleCommand("rp_3dvoice", "3dvoice", 1)
AddToggleCommand("rp_adminnpcs", "adminnpcs", 1)
AddToggleCommand("rp_adminsents", "adminsents", 1)
AddToggleCommand("rp_AdminsSpawnWithCopWeapons", "AdminsCopWeapons", 1, true)
AddValueCommand("rp_adminweapons", "adminweapons", 1)
AddToggleCommand("rp_adminvehicles", "adminvehicles", 1)
AddToggleCommand("rp_advertisements", "advertisements", 1)
AddToggleCommand("rp_allowrpnames", "allowrpnames", 1)
AddToggleCommand("rp_allowswitchjob", "allowjobswitch", 1)
AddToggleCommand("rp_allowvehiclenocollide", "allowvnocollide", 0)
AddToggleCommand("rp_allowvehicleowning", "allowvehicleowning", 1)
AddToggleCommand("rp_alltalk", "alltalk", 1)
AddToggleCommand("rp_autovehiclelock", "autovehiclelock", 0)
AddToggleCommand("rp_babygod", "babygod", 5)
AddToggleCommand("rp_chiefjailpos", "chiefjailpos", 1)
AddToggleCommand("rp_citpropertytax", "cit_propertytax", 0)
AddToggleCommand("rp_copscanunfreeze", "copscanunfreeze", 1)
AddToggleCommand("rp_copscanunweld", "copscanunweld", 0)
AddToggleCommand("rp_cpcanarrestcp", "cpcanarrestcp", 1)
AddToggleCommand("rp_customjobs", "customjobs", 1)
AddToggleCommand("rp_customspawns", "customspawns", 1)
AddToggleCommand("rp_deathblack", "deathblack", 0)
AddToggleCommand("rp_deathpov", "deathpov", 1)
AddToggleCommand("rp_decalcleaner", "decalcleaner", 0)
AddToggleCommand("rp_dm_autokick", "dmautokick", 1)
AddToggleCommand("rp_doorwarrants", "doorwarrants", 1)
AddToggleCommand("rp_dropmoneyondeath", "dropmoneyondeath", 0)
AddToggleCommand("rp_droppocketonarrest", "droppocketarrest", 0)
AddToggleCommand("rp_droppocketondeath", "droppocketdeath", 1)
AddToggleCommand("rp_dropweaponondeath", "dropweapondeath", 0)
AddToggleCommand("rp_earthquakes", "earthquakes", 0)
AddToggleCommand("rp_enablebuyhealth", "enablebuyhealth", 1)
AddToggleCommand("rp_enablebuypistol", "enablebuypistol", 1)
AddToggleCommand("rp_enablemayorsetsalary", "enablemayorsetsalary", 1)
AddToggleCommand("rp_enableshipments", "enableshipments", 1)
AddToggleCommand("rp_enforcemodels", "enforceplayermodel", 1)
AddToggleCommand("rp_globaltags", "globalshow", 0)
AddToggleCommand("rp_hobownership", "hobownership", 1)
AddToggleCommand("rp_ironshoot", "ironshoot", 1)
AddToggleCommand("rp_letters", "letters", 1)
AddToggleCommand("rp_license", "license", 0)
AddToggleCommand("rp_logging", "logging", 1, true)
AddToggleCommand("rp_lottery", "lottery", 1)
AddToggleCommand("rp_needwantedforarrest", "needwantedforarrest", 0)
AddToggleCommand("rp_noguns", "noguns", 0)
AddToggleCommand("rp_norespawn", "norespawn", 1)
AddToggleCommand("rp_npcarrest", "npcarrest", 1)
AddToggleCommand("rp_ooc", "ooc", 1)
AddToggleCommand("rp_pocket", "pocket", 1)
AddToggleCommand("rp_propertytax", "propertytax", 0)
AddToggleCommand("rp_proplympics", "proplympics", 1)
AddToggleCommand("rp_proppaying", "proppaying", 0)
AddToggleCommand("rp_propspawning", "propspawning", 1)
AddToggleCommand("rp_removeclassitems",  "removeclassitems", 1)
AddToggleCommand("rp_respawninjail", "respawninjail", 1)
AddToggleCommand("rp_restrictallteams", "restrictallteams", 0)
AddToggleCommand("rp_restrictbuypistol", "restrictbuypistol", 0)
AddToggleCommand("rp_restrictdrop", "restrictdrop", 0)
AddToggleCommand("rp_showcrosshairs", "xhair", 1)
AddToggleCommand("rp_showdeaths", "deathnotice", 1)
AddToggleCommand("rp_showjob", "jobtag", 1)
AddToggleCommand("rp_showname", "nametag", 1)
AddToggleCommand("rp_strictsuicide", "strictsuicide", 0)
AddToggleCommand("rp_telefromjail", "telefromjail", 1)
AddToggleCommand("rp_teletojail", "teletojail", 1)
AddToggleCommand("rp_toolgun", "toolgun", 1)
AddToggleCommand("rp_unlockdoorsonstart", "unlockdoorsonstart", 0)
AddToggleCommand("rp_voiceradius", "voiceradius", 0)
AddToggleCommand("rp_voiceradius_dynamic", "dynamicvoice", 1)
AddToggleCommand("rp_wantedsuicide", "wantedsuicide", 0)

-----------------------------------------------------------
-- VALUE COMMANDS --
-----------------------------------------------------------

AddValueCommand("rp_ammopistolcost", "ammopistolcost", 0)
AddValueCommand("rp_ammoriflecost", "ammoriflecost", 60)
AddValueCommand("rp_ammoshotguncost", "ammoshotguncost", 70)
AddValueCommand("rp_arrestspeed", "aspd", 120)
AddValueCommand("rp_babygodtime", "babygodtime", 5)
AddValueCommand("rp_deathfee", "deathfee", 30)
AddValueCommand("rp_decaltimer", "decaltimer", 120)
AddValueCommand("rp_demotetime", "demotetime", 120)
AddValueCommand("rp_dm_gracetime", "dmgracetime", 30)
AddValueCommand("rp_dm_maxkills", "dmmaxkills", 3)
AddValueCommand("rp_doorcost", "doorcost", 30)
AddValueCommand("rp_EntityRemoveDelay", "entremovedelay", 0)
AddValueCommand("rp_healthcost", "healthcost", 60)
AddValueCommand("rp_jailtimer", "jailtimer", 120)
AddValueCommand("rp_lotterycommitcost", "lotterycommitcost", 50)
AddValueCommand("rp_maxcopsalary", "maxcopsalary", 100)
AddValueCommand("rp_maxdrugs", "maxdrugs", 2)
AddValueCommand("rp_maxfoods", "maxfoods", 2)
AddValueCommand("rp_maxlawboards", "maxlawboards", 2)
AddValueCommand("rp_maxletters", "maxletters", 10)
AddValueCommand("rp_maxmayorsetsalary", "maxmayorsetsalary", 120)
AddValueCommand("rp_maxnormalsalary", "maxnormalsalary", 90)
AddValueCommand("rp_maxvehicles", "maxvehicles", 5)
AddValueCommand("rp_microwavefoodcost", "microwavefoodcost", 30)
AddValueCommand("rp_normalsalary", "normalsalary", 45)
AddValueCommand("rp_npckillpay", "npckillpay", 10)
AddValueCommand("rp_paydelay", "paydelay", 160)
AddValueCommand("rp_pocketitems", "pocketitems", 10)
AddValueCommand("rp_pricecap", "pricecap", 500)
AddValueCommand("rp_pricemin", "pricemin", 50)
AddValueCommand("rp_printamount", "mprintamount", 250)
AddValueCommand("rp_propcost", "propcost", 10)
AddValueCommand("rp_quakechance_1_in", "quakechance", 4000)
AddValueCommand("rp_respawntime", "respawntime", 3)
AddValueCommand("rp_runspeed", "rspd", 240)
AddValueCommand("rp_searchtime", "searchtime", 30)
AddValueCommand("rp_ShipmentSpawnTime", "ShipmentSpamTime", 3)
AddValueCommand("rp_shipmenttime", "shipmentspawntime", 10)
AddValueCommand("rp_startinghealth", "startinghealth", 100)
AddValueCommand("rp_startingmoney", "startingmoney", 500)
AddValueCommand("rp_vehiclecost", "vehiclecost", 40)
AddValueCommand("rp_walkspeed", "wspd", 160)
AddValueCommand("rp_wantedtime", "wantedtime", 120)

function AddEntityCommands(name, command, max, price)
	local cmdname = string.gsub(command, " ", "_")

	AddToggleCommand("rp_disable"..cmdname, "disable"..cmdname, 0)
	AddValueCommand("rp_"..cmdname.."_price", cmdname.."_price", price or 30)

	if CLIENT then
		GM:AddHelpLabel(-1, HELP_CATEGORY_ADMINTOGGLE, "rp_disable"..cmdname.." - disable that people can buy the "..name..".")
		GM:AddHelpLabel(-1, HELP_CATEGORY_ADMINCMD, "rp_"..cmdname.."_price <Number> - Sets the price of ".. name .. ".")
	end
end

function AddTeamCommands(CTeam, max)
	local k = 0
	for num,v in pairs(RPExtraTeams) do
		if v.command == CTeam.command then
			k = num
		end
	end
	AddToggleCommand("rp_allow"..CTeam.command, "allow"..CTeam.command, 1, true)

	if CLIENT then
		GAMEMODE:AddHelpLabel(-1, HELP_CATEGORY_ADMINCMD, "rp_"..CTeam.command.. " [Nick|SteamID|UserID] - Make a player become a "..CTeam.name..".")
		GAMEMODE:AddHelpLabel(-1, HELP_CATEGORY_ADMINTOGGLE, "rp_allow"..CTeam.command.." - Enable/disable "..CTeam.name)
		return
	end

	if CTeam.Vote then
		AddChatCommand("/vote"..CTeam.command, function(ply)
			if GetConVarNumber("allow"..CTeam.command) and GetConVarNumber("allow"..CTeam.command) ~= 1 then
				Notify(ply, 1, 4, string.format(LANGUAGE.disabled, CTeam.name, ""))
				return ""
			end
			if type(CTeam.NeedToChangeFrom) == "number" and ply:Team() ~= CTeam.NeedToChangeFrom then
				Notify(ply, 1,4, string.format(LANGUAGE.need_to_be_before, team.GetName(CTeam.NeedToChangeFrom), CTeam.name))
				return ""
			elseif type(CTeam.NeedToChangeFrom) == "table" and not table.HasValue(CTeam.NeedToChangeFrom, ply:Team()) then
				local teamnames = ""
				for a,b in pairs(CTeam.NeedToChangeFrom) do teamnames = teamnames.." or "..team.GetName(b) end
				Notify(ply, 1,4, string.format(LANGUAGE.need_to_be_before, string.sub(teamnames, 5), CTeam.name))
				return ""
			end
			if #player.GetAll() == 1 then
				Notify(ply, 0, 4, LANGUAGE.vote_alone)
				ply:ChangeTeam(k)
				return ""
			end
			if not ply:ChangeAllowed(k) then
				Notify(ply, 1, 4, string.format(LANGUAGE.unable, "/vote"..CTeam.command, "banned/demoted"))
				return ""
			end
			if CurTime() - ply:GetTable().LastVoteCop < 80 then
				Notify(ply, 1, 4, string.format(LANGUAGE.have_to_wait, math.ceil(80 - (CurTime() - ply:GetTable().LastVoteCop)), CTeam.command))
				return ""
			end
			if ply:Team() == k then
				Notify(ply, 1, 4,  string.format(LANGUAGE.unable, CTeam.command, ""))
				return ""
			end
			local max = CTeam.max
			if max ~= 0 and ((max % 1 == 0 and team.NumPlayers(k) >= max) or (max % 1 ~= 0 and (team.NumPlayers(k) + 1) / #player.GetAll() > max)) then
				Notify(ply, 1, 4,  string.format(LANGUAGE.team_limit_reached,CTeam.name))
				return ""
			end
			vote:Create(string.format(LANGUAGE.wants_to_be, ply:Nick(), CTeam.name), ply:EntIndex() .. "votecop", ply, 20, function(choice, ply)
				if choice == 1 then
					ply:ChangeTeam(k)
				else
					NotifyAll(1, 4, string.format(LANGUAGE.has_not_been_made_team, ply:Nick(), CTeam.name))
				end
			end)
			ply:GetTable().LastVoteCop = CurTime()
			return ""
		end)
		AddChatCommand("/"..CTeam.command, function(ply)
			if GetConVarNumber("allow"..CTeam.command) ~= 1 then
				Notify(ply, 1, 4, string.format(LANGUAGE.disabled, CTeam.name, ""))
				return ""
			end

			if ply:HasPriv("rp_"..CTeam.command) then
				ply:ChangeTeam(k, true)
				return ""
			end

			local a = CTeam.admin
			if a > 0 and not ply:IsAdmin()
			or a > 1 and not ply:IsSuperAdmin()
			then
				Notify(ply, 1, 4, string.format(LANGUAGE.need_admin, CTeam.name))
				return ""
			end

			if a == 0 and not ply:IsAdmin()
			or a == 1 and not ply:IsSuperAdmin()
			or a == 2
			then
				Notify(ply, 1, 4, string.format(LANGUAGE.need_to_make_vote, CTeam.name))
				return ""
			end

			ply:ChangeTeam(k, true)
			return ""
		end)
	else
		AddChatCommand("/"..CTeam.command, function(ply)
			if GetConVarNumber("allow"..CTeam.command) ~= 1 then
				Notify(ply, 1, 4, string.format(LANGUAGE.disabled, CTeam.name, ""))
				return ""
			end
			if CTeam.admin == 1 and not ply:IsAdmin() then
				Notify(ply, 1, 4, string.format(LANGUAGE.need_admin, "/"..CTeam.command))
				return ""
			end
			if CTeam.admin > 1 and not ply:IsSuperAdmin() then
				Notify(ply, 1, 4, string.format(LANGUAGE.need_sadmin, "/"..CTeam.command))
				return ""
			end
			ply:ChangeTeam(k)
			return ""
		end)
	end

	concommand.Add("rp_"..CTeam.command, function(ply, cmd, args)
		if ply:EntIndex() ~= 0 and not ply:IsAdmin() then
			ply:PrintMessage(2, string.format(LANGUAGE.need_admin, cmd))
			return
        end

		if CTeam.admin > 1 and not ply:IsSuperAdmin() then
			ply:PrintMessage(2, string.format(LANGUAGE.need_sadmin, cmd))
			return
		end

		if CTeam.Vote then
			if CTeam.admin >= 1 and ply:EntIndex() ~= 0 and not ply:IsSuperAdmin() then
				ply:PrintMessage(2, string.format(LANGUAGE.need_admin, cmd))
				return
			elseif CTeam.admin > 1 and ply:IsSuperAdmin() and ply:EntIndex() ~= 0 then
				ply:PrintMessage(2, string.format(LANGUAGE.need_to_make_vote, CTeam.name))
				return
			end
		end

		if not args[1] then return end
		local target = FindPlayer(args[1])

        if (target) then
			target:ChangeTeam(k, true)
			if (ply:EntIndex() ~= 0) then
				nick = ply:Nick()
			else
				nick = "Console"
			end
			target:PrintMessage(2, nick .. " has made you a " .. CTeam.name .. "!")
        else
			if (ply:EntIndex() == 0) then
				print(string.format(LANGUAGE.could_not_find, "player: "..tostring(args[1])))
			else
				ply:PrintMessage(2, string.format(LANGUAGE.could_not_find, "player: "..tostring(args[1])))
			end
			return
        end
	end)
end

hook.Add("InitPostEntity", "FAdmin_DarkRP_privs", function()
	if not FAdmin or not FAdmin.StartHooks then return end
	FAdmin.Access.AddPrivilege("rp_commands", 2)
	FAdmin.Access.AddPrivilege("rp_tool", 2)
	FAdmin.Access.AddPrivilege("rp_phys", 2)
	FAdmin.Access.AddPrivilege("rp_prop", 2)
	for k,v in pairs(RPExtraTeams) do
		if v.Vote then
			FAdmin.Access.AddPrivilege("rp_"..v.command, (v.admin or 0) + 2) -- Add privileges for the teams that are voted for
		end
	end
end)