GM.Version = "2.4.2"
GM.Name = "DarkRP "..GM.Version
GM.Author = "By Rickster, Updated: Pcwizdan, Sibre, philxyz, [GNC] Matt, Chrome Bolt, FPtje Falco, Eusion"

require("datastream")

DeriveGamemode("sandbox")
util.PrecacheSound("earthquake.mp3")

CUR = "$"

HelpLabels = { }
HelpCategories = { }

-- Make sure the client sees the RP name where they expect to see the name
local pmeta = FindMetaTable("Player")

pmeta.SteamName = pmeta.Name
function pmeta:Name()
	if not self or not self.IsValid or not ValidEntity(self) then return "" end
	
	self.DarkRPVars = self.DarkRPVars or {}
	if GetConVarNumber("allowrpnames") == 0 then
		return self:SteamName()
	end
	return self.DarkRPVars.rpname or self:SteamName()
end

pmeta.GetName = pmeta.Name
pmeta.Nick = pmeta.Name
-- End

local ENT = FindMetaTable("Entity")
ENT.OldIsVehicle = ENT.IsVehicle

function ENT:IsVehicle()
	if type(self) ~= "Entity" then return false end
	local class = string.lower(self:GetClass())
	return ENT:OldIsVehicle() or string.find(class, "vehicle") 
	-- Ent:IsVehicle() doesn't work correctly clientside:
	/*	
		] lua_run_cl print(LocalPlayer():GetEyeTrace().Entity)
		> 		Entity [128][prop_vehicle_jeep_old]
		] lua_run_cl print(LocalPlayer():GetEyeTrace().Entity:IsVehicle())
		> 		false
	*/
end

function GM:DrawDeathNotice(x, y)
	if GetConVarNumber("deathnotice") ~= 1 then return end
	self.BaseClass:DrawDeathNotice(x, y)
end

local function DisplayNotify(msg)
	local txt = msg:ReadString()
	GAMEMODE:AddNotify(txt, msg:ReadShort(), msg:ReadLong())
	surface.PlaySound("buttons/lightswitch2.wav")

	-- Log to client console
	print(txt)
end
usermessage.Hook("_Notify", DisplayNotify)

local function LoadModules(msg)
	local num = msg:ReadShort()

	for n = 1, num do
		include(GAMEMODE.FolderName.."/gamemode/modules/" .. msg:ReadString())
	end
end
usermessage.Hook("LoadModules", LoadModules)

LocalPlayer().DarkRPVars = LocalPlayer().DarkRPVars or {}
for k,v in pairs(player.GetAll()) do
	v.DarkRPVars = v.DarkRPVars or {}
end

include("help.lua")
include("language_sh.lua")
include("MakeThings.lua")
include("cl_vgui.lua")
include("entity.lua")
include("cl_helpvgui.lua")
include("showteamtabs.lua")
include("DRPDermaSkin.lua")
include("sh_animations.lua")
include("cl_hud.lua")
include("Workarounds.lua")

include("FPP/sh_settings.lua")
include("FPP/client/FPP_Menu.lua")
include("FPP/client/FPP_HUD.lua")
include("FPP/client/FPP_Buddies.lua")
include("FPP/sh_CPPI.lua")

surface.CreateFont("akbar", 20, 500, true, false, "AckBarWriting")

-- Copy from FESP(made by FPtje Falco)
-- This is no stealing since I made FESP myself.
local vector = FindMetaTable("Vector")
function vector:RPIsInSight(v, ply)
	ply = ply or LocalPlayer()
	local trace = {}
	trace.start = ply:EyePos()
	trace.endpos = self	
	trace.filter = v
	trace.mask = -1
	local TheTrace = util.TraceLine(trace)
	if TheTrace.Hit then
		return false, TheTrace.HitPos
	else
		return true, TheTrace.HitPos
	end
end

function GM:HUDShouldDraw(name)
	if name == "CHudHealth" or
		name == "CHudBattery" or
		name == "CHudSuitPower" or
		(HelpToggled and name == "CHudChat") then
			return false
	else
		return true
	end
end

function GM:HUDDrawTargetID()
    return false
end

function FindPlayer(info)
	local pls = player.GetAll()

	-- Find by Index Number (status in console)
	for k, v in pairs(pls) do
		if tonumber(info) == v:UserID() then
			return v
		end
	end

	-- Find by RP Name
	for k, v in pairs(pls) do
		if string.find(string.lower(v.DarkRPVars.rpname or ""), string.lower(tostring(info))) ~= nil then
			return v
		end
	end

	-- Find by Partial Nick
	for k, v in pairs(pls) do
		if string.find(string.lower(v:Name()), string.lower(tostring(info))) ~= nil then
			return v
		end
	end
	return nil
end

local GUIToggled = false
local HelpToggled = false

local HelpVGUI
local function ToggleHelp()
	if not HelpVGUI then
		HelpVGUI = vgui.Create("HelpVGUI")
	end

	HelpToggled = not HelpToggled

	HelpVGUI.HelpX = HelpVGUI.StartHelpX
	HelpVGUI:SetVisible(HelpToggled)
	gui.EnableScreenClicker(HelpToggled)
end
usermessage.Hook("ToggleHelp", ToggleHelp)

local function ToggleClicker()
	GUIToggled = not GUIToggled
	gui.EnableScreenClicker(GUIToggled)
end
usermessage.Hook("ToggleClicker", ToggleClicker)
	
include("sh_commands.lua")
include("shared.lua")
include("addentities.lua")

local function DoSpecialEffects(Type)
	local thetype = string.lower(Type:ReadString())
	local toggle = tobool(Type:ReadString())
	if toggle then
		if thetype == "motionblur" then
			hook.Add("RenderScreenspaceEffects", thetype, function()
				DrawMotionBlur(0.05, 1.00, 0.035)
			end)
		elseif thetype == "dof" then
			DOF_SPACING = 8
			DOF_OFFSET = 9
			DOF_Start()
		elseif thetype == "colormod" then
			hook.Add("RenderScreenspaceEffects", thetype, function()
				local settings = {}
				settings[ "$pp_colour_addr" ] = 0
			 	settings[ "$pp_colour_addg" ] = 0 
			 	settings[ "$pp_colour_addb" ] = 0 
			 	settings[ "$pp_colour_brightness" ] = -1
			 	settings[ "$pp_colour_contrast" ] = 0
			 	settings[ "$pp_colour_colour" ] =0
			 	settings[ "$pp_colour_mulr" ] = 0
			 	settings[ "$pp_colour_mulg" ] = 0
			 	settings[ "$pp_colour_mulb" ] = 0
				DrawColorModify(settings)
			end)
		elseif thetype == "drugged" then
			hook.Add("RenderScreenspaceEffects", thetype, function()
				DrawSharpen(-1, 2)
				DrawMaterialOverlay("models/props_lab/Tank_Glass001", 0)
				DrawMotionBlur(0.13, 1, 0.00)
			end)
		elseif thetype == "deathpov" then
			hook.Add("CalcView", "rp_deathPOV", function(ply, origin, angles, fov)
				local Ragdoll = ply:GetRagdollEntity()
				if not ValidEntity(Ragdoll) then return end
				
				local head = Ragdoll:LookupAttachment("eyes")
				head = Ragdoll:GetAttachment(head)
				if not head or not head.Pos then return end

				local view = {}
				view.origin = head.Pos
				view.angles = head.Ang
				view.fov = fov
				return view
			end)
		end
	elseif toggle == false then
		if thetype == "dof" then
			DOF_Kill()
			return
		elseif thetype == "deathpov" then
			if hook.GetTable().CalcView and hook.GetTable().CalcView.rp_deathPOV then 
				hook.Remove("CalcView", "rp_deathPOV")
			end
			return
		end
		hook.Remove("RenderScreenspaceEffects", thetype)
	end
end
usermessage.Hook("DarkRPEffects", DoSpecialEffects)

local Messagemode = false
local playercolors = {}
local HearMode = "talk"
local isSpeaking = false

local function RPStopMessageMode()
	Messagemode = false
	hook.Remove("Think", "RPGetRecipients")
	hook.Remove("HUDPaint", "RPinstructionsOnSayColors")
	playercolors = {}
end

local function CL_IsInRoom(listener) -- IsInRoom function to see if the player is in the same room.
	local tracedata = {}
	tracedata.start = LocalPlayer():GetShootPos()
	tracedata.endpos = listener:GetShootPos()
	local trace = util.TraceLine( tracedata )
	
	return not trace.HitWorld
end

local PlayerColorsOn = CreateClientConVar("rp_showchatcolors", 1, true, false)
local function RPSelectwhohearit()
	if PlayerColorsOn:GetInt() == 0 then return end
	Messagemode = true
	
	hook.Add("HUDPaint", "RPinstructionsOnSayColors", function()
		local w, l = ScrW()/80, ScrH() /1.75
		local h = l - (#playercolors * 20) - 20
		local AllTalk = GetConVarNumber("alltalk") == 1
		if #playercolors <= 0 and ((HearMode ~= "talk through OOC" and HearMode ~= "advert" and not AllTalk) or (AllTalk and HearMode ~= "talk" and HearMode ~= "me") or HearMode == "speak" ) then
			draw.WordBox(2, w, h, string.format(LANGUAGE.hear_noone, HearMode), "ScoreboardText", Color(0,0,0,120), Color(255,0,0,255))
		elseif HearMode == "talk through OOC" or HearMode == "advert" then
			draw.WordBox(2, w, h, LANGUAGE.hear_everyone, "ScoreboardText", Color(0,0,0,120), Color(0,255,0,255))
		elseif not AllTalk or (AllTalk and HearMode ~= "talk" and HearMode ~= "me") then
			draw.WordBox(2, w, h, string.format(LANGUAGE.hear_certain_persons, HearMode), "ScoreboardText", Color(0,0,0,120), Color(0,255,0,255))
		end
		
		for k,v in pairs(playercolors) do
			if v.Nick then
				draw.WordBox(2, w, h + k*20, v:Nick(), "ScoreboardText", Color(0,0,0,120), Color(255,255,255,255))
			end
		end
	end)
	
	hook.Add("Think", "RPGetRecipients", function() 
		if not Messagemode then RPStopMessageMode() hook.Remove("Think", "RPGetRecipients") return end 
		if HearMode ~= "whisper" and HearMode ~= "yell" and HearMode ~= "talk" and HearMode ~= "speak" and HearMode ~= "me" then return end
		playercolors = {}
		for k,v in pairs(player.GetAll()) do
			if v ~= LocalPlayer() then
				local distance = LocalPlayer():GetPos():Distance(v:GetPos())
				if HearMode == "whisper" and distance < 90 and not table.HasValue(playercolors, v) then
					table.insert(playercolors, v)
				elseif HearMode == "yell" and distance < 550 and not table.HasValue(playercolors, v) then
					table.insert(playercolors, v)
				elseif HearMode == "speak" and distance < 550 and not table.HasValue(playercolors, v) then
					if GetConVarNumber("dynamicvoice") == 1 then
						if CL_IsInRoom( v ) then
							table.insert(playercolors, v)
						end
					else
						table.insert(playercolors, v)
					end
				elseif HearMode == "talk" and GetConVarNumber("alltalk") ~= 1 and distance < 250 and not table.HasValue(playercolors, v) then
					table.insert(playercolors, v)
				elseif HearMode == "me" and GetConVarNumber("alltalk") ~= 1 and distance < 250 and not table.HasValue(playercolors, v) then
					table.insert(playercolors, v)
				end
			end
		end
	end)
end
hook.Add("StartChat", "RPDoSomethingWithChat", RPSelectwhohearit)
hook.Add("FinishChat", "RPCloseRadiusDetection", function() 
	if not isSpeaking then 
		Messagemode = false
		RPStopMessageMode() 
	else
		HearMode = "speak" 
	end
end)

function GM:ChatTextChanged(text)
	if PlayerColorsOn:GetInt() == 0 then return end
	if not Messagemode or HearMode == "speak" then return end
	local old = HearMode
	HearMode = "talk"
	if GetConVarNumber("alltalk") == 0 then
		if string.sub(text, 1, 2) == "//" or string.sub(string.lower(text), 1, 4) == "/ooc" or string.sub(string.lower(text), 1, 4) == "/a" then
			HearMode = "talk through OOC"
		elseif string.sub(string.lower(text), 1, 7) == "/advert" then
			HearMode = "advert"
		end
	end
	
	if string.sub(string.lower(text), 1, 3) == "/pm" then
		local plyname = string.sub(text, 5)
		if string.find(plyname, " ") then
			plyname = string.sub(plyname, 1, string.find(plyname, " ") - 1)
		end
		HearMode = "pm"
		playercolors = {}
		if plyname ~= "" and FindPlayer(plyname) then
			playercolors = {FindPlayer(plyname)}
		end
	elseif string.sub(string.lower(text), 1, 5) == "/call" then
		local plyname = string.sub(text, 7)
		if string.find(plyname, " ") then
			plyname = string.sub(plyname, 1, string.find(plyname, " ") - 1)
		end
		HearMode = "call"
		playercolors = {}
		if plyname ~= "" and FindPlayer(plyname) then
			playercolors = {FindPlayer(plyname)}
		end
	elseif string.sub(string.lower(text), 1, 3) == "/g " then
		HearMode = "group chat"
		local t = LocalPlayer():Team()
		playercolors = {}
		if t == TEAM_POLICE or t == TEAM_CHIEF or t == TEAM_MAYOR then
			for k, v in pairs(player.GetAll()) do
				if v ~= LocalPlayer() then
					local vt = v:Team()
					if vt == TEAM_POLICE or vt == TEAM_CHIEF or vt == TEAM_MAYOR then table.insert(playercolors, v) end
				end
			end
		elseif t == TEAM_MOB or t == TEAM_GANG then
			for k, v in pairs(player.GetAll()) do
				if v ~= LocalPlayer() then
					local vt = v:Team()
					if vt == TEAM_MOB or vt == TEAM_GANG then table.insert(playercolors, v) end
				end
			end
		end
	elseif string.sub(string.lower(text), 1, 3) == "/w " then
		HearMode = "whisper"
	elseif string.sub(string.lower(text), 1, 2) == "/y" then
		HearMode = "yell"
	elseif string.sub(string.lower(text), 1, 3) == "/me" then
		HearMode = "me"
	end
	if old ~= HearMode then
		playercolors = {}
	end
end

function GM:PlayerStartVoice(ply)
	if ply == LocalPlayer() and LocalPlayer().DarkRPVars and ValidEntity(LocalPlayer().DarkRPVars.phone) then
		return
	end
	isSpeaking = true
	LocalPlayer().DarkRPVars = LocalPlayer().DarkRPVars or {}
	if ply == LocalPlayer() and GetConVarNumber("sv_alltalk") == 0 and GetConVarNumber("voiceradius") == 1 and not ValidEntity(LocalPlayer().DarkRPVars.phone) then
		HearMode = "speak"
		RPSelectwhohearit()
	end
	
	if ply == LocalPlayer() then
		ply.DRPIsTalking = true
		return -- Not the original rectangle for yourself! ugh!
	end
	self.BaseClass:PlayerStartVoice(ply)
end

function GM:PlayerEndVoice(ply) //voice/icntlk_pl.vtf
	if LocalPlayer().DarkRPVars and ValidEntity(LocalPlayer().DarkRPVars.phone) then
		ply.DRPIsTalking = false
		timer.Simple(0.2, function() 
			if ValidEntity(LocalPlayer().DarkRPVars.phone) then
				LocalPlayer():ConCommand("+voicerecord") 
			end
		end)
		self.BaseClass:PlayerEndVoice(ply)
		return
	end
	
	isSpeaking = false
	
	if ply == LocalPlayer() and GetConVarNumber("sv_alltalk") == 0 and GetConVarNumber("voiceradius") == 1 then
		HearMode = "talk"
		hook.Remove("Think", "RPGetRecipients")
		hook.Remove("HUDPaint", "RPinstructionsOnSayColors")
		Messagemode = false
		playercolors = {}
	end
	
	if ply == LocalPlayer() then
		ply.DRPIsTalking = false
		return
	end	
	self.BaseClass:PlayerEndVoice(ply)
end

function GM:PlayerBindPress(ply,bind,pressed)
	self.BaseClass:PlayerBindPress(ply, bind, pressed)
	if ply == LocalPlayer() and ValidEntity(ply:GetActiveWeapon()) and string.find(string.lower(bind), "attack2") and ply:GetActiveWeapon():GetClass() == "weapon_bugbait" then
		LocalPlayer():ConCommand("_hobo_emitsound")
	end
	return
end

local function AddToChat(msg)
	local col1 = Color(msg:ReadShort(), msg:ReadShort(), msg:ReadShort())

	local name = msg:ReadString()
	local ply = msg:ReadEntity()
	local col2 = Color(msg:ReadShort(), msg:ReadShort(), msg:ReadShort())

	local text = msg:ReadString()
	if text and text ~= "" then
		chat.AddText(col1, name, col2, ": "..text)
		if ValidEntity(ply) then
			hook.Call("OnPlayerChat", nil, ply, text, false, ply:Alive())
		end
	else
		chat.AddText(col1, name)
		hook.Call("ChatText", nil, "0", name, name, "none")
	end
	chat.PlaySound()
end
usermessage.Hook("DarkRP_Chat", AddToChat)

local function GetAvailableVehicles()
	print("Available vehicles for custom vehicles:")
	for k,v in pairs(list.Get("Vehicles")) do
		print("\""..k.."\"")
	end
end
concommand.Add("rp_getvehicles", GetAvailableVehicles)

local function RetrieveDoorData(handler, id, encoded, decoded)
	-- decoded[1] = Entity you were looking at
	-- Decoded[2] = table of that door
	if not decoded[1] or not decoded[1].IsValid or not ValidEntity(decoded[1]) then return end
	decoded[1].DoorData = decoded[2]
	
	local DoorString = "Data:\n"
	for k,v in pairs(decoded[2]) do
		DoorString = DoorString .. k.."\t\t".. tostring(v) .. "\n"
	end
end
datastream.Hook("DarkRP_DoorData", RetrieveDoorData)

local function UpdateDoorData(um)
	local door = um:ReadEntity()
	if not ValidEntity(door) then return end
	
	local var, value = um:ReadString(), um:ReadString()
	value = tonumber(value) or value
	
	if string.match(tostring(value), "Entity .([0-9]*)") then
		value = Entity(string.match(value, "Entity .([0-9]*)"))
	end
	
	if string.match(tostring(value), "Player .([0-9]*)") then
		value = Entity(string.match(value, "Player .([0-9]*)"))
	end
	
	if value == "true" or value == "false" then value = tobool(value) end
	
	if value == "nil" then value = nil end
	door.DoorData[var] = value
end
usermessage.Hook("DRP_UpdateDoorData", UpdateDoorData)

local function RetrievePlayerVar(um)
	local ply = um:ReadEntity()
	if not ValidEntity(ply) then return end
	
	ply.DarkRPVars = ply.DarkRPVars or {}
	
	local var, value = um:ReadString(), um:ReadString()
	local stringvalue = value
	value = tonumber(value) or value
	
	if string.match(stringvalue, "Entity .([0-9]*)") then
		value = Entity(string.match(stringvalue, "Entity .([0-9]*)"))
	end
	
	if string.match(stringvalue, "(-?[0-9]+\.[0-9]+) (-?[0-9]+\.[0-9]+) (-?[0-9]+\.[0-9]+)") then 
		local x,y,z = string.match(value, "(-?[0-9]+\.[0-9]+) (-?[0-9]+\.[0-9]+) (-?[0-9]+\.[0-9]+)")
		value = Vector(x,y,z)
	end
	
	if stringvalue == "true" or stringvalue == "false" then value = tobool(value) end
	
	if stringvalue == "nil" then value = nil end
	ply.DarkRPVars[var] = value
end
usermessage.Hook("DarkRP_PlayerVar", RetrievePlayerVar)

local function InitializeDarkRPVars(handler, id, encoded, decoded)
	if not decoded then return end
	for ply,vars in pairs(decoded) do
		ply.DarkRPVars = vars
	end
end
datastream.Hook("DarkRP_InitializeVars", InitializeDarkRPVars)
	
function GM:InitPostEntity()
	function VoiceNotify:Init()
		self.LabelName = vgui.Create( "DLabel", self )
		self.Avatar = vgui.Create( "SpawnIcon", self )
	end
	
	function VoiceNotify:Setup(ply)
		self.LabelName:SetText( ply:Nick() )
		self.Avatar:SetModel( ply:GetModel() )
		self.Avatar:SetIconSize(32)
		
		self.Color = team.GetColor( ply:Team() )
		
		self:InvalidateLayout()
	end
	
	RunConsoleCommand("_sendDarkRPvars")
	timer.Create("DarkRPCheckifitcamethrough", 30, 0, function()
		for k,v in pairs(player.GetAll()) do
			v.DarkRPVars = v.DarkRPVars or {}
			if not v.DarkRPVars.job or not v.DarkRPVars.salary or not v.DarkRPVars.money or not v.DarkRPVars.rpname then
				RunConsoleCommand("_sendDarkRPvars")
				break
			end
		end
	end)
end

-- DarkRP plugin for FAdmin. It's this simple to make a plugin. If FAdmin isn't installed, this code won't bother anyone
hook.Add("PostGamemodeLoaded", "FAdmin_DarkRP", function()
	if not FAdmin or not FAdmin.StartHooks then return end
	FAdmin.StartHooks["DarkRP"] = function()
		-- DarkRP information:
		FAdmin.ScoreBoard.Player:AddInformation("Steam name", function(ply) return ply:SteamName() end, true)
		FAdmin.ScoreBoard.Player:AddInformation("Money", function(ply) if LocalPlayer():IsAdmin() and ply.DarkRPVars and ply.DarkRPVars.money then return "$"..ply.DarkRPVars.money end end)
		FAdmin.ScoreBoard.Player:AddInformation("Wanted", function(ply) if ply.DarkRPVars and ply.DarkRPVars.wanted then return tostring(ply.DarkRPVars["wantedReason"] or "N/A") end end)
		
		-- Warrant
		FAdmin.ScoreBoard.Player:AddActionButton("Warrant", "FAdmin/icons/Message",	Color(0, 0, 200, 255), 
			function(ply) local t = LocalPlayer():Team() return t == TEAM_POLICE or t == TEAM_MAYOR or t == TEAM_CHIEF end, 
			function(ply, button)
				Derma_StringRequest("Warrant reason", "Enter the reason for the warrant", "", function(Reason)
					LocalPlayer():ConCommand("say /warrant ".. ply:UserID().." ".. Reason)
				end)
			end)
			
		--wanted
		FAdmin.ScoreBoard.Player:AddActionButton(function(ply)
				return ((ply.DarkRPVars.wanted and "Unw") or "W") .. "anted"
			end, 
			function(ply) return "FAdmin/icons/jail", ply.DarkRPVars.wanted and "FAdmin/icons/disable" end,
			Color(0, 0, 200, 255), 
			function(ply) local t = LocalPlayer():Team() return t == TEAM_POLICE or t == TEAM_MAYOR or t == TEAM_CHIEF end, 
			function(ply, button)
				if ply.DarkRPVars.wanted  then
					Derma_StringRequest("wanted reason", "Enter the reason to arrest this player", "", function(Reason)
						LocalPlayer():ConCommand("say /wanted ".. ply:UserID().." ".. Reason)
					end)
				else
					LocalPlayer():ConCommand("say /unwanted ".. ply:UserID())
				end
			end)
		
		--Teamban
		FAdmin.ScoreBoard.Player:AddActionButton("Ban from job", "FAdmin/icons/changeteam", Color(200, 0, 0, 255), 
		function(ply) return FAdmin.Access.PlayerHasPrivilege(LocalPlayer(), "rp_commands", ply) end, function(ply, button)
			local menu = DermaMenu()
			local Title = vgui.Create("DLabel")
			Title:SetText("  Jobs:\n")
			Title:SetFont("UiBold")
			Title:SizeToContents()
			Title:SetTextColor(color_black)
			
			menu:AddPanel(Title)
			for k,v in SortedPairsByMemberValue(RPExtraTeams, "name") do
				menu:AddOption(v.name, function() RunConsoleCommand("rp_teamban", ply:UserID(), v.command) end)
			end
			menu:Open()
		end)
	end
end)
include("FAdmin_DarkRP.lua")