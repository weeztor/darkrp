local HELP_CATEGORY_CHATCMD = 1
local HELP_CATEGORY_CONCMD = 2
local HELP_CATEGORY_ZOMBIE = 3
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

AddHelpCategory(HELP_CATEGORY_CHATCMD, "Chat Commands")
AddHelpCategory(HELP_CATEGORY_CONCMD, "Console Commands")
AddHelpCategory(HELP_CATEGORY_ADMINTOGGLE, "Admin Toggle Commands (1 or 0!)")
AddHelpCategory(HELP_CATEGORY_ADMINCMD, "Admin Console Commands")
AddHelpCategory(HELP_CATEGORY_ZOMBIE, "Zombie Chat Commands")

AddHelpLabel(-1, HELP_CATEGORY_CONCMD, "gm_showhelp - Toggle help menu (bind this to F1 if you haven't already)")
AddHelpLabel(-1, HELP_CATEGORY_CONCMD, "gm_showteam - Show door menu")
AddHelpLabel(-1, HELP_CATEGORY_CONCMD, "gm_showspare1 - Toggle vote clicker (bind this to F3 if you haven't already)")
AddHelpLabel(-1, HELP_CATEGORY_CONCMD, "gm_showspare2 - Job menu(bind this to F4 if you haven't already)")

AddHelpLabel(-1, HELP_CATEGORY_ZOMBIE, "/addzombie (creates a zombie spawn)")
AddHelpLabel(-1, HELP_CATEGORY_ZOMBIE, "/zombiemax (maximum amount of zombies that can be alive)")
AddHelpLabel(-1, HELP_CATEGORY_ZOMBIE, "/removezombie index (removes a zombie spawn, index is the number inside ()")
AddHelpLabel(-1, HELP_CATEGORY_ZOMBIE, "/showzombie (shows where the zombie spawns are)")
AddHelpLabel(-1, HELP_CATEGORY_ZOMBIE, "/enablezombie (enables zombiemode)")
AddHelpLabel(-1, HELP_CATEGORY_ZOMBIE, "/disablezombie (disables zombiemode)")
AddHelpLabel(-1, HELP_CATEGORY_ZOMBIE, "/enablestorm (enables meteor storms)")

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

AddToggleCommand("rp_propertytax", "propertytax", 0)
AddHelpLabel(-1, HELP_CATEGORY_ADMINTOGGLE, "rp_propertytax - Enable/disable property tax.")

AddToggleCommand("rp_citpropertytax", "cit_propertytax", 0)
AddHelpLabel(-1, HELP_CATEGORY_ADMINTOGGLE, "rp_citpropertytax - Enable/disable property tax that is exclusive only for citizens.")

AddToggleCommand("rp_strictsuicide", "strictsuicide", 0)
AddHelpLabel(-1, HELP_CATEGORY_ADMINTOGGLE, "rp_strictsuicide - Whether or not players should spawn where they suicided (regardless of whether or not they are arrested)")

AddToggleCommand("rp_ooc", "ooc", 1)
AddHelpLabel(-1, HELP_CATEGORY_ADMINTOGGLE, "rp_ooc - Whether or not OOC tags are enabled.")

AddToggleCommand("rp_alltalk", "alltalk", 1)
AddHelpLabel(-1, HELP_CATEGORY_ADMINTOGGLE, "rp_alltalk - Enable for global chat, disable for local chat.")

AddToggleCommand("rp_allowrpnames", "allowrpnames", 1)
AddHelpLabel(-1, HELP_CATEGORY_ADMINTOGGLE, "rp_allowrpnames - Allow Players to Set their RP names using the /rpname command.")

AddToggleCommand("rp_globaltags", "globalshow", 0)
AddHelpLabel(-1, HELP_CATEGORY_ADMINTOGGLE, "rp_globaltags - Whether or not to display player info above players' heads in-game.")

AddToggleCommand("rp_showcrosshairs", "xhair", 1)
AddHelpLabel(-1, HELP_CATEGORY_ADMINTOGGLE, "rp_showcrosshairs - Enable/disable crosshair visibility")

AddToggleCommand("rp_showjob", "jobtag", 1)
AddHelpLabel(-1, HELP_CATEGORY_ADMINTOGGLE, "rp_showjob - Whether or not to display a player's job above their head in-game.")

