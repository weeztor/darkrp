DeriveGamemode("sandbox")
util.PrecacheSound("earthquake.mp3")

-- Currency Symbol
local currencysymbol = CreateClientConVar("rp_currency", "$", true, false)
CUR = currencysymbol:GetString()

GUIToggled = false
HelpToggled = false

HelpLabels = { }
HelpCategories = { }

AdminTellAlpha = -1
AdminTellStartTime = 0
AdminTellMsg = ""

StunStickFlashAlpha = -1

-- Make sure the client sees the RP name where they expect to see the name
local pmeta = FindMetaTable("Player")

pmeta.Name = function(self)
	return self:GetNWString("rpname")
end

pmeta.GetName = pmeta.Name
pmeta.Nick = pmeta.Name
-- End

if HelpVGUI then
	HelpVGUI:Remove()
	HelpVGUI = nil
end

function GM:Initialize()
	self.BaseClass:Initialize()
end

function DisplayNotify(msg)
	local txt = msg:ReadString()
	GAMEMODE:AddNotify(txt, msg:ReadShort(), msg:ReadLong())

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
include("cl_deathnotice.lua")
include("cl_helpvgui.lua")

surface.CreateFont("akbar", 20, 500, true, false, "AckBarWriting")

function GetTextHeight(font, str)
	surface.SetFont(font)
	local w, h = surface.GetTextSize(str)
	return h
end

function DrawPlayerInfo(ply)
	if not ply:Alive() then return end

	local pos = ply:EyePos()

	pos.z = pos.z + 14
	pos = pos:ToScreen()

	if GetGlobalInt("nametag") == 1 then
		draw.DrawText(ply:Nick(), "TargetID", pos.x + 1, pos.y + 1, Color(0, 0, 0, 255), 1)
		draw.DrawText(ply:Nick(), "TargetID", pos.x, pos.y, team.GetColor(ply:Team()), 1)
	end

	if GetGlobalInt("jobtag") == 1 then
		draw.DrawText(ply:GetNWString("job"), "TargetID", pos.x + 1, pos.y + 21, Color(0, 0, 0, 255), 1)
		draw.DrawText(ply:GetNWString("job"), "TargetID", pos.x, pos.y + 20, Color(255, 255, 255, 200), 1)
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

	local owner = ent:GetNWEntity("owning_ent")
	local text = owner:Name() .. "'s\nMoney Printer"

	draw.DrawText(text, "TargetID", pos.x + 1, pos.y + 1, Color(0, 0, 0, 200), 1)
	draw.DrawText(text, "TargetID", pos.x, pos.y, Color(255, 255, 255, 200), 1)
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

