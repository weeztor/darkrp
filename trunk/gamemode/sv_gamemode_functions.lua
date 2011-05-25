require("datastream")
/*---------------------------------------------------------
 Gamemode functions
 ---------------------------------------------------------*/
-- Grammar corrections by Eusion
function GM:Initialize()
	self.BaseClass:Initialize()
end

function GM:PlayerSpawnProp(ply, model)
	if not self.BaseClass:PlayerSpawnProp(ply, model) then return false end

	-- If prop spawning is enabled or the user has admin or prop privileges
	local allowed = ((GetConVarNumber("propspawning") == 1 or (FAdmin and FAdmin.Access.PlayerHasPrivilege(ply, "rp_prop")) or ply:IsAdmin()) and true) or false

	if RPArrestedPlayers[ply:SteamID()] then return false end
	model = string.gsub(tostring(model), "\\", "/")
	if string.find(model,  "//") then Notify(ply, 1, 4, "You can't spawn this prop as it contains an invalid path. " ..model) 
	DB.Log(ply:SteamName().." ("..ply:SteamID()..") tried to spawn prop with an invalid path "..model) return false end

	if allowed then
		if GetConVarNumber("proppaying") == 1 then
			if ply:CanAfford(GetConVarNumber("propcost")) then
				Notify(ply, 0, 4, "Deducted " .. CUR .. GetConVarNumber("propcost"))
				ply:AddMoney(-GetConVarNumber("propcost"))
				return true
			else
				Notify(ply, 1, 4, "Need " .. CUR .. GetConVarNumber("propcost"))
				return false
			end
		else
			return true
		end
	end
	return false
end

function GM:PlayerSpawnSENT(ply, model)
	return self.BaseClass:PlayerSpawnSENT(ply, model) and not RPArrestedPlayers[ply:SteamID()]
end

function GM:PlayerSpawnSWEP(ply, model)
	return self.BaseClass:PlayerSpawnSWEP(ply, model) and not RPArrestedPlayers[ply:SteamID()]
end

function GM:PlayerSpawnEffect(ply, model)
	return self.BaseClass:PlayerSpawnEffect(ply, model) and not RPArrestedPlayers[ply:SteamID()]
end

function GM:PlayerSpawnVehicle(ply, model)
	return self.BaseClass:PlayerSpawnVehicle(ply, model) and not RPArrestedPlayers[ply:SteamID()]
end

function GM:PlayerSpawnNPC(ply, model)
	return self.BaseClass:PlayerSpawnNPC(ply, model) and not RPArrestedPlayers[ply:SteamID()]
end

function GM:PlayerSpawnRagdoll(ply, model)
	return self.BaseClass:PlayerSpawnRagdoll(ply, model) and not RPArrestedPlayers[ply:SteamID()]
end

function GM:PlayerSpawnedProp(ply, model, ent)
	self.BaseClass:PlayerSpawnedProp(ply, model, ent)
	ent.SID = ply.SID
	ent.Owner = ply
end

function GM:PlayerSpawnedRagdoll(ply, model, ent)
	self.BaseClass:PlayerSpawnedRagdoll(ply, model, ent)
	ent.SID = ply.SID
end

function GM:EntityRemoved(ent)
	self.BaseClass:EntityRemoved(ent)
	if ent:IsVehicle() then
		local found = ent.Owner
		if ValidEntity(found) then
			found.Vehicles = found.Vehicles or 1
			found.Vehicles = found.Vehicles - 1
		end
	end
	
	for k,v in pairs(DarkRPEntities or {}) do
		if ent:IsValid() and ent:GetClass() == v.ent and ent.dt and ValidEntity(ent.dt.owning_ent) and not ent.IsRemoved then
			local ply = ent.dt.owning_ent
			local cmdname = string.gsub(v.ent, " ", "_")
			if not ply["max"..cmdname] then
				ply["max"..cmdname] = 1
			end
			ply["max"..cmdname] = ply["max"..cmdname] - 1
			ent.IsRemoved = true
		end
	end
end

function GM:ShowSpare1(ply)
	umsg.Start("ToggleClicker", ply)
	umsg.End()
end

function GM:ShowSpare2(ply)
	umsg.Start("ChangeJobVGUI", ply)
	umsg.End()