AddToggleCommand("rp_showname", "nametag", 1)
AddHelpLabel(-1, HELP_CATEGORY_ADMINTOGGLE, "rp_showname - Whether or not to display a player's name above their head in-game.")

AddToggleCommand("rp_showdeaths", "deathnotice", 1)
AddHelpLabel(-1, HELP_CATEGORY_ADMINTOGGLE, "rp_showdeaths - Display kill information in the upper right corner of everyone's screen.")

AddToggleCommand("rp_deathblack", "deathblack", 0)
AddHelpLabel(-1, HELP_CATEGORY_ADMINTOGGLE, "rp_deathblack - Whether or not a player sees black on death.")

AddToggleCommand("rp_toolgun", "toolgun", 1)
AddHelpLabel(-1, HELP_CATEGORY_ADMINTOGGLE, "rp_toolgun - Whether or not non-admin players spawn with toolguns.")

AddToggleCommand("rp_propspawning", "propspawning", 1)
AddHelpLabel(-1, HELP_CATEGORY_ADMINTOGGLE, "rp_propspawning - Enable/disable props spawning for non-admins.")

AddToggleCommand("rp_proppaying", "proppaying", 0)
AddHelpLabel(-1, HELP_CATEGORY_ADMINTOGGLE, "rp_proppaying - Whether or not players should pay for spawning props.")

AddToggleCommand("rp_adminsweps", "adminsweps", 1)
AddHelpLabel(-1, HELP_CATEGORY_ADMINTOGGLE, "rp_adminsweps - Whether or not SWEPs should be admin only.")

AddToggleCommand("rp_adminsents", "adminsents", 1)
AddHelpLabel(-1, HELP_CATEGORY_ADMINTOGGLE, "rp_adminsents - Whether or not SENTs should be admin only.")

AddToggleCommand("rp_adminvehicles", "adminvehicles", 1)
AddHelpLabel(-1, HELP_CATEGORY_ADMINTOGGLE, "rp_adminvehicles - Whether or not Vehicles should be admin only.")

AddToggleCommand("rp_adminnpcs", "adminnpcs", 1)
AddHelpLabel(-1, HELP_CATEGORY_ADMINTOGGLE, "rp_adminnpcs - Whether or not NPCs should be admin only.")

AddToggleCommand("rp_enforcemodels", "enforceplayermodel", 1)
AddHelpLabel(-1, HELP_CATEGORY_ADMINTOGGLE, "rp_enforcemodels - Whether or not to force players to use their role-defined character models.")

AddToggleCommand("rp_letters", "letters", 1)
AddHelpLabel(-1, HELP_CATEGORY_ADMINTOGGLE, "rp_letters - Enable/disable letter writing / typing.")

AddToggleCommand("rp_earthquakes", "earthquakes", 0)
AddHelpLabel(-1, HELP_CATEGORY_ADMINTOGGLE, "rp_earthquakes - Enable/disable earthquakes.")

AddToggleCommand("rp_customjobs", "customjobs", 1)
AddHelpLabel(-1, HELP_CATEGORY_ADMINTOGGLE, "rp_customjobs - Enable/disable the /job command (personalized job names).")

AddToggleCommand("rp_copscanunfreeze", "copscanunfreeze", 1)
AddHelpLabel(-1, HELP_CATEGORY_ADMINTOGGLE, "rp_copscanunfreeze - Enable/disable the ability of cops to unfreeze other people's props")

AddToggleCommand("rp_copscanunweld", "copscanunweld", 0)
AddHelpLabel(-1, HELP_CATEGORY_ADMINTOGGLE, "rp_copscanunweld - Enable/disable the ability of cops to unweld other people's props")

AddToggleCommand("rp_removeclassitems",  "removeclassitems", 1)
AddHelpLabel(-1, HELP_CATEGORY_ADMINTOGGLE, "rp_removeclassitems - Enable/disable shipments/microwaves/etc. removal when someone changes team.")

AddToggleCommand("rp_lottery", "lottery", 1)
AddHelpLabel(-1, HELP_CATEGORY_ADMINTOGGLE, "rp_lottery - Enable/disable creating lotteries for mayors")

