GM.Name = "DarkRP 2.4.1"
GM.Author = "By Rickster, Updated: Pcwizdan, Sibre, philxyz, [GNC] Matt, Chrome Bolt, FPtje Falco"

CUR = "$"
GlobalInts = {}
CfgVars = {}

--Overriding garryfunctions to fix the global ints
local oldGetGlobalInt = GetGlobalInt
function GetGlobalInt(id)
	if GlobalInts[id] then
		if oldGetGlobalInt(id) ~= GlobalInts[id] then
			SetGlobalInt(id, GlobalInts[id])
		end
		return GlobalInts[id]
	else
		return oldGetGlobalInt(id)
	end
end

local OldSetGlobalInt = SetGlobalInt

function SetGlobalInt(id, int)
	GlobalInts[id] = int
	OldSetGlobalInt(id, int)
	for k, ply in pairs(player.GetAll()) do
		if v ~= 0 then
			umsg.Start("FRecieveGlobalInt", ply)
				umsg.Long(int)
				umsg.String(id)
			umsg.End()
		else
			GlobalInts[k] = nil
		end
	end
end

function SendGlobalIntsOnSpawn(ply)
	for k,v in pairs(GlobalInts) do
		if v ~= 0 then
			umsg.Start("FRecieveGlobalInt", ply)
				umsg.Long(v)
				umsg.String(k)
			umsg.End()
		else
			GlobalInts[k] = nil
		end
	end
end
hook.Add("PlayerInitialSpawn", "SendGlobalIntsOnSpawn", SendGlobalIntsOnSpawn)
-- end of overriding SetGlobalInt...

--Checking if counterstrike is installed correctly
local foundCSS = false
for k,v in pairs(GetMountedContent()) do
	if v == "cstrike" then
		foundCSS = true
		break
	end
end

if not foundCSS then
	timer.Create("TheresNoCSS", 10, 0, function()
		for k,v in pairs(player.GetAll()) do
			v:ChatPrint("Counter:Strike Source is incorrectly installed!")
			v:ChatPrint("You need it for DarkRP to work!")
			print("Counter:Strike Source is incorrectly installed!\nYou need it for DarkRP to work!")
		end
	end)
end

-- RP Name Overrides

local meta = FindMetaTable("Player")
meta.SteamName = meta.Name
meta.Name = function(self)
	if CfgVars and CfgVars["allowrpnames"] == 1 then
		self.DarkRPVars = self.DarkRPVars or {}
		return self.DarkRPVars.rpname or self:SteamName()
	else
		return self:SteamName()
	end
end
meta.Nick = meta.Name
meta.GetName = meta.Name
-- End

RPArrestedPlayers = {}

DeriveGamemode("sandbox")
AddCSLuaFile("language_sh.lua")
AddCSLuaFile("MakeThings.lua")
AddCSLuaFile("addentities.lua")
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_vgui.lua")
AddCSLuaFile("entity.lua")
AddCSLuaFile("cl_scoreboard.lua")
AddCSLuaFile("scoreboard/admin_buttons.lua")
AddCSLuaFile("scoreboard/player_frame.lua")
AddCSLuaFile("scoreboard/player_infocard.lua")
AddCSLuaFile("scoreboard/player_row.lua")
AddCSLuaFile("scoreboard/scoreboard.lua")
AddCSLuaFile("scoreboard/vote_button.lua")
AddCSLuaFile("cl_helpvgui.lua")
AddCSLuaFile("showteamtabs.lua")
AddCSLuaFile("sh_commands.lua")
AddCSLuaFile("DRPDermaSkin.lua")

-- Earthquake Mod addon
resource.AddFile("sound/earthquake.mp3")
util.PrecacheSound("earthquake.mp3")


DB = {}

-- sv_alltalk must be 0
-- note, everyone will STILL hear everyone UNLESS rp_voiceradius is 1!!!
-- This will fix the rp_voiceradius not working
game.ConsoleCommand("sv_alltalk 0\n")

include("language_sh.lua")
include("MakeThings.lua")
include("shared.lua")
include("help.lua")
include("admins.lua")
include("data.lua")
include("admincc.lua")
include("sh_commands.lua")
include("chat.lua")
include("player.lua")
include("sv_gamemode_functions.lua")
include("util.lua")
include("votes.lua")
include("questions.lua")
include("entity.lua")
include("addentities.lua")
include("main.lua")
include("bannedprops.lua")
include("rating.lua")


--Falco's prop protection

