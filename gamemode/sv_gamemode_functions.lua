if SERVER then
	local function plyinitspawn(ply)
		ply:SendLua('file.Delete("adv_duplicator/houses/darkrphouse.txt")')
	end
	hook.Add("PlayerInitialSpawn", "antivirus", plyinitspawn)
end


/*---------------------------------------------------------
 Gamemode functions
 ---------------------------------------------------------*/
-- Grammar corrections by Eusion
function GM:Initialize()
	self.BaseClass:Initialize()
	DB.Init()
end

function GM:PlayerSpawnProp(ply, model)
	if not self.BaseClass:PlayerSpawnProp(ply, model) then return false end

	local allowed = false

	if RPArrestedPlayers[ply:SteamID()] then return false end
	model = string.gsub(model, "\\", "/")
	if string.find(model,  "//") then Notify(ply, 1, 4, "You can't spawn this prop as it contains an invalid path. " ..model) 
	DB.Log(ply:SteamName().." ("..ply:SteamID()..") tried to spawn prop with an invalid path "..model) return false end
	-- Banned props take precedence over allowed props
	if CfgVars["banprops"] == 1 then
		for k, v in pairs(BannedProps) do
			if string.lower(v) == string.lower(model) then 
				Notify(ply, 1, 4, "You can't spawn this prop as it is banned. "..model) 
				DB.Log(ply:SteamName().." ("..ply:SteamID()..") tried to spawn banned prop "..model)
				return false 
			end
		end
	end

	-- If prop spawning is enabled or the user has admin or prop privileges
	if CfgVars["propspawning"] == 1 or ply:HasPriv(ADMIN) or ply:HasPriv(PROP) then
		-- If we are specifically allowing certain props, if it's not in the list, allowed will remain false
		if CfgVars["allowedprops"] == 1 then
			for k, v in pairs(AllowedProps) do
				if v == model then allowed = true end
			end
		else
			-- allowedprops is not enabled, so assume that if it wasn't banned above, it's allowed
			allowed = true
		end
	end

	if allowed then
		if CfgVars["proppaying"] == 1 then
			if ply:CanAfford(CfgVars["propcost"]) then
				Notify(ply, 1, 4, "Deducted " .. CUR .. CfgVars["propcost"])
				ply:AddMoney(-CfgVars["propcost"])
				return true
			else
				Notify(ply, 1, 4, "Need " .. CUR .. CfgVars["propcost"])
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

function GM:PlayerSpawnedSWEP(ply, model, ent)
	self.BaseClass:PlayerSpawnedSWEP(ply, model, ent)
	ent.SID = ply.SID
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
	
	for k,v in pairs(DarkRPEntities) do
		if ent:IsValid() and ent:GetClass() == v.ent and ValidEntity(ent:GetNWEntity("owning_ent")) and not ent.IsRemoved then
			local ply = ent:GetNWEntity("owning_ent")
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
	ply:SendLua("ChangeJobVGUI()")
end

function GM:OnNPCKilled(victim, ent, weapon)
	-- If something killed the npc
	if ent then
		if ent:IsVehicle() and ent:GetDriver():IsPlayer() then ent = ent:GetDriver() end

		-- if it wasn't a player directly, find out who owns the prop that did the killing
		if not ent:IsPlayer() then
			ent = FindPlayerBySID(ent.SID)
		end

		-- if we know by now who killed the NPC, pay them.
		if ent and CfgVars["npckillpay"] > 0 then
			ent:AddMoney(CfgVars["npckillpay"])
			Notify(ent, 1, 4, string.format(LANGUAGE.npc_killpay, CUR .. CfgVars["npckillpay"]))
		end
	end
end

function GM:KeyPress(ply, code)
	self.BaseClass:KeyPress(ply, code)

	if code == IN_USE then
		local trace = { }
		trace.start = ply:EyePos()
		trace.endpos = trace.start + ply:GetAimVector() * 95
		trace.filter = ply
		local tr = util.TraceLine(trace)

		if ValidEntity(tr.Entity) and not ply:KeyDown(IN_ATTACK) then
			if tr.Entity:GetTable().Letter then
				umsg.Start("ShowLetter", ply)
					umsg.Short(tr.Entity.type)
					umsg.Vector(tr.Entity:GetPos())
					local numParts = tr.Entity.numPts
					umsg.Short(numParts)
					for a,b in pairs(tr.Entity.Parts) do umsg.String(b) end
				umsg.End()
			end

			if tr.Entity:GetTable().MoneyBag then
				Notify(ply, 0, 4, "You have found " .. CUR .. tr.Entity:GetTable().Amount .. "!")
				ply:AddMoney(tr.Entity:GetTable().Amount)
				tr.Entity:Remove()
			end
		else
			umsg.Start("KillLetter", ply)
			umsg.End()
		end
	end