function GM:HUDPaint()
	self.BaseClass:HUDPaint()

	local hx = 9
	local hy = ScrH() - 25
	local hw = 190
	local hh = 10

	if LocalPlayer():GetActiveWeapon().IAmControlling then return end
	draw.RoundedBox(6, hx - 8, hy - 90, hw + 30, hh + 110, Color(0, 0, 0, 100))

	draw.RoundedBox(6, hx - 4, hy - 4, hw + 8, hh + 8, Color(0, 0, 0, 200))

	if LocalPlayer():Health() > 0 then
		draw.RoundedBox(4, hx, hy, math.Clamp(hw * (LocalPlayer():Health() / 100), 0, 190), hh, Color(140, 0, 0, 180))
	end

	draw.DrawText(LocalPlayer():Health(), "TargetID", hx + hw / 2, hy - 6, Color(255, 255, 255, 200), 1)
	draw.DrawText("Job: " .. LocalPlayer():GetNWString("job") .. "\nWallet: " .. CUR .. LocalPlayer():GetNWInt("money") .. "", "TargetID", hx + 1, hy - 49, Color(0, 0, 150, 200), 0)
	draw.DrawText("Job: " .. LocalPlayer():GetNWString("job") .. "\nWallet: " .. CUR .. LocalPlayer():GetNWInt("money") .. "", "TargetID", hx, hy - 50, Color(0, 0, 0, 255), 0)
	draw.DrawText("Salary: " .. CUR .. LocalPlayer():GetNWInt("salary"), "TargetID", hx + 1, hy - 70, Color(0, 150, 0, 200), 0)
	draw.DrawText("Salary: " .. CUR .. LocalPlayer():GetNWInt("salary"), "TargetID", hx, hy - 71, Color(0, 0, 0, 255), 0)


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
			local pos = LocalPlayer():GetEyeTrace().HitPos:ToScreen()
			
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

			if tr.Entity:IsOwnable() then
				local ownerstr = ""
				local ent = ents.GetByIndex(tr.Entity:EntIndex())

				if ent:GetNWInt("Ownerz") > 0 then
					if ValidEntity(player.GetByID(ent:GetNWInt("Ownerz"))) then
						ownerstr = player.GetByID(ent:GetNWInt("Ownerz")):Nick() .. "\n"
					end
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
						ownerstr = ownerstr .. "You are allowed to co-own this door\n(Press reload with keys to co-own)"
					elseif ent:GetNWInt("Allowed" .. n) > -1 then
						if ValidEntity(player.GetByID(ent:GetNWInt("Allowed" .. n))) then
							ownerstr = ownerstr .. player.GetByID(ent:GetNWInt("Allowed" .. n)):Nick() .. " is allowed to co-own this door\n"
						end
					end
				end

				if not LocalPlayer():InVehicle() then
					local blocked = ent:GetNWBool("nonOwnable")
					local st = nil
					local whiteText = false -- false for red, true for white text

					if ent:IsOwned() then
						whiteText = true

						if superAdmin then
							if blocked then
								st = ent:GetNWString("dTitle") .. "\n(Press reload with keys to allow ownership)"
							else
								if ownerstr == "" then
									st = ent:GetNWString("title") .. "\n(Press reload with keys to disallow ownership)"
								else
									if ent:OwnedBy(LocalPlayer()) then
										st = ent:GetNWString("title") .. "\nOwned by:\n" .. ownerstr
									else
										st = ent:GetNWString("title") .. "\nOwned by:\n" .. ownerstr .. "(Press reload with keys to disallow ownership)"
									end
								end
							end
						else
							if blocked then
								st = ent:GetNWString("dTitle")
							else
								if ownerstr == "" then
									st = ent:GetNWString("title")
								else
									st = ent:GetNWString("title") .. "\nOwned by:\n" .. ownerstr
								end
							end
						end
					else
						if superAdmin then
							if blocked then
								whiteText = true
								st = ent:GetNWString("dTitle") .. "\n(Press reload with keys to allow ownership)"
							else
								st = "Unowned\n(Press reload with keys to own)\n(Press reload with keys to disallow ownership)"
							end
						else
							if blocked then
								whiteText = true
								st = ent:GetNWString("dTitle")
							else
								st = "Unowned\n(Press reload with keys to own)"
							end
						end
					end

					if whiteText then
						draw.DrawText(st, "TargetID", pos.x + 1, pos.y + 1, Color(0, 0, 0, 200), 1)
						draw.DrawText(st, "TargetID", pos.x, pos.y, Color(255, 255, 255, 200), 1)
					else
						draw.DrawText(st, "TargetID", pos.x + 1, pos.y + 1, Color(0, 0, 0, 255), 1)
						draw.DrawText(st, "TargetID", pos.x, pos.y, Color(128, 30, 30, 255), 1)
					end
				end
			end
		end

		if PanelNum > 0 then
			draw.RoundedBox(2, 0, 0, 100, 20, Color(0, 0, 0, 128))
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
			draw.DrawText("The Admin Tells You:", "GModToolName", ScrW() / 2 + 10, 10, Color(255, 255, 255, AdminTellAlpha), 1)
			draw.DrawText(AdminTellMsg, "ChatFont", ScrW() / 2 + 10, 65, Color(200, 30, 30, AdminTellAlpha), 1)
		end

		if not LocalPlayer():Alive() then
			draw.RoundedBox(0, 0, 0, ScrW(), ScrH(), Color(0,0,0,255))
			draw.SimpleText("New Life Rule: Do Not Revenge Arrest/Kill.", "ChatFont", ScrW() / 2 +10, ScrH() / 2 - 5, Color(200,0,0,255),1)
		end
	end

	if LocalPlayer():GetNWBool("helpMenu") then
		draw.RoundedBox(10, 10, 10, 860, 802, Color(0, 0, 0, 255))
		draw.RoundedBox(10, 12, 12, 856, 798, Color(51, 58, 51, 200))
		draw.RoundedBox(10, 12, 12, 856, 20, Color(0, 0, 70, 200))
		draw.DrawText("Chat commands - # of Connected Players:" .. #player.GetAll() .. "/" .. MaxPlayers() .. "", "ScoreboardText", 30, 12, Color(255,0,0,255),0)
		draw.DrawText("- Money -\n/give <Amount> - Give money to another player (aim at them first)\n/dropmoney <Amount> - Drop some cash where you are aiming\n\n- Pistols -\n/buypistol deagle (" .. CUR .. tostring(GetGlobalInt("deaglecost")) .. ") (" .. CUR .. tostring(math.ceil(GetGlobalInt("deaglecost") * 0.88)) .. " for Gun Dealers)\n/buypistol glock (" .. CUR .. tostring(GetGlobalInt("glockcost")) .. ") (" .. CUR .. tostring(math.ceil(GetGlobalInt("glockcost") * 0.88)) .. " for Gun Dealers)\n/buypistol fiveseven (" .. CUR .. tostring(GetGlobalInt("fivesevencost")) .. ") (" .. CUR .. tostring(math.ceil(GetGlobalInt("fivesevencost") * 0.88)) .. " for Gun Dealers)\n/buypistol p228 (" .. CUR .. tostring(GetGlobalInt("p228cost")) .. ") (" .. CUR .. tostring(math.ceil(GetGlobalInt("p228cost") * 0.88)) .. " for Gun Dealers)\n\n- Rifle Shipments -\n/buyshipment ak47 (" .. CUR .. tostring(GetGlobalInt("ak47cost")) .. ") - Possibly illegal to own (ask Mayor or Admin)\n/buyshipment sniper (" .. CUR .. tostring(GetGlobalInt("snipercost")) .. ") - Possibly illegal to own (ask Mayor or Admin)\n/buyshipment mp5 (" .. CUR .. tostring(GetGlobalInt("mp5cost")) .. ") - Possibly illegal to own (ask Mayor or Admin)\n/buyshipment m16 (" .. CUR .. tostring(GetGlobalInt("m16cost")) .. ") - Possibly illegal to own (ask Mayor or Admin)\n/buyshipment shotgun (" .. CUR .. tostring(GetGlobalInt("shotguncost")) .. ") - Possibly illegal to own (ask Mayor or Admin)\n/buyshipment mac10 (" .. CUR .. tostring(GetGlobalInt("mac10cost")) .. ") - Possibly illegal to own (ask Mayor or Admin)\n\n- Ammo -\n/buyammo pistol (" .. CUR .. tostring(GetGlobalInt("ammopistolcost")) .. ")\n/buyammo shotgun (" .. CUR .. tostring(GetGlobalInt("ammoshotguncost")) .. ")\n/buyammo rifle (" .. CUR .. tostring(GetGlobalInt("ammoriflecost")) .. ")\n\n- Items-\n/buydruglab (" .. CUR .. tostring(GetGlobalInt("druglabcost")) .. ") - Definitely illegal to own, earns you " .. CUR .. tostring(GetGlobalInt("drugpayamount")) .. " per minute\n/buymicrowave (" .. CUR .. tostring(GetGlobalInt("microwavecost")) .. ") - Cook only, aim and use /price <Amount> to set the customer price.\n/buygunlab (" .. CUR .. tostring(GetGlobalInt("gunlabcost")) .. ") - Gun Dealer only, aim and use /price <Amount> to set the customer price.\n/buymoneyprinter (" .. CUR .. tostring(GetGlobalInt("mprintercost")) .. ") - Prints " .. CUR .. tostring(GetGlobalInt("mprintamount")) .. " every so often. It's fragile, so look after it!\n\n- Jobs -\n/mobboss - Makes you the Mob Boss\n/gangster - Makes you a Gangster\n/medic - Makes you a Medic\n/gundealer - Makes you a Gun Dealer\n/cook - Makes you a cook\n/votecop - Start a vote to become a cop\n/votemayor - Start a vote to become the Mayor\n\n- Doors -\n/title - Set the title of a door.\n/addowner (or /ao) [Nick|SteamID|Status ID] - Allow the named player to co-own this door\n/removeowner (or /ro) [Nick|SteamID|Status ID] - Remove the named player's co-ownership of your door\n\n- Other -\n/buyhealth (" .. CUR .. tostring(GetGlobalInt("healthcost")) .. ")\n/drop drops the weapon you are currently holding\n/sleep - Fall asleep or wake up\n/adminhelp - List of admin commands", "ScoreboardText", 30, 30, Color(255,255,255,255),0)
	end

	if LocalPlayer():GetNWBool("helpCop") then
		draw.RoundedBox(10, 10, 10, 590, 194, Color(0, 0, 0, 255))
		draw.RoundedBox(10, 12, 12, 586, 190, Color(51, 58, 51, 200))
		draw.RoundedBox(10, 12, 12, 586, 20, Color(0, 0, 70, 200))
		draw.DrawText("Cop Help", "ScoreboardText", 30, 12, Color(255,0,0,255),0)
		draw.DrawText("Things Cops need to know-\n-Please don't abuse your job\n-When you arrest someone they are auto transported to jail.\n-They are auto let out of jail after " .. GetGlobalInt("jailtimer") .. " seconds\n-Type /warrant [Nick|SteamID|Status ID] to set a search warrant for a player.\n-Type /wanted [Nick|SteamID|Status ID] to alert everyone to a wanted suspect\n-Type /unwanted [Nick|SteamID|Status ID] to clear the suspect\n-Type /jailpos to set the jail position\n-Type /cophelp to toggle this menu, /x to close it", "ScoreboardText", 30, 35, Color(255,255,255,255),0)
		--[[ local CloseX = vgui.Create("DSysButton")
		CloseX:SetPos(580, 10)
		CloseX:SetSize(16,16)
		CloseX:SetType( "close" ) 
		CloseX.DoClick = function(button) RunConsoleCommand("rp_CloseHelpScreen") self:Close() end ]]
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
		draw.DrawText("/zombiehelp Shows you how to setup zombie mode\n/enablestorm enables meteor storms\n/disablestorm Disables meteor storms\n\nYou can change the price of weapons, jailtimer, max gangsters, ect.\nTo do this press F1 then scroll down and you will see all of the console commands\nIf you edit the init.lua file you can save the vars.\n/jailpos sets the jailposition!\n/setspawn <team> - Enter teamname Ex. police, mayor, gangster\n/adminhelp toggles this menu, /x closes it", "ScoreboardText", 30, 35, Color(255,255,255,255),0)
	end

	if LocalPlayer():GetNWBool("helpZombie") then
		draw.RoundedBox(10, 10, 10, 860, 230, Color(0, 0, 0, 255))
		draw.RoundedBox(10, 12, 12, 856, 226, Color(51, 58, 51, 200))
		draw.RoundedBox(10, 12, 12, 856, 20, Color(0, 0, 70, 200))
		draw.DrawText("Zombie Help", "ScoreboardText", 30, 12, Color(255,0,0,255),0)
		draw.DrawText("/addzombie (creates a zombie spawn)\n/removezombie index (removes a zombie spawn, index is the number inside ()\n/showzombie (shows where the zombie spawns are)\n/enablezombie (enables zombiemode)\n/disablezombie (disables zombiemode)\n/zombiehelp (toggles this menu, /x to close)\n\nAll the zombie commands are admin only, the spawns are saved on different maps so you\ncan have a different set of zombie spawns depending on which map you are on.\nThe zombie spawns file is located in garrysmod/data/DarkRP if it ever becomes corrupt just delete it. /x to close", "ScoreboardText", 30, 35, Color(255,255,255,255),0)
	end

	if LocalPlayer():Team() == TEAM_GANG or LocalPlayer():Team() == TEAM_MOB then
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
		draw.DrawText("Mob Boss Help", "ScoreboardText", 30, 12, Color(255,0,0,255),0)
		draw.DrawText("As the Mob Boss, you decide what you want the other Gangsters to do\nYou get an Unarrest Stick which you can use to break people out of jail\n/agenda <Message> (Sets the Gangsters' agenda. Use // to go to the next line\nType /mobbosshelp toggles this menu, /x closes it", "ScoreboardText", 30, 35, Color(255,255,255,255),0)
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

LetterY = 0
LetterAlpha = -1
LetterMsg = ""
LetterType = 0
LetterStartTime = 0
LetterPos = Vector(0, 0, 0)

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
	if LetterAlpha > -1 and LocalPlayer():GetPos():Distance(LetterPos) > 125 then LetterAlpha = -1 end
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

	for k, v in pairs(VoteVGUI) do
		v:SetMouseInputEnabled(GUIToggled)
	end

	for k, v in pairs(QuestionVGUI) do
		v:SetMouseInputEnabled(GUIToggled)
	end
end
usermessage.Hook("ToggleClicker", ToggleClicker)

function AddHelpLabel(msg)
	local id = msg:ReadShort()
	local category = msg:ReadShort()
	local text = msg:ReadString()
	local constant = msg:ReadShort()

	local function tAddHelpLabel(id, category, text, constant)
		for k, v in pairs(HelpLabels) do
			if v.id == id then
				v.text = text
				return
			end
		end

		table.insert(HelpLabels, { id = id, category = category, text = text, constant = constant })
	end

	timer.Simple(.01, tAddHelpLabel, id, category, text, constant)
end
usermessage.Hook("AddHelpLabel", AddHelpLabel)

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

function AddHelpCategory(msg)
	local id = msg:ReadShort()
	local text = msg:ReadString()

	local function tAddHelpCategory(id, text)
		table.insert(HelpCategories, { id = id, text = text })
	end

	timer.Simple(.01, tAddHelpCategory, id, text)
end
usermessage.Hook("AddHelpCategory", AddHelpCategory)

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