AddToggleCommand("rp_AdminsSpawnWithCopWeapons", "AdminsCopWeapons", 1, true)
AddHelpLabel(-1, HELP_CATEGORY_ADMINTOGGLE, "rp_AdminsSpawnWithCopWeapons - Enable/disable admins spawning with cops weapons(SUPERADMIN ONLY)")

AddToggleCommand("rp_babygod", "babygod", 5)
AddHelpLabel(-1, HELP_CATEGORY_ADMINTOGGLE, "rp_babygod - Enable/disable People who have just spawned, are unable to die for 10 seconds.")

AddToggleCommand("rp_needwantedforarrest", "needwantedforarrest", 0)
AddHelpLabel(-1, HELP_CATEGORY_ADMINTOGGLE, "rp_needwantedforarrest - Enable/disable Cops can only arrest wanted people.")

AddToggleCommand("rp_license", "license", 0)
AddHelpLabel(-1, HELP_CATEGORY_ADMINTOGGLE, "rp_license - Enable/disable People need a license to be able to pick up guns")

AddToggleCommand("rp_allowvehiclenocollide", "allowvnocollide", 0)
AddHelpLabel(-1, HELP_CATEGORY_ADMINTOGGLE, "rp_allowvehiclenocollide - Enable/disable the ability to no-collide a vehicle (for security).")

AddToggleCommand("rp_restrictbuypistol", "restrictbuypistol", 0)
AddHelpLabel(-1, HELP_CATEGORY_ADMINTOGGLE, "rp_restrictbuypistol - Enabling this feature makes /buy available only to Gun Dealers (if one or more).")

AddToggleCommand("rp_noguns", "noguns", 0)
AddHelpLabel(-1, HELP_CATEGORY_ADMINTOGGLE, "rp_noguns - Enabling this feature bans Guns and Gun Dealers.")

AddToggleCommand("rp_chiefjailpos", "chiefjailpos", 1)
AddHelpLabel(-1, HELP_CATEGORY_ADMINTOGGLE, "rp_chiefjailpos - Allow the Chief to set the jail positions.")

AddToggleCommand("rp_physgun", "physgun", 1)
AddHelpLabel(-1, HELP_CATEGORY_ADMINTOGGLE, "rp_physgun - Enable/disable Players spawning with physguns.")

AddToggleCommand("rp_enableshipments", "enableshipments", 1)
AddHelpLabel(-1, HELP_CATEGORY_ADMINTOGGLE, "rp_enableshipments - Turn /buyshipment on of off.")

AddToggleCommand("rp_enablebuypistol", "enablebuypistol", 1)
AddHelpLabel(-1, HELP_CATEGORY_ADMINTOGGLE, "rp_enablebuypistol - Turn /buy on of off.")

AddToggleCommand("rp_enablemayorsetsalary", "enablemayorsetsalary", 1)
AddHelpLabel(-1, HELP_CATEGORY_ADMINTOGGLE, "rp_enablemayorsetsalary - Enable Mayor salary control.")

AddToggleCommand("rp_customspawns", "customspawns", 1)
AddHelpLabel(-1, HELP_CATEGORY_ADMINTOGGLE, "rp_customspawns - Enable/disable whether custom spawns should be used.")

AddToggleCommand("rp_dm_autokick", "dmautokick", 1)
AddHelpLabel(-1, HELP_CATEGORY_ADMINTOGGLE, "rp_dm_autokick - Enable/disable Auto-kick of deathmatchers.")

AddToggleCommand("rp_norespawn", "norespawn", 1)
AddHelpLabel(-1, HELP_CATEGORY_ADMINTOGGLE, "rp_norespawn - Enable/Disable that people don't have to respawn when they change job.")

AddToggleCommand("rp_advertisements", "advertisements", 1)
AddHelpLabel(-1, HELP_CATEGORY_ADMINTOGGLE, "rp_advertisements - Enable/Disable chatprint advertisements.")

AddToggleCommand("rp_doorwarrants", "doorwarrants", 1)
AddHelpLabel(-1, HELP_CATEGORY_ADMINTOGGLE, "rp_doorwarrants - Enable/disable Warrant requirement to enter property.")