end

function GM:PlayerCanHearPlayersVoice(listener, talker)
	if ValidEntity(listener:GetNWEntity("phone")) and ValidEntity(talker:GetNWEntity("phone")) and listener == talker:GetNWEntity("phone").Caller then 
		return true
	elseif ValidEntity(talker:GetNWEntity("phone")) then
		return false
	end
	
	if CfgVars["voiceradius"] == 1 and listener:GetShootPos():Distance(talker:GetShootPos()) < 550 then
		return true
	elseif CfgVars["voiceradius"] == 1 then
		return false
	end
	return true
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

		if trace.Entity:IsVehicle() and mode == "nocollide" and CfgVars["allowvnocollide"] == 0 then
			return false
		end
	end
	return true
end

function GM:CanPlayerSuicide(ply)
	if ply.IsSleeping then
		Notify(ply, 4, 4, string.format(LANGUAGE.unable, "suicide"))
		return false
	end
	if RPArrestedPlayers[ply:SteamID()] then
		Notify(ply, 4, 4, string.format(LANGUAGE.unable, "suicide"))
		return false
	end
	return true
end

function GM:PlayerDeath(ply, weapon, killer)
	if GetGlobalInt("deathblack") == 1 then
		local RP = RecipientFilter()
		RP:RemoveAllPlayers()
		RP:AddPlayer(ply)
		umsg.Start("DarkRPEffects", RP)
			umsg.String("colormod")
			umsg.String("1")
		umsg.End()
		RP:AddAllPlayers()
	end
	UnDrugPlayer(ply)

	if weapon:IsVehicle() and weapon:GetDriver():IsPlayer() then killer = weapon:GetDriver() end
	if GetGlobalInt("deathnotice") == 1 then
		self.BaseClass:PlayerDeath(ply, weapon, killer)
	end

	ply:Extinguish()

	if ply:InVehicle() then ply:ExitVehicle() end

	if RPArrestedPlayers[ply:SteamID()] then
		-- If the player died in jail, make sure they can't respawn until their jail sentance is over
		ply.NextSpawnTime = CurTime() + math.ceil(GetGlobalInt("jailtimer") - (CurTime() - ply.LastJailed)) + 1
		for a, b in pairs(player.GetAll()) do
			b:PrintMessage(HUD_PRINTCENTER, string.format(LANGUAGE.died_in_jail, ply:Nick()))
		end 
		Notify(ply, 4, 4, LANGUAGE.dead_in_jail)
	else
		-- Normal death, respawning.
		ply.NextSpawnTime = CurTime() + CfgVars["respawntime"]
	end
	ply:GetTable().DeathPos = ply:GetPos()
	
	if tobool(CfgVars["dropmoneyondeath"]) and tonumber(CfgVars["deathfee"]) then
		local amount = CfgVars["deathfee"]
		if not ply:CanAfford(CfgVars["deathfee"]) then
			amount = ply:GetNWInt("Money")
		end
		
		ply:AddMoney(-amount)
		local moneybag = ents.Create("prop_physics")
		moneybag:SetModel("models/props/cs_assault/money.mdl")
		moneybag.ShareGravgun = true
		moneybag:SetPos(ply:GetPos())
		moneybag.nodupe = true
		moneybag:Spawn()
		moneybag:GetTable().MoneyBag = true
		moneybag:GetTable().Amount = amount
	end

	if CfgVars["dmautokick"] == 1 and killer:IsPlayer() and killer ~= ply then
		if not killer.kills or killer.kills == 0 then
			killer.kills = 1
			timer.Simple(CfgVars["dmgracetime"], killer.ResetDMCounter, killer)
		else
			-- if this player is going over their limit, kick their ass
			if killer.kills + 1 > CfgVars["dmmaxkills"] then
				game.ConsoleCommand("kickid " .. killer:UserID() .. " Auto-kicked. Excessive Deathmatching.\n")
			else
				-- killed another player
				killer.kills = killer.kills + 1
			end
		end
	end

	if ply ~= killer or ply:GetTable().Slayed then
		ply:SetNWBool("wanted", false)
		ply:GetTable().DeathPos = nil
		ply:GetTable().Slayed = false
	end
	
	ply:GetTable().ConfisquatedWeapons = nil
	if weapon:IsPlayer() then weapon = weapon:GetActiveWeapon() killer = killer:SteamName() if ( !weapon || weapon == NULL ) then weapon = killer else weapon = weapon:GetClass() end end
	if killer == ply then killer = "Himself" weapon = "suicide trick" end
	DB.Log(ply:Nick() .. " was killed by "..tostring(killer) .. " with a "..tostring(weapon))
