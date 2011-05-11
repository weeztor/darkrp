/*---------------------------------------------------------
 Variables
 ---------------------------------------------------------*/
local meta = FindMetaTable("Player")

/*---------------------------------------------------------
 RP names
 ---------------------------------------------------------*/
local function RPName(ply, args)
	
	if ply.LastNameChange and ply.LastNameChange > (CurTime() - 5) then
		Notify( ply, 1, 4, string.format( LANGUAGE.have_to_wait,  math.ceil(5 - (CurTime() - ply.LastNameChange)), "/rpname" ))
		return ""
	end
	
	if GetConVarNumber("allowrpnames") ~= 1 then
		Notify(ply, 1, 6,  string.format(LANGUAGE.disabled, "RPname", "")) 
		return ""
	end

	local len = string.len(args)
	local low = string.lower(args)

	if len > 30 then
		Notify(ply, 1, 4, string.format(LANGUAGE.unable, "RPname", "<=30"))
		return ""
	elseif len < 3 then
		Notify(ply, 1, 4, string.format(LANGUAGE.unable, "RPname", ">2"))
		return ""
	end
	
 	if string.find(args, "\160") or string.find(args, " ") == 1 then -- No system spaces in your name bro!
		Notify(ply, 1, 4, string.format(LANGUAGE.unable, "RPname", ""))
		return ""
	end
	
	if low == "ooc" or low == "shared" or low == "world" or low == "n/a" or low == "world prop" then
		Notify(ply, 1, 4, string.format(LANGUAGE.unable, "RPname", ""))
		return ""
	end
	
	local allowed = {'1', '2', '3', '4', '5', '6', '7', '8', '9', '0',
	'q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p', 
	'a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l', 
	'z', 'x', 'c', 'v', 'b', 'n', 'm', ' ',
	'(', ')', '[', ']', '!', '@', '#', '$', '%', '^', '&', '*', '-', '_', '=', '+', '|', '\\'}
	
	for k in string.gmatch(args, ".") do
		if not table.HasValue(allowed, string.lower(k)) then
			Notify(ply, 1, 4, string.format(LANGUAGE.unable, "RPname", k))
			return "" 
		end
	end 
	ply:SetRPName(args)
	ply.LastNameChange = CurTime()
	return ""
end
AddChatCommand("/rpname", RPName)
AddChatCommand("/name", RPName)
AddChatCommand("/nick", RPName)

function meta:IsCP()
	local Team = self:Team()
	return Team == TEAM_POLICE or Team == TEAM_CHIEF or Team == TEAM_MAYOR
end

function meta:SetRPName(name, firstRun)
	-- Make sure nobody on this server already has this RP name
	local lowername = string.lower(tostring(name))
	DB.RetrieveRPNames(self, name, function(taken)
		if string.len(lowername) < 2 and not firstrun then return end
		-- If we found that this name exists for another player
		if taken then
			if firstRun then
				-- If we just connected and another player happens to be using our steam name as their RP name
				-- Put a 1 after our steam name
				DB.StoreRPName(self, name .. " 1")
				Notify(self, 0, 12, "Someone is already using your Steam name as their RP name so we gave you a '1' after your name.") 
			else
				Notify(self, 1, 5, string.format(LANGUAGE.unable, "RPname", "it's been taken"))
				return ""
			end
		else
			if not firstRun then -- Don't save the steam name in the database
				NotifyAll(2, 6, string.format(LANGUAGE.rpname_changed, self:SteamName(), name))
				DB.StoreRPName(self, name)
			end
		end
	end)
end

function meta:RestoreRPName()
	if not ValidEntity(self) then return end
	DB.RetrieveRPName(self, function(name)
		if not name or name == "" then name = string.gsub(self:SteamName(), "\\\"", "\"") end

		self:SetDarkRPVar("rpname", name)
	end)
end

/*---------------------------------------------------------
 Admin/automatic stuff
 ---------------------------------------------------------*/
function meta:HasPriv(priv)
	return (FAdmin and FAdmin.Access.PlayerHasPrivilege(self, priv)) or self:IsAdmin()
end

function meta:ChangeAllowed(t)
	if not self.bannedfrom then return true end
	if self.bannedfrom[t] == 1 then return false else return true end
end

function meta:ResetDMCounter()
	if not ValidEntity(self) then return end
	self.kills = 0
	return true
end

function meta:TeamUnBan(Team)
	if not ValidEntity(self) then return end
	if not self.bannedfrom then self.bannedfrom = {} end
	self.bannedfrom[Team] = 0
end