AddToggleCommand("rp_restrictallteams", "restrictallteams", 0)
AddHelpLabel(-1, HELP_CATEGORY_ADMINTOGGLE, "rp_restrictallteams - Enable/disable Players can only be citizen until an admin allows them.")

AddToggleCommand("rp_pocket", "pocket", 1)
AddHelpLabel(-1, HELP_CATEGORY_ADMINTOGGLE, "rp_pocket - Enable/disable pocket swep.")

AddToggleCommand("rp_voiceradius", "voiceradius", 0)
AddHelpLabel(-1, HELP_CATEGORY_ADMINTOGGLE, "rp_voiceradius - Enable/disable local voice chat.")

AddToggleCommand("rp_teletojail", "teletojail", 1)
AddHelpLabel(-1, HELP_CATEGORY_ADMINTOGGLE, "rp_teletojail - Enable/disable teleporting to jail.")

AddToggleCommand("rp_telefromjail", "telefromjail", 1)
AddHelpLabel(-1, HELP_CATEGORY_ADMINTOGGLE, "rp_telefromjail - Enable/disable teleporting from jail.")

AddToggleCommand("rp_logging", "logging", 1, true)
AddHelpLabel(-1, HELP_CATEGORY_ADMINTOGGLE, "rp_logging - Enable/disable logging everything that happens.")

AddToggleCommand("rp_restrictdrop", "RestrictDrop", 0)
AddHelpLabel(-1, HELP_CATEGORY_ADMINTOGGLE, "rp_RestrictDrop - Enable/disable restricting which weapons players can drop.")

AddToggleCommand("rp_ironshoot", "ironshoot", 1)
AddHelpLabel(-1, HELP_CATEGORY_ADMINTOGGLE, "rp_ironshoot - Enable/disable whether people need iron sights to shoot.")

AddToggleCommand("rp_dropmoneyondeath", "dropmoneyondeath", 0)
AddHelpLabel(-1, HELP_CATEGORY_ADMINTOGGLE, "rp_dropmoneyondeath - Enable/disable whether people drop money on death.")

AddToggleCommand("rp_allowswitchjob", "allowjobswitch", 1)
AddHelpLabel(-1, HELP_CATEGORY_ADMINTOGGLE, "rp_allowswitchjob - Enable/disable whether people can switch eachother's jobs.")

AddToggleCommand("rp_dropweaponondeath", "dropweapondeath", 0)
AddHelpLabel(-1, HELP_CATEGORY_ADMINTOGGLE, "rp_dropweaponondeath - Enable/disable whether people drop their current weapon when they die.")

AddToggleCommand("rp_droppocketondeath", "droppocketdeath", 1)
AddHelpLabel(-1, HELP_CATEGORY_ADMINTOGGLE, "rp_droppocketondeath - Enable/disable whether people drop the stuff in their pockets when they die.")

AddToggleCommand("rp_droppocketonarrest", "droppocketarrest", 0)
AddHelpLabel(-1, HELP_CATEGORY_ADMINTOGGLE, "rp_droppocketonarrest - Enable/disable whether people drop the stuff in their pockets when they get arrested.")

AddToggleCommand("rp_allowvehicleowning", "allowvehicleowning", 1)
AddHelpLabel(-1, HELP_CATEGORY_ADMINTOGGLE, "rp_allowvehicleowning - Enable/disable whether people can own vehicles.")

AddToggleCommand("rp_deathpov", "deathpov", 1)
AddHelpLabel(-1, HELP_CATEGORY_ADMINTOGGLE, "rp_deathpov - Enable/disable whether people see their death in first person view")

AddToggleCommand("rp_respawninjail", "respawninjail", 1)
AddHelpLabel(-1, HELP_CATEGORY_ADMINTOGGLE, "rp_respawninjail - Enable/disable whether people can respawn in jail when they die")

AddToggleCommand("rp_enablebuyhealth", "enablebuyhealth", 1)
AddHelpLabel(-1, HELP_CATEGORY_ADMINTOGGLE, "rp_enablebuyhealth - Enable/disable buyhealth")

AddToggleCommand("rp_npcarrest", "npcarrest", 1)
AddHelpLabel(-1, HELP_CATEGORY_ADMINTOGGLE, "rp_npcarrest - Enable/disable arresting npc's")