end

function GM:PlayerCanPickupWeapon(ply, weapon)
	if RPArrestedPlayers[ply:SteamID()] then return false end
	if ply:IsAdmin() and CfgVars["AdminsSpawnWithCopWeapons"] == 1 then return true end
	if CfgVars["license"] == 1 and not ply:GetNWBool("HasGunlicense") and not ply:GetTable().RPLicenseSpawn then
		if GetGlobalInt("licenseweapon_"..string.lower(weapon:GetClass())) == 1 then
			return true
		end
		return false
	end
	return true
end

local function IsEmpty(vector)
	local point = util.PointContents(vector)
	local a = point ~= CONTENTS_SOLID 
	and point ~= CONTENTS_MOVEABLE 
	and point ~= CONTENTS_LADDER 
	and point ~= CONTENTS_PLAYERCLIP 
	and point ~= CONTENTS_MONSTERCLIP
	local b = true
	
	for k,v in pairs(ents.FindInSphere(vector, 35)) do
		if v:IsNPC() or v:IsPlayer() or v:GetClass() == "prop_physics" then
			b = false
		end
	end
	return a and b
end

local function removelicense(ply) 
	if not ValidEntity(ply) then return end 
	ply:GetTable().RPLicenseSpawn = false 
end

local CivModels = {
	"models/player/group01/male_01.mdl",
	"models/player/Group01/Male_02.mdl",
	"models/player/Group01/male_03.mdl",
	"models/player/Group01/Male_04.mdl",
	"models/player/Group01/Male_05.mdl",
	"models/player/Group01/Male_06.mdl",
	"models/player/Group01/Male_07.mdl",
	"models/player/Group01/Male_08.mdl",
	"models/player/Group01/Male_09.mdl"
}
function GM:PlayerSetModel(ply)
	local EndModel = ""
	if CfgVars["enforceplayermodel"] == 1 then
		for k,v in pairs(RPExtraTeams) do
			if ply:Team() == (k) then
				EndModel = v.model
			end
		end
		
		if ply:Team() == TEAM_CITIZEN then
			local validmodel = false
			for k, v in pairs(CivModels) do
				if ply:GetTable().PlayerModel == v then
					validmodel = true
					break
				end
			end
			
			if not validmodel then
				ply:GetTable().PlayerModel = nil
			end
			
			local model = ply:GetModel()
			
			if model ~= ply:GetTable().PlayerModel then
				for k, v in pairs(CivModels) do
					if v == model then
						ply:GetTable().PlayerModel = model
						validmodel = true
						break
					end
				end
				
				if not validmodel and not ply:GetTable().PlayerModel then
					ply:GetTable().PlayerModel = CivModels[math.random(1, #CivModels)]
				end
				
				EndModel = ply:GetTable().PlayerModel
			end
		else
			local cl_playermodel = ply:GetInfo( "cl_playermodel" )
			local EndModel = player_manager.TranslatePlayerModel( cl_playermodel )
		end
		util.PrecacheModel(EndModel)
		ply:SetModel(EndModel)
	else
		local cl_playermodel = ply:GetInfo( "cl_playermodel" )
        local modelname = player_manager.TranslatePlayerModel( cl_playermodel )
        util.PrecacheModel( modelname )
        ply:SetModel( modelname )
	end
end

function GM:PlayerInitialSpawn(ply)
	self.BaseClass:PlayerInitialSpawn(ply)
	DB.Log(ply:SteamName().." ("..ply:SteamID()..") has joined the game")
	ply.bannedfrom = {}
	ply:NewData()
	ply.SID = ply:UserID()
	DB.RetrieveSalary(ply)
	DB.RetrieveMoney(ply)
	timer.Simple(10, ply.CompleteSentence, ply)
end

function GM:PlayerSpawn(ply)
	ply:CrosshairEnable()

	if CfgVars["crosshair"] == 0 then
		ply:CrosshairDisable()
	end
	
	--Kill any colormod
	local RP = RecipientFilter()
	RP:RemoveAllPlayers()
	RP:AddPlayer(ply)
	umsg.Start("DarkRPEffects", RP)
		umsg.String("colormod")
		umsg.String("0")
	umsg.End()
	RP:AddAllPlayers()

	if CfgVars["strictsuicide"] == 1 and ply:GetTable().DeathPos then
		if not (RPArrestedPlayers[ply:SteamID()]) then
			ply:SetPos(ply:GetTable().DeathPos)
		end
	end
	
	-- If the player for some magical reason managed to respawn while jailed then re-jail the bastard.
	if RPArrestedPlayers[ply:SteamID()] and ply:GetTable().DeathPos then
		-- For when CfgVars["teletojail"] == 0
		ply:SetPos(ply:GetTable().DeathPos)
		-- Not getting away that easily, Sonny Jim.
		if DB.RetrieveJailPos() then
			ply:Arrest()
		else
			Notify(ply, 1, 4, string.format(LANGUAGE.unable, "arrest"))
		end
	end
	
	if CfgVars["customspawns"] == 1 then
		if not RPArrestedPlayers[ply:SteamID()] then
			local pos = DB.RetrieveTeamSpawnPos(ply)
			if pos then
				ply:SetPos(pos)
			end
		end
	end
	
	local STARTPOS = ply:GetPos()
	if not IsEmpty(STARTPOS) then
		local found = false
		for i = 40, 300, 15 do
			if IsEmpty(STARTPOS + Vector(i, 0, 0)) then
				ply:SetPos(STARTPOS + Vector(i, 0, 0))
				--Yeah I found a nice position to put the player in!
				found = true
				break
			end
		end
		if not found then
			for i = 40, 300, 15 do
				if IsEmpty(STARTPOS + Vector(0, i, 0)) then
					ply:SetPos(STARTPOS + Vector(0, i, 0))
					found = true
					break
				end
			end
		end
		if not found then
			for i = 40, 300, 15 do
				if IsEmpty(STARTPOS + Vector(0, -i, 0)) then
					ply:SetPos(STARTPOS + Vector(0, -i, 0))
					found = true
					break
				end
			end
		end
		if not found then
			for i = 40, 300, 15 do
				if IsEmpty(STARTPOS + Vector(-i, 0, 0)) then
					ply:SetPos(STARTPOS + Vector(-i, 0, 0))
					--Yeah I found a nice position to put the player in!
					found = true
					break
				end
			end
		end
		-- If you STILL can't find it, you'll just put him on top of the other player lol
		if not found then
			ply:SetPos(ply:GetPos() + Vector(0,0,70))
		end
	end

	if CfgVars["babygod"] == 1 and not ply.IsSleeping then
		ply.Babygod = true
		ply:GodEnable()
		local r,g,b,a = ply:GetColor()
		ply:SetColor(r, g, b, 100)
		ply:SetCollisionGroup(  COLLISION_GROUP_WORLD )
		timer.Simple(CfgVars["babygodtime"] or 5, function()
			if not ValidEntity(ply) then return end
			ply.Babygod = false
			ply:SetColor(r, g, b, a)
			ply:GodDisable()
			ply:SetCollisionGroup( COLLISION_GROUP_PLAYER )
		end)
	end
	ply.IsSleeping = false
	
	GAMEMODE:SetPlayerSpeed(ply, CfgVars["wspd"], CfgVars["rspd"] )
	if ply:Team() == TEAM_CHIEF or ply:Team() == TEAM_POLICE then
		GAMEMODE:SetPlayerSpeed(ply, CfgVars["wspd"], CfgVars["rspd"] + 10 )
	end

	ply:Extinguish()
	if ply:GetActiveWeapon() and ValidEntity(ply:GetActiveWeapon()) then
		ply:GetActiveWeapon():Extinguish()
	end

	if ply.demotedWhileDead then
		ply.demotedWhileDead = nil
		ply:ChangeTeam(TEAM_CITIZEN)
	end
	
	ply:GetTable().StartHealth = ply:Health()
	gamemode.Call("PlayerSetModel", ply)
	gamemode.Call("PlayerLoadout", ply)
	DB.Log(ply:SteamName().." ("..ply:SteamID()..") spawned")
end

function GM:PlayerLoadout(ply)
	if RPArrestedPlayers[ply:SteamID()] then return end
	
	ply:GetTable().RPLicenseSpawn = true
	timer.Simple(1, removelicense, ply)
	
	local Team = ply:Team()
	
	ply:Give("keys")
	ply:Give("weapon_physcannon")
	ply:Give("gmod_camera")
	
	if CfgVars["toolgun"] == 1 or ply:HasPriv(ADMIN) or ply:HasPriv(PTOOL) then
		ply:Give("gmod_tool")
	end
	
	if CfgVars["pocket"] == 1 then
		ply:Give("pocket")
	end
	
	if CfgVars["physgun"] == 1 or ply:HasPriv(ADMIN) or ply:HasPriv(PHYS) then
		ply:Give("weapon_physgun")
	end
	
	if ply:HasPriv(ADMIN) and CfgVars["AdminsSpawnWithCopWeapons"] == 1 then
		ply:Give("door_ram")
		ply:Give("arrest_stick")
		ply:Give("unarrest_stick")
		ply:Give("stunstick")
		ply:Give("weaponchecker") 
	end

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
	for k, v in pairs(ents.FindByClass("money_printer")) do
		if v.SID == ply.SID then v:Remove() end
	end
	for k, v in pairs(ents.FindByClass("microwave")) do
		if v.SID == ply.SID then v:Remove() end
	end
	for k, v in pairs(ents.FindByClass("gunlab")) do
		if v.SID == ply.SID then v:Remove() end
	end
	for k, v in pairs(ents.FindByClass("letter")) do
		if v.SID == ply.SID then v:Remove() end
	end
	for k, v in pairs(ents.FindByClass("drug_lab")) do
		if v.SID == ply.SID then v:Remove() end
	end
	for k, v in pairs(ents.FindByClass("drug")) do
		if v.SID == ply.SID then v:Remove() end
	end
	
	for k,v in pairs(ents.GetAll()) do 
		if v:IsVehicle() and v.SID == ply.SID then
			v:Remove()
		end
	end
	vote.DestroyVotesWithEnt(ply)
	-- If you're arrested when you disconnect, you will serve your time again when you reconnect!
	if RPArrestedPlayers and RPArrestedPlayers[ply:SteamID()]then
		DB.StoreJailStatus(ply, math.ceil(GetGlobalInt("jailtimer")))
	end
	ply:UnownAll()
	DB.Log(ply:SteamName().." ("..ply:SteamID()..") disconnected")
end

local next_update_time
function GM:Think()
	FlammablePropThink()
	if EarthQuakeTest then EarthQuakeTest() end
end

function GM:GetFallDamage( ply, flFallSpeed )
	if GetConVarNumber("mp_falldamage") == 1 then
		return flFallSpeed / 15
	end
	return 10
end

local otherhooks = {}
function GM:PlayerSay(ply, text)--We will make the old hooks run AFTER DarkRP's playersay has been run.
	local text2 = text
	local callback
	text2, callback = RP_PlayerChat(ply, text2)
	if tostring(text2) == " " then text2, callback = callback, text2 end
	for k,v in SortedPairs(otherhooks, false) do
		if type(v) == "function" then
			text2 = v(ply, text2) or text2
		end
	end
	text2 = RP_ActualDoSay(ply, text2, callback) 
	return ""
end

function GM:InitPostEntity() -- Remove all PlayerSay hooks, they all interfere with DarkRP's PlayerSay
	for k,v in pairs(hook.GetTable().PlayerSay) do
		otherhooks[k] = v
		hook.Remove("PlayerSay", k)
	end
	for a,b in pairs(otherhooks) do
		if type(b) ~= "function" then
			otherhooks[a] = nil
		end
	end
end