end

function GM:OnNPCKilled(victim, ent, weapon)
	-- If something killed the npc
	if ent then
		if ent:IsVehicle() and ent:GetDriver():IsPlayer() then ent = ent:GetDriver() end

		-- If it wasn't a player directly, find out who owns the prop that did the killing
		if not ent:IsPlayer() then
			ent = Player(ent.SID)
		end

		-- If we know by now who killed the NPC, pay them.
		if ValidEntity(ent) and GetConVarNumber("npckillpay") > 0 then
			ent:AddMoney(GetConVarNumber("npckillpay"))
			Notify(ent, 0, 4, string.format(LANGUAGE.npc_killpay, CUR .. GetConVarNumber("npckillpay")))
		end
	end
end

function GM:KeyPress(ply, code)
	self.BaseClass:KeyPress(ply, code)

	/*if code == IN_USE then
		local trace = { }
		trace.start = ply:EyePos()
		trace.endpos = trace.start + ply:GetAimVector() * 95
		trace.filter = ply
		local tr = util.TraceLine(trace)
		
		-- Begin trading server-side (Although this appears to be unstable, don't worry, I've planned the system out, I've just not implemented the update completely).
		-- Note: Uncomplete; Please leave for Eusion to complete. :)
		if ValidEntity(tr.Entity) and tr.Entity:IsPlayer() then
			ply.Trading = nil
			local recipient = tr.Entity
			local items = {}
			for k, v in pairs(ents.GetAll()) do
				local owner = (v.dt and v.dt.owning_ent) or nil
				if owner and ValidEntity(owner) and owner == ply then
					table.insert(items, v)
				end
			end
			if #items > 0 then
				datastream.StreamToClients(ply, "darkrp_trade", items)
				items = {}
				ply.Trading = recipient
			else
				Notify(ply, 1, 4, "You have no items that you can trade.")
			end
		end
	end*/
end
/*
local AllowedTrades = {"money_printer"}
concommand.Add("rp_tradeitem", function(ply, cmd, args)
	local ent = Entity(tonumber(args[1]))
	local owner = (ent.dt and ent.dt.owning_ent) or nil
	local recipient = ply.Trading or nil
	if owner and owner == ply and ValidEntity(ent) and recipient and ValidEntity(recipient) then
		if table.HasValue(AllowedTrades, ent:GetClass()) then
			vote:Trade(tonumber(ply:EntIndex()), ply, recipient, ent)
		else
			Notify(ply, 1, 4, "An administrator has forbidden trades using this item!")
		end
	else
		Notify(ply, 1, 4, "Can't trade at this time.")
	end
end)

concommand.Add("rp_killtrade", function(ply, cmd, args)
	local id = args[1]
	if not Trades[id] then return end
	local recipient = Trades[id].recipient
	local client = Trades[id].client
	if not recipient then return end
	if not client then return end
	if not id then return end
	if (ply == client or ply == recipient) then
		local rf = RecipientFilter()
		rf:AddPlayer(client)
		rf:AddPlayer(recipient)
		umsg.Start("darkrp_killtrade", rf)
			umsg.Entity(ply) -- Send the player who declined.
		umsg.End()
		Trades[id] = {}
		table.remove(Trades, id)
	end
end)*/

local function IsInRoom(listener, talker) -- IsInRoom function to see if the player is in the same room.
	local tracedata = {}
	tracedata.start = talker:GetShootPos()
	tracedata.endpos = listener:GetShootPos()
	local trace = util.TraceLine( tracedata )
	
	return not trace.HitWorld
end

function GM:PlayerCanHearPlayersVoice(listener, talker, other)
	if listener.DarkRPVars and talker.DarkRPVars and ValidEntity(listener.DarkRPVars.phone) and ValidEntity(talker.DarkRPVars.phone) and listener == talker.DarkRPVars.phone.Caller then 
		return true, tobool(GetConVarNumber("3dvoice"))
	elseif talker.DarkRPVars and ValidEntity(talker.DarkRPVars.phone) then
		return false, tobool(GetConVarNumber("3dvoice"))
	end
	
	if GetConVarNumber("voiceradius") == 1 and listener:GetShootPos():Distance(talker:GetShootPos()) < 550 then
		if GetConVarNumber("dynamicvoice") == 1 then
			if IsInRoom( listener, talker ) then
				return true, tobool(GetConVarNumber("3dvoice"))
			else
				return false, tobool(GetConVarNumber("3dvoice"))
			end
		end
		return true, tobool(GetConVarNumber("3dvoice"))
	elseif GetConVarNumber("voiceradius") == 1 then
		return false, tobool(GetConVarNumber("3dvoice"))
	end
	return true, tobool(GetConVarNumber("3dvoice"))