AddToggleCommand("rp_3dvoice", "3dvoice", 1)
AddHelpLabel(-1, HELP_CATEGORY_ADMINTOGGLE, "rp_3dvoice - Enable/disable 3DVoice is enabled")

AddToggleCommand("rp_voiceradius_dynamic", "dynamicvoice", 1)
AddHelpLabel(-1, HELP_CATEGORY_ADMINTOGGLE, "rp_voiceradius_dynamic - Enable/disable whether only people in the same room as you can hear your mic.")

-----------------------------------------------------------
-- VALUE COMMANDS -- 
-----------------------------------------------------------

AddValueCommand("rp_ammopistolcost", "ammopistolcost", 0)
AddHelpLabel(-1, HELP_CATEGORY_ADMINCMD, "rp_ammopistolcost <Number> - Sets the cost of pistol ammo.")

AddValueCommand("rp_ammoriflecost", "ammoriflecost", 60)
AddHelpLabel(-1, HELP_CATEGORY_ADMINCMD, "rp_ammoriflecost <Number> - Sets the cost of rifle ammo.")

AddValueCommand("rp_ammoshotguncost", "ammoshotguncost", 70)
AddHelpLabel(-1, HELP_CATEGORY_ADMINCMD, "rp_ammoshotguncost <Number> - Sets the cost of shotgun ammo.")

AddValueCommand("rp_healthcost", "healthcost", 60)
AddHelpLabel(-1, HELP_CATEGORY_ADMINCMD, "rp_healthcost <Number> - Sets the cost of health.")

AddValueCommand("rp_jailtimer", "jailtimer", 120)
AddHelpLabel(-1, HELP_CATEGORY_ADMINCMD, "rp_jailtimer <Number> - Sets the jailtimer. (in seconds)")

AddValueCommand("rp_maxdrugs", "maxdrugs", 2)
AddHelpLabel(-1, HELP_CATEGORY_ADMINCMD, "rp_maxdrugs <Number> - Sets max drugs.")

AddValueCommand("rp_maxletters", "maxletters", 10)
AddHelpLabel(-1, HELP_CATEGORY_ADMINCMD, "rp_maxletters <Number> - Sets max letters.")

AddValueCommand("rp_babygodtime", "babygodtime", 5)
AddHelpLabel(-1, HELP_CATEGORY_ADMINCMD, "rp_babygodtime <Number> - How long the babygod lasts")

AddValueCommand("rp_doorcost", "doorcost", 30)
AddHelpLabel(-1, HELP_CATEGORY_ADMINCMD, "rp_doorcost <Number> - Sets the cost of a door.")

AddValueCommand("rp_vehiclecost", "vehiclecost", 40)
AddHelpLabel(-1, HELP_CATEGORY_ADMINCMD, "rp_vehiclecost <Number> - Sets the cost of a vehicle (To own it).")

AddValueCommand("rp_microwavefoodcost", "microwavefoodcost", 30)
AddHelpLabel(-1, HELP_CATEGORY_ADMINCMD, "rp_microwavefoodcost <Number> - Sets the sale price of Microwave Food.")

AddValueCommand("rp_maxfoods", "maxfoods", 2)
AddHelpLabel(-1, HELP_CATEGORY_ADMINCMD, "rp_maxfoods <Number> - Sets the max food cartons per Microwave owner.")

AddValueCommand("rp_maxmayorsetsalary", "maxmayorsetsalary", 120)
AddHelpLabel(-1, HELP_CATEGORY_ADMINCMD, "rp_maxmayorsetsalary <Number> - Sets the Max Salary that a Mayor can set for another player.")

AddValueCommand("rp_runspeed", "rspd", 240)
AddHelpLabel(-1, HELP_CATEGORY_ADMINCMD, "rp_runspeed <Number> - Sets the max running speed.")

AddValueCommand("rp_arrestspeed", "aspd", 120)
AddHelpLabel(-1, HELP_CATEGORY_ADMINCMD, "rp_arrestspeed <Number> - Sets the max arrest speed.")

AddValueCommand("rp_walkspeed", "wspd", 160)
AddHelpLabel(-1, HELP_CATEGORY_ADMINCMD, "rp_walkspeed <Number> - Sets the max walking speed.")

