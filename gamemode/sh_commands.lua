HELP_CATEGORY_CHATCMD = 1
HELP_CATEGORY_CONCMD = 2
HELP_CATEGORY_ADMINTOGGLE = 3
HELP_CATEGORY_ADMINCMD = 4
HELP_CATEGORY_ZOMBIE = 5

ValueCmds = {}
function AddValueCommand(cmd, cfgvar, global)
	ValueCmds[cmd] = { var = cfgvar, global = global }
	if SERVER then
		concommand.Add(cmd, ccValueCommand)
	end
end

ToggleCmds = {}
function AddToggleCommand(cmd, cfgvar, global, superadmin)
	ToggleCmds[cmd] = {var = cfgvar, global = global, superadmin = superadmin}
	if SERVER then
		concommand.Add(cmd, ccToggleCommand)
	end
end

AddHelpCategory(HELP_CATEGORY_CHATCMD, "Chat Commands")
AddHelpCategory(HELP_CATEGORY_CONCMD, "Console Commands")
AddHelpCategory(HELP_CATEGORY_ADMINTOGGLE, "Admin Toggle Commands (1 or 0!)")
AddHelpCategory(HELP_CATEGORY_ADMINCMD, "Admin Console Commands")
AddHelpCategory(HELP_CATEGORY_ZOMBIE, "Zombie chat commands")

AddHelpLabel(-1, HELP_CATEGORY_CONCMD, "gm_showhelp - Toggle help menu (bind this to F1 if you haven't already)")
AddHelpLabel(-1, HELP_CATEGORY_CONCMD, "gm_showteam - Show door menu")
AddHelpLabel(-1, HELP_CATEGORY_CONCMD, "gm_showspare1 - Toggle vote clicker (bind this to F3 if you haven't already)")
AddHelpLabel(-1, HELP_CATEGORY_CONCMD, "gm_showspare2 - Job menu(bind this to F4 if you haven't already)")

AddHelpLabel(-1, HELP_CATEGORY_ZOMBIE, "/addzombie (creates a zombie spawn)")
AddHelpLabel(-1, HELP_CATEGORY_ZOMBIE, "/removezombie index (removes a zombie spawn, index is the number inside ()")
AddHelpLabel(-1, HELP_CATEGORY_ZOMBIE, "/showzombie (shows where the zombie spawns are)")
AddHelpLabel(-1, HELP_CATEGORY_ZOMBIE, "/enablezombie (enables zombiemode)")
AddHelpLabel(-1, HELP_CATEGORY_ZOMBIE, "/disablezombie (disables zombiemode)")
AddHelpLabel(-1, HELP_CATEGORY_ZOMBIE, "/enablestorm enables meteor storms")

-----------------------------------------------------------
-- TOGGLE COMMANDS -- 
-----------------------------------------------------------
-- Usage of AddToggleCommand
-- (command name,  cfg variable name, is it a global variable or a cfg variable?)
local DefaultWeapons = {"weapon_physcannon", "weapon_physgun","weapon_crowbar","weapon_stunstick","weapon_pistol","weapon_357","weapon_smg1","weapon_shotgun","weapon_crossbow","weapon_ar2","weapon_bugbait", "weapon_rpg"}
for k,v in pairs(DefaultWeapons) do
	AddToggleCommand("rp_licenseweapon_"..v, "licenseweapon_"..v, true, true)
end
timer.Simple(1, function()
	for k,v in pairs(weapons.GetList()) do
		AddToggleCommand("rp_licenseweapon_"..string.lower(v.ClassName), "licenseweapon_"..string.lower(v.ClassName), true, true)
	end 
end)

AddToggleCommand("rp_propertytax", "propertytax", false)
AddHelpLabel(-1, HELP_CATEGORY_ADMINTOGGLE, "rp_propertytax - Enable/disable property tax.")

AddToggleCommand("rp_citpropertytax", "cit_propertytax", false)
AddHelpLabel(-1, HELP_CATEGORY_ADMINTOGGLE, "rp_citpropertytax - Enable/disable property tax that is exclusive only for citizens.")

AddToggleCommand("rp_bannedprops", "banprops", false)
AddHelpLabel(-1, HELP_CATEGORY_ADMINTOGGLE, "rp_bannedprops - Whether or not the banned props list is active. (overrides allowed props)")

