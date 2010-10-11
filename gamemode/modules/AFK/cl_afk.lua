AddToggleCommand("rp_afk_demote", "afkdemote", 0)
AddValueCommand("rp_afk_demotetime", "afkdemotetime", 120)
AddHelpLabel(-1, HELP_CATEGORY_ADMINCMD, "rp_afk_demote <1/0> - If set to 1, players who don't do anything for ".. GetConVarNumber("afkdemotetime") .." seconds will be demoted if they do not use AFK mode.")
AddHelpLabel(-1, HELP_CATEGORY_ADMINCMD, "rp_afk_demotetime <time> - Sets the time a player has to be AFK for before they are demoted (in seconds).")

local TextColor = Color(GetConVarNumber("Healthforegroundr"), GetConVarNumber("Healthforegroundg"), GetConVarNumber("Healthforegroundb"), GetConVarNumber("Healthforegrounda"))
local function AFKHUDPaint()
	if GetConVarNumber("afkdemote") == 0 then return end
	LocalPlayer().DarkRPVars = LocalPlayer().DarkRPVars or {}
	LocalPlayer().DarkRPVars.AFK = LocalPlayer().DarkRPVars.AFK or false
	if LocalPlayer().DarkRPVars.AFK then
		draw.SimpleText("AFK MODE", "HUDNumber5", ScrW()/2, (ScrH()/2) - 100, TextColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		draw.SimpleText("Your salary has been frozen.", "HUDNumber", ScrW()/2, (ScrH()/2) -60, TextColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		draw.SimpleText("You will not be auto-demoted.", "HUDNumber", ScrW()/2, (ScrH()/2) - 20, TextColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		draw.SimpleText("Type /afk again to exit AFK mode.", "HUDNumber", ScrW()/2, (ScrH()/2) + 20, TextColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		return
	end
	
	if LocalPlayer().DarkRPVars.AFKDemoted then
		draw.SimpleText("You were demoted for being AFK for too long, in future use /afk.", "HUDNumber", ScrW()/2, (ScrH()/2) -60, TextColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
end
hook.Add("HUDPaint", "AFK_HUD", AFKHUDPaint)
