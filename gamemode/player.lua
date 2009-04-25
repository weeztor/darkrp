if not RPArrestedPlayers then
	RPArrestedPlayers {}
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

local meta = FindMetaTable("Player")

-- Each time a player connects, they get a new ID
local sessionid = 0

function meta:InitSID()
	sessionid = sessionid + 1
	self.SID = sessionid
end


function meta:SetRPName(name, firstRun)
	-- Make sure nobody on this server already has this RP name
	local lowername = string.lower(tostring(name))
	local rpNames = DB.RetrieveRPNames()
	local taken = false

	for id, row in pairs(rpNames) do
		if row.name and lowername == string.lower(row.name) and row.steam ~= self:SteamID() then
			taken = true
		end
	end
	
	if string.len(lowername) < 3 then return end
	-- If we found that this name exists for another player
	if taken then
		if firstRun then
			-- If we just connected and another player happens to be using our steam name as their RP name
			-- Put a 1 after our steam name
			DB.StoreRPName(self, name .. " 1")
			Notify(self, 1, 12, "Someone is already using your Steam name as their RP name so we gave you a '1' after your name.")
		else
			Notify(self, 1, 5, "This RP name in use by another player on this server!")
		end
	else
		DB.StoreRPName(self, name)
	end
end

function meta:HasPriv(priv)
	return DB.HasPriv(self, priv)
end

function meta:GrantPriv(priv)
	return DB.GrantPriv(self, priv)
end

function meta:ChangeAllowed(t)
	if not self.bannedfrom then return true end
	if self.bannedfrom[t] == 1 then return false else return true end
end

function meta:ChangeTeam(t)
	if RPArrestedPlayers[self:SteamID()] then
		if not self:Alive() then
			Notify(self, 1, 4, "Can not change your job while dead in jail.")
			return
		else
			Notify(self, 1, 4, "You are in Jail. Get a new job when you have been released.")
			return
		end
	end

	self:SetNWBool("helpBoss",false)
	self:SetNWBool("helpCop",false)
	self:SetNWBool("helpMayor",false)
	
	if self:GetNWBool("HasGunlicense") and t ~= TEAM_POLICE and t ~= TEAM_CHIEF then
		self:SetNWBool("HasGunlicense", false)
	end

	if t ~= TEAM_CITIZEN and not self:ChangeAllowed(t) then
		Notify(self, 1, 4, "You're either banned from this team or you were demoted.)")
		return
	end

	if t == TEAM_CITIZEN then
		self:UpdateJob("Citizen")
		DB.StoreSalary(self, GetGlobalInt("normalsalary"))
		NotifyAll(1, 4, self:Name() .. " is now an ordinary Citizen!")
		local validmodel = false

		for k, v in pairs(CivModels) do
			if self:GetTable().PlayerModel == v then
				validmodel = true
				break
			end
		end

		if not validmodel then
			self:GetTable().PlayerModel = nil
		end

		local model = self:GetModel()

		if model ~= self:GetTable().PlayerModel then
			for k, v in pairs(CivModels) do
				if v == model then
					self:GetTable().PlayerModel = model
					validmodel = true
					break
				end
			end

			if not validmodel and not self:GetTable().PlayerModel then
				self:GetTable().PlayerModel = CivModels[math.random(1, #CivModels)]
			end

			self:SetModel(self:GetTable().PlayerModel)
		end
	elseif t == TEAM_POLICE then
		if self:Team() == t then
			Notify(self, 1, 4, "You're already a CP!")
			return
		end

		if team.NumPlayers(t) >= CfgVars["maxcps"] then
			Notify(self, 1, 4,  "Max CPs reached!")
			return
		end

		self:UpdateJob("Civil Protection")
		DB.StoreSalary(self, GetGlobalInt("normalsalary") + 20)
		self:SetNWBool("helpCop", true)
		self:SetNWBool("HasGunlicense", true)
		NotifyAll(1, 4, self:Name() .. " has been made a CP!")
		self:SetModel("models/player/police.mdl")
	elseif t == TEAM_MAYOR then
		if self:Team() == t then
			Notify(self, 1, 4, "You're already the Mayor!")
			return
		end

		if team.NumPlayers(t) >= 1 then
			Notify(self, 1, 4,  "Max Mayors reached!")
			return
		end

		if CfgVars["cptomayoronly"] == 1 and (self:Team() ~= TEAM_POLICE and self:Team() ~= TEAM_CHIEF) then
			Notify(self, 1, 4,  "You have to be in the Civil Protection first to become Mayor!")
			return
		end

		self:UpdateJob("Mayor")
		DB.StoreSalary(self, GetGlobalInt("normalsalary") + 40)
		self:SetNWBool("helpMayor", true)
		NotifyAll(1, 4, self:Name() .. " has been made Mayor!")
		self:SetModel("models/player/breen.mdl")
	elseif t == TEAM_GANG then
		if self:Team() == t then
			Notify(self, 1, 4, "You're already a Gangster!")
			return
		end
				
		if CfgVars["allowgang"] == 0 then
			Notify(self, 1, 4, "Gangs are disabled!")
			return
		end

		if team.NumPlayers(t) >= CfgVars["maxgangsters"] then
			Notify(self, 1, 4, "Max Gangsters reached!")
			return
		end

		self:UpdateJob("Gangster")
		DB.StoreSalary(self, GetGlobalInt("normalsalary") + 10)
		self:SetNWString("agenda", CfgVars["mobagenda"])
		NotifyAll(1, 4, self:Name() .. " has been made a Gangster!")
		self:SetModel("models/player/group03/male_01.mdl")
	elseif t == TEAM_MOB then
		if self:Team() == t then
			Notify(self, 1, 4, "You're already the Mob Boss!")
			return
		end
				
		if CfgVars["allowgang"] == 0 then
			Notify(self, 1, 4, "Gangs are disabled!")
			return
		end

		if team.NumPlayers(t) >= 1 then
			Notify(self, 1, 4, "Only one Mob Boss is allowed.")
			return
		end

		self:UpdateJob("Mob Boss")
		DB.StoreSalary(self, GetGlobalInt("normalsalary") + 15)
		self:SetNWBool("helpBoss", true)
		self:SetNWString("agenda", CfgVars["mobagenda"])
		NotifyAll(1, 4, self:Name() .. " has been made Mob Boss!")
		self:SetModel("models/player/gman_high.mdl")
	elseif t == TEAM_GUN then
		if self:Team() == t then
			Notify(self, 1, 4, "You're already a Gun Dealer!")
			return
		end

		if CfgVars["noguns"] == 1 then
			Notify(self, 1, 4, "Guns are disabled!")
			return
		end

		if CfgVars["allowdealers"] == 0 then
			Notify(self, 1, 4, "Gun Dealers are disabled!")
			return
		end

		if team.NumPlayers(t) >= CfgVars["maxgundealers"] then
			Notify(self, 1, 4,  "Max Gun Dealers reached!")
			return
		end

		self:UpdateJob("Gun Dealer")
		DB.StoreSalary(self, GetGlobalInt("normalsalary"))
		NotifyAll(1, 4, self:Name() .. " has been made a Gun Dealer!")
		self:SetModel("models/player/monk.mdl")
	elseif t == TEAM_MEDIC then
		if self:Team() == t then
			Notify(self, 1, 4, "You're already a Medic!")
			return
		end

		if CfgVars["allowmedics"] == 0 then
			Notify(self, 1, 4, "Medics are disabled!")
			return
		end

		if team.NumPlayers(t) >= CfgVars["maxmedics"] then
			Notify(self, 1, 4,  "Max Medics reached!")
			return
		end
		self:UpdateJob("Medic")
		DB.StoreSalary(self, GetGlobalInt("normalsalary") + 15)
		NotifyAll(1, 4, self:Name() .. " has been made a Medic!")
		self:SetModel("models/player/kleiner.mdl")
	elseif t == TEAM_COOK then
		if self:Team() == t then
			Notify(self, 1, 4, "You're already a Cook!")
			return
		end

		if CfgVars["allowcooks"] == 0 then
			Notify(self, 1, 4, "Cooks are disabled!")
			return
		end

		if team.NumPlayers(t) >= CfgVars["maxcooks"] then
			Notify(self, 1, 4,  "Max Cooks reached!")
			return
		end

		self:UpdateJob("Cook")
		DB.StoreSalary(self, GetGlobalInt("normalsalary"))
		NotifyAll(1, 4, self:Name() .. " has been made a Cook!")
		self:SetModel("models/player/mossman.mdl")
	elseif t == TEAM_CHIEF then
		if self:Team() == t then
			Notify(self, 1, 4, "You're already the Civil Protection Chief!")
			return
		end

		if self:Team() ~= TEAM_POLICE then
			Notify(self, 1, 4, "You must be a CP first in order to become Chief!")
			return
		end

		if team.NumPlayers(t) >= 1 then
			Notify(self, 1, 4,  "Max Civil Protection Chiefs reached")
			return
		end

		self:UpdateJob("Civil Protection Chief")
		DB.StoreSalary(self, GetGlobalInt("normalsalary") + 30)
		NotifyAll(1, 4, self:Name() .. " has been made Chief!")
		self:SetModel("models/player/combine_soldier_prisonguard.mdl")
		self:SetNWBool("HasGunlicense", true)
	end
	
	
	for k,v in pairs(RPExtraTeams) do
		if t == (9 + k) then
			if self:Team() == t then
				Notify(self, 1, 4, "You're already a " .. v.name .. "!")	
				return
			end
			if v.NeedToChangeFrom and self:Team() ~= v.NeedToChangeFrom then
				Notify(self, 1,4, "You have to be "..team.GetName(v.NeedToChangeFrom).." to become " .. team.GetName(t))
				return
			end
			if team.NumPlayers(t) >= v.max then
				Notify(self, 1, 4,  "Max "..v.name.." reached")
				return
			end
			self:UpdateJob(v.name)
			DB.StoreSalary(self, v.salary)
			NotifyAll(1, 4, self:Name() .. " has been made a " .. v.name .. "!")
			self:SetModel(v.model)
			if v.Haslicense then
				self:SetNWBool("HasGunlicense", true)
			end
		end
	end

	if CfgVars["removeclassitems"] == 1 then
		for k, v in pairs(ents.FindByClass("microwave")) do
			if v.SID == self.SID then v:Remove() end
		end
		for k, v in pairs(ents.FindByClass("gunlab")) do
			if v.SID == self.SID then v:Remove() end
		end
		
		if t ~= TEAM_MOB and t ~= TEAM_GANG then
			for k, v in pairs(ents.FindByClass("drug_lab")) do
				if v.SID == self.SID then v:Remove() end
			end
		end
		
		for k,v in pairs(ents.FindByClass("spawned_shipment")) do
			if v.SID == self.SID then v:Remove() end
		end
	end

	self:SetTeam(t)
	if self:InVehicle() then self:ExitVehicle() end
	if CfgVars["norespawn"] == 1 then
		self:StripWeapons()
		local vPoint = self:GetShootPos() + Vector(0,0,50)
		local effectdata = EffectData()
		effectdata:SetEntity(self)
		effectdata:SetStart( vPoint ) -- not sure if we need a start and origin (endpoint) for this effect, but whatever
		effectdata:SetOrigin( vPoint )
		effectdata:SetScale(1)
		util.Effect( "entity_remove", effectdata )	
		GAMEMODE:PlayerLoadout(self)
	else
		self:KillSilent()
	end
end

function meta:ResetDMCounter()
	if not ValidEntity(self) then return end
	self.kills = 0
	return true
end

function meta:CanAfford(amount)
	return math.floor(amount) >= 0 and DB.RetrieveMoney(self) - math.floor(amount) >= 0
end

function meta:AddMoney(amount)
	DB.StoreMoney(self, DB.RetrieveMoney(self) + math.floor(amount))
end

function meta:PayDay()
	if ValidEntity(self) and self:GetTable().Pay == 1 then
		if not RPArrestedPlayers[self:SteamID()] then
			local amount = math.floor(DB.RetrieveSalary(self))
			if amount == 0 then
				Notify(self, 4, 4, "You recieved no salary because you are unemployed!")
			else
				self:AddMoney(amount)
				Notify(self, 4, 4, "Payday! You received " .. CUR .. amount .. "!")
			end
		else
			Notify(self, 4, 4, "Pay day missed! (arrested)")
		end
	end
end

function meta:UpdateJob(job)
	self:SetNWString("job", job)
	self:GetTable().Pay = 1
	self:GetTable().LastPayDay = CurTime()

	local l = string.lower(job)

	if l == "unemployed" or l == "bum" or l == "hobo" then
		DB.StoreSalary(self, 0)
	else
		timer.Create(self:SteamID() .. "jobtimer", CfgVars["paydelay"], 0, self.PayDay, self)
	end
end

function meta:TeamUnBan(team)
	if not self.bannedfrom then self.bannedfrom = {} end
	self.bannedfrom[team] = 0
end

function meta:TeamBan()
	if not self.bannedfrom then self.bannedfrom = {} end
	self.bannedfrom[self:Team()] = 1
	timer.Simple(CfgVars["demotetime"], self.TeamUnBan, self, self:Team())
end

function meta:Arrest(time, rejoin)
	if self:GetNWBool("wanted") then
		self:SetNetworkedBool("wanted", false)
	end
	self:SetNWBool("HasGunlicense", false)
	GAMEMODE:SetPlayerSpeed(self, CfgVars["aspd"], CfgVars["aspd"] )
	-- Always get sent to jail when Arrest() is called, even when already under arrest
	if CfgVars["teletojail"] == 1 and DB.CountJailPos() and DB.CountJailPos() ~= 0 then
		self:SetPos(DB.RetrieveJailPos())
	end
	if not RPArrestedPlayers[self:SteamID()] or rejoin then
		local ID = self:SteamID()
		RPArrestedPlayers[ID] = true
		self:StripWeapons()
		self.LastJailed = CurTime()
		
		-- If the player has no remaining jail time,
		-- set it back to the max for this new sentence
		if not time or time == 0 then
			time = GetGlobalInt("jailtimer")
		end
		DB.StoreJailStatus(self, time)
		self:PrintMessage(HUD_PRINTCENTER, "You have been arrested for " .. time .. " seconds!")
		for k, v in pairs(player.GetAll()) do
			if v ~= self then
				v:PrintMessage(HUD_PRINTCENTER, self:Name() .. " has been arrested for " .. time .. " seconds!")
			end
		end
		
		timer.Create(ID .. "jailtimer", time, 1, function() self:Unarrest(ID) end)
	end
end

function meta:Unarrest(ID)
	if not ValidEntity(self) then
		RPArrestedPlayers[ID] = nil
		return
	end
	GAMEMODE:SetPlayerSpeed(self, CfgVars["wspd"], CfgVars["rspd"] )
	if type(self) == "string" then
		if RPArrestedPlayers[ID] then
			RPArrestedPlayers[ID] = nil
			if CfgVars["telefromjail"] == 1 then
				self:SetPos(GAMEMODE:PlayerSelectSpawn(self):GetPos())
			end
			GAMEMODE:PlayerLoadout(self)
			DB.StoreJailStatus(self, 0)
			timer.Stop(self .. "jailtimer")
			timer.Destroy(self .. "jailtimer")
			NotifyAll(1, 4, self:Name() .. " has been released from jail!")
		end
	else
		if self and RPArrestedPlayers[self:SteamID()] then
			RPArrestedPlayers[self:SteamID()] = nil
			if CfgVars["telefromjail"] == 1 then
				self:SetPos(GAMEMODE:PlayerSelectSpawn(self):GetPos())
			end
			GAMEMODE:PlayerLoadout(self)
			DB.StoreJailStatus(self, 0)
			timer.Stop(self:SteamID() .. "jailtimer")
			timer.Destroy(self:SteamID() .. "jailtimer")
			NotifyAll(1, 4, self:Name() .. " has been released from jail!")
		elseif not self and RPArrestedPlayers[self:SteamID()] then
			RPArrestedPlayers[self:SteamID()] = nil
			DB.StoreJailStatus(self, 0)
		end
	end
end

function meta:UnownAll()
	for k, v in pairs(ents.GetAll()) do
		if v:IsOwnable() and v:OwnedBy(self) == true then
			v:Fire("unlock", "", 0.6)
		end
	end

	if self:GetTable().Ownedz then
		for k, v in pairs(self:GetTable().Ownedz) do
			v:UnOwn(self)
			self:GetTable().Ownedz[v:EntIndex()] = nil
		end
	end

	for k, v in pairs(player.GetAll()) do
		if  v:GetTable().Ownedz then
			for n, m in pairs(v:GetTable().Ownedz) do
				if m:AllowedToOwn(self) then
					m:RemoveAllowed(self)
				end
			end
		end
	end

	self:GetTable().OwnedNumz = 0
end

function meta:DoPropertyTax()
	if CfgVars["propertytax"] == 0 then return end
	if self:Team() == TEAM_POLICE or self:Team() == TEAM_MAYOR or self:Team() == TEAM_CHIEF and CfgVars["cit_propertytax"] == 1 then return end

	local numowned = self:GetTable().OwnedNumz

	if numowned <= 0 then return end

	local price = 10
	local tax = price * numowned + math.random(-5, 5)

	if self:CanAfford(tax) then
		if tax == 0 then
			Notify(self, 1, 5, "No property tax - You don't own a door or a vehicle.")
		else
			self:AddMoney(-tax)
			Notify(self, 1, 5, "Property tax! " .. CUR .. tax)
		end
	else
		Notify(self, 1, 8, "Couldn't pay the taxes! Your property has been taken away from you!")
		self:UnownAll()
	end
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
	if ply:GetNWInt("slp") == 1 then
		Notify(ply, 4, 4, "Can not suicide while sleeping!")
		return false
	end
	if RPArrestedPlayers[ply:SteamID()] then
		Notify(ply, 4, 4, "You cannot suicide in jail.")
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
			b:PrintMessage(HUD_PRINTCENTER, ply:Nick() .. " has died in jail!")
		end
		Notify(ply, 4, 4, "You now are dead until your jail time is up!")
	else
		-- Normal death, respawning.
		ply.NextSpawnTime = CurTime() + CfgVars["respawntime"]
	end
	ply:GetTable().DeathPos = ply:GetPos()

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
		ply:SetNetworkedBool("wanted", false)
		RPArrestedPlayers[ply:SteamID()] = false
		ply:GetTable().DeathPos = nil
		ply:GetTable().Slayed = false
	end
	ply:GetTable().ConfisquatedWeapons = nil
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

function GM:PlayerSpawn(ply)
	self.BaseClass:PlayerSpawn(ply)
	ply:CrosshairEnable()

	if CfgVars["crosshair"] == 0 then
		ply:CrosshairDisable()
	end
	
	ply:GetTable().RPLicenseSpawn = true
	timer.Simple(1, function(ply) ply:GetTable().RPLicenseSpawn = false end, ply)
	
	--Kill any colormod anyway
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
			Notify(ply, 1, 4, "You're no longer under arrest because no jail positions are set!")
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

	if CfgVars["babygod"] == 1 and ply:GetNWInt("slp") ~= 1 then
		ply:SetNWBool("Babygod", true)
		ply:GodEnable()
		local r,g,b,a = ply:GetColor()
		ply:SetColor(r, g, b, 100)
		ply:SetCollisionGroup(  COLLISION_GROUP_WORLD )
		timer.Simple(CfgVars["babygodtime"] or 5, function()
			if not ValidEntity(ply) then return end
			ply:SetNWBool("Babygod", false)
			ply:SetColor(r, g, b, a)
			ply:GodDisable()
			ply:SetCollisionGroup( COLLISION_GROUP_PLAYER )
		end)
	end
	ply:SetNWInt("slp", 0)
	if CfgVars["enforceplayermodel"] == 1 then
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

				ply:SetModel(ply:GetTable().PlayerModel)
			end
		elseif ply:Team() == TEAM_POLICE then
			ply:SetModel("models/player/police.mdl")
		elseif ply:Team() == TEAM_MAYOR then
			ply:SetModel("models/player/breen.mdl")
		elseif ply:Team() == TEAM_GANG then
			ply:SetModel("models/player/group03/male_01.mdl")
		elseif ply:Team() == TEAM_MOB  then
			ply:SetModel("models/player/gman_high.mdl")
		elseif ply:Team() == TEAM_GUN then
			ply:SetModel("models/player/monk.mdl")
		elseif ply:Team() == TEAM_MEDIC then
			ply:SetModel("models/player/kleiner.mdl")
		elseif ply:Team() == TEAM_COOK then
			ply:SetModel("models/player/mossman.mdl")
		elseif ply:Team() == TEAM_CHIEF then
			ply:SetModel("models/player/combine_soldier_prisonguard.mdl")
		elseif ply:Team() == TEAM_HOBO then
			ply:SetModel("models/player/corpse1.mdl")
		end
		
		for k,v in pairs(RPExtraTeams) do
			if ply:Team() == (9+k) then
				ply:SetModel(v.model)
			end
		end
	end
	
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
end

function GM:PlayerLoadout(ply)
	if RPArrestedPlayers[ply:SteamID()] then return end

	local team = ply:Team()

	ply:Give("keys")
	ply:Give("weapon_physcannon")
	ply:Give("gmod_camera")

	if CfgVars["toolgun"] == 1 or ply:HasPriv(ADMIN) or ply:HasPriv(TOOL) then
		ply:Give("gmod_tool")
	end
	
	if CfgVars["pocket"] == 1 then
		ply:Give("pocket")
	end

	if CfgVars["physgun"] == 1 or ply:HasPriv(ADMIN) or ply:HasPriv(PHYS) then
		ply:Give("weapon_physgun")
	end
	
	if team == TEAM_POLICE or team == TEAM_CHIEF or (ply:HasPriv(ADMIN) and CfgVars["AdminsSpawnWithCopWeapons"] == 1) then
		ply:Give("door_ram")
		ply:Give("arrest_stick")
		ply:Give("unarrest_stick")
		ply:Give("stunstick")
		ply:Give("weaponchecker") 
	end

	if team == TEAM_POLICE then
		if CfgVars["noguns"] ~= 1 then
			ply:Give("weapon_glock2")
			ply:GiveAmmo(30, "Pistol")
		end
	elseif team == TEAM_MAYOR then
		if CfgVars["noguns"] ~= 1 then ply:GiveAmmo(28, "Pistol") end
	elseif team == TEAM_GANG then
		if CfgVars["noguns"] ~= 1 then ply:GiveAmmo(1, "Pistol") end
	elseif team == TEAM_MOB then
		ply:Give("unarrest_stick")
		ply:Give("lockpick")
		if CfgVars["noguns"] ~= 1 then ply:GiveAmmo(1, "Pistol") end
	elseif team == TEAM_GUN then
		if CfgVars["noguns"] ~= 1 then ply:GiveAmmo(1, "Pistol") end
	elseif team == TEAM_MEDIC then
		ply:Give("med_kit")
	elseif team == TEAM_COOK then
		if CfgVars["noguns"] ~= 1 then ply:GiveAmmo(1, "Pistol") end
	elseif team == TEAM_CHIEF then
		if CfgVars["noguns"] ~= 1 then
			ply:Give("weapon_deagle2")
			ply:GiveAmmo(30, "Pistol")
		end
	end
	for k,v in pairs(RPExtraTeams) do
		if team == (9 + k) then
			for _,b in pairs(v.Weapons) do ply:Give(b) end
		end
	end
end

function meta:CompleteSentence()
	if not ValidEntity(self) then return end
	local ID = self:SteamID()
	if ValidEntity(self) and ID ~= nil and RPArrestedPlayers[ID] then
		local time = GetGlobalInt("jailtimer")
		self:Arrest(time, true)
		Notify(self, 0, 5, "Punishment for disconnecting! Jailed for: " .. time .. " seconds.")
	end
end


function meta:NewData()
	local function ModuleDelay(ply)
		umsg.Start("LoadModules", ply)
			umsg.Short(#CSFiles)
			for n = 1, #CSFiles do
				umsg.String(CSFiles[n])
			end
		umsg.End()
	end

	timer.Simple(.01, ModuleDelay, self)

	self:RestoreRPName()

	DB.StoreSalary(self, GetGlobalInt("normalsalary"))

	self:UpdateJob("Citizen")

	self:GetTable().Ownedz = { }
	self:GetTable().OwnedNumz = 0

	self:GetTable().LastLetterMade = CurTime() - 61
	self:GetTable().LastVoteCop = CurTime() - 61

	self:SetTeam(TEAM_CITIZEN)

	-- Whether or not a player is being prevented from joining
	-- a specific team for a certain length of time
	for i = 1, 9 + #RPExtraTeams do
		if CfgVars["restrictallteams"] == 1 then
			self.bannedfrom[i] = 1
		else
			self.bannedfrom[i] = 0
		end
	end

	if self:IsSuperAdmin() or self:IsAdmin() then
		self:GrantPriv(ADMIN)
	end
end

function meta:RestoreRPName()
	local name = DB.RetrieveRPName(self)
	if not name or name == "" then name = self:SteamName() end

	self:SetRPName(name, true)
end

function GM:PlayerInitialSpawn(ply)
	self.BaseClass:PlayerInitialSpawn(ply)
	ply.bannedfrom = {}
	ply:NewData()
	ply:InitSID()
	DB.RetrieveSalary(ply)
	DB.RetrieveMoney(ply)
	timer.Simple(10, ply.CompleteSentence, ply)
end
timer.Simple(5, function()
	DB.SetUpNonOwnableDoors()
	DB.SetUpCPOwnableDoors() 
end)

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
	vote.DestroyVotesWithEnt(ply)
	-- If you're arrested when you disconnect, you will serve your time again when you reconnect!
	if RPArrestedPlayers and RPArrestedPlayers[ply:SteamID()]then
		DB.StoreJailStatus(ply, math.ceil(GetGlobalInt("jailtimer")))
	end
	ply:UnownAll()
end