end

function GM:CanTool(ply, trace, mode)
	if not self.BaseClass:CanTool(ply, trace, mode) then return false end

	if ValidEntity(trace.Entity) then
		if trace.Entity.onlyremover then
			if mode == "remover" then
				return (ply:IsAdmin() or ply:IsSuperAdmin())
			else
				return false
			end
		end

		if trace.Entity.nodupe and (mode == "weld" or
					mode == "weld_ez" or
					mode == "spawner" or
					mode == "duplicator" or
					mode == "adv_duplicator") then
			return false
		end

		if trace.Entity:IsVehicle() and mode == "nocollide" and GetConVarNumber("allowvnocollide") == 0 then
			return false
		end
	end
	return true
end

function GM:CanPlayerSuicide(ply)
	if ply.IsSleeping then
		Notify(ply, 1, 4, string.format(LANGUAGE.unable, "suicide"))
		return false
	end
	if RPArrestedPlayers[ply:SteamID()] then
		Notify(ply, 1, 4, string.format(LANGUAGE.unable, "suicide"))
		return false
	end
	return true
end

function GM:DoPlayerDeath(ply, attacker, dmginfo, ...)
	if tobool(GetConVarNumber("dropweapondeath")) and ValidEntity(ply:GetActiveWeapon()) then
		ply:DropWeapon(ply:GetActiveWeapon())
	end
	ply:CreateRagdoll()
	ply:AddDeaths( 1 )
	if ValidEntity(attacker) and attacker:IsPlayer() then
		if attacker == ply then
			attacker:AddFrags(-1)
		else
			attacker:AddFrags(1)
		end
	end
end