function meta:TeamBan(t)
	if not self.bannedfrom then self.bannedfrom = {} end
	self.bannedfrom[t or self:Team()] = 1
	timer.Simple(GetConVarNumber("demotetime"), self.TeamUnBan, self, self:Team())
end

function meta:CompleteSentence()
	if not ValidEntity(self) then return end
	for k,v in pairs(ToggleCmds) do
		local value = GetConVarNumber(v.var)
		if value ~= v.default then
			RunConsoleCommand(v.var, v.default)
			timer.Simple(0, RunConsoleCommand, v.var, value)
		end
	end
	
	for k,v in pairs(ValueCmds) do
		local value = GetConVarNumber(v.var)
		if value ~= v.default then
			RunConsoleCommand(v.var, v.default)
			timer.Simple(0, RunConsoleCommand, v.var, value)
		end
	end
	
	local ID = self:SteamID()
	if ValidEntity(self) and ID ~= nil and RPArrestedPlayers[ID] then
		local time = GetConVarNumber("jailtimer")
		self:Arrest(time, true)
		Notify(self, 0, 5, string.format(LANGUAGE.jail_punishment, time))
	end
end

local CSFiles = {}
function includeCS(dir)
	AddCSLuaFile(dir)
	table.insert(CSFiles, dir)
end

function meta:NewData()
	if not ValidEntity(self) then return end
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

	DB.StoreSalary(self, GetConVarNumber("normalsalary"))

	self:UpdateJob(team.GetName(1))

	self:GetTable().Ownedz = { }
	self:GetTable().OwnedNumz = 0

	self:GetTable().LastLetterMade = CurTime() - 61
	self:GetTable().LastVoteCop = CurTime() - 61

	self:SetTeam(1)

	-- Whether or not a player is being prevented from joining
	-- a specific team for a certain length of time
	for i = 1, #RPExtraTeams do
		if GetConVarNumber("restrictallteams") == 1 then
			self.bannedfrom[i] = 1
		else
			self.bannedfrom[i] = 0
		end
	end
end

/*---------------------------------------------------------
 Teams/jobs
 ---------------------------------------------------------*/
function meta:ChangeTeam(t, force)
	if RPArrestedPlayers[self:SteamID()] and not force then
		if not self:Alive() then
			Notify(self, 1, 4, string.format(LANGUAGE.unable, team.GetName(t), ""))
			return
		else
			Notify(self, 1, 4, string.format(LANGUAGE.unable, team.GetName(t), ""))
			return
		end
	end
	
	self:SetDarkRPVar("helpBoss",false)
	self:SetDarkRPVar("helpCop",false)
	self:SetDarkRPVar("helpMayor",false)

	
	if t ~= TEAM_CITIZEN and not self:ChangeAllowed(t) and not force then
		Notify(self, 1, 4, string.format(LANGUAGE.unable, team.GetName(t), "banned/demoted"))
		return
	end
	
	if self.LastJob and 10 - (CurTime() - self.LastJob) >= 0 and not force then
		Notify(self, 1, 4, string.format(LANGUAGE.have_to_wait,  math.ceil(10 - (CurTime() - self.LastJob)), "/job"))
		return 
	end
	
	if self.IsBeingDemoted then
		self:TeamBan()
		vote.DestroyVotesWithEnt(self)
		Notify(self, 1, 4, "You tried to escape demotion. You failed, and have been demoted.")
	end
	
	
	if self:Team() == t then
		Notify(self, 1, 4, string.format(LANGUAGE.unable, team.GetName(t), ""))
		return
	end

	local TEAM = RPExtraTeams[t]
	if not TEAM then return end
	
	if not self.DarkRPVars["Priv"..TEAM.command] and not force  then
		if type(TEAM.NeedToChangeFrom) == "number" and self:Team() ~= TEAM.NeedToChangeFrom then
			Notify(self, 1,4, string.format(LANGUAGE.need_to_be_before, team.GetName(TEAM.NeedToChangeFrom), TEAM.name))
			return
		elseif type(TEAM.NeedToChangeFrom) == "table" and not table.HasValue(TEAM.NeedToChangeFrom, self:Team()) then
			local teamnames = ""
			for a,b in pairs(TEAM.NeedToChangeFrom) do teamnames = teamnames.." or "..team.GetName(b) end
			Notify(self, 1,4, string.format(string.sub(teamnames, 5), team.GetName(TEAM.NeedToChangeFrom), TEAM.name))
			return
		end
		if GetConVarNumber("max"..TEAM.command.."s") and GetConVarNumber("max"..TEAM.command.."s") ~= 0 and team.NumPlayers(t) >= GetConVarNumber("max"..TEAM.command.."s")then
			Notify(self, 1, 4, string.format(LANGUAGE.team_limit_reached, TEAM.name))
			return
		end
	end
	if self:Team() == TEAM_MAYOR and tobool(GetConVarNumber("DarkRP_LockDown")) then
		UnLockdown(self)
	end
	self:UpdateJob(TEAM.name)
	DB.StoreSalary(self, TEAM.salary)
	NotifyAll(0, 4, string.format(LANGUAGE.job_has_become, self:Nick(), TEAM.name))
	if self.DarkRPVars.HasGunlicense then
		self:SetDarkRPVar("HasGunlicense", false)
	end
	if TEAM.Haslicense and GetConVarNumber("license") ~= 0 then
		self:SetDarkRPVar("HasGunlicense", true)
	end
	
	self.LastJob = CurTime()
	
	if t == TEAM_POLICE then	
		self:SetDarkRPVar("helpCop", true)
	elseif t == TEAM_MOB then
		self:SetDarkRPVar("helpBoss", true)
	elseif t == TEAM_MAYOR then
		self:SetDarkRPVar("helpMayor", true)
	end
	
	if tobool(GetConVarNumber("removeclassitems")) then
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
	DB.Log(self:SteamName().." ("..self:SteamID()..") changed to "..team.GetName(t))
	if self:InVehicle() then self:ExitVehicle() end
	if GetConVarNumber("norespawn") == 1 and self:Alive() then
		self:StripWeapons()
		local vPoint = self:GetShootPos() + Vector(0,0,50)
		local effectdata = EffectData()
		effectdata:SetEntity(self)
		effectdata:SetStart( vPoint ) -- Not sure if we need a start and origin (endpoint) for this effect, but whatever
		effectdata:SetOrigin( vPoint )
		effectdata:SetScale(1)
		util.Effect("entity_remove", effectdata)
		GAMEMODE:PlayerSetModel(self)
		GAMEMODE:PlayerLoadout(self)
	else
		self:KillSilent()
	end
