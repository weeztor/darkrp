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

-- RP Name Overrides

DARKRPVERSION = "2.3.5+"

local meta = FindMetaTable("Player")
meta.SteamName = meta.Name
meta.Name = function(self)
	if CfgVars and CfgVars["allowrpnames"] == 1 then
		return self:GetNWString("rpname")
	else
		return self:SteamName()
	end
end
meta.Nick = meta.Name
meta.GetName = meta.Name
-- End
RPArrestedPlayers = {}

DeriveGamemode("sandbox")
AddCSLuaFile("addshipments.lua")
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_vgui.lua")
AddCSLuaFile("entity.lua")
AddCSLuaFile("cl_scoreboard.lua")
AddCSLuaFile("cl_deathnotice.lua")
AddCSLuaFile("scoreboard/admin_buttons.lua")
AddCSLuaFile("scoreboard/player_frame.lua")
AddCSLuaFile("scoreboard/player_infocard.lua")
AddCSLuaFile("scoreboard/player_row.lua")
AddCSLuaFile("scoreboard/scoreboard.lua")
AddCSLuaFile("scoreboard/vote_button.lua")
AddCSLuaFile("cl_helpvgui.lua")
AddCSLuaFile("showteamtabs.lua")
AddCSLuaFile("sh_commands.lua")

-- Earthquake Mod addon
resource.AddFile("sound/earthquake.mp3")
util.PrecacheSound("earthquake.mp3")
//quakenotify = nil -- When the next quake report comes up
lastmagnitudes = {} -- The magnitudes of the last tremors

DB = {}
LRP = {}
CSFiles = {}


include("help.lua")
include("shared.lua")
include("data.lua")
include("admincc.lua")
include("sh_commands.lua")
include("player.lua")
include("chat.lua")
include("util.lua")
include("votes.lua")
include("questions.lua")
include("admins.lua")
include("entity.lua")
include("addshipments.lua")
include("main.lua")
include("bannedprops.lua")
include("hints.lua")
include("rating.lua")
AddCSLuaFile("SPropProtection/cl_Init.lua")
AddCSLuaFile("SPropProtection/sh_CPPI.lua")
include("SPropProtection/sv_Init.lua")
include("SPropProtection/sh_CPPI.lua")

function includeCS(dir)
	AddCSLuaFile(dir)
	table.insert(CSFiles, dir)
end

local files = file.Find("../gamemodes/DarkRP/gamemode/modules/*.lua")
for k, v in pairs(files) do
	include("modules/" .. v)
end

local function RefreshSettings(RESET)
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
	CfgVars["cpvote"] = 1 --Should people be able to use /votecop?
	CfgVars["mayorvote"] = 1 --Should people be able to use /votemayor?
	CfgVars["enforceplayermodel"] = 1 --Should player models be enforced? (Bans using player models like zombie/combine/etc)
	CfgVars["proppaying"] = 0 --Should players pay for props
	CfgVars["letters"] = 1 --Allow letter writing
	CfgVars["cpvoting"] = 1 --Allow CP voting
	CfgVars["mayorvoting"] = 1 --Allow Mayor voting
	CfgVars["enablemayorsetsalary"] = 1 --Allow the Mayor to decide salaries of other players
	CfgVars["cptomayoronly"] = 0 --Only CPs can do /votemayor
	CfgVars["chiefjailpos"] = 1 -- Can the Chief set the jail positions?
	CfgVars["physgun"] = 1 --Physguns for everybody? 0 = Admins only
	CfgVars["teletojail"] = 1 --Should Criminals Be AUTOMATICALLY Teleported TO jail?
	CfgVars["telefromjail"] = 1 --Should Jailed People be automatically Teleported FROM jail?
	CfgVars["allowgang"] = 1 -- Should Gangs be allowed?
	CfgVars["allowmedics"] = 1 -- Should Medics be allowed?
	CfgVars["allowdealers"] = 1 -- Should Gun Dealers be allowed?
	CfgVars["allowcooks"] = 1 -- Should Cooks be allowed?
	CfgVars["allowhobos"] = 1 -- Disable hobos? :(
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
	CfgVars["removeclassitems"] = 1 -- Remove(example) every gun shipment when the gundealer changes to a medic or something
	CfgVars["enablebuypistol"] = 1 -- People can do /buy
	CfgVars["allowpdchief"] = 1 --Allow the chief
	CfgVars["enableshipments"] = 1 --Enable gun shipments
	CfgVars["lottery"] = 1 -- Enable the lottery
	CfgVars["restrictallteams"] = 0
	CfgVars["AdminsSpawnWithCopWeapons"] = 1
	CfgVars["babygod"] = 0
	CfgVars["needwantedforarrest"] = 0
	CfgVars["voiceradius"] = 0

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
	CfgVars["maxgangsters"] = 3 -- Maximum number of Gangsters
	CfgVars["maxmedics"] = 3 -- Maximum number of Medics
	CfgVars["maxgundealers"] = 2 -- Maximum number of Gun Dealers
	CfgVars["maxcooks"] = 2 -- Maximum number of Cooks
	CfgVars["quakechance"] = 4000 -- Earthquake probability (1 in 4000)
	CfgVars["dmgracetime"] = 30 -- Players have a 30 second grace time by default
	CfgVars["dmmaxkills"] = 3 -- ...in which they can make a maximum of 3 kills
	CfgVars["demotetime"] = 120 -- Amount of time a player is banned from rejoining a team after being demoted
	CfgVars["searchtime"] = 30 -- Amount of time a search warrant is valid for
	CfgVars["respawntime"] = 4 -- Amount of time a player has to wait before respawning
	CfgVars["wantedtime"] = 120 -- Amount of time a player is wanted for
	CfgVars["lotterycommitcost"] = 50
	CfgVars["babygodtime"] = 5
	CfgVars["license"] = 1
	CfgVars["pocket"] = 1
	CfgVars["pocketitems"] = 10

	SetGlobalString("cmdprefix", "/") --Prefix before any chat commands

	if RESET then
		for k,v in pairs(CfgVars) do
			if type(v) == "number" then
				DB.SaveSetting(k, v)
			end
		end
	end
end
RefreshSettings()

-- Strings
CfgVars["mobagenda"] = ""

DB.RetrieveSettings()
if not DB.RetrieveSettings() then
	RefreshSettings(true)
end

DB.RetrieveGlobals()
if not DB.RetrieveGlobals() then
	RefreshGlobals()
end
timer.Simple(10.5, DB.RetrieveGlobals) // for some reason I don't know about the vars reset after 10 seconds...

function ResetAllRPSettings(ply,cmd,args)
	if not ply:IsSuperAdmin() then
		Notify(ply, 1, 4, "You must be a superadmin")
		return
	end
	Notify(ply, 1, 4, "All settings resetted!")
	RefreshSettings(true)
	RefreshGlobals()
end
concommand.Add("rp_ResetAllSettings", ResetAllRPSettings)

timer.Simple(5, function()
	-- Player Priviliges
	ADMIN = 0			-- DarkRP Admin
	MAYOR = 1			-- Can become Mayor without a vote (Uses /mayor)
	CP = 2					-- Can become CP without a vote (Uses /cp)
	TOOL = 3				-- Always spawns with the toolgun
	PHYS = 4				-- Always spawns with the physgun
	PROP = 5			-- Can always spawn props (unless jailed)
end)

function GM:Initialize()
	self.BaseClass:Initialize()
	DB.Init()
end

function ShowSpare1(ply)
	ply:ConCommand("gm_showspare1\n")
end
concommand.Add("gm_spare1", ShowSpare1)

function ShowSpare2(ply)
	ply:ConCommand("gm_showspare2\n")
end
concommand.Add("gm_spare2", ShowSpare2)

function GM:ShowTeam(ply)
	ply:SendLua("KeysMenu(" ..tostring(ply:GetEyeTrace().Entity:IsVehicle()) .. ")")
end

function GM:ShowHelp(ply)
	umsg.Start("ToggleHelp", ply)
	umsg.End()
end

-- Earthquake Mod part
local next_update_time
local tremor = ents.Create("env_physexplosion")
tremor:SetPos(Vector(0,0,0))
tremor:SetKeyValue("radius",9999999999)
tremor:SetKeyValue("spawnflags", 7)
tremor.nodupe = true
tremor:Spawn()

function TremorReport(alert)
	local mag = table.remove(lastmagnitudes, 1)
	if mag then
		local alert = "Earthquake"
		if mag < 6.5 then
			alert = "Earth Tremor"
		end
		NotifyAll(1, 3, alert .. " reported of magnitude " .. tostring(mag) .. "Mw")
	end
end

FlammableProps = {"drug", "drug_lab", "food", "gunlab", "letter", "melon", "microwave", "money_printer", "spawned_shipment", "spawned_weapon", "cash_bundle", "prop_physics"}

function IsFlammable(ent)
        local class = ent:GetClass()
        for k, v in pairs(FlammableProps) do
            if class == v then return true end
        end
        return false
end

-- FireSpread from SeriousRP
function FireSpread(e)
	if e:IsOnFire() then
		if e:GetTable().MoneyBag then
			e:Remove()
		end
		local en = ents.FindInSphere(e:GetPos(), math.random(20, 90))
		local maxcount = 3
		local count = 1
		local rand = 0
		for k, v in pairs(en) do
			if IsFlammable(v) then
			if count >= maxcount then break end
				if math.random(0.0, 60000.0) < 1.0 then
					if not v.burned then
						v:Ignite(math.random(5,180), 0)
						v.burned = true
					else
						local r, g, b, a = v:GetColor()
						if (r - 51)>=0 then r = r - 51 end
						if (g - 51)>=0 then g = g - 51 end
						if (b - 51)>=0 then b = b - 51 end
						v:SetColor(r, g, b, a)
						math.randomseed((r / (g+1)) + b)
						if (r + g + b) < 103 and math.random(1, 100) < 35 then
							v:Fire("enablemotion","",0)
							constraint.RemoveAll(v)
						end
					end
					count = count + 1
				end
			end
		end
	end
end


function GM:Think()
	for k, v in ipairs(FlammableProps) do
		local ens = ents.FindByClass(v)

		for a, b in pairs(ens) do
			FireSpread(b)
		end
	end
	-- End Spreadable fire Mod
end

function GM:GetFallDamage( ply, flFallSpeed )
	if GetConVarNumber("mp_falldamage") == 1 then
		return flFallSpeed / 8
	end
	return 10
end

GM.Name = "DarkRP "..DARKRPVERSION
GM.Author = "By Rickster, Updated: Pcwizdan, Sibre, philxyz, [GNC] Matt, Chrome Bolt, FPtje Falco"