function GM:PlayerDeath(ply, weapon, killer)
	if tobool(GetConVarNumber("deathblack")) then
		local RP = RecipientFilter()
		RP:RemoveAllPlayers()
		RP:AddPlayer(ply)
		umsg.Start("DarkRPEffects", RP)
			umsg.String("colormod")
			umsg.String("1")
		umsg.End()
		RP:AddAllPlayers()
	end
	if tobool(GetConVarNumber("deathpov")) then
		SendUserMessage("DarkRPEffects", ply, "deathPOV", "1")
	end
	UnDrugPlayer(ply)

	if weapon:IsVehicle() and weapon:GetDriver():IsPlayer() then killer = weapon:GetDriver() end
	
	local KillerName = (killer:IsPlayer() and killer:Nick()) or killer:GetClass()
	ServerLog(ply:Nick().." was killed by "..KillerName.." with "..weapon:GetClass())
	
	if GetConVarNumber("deathnotice") == 1 then
		self.BaseClass:PlayerDeath(ply, weapon, killer)
	else
		for k,v in pairs(player.GetAll()) do
			if v:IsAdmin() then
				v:PrintMessage(HUD_PRINTCONSOLE, ply:Nick().." was killed by "..KillerName.." with "..weapon:GetClass())
			end
		end
	end

	ply:Extinguish()

	if ply:InVehicle() then ply:ExitVehicle() end

	if RPArrestedPlayers[ply:SteamID()] and not tobool(GetConVarNumber("respawninjail"))  then
		-- If the player died in jail, make sure they can't respawn until their jail sentance is over
		ply.NextSpawnTime = CurTime() + math.ceil(GetConVarNumber("jailtimer") - (CurTime() - ply.LastJailed)) + 1
		for a, b in pairs(player.GetAll()) do
			b:PrintMessage(HUD_PRINTCENTER, string.format(LANGUAGE.died_in_jail, ply:Nick()))
		end 
		Notify(ply, 4, 4, LANGUAGE.dead_in_jail)
	else
		-- Normal death, respawning.
		ply.NextSpawnTime = CurTime() + math.Clamp(GetConVarNumber("respawntime"), 0, 3)
	end
	ply.DeathPos = ply:GetPos()
	
	if tobool(GetConVarNumber("dropmoneyondeath")) then
		local amount = GetConVarNumber("deathfee")
		if not ply:CanAfford(GetConVarNumber("deathfee")) then
			amount = ply.DarkRPVars.money
		end
		
		if amount > 0 then
			ply:AddMoney(-amount)
			DarkRPCreateMoneyBag(ply:GetPos(), amount)
		end
	end

	if GetConVarNumber("dmautokick") == 1 and killer and killer:IsPlayer() and killer ~= ply then
		if not killer.kills or killer.kills == 0 then
			killer.kills = 1
			timer.Simple(GetConVarNumber("dmgracetime"), killer.ResetDMCounter, killer)
		else
			-- If this player is going over their limit, kick their ass
			if killer.kills + 1 > GetConVarNumber("dmmaxkills") then
				game.ConsoleCommand("kickid " .. killer:UserID() .. " Auto-kicked. Excessive Deathmatching.\n")
			else
				-- Killed another player
				killer.kills = killer.kills + 1
			end
		end
	end

	if ValidEntity(ply) and (ply ~= killer or ply.Slayed) and not RPArrestedPlayers[ply:SteamID()] then
		ply:SetDarkRPVar("wanted", false)
		ply.DeathPos = nil
		ply.Slayed = false
	end
	
	ply:GetTable().ConfisquatedWeapons = nil
	if tobool(GetConVarNumber("droppocketdeath")) then
		if ply.Pocket then 
			for k, v in pairs(ply.Pocket) do
				if ValidEntity(v) then
					v:SetMoveType(MOVETYPE_VPHYSICS)
					v:SetNoDraw(false)
					v:SetCollisionGroup(4)
					v:SetPos(ply:GetPos() + Vector(0,0,10))
					local phys = v:GetPhysicsObject()
					if phys:IsValid() then
						phys:EnableCollisions(true)
						phys:Wake()
					end
				end
			end
		end
		ply.Pocket = nil
	end
	if weapon:IsPlayer() then weapon = weapon:GetActiveWeapon() killer = killer:SteamName() if ( !weapon || weapon == NULL ) then weapon = killer else weapon = weapon:GetClass() end end
	if killer == ply then killer = "Himself" weapon = "suicide trick" end
	DB.Log(ply:SteamName() .. " was killed by "..tostring(killer) .. " with a "..tostring(weapon))
end

function GM:PlayerCanPickupWeapon(ply, weapon)
	if RPArrestedPlayers[ply:SteamID()] then return false end
	if ply:IsAdmin() and GetConVarNumber("AdminsCopWeapons") == 1 then return true end
	if GetConVarNumber("license") == 1 and not ply.DarkRPVars.HasGunlicense and not ply:GetTable().RPLicenseSpawn then
		if GetConVarNumber("licenseweapon_"..string.lower(weapon:GetClass())) == 1 or not weapon:IsWeapon() then
			return true
		end
		return false
	end
	return true
end

local function removelicense(ply) 
	if not ValidEntity(ply) then return end 
	ply:GetTable().RPLicenseSpawn = false 
end

local function SetPlayerModel(ply, cmd, args)
	if not args[1] then return end
	ply.rpChosenModel = args[1]
end
concommand.Add("_rp_ChosenModel", SetPlayerModel)