AddCSLuaFile("FPP/sh_CPPI.lua")
AddCSLuaFile("FPP/client/FPP_Menu.lua")
AddCSLuaFile("FPP/client/FPP_HUD.lua")
AddCSLuaFile("FPP/client/FPP_Buddies.lua")

include("FPP/sh_CPPI.lua")
include("FPP/server/FPP_Settings.lua")
include("FPP/server/FPP_Core.lua")
include("FPP/server/FPP_Antispam.lua")

local files = file.Find("../gamemodes/DarkRP/gamemode/modules/*.lua")
for k, v in pairs(files) do
	include("modules/" .. v)
end

function RefreshRPSettings(RESET)
	-- DO NOT TOUCH THIS! JUST SET THE RP SETTING IN GAME AND IT WILL SAVE AUTOMATICALLY! IF IT DOESNT SAVE AUTOMATICALLY DO rp_savechanges IN CONSOLE!
	CfgVars["ooc"] = 1 --OOC allowed
	CfgVars["allowrpnames"] = 1 --RP Name changing allowed?
	CfgVars["crosshair"] = 1 --Crosshairs enabled?
	CfgVars["strictsuicide"] = 0 --Should players respawn where they suicided (regardless of they're arrested or not)
	CfgVars["propertytax"] = 0 --Property taxes
	CfgVars["cit_propertytax"] = 0 --Just citizens have to pay property tax?
	CfgVars["banprops"] = 1 --Prop banning
	CfgVars["toolgun"] = 0 --Tool gun enabled?
	CfgVars["allowedprops"] = 0 --Should players be only able to spawn "allowed" props?
	CfgVars["propspawning"] = 1 --Prop spawning enabled?
	CfgVars["adminsents"] = 1 --Should all SENTs be admin only?
	CfgVars["adminsweps"] = 1 --Should all sweps be admin only?
	CfgVars["enforceplayermodel"] = 1 --Should player models be enforced? (Bans using player models like zombie/combine/etc)
	CfgVars["proppaying"] = 0 --Should players pay for props
	CfgVars["letters"] = 1 --Allow letter writing
	CfgVars["enablemayorsetsalary"] = 1 --Allow the Mayor to decide salaries of other players
	CfgVars["chiefjailpos"] = 1 -- Can the Chief set the jail positions?
	CfgVars["physgun"] = 1 --Physguns for everybody? 0 = Admins only
	CfgVars["teletojail"] = 1 --Should Criminals Be AUTOMATICALLY Teleported TO jail?
	CfgVars["telefromjail"] = 1 --Should Jailed People be automatically Teleported FROM jail?
	CfgVars["customspawns"] = 1 -- Custom spawn points enabled?
	CfgVars["earthquakes"] = 1 -- Should earthquakes be enabled?
	CfgVars["dmautokick"] = 1 -- Enable deathmatch auto-kick
	CfgVars["doorwarrants"] = 1 -- Whether or not CPs require a warrant to smash in a door
	CfgVars["allowvnocollide"] = 0 -- Whether or not to allow players to no-collide their vehicles (security)
	CfgVars["restrictbuypistol"] = 0 -- Whether /buy is available only to Gun Dealers (if one or more)
	CfgVars["noguns"] = 0 -- Whether or not guns are banned on this server
	CfgVars["customjobs"] = 1 -- Whether or not players can use the /job command
	CfgVars["deathblack"] = 1 -- Whether or not players see black when dead
	CfgVars["norespawn"] = 1 -- Whether people have to respawn when they change job or not
	CfgVars["advertisements"] = 1--chatprint advertisements
	CfgVars["copscanunfreeze"] = 1  -- Cops can unfreeze props with the battering ram
	CfgVars["copscanunweld"] = 0  -- Cops can unweld props with the battering ram
	CfgVars["removeclassitems"] = 1 -- Remove(example) every gun shipment when the gundealer changes to a medic or something
	CfgVars["enablebuypistol"] = 1 -- People can do /buy
	CfgVars["enableshipments"] = 1 --Enable gun shipments
	CfgVars["lottery"] = 1 -- Enable the lottery
	CfgVars["restrictallteams"] = 0
	CfgVars["AdminsSpawnWithCopWeapons"] = 1
	CfgVars["babygod"] = 0
	CfgVars["needwantedforarrest"] = 0
	CfgVars["voiceradius"] = 0
	CfgVars["license"] = 1
	CfgVars["pocket"] = 1
	CfgVars["logging"] = 1
	CfgVars["ironshoot"] = 1
	CfgVars["dropmoneyondeath"] = 0
	CfgVars["allowjobswitch"] = 1
	CfgVars["droppocketdeath"] = 1
	CfgVars["allowvehicleowning"] = 1

	-- You can set the exact value of the below items:

	CfgVars["aspd"] = 120 -- Arrested speed
	CfgVars["rspd"] = 230 -- Run Speed
	CfgVars["wspd"] = 155 -- Walk Speed
	CfgVars["doorcost"] = 30 -- Cost to buy a door.
	CfgVars["vehiclecost"] = 40 -- Car/Airboat Cost
	CfgVars["npckillpay"] = 10 -- Amount paid for killing a non-player character
	CfgVars["maxnormalsalary"] = 150 -- Maximum Normal Salary
	CfgVars["maxmayorsetsalary"] = 120 -- Max salary that a mayor can set for another player
	CfgVars["paydelay"] = 160 -- Pay day delay (in seconds)
	CfgVars["maxcps"] = 4 -- Max number of CPs you can have
	CfgVars["propcost"] = 10 -- Prop cost
	CfgVars["maxdruglabs"] = 1 -- Maximum drug labs per player
	CfgVars["maxdrugs"] = 2 -- Maximum drug bottles per druglab owner
	CfgVars["maxmicrowaves"] = 1 -- Maximum microwave ovens per player
	CfgVars["maxfoods"] = 2 -- Maximum food cartons per microwave owner
	CfgVars["maxgunlabs"] = 1 -- Maximum gun labs per player
	CfgVars["maxmprinters"] = 2 -- Maximum money printers per player
	CfgVars["maxletters"] = 4 -- Maximum number of letters per player
	CfgVars["quakechance"] = 4000 -- Earthquake probability (1 in 4000)
	CfgVars["dmgracetime"] = 30 -- Players have a 30 second grace time by default
	CfgVars["dmmaxkills"] = 3 -- ...in which they can make a maximum of 3 kills
	CfgVars["demotetime"] = 120 -- Amount of time a player is banned from rejoining a team after being demoted
	CfgVars["searchtime"] = 30 -- Amount of time a search warrant is valid for
	CfgVars["respawntime"] = 4 -- Amount of time a player has to wait before respawning
	CfgVars["wantedtime"] = 120 -- Amount of time a player is wanted for
	CfgVars["lotterycommitcost"] = 50
	CfgVars["babygodtime"] = 5
	CfgVars["pocketitems"] = 10
	CfgVars["maxvehicles"] = 5
	CfgVars["deathfee"] = 30
	CfgVars["startinghealth"] = 100
	CfgVars["startingmoney"] = 500
	CfgVars["mobagenda"] = ""

	if RESET then
		for k,v in pairs(CfgVars) do
			if type(v) == "number" then
				DB.SaveSetting(k, v)
			end
		end
	end
	
	for k,v in pairs(CfgVars) do 
		SetGlobalInt(k, v)
	end
end
RefreshRPSettings()

local function RPVersion(ply)
	local FindGameModes = file.FindDir("../gamemodes/*")
	for _, folder in pairs(FindGameModes) do
		local info_txt = file.Read("../gamemodes/"..folder.."/info.txt")
		if not info_txt then info_txt = "" end
		
		local Gamemode = util.KeyValuesToTable(info_txt)
		if Gamemode.name and string.lower(Gamemode.name) == "darkrp" then 
			local version = Gamemode.version
			local SVN = " non-SVN version"
			
			local entries = file.Read("../gamemodes/"..folder.."/.svn/entries")
			if entries then
				local _, dirFind = string.find(entries, "dir")
				SVN = " revision " .. string.sub(entries, dirFind + 2, dirFind + 4)
			end
			TalkToPerson(ply, Color(0,0,255,255), "This server is running "..folder, Color(1,255, 1), version .. SVN, ply)
			break
		end
	end
end
concommand.Add("rp_version", RPVersion)

-- Vehicle fix from tobba!
function debug.getupvalues(f)
	local t, i, k, v = {}, 1, debug.getupvalue(f, 1)
	while k do
		t[k] = v
		i = i+1
		k,v = debug.getupvalue(f, i)
	end
	return t
end

glon.encode_types = debug.getupvalues(glon.Write).encode_types
glon.encode_types["Vehicle"] = glon.encode_types["Vehicle"] or {10, function(o)
		return (ValidEntity(o) and o:EntIndex() or -1).."\1"
	end}