end

function meta:UpdateJob(job)
	self:SetDarkRPVar("job", job)
	self:GetTable().Pay = 1
	self:GetTable().LastPayDay = CurTime()

	timer.Create(self:SteamID() .. "jobtimer", GetConVarNumber("paydelay"), 0, self.PayDay, self)
end

/*---------------------------------------------------------
 Money
 ---------------------------------------------------------*/
function meta:CanAfford(amount)
	if not amount then return false end
	return math.floor(amount) >= 0 and self.DarkRPVars.money - math.floor(amount) >= 0
end

function meta:AddMoney(amount)
	if not amount then return false end
	DB.StoreMoney(self, self.DarkRPVars.money + math.floor(amount))
end

function meta:PayDay()
	if ValidEntity(self) and self:GetTable().Pay == 1 then
		if not RPArrestedPlayers[self:SteamID()] then
			DB.RetrieveSalary(self, function(amount)
				amount = math.floor(amount or GetConVarNumber("normalsalary"))
				if amount == 0 or not amount then
					Notify(self, 4, 4, LANGUAGE.payday_unemployed)
				else
					self:AddMoney(amount)
					Notify(self, 4, 4, string.format(LANGUAGE.payday_message, CUR .. amount))
				end
			end)
		else
			Notify(self, 4, 4, LANGUAGE.payday_missed)
		end
	end
end

/*---------------------------------------------------------
 Jail/arrest
 ---------------------------------------------------------*/
local function JailPos(ply)
	-- Admin or Chief can set the Jail Position
	if (ply:Team() == TEAM_CHIEF and GetConVarNumber("chiefjailpos") == 1) or ply:HasPriv("rp_commands") then
		DB.StoreJailPos(ply)
	else
		local str = "Admin only!"
		if GetConVarNumber("chiefjailpos") == 1 then
			str = "Chief or " .. str
		end

		Notify(ply, 1, 4, str)
	end
	return ""
end
AddChatCommand("/jailpos", JailPos)

local function AddJailPos(ply)
	-- Admin or Chief can add Jail Positions
	if (ply:Team() == TEAM_CHIEF and GetConVarNumber("chiefjailpos") == 1) or ply:HasPriv("rp_commands") then
		DB.StoreJailPos(ply, true)
	else
		local str = LANGUAGE.admin_only
		if GetConVarNumber("chiefjailpos") == 1 then
			str = LANGUAGE.chief_or .. str
		end

		Notify(ply, 1, 4, str) 
	end
	return ""
end
AddChatCommand("/addjailpos", AddJailPos)

function meta:Arrest(time, rejoin)
	self:SetDarkRPVar("wanted", false)
	self.warranted = false
	self:SetDarkRPVar("HasGunlicense", false)
	self:SetDarkRPVar("Arrested", true)
	GAMEMODE:SetPlayerSpeed(self, GetConVarNumber("aspd"), GetConVarNumber("aspd"))
	self:StripWeapons()
	
	if tobool(GetConVarNumber("droppocketarrest")) and self.Pocket then 
		for k, v in pairs(self.Pocket) do
			if ValidEntity(v) then
				v:SetMoveType(MOVETYPE_VPHYSICS)
				v:SetNoDraw(false)
				v:SetCollisionGroup(4)
				v:SetPos(self:GetPos() + Vector(0,0,10))
				local phys = v:GetPhysicsObject()
				if phys:IsValid() then
					phys:EnableCollisions(true)
					phys:Wake()
				end
			end
		end
		self.Pocket = nil
	end
	
	-- Always get sent to jail when Arrest() is called, even when already under arrest
	if GetConVarNumber("teletojail") == 1 and DB.CountJailPos() and DB.CountJailPos() ~= 0 then
		local jailpos = DB.RetrieveJailPos()
		if jailpos then
			self:SetPos(jailpos)
		end
	end
	
	if not RPArrestedPlayers[self:SteamID()] or rejoin then
		local ID = self:SteamID()
		RPArrestedPlayers[ID] = true
		self.LastJailed = CurTime()
		
		-- If the player has no remaining jail time,
		-- set it back to the max for this new sentence
		if not time or time == 0 then
			time = (GetConVarNumber("jailtimer") ~= 0 and GetConVarNumber("jailtimer")) or 120
		end

		self:PrintMessage(HUD_PRINTCENTER, string.format(LANGUAGE.youre_arrested, time))
		for k, v in pairs(player.GetAll()) do
			if v ~= self then
				v:PrintMessage(HUD_PRINTCENTER, string.format(LANGUAGE.hes_arrested, self:Name(), time))
			end
		end
		
		timer.Create(ID .. "jailtimer", time, 1, function() if ValidEntity(self) then self:Unarrest(ID) end end)
		umsg.Start("GotArrested", self)
			umsg.Float(time)
		umsg.End()
	end
end

function meta:Unarrest(ID)
	self:SetDarkRPVar("Arrested", false)
	if not ValidEntity(self) then
		RPArrestedPlayers[ID] = nil
		return
	end
	
	if self.Sleeping then
		KnockoutToggle(self, "force")
	end

	if RPArrestedPlayers[self:SteamID()] ~= nil then
		RPArrestedPlayers[self:SteamID()] = nil
		
		GAMEMODE:SetPlayerSpeed(self, GetConVarNumber("wspd"), GetConVarNumber("rspd"))
		GAMEMODE:PlayerLoadout(self)
		if GetConVarNumber("telefromjail") == 1 and (not FAdmin or not self:FAdmin_GetGlobal("fadmin_jailed")) then
			local _, pos = GAMEMODE:PlayerSelectSpawn(self)
			self:SetPos(pos)
		elseif FAdmin and self:FAdmin_GetGlobal("fadmin_jailed") then
			self:SetPos(self.FAdminJailPos)
		end
		
		timer.Destroy(self:SteamID() .. "jailtimer")
		NotifyAll(0, 4, string.format(LANGUAGE.hes_unarrested, self:Name()))
	end
end

/*---------------------------------------------------------
 Items
 ---------------------------------------------------------*/
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
		if v:GetTable().Ownedz then
			for n, m in pairs(v:GetTable().Ownedz) do
				if ValidEntity(m) and m:AllowedToOwn(self) then
					m:RemoveAllowed(self)
				end
			end
		end
	end

	self:GetTable().OwnedNumz = 0
end

function meta:DoPropertyTax()
	if GetConVarNumber("propertytax") == 0 then return end
	if (self:IsCP()) and GetConVarNumber("cit_propertytax") == 1 then return end

	local numowned = self:GetTable().OwnedNumz

	if numowned <= 0 then return end

	local price = 10
	local tax = price * numowned + math.random(-5, 5)

	if self:CanAfford(tax) then
		if tax ~= 0 then
			self:AddMoney(-tax)
			Notify(self, 0, 5, string.format(LANGUAGE.property_tax, CUR .. tax))
		end
	else
		Notify(self, 1, 8, LANGUAGE.property_tax_cant_afford)
		self:UnownAll()
	end
end