AddValueCommand("rp_npckillpay", "npckillpay", 10)
AddHelpLabel(-1, HELP_CATEGORY_ADMINCMD, "rp_npckillpay <Number> - Sets the money given for each NPC kill.")

AddValueCommand("rp_normalsalary", "normalsalary", 45)
AddHelpLabel(-1, HELP_CATEGORY_ADMINCMD, "rp_normalsalary <Number> - Sets the starting salary for newly joined players.")

AddValueCommand("rp_maxnormalsalary", "maxnormalsalary", 90)
AddHelpLabel(-1, HELP_CATEGORY_ADMINCMD, "rp_maxnormalsalary <Number> - Sets the max normal salary.")

AddValueCommand("rp_maxcopsalary", "maxcopsalary", 100)
AddHelpLabel(-1, HELP_CATEGORY_ADMINCMD, "rp_maxcopsalary <Number> - Sets the max salary that the Mayor can give to a CP.")

AddValueCommand("rp_quakechance_1_in", "quakechance", 4000)
AddHelpLabel(-1, HELP_CATEGORY_ADMINCMD, "rp_quakechance_1_in <Number> - Chance of an earthquake happening.")

AddValueCommand("rp_respawntime", "respawntime", 3)
AddHelpLabel(-1, HELP_CATEGORY_ADMINCMD, "rp_respawntime <Number> - Minimum amount of seconds a player has to wait before respawning.")

AddValueCommand("rp_dm_gracetime", "dmgracetime", 30)
AddHelpLabel(-1, HELP_CATEGORY_ADMINCMD, "rp_dm_gracetime <Number> - Number of seconds after killing a player that the killer will be watched for DM.")

AddValueCommand("rp_dm_maxkills", "dmmaxkills", 3)
AddHelpLabel(-1, HELP_CATEGORY_ADMINCMD, "rp_dm_maxkills <Number> - Max number of kills allowed during rp_dm_gracetime to avoid being auto-kicked for DM.")

AddValueCommand("rp_demotetime", "demotetime", 120)
AddHelpLabel(-1, HELP_CATEGORY_ADMINCMD, "rp_demotetime <Number> - Number of seconds before a player can rejoin a team after demotion from that team.")

AddValueCommand("rp_searchtime", "searchtime", 30)
AddHelpLabel(-1, HELP_CATEGORY_ADMINCMD, "rp_searchtime <Number> - Number of seconds for which a search warrant is valid.")

AddValueCommand("rp_wantedtime", "wantedtime", 120)
AddHelpLabel(-1, HELP_CATEGORY_ADMINCMD, "rp_wantedtime <Number> - Number of seconds for which a player is wanted for.")

AddValueCommand("rp_printamount", "mprintamount", 250)
AddHelpLabel(-1, HELP_CATEGORY_ADMINCMD, "rp_printamount <Number> - Value of the money printed by the money printer.")

AddValueCommand("rp_lotterycommitcost", "lotterycommitcost", 50)
AddHelpLabel(-1, HELP_CATEGORY_ADMINCMD, "rp_lotterycommitcost <Number> - How much you pay for entering a lottery")

AddValueCommand("rp_propcost", "propcost", 10)
AddHelpLabel(-1, HELP_CATEGORY_ADMINCMD, "rp_propcost <Number> - How much prop spawning should cost. (prop paying must be enabled for this to have an effect)")

AddValueCommand("rp_pocketitems", "pocketitems", 10)
AddHelpLabel(-1, HELP_CATEGORY_ADMINCMD, "rp_pocketitems <Number> - Sets the amount of objects the pocket can carry")

AddValueCommand("rp_paydelay", "paydelay", 160)
AddHelpLabel(-1, HELP_CATEGORY_ADMINCMD, "rp_paydelay <Number> - Sets how long it takes before people get salary")

AddValueCommand("rp_maxvehicles", "maxvehicles", 5)
AddHelpLabel(-1, HELP_CATEGORY_ADMINCMD, "rp_maxvehicles <Number> - Sets how many vehicles one can buy.")