function GM:PlayerSetModel(ply)
	local EndModel = ""
	if GetConVarNumber("enforceplayermodel") == 1 then
		local TEAM = RPExtraTeams[ply:Team()]
		
		if type(TEAM.model) == "table" then
			local ChosenModel = ply.rpChosenModel or ply:GetInfo("rp_playermodel")
			ChosenModel = string.lower(ChosenModel)
			
			local found
			for _,Models in pairs(TEAM.model) do
				if ChosenModel == string.lower(Models) then
					EndModel = Models
					found = true
					break
				end
			end
			
			if not found then
				EndModel = TEAM.model[math.random(#TEAM.model)]
			end
		else
			EndModel = TEAM.model
		end

		ply:SetModel(EndModel)
	else
		local cl_playermodel = ply:GetInfo( "cl_playermodel" )
        local modelname = player_manager.TranslatePlayerModel( cl_playermodel )
        ply:SetModel( modelname )
	end
end

function GM:PlayerInitialSpawn(ply)
	self.BaseClass:PlayerInitialSpawn(ply)
	DB.Log(ply:SteamName().." ("..ply:SteamID()..") has joined the game")
	ply.bannedfrom = {}
	ply.DarkRPVars = {}
	ply:NewData()
	ply.SID = ply:UserID()
	DB.RetrieveSalary(ply, function() end)
	DB.RetrieveMoney(ply)
	if GetConVarNumber("DarkRP_Lockdown") == 1 then
		RunConsoleCommand("DarkRP_Lockdown", 1 ) -- so new players who join know there's a lockdown
	end
	timer.Simple(10, ply.CompleteSentence, ply)
end

local meta = FindMetaTable("Player")
function meta:SetDarkRPVar(var, value)
	if not ValidEntity(self) then return end
	self.DarkRPVars = self.DarkRPVars or {}
	self.DarkRPVars[var] = value
	umsg.Start("DarkRP_PlayerVar")
		umsg.Entity(self)
		umsg.String(var)
		if value == nil then value = "nil" end
		umsg.String(tostring(value))
	umsg.End()
end

local function SendDarkRPVars(ply)
	if ply.DarkRPVarsSent and ply.DarkRPVarsSent > (CurTime() - 1) then return end --prevent spammers
	ply.DarkRPVarsSent = CurTime()
	
	local sendtable = {}
	for k,v in pairs(player.GetAll()) do
		sendtable[v] = v.DarkRPVars
	end
	datastream.StreamToClients(ply, "DarkRP_InitializeVars", sendtable)
end
concommand.Add("_sendDarkRPvars", SendDarkRPVars)

function GM:PlayerSelectSpawn(ply)
	local POS = self.BaseClass:PlayerSelectSpawn(ply)
	if POS.GetPos then 
		POS = POS:GetPos()
	else
		POS = ply:GetPos()
	end 
	
	
	local CustomSpawnPos = DB.RetrieveTeamSpawnPos(ply)
	if GetConVarNumber("customspawns") == 1 and not RPArrestedPlayers[ply:SteamID()] and CustomSpawnPos then
		POS = CustomSpawnPos[math.random(1, #CustomSpawnPos)]
	end
	
	-- Spawn where died in certain cases
	if GetConVarNumber("strictsuicide") == 1 and ply:GetTable().DeathPos then
		POS = ply:GetTable().DeathPos
	end
	
	if RPArrestedPlayers[ply:SteamID()] then
		POS = DB.RetrieveJailPos() or ply:GetTable().DeathPos -- If we can't find a jail pos then we'll use where they died as a last resort
	end
	
	if not IsEmpty(POS) then
		local found = false
		for i = 40, 300, 15 do
			if IsEmpty(POS + Vector(i, 0, 0)) then
				POS = POS + Vector(i, 0, 0)
				-- Yeah I found a nice position to put the player in!
				found = true
				break
			end
		end
		if not found then
			for i = 40, 300, 15 do
				if IsEmpty(POS + Vector(0, i, 0)) then
					POS = POS + Vector(0, i, 0)
					found = true
					break
				end
			end
		end
		if not found then
			for i = 40, 300, 15 do
				if IsEmpty(POS + Vector(0, -i, 0)) then
					POS = POS + Vector(0, -i, 0)
					found = true
					break
				end
			end
		end
		if not found then
			for i = 40, 300, 15 do
				if IsEmpty(POS + Vector(-i, 0, 0)) then
					POS = POS + Vector(-i, 0, 0)
					-- Yeah I found a nice position to put the player in!
					found = true
					break
				end
			end
		end
		-- If you STILL can't find it, you'll just put him on top of the other player lol
		if not found then
			POS = POS + Vector(0,0,70)
		end
	end
	return self.BaseClass:PlayerSelectSpawn(ply), POS
end

function GM:PlayerSpawn(ply)
	ply:CrosshairEnable()
	ply:UnSpectate()
	ply:SetHealth(tonumber(GetConVarNumber("startinghealth")) or 100)

	if GetConVarNumber("xhair") == 0 then
		ply:CrosshairDisable()
	end
	
	SendUserMessage("DarkRPEffects", ply, "deathPOV", "0") -- No checks to prevent bugs
	
	-- Kill any colormod
	local RP = RecipientFilter()
	RP:RemoveAllPlayers()
	RP:AddPlayer(ply)
	umsg.Start("DarkRPEffects", RP)
		umsg.String("colormod")
		umsg.String("0")
	umsg.End()
	RP:AddAllPlayers()

	if GetConVarNumber("babygod") == 1 and not ply.IsSleeping then
		ply.Babygod = true
		ply:GodEnable()
		local r,g,b,a = ply:GetColor()
		ply:SetColor(r, g, b, 100)
		ply:SetCollisionGroup(  COLLISION_GROUP_WORLD )
		timer.Simple(GetConVarNumber("babygodtime"), function()
			if not ValidEntity(ply) then return end
			ply.Babygod = false
			ply:SetColor(r, g, b, a)
			ply:GodDisable()
			ply:SetCollisionGroup( COLLISION_GROUP_PLAYER )
		end)
	end
	ply.IsSleeping = false
	
	GAMEMODE:SetPlayerSpeed(ply, GetConVarNumber("wspd"), GetConVarNumber("rspd"))
	if ply:Team() == TEAM_CHIEF or ply:Team() == TEAM_POLICE then
		GAMEMODE:SetPlayerSpeed(ply, GetConVarNumber("wspd"), GetConVarNumber("rspd") + 10)
	end
	
	if RPArrestedPlayers[ply:SteamID()] then
		GAMEMODE:SetPlayerSpeed(ply, GetConVarNumber("aspd"), GetConVarNumber("aspd"))
	end

	ply:Extinguish()
	if ply:GetActiveWeapon() and ValidEntity(ply:GetActiveWeapon()) then
		ply:GetActiveWeapon():Extinguish()
	end
	
	for k,v in pairs(ents.FindByClass("predicted_viewmodel")) do -- Money printer ignite fix
		v:Extinguish()
	end

	if ply.demotedWhileDead then
		ply.demotedWhileDead = nil
		ply:ChangeTeam(TEAM_CITIZEN)
	end
	
	ply:GetTable().StartHealth = ply:Health()
	gamemode.Call("PlayerSetModel", ply)
	gamemode.Call("PlayerLoadout", ply)
	DB.Log(ply:SteamName().." ("..ply:SteamID()..") spawned")
	
	local _, pos = self:PlayerSelectSpawn(ply)
	ply:SetPos(pos)
end

function GM:PlayerLoadout(ply)
	if RPArrestedPlayers[ply:SteamID()] then return end
	
	ply:GetTable().RPLicenseSpawn = true
	timer.Simple(1, removelicense, ply)
	
	local Team = ply:Team() or 1
	
	ply:Give("keys")
	ply:Give("weapon_physcannon")
	ply:Give("gmod_camera")
	
	if GetConVarNumber("toolgun") == 1 or (FAdmin and FAdmin.Access.PlayerHasPrivilege(ply, "rp_tool")) or ply:IsAdmin()  then
		ply:Give("gmod_tool")
	end
	
	if GetConVarNumber("pocket") == 1 then
		ply:Give("pocket")
	end
	
	if GetConVarNumber("physgun") == 1 or (FAdmin and FAdmin.Access.PlayerHasPrivilege(ply, "rp_phys")) or ply:IsAdmin() then
		ply:Give("weapon_physgun")
	end
	
	if ply:HasPriv("rp_commands") and GetConVarNumber("AdminsCopWeapons") == 1 then
		ply:Give("door_ram")
		ply:Give("arrest_stick")
		ply:Give("unarrest_stick")
		ply:Give("stunstick")
		ply:Give("weaponchecker")
	end

	if not RPExtraTeams[Team] then return end
	for k,v in pairs(RPExtraTeams[Team].Weapons) do
		ply:Give(v)
	end
	
	-- Switch to prefered weapon if they have it
	local cl_defaultweapon = ply:GetInfo( "cl_defaultweapon" )
	
	if ply:HasWeapon( cl_defaultweapon ) then
		ply:SelectWeapon( cl_defaultweapon )
	end
end

function GM:PlayerDisconnected(ply)
	self.BaseClass:PlayerDisconnected(ply)
	timer.Destroy(ply:SteamID() .. "jobtimer")
	timer.Destroy(ply:SteamID() .. "propertytax")
	
	for k, v in pairs( ents.GetAll() ) do
		local class = v:GetClass()
		if (class == "money_printer" or class == "microwave" or class == "gunlab" or class == "letter" or class == "drug_lab" or class == "drug" or v:IsVehicle()) and v.SID == ply.SID then
			v:Remove()
		end
	end
		
	vote.DestroyVotesWithEnt(ply)
	
	if ply:Team() == TEAM_MAYOR and tobool(GetConVarNumber("DarkRP_LockDown")) then -- Stop the lockdown
		UnLockdown(ply)
	end
	
	if ValidEntity(ply.SleepRagdoll) then
		ply.SleepRagdoll:Remove()
	end
	
	ply:UnownAll()
	DB.Log(ply:SteamName().." ("..ply:SteamID()..") disconnected")
end

local function PlayerDoorCheck()
	for k, ply in pairs(player.GetAll()) do
		local trace = ply:GetEyeTrace()
		if ValidEntity(trace.Entity) and (trace.Entity:IsDoor() or trace.Entity:IsVehicle()) and ply.LookingAtDoor ~= trace.Entity and trace.HitPos:Distance(ply:GetShootPos()) < 410 then
			ply.LookingAtDoor = trace.Entity -- Variable that prevents streaming to clients every frame
			
			trace.Entity.DoorData = trace.Entity.DoorData or {}
			
			local DoorString = "Data:\n"
			for key, v in pairs(trace.Entity.DoorData) do
				DoorString = DoorString .. key.."\t\t".. tostring(v) .. "\n"
			end
			
			if not ply.DRP_DoorMemory or not ply.DRP_DoorMemory[trace.Entity] then
				datastream.StreamToClients(ply, "DarkRP_DoorData", {trace.Entity, trace.Entity.DoorData})
				ply.DRP_DoorMemory = ply.DRP_DoorMemory or {}
				ply.DRP_DoorMemory[trace.Entity] = table.Copy(trace.Entity.DoorData)
			else
				for key, v in pairs(trace.Entity.DoorData) do
					if not ply.DRP_DoorMemory[trace.Entity][key] or ply.DRP_DoorMemory[trace.Entity][key] ~= v then
						ply.DRP_DoorMemory[trace.Entity][key] = v
						umsg.Start("DRP_UpdateDoorData", ply)
							umsg.Entity(trace.Entity)
							umsg.String(key)
							umsg.String(tostring(v))
						umsg.End()
					end
				end
				
				for key, v in pairs(ply.DRP_DoorMemory[trace.Entity]) do
					if not trace.Entity.DoorData[key] then
						ply.DRP_DoorMemory[trace.Entity][key] = nil
						umsg.Start("DRP_UpdateDoorData", ply)
							umsg.Entity(trace.Entity)
							umsg.String(key)
							umsg.String("nil")
						umsg.End()
					end
				end
			end
		elseif ply.LookingAtDoor ~= trace.Entity then
			ply.LookingAtDoor = nil
		end
	end
end
timer.Create("RP_DoorCheck", 0.1, 0, PlayerDoorCheck)

function GM:GetFallDamage( ply, flFallSpeed )
	if GetConVarNumber("mp_falldamage") == 1 then
		return flFallSpeed / 15
	end
	return 10
end

function GM:InitPostEntity() 
	timer.Simple(2, function()
		if RP_MySQLConfig and RP_MySQLConfig.EnableMySQL then
			DB.ConnectToMySQL(RP_MySQLConfig.Host, RP_MySQLConfig.Username, RP_MySQLConfig.Password, RP_MySQLConfig.Database_name, RP_MySQLConfig.Database_port)
			return
		end
		DB.Init()
	end)
end

hook.Add("WeaponEquip", "AmmoHackFix", function( wep )
	if wep.ammohacked and wep.Primary then
		local clip = wep.Primary.ClipSize
		wep:TakePrimaryAmmo(clip)
	end
end)