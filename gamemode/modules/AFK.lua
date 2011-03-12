-- How to use:
-- Use rp_afk_demote 1 to enable AFK mode.
-- Use rp_afk_demotetime to set the time someone has to be AFK before they are demoted.
-- If a player uses /afk, they go into AFK mode, they will not be autodemoted and their salary is set to $0 (you can still be killed/vote demoted though!).
-- If a player does not use /afk, and they don't do anything for the demote time specified, they will be automatically demoted to hobo.

includeCS("AFK/cl_afk.lua")
AddToggleCommand("rp_afk_demote", "afkdemote", 0)
AddValueCommand("rp_afk_demotetime", "afkdemotetime", 600)
AddHelpLabel(-1, HELP_CATEGORY_ADMINCMD, "rp_afk_demote <1/0> - If set to 1, players who don't do anything for ".. GetConVarNumber("afkdemotetime") .." seconds will be demoted if they do not use AFK mode.")
AddHelpLabel(-1, HELP_CATEGORY_ADMINCMD, "rp_afk_demotetime <time> - Sets the time a player has to be AFK for before they are demoted (in seconds).")

local function AFKDemote(ply)
	local rpname = ply.DarkRPVars.rpname
	if ply.DarkRPVars.AFK then return
	elseif ply:Team() ~= TEAM_CITIZEN then
		ply:ChangeTeam(TEAM_CITIZEN, true)
		ply:SetDarkRPVar("AFKDemoted", true)
		NotifyAll(1, 5, rpname .. " has been demoted for being AFK for too long.")
	end
	ply:SetDarkRPVar("job", "AFK")
end

local function StartAFKOnPlayer(ply)
	ply:SetDarkRPVar("AFK", true)
	local demotetime
	if GetConVarNumber("afkdemote") == 0 then
		demotetime = math.huge
	else
		demotetime = GetConVarNumber("afkdemotetime")
	end
	ply.AFKDemote = CurTime() + demotetime
end
hook.Add("PlayerInitialSpawn", "StartAFKOnPlayer", StartAFKOnPlayer)

local function ToggleAFK(ply)
	if GetConVarNumber("afkdemote") == 0 then
		Notify( ply, 1, 5, "AFK mode is disabled.")
		return ""
	end
	local rpname = ply.DarkRPVars.rpname
	if not ply.DarkRPVars.AFK then
		ply:SetDarkRPVar("AFK", true)
		DB.RetrieveSalary(ply, function(amount) ply.OldSalary = amount end)
		ply.OldJob = ply.DarkRPVars.job
		ply:SetDarkRPVar("job", "AFK")
		DB.StoreSalary(ply, 0)
		NotifyAll(1, 5, rpname .. " is now AFK.")
		umsg.Start("DarkRPEffects", ply)
			umsg.String("colormod")
			umsg.String("1")
		umsg.End()
		for k, v in pairs(team.GetAllTeams()) do
			ply.bannedfrom[k] = 1
		end
	else
		ply:SetDarkRPVar("AFK", false)
		DB.StoreSalary(ply, ply.OldSalary)
		NotifyAll(1, 5, rpname .. " is no longer AFK.")
		Notify(ply, 1, 5, "Welcome back, your salary has now been restored.")
		ply:SetDarkRPVar("job", ply.OldJob)
		umsg.Start("DarkRPEffects", ply)
			umsg.String("colormod")
			umsg.String("0")
		umsg.End()
		for k, v in pairs(team.GetAllTeams()) do
			ply.bannedfrom[k] = 0
		end
	end
	return ""
end
AddChatCommand("/afk", ToggleAFK)

local function AFKTimer(ply, key)
	if GetConVarNumber("afkdemote") == 0 then return end
	ply.AFKDemote = CurTime() + GetConVarNumber("afkdemotetime")
	if ply.DarkRPVars.AFKDemoted then
		ply:SetDarkRPVar("job", "Citizen")
		timer.Simple(3, function() ply:SetDarkRPVar("AFKDemoted", false) end)
	end
end
hook.Add("KeyPress", "DarkRPKeyReleasedCheck", AFKTimer)

local function KillAFKTimer()
	for id, ply in pairs(player.GetAll()) do 
		if ply.AFKDemote and CurTime() > ply.AFKDemote then
			AFKDemote(ply)
			ply.AFKDemote = math.huge
		end
	end
end
hook.Add("Think", "DarkRPKeyPressedCheck", KillAFKTimer)