AddValueCommand("rp_deathfee", "deathfee", 30)
AddHelpLabel(-1, HELP_CATEGORY_ADMINCMD, "rp_deathfee <Number> - the amount of money someone drops when dead.")

AddValueCommand("rp_startinghealth", "startinghealth", 100)
AddHelpLabel(-1, HELP_CATEGORY_ADMINCMD, "rp_startinghealth <Number> - the health when you spawn.")

AddValueCommand("rp_startingmoney", "startingmoney", 500)
AddHelpLabel(-1, HELP_CATEGORY_ADMINCMD, "rp_startingmoney <Number> - your wallet when you join for the first time.")

AddValueCommand("rp_pricecap", "pricecap", 500)
AddHelpLabel(-1, HELP_CATEGORY_ADMINCMD, "rp_pricecap <Number> - The maximum price of items (using /price)")

AddValueCommand("rp_pricemin", "pricemin", 50)
AddHelpLabel(-1, HELP_CATEGORY_ADMINCMD, "rp_pricemin <Number> - The minimum price of items (using /price)")


function AddEntityCommands(name, command, max, price)
	local cmdname = string.gsub(command, " ", "_")
	
	AddToggleCommand("rp_disable"..cmdname, "disable"..cmdname, 0)
	AddHelpLabel(-1, HELP_CATEGORY_ADMINTOGGLE, "rp_disable"..cmdname.." - disable that people can buy the "..name..".")

	AddValueCommand("rp_max"..cmdname, "max"..cmdname, max or 3)
	AddHelpLabel(-1, HELP_CATEGORY_ADMINCMD, "rp_max"..cmdname.." <Number> - Sets how many ".. name .. " one can buy.")
	
	AddValueCommand("rp_"..cmdname.."_price", cmdname.."_price", price or 30)
	AddHelpLabel(-1, HELP_CATEGORY_ADMINCMD, "rp_"..cmdname.."_price <Number> - Sets the price of ".. name .. ".")
end

function AddTeamCommands(CTeam, max)
	local k = 0
	for num,v in pairs(RPExtraTeams) do
		if v.command == CTeam.command then
			k = num
		end
	end
	AddValueCommand("rp_max"..CTeam.command.."s", "max"..CTeam.command.."s", max or 5)
	AddToggleCommand("rp_allow"..CTeam.command, "allow"..CTeam.command, 1, true)
	AddHelpLabel(-1, HELP_CATEGORY_ADMINCMD, "rp_"..CTeam.command.. " [Nick|SteamID|UserID] - Make a player become a "..CTeam.name..".")
	AddHelpLabel(-1, HELP_CATEGORY_ADMINTOGGLE, "rp_allow"..CTeam.command.." - Enable/disable "..CTeam.name)
	AddHelpLabel(-1, HELP_CATEGORY_ADMINCMD, "rp_max"..CTeam.command.."s".." <Number> - Sets max "..CTeam.name.."s.")
	if CLIENT then return end
	
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
			if team.NumPlayers(k) >= GetConVarNumber("max"..CTeam.command.."s") then
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

