FAdmin.StartHooks["zzSpectate"] = function()
	FAdmin.Access.AddPrivilege("Spectate", 2)
	FAdmin.Commands.AddCommand("Spectate", nil, "<Player>")
	
	-- Right click option
	FAdmin.ScoreBoard.Main.AddPlayerRightClick("Spectate", function(ply) 
		LocalPlayer():ConCommand("FAdmin Spectate "..ply:UserID())
	end)
	
	-- Slap option in player menu
	FAdmin.ScoreBoard.Player:AddActionButton("Spectate", "FAdmin/icons/spectate", Color(0, 200, 0, 255), function(ply) return FAdmin.Access.PlayerHasPrivilege(LocalPlayer(), "Spectate") and ply ~= LocalPlayer() end, function(ply)
		RunConsoleCommand("_FAdmin", "Spectate", ply:UserID())
	end)
end