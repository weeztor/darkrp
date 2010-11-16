local function Spectate(ply, cmd, args)
	if not FAdmin.Access.PlayerHasPrivilege(ply, "Spectate") then FAdmin.Messages.SendMessage(ply, 5, "No access!") return end
	if not args[1] then return end
	
	local target = FAdmin.FindPlayer(args[1])
	target = target and target[1] or nil
	if not ValidEntity(target) or target == ply then return end
	
	ply:KillSilent()
	ply:Spectate(OBS_MODE_IN_EYE)
	ply:SpectateEntity(target)
	
	FAdmin.Messages.SendMessage(ply, 4, "You are now spectating "..target:Nick() .. " ("..target:SteamID()..")")
end

FAdmin.StartHooks["Spectate"] = function()
	FAdmin.Commands.AddCommand("Spectate", Spectate)
	
	FAdmin.Access.AddPrivilege("Spectate", 2)
end