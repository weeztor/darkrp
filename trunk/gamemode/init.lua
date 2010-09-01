GM.Name = "DarkRP 2.4.1"
GM.Author = "By Rickster, Updated: Pcwizdan, Sibre, philxyz, [GNC] Matt, Chrome Bolt, FPtje Falco, Eusion"

CUR = "$"

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
	if not ValidEntity(self) then return "" end
	if GetConVarNumber("allowrpnames") == 1 then
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
AddCSLuaFile("help.lua")
AddCSLuaFile("sh_animations.lua")

-- Earthquake Mod addon
resource.AddFile("sound/earthquake.mp3")
util.PrecacheSound("earthquake.mp3")


DB = {}

-- sv_alltalk must be 0
-- note, everyone will STILL hear everyone UNLESS rp_voiceradius is 1!!!
-- This will fix the rp_voiceradius not working
game.ConsoleCommand("sv_alltalk 0\n")

include("_MySQL.lua")
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
include("rating.lua")
include("sh_animations.lua")


--Falco's prop protection
local BlockedModelsExist = sql.QueryValue("SELECT COUNT(*) FROM FPP_BLOCKEDMODELS;") ~= false
if not BlockedModelsExist then
	sql.Query("CREATE TABLE IF NOT EXISTS FPP_BLOCKEDMODELS('model' TEXT NOT NULL PRIMARY KEY);")
	include("FPP/FPP_DefaultBlockedModels.lua") -- Load the default blocked models
end
AddCSLuaFile("FPP/sh_CPPI.lua")
AddCSLuaFile("FPP/sh_settings.lua")
AddCSLuaFile("FPP/client/FPP_Menu.lua")
AddCSLuaFile("FPP/client/FPP_HUD.lua")
AddCSLuaFile("FPP/client/FPP_Buddies.lua")

include("FPP/sh_settings.lua")
include("FPP/sh_CPPI.lua")
include("FPP/server/FPP_Settings.lua")
include("FPP/server/FPP_Core.lua")
include("FPP/server/FPP_Antispam.lua")

local files = file.Find("../gamemodes/"..GM.FolderName.."/gamemode/modules/*.lua")
for k, v in pairs(files) do
	include("modules/" .. v)
end

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

local function GetAvailableVehicles(ply)
	if not ply:IsAdmin() then return end
	ServerLog("Available vehicles for custom vehicles:")
	print("Available vehicles for custom vehicles:")
	for k,v in pairs(list.Get("Vehicles")) do
		ServerLog("\""..k.."\"")
		print("\""..k.."\"")
	end
end
concommand.Add("rp_getvehicles_sv", GetAvailableVehicles)

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