local function GenerateChatCommandHelp()
	local p = "/"

	AddHelpLabel(1000, HELP_CATEGORY_CHATCMD, p .. "help - Bring up this menu")
	AddHelpLabel(1100, HELP_CATEGORY_CHATCMD, p .. "job <Job Name> - Set a custom job")
	AddHelpLabel(1200, HELP_CATEGORY_CHATCMD, p .. "w <Message> - Whisper a message")
	AddHelpLabel(1300, HELP_CATEGORY_CHATCMD, p .. "y <Message> - Yell a message")
	AddHelpLabel(1350, HELP_CATEGORY_CHATCMD, p .. "g <Message> - Group only message")
	AddHelpLabel(1350, HELP_CATEGORY_CHATCMD, p .. "pm <Person> <Message> - Private message")
	AddHelpLabel(1350, HELP_CATEGORY_CHATCMD, p .. "call <Person> - Private voice chat with someone through the telephone")
	AddHelpLabel(1400, HELP_CATEGORY_CHATCMD, "/Channel <1-100> - Set the channel of the radio", 1)
	AddHelpLabel(1400, HELP_CATEGORY_CHATCMD, "/radio <Message> - Say something through the radio!", 1)
	AddHelpLabel(1400, HELP_CATEGORY_CHATCMD, "/me <Message> - *name* is doing something!", 1)
	AddHelpLabel(1400, HELP_CATEGORY_CHATCMD, "/advert <Message> - Advertise!", 1)
	AddHelpLabel(1400, HELP_CATEGORY_CHATCMD, "/broadcast <Message> - Broadcast a message as mayor!", 1)
	AddHelpLabel(1400, HELP_CATEGORY_CHATCMD, "//, or /a, or /ooc - Out of Character speak", 1)
	AddHelpLabel(1500, HELP_CATEGORY_CHATCMD, "/x to close a help dialog", 1)
	AddHelpLabel(2700, HELP_CATEGORY_CHATCMD, p .. "pm <Name/Partial Name> <Message> - Send another player a PM.")
	AddHelpLabel(2500, HELP_CATEGORY_CHATCMD, "")
	AddHelpLabel(2650, HELP_CATEGORY_CHATCMD, "Letters - Press use key to read a letter.  Look away and press use key again to stop reading a letter.")
	AddHelpLabel(2550, HELP_CATEGORY_CHATCMD, p .. "write <Message> - Write a letter in handwritten font. Use // to go down a line.")
	AddHelpLabel(2600, HELP_CATEGORY_CHATCMD, p .. "type <Message> - Type a letter in computer font.  Use // to go down a line.")
	AddHelpLabel(1450, HELP_CATEGORY_CHATCMD, "")
	AddHelpLabel(1500, HELP_CATEGORY_CHATCMD, p .. "give <Amount> - Give a money amount")
	AddHelpLabel(1600, HELP_CATEGORY_CHATCMD, p .. "moneydrop or "..p.."dropmoney <Amount> - Drop a money amount")
	AddHelpLabel(1650, HELP_CATEGORY_CHATCMD, "")
	AddHelpLabel(1700, HELP_CATEGORY_CHATCMD, p .. "title <Name> - Give a door you own, a title")
	AddHelpLabel(1800, HELP_CATEGORY_CHATCMD, p .. "addowner or ao <Name> - Allow another to player to own your door")
	AddHelpLabel(1825, HELP_CATEGORY_CHATCMD, p .. "removeowner <Name> - Remove an owner from your door")
	AddHelpLabel(2250, HELP_CATEGORY_CHATCMD, "")
	AddHelpLabel(2300, HELP_CATEGORY_CHATCMD, p .. "cr <Message> - Request the CP's assistance")
	AddHelpLabel(2300, HELP_CATEGORY_CHATCMD, p .. "/911 - Call 911 (when you're attacked by a person)")
	AddHelpLabel(2300, HELP_CATEGORY_CHATCMD, p .. "/report - Call 911 for an illegal entity (you have to be looking at an entity)")
end
GenerateChatCommandHelp()

-- concommand help labels
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
AddHelpLabel(-1, HELP_CATEGORY_ADMINCMD, "rp_arrest [Nick|SteamID|UserID] <Length> - Arrest a player for a custom amount of time. If no time is specified, it will default to " .. GetConVarNumber("jailtimer") .. " seconds.")
AddHelpLabel(-1, HELP_CATEGORY_ADMINCMD, "rp_unarrest [Nick|SteamID|UserID] - Unarrest a player.")
AddHelpLabel(-1, HELP_CATEGORY_ADMINCMD, "rp_kickban [Nick|SteamID|UserID] <Length in minutes> - Kick and ban a player.")
AddHelpLabel(-1, HELP_CATEGORY_ADMINCMD, "rp_kick [Nick|SteamID|UserID] <Kick reason> - Kick a player. The reason is optional.")
AddHelpLabel(-1, HELP_CATEGORY_ADMINCMD, "rp_setmoney [Nick|SteamID|UserID] <Amount> - Set a player's money to a specific amount.")
AddHelpLabel(-1, HELP_CATEGORY_ADMINCMD, "rp_setsalary [Nick|SteamID|UserID] <Amount> - Set a player's Roleplay Salary.")
AddHelpLabel(-1, HELP_CATEGORY_ADMINCMD, "rp_setname [Nick|SteamID|UserID] <Name> - Set a player's RP name.")