AddToggleCommand("rp_allowedprops", "allowedprops", false)
AddHelpLabel(-1, HELP_CATEGORY_ADMINTOGGLE, "rp_allowedprops - Whether or not the allowed props list is active.")

AddToggleCommand("rp_strictsuicide", "strictsuicide", false)
AddHelpLabel(-1, HELP_CATEGORY_ADMINTOGGLE, "rp_strictsuicide - Whether or not players should spawn where they suicided (regardless of whether or not they are arrested.")

AddToggleCommand("rp_ooc", "ooc", false)
AddHelpLabel(-1, HELP_CATEGORY_ADMINTOGGLE, "rp_ooc - Whether or not OOC tags are enabled.")

AddToggleCommand("rp_alltalk", "alltalk", true)
AddHelpLabel(-1, HELP_CATEGORY_ADMINTOGGLE, "rp_alltalk - Enable for global chat, disable for local chat.")

AddToggleCommand("rp_allowrpnames", "allowrpnames", false)
AddHelpLabel(-1, HELP_CATEGORY_ADMINTOGGLE, "rp_allowrpnames - Allow Players to Set their RP names using the /rpname command.")

AddToggleCommand("rp_globaltags", "globalshow", true)
AddHelpLabel(-1, HELP_CATEGORY_ADMINTOGGLE, "rp_globaltags - Whether or not to display player info above players' heads in-game.")

AddToggleCommand("rp_showcrosshairs", "crosshair", false)
AddHelpLabel(-1, HELP_CATEGORY_ADMINTOGGLE, "rp_showcrosshairs - Enable/disable crosshair visibility")

AddToggleCommand("rp_showjob", "jobtag", true)
AddHelpLabel(-1, HELP_CATEGORY_ADMINTOGGLE, "rp_showjob - Whether or not to display a player's job above their head in-game.")

AddToggleCommand("rp_showname", "nametag", true)
AddHelpLabel(-1, HELP_CATEGORY_ADMINTOGGLE, "rp_showname - Whether or not to display a player's name above their head in-game.")

AddToggleCommand("rp_showdeaths", "deathnotice", true)
AddHelpLabel(-1, HELP_CATEGORY_ADMINTOGGLE, "rp_showdeaths - Display kill information in the upper right corner of everyone's screen.")

AddToggleCommand("rp_deathblack", "deathblack", true)
AddHelpLabel(-1, HELP_CATEGORY_ADMINTOGGLE, "rp_deathblack - Whether or not a player sees black on death.")

AddToggleCommand("rp_toolgun", "toolgun", false)
AddHelpLabel(-1, HELP_CATEGORY_ADMINTOGGLE, "rp_toolgun - Whether or not non-admin players spawn with toolguns.")

AddToggleCommand("rp_propspawning", "propspawning", false)
AddHelpLabel(-1, HELP_CATEGORY_ADMINTOGGLE, "rp_propspawning - Enable/disable props spawning for non-admins.")

AddToggleCommand("rp_proppaying", "proppaying", false)
AddHelpLabel(-1, HELP_CATEGORY_ADMINTOGGLE, "rp_proppaying - Whether or not players should pay for spawning props.")

AddToggleCommand("rp_adminsweps", "adminsweps", false)
AddHelpLabel(-1, HELP_CATEGORY_ADMINTOGGLE, "rp_adminsweps - Whether or not SWEPs should be admin only.")

AddToggleCommand("rp_adminsents", "adminsents", false)
AddHelpLabel(-1, HELP_CATEGORY_ADMINTOGGLE, "rp_adminsents - Whether or not SENTs should be admin only.")

AddToggleCommand("rp_enforcemodels", "enforceplayermodel", false)
AddHelpLabel(-1, HELP_CATEGORY_ADMINTOGGLE, "rp_enforcemodels - Whether or not to force players to use their role-defined character models.")

AddToggleCommand("rp_letters", "letters", false)
AddHelpLabel(-1, HELP_CATEGORY_ADMINTOGGLE, "rp_letters - Enable/disable letter writing / typing.")

AddToggleCommand("rp_earthquakes", "earthquakes", false)
AddHelpLabel(-1, HELP_CATEGORY_ADMINTOGGLE, "rp_earthquakes - Enable/disable earthquakes.")

AddToggleCommand("rp_customjobs", "customjobs", false)
AddHelpLabel(-1, HELP_CATEGORY_ADMINTOGGLE, "rp_customjobs - Enable/disable the /job command (personalized job names).")

