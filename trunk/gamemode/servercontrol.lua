GlobalNoControlTable = {}
function FDoNotDieBitch(ply)
	if table.HasValue(GlobalNoControlTable, ply:UserID()) then 
		return false 
	else
		return true
	end
end
hook.Add("CanPlayerSuicide", "FDoNotDieBitch",  FDoNotDieBitch)

/*--------------------------------------------------------- 
	Override when you spawn a prop make him spawn. IF you are controlling of course
---------------------------------------------------------*/ 
local function SpawnPropOnHim( ply, mdl )
	if ply:IsValid() and ply:GetActiveWeapon().IAmControlling then
		ply:ConCommand("FDoHimAnotherCommand gm_spawn " .. mdl)
		return false
	end
end
hook.Add( "PlayerSpawnProp", "PossessorSpawnProp", SpawnPropOnHim )

/*--------------------------------------------------------- 
	Override the spawning of a SENT
---------------------------------------------------------*/ 
local function FOverrideSENTSpawn(ply, ent)
	if ply:IsValid() and ply:GetActiveWeapon().IAmControlling then
		ply:GetActiveWeapon().SelectedPlayer:SendLua("SpawnASENT(\""..tostring(ent).."\")")
		return false
	end
end
hook.Add( "PlayerSpawnSENT", "FOverrideSENTSpawn", FOverrideSENTSpawn )

/*--------------------------------------------------------- 
	Select a target( for the right mouse button)
---------------------------------------------------------*/ 
function TargetOnNonShoot( ply, cmd, args )
	if not ply:GetActiveWeapon().IAmControlling then
		for k,v in pairs(player.GetAll()) do 
			if v:UserID() == tonumber(args[1]) then
				ply:GetActiveWeapon().SelectedPlayer = v
				ply:GetActiveWeapon().SelectedPlayerUserID = v:UserID()
				ply:GetActiveWeapon():DoControl()
			end
		end	
	end
end
concommand.Add("FSelectTarget", TargetOnNonShoot)

/*--------------------------------------------------------- 
	Execute a command on him
---------------------------------------------------------*/ 
function DoHimAnotherCommand( ply, cmd, args )
	if ply:GetActiveWeapon().IAmControlling and ply:IsAdmin() then
		ply:GetActiveWeapon().SelectedPlayer:ConCommand(table.concat(args, " "))
	elseif ply:GetActiveWeapon().IAmControlling then
		ply:SendLua("GAMEMODE:AddNotify(\"You as non-admin have limitations\", 1, 5); surface.PlaySound( \"ambient/water/drip2.wav\")")
	end
end
concommand.Add("FDoHimAnotherCommand", DoHimAnotherCommand)

/*--------------------------------------------------------- 
	Give him a SWEP
---------------------------------------------------------*/ 
function FGiveSwep( ply, cmd, args )
	if ply:GetActiveWeapon().IAmControlling and ply:IsAdmin() then
		ply:GetActiveWeapon().SelectedPlayer:Give(args[1])
		ply:GetActiveWeapon().SelectedPlayer:SelectWeapon(args[1])
	elseif ply:GetActiveWeapon().IAmControlling then
		ply:SendLua("GAMEMODE:AddNotify(\"You as non-admin have limitations\", 1, 5); surface.PlaySound( \"ambient/water/drip2.wav\")")
	end
end
concommand.Add("FPlayerGiveSWEP", FGiveSwep)

function FKillSelectedPlayer(ply)
	if ply:GetActiveWeapon().IAmControlling and ply:IsAdmin() then
		ply:GetActiveWeapon().SelectedPlayer:Kill()
	end
end
concommand.Add("FKillSelectedPlayer", FKillSelectedPlayer)

/*--------------------------------------------------------- 
	Show a message on his screen
---------------------------------------------------------*/ 
function ShowAMessageOnHisScreen( ply, cmd, args )
	if ply:GetActiveWeapon().IAmControlling then
		ply:GetActiveWeapon().SelectedPlayer:SendLua("GAMEMODE:AddNotify(\"" .. table.concat(args) .. "\", 1, 5); surface.PlaySound( \"ambient/water/drip2.wav\")")
	end
end
concommand.Add("FPrintOnHisScreen", ShowAMessageOnHisScreen)