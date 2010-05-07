GM.Name = "DarkRP 2.4.1"
GM.Author = "Rickster, Updated: Pcwizdan, Sibre, philxyz, [GNC] Matt, Chrome Bolt, FPtje Falco, Eusion"

GlobalInts = {}
require("datastream")

DeriveGamemode("sandbox")
util.PrecacheSound("earthquake.mp3")

CUR = "$"

local GUIToggled = false
local HelpToggled = false

HelpLabels = { }
HelpCategories = { }

local AdminTellAlpha = -1
local AdminTellStartTime = 0
local AdminTellMsg = ""

local StunStickFlashAlpha = -1

-- Make sure the client sees the RP name where they expect to see the name
local pmeta = FindMetaTable("Player")

pmeta.SteamName = pmeta.Name
function pmeta:Name()
	if not ValidEntity(self) then return "" end
	
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
	surface.PlaySound("ambient/water/drip" .. math.random(1, 4) .. ".wav")

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

include("language_sh.lua")
include("MakeThings.lua")
include("cl_vgui.lua")
include("entity.lua")
include("cl_scoreboard.lua")
include("cl_helpvgui.lua")
include("showteamtabs.lua")
include("scoreboard/admin_buttons.lua")
include("scoreboard/player_frame.lua")
include("scoreboard/player_infocard.lua")
include("scoreboard/player_row.lua")
include("scoreboard/scoreboard.lua")
include("scoreboard/vote_button.lua")
include("DRPDermaSkin.lua")

include("FPP/client/FPP_Menu.lua")
include("FPP/client/FPP_HUD.lua")
include("FPP/client/FPP_Buddies.lua")
include("FPP/sh_CPPI.lua")

surface.CreateFont("akbar", 20, 500, true, false, "AckBarWriting")

local function GetTextHeight(font, str)
	surface.SetFont(font)
	local w, h = surface.GetTextSize(str)
	return h
end

local function DrawPlayerInfo(ply)
	if not ply:Alive() then return end

	local pos = ply:EyePos()

	pos.z = pos.z + 34
	pos = pos:ToScreen()

	if GetConVarNumber("nametag") == 1 then
		draw.DrawText(ply:Nick(), "TargetID", pos.x + 1, pos.y + 1, Color(0, 0, 0, 255), 1)
		draw.DrawText(ply:Nick(), "TargetID", pos.x, pos.y, team.GetColor(ply:Team()), 1)
		draw.DrawText(LANGUAGE.health ..ply:Health(), "TargetID", pos.x + 1, pos.y + 21, Color(0, 0, 0, 255), 1)
		draw.DrawText(LANGUAGE.health..ply:Health(), "TargetID", pos.x, pos.y + 20, Color(255,255,255,200), 1)
	end

	if GetConVarNumber("jobtag") == 1 then
		draw.DrawText(ply.DarkRPVars.job or "", "TargetID", pos.x + 1, pos.y + 41, Color(0, 0, 0, 255), 1)
		draw.DrawText(ply.DarkRPVars.job or "", "TargetID", pos.x, pos.y + 40, Color(255, 255, 255, 200), 1)
	end
end


--Copy from FESP(made by FPtje Falco)
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

local function DrawWantedInfo(ply)
	if not ply:Alive() then return end

	local pos = ply:EyePos()
	if not pos:RPIsInSight({LocalPlayer(), ply}) then return end

	pos.z = pos.z + 14
	pos = pos:ToScreen()

	if GetConVarNumber("nametag") == 1 then
		draw.DrawText(ply:Nick(), "TargetID", pos.x + 1, pos.y + 1, Color(0, 0, 0, 255), 1)
		draw.DrawText(ply:Nick(), "TargetID", pos.x, pos.y, team.GetColor(ply:Team()), 1)
	end

	draw.DrawText(LANGUAGE.wanted.."\nReason: "..tostring(ply.DarkRPVars["wantedReason"]), "TargetID", pos.x, pos.y - 40, Color(255, 255, 255, 200), 1)
	draw.DrawText(LANGUAGE.wanted.."\nReason: "..tostring(ply.DarkRPVars["wantedReason"]), "TargetID", pos.x + 1, pos.y - 41, Color(255, 0, 0, 255), 1)
end

local function DrawZombieInfo(ply)
	for x=1, LocalPlayer().DarkRPVars.numPoints, 1 do
		local zPoint = LocalPlayer().DarkRPVars["zPoints".. x]
		zPoint = zPoint:ToScreen()
		draw.DrawText("Zombie Spawn (" .. x .. ")", "TargetID", zPoint.x, zPoint.y - 20, Color(255, 255, 255, 200), 1)
		draw.DrawText("Zombie Spawn (" .. x .. ")", "TargetID", zPoint.x + 1, zPoint.y - 21, Color(255, 0, 0, 255), 1)
	end
end

local backgroundr = CreateClientConVar("backgroundr", 0, true, false)
local backgroundg = CreateClientConVar("backgroundg", 0, true, false)
local backgroundb = CreateClientConVar("backgroundb", 0, true, false)
local backgrounda = CreateClientConVar("backgrounda", 100, true, false)

local Healthbackgroundr = CreateClientConVar("Healthbackgroundr", 0, true, false)
local Healthbackgroundg = CreateClientConVar("Healthbackgroundg", 0, true, false)
local Healthbackgroundb = CreateClientConVar("Healthbackgroundb", 0, true, false)
local Healthbackgrounda = CreateClientConVar("Healthbackgrounda", 200, true, false)

local Healthforegroundr = CreateClientConVar("Healthforegroundr", 140, true, false)
local Healthforegroundg = CreateClientConVar("Healthforegroundg", 0, true, false)
local Healthforegroundb = CreateClientConVar("Healthforegroundb", 0, true, false)
local Healthforegrounda = CreateClientConVar("Healthforegrounda", 180, true, false)

local HealthTextr = CreateClientConVar("HealthTextr", 255, true, false)
local HealthTextg = CreateClientConVar("HealthTextg", 255, true, false)
local HealthTextb = CreateClientConVar("HealthTextb", 255, true, false)
local HealthTexta = CreateClientConVar("HealthTexta", 200, true, false)

local Job1r = CreateClientConVar("Job1r", 0, true, false)
local Job1g = CreateClientConVar("Job1g", 0, true, false)
local Job1b = CreateClientConVar("Job1b", 150, true, false)
local Job1a = CreateClientConVar("Job1a", 200, true, false)

local Job2r = CreateClientConVar("Job2r", 0, true, false)
local Job2g = CreateClientConVar("Job2g", 0, true, false)
local Job2b = CreateClientConVar("Job2b", 0, true, false)
local Job2a = CreateClientConVar("Job2a", 255, true, false)

local salary1r = CreateClientConVar("salary1r", 0, true, false)
local salary1g = CreateClientConVar("salary1g", 150, true, false)
local salary1b = CreateClientConVar("salary1b", 0, true, false)
local salary1a = CreateClientConVar("salary1a", 200, true, false)

local salary2r = CreateClientConVar("salary2r", 0, true, false)
local salary2g = CreateClientConVar("salary2g", 0, true, false)
local salary2b = CreateClientConVar("salary2b", 0, true, false)
local salary2a = CreateClientConVar("salary2a", 255, true, false)

local HUDwidth = CreateClientConVar("HudWidth", 190, true, false)
local HUDHeight = CreateClientConVar("HudHeight", 10, true, false)


local arresttime = 0
local arresteduntil = 120
local function GetArrested(msg)
	arresttime = CurTime()
	arresteduntil = msg:ReadFloat()
end
usermessage.Hook("GotArrested", GetArrested)

local function DrawDisplay()
	for k, v in pairs(player.GetAll()) do
		v.DarkRPVars = v.DarkRPVars or {}
		if v.DarkRPVars.zombieToggle == true then DrawZombieInfo(v) end
		if v.DarkRPVars.wanted == true then DrawWantedInfo(v) end
	end

	local tr = LocalPlayer():GetEyeTrace()
	local superAdmin = LocalPlayer():IsSuperAdmin()

	if GetConVarNumber("globalshow") == 1 then
		for k, v in pairs(player.GetAll()) do
			DrawPlayerInfo(v)
		end
	end

	if ValidEntity(tr.Entity) and tr.Entity:GetPos():Distance(LocalPlayer():GetPos()) < 400 then
		local pos = {x = ScrW()/2, y = ScrH() / 2}
		if GetConVarNumber("globalshow") == 0 then
			if tr.Entity:IsPlayer() then DrawPlayerInfo(tr.Entity) end
		end

		if tr.Entity:IsOwnable() then
			local ownerstr = ""
			local ent = tr.Entity

			if ValidEntity(ent:GetDoorOwner()) and ent:GetDoorOwner().Nick then
				ownerstr = ent:GetDoorOwner():Nick() .. "\n"
			end

			for k,v in pairs(player.GetAll()) do
				if ent:OwnedBy(v) and v ~= ent:GetDoorOwner() then
					ownerstr = ownerstr .. v:Nick() .. "\n"
				end
			end
			
			if ent.DoorData.AllowedToOwn and table.Count(ent.DoorData.AllowedToOwn) > 0 then
				local names = {}
				for a,b in pairs(ent.DoorData.AllowedToOwn) do
					if ValidEntity(b) then
						table.insert(names, b:Nick())
					end
				end
				ownerstr = ownerstr .. string.format(LANGUAGE.keys_other_allowed).. table.concat(names, "\n").."\n"
			end

			if not LocalPlayer():InVehicle() then
				local blocked = ent.DoorData.NonOwnable
				local st = nil
				local whiteText = false -- false for red, true for white text
				
				ent.DoorData.title = ent.DoorData.title or ""
				
				if ent:IsOwned() then
					whiteText = true
					if superAdmin then
						if blocked then
							st = ent.DoorData.title .. "\n"..LANGUAGE.keys_allow_ownership
						else
							if ownerstr == "" then
								st = ent.DoorData.title .. "\n"..LANGUAGE.keys_disallow_ownership .. "\n"
							else
								if ent:OwnedBy(LocalPlayer()) and not ent.DoorData.GroupOwn then
									st = ent.DoorData.title .. "\n".. LANGUAGE.keys_owned_by .."\n" .. ownerstr
								elseif not ent.DoorData.GroupOwn then
									st = ent.DoorData.title .. "\n".. LANGUAGE.keys_owned_by .."\n" .. ownerstr .. LANGUAGE.keys_disallow_ownership .. "\n"
								elseif not ent:IsVehicle() then
									st = ent.DoorData.title .. "\n" .. ent.DoorData.GroupOwn .. "\n" .. LANGUAGE.keys_disallow_ownership .. "\n"
								end
							end
							if ent.DoorData.GroupOwn and not ent:IsVehicle() then
								st = st .. LANGUAGE.keys_everyone
							elseif not ent:IsVehicle() and ent.DoorData.GroupOwn then
								st = st .. ent.DoorData.GroupOwn
							end
						end
					else
						if blocked then
							st = ent.DoorData.title
						else
							if ownerstr == "" then
								st = ent.DoorData.title
							else
								if ent.DoorData.GroupOwn then
									whiteText = true
									st = ent.DoorData.title .. "\n".. LANGUAGE.keys_owned_by .."\n" .. ent.DoorData.GroupOwn
								else
									st = ent.DoorData.title .. "\n".. LANGUAGE.keys_owned_by .."\n" .. ownerstr
								end
							end
						end
					end
				else
					if superAdmin then
						if blocked then
							whiteText = true
							st = ent.DoorData.title .. "\n".. LANGUAGE.keys_allow_ownership
						else
							if ent.DoorData.GroupOwn then
								whiteText = true
								st = ent.DoorData.title .. "\n".. LANGUAGE.keys_owned_by .."\n" .. ent.DoorData.GroupOwn
								if not ent:IsVehicle() then
									st = st .. "\n".. LANGUAGE.keys_everyone
								end
							else
								st = LANGUAGE.keys_unowned.."\n".. LANGUAGE.keys_disallow_ownership
								if not ent:IsVehicle() then
									st = st .. "\n"..LANGUAGE.keys_cops
								end
							end
						end
					else
						if blocked then
							whiteText = true
							st = ent.DoorData.title
						else
							if ent.DoorData.GroupOwn then
								whiteText = true
								st = ent.DoorData.title .. "\n".. LANGUAGE.keys_owned_by .."\n" .. ent.DoorData.GroupOwn
							else
								st = LANGUAGE.keys_unowned
							end
						end
					end
				end

				if whiteText then
					draw.DrawText(st, "TargetID", pos.x + 1, pos.y + 1, Color(0, 0, 0, 200), 1)
					draw.DrawText(st, "TargetID", pos.x, pos.y, Color(255, 255, 255, 200), 1)
				else
					draw.DrawText(st, "TargetID", pos.x , pos.y+1 , Color(0, 0, 0, 255), 1)
					draw.DrawText(st, "TargetID", pos.x, pos.y, Color(128, 30, 30, 255), 1)
				end
			end
		end
	end

	if PanelNum and PanelNum > 0 then
		draw.RoundedBox(2, 0, 0, 150, 30, Color(0, 0, 0, 128))
		draw.DrawText(LANGUAGE.f3tovote, "ChatFont", 2, 2, Color(255, 255, 255, 200), 0)
	end
end

local LetterY = 0
local LetterAlpha = -1
local LetterMsg = ""
local LetterType = 0
local LetterStartTime = 0
local LetterPos = Vector(0, 0, 0)

local MoneyChangeAlpha = 0
local function MakeMoneyShine()
	local start = CurTime()
	local End = CurTime() + 1
	hook.Add("Tick", "MoneyShine", function()
		MoneyChangeAlpha = 255 - 255 * (math.sin((CurTime() - start) *2))
		if CurTime() >= End then
			hook.Remove("Tick", "MoneyShine")
			MoneyChangeAlpha = 0
		end
	end)
end

local OldHealth = 100
local ShowHealth = 100
local function ChangeHealth(old, new)
	local start = CurTime()
	local End = CurTime() + 1.58
	local difference = old - new
	local lastsin = new
	hook.Add("Tick", "HealthChange", function()
		ShowHealth =  old - difference * (math.sin((CurTime() - start)))
		if CurTime() >= End then
			hook.Remove("Tick", "HealthChange")
			ShowHealth = new
		end
	end)
end

local oldmoney = 0
function GM:HUDPaint()
	LocalPlayer().DarkRPVars = LocalPlayer().DarkRPVars or {}
	local health = LocalPlayer():Health()
	local money = LocalPlayer().DarkRPVars.money or 0
	local job = LocalPlayer().DarkRPVars.job or "" 
	local salary = LocalPlayer().DarkRPVars.salary or 0
	local CurrentTime = CurTime()
	
	if arresttime ~= 0 and CurrentTime - arresttime <= arresteduntil and LocalPlayer().DarkRPVars.Arrested then
		draw.DrawText(string.format(LANGUAGE.youre_arrested, math.ceil(arresteduntil - (CurrentTime - arresttime))), "ScoreboardText", ScrW()/2, ScrH() - ScrH()/12, Color(255,255,255,255), 1)
	elseif arresttime ~= 0 or not LocalPlayer().DarkRPVars.Arrested then arresttime = 0
	end
	self.BaseClass:HUDPaint()

	local hx = 9
	local hy = ScrH() - (HUDHeight:GetInt() + 20)
	local hw = HUDwidth:GetInt()
	local hh = HUDHeight:GetInt()
	
	if LocalPlayer():GetActiveWeapon().IAmControlling then return end
	local backgroundcolor = Color(backgroundr:GetInt(), backgroundg:GetInt(), backgroundb:GetInt(), backgrounda:GetInt())
	local Healthbackgroundcolor = Color(Healthbackgroundr:GetInt(), Healthbackgroundg:GetInt(), Healthbackgroundb:GetInt(), Healthbackgrounda:GetInt())
	local Healthforegroundcolor = Color(Healthforegroundr:GetInt(), Healthforegroundg:GetInt(), Healthforegroundb:GetInt(), Healthforegrounda:GetInt())
	local HealthTextColor = Color( HealthTextr:GetInt(), HealthTextg:GetInt(), HealthTextb:GetInt(), HealthTexta:GetInt())
	draw.RoundedBox(6, hx - 8, hy - 90, hw + 30, hh + 110, backgroundcolor)

	draw.RoundedBox(6, hx - 4, hy - 4, hw + 8, hh + 8, Healthbackgroundcolor)

	if health ~= OldHealth then
		ChangeHealth(OldHealth, health)
		OldHealth = health
	end
	
	if ShowHealth > 0 then
		local max = GetConVarNumber("startinghealth")
		if max == 0 then max = 100 end
		draw.RoundedBox(4, hx, hy, math.Clamp(hw * (ShowHealth / max), 0, hw), hh, Healthforegroundcolor)
	end
	
	if oldmoney ~= money then
		MakeMoneyShine()
		oldmoney = money
	end

	local job1color = Color(Job1r:GetInt(), Job1g:GetInt(), Job1b:GetInt(), Job1a:GetInt())
	local job2color = Color(Job2r:GetInt(), Job2g:GetInt(), Job2b:GetInt(), Job2a:GetInt())
	local Salary1color = Color(salary1r:GetInt(), salary1g:GetInt(), salary1b:GetInt(), salary1a:GetInt())
	local Salary2color = Color(salary2r:GetInt(), salary2g:GetInt(), salary2b:GetInt(), salary2a:GetInt())
	draw.DrawText(math.Max(0, math.Round(ShowHealth)), "TargetID", hx + hw / 2, hy - 6, HealthTextColor, 1)
	draw.DrawText(LANGUAGE.job .. job .. "\n"..LANGUAGE.wallet .. CUR .. money .. "", "TargetID", hx + 1, hy - 49, job1color, 0)
	draw.DrawText(LANGUAGE.job .. job .. "\n"..LANGUAGE.wallet .. CUR .. money .. "", "TargetID", hx, hy - 50, job2color, 0)
	draw.DrawText("\n"..LANGUAGE.wallet .. CUR .. money .. "", "TargetID", hx, hy - 50, Color(255,255,255,MoneyChangeAlpha), 0)
	draw.DrawText(LANGUAGE.salary .. CUR .. salary, "TargetID", hx + 1, hy - 70, Salary1color, 0)
	draw.DrawText(LANGUAGE.salary .. CUR .. salary, "TargetID", hx, hy - 71, Salary2color, 0)

	if LetterAlpha > -1 then
		if LetterY > ScrH() * .25 then
			LetterY = math.Clamp(LetterY - 300 * FrameTime(), ScrH() * .25, ScrH() / 2)
		end

		if LetterAlpha < 255 then
			LetterAlpha = math.Clamp(LetterAlpha + 400 * FrameTime(), 0, 255)
		end

		local font = ""

		if LetterType == 1 then
			font = "AckBarWriting"
		else
			font = "Default"
		end

		draw.RoundedBox(2, ScrW() * .2, LetterY, ScrW() * .8 - (ScrW() * .2), ScrH(), Color(255, 255, 255, math.Clamp(LetterAlpha, 0, 200)))
		draw.DrawText(LetterMsg, font, ScrW() * .25 + 20, LetterY + 80, Color(0, 0, 0, LetterAlpha), 0)
	end

	DrawDisplay()

	if StunStickFlashAlpha > -1 then
		surface.SetDrawColor(255, 255, 255, StunStickFlashAlpha)
		surface.DrawRect(0, 0, ScrW(), ScrH())
		StunStickFlashAlpha = math.Clamp(StunStickFlashAlpha + 1500 * FrameTime(), 0, 255)
	end

	if AdminTellAlpha > -1 then
		local dir = 1

		if CurrentTime - AdminTellStartTime > 10 then
			dir = -1

			if AdminTellAlpha <= 0 then
				AdminTellAlpha = -1
			end
		end

		if AdminTellAlpha > -1 then
			AdminTellAlpha = math.Clamp(AdminTellAlpha + FrameTime() * dir * 300, 0, 190)
			draw.RoundedBox(4, 10, 10, ScrW() - 20, 100, Color(0, 0, 0, AdminTellAlpha))
			draw.DrawText(LANGUAGE.listen_up, "GModToolName", ScrW() / 2 + 10, 10, Color(255, 255, 255, AdminTellAlpha), 1)
			draw.DrawText(AdminTellMsg, "ChatFont", ScrW() / 2 + 10, 65, Color(200, 30, 30, AdminTellAlpha), 1)
		end

		if not LocalPlayer():Alive() then
			draw.RoundedBox(0, 0, 0, ScrW(), ScrH(), Color(0,0,0,255))
			draw.SimpleText(LANGUAGE.nlr, "ChatFont", ScrW() / 2 +10, ScrH() / 2 - 5, Color(200,0,0,255),1)
		end
	end

	if LocalPlayer().DarkRPVars.helpCop then
		draw.RoundedBox(10, 10, 10, 590, 194, Color(0, 0, 0, 255))
		draw.RoundedBox(10, 12, 12, 586, 190, Color(51, 58, 51, 200))
		draw.RoundedBox(10, 12, 12, 586, 20, Color(0, 0, 70, 200))
		draw.DrawText("Cop Help", "ScoreboardText", 30, 12, Color(255,0,0,255),0)
		draw.DrawText(string.format(LANGUAGE.cophelp, GetConVarNumber("jailtimer")), "ScoreboardText", 30, 35, Color(255,255,255,255),0)
	end

	if LocalPlayer().DarkRPVars.helpMayor then
		draw.RoundedBox(10, 10, 10, 590, 158, Color(0, 0, 0, 255))
		draw.RoundedBox(10, 12, 12, 586, 154, Color(51, 58, 51, 200))
		draw.RoundedBox(10, 12, 12, 586, 20, Color(0, 0, 70, 200))
		draw.DrawText("Mayor Help", "ScoreboardText", 30, 12, Color(255,0,0,255),0)
		draw.DrawText(LANGUAGE.mayorhelp, "ScoreboardText", 30, 35, Color(255,255,255,255),0)
	end

	if LocalPlayer().DarkRPVars.helpAdmin then
		draw.RoundedBox(10, 10, 10, 560, 260, Color(0, 0, 0, 255))
		draw.RoundedBox(10, 12, 12, 556, 256, Color(51, 58, 51, 200))
		draw.RoundedBox(10, 12, 12, 556, 20, Color(0, 0, 70, 200))
		draw.DrawText("Admin Help", "ScoreboardText", 30, 12, Color(255,0,0,255),0)
		draw.DrawText(LANGUAGE.adminhelp, "ScoreboardText", 30, 35, Color(255,255,255,255),0)
	end

	if LocalPlayer():Team() == TEAM_GANG or LocalPlayer():Team() == TEAM_MOB and not LocalPlayer().DarkRPVars.helpBoss then
		draw.RoundedBox(10, 10, 10, 460, 110, Color(0, 0, 0, 155))
		draw.RoundedBox(10, 12, 12, 456, 106, Color(51, 58, 51,100))
		draw.RoundedBox(10, 12, 12, 456, 20, Color(0, 0, 70, 100))
		draw.DrawText(LANGUAGE.gangster_agenda, "ScoreboardText", 30, 12, Color(255,0,0,255),0)
		draw.DrawText(string.gsub(string.gsub(GetConVarString("mobagenda"), "//", "\n"), "\\n", "\n"), "ScoreboardText", 30, 35, Color(255,255,255,255),0)
	end

	if LocalPlayer().DarkRPVars.helpBoss then
		draw.RoundedBox(10, 10, 10, 560, 130, Color(0, 0, 0, 255))
		draw.RoundedBox(10, 12, 12, 556, 126, Color(51, 58, 51, 200))
		draw.RoundedBox(10, 12, 12, 556, 20, Color(0, 0, 70, 200))
		draw.DrawText("mob boss Help", "ScoreboardText", 30, 12, Color(255,0,0,255),0)
		draw.DrawText(LANGUAGE.mobhelp, "ScoreboardText", 30, 35, Color(255,255,255,255),0)
	end
	
	if LocalPlayer().DarkRPVars.HasGunlicense then
		local QuadTable = {}  
		
		QuadTable.texture 	= surface.GetTextureID( "gui/silkicons/page" ) 
		QuadTable.color		= Color( 255, 255, 255, 100 )  
		
		QuadTable.x = hw + 31
		QuadTable.y = ScrH() - 32
		QuadTable.w = 32
		QuadTable.h = 32
		draw.TexturedQuad( QuadTable )
	end
	
	local chbxX, chboxY = chat.GetChatBoxPos()
	if util.tobool(GetConVarNumber("DarkRP_LockDown")) then
		local cin = (math.sin(CurTime()) + 1) / 2
		draw.DrawText(LANGUAGE.lockdown_started, "ScoreboardSubtitle", chbxX, chboxY + 260, Color(cin * 255, 0, 255 - (cin * 255), 255), TEXT_ALIGN_LEFT)
	end
	
	if LocalPlayer().DRPIsTalking then
		local Rotating = math.sin(CurTime()*3)
		local backwards = 0
		if Rotating < 0 then
			Rotating = 1-(1+Rotating)
			backwards = 180
		end
		surface.SetTexture(surface.GetTextureID( "voice/icntlk_pl" ))
		surface.SetDrawColor(Healthforegroundcolor.r, Healthforegroundcolor.g, Healthforegroundcolor.b, Healthforegroundcolor.a)
		surface.DrawTexturedRectRotated(ScrW() - 100, chboxY, Rotating*96, 96, backwards)
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

local function EndStunStickFlash()
	StunStickFlashAlpha = -1
end

local function StunStickFlash()
	if StunStickFlashAlpha == -1 then
		StunStickFlashAlpha = 0
	end

	timer.Create(LocalPlayer():EntIndex() .. "StunStickFlashTimer", .3, 1, EndStunStickFlash)
end
usermessage.Hook("StunStickFlash", StunStickFlash)

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

local function AdminTell(msg)
	AdminTellStartTime = CurTime()
	AdminTellAlpha = 0
	AdminTellMsg = msg:ReadString()
end
usermessage.Hook("AdminTell", AdminTell)

local function ShowLetter(msg)
	LetterMsg = ""
	LetterType = msg:ReadShort()
	LetterPos = msg:ReadVector()
	local sectionCount = msg:ReadShort()
	for k=1, sectionCount do
		LetterMsg = LetterMsg .. msg:ReadString()
	end
	LetterY = ScrH() / 2
	LetterAlpha = 0
	LetterStartTime = CurTime()
end
usermessage.Hook("ShowLetter", ShowLetter)

function GM:Think()
	if LetterAlpha > -1 and LocalPlayer():GetPos():Distance(LetterPos) > 100 then LetterAlpha = -1 end
end

function KillLetter(msg) LetterAlpha = -1 end
usermessage.Hook("KillLetter", KillLetter)

local function ToggleClicker()
	GUIToggled = not GUIToggled
	gui.EnableScreenClicker(GUIToggled)

	for k, v in pairs(QuestionVGUI) do
		if v:IsValid() then
			v:SetMouseInputEnabled(GUIToggled)
		end
	end
end
usermessage.Hook("ToggleClicker", ToggleClicker)

local function AddHelpLabel(id, category, text, constant)
	table.insert(HelpLabels, { id = id, category = category, text = text, constant = constant })
end

local function ChangeHelpLabel(msg)
	local id = msg:ReadShort()
	local text = msg:ReadString()

	local function tChangeHelpLabel(id, text)
		for k, v in pairs(HelpLabels) do
			if v.id == id then
				v.text = text
				return
			end
		end
	end

	timer.Simple(.01, tChangeHelpLabel, id, text)
end
usermessage.Hook("ChangeHelpLabel", ChangeHelpLabel)
function AddHelpCategory(id, name)
	table.insert(HelpCategories, { id = id, text = name })
end
	
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
				if not head.Pos then return end

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

local function RPStopMessageMode()
	Messagemode = false
	hook.Remove("Think", "RPGetRecipients")
	hook.Remove("HUDPaint", "RPinstructionsOnSayColors")
	playercolors = {}
end


local function RPSelectwhohearit()
	if PlayerColorsOn:GetInt() == 0 then return end
	Messagemode = true
	
	hook.Add("HUDPaint", "RPinstructionsOnSayColors", function()
		local w, l = chat.GetChatBoxPos()
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
				elseif (HearMode == "yell" or HearMode == "speak") and distance < 550 and not table.HasValue(playercolors, v) then
					table.insert(playercolors, v)
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
hook.Add("FinishChat", "RPCloseRadiusDetection", function() Messagemode = false RPStopMessageMode() end)

local PlayerColorsOn = CreateClientConVar("rp_showchatcolors", 1, true, false)
function GM:ChatTextChanged(text)
	if PlayerColorsOn:GetInt() == 0 then return end
	
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
	if ply == LocalPlayer() and ValidEntity(LocalPlayer().DarkRPVars.phone) then
		return
	end
	
	
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
	if ValidEntity(LocalPlayer().DarkRPVars.phone) then
		ply.DRPIsTalking = false
		timer.Simple(0.2, function() 
			if ValidEntity(LocalPlayer().DarkRPVars.phone) then
				LocalPlayer():ConCommand("+voicerecord") 
			end
		end)
		self.BaseClass:PlayerEndVoice(ply)
		return
	end
	
	
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
		if ply:IsValid() then
			hook.Call("OnPlayerChat", GM, ply, text, false, ply:Alive())
		end
	else
		chat.AddText(col1, name)
		hook.Call("ChatText", GM, "0", name, "", "none")
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
	if not ValidEntity(decoded[1]) then return end
	decoded[1].DoorData = decoded[2]
	
	local DoorString = "Data:\n"
	for k,v in pairs(decoded[2]) do
		DoorString = DoorString .. k.."\t\t".. tostring(v) .. "\n"
	end
end
datastream.Hook("DarkRP_DoorData", RetrieveDoorData)

local function RetrievePlayerVar(handler, id, encoded, decoded)
	if not ValidEntity(decoded[1]) then return end
	decoded[1].DarkRPVars = decoded[1].DarkRPVars or {}
	decoded[1].DarkRPVars[decoded[2]] = decoded[3]
end
datastream.Hook("DarkRP_PlayerVar", RetrievePlayerVar)

local function InitializeDarkRPVars(handler, id, encoded, decoded)
	if not decoded then return end
	for ply,vars in pairs(decoded) do
		ply.DarkRPVars = vars
	end
end
datastream.Hook("DarkRP_InitializeVars", InitializeDarkRPVars)

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
	timer.Create("DarkRPCheckifitcamethrough", 2, 0, function()
		for k,v in pairs(player.GetAll()) do
			v.DarkRPVars = v.DarkRPVars or {}
			if not v.DarkRPVars.job or not v.DarkRPVars.salary or not v.DarkRPVars.money or not v.DarkRPVars.rpname then
				RunConsoleCommand("_sendDarkRPvars")
				break
			end
		end
	end)
end