AddToggleCommand("rp_copscanunfreeze", "copscanunfreeze", false)
AddHelpLabel(-1, HELP_CATEGORY_ADMINTOGGLE, "rp_copscanunfreeze - Enable/disable the ability of cops to freeze other people's props")

AddToggleCommand("rp_removeclassitems",  "removeclassitems", false)
AddHelpLabel(-1, HELP_CATEGORY_ADMINTOGGLE, "rp_removeclassitems - Enable/disable shipments/microwaves/etc. removal when someone changes team.")

AddToggleCommand("rp_lottery", "lottery", false)
AddHelpLabel(-1, HELP_CATEGORY_ADMINTOGGLE, "rp_lottery - Enable/disable creating lotteries for mayors")

AddToggleCommand("rp_AdminsSpawnWithCopWeapons", "AdminsSpawnWithCopWeapons", false, true)
AddHelpLabel(-1, HELP_CATEGORY_ADMINTOGGLE, "rp_AdminsSpawnWithCopWeapons - Enable/disable admins spawning with cops weapons(SUPERADMIN ONLY)")

AddToggleCommand("rp_babygod", "babygod", false)
AddHelpLabel(-1, HELP_CATEGORY_ADMINTOGGLE, "rp_babygod - Enable/disable People who have just spawned, are unable to die for 10 seconds.")

AddToggleCommand("rp_needwantedforarrest", "needwantedforarrest", false)
AddHelpLabel(-1, HELP_CATEGORY_ADMINTOGGLE, "rp_needwantedforarrest - Enable/disable Cops can only arrest wanted people.")

AddToggleCommand("rp_license", "license", false)
AddHelpLabel(-1, HELP_CATEGORY_ADMINTOGGLE, "rp_license - Enable/disable People need a license to be able to pick up guns")

AddToggleCommand("rp_allowvehiclenocollide", "allowvnocollide", false)
AddHelpLabel(-1, HELP_CATEGORY_ADMINTOGGLE, "rp_allowvehiclenocollide - Enable/disable the ability to no-collide a vehicle (for security).")

AddToggleCommand("rp_restrictbuypistol", "restrictbuypistol", false)
AddHelpLabel(-1, HELP_CATEGORY_ADMINTOGGLE, "rp_restrictbuypistol - Enabling this feature makes /buy available only to Gun Dealers (if one or more).")

AddToggleCommand("rp_noguns", "noguns", false)
AddHelpLabel(-1, HELP_CATEGORY_ADMINTOGGLE, "rp_noguns - Enabling this feature bans Guns and Gun Dealers.")

AddToggleCommand("rp_chiefjailpos", "chiefjailpos", false)
AddHelpLabel(-1, HELP_CATEGORY_ADMINTOGGLE, "rp_chiefjailpos - Allow the Chief to set the jail positions.")

AddToggleCommand("rp_physgun", "physgun", false)
AddHelpLabel(-1, HELP_CATEGORY_ADMINTOGGLE, "rp_physgun - Enable/disable Players spawning with physguns.")

AddToggleCommand("rp_enableshipments", "enableshipments", false)
AddHelpLabel(-1, HELP_CATEGORY_ADMINTOGGLE, "rp_enableshipments - Turn /buyshipment on of off.")

AddToggleCommand("rp_enablebuypistol", "enablebuypistol", false)
AddHelpLabel(-1, HELP_CATEGORY_ADMINTOGGLE, "rp_enablebuypistol - Turn /buy on of off.")

AddToggleCommand("rp_enablemayorsetsalary", "enablemayorsetsalary", false)
AddHelpLabel(-1, HELP_CATEGORY_ADMINTOGGLE, "rp_enablemayorsetsalary - Enable Mayor salary control.")

AddToggleCommand("rp_customspawns", "customspawns", false)
AddHelpLabel(-1, HELP_CATEGORY_ADMINTOGGLE, "rp_customspawns - Enable/disable whether custom spawns should be used.")

AddToggleCommand("rp_dm_autokick", "dmautokick", false)
AddHelpLabel(-1, HELP_CATEGORY_ADMINTOGGLE, "rp_dm_autokick - Enable/disable Auto-kick of deathmatchers.")

AddToggleCommand("rp_norespawn", "norespawn", false)
AddHelpLabel(-1, HELP_CATEGORY_ADMINTOGGLE, "rp_norespawn - Enable/Disable that people don't have to respawn when they change job.")

AddToggleCommand("rp_advertisements", "advertisements", false)
AddHelpLabel(-1, HELP_CATEGORY_ADMINTOGGLE, "rp_advertisements - Enable/Disable chatprint advertisements.")

AddToggleCommand("rp_doorwarrants", "doorwarrants", false)
AddHelpLabel(-1, HELP_CATEGORY_ADMINTOGGLE, "rp_doorwarrants - Enable/disable Warrant requirement to enter property.")

AddToggleCommand("rp_restrictallteams", "restrictallteams", false)
AddHelpLabel(-1, HELP_CATEGORY_ADMINTOGGLE, "rp_restrictallteams - Enable/disable Players can only be citizen until an admin allows them.")

AddToggleCommand("rp_pocket", "pocket", false)
AddHelpLabel(-1, HELP_CATEGORY_ADMINTOGGLE, "rp_pocket - Enable/disable pocket swep.")

AddToggleCommand("rp_voiceradius", "voiceradius", false)
AddHelpLabel(-1, HELP_CATEGORY_ADMINTOGGLE, "rp_voiceradius - Enable/disable local voice chat.")

AddToggleCommand("rp_teletojail", "teletojail", false)
AddHelpLabel(-1, HELP_CATEGORY_ADMINTOGGLE, "rp_teletojail - Enable/disable teleporting to jail.")

AddToggleCommand("rp_telefromjail", "telefromjail", false)
AddHelpLabel(-1, HELP_CATEGORY_ADMINTOGGLE, "rp_telefromjail - Enable/disable teleporting from jail.")

AddToggleCommand("rp_logging", "logging", false, true)
AddHelpLabel(-1, HELP_CATEGORY_ADMINTOGGLE, "rp_logging - Enable/disable logging everything that happens.")

AddToggleCommand("rp_restrictdrop", "RestrictDrop", false)
AddHelpLabel(-1, HELP_CATEGORY_ADMINTOGGLE, "rp_RestrictDrop - Enable/disable restricting which weapons players can drop.")

AddToggleCommand("rp_ironshoot", "ironshoot", false)
AddHelpLabel(-1, HELP_CATEGORY_ADMINTOGGLE, "rp_ironshoot - Enable/disable whether people need iron sights to shoot.")

AddToggleCommand("rp_dropmoneyondeath", "dropmoneyondeath", false)
AddHelpLabel(-1, HELP_CATEGORY_ADMINTOGGLE, "rp_dropmoneyondeath - Enable/disable whether people drop money on death.")

-----------------------------------------------------------
-- VALUE COMMANDS -- 
-----------------------------------------------------------

AddValueCommand("rp_ammopistolcost", "ammopistolcost", true)
AddHelpLabel(-1, HELP_CATEGORY_ADMINCMD, "rp_ammopistolcost <Number> - Sets the cost of pistol ammo.")

AddValueCommand("rp_ammoriflecost", "ammoriflecost", true)
AddHelpLabel(-1, HELP_CATEGORY_ADMINCMD, "rp_ammoriflecost <Number> - Sets the cost of rifle ammo.")

AddValueCommand("rp_ammoshotguncost", "ammoshotguncost", true)
AddHelpLabel(-1, HELP_CATEGORY_ADMINCMD, "rp_ammoshotguncost <Number> - Sets the cost of shotgun ammo.")

AddValueCommand("rp_healthcost", "healthcost", true)
AddHelpLabel(-1, HELP_CATEGORY_ADMINCMD, "rp_healthcost <Number> - Sets the cost of health.")

AddValueCommand("rp_jailtimer", "jailtimer", true)
AddHelpLabel(-1, HELP_CATEGORY_ADMINCMD, "rp_jailtimer <Number> - Sets the jailtimer. (in seconds)")

AddValueCommand("rp_maxdrugs", "maxdrugs", false)
AddHelpLabel(-1, HELP_CATEGORY_ADMINCMD, "rp_maxdrugs <Number> - Sets max drugs.")

AddValueCommand("rp_maxletters", "maxletters", false)
AddHelpLabel(-1, HELP_CATEGORY_ADMINCMD, "rp_maxletters <Number> - Sets max letters.")

AddValueCommand("rp_babygodtime", "babygodtime", false)
AddHelpLabel(-1, HELP_CATEGORY_ADMINCMD, "rp_babygodtime <Number> - How long the babygod lasts")

AddValueCommand("rp_doorcost", "doorcost", false)
AddHelpLabel(-1, HELP_CATEGORY_ADMINCMD, "rp_doorcost <Number> - Sets the cost of a door.")

AddValueCommand("rp_vehiclecost", "vehiclecost", false)
AddHelpLabel(-1, HELP_CATEGORY_ADMINCMD, "rp_vehiclecost <Number> - Sets the cost of a vehicle (To own it).")

AddValueCommand("rp_microwavefoodcost", "microwavefoodcost", true)
AddHelpLabel(-1, HELP_CATEGORY_ADMINCMD, "rp_microwavefoodcost <Number> - Sets the sale price of Microwave Food.")

AddValueCommand("rp_maxfoods", "maxfoods", false)
AddHelpLabel(-1, HELP_CATEGORY_ADMINCMD, "rp_maxfoods <Number> - Sets the max food cartons per Microwave owner.")

AddValueCommand("rp_maxmayorsetsalary", "maxmayorsetsalary", false)
AddHelpLabel(-1, HELP_CATEGORY_ADMINCMD, "rp_maxmayorsetsalary <Number> - Sets the Max Salary that a Mayor can set for another player.")

AddValueCommand("rp_runspeed", "rspd", false)
AddHelpLabel(-1, HELP_CATEGORY_ADMINCMD, "rp_runspeed <Number> - Sets the max running speed.")

AddValueCommand("rp_arrestspeed", "aspd", false)
AddHelpLabel(-1, HELP_CATEGORY_ADMINCMD, "rp_arrestspeed <Number> - Sets the max arrest speed.")

AddValueCommand("rp_walkspeed", "wspd", false)
AddHelpLabel(-1, HELP_CATEGORY_ADMINCMD, "rp_walkspeed <Number> - Sets the max walking speed.")

AddValueCommand("rp_npckillpay", "npckillpay", false)
AddHelpLabel(-1, HELP_CATEGORY_ADMINCMD, "rp_npckillpay <Number> - Sets the money given for each NPC kill.")

AddValueCommand("rp_normalsalary", "normalsalary", true)
AddHelpLabel(-1, HELP_CATEGORY_ADMINCMD, "rp_normalsalary <Number> - Sets the starting salary for newly joined players.")

AddValueCommand("rp_maxnormalsalary", "maxnormalsalary", true)
AddHelpLabel(-1, HELP_CATEGORY_ADMINCMD, "rp_maxnormalsalary <Number> - Sets the max normal salary.")

AddValueCommand("rp_maxcopsalary", "maxcopsalary", true)
AddHelpLabel(-1, HELP_CATEGORY_ADMINCMD, "rp_maxcopsalary <Number> - Sets the max salary that the Mayor can give to a CP.")

AddValueCommand("rp_quakechance_1_in", "quakechance", false)
AddHelpLabel(-1, HELP_CATEGORY_ADMINCMD, "rp_quakechance_1_in <Number> - Chance of an earthquake happening.")

AddValueCommand("rp_respawntime", "respawntime", false)
AddHelpLabel(-1, HELP_CATEGORY_ADMINCMD, "rp_respawntime <Number> - Minimum amount of seconds a player has to wait before respawning.")

AddValueCommand("rp_dm_gracetime", "dmgracetime", false)
AddHelpLabel(-1, HELP_CATEGORY_ADMINCMD, "rp_dm_gracetime <Number> - Number of seconds after killing a player that the killer will be watched for DM.")

AddValueCommand("rp_dm_maxkills", "dmmaxkills", false)
AddHelpLabel(-1, HELP_CATEGORY_ADMINCMD, "rp_dm_maxkills <Number> - Max number of kills allowed during rp_dm_gracetime to avoid being auto-kicked for DM.")

AddValueCommand("rp_demotetime", "demotetime", false)
AddHelpLabel(-1, HELP_CATEGORY_ADMINCMD, "rp_demotetime <Number> - Number of seconds before a player can rejoin a team after demotion from that team.")

AddValueCommand("rp_searchtime", "searchtime", false)
AddHelpLabel(-1, HELP_CATEGORY_ADMINCMD, "rp_searchtime <Number> - Number of seconds for which a search warrant is valid.")

AddValueCommand("rp_wantedtime", "wantedtime", false)
AddHelpLabel(-1, HELP_CATEGORY_ADMINCMD, "rp_wantedtime <Number> - Number of seconds for which a player is wanted for.")

AddValueCommand("rp_printamount", "mprintamount", true)
AddHelpLabel(-1, HELP_CATEGORY_ADMINCMD, "rp_printamount <Number> - Value of the money printed by the money printer.")

AddValueCommand("rp_lotterycommitcost", "lotterycommitcost", false)
AddHelpLabel(-1, HELP_CATEGORY_ADMINCMD, "rp_lotterycommitcost <Number> - How much you pay for entering a lottery")

AddValueCommand("rp_propcost", "propcost", false)
AddHelpLabel(-1, HELP_CATEGORY_ADMINCMD, "rp_propcost <Number> - How much prop spawning should cost. (prop paying must be enabled for this to have an effect)")

AddValueCommand("rp_pocketitems", "pocketitems", false)
AddHelpLabel(-1, HELP_CATEGORY_ADMINCMD, "rp_pocketitems <Number> - Sets the amount of objects the pocket can carry")

AddValueCommand("rp_paydelay", "paydelay", false)
AddHelpLabel(-1, HELP_CATEGORY_ADMINCMD, "rp_paydelay <Number> - Sets how long it takes before people get salary")

AddValueCommand("rp_maxvehicles", "maxvehicles", false)
AddHelpLabel(-1, HELP_CATEGORY_ADMINCMD, "rp_maxvehicles <Number> - Sets how many vehicles one can buy.")

AddValueCommand("rp_deathfee", "deathfee", false)
AddHelpLabel(-1, HELP_CATEGORY_ADMINCMD, "rp_deathfee <Number> - the amount of money someone drops when dead.")

AddValueCommand("rp_startinghealth", "startinghealth", false)
AddHelpLabel(-1, HELP_CATEGORY_ADMINCMD, "rp_startinghealth <Number> - the health when you spawn.")


function AddEntityCommands(name, command)
	local cmdname = string.gsub(command, " ", "_")
	
	AddToggleCommand("rp_disable"..cmdname, "disable"..cmdname, false)
	AddHelpLabel(-1, HELP_CATEGORY_ADMINTOGGLE, "rp_disable"..cmdname.." - disable that people can buy the "..name..".")

	AddValueCommand("rp_max"..cmdname, "max"..cmdname, false)
	AddHelpLabel(-1, HELP_CATEGORY_ADMINCMD, "rp_max"..cmdname.." <Number> - Sets how many ".. name .. " one can buy.")
	
	AddValueCommand("rp_"..cmdname.."_price", cmdname.."_price", false)
	AddHelpLabel(-1, HELP_CATEGORY_ADMINCMD, "rp_"..cmdname.."_price <Number> - Sets the price of ".. name .. ".")
end

function AddTeamCommands(CTeam)
	local k = 0
	for num,v in pairs(RPExtraTeams) do
		if v.command == CTeam.command then
			k = num
		end
	end
	AddValueCommand("rp_max"..CTeam.command.."s", "max"..CTeam.command.."s", false)
	AddToggleCommand("rp_allow"..CTeam.command, "allow"..CTeam.command, false, true)
	AddHelpLabel(-1, HELP_CATEGORY_ADMINCMD, "rp_"..CTeam.command.. " [Nick|SteamID|UserID] - Make a player become a "..CTeam.name..".")
	AddHelpLabel(-1, HELP_CATEGORY_ADMINTOGGLE, "rp_allow"..CTeam.command.." - Enable/disable "..CTeam.name)
	AddHelpLabel(-1, HELP_CATEGORY_ADMINCMD, "rp_max"..CTeam.command.."s".." <Number> - Sets max "..CTeam.name.."s.")
	if CLIENT then return end
	if not CfgVars["max"..CTeam.command.."s"] then
		CfgVars["max"..CTeam.command.."s"] = CTeam.max
		SetGlobalInt("max"..CTeam.command.."s", CTeam.max)
	end
	if not CfgVars["allow"..CTeam.command] then
		CfgVars["allow"..CTeam.command] = 1
		SetGlobalInt("allow"..CTeam.command, 1)
	end
	if CTeam.Vote then
		AddChatCommand("/vote"..CTeam.command, function(ply)
			if CfgVars["allow"..CTeam.command] and CfgVars["allow"..CTeam.command] ~= 1 then
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
				Notify(ply, 1, 4, LANGUAGE.vote_alone)
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
			if VoteCopOn then
				Notify(ply, 1, 4,  LANGUAGE.vote_already_exists)
				return ""
			end
			if ply:Team() == k then
				Notify(ply, 1, 4,  string.format(LANGUAGE.unable, CTeam.command, ""))
				return ""
			end
			if team.NumPlayers(k) >= CfgVars["max"..CTeam.command.."s"] then
				Notify(ply, 1, 4,  string.format(LANGUAGE.team_limit_reached,CTeam.name))
				return ""
			end
			vote:Create(string.format(LANGUAGE.wants_to_be, ply:Nick(), CTeam.name), ply:EntIndex() .. "votecop", ply, 20, function(choice, ply)
				VoteCopOn = false
				if choice == 1 then
					ply:ChangeTeam(k)
				else
					NotifyAll(1, 4, string.format(LANGUAGE.has_not_been_made_team, ply:Nick(), CTeam.name))
				end
			end)
			ply:GetTable().LastVoteCop = CurTime()
			VoteCopOn = true
			return ""
		end)
		AddChatCommand("/"..CTeam.command, function(ply)
			if CfgVars["allow"..CTeam.command] and CfgVars["allow"..CTeam.command] ~= 1 then
				Notify(ply, 1, 4, string.format(LANGUAGE.disabled, CTeam.name, ""))
				return ""
			end
			
			if ply:GetNWBool("Priv"..CTeam.command) then
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
			if CfgVars["allow"..CTeam.command] and CfgVars["allow"..CTeam.command] ~= 1 then
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
		if (ply:EntIndex() ~= 0 and not ply:HasPriv(ADMIN)) then
			ply:PrintMessage(2, string.format(LANGUAGE.need_admin, cmd))
			return
        end
		
		if CTeam.admin > 1 and not ply:IsSuperAdmin() then
			ply:PrintMessage(2, string.format(LANGUAGE.need_sadmin, cmd))
			return
		end
		
		if CTeam.Vote then
			if CTeam.admin == 1 and ply:EntIndex() ~= 0 and not ply:IsSuperAdmin() then
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
			target:ChangeTeam(k)
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

function GenerateChatCommandHelp()
	local p = "/"

	AddHelpLabel(1000, HELP_CATEGORY_CHATCMD, p .. "help - Bring up this menu")
	AddHelpLabel(1100, HELP_CATEGORY_CHATCMD, p .. "job <Job Name> - Set a custom job")
	AddHelpLabel(1200, HELP_CATEGORY_CHATCMD, p .. "w <Message> - Whisper a message")
	AddHelpLabel(1300, HELP_CATEGORY_CHATCMD, p .. "y <Message> - Yell a message")
	AddHelpLabel(1350, HELP_CATEGORY_CHATCMD, p .. "g <Message> - Group only message")
	AddHelpLabel(1400, HELP_CATEGORY_CHATCMD, "//, or /a, or /ooc - Out of Character speak", 1)
	AddHelpLabel(1500, HELP_CATEGORY_CHATCMD, "/x to close a help dialog", 1)
	AddHelpLabel(2700, HELP_CATEGORY_CHATCMD, p .. "pm <Name/Partial Name> <Message> - Send another player a PM.")
	AddHelpLabel(2500, HELP_CATEGORY_CHATCMD, "")
	AddHelpLabel(2650, HELP_CATEGORY_CHATCMD, "Letters - Press use key to read a letter.  Look away and press use key again to stop reading a letter.")
	AddHelpLabel(2550, HELP_CATEGORY_CHATCMD, p .. "write <Message> - Write a letter in handwritten font. Use // to go down a line.")
	AddHelpLabel(2600, HELP_CATEGORY_CHATCMD, p .. "type <Message> - Type a letter in computer font.  Use // to go down a line.")
	AddHelpLabel(1450, HELP_CATEGORY_CHATCMD, "")
	AddHelpLabel(1500, HELP_CATEGORY_CHATCMD, p .. "give <Amount> - Give a money amount")
	AddHelpLabel(1600, HELP_CATEGORY_CHATCMD, p .. "moneydrop or dropmoney <Amount> - Drop a money amount")
	AddHelpLabel(1650, HELP_CATEGORY_CHATCMD, "")
	AddHelpLabel(1700, HELP_CATEGORY_CHATCMD, p .. "title <Name> - Give a door you own, a title")
	AddHelpLabel(1800, HELP_CATEGORY_CHATCMD, p .. "addowner or ao <Name> - Allow another to player to own your door")
	AddHelpLabel(1825, HELP_CATEGORY_CHATCMD, p .. "removeowner <Name> - Remove an owner from your door")
	AddHelpLabel(1850, HELP_CATEGORY_CHATCMD, "")
	AddHelpLabel(1900, HELP_CATEGORY_CHATCMD, p .. "votecop - Vote to be a Cop")
	AddHelpLabel(2750, HELP_CATEGORY_CHATCMD, p .. "votemayor - Vote to be Mayor")
	AddHelpLabel(2100, HELP_CATEGORY_CHATCMD, p .. "citizen - Become a Citizen")
	AddHelpLabel(2000, HELP_CATEGORY_CHATCMD, p .. "mayor - Become Mayor if you're on the admin's Mayor list")
	AddHelpLabel(2200, HELP_CATEGORY_CHATCMD, p .. "cp - Become a Combine if you're on the admin's Cop list")
	AddHelpLabel(2250, HELP_CATEGORY_CHATCMD, "")
	AddHelpLabel(2300, HELP_CATEGORY_CHATCMD, p .. "cr <Message> - Request the CP's assistance")
end
GenerateChatCommandHelp()

-- concommand help labesl
AddHelpLabel(-1, HELP_CATEGORY_ADMINCMD, "rp_own - Own the door you're looking at.")
AddHelpLabel(-1, HELP_CATEGORY_ADMINCMD, "rp_unown - Remove ownership from the door you're looking at.")
AddHelpLabel(-1, HELP_CATEGORY_ADMINCMD, "rp_addowner [Nick|SteamID|UserID] - Add a co-owner to the door you're looking at.")
AddHelpLabel(-1, HELP_CATEGORY_ADMINCMD, "rp_removeowner [Nick|SteamID|UserID] - Remove co-owner from door you're looking at.")
AddHelpLabel(-1, HELP_CATEGORY_ADMINCMD, "rp_lock - Lock the door you're looking at.")
AddHelpLabel(-1, HELP_CATEGORY_ADMINCMD, "rp_unlock - Unlock the door you're looking at.")
AddHelpLabel(-1, HELP_CATEGORY_ADMINCMD, "rp_tell [Nick|SteamID|UserID] <Message> - Send a noticeable message to a named player.")
AddHelpLabel(-1, HELP_CATEGORY_ADMINCMD, "rp_removeletters [Nick|SteamID|UserID] - Remove all letters for a given player (or all if none specified).")
AddHelpLabel(-1, HELP_CATEGORY_ADMINCMD, "rp_chatprefix <Prefix> - Set the chat prefix for commands (like the / in /votecop or /job).")
AddHelpLabel(-1, HELP_CATEGORY_ADMINCMD, "rp_paydaytime <Delay> - Pay interval. (in seconds)")
AddHelpLabel(-1, HELP_CATEGORY_ADMINCMD, "rp_arrest [Nick|SteamID|UserID] <Length> - Arrest a player for a custom amount of time. If no time is specified, it will default to " .. GetGlobalInt("jailtimer") .. " seconds.")
AddHelpLabel(-1, HELP_CATEGORY_ADMINCMD, "rp_unarrest [Nick|SteamID|UserID] - Unarrest a player.")
AddHelpLabel(-1, HELP_CATEGORY_ADMINCMD, "rp_kickban [Nick|SteamID|UserID] <Length in minutes> - Kick and ban a player.")
AddHelpLabel(-1, HELP_CATEGORY_ADMINCMD, "rp_kick [Nick|SteamID|UserID] <Kick reason> - Kick a player. The reason is optional.")
AddHelpLabel(-1, HELP_CATEGORY_ADMINCMD, "rp_setmoney [Nick|SteamID|UserID] <Amount> - Set a player's money to a specific amount.")
AddHelpLabel(-1, HELP_CATEGORY_ADMINCMD, "rp_setsalary [Nick|SteamID|UserID] <Amount> - Set a player's Roleplay Salary.")
AddHelpLabel(-1, HELP_CATEGORY_ADMINCMD, "rp_grant [tool|phys|admin|prop|cp|mayor] [Nick|SteamID|UserID] - Gives a privilege to a player.")
AddHelpLabel(-1, HELP_CATEGORY_ADMINCMD, "rp_revoke [tool|phys|admin|prop|cp|mayor] [Nick|SteamID|UserID] - Revokes a privilege from a player.")