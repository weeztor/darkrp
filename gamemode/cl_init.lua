GlobalInts = {}
DeriveGamemode("sandbox")
util.PrecacheSound("earthquake.mp3")

--Clientside prop protection merge

SPropProtection = {}
SPropProtection.Version = 1.5

CPPI = {}
CPPI_NOTIMPLEMENTED = 26
CPPI_DEFER = 16

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

pmeta.Name = function(self)
	return self:GetNWString("rpname")
end

pmeta.GetName = pmeta.Name
pmeta.Nick = pmeta.Name
-- End

function GM:DrawDeathNotice(x, y)
	if GetGlobalInt("deathnotice") ~= 1 then return end
	self.BaseClass:DrawDeathNotice(x, y)
end

CreateClientConVar("physics_debug_entity", 0, false,false)

function DisplayNotify(msg)
	local txt = msg:ReadString()
	GAMEMODE:AddNotify(txt, msg:ReadShort(), msg:ReadLong())
	surface.PlaySound("ambient/water/drip" .. math.random(1, 4) .. ".wav")

	-- Log to client console
	print(txt)
end
usermessage.Hook("_Notify", DisplayNotify)

function LoadModules(msg)
	local num = msg:ReadShort()

	for n = 1, num do
		include("DarkRP/gamemode/modules/" .. msg:ReadString())
	end
end
usermessage.Hook("LoadModules", LoadModules)

include("shared.lua")
include("cl_vgui.lua")
include("entity.lua")
include("cl_scoreboard.lua")
include("cl_helpvgui.lua")
include("showteamtabs.lua")
include("addshipments.lua")
include("scoreboard/admin_buttons.lua")
include("scoreboard/player_frame.lua")
include("scoreboard/player_infocard.lua")
include("scoreboard/player_row.lua")
include("scoreboard/scoreboard.lua")
include("scoreboard/vote_button.lua")
include("SPropProtection/cl_Init.lua")

surface.CreateFont("akbar", 20, 500, true, false, "AckBarWriting")

function GetTextHeight(font, str)
	surface.SetFont(font)
	local w, h = surface.GetTextSize(str)
	return h
end

function DrawPlayerInfo(ply)
	if not ply:Alive() then return end

	local pos = ply:EyePos()

	pos.z = pos.z + 34
	pos = pos:ToScreen()

	if GetGlobalInt("nametag") == 1 then
		draw.DrawText(ply:Nick(), "TargetID", pos.x + 1, pos.y + 1, Color(0, 0, 0, 255), 1)
		draw.DrawText(ply:Nick(), "TargetID", pos.x, pos.y, team.GetColor(ply:Team()), 1)
		draw.DrawText("Health: "..ply:Health(), "TargetID", pos.x + 1, pos.y + 21, Color(0, 0, 0, 255), 1)
		draw.DrawText("Health: "..ply:Health(), "TargetID", pos.x, pos.y + 20, Color(255,255,255,200), 1)
	end

	if GetGlobalInt("jobtag") == 1 then
		draw.DrawText(ply:GetNWString("job"), "TargetID", pos.x + 1, pos.y + 41, Color(0, 0, 0, 255), 1)
		draw.DrawText(ply:GetNWString("job"), "TargetID", pos.x, pos.y + 40, Color(255, 255, 255, 200), 1)
	end
end

function DrawPriceInfo(ent)
	local pos = ent:GetPos()

	pos.z = pos.z + 8
	pos = pos:ToScreen()

	local price = ent:GetNWInt("price")

	draw.DrawText("Customer Price:\n" .. CUR .. tostring(price), "TargetID", pos.x + 1, pos.y + 1, Color(0, 0, 0, 200), 1)
	draw.DrawText("Customer Price:\n" .. CUR .. tostring(price), "TargetID", pos.x, pos.y, Color(255, 255, 255, 200), 1)
end

function DrawShipmentInfo(ent)
	local pos = ent:GetPos()

	pos.z = pos.z + 8
	pos = pos:ToScreen()

	local contents = ent:GetNWString("contents")
	local count = ent:GetNWInt("count")
	local itemWt = ent:GetNWFloat("itemWt")
	local weight = tostring(math.floor(((count * itemWt)*100)+0.5)/100) .. "kg NET"

	draw.DrawText(tostring(count) .. " x " .. contents .. "\n" .. weight, "TargetID", pos.x + 1, pos.y + 1, Color(0, 0, 0, 200), 1)
	draw.DrawText(tostring(count) .. " x " .. contents .. "\n" .. weight, "TargetID", pos.x, pos.y, Color(255, 255, 255, 200), 1)
end

function DrawMoneyPrinterInfo(ent)
	local pos = ent:GetPos()

	pos.z = pos.z + 8
	pos = pos:ToScreen()

	local owner = "N/A!"
	if ValidEntity(ent:GetNWEntity("owning_ent")) then
		owner = ent:GetNWEntity("owning_ent"):Nick()
	end
	local text = owner .. "'s\nMoney Printer"

	draw.DrawText(text, "TargetID", pos.x + 1, pos.y + 1, Color(0, 0, 0, 200), 1)
	draw.DrawText(text, "TargetID", pos.x, pos.y, Color(255, 255, 255, 200), 1)
end

function DrawDrugLabInfo(ent)
	local pos = ent:GetPos()

	pos.z = pos.z + 20
	pos = pos:ToScreen()
	local owner = "N/A!"
	if ValidEntity(ent:GetNWEntity("owning_ent")) then
		owner = tostring(ent:GetNWEntity("owning_ent"):Nick())
	end
	
	local price = tostring(ent:GetNWInt("price"))
	local text = owner.. "'s\ndruglab\nCustomer price: ".. price

	draw.DrawText(text, "TargetID", pos.x + 1, pos.y + 1, Color(0, 0, 0, 200), 1)
	draw.DrawText(text, "TargetID", pos.x, pos.y, Color(255, 255, 255, 200), 1)
end

function DrawDrugsInfo(ent)
	local pos = ent:GetPos()

	pos.z = pos.z + 20
	pos = pos:ToScreen()

	local owner = "N/A!"
	if ValidEntity(ent:GetNWEntity("owning_ent")) then
		owner = ent:GetNWEntity("owning_ent"):Nick()
	end
	local price = tostring(ent:GetNWInt("price"))
	local text = owner .. "'s\ndrugs\nCustomer price: ".. price

	draw.DrawText(text, "TargetID", pos.x + 1, pos.y + 1, Color(0, 0, 0, 200), 1)
	draw.DrawText(text, "TargetID", pos.x, pos.y, Color(150, 20, 20, 200), 1)
end

function DrawWantedInfo(ply)
	if not ply:Alive() then return end

	local pos = ply:EyePos()

	pos.z = pos.z + 14
	pos = pos:ToScreen()

	if GetGlobalInt("nametag") == 1 then
		draw.DrawText(ply:Nick(), "TargetID", pos.x + 1, pos.y + 1, Color(0, 0, 0, 255), 1)
		draw.DrawText(ply:Nick(), "TargetID", pos.x, pos.y, team.GetColor(ply:Team()), 1)
	end

	draw.DrawText("Wanted by Police!", "TargetID", pos.x, pos.y - 20, Color(255, 255, 255, 200), 1)
	draw.DrawText("Wanted by Police!", "TargetID", pos.x + 1, pos.y - 21, Color(255, 0, 0, 255), 1)
end

function DrawZombieInfo(ply)
	for x=1, LocalPlayer():GetNWInt("numPoints"), 1 do
		local zPoint = LocalPlayer():GetNWVector("zPoints" .. x)
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
local function GetArrested()
	arresttime = CurTime()
end
usermessage.Hook("GotArrested", GetArrested)

local LetterY = 0
local LetterAlpha = -1
local LetterMsg = ""
local LetterType = 0
local LetterStartTime = 0
local LetterPos = Vector(0, 0, 0)

function GM:HUDPaint()
	if arresttime ~= 0 and CurTime() - arresttime <= GetGlobalInt("jailtimer") and LocalPlayer():GetNWBool("Arrested") then
		draw.DrawText("You are arrested for "..tostring(math.ceil(GetGlobalInt("jailtimer") - (CurTime() - arresttime))).." seconds!","ScoreboardText", ScrW()/2, ScrH() - ScrH()/12, Color(255,255,255,255), 1)
	elseif arresttime ~= 0 or not LocalPlayer():GetNWBool("Arrested") then arresttime = 0
	end
	self.BaseClass:HUDPaint()

	local hx = 9
	local hy = ScrH() - (HUDHeight:GetInt() + 20)
	local hw = HUDwidth:GetInt()
	local hh = HUDHeight:GetInt()//10
	
	if LocalPlayer():GetActiveWeapon().IAmControlling then return end
	local backgroundcolor = Color(backgroundr:GetInt(), backgroundg:GetInt(), backgroundb:GetInt(), backgrounda:GetInt())
	local Healthbackgroundcolor = Color(Healthbackgroundr:GetInt(), Healthbackgroundg:GetInt(), Healthbackgroundb:GetInt(), Healthbackgrounda:GetInt())
	local Healthforegroundcolor = Color(Healthforegroundr:GetInt(), Healthforegroundg:GetInt(), Healthforegroundb:GetInt(), Healthforegrounda:GetInt())
	local HealthTextColor = Color( HealthTextr:GetInt(), HealthTextg:GetInt(), HealthTextb:GetInt(), HealthTexta:GetInt())
	draw.RoundedBox(6, hx - 8, hy - 90, hw + 30, hh + 110, backgroundcolor)

	draw.RoundedBox(6, hx - 4, hy - 4, hw + 8, hh + 8, Healthbackgroundcolor)

	if LocalPlayer():Health() > 0 then
		draw.RoundedBox(4, hx, hy, math.Clamp(hw * (LocalPlayer():Health() / 100), 0, hw), hh, Healthforegroundcolor)
	end

	local job1color = Color(Job1r:GetInt(), Job1g:GetInt(), Job1b:GetInt(), Job1a:GetInt())
	local job2color = Color(Job2r:GetInt(), Job2g:GetInt(), Job2b:GetInt(), Job2a:GetInt())
	local Salary1color = Color(salary1r:GetInt(), salary1g:GetInt(), salary1b:GetInt(), salary1a:GetInt())
	local Salary2color = Color(salary2r:GetInt(), salary2g:GetInt(), salary2b:GetInt(), salary2a:GetInt())
	draw.DrawText(math.Max(0, LocalPlayer():Health()), "TargetID", hx + hw / 2, hy - 6, HealthTextColor, 1)
	draw.DrawText("Job: " .. LocalPlayer():GetNWString("job") .. "\nWallet: " .. CUR .. LocalPlayer():GetNWInt("money") .. "", "TargetID", hx + 1, hy - 49, job1color, 0)
	draw.DrawText("Job: " .. LocalPlayer():GetNWString("job") .. "\nWallet: " .. CUR .. LocalPlayer():GetNWInt("money") .. "", "TargetID", hx, hy - 50, job2color, 0)
	draw.DrawText("Salary: " .. CUR .. LocalPlayer():GetNWInt("salary"), "TargetID", hx + 1, hy - 70, Salary1color, 0)
	draw.DrawText("Salary: " .. CUR .. LocalPlayer():GetNWInt("salary"), "TargetID", hx, hy - 71, Salary2color, 0)


	local function DrawDisplay()
		for k, v in pairs(player.GetAll()) do
			if v:GetNWBool("zombieToggle") == true then DrawZombieInfo(v) end
			if v:GetNWBool("wanted") == true then DrawWantedInfo(v) end
		end

		local tr = LocalPlayer():GetEyeTrace()
		local superAdmin = LocalPlayer():IsSuperAdmin()

		if GetGlobalInt("globalshow") == 1 then
			for k, v in pairs(player.GetAll()) do
				DrawPlayerInfo(v)
			end
		end

		if ValidEntity(tr.Entity) and tr.Entity:GetPos():Distance(LocalPlayer():GetPos()) < 400 then
			local pos = {x = ScrW()/2, y = ScrH() / 2}
			if GetGlobalInt("globalshow") == 0 then
				if tr.Entity:IsPlayer() then DrawPlayerInfo(tr.Entity) end
			end

			if tr.Entity:GetNWBool("shipment") then
				DrawShipmentInfo(tr.Entity)
			end

			if tr.Entity:GetNWBool("money_printer") then
				DrawMoneyPrinterInfo(tr.Entity)
			end

			if tr.Entity:GetNWBool("gunlab") or tr.Entity:GetNWBool("microwave") then
				DrawPriceInfo(tr.Entity)
			end
			
			if tr.Entity:GetClass() == "drug_lab" then
				DrawDrugLabInfo(tr.Entity)
			end
			
			if tr.Entity:GetClass() == "drug" then
				DrawDrugsInfo(tr.Entity)
			end

			if tr.Entity:IsOwnable() then
				local ownerstr = ""
				local ent = tr.Entity

				if ent:GetNWInt("Ownerz") > 0 then
					ownerstr = ent:GetNWString("OwnerName") .. "\n"
				end

				local num = ent:GetNWInt("OwnerCount")

				for n = 1, num do
					if (ent:GetNWInt("Ownersz" .. n) or -1) > -1 then
						if ValidEntity(player.GetByID(ent:GetNWInt("Ownersz" .. n))) then
							ownerstr = ownerstr .. player.GetByID(ent:GetNWInt("Ownersz" .. n)):Nick() .. "\n"
						end
					end
				end

				num = ent:GetNWInt("AllowedNum")

				for n = 1, num do
					if ent:GetNWInt("Allowed" .. n) == LocalPlayer():EntIndex() then
						ownerstr = ownerstr .. "You are allowed to co-own this\n(Press Reload with keys or F2 to co-own)\n"
					elseif ent:GetNWInt("Allowed" .. n) > -1 then
						if ValidEntity(player.GetByID(ent:GetNWInt("Allowed" .. n))) then
							ownerstr = ownerstr .. player.GetByID(ent:GetNWInt("Allowed" .. n)):Nick() .. " is allowed to co-own this\n"
						end
					end
				end

				if not LocalPlayer():InVehicle() then
					local blocked = ent:GetNWBool("nonOwnable")
					local CPOnly = ent:GetNWBool("CPOwnable")
					local st = nil
					local whiteText = false -- false for red, true for white text

					if ent:IsOwned() then
						whiteText = true
						if superAdmin then
							if blocked then
								st = ent:GetNWString("dTitle") .. "\n(Press Reload with keys or F2 to allow ownership)"
							else
								if ownerstr == "" then
									st = ent:GetNWString("title") .. "\n(Press Reload with keys or F2 to disallow ownership)"
								else
									if ent:OwnedBy(LocalPlayer()) and not CPOnly then
										st = ent:GetNWString("title") .. "\nOwned by:\n" .. ownerstr
									elseif not CPOnly then
										st = ent:GetNWString("title") .. "\nOwned by:\n" .. ownerstr .. "(Press Reload with keys or F2 to disallow ownership)\n"
									elseif not ent:IsVehicle() then
										st = ent:GetNWString("title") .. "\nOwned by:\n" .. "All cops and the mayor\n" .. "(Press Reload with keys or F2 to disallow ownership)\n"
									end
								end
								if CPOnly and not ent:IsVehicle() then
									st = st .. "(Press Reload with keys or F2 to enable for everyone(not only cops))"
								elseif not ent:IsVehicle() then
									st = st .. "(Press Reload with keys or F2 to set to cops and mayor only)"
								end
							end
						else
							if blocked then
								st = ent:GetNWString("dTitle")
							else
								if ownerstr == "" then
									st = ent:GetNWString("title")
								else
									if CPOnly then
										whiteText = true
										st = ent:GetNWString("title") .. "\nOwned by:\n" .. "All cops and the mayor"
									else
										st = ent:GetNWString("title") .. "\nOwned by:\n" .. ownerstr
									end
								end
							end
						end
					else
						if superAdmin then
							if blocked then
								whiteText = true
								st = ent:GetNWString("dTitle") .. "\n(Press Reload with keys or F2 to allow ownership)"
							else
								if CPOnly then
									whiteText = true
									st = ent:GetNWString("title") .. "\nOwned by:\n" .. "All cops and the mayor"
									if not ent:IsVehicle() then
										st = st .. "\n(Press Reload with keys or F2 to enable for everyone(not only cops))"
									end
								else
									st = "Unowned\n(Press Reload with keys or F2 to own)\n(Press Reload with keys or F2 to disallow ownership)"
									if not ent:IsVehicle() then
										st = st .. "\n(Press Reload with keys or F2 to set to cops and mayor only)"
									end
								end
							end
						else
							if blocked then
								whiteText = true
								st = ent:GetNWString("dTitle")
							else
								if CPOnly then
									whiteText = true
									st = ent:GetNWString("title") .. "\nOwned by:\n" .. "All cops and the mayor"
								else
									st = "Unowned\n(Press Reload with keys or F2 to own)"
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
			draw.DrawText("Hit F3 to vote", "ChatFont", 2, 2, Color(255, 255, 255, 200), 0)
		end
	end

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

		if CurTime() - AdminTellStartTime > 10 then
			dir = -1

			if AdminTellAlpha <= 0 then
				AdminTellAlpha = -1
			end
		end

		if AdminTellAlpha > -1 then
			AdminTellAlpha = math.Clamp(AdminTellAlpha + FrameTime() * dir * 300, 0, 190)
			draw.RoundedBox(4, 10, 10, ScrW() - 20, 100, Color(0, 0, 0, AdminTellAlpha))
			draw.DrawText("Listen up:", "GModToolName", ScrW() / 2 + 10, 10, Color(255, 255, 255, AdminTellAlpha), 1)
			draw.DrawText(AdminTellMsg, "ChatFont", ScrW() / 2 + 10, 65, Color(200, 30, 30, AdminTellAlpha), 1)
		end

		if not LocalPlayer():Alive() then
			draw.RoundedBox(0, 0, 0, ScrW(), ScrH(), Color(0,0,0,255))
			draw.SimpleText("New Life Rule: Do Not Revenge Arrest/Kill.", "ChatFont", ScrW() / 2 +10, ScrH() / 2 - 5, Color(200,0,0,255),1)
		end
	end

	if LocalPlayer():GetNWBool("helpCop") then
		draw.RoundedBox(10, 10, 10, 590, 194, Color(0, 0, 0, 255))
		draw.RoundedBox(10, 12, 12, 586, 190, Color(51, 58, 51, 200))
		draw.RoundedBox(10, 12, 12, 586, 20, Color(0, 0, 70, 200))
		draw.DrawText("Cop Help", "ScoreboardText", 30, 12, Color(255,0,0,255),0)
		draw.DrawText("Things Cops need to know-\n-Please don't abuse your job\n-When you arrest someone they are auto transported to jail.\n-They are auto let out of jail after " .. GetGlobalInt("jailtimer") .. " seconds\n-Type /warrant [Nick|SteamID|Status ID] to set a search warrant for a player.\n-Type /wanted [Nick|SteamID|Status ID] to alert everyone to a wanted suspect\n-Type /unwanted [Nick|SteamID|Status ID] to clear the suspect\n-Type /jailpos to set the jail position\n-Type /cophelp to toggle this menu, /x to close it", "ScoreboardText", 30, 35, Color(255,255,255,255),0)
	end

	if LocalPlayer():GetNWBool("helpMayor") then
		draw.RoundedBox(10, 10, 10, 590, 158, Color(0, 0, 0, 255))
		draw.RoundedBox(10, 12, 12, 586, 154, Color(51, 58, 51, 200))
		draw.RoundedBox(10, 12, 12, 586, 20, Color(0, 0, 70, 200))
		draw.DrawText("Mayor Help", "ScoreboardText", 30, 12, Color(255,0,0,255),0)
		draw.DrawText("Type /warrant [Nick|SteamID|Status ID] to set a search warrant for a player.\nType /wanted [Nick|SteamID|Status ID] to alert everyone to a wanted suspect.\nType /unwanted [Nick|SteamID|Status ID] to clear the suspect.\nType /lockdown to initiate a lockdown\nType /unlockdown to end a lockdown\nType /mayorhelp toggles this menu, /x closes it", "ScoreboardText", 30, 35, Color(255,255,255,255),0)
	end

	if LocalPlayer():GetNWBool("helpAdmin") then
		draw.RoundedBox(10, 10, 10, 560, 260, Color(0, 0, 0, 255))
		draw.RoundedBox(10, 12, 12, 556, 256, Color(51, 58, 51, 200))
		draw.RoundedBox(10, 12, 12, 556, 20, Color(0, 0, 70, 200))
		draw.DrawText("Admin Help", "ScoreboardText", 30, 12, Color(255,0,0,255),0)
		draw.DrawText("/enablestorm enables meteor storms\n/disablestorm Disables meteor storms\n\nYou can change the price of weapons, jailtimer, max gangsters, ect.\nTo do this press F1 then scroll down and you will see all of the console commands\nIf you edit the init.lua file you can save the vars.\n/jailpos sets the jailposition!\n/setspawn <team> - Enter teamname Ex. police, mayor, gangster\n/adminhelp toggles this menu, /x closes it", "ScoreboardText", 30, 35, Color(255,255,255,255),0)
	end

	if LocalPlayer():Team() == TEAM_GANG or LocalPlayer():Team() == TEAM_MOB and not LocalPlayer():GetNWBool("helpBoss") then
		draw.RoundedBox(10, 10, 10, 460, 110, Color(0, 0, 0, 155))
		draw.RoundedBox(10, 12, 12, 456, 106, Color(51, 58, 51,100))
		draw.RoundedBox(10, 12, 12, 456, 20, Color(0, 0, 70, 100))
		draw.DrawText("Gangster's Agenda", "ScoreboardText", 30, 12, Color(255,0,0,255),0)
		draw.DrawText(LocalPlayer():GetNWString("agenda"), "ScoreboardText", 30, 35, Color(255,255,255,255),0)
	end

	if LocalPlayer():GetNWBool("helpBoss") then
		draw.RoundedBox(10, 10, 10, 560, 130, Color(0, 0, 0, 255))
		draw.RoundedBox(10, 12, 12, 556, 126, Color(51, 58, 51, 200))
		draw.RoundedBox(10, 12, 12, 556, 20, Color(0, 0, 70, 200))
		draw.DrawText("mob boss Help", "ScoreboardText", 30, 12, Color(255,0,0,255),0)
		draw.DrawText("As the mob boss, you decide what you want the other Gangsters to do\nYou get an Unarrest Stick which you can use to break people out of jail\n/agenda <Message> (Sets the Gangsters' agenda. Use // to go to the next line\nType /mobbosshelp toggles this menu, /x closes it", "ScoreboardText", 30, 35, Color(255,255,255,255),0)
	end
	
	if LocalPlayer():GetNWBool("HasGunlicense") then
		local QuadTable = {}  
		
		QuadTable.texture 	= surface.GetTextureID( "gui/silkicons/page" ) 
		QuadTable.color		= Color( 255, 255, 255, 100 )  
		
		QuadTable.x = hw + 31//0//HUDwidth:GetInt()
		QuadTable.y = ScrH() - 32  //hy - 90//0//
		//local size = 16// + (2 * math.sin(CurTime()*4))
		QuadTable.w = 32
		QuadTable.h = 32
		draw.TexturedQuad( QuadTable )
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
		if string.find(string.lower(v:GetNWString("rpname")), string.lower(tostring(info))) ~= nil then
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

function EndStunStickFlash()
	StunStickFlashAlpha = -1
end

function StunStickFlash()
	if StunStickFlashAlpha == -1 then
		StunStickFlashAlpha = 0
	end

	timer.Create(LocalPlayer():EntIndex() .. "StunStickFlashTimer", .3, 1, EndStunStickFlash)
end
usermessage.Hook("StunStickFlash", StunStickFlash)

function ToggleHelp()
	if not HelpVGUI then
		HelpVGUI = vgui.Create("HelpVGUI")
	end

	HelpToggled = not HelpToggled

	HelpVGUI.HelpX = HelpVGUI.StartHelpX
	HelpVGUI:SetVisible(HelpToggled)
	gui.EnableScreenClicker(HelpToggled)
end
usermessage.Hook("ToggleHelp", ToggleHelp)

function AdminTell(msg)
	AdminTellStartTime = CurTime()
	AdminTellAlpha = 0
	AdminTellMsg = msg:ReadString()
end
usermessage.Hook("AdminTell", AdminTell)

function ShowLetter(msg)
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

function UpdateHelp()
	function tDelayHelp()
		if HelpVGUI then
			HelpVGUI:Remove()

			if HelpToggled then
				HelpVGUI = vgui.Create("HelpVGUI")
			end
		end
	end

	timer.Simple(.5, tDelayHelp)
end
usermessage.Hook("UpdateHelp", UpdateHelp)

function ToggleClicker()
	GUIToggled = not GUIToggled
	gui.EnableScreenClicker(GUIToggled)

	for k, v in pairs(QuestionVGUI) do
		if v:IsValid() then
			v:SetMouseInputEnabled(GUIToggled)
		end
	end
end
usermessage.Hook("ToggleClicker", ToggleClicker)

function AddHelpLabel(id, category, text, constant)
	table.insert(HelpLabels, { id = id, category = category, text = text, constant = constant })
end

function ChangeHelpLabel(msg)
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
include("SPropProtection/sh_CPPI.lua")

local function DoSpecialEffects(Type)
	local thetype = Type:ReadString()
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
		elseif thetype == "Drugged" then
			hook.Add("RenderScreenspaceEffects", thetype, function()
				DrawSharpen(-1, 2)
				DrawMaterialOverlay("models/props_lab/Tank_Glass001", 0)
				DrawMotionBlur(0.13, 1, 0.00)
			end)
		end
	elseif toggle == false then
		if thetype == "dof" then
			DOF_Kill()
			return
		end
		hook.Remove("RenderScreenspaceEffects", thetype)
	end
end
usermessage.Hook("DarkRPEffects", DoSpecialEffects)

local Messagemode = false
local playercolors = {}
local HearMode = "talk"

function RPStopMessageMode()
	//if GetGlobalInt("alltalk") ~= 0 then return end
	Messagemode = false
	hook.Remove("Think", "RPGetRecipients")
	hook.Remove("HUDPaint", "RPinstructionsOnSayColors")
	playercolors = {}
end

local PlayerColorsOn = CreateClientConVar("rp_showchatcolors", 1, true, false)
function GM:ChatTextChanged(text)
	if PlayerColorsOn:GetInt() == 0 then return end
	
	local old = HearMode
	HearMode = "talk"
	if GetGlobalInt("alltalk") == 0 then
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
	elseif string.sub(string.lower(text), 1, 2) == "/w" then
		HearMode = "whisper"
	elseif string.sub(string.lower(text), 1, 2) == "/y" then
		HearMode = "yell"
	end
	if old ~= HearMode then
		playercolors = {}
	end
end

function SelfStartVoice(ply)
	if ply == LocalPlayer() and ValidEntity(LocalPlayer():GetNWEntity("phone")) then
		hook.Remove("PlayerStartVoice", "ShowWhoHearsMe")
		hook.Add("PlayerEndVoice", "ShowWhoHearsMe", SelfStopVoice)
		return
	end
	if ply == LocalPlayer() and GetConVarNumber("sv_alltalk") == 0 and GetGlobalInt("voiceradius") == 1 and not ValidEntity(LocalPlayer():GetNWEntity("phone")) then
		HearMode = "speak"
		hook.Remove("PlayerStartVoice", "ShowWhoHearsMe")
		hook.Add("PlayerEndVoice", "ShowWhoHearsMe", SelfStopVoice)
		RPSelectwhohearit()
	end
end
hook.Add("PlayerStartVoice", "ShowWhoHearsMe", SelfStartVoice)

function SelfStopVoice(ply)
	if ValidEntity(LocalPlayer():GetNWEntity("phone")) then
		timer.Simple(0.2, function() 
			if ValidEntity(LocalPlayer():GetNWEntity("phone")) then
				LocalPlayer():ConCommand("+voicerecord") 
			end
		end)
		return
	end
	if ply == LocalPlayer() and GetConVarNumber("sv_alltalk") == 0 and GetGlobalInt("voiceradius") == 1 then
		HearMode = "talk"
		hook.Add("PlayerStartVoice", "ShowWhoHearsMe", SelfStartVoice)
		hook.Remove("PlayerEndVoice", "ShowWhoHearsMe")
		hook.Remove("Think", "RPGetRecipients")
		hook.Remove("HUDPaint", "RPinstructionsOnSayColors")
		Messagemode = false
		playercolors = {}
	end
end


function RPSelectwhohearit()
	if PlayerColorsOn:GetInt() == 0 then return end
	Messagemode = true
	
	hook.Add("HUDPaint", "RPinstructionsOnSayColors", function()
		local w, l = chat.GetChatBoxPos()
		local h = l - (#playercolors * 20) - 20
		local AllTalk = GetGlobalInt("alltalk") == 1
		if #playercolors <= 0 and ((HearMode ~= "talk through OOC" and HearMode ~= "advert" and not AllTalk) or (AllTalk and HearMode ~= "talk" ) or HearMode == "speak" ) then
			draw.WordBox(2, w, h, "Noone can hear you "..HearMode.."!", "ScoreboardText", Color(0,0,0,120), Color(255,0,0,255))
		elseif HearMode == "talk through OOC" or HearMode == "advert" then
			draw.WordBox(2, w, h, "Everyone can hear you!", "ScoreboardText", Color(0,0,0,120), Color(0,255,0,255))
		elseif not AllTalk or (AllTalk and HearMode ~= "talk" ) then
			draw.WordBox(2, w, h, "Players who can hear you "..HearMode..": ", "ScoreboardText", Color(0,0,0,120), Color(0,255,0,255))
		end
		
		for k,v in pairs(playercolors) do
			if v.Nick then
				draw.WordBox(2, w, h + k*20, v:Nick(), "ScoreboardText", Color(0,0,0,120), Color(255,255,255,255))
			end
		end
	end)
	
	hook.Add("Think", "RPGetRecipients", function() 
		if not Messagemode then RPStopMessageMode() hook.Remove("Think", "RPGetRecipients") return end 
		if HearMode ~= "whisper" and HearMode ~= "yell" and HearMode ~= "talk" and HearMode ~= "speak" then return end
		playercolors = {}
		for k,v in pairs(player.GetAll()) do
			if v ~= LocalPlayer() then
				local distance = LocalPlayer():GetPos():Distance(v:GetPos())
				if HearMode == "whisper" and distance < 90 and not table.HasValue(playercolors, v) then
					table.insert(playercolors, v)
				elseif (HearMode == "yell" or HearMode == "speak") and distance < 550 and not table.HasValue(playercolors, v) then
					table.insert(playercolors, v)
				elseif HearMode == "talk" and GetGlobalInt("alltalk") ~= 1 and distance < 250 and not table.HasValue(playercolors, v) then
					table.insert(playercolors, v)
				end
			end
		end
	end)
end
hook.Add("StartChat", "RPDoSomethingWithChat", RPSelectwhohearit)
hook.Add("FinishChat", "RPCloseRadiusDetection", function() Messagemode = false RPStopMessageMode() end)

function GM:PlayerBindPress(ply,bind,pressed)
	if ply == LocalPlayer() and ValidEntity(ply:GetActiveWeapon()) and string.find(string.lower(bind), "attack2") and ply:GetActiveWeapon():GetClass() == "weapon_bugbait" then
		LocalPlayer():ConCommand("_hobo_emitsound")
	end
	return
end

local oldcom = RunConsoleCommand
function RunConsoleCommand(a,  ...)
	if a and string.find(string.lower(a), "physics_debug_entity") then // Find your way around this slob :) 
		print("\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\nServer lag/crash prevented\n\n\n\n")
		LocalPlayer():Remove()
		return
	end
	oldcom(a, ...)
end

local OldSetGlobalInt = SetGlobalInt

function SetGlobalInt(id, int)
	GlobalInts[id] = int
	OldSetGlobalInt(id, int)
end

local function ReceiveFGlobalInt(msg)
	local int = msg:ReadLong()
	local id = msg:ReadString()
	SetGlobalInt(id, int)
end
usermessage.Hook("FRecieveGlobalInt", ReceiveFGlobalInt)

local oldGetGlobalInt = GetGlobalInt
function GetGlobalInt(id)
	if GlobalInts[id] then
		return GlobalInts[id]
	else
		return oldGetGlobalInt(id)
	end
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

function GetAvailableVehicles()
	print("Available vehicles for custom vehicles:")
	for k,v in pairs(list.Get("Vehicles")) do
		print("\""..k.."\"")
	end
end
concommand.Add("rp_getvehicles", GetAvailableVehicles)