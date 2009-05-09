/*---------------------------------------------------------
 Variables
 ---------------------------------------------------------*/
local meta = FindMetaTable("Player")

-- Each time a player connects, they get a new ID
local sessionid = 0

function meta:InitSID()
	sessionid = sessionid + 1
	self.SID = sessionid
end

/*---------------------------------------------------------
 RP names
 ---------------------------------------------------------*/
function RPName(ply, args)
	if CfgVars["allowrpnames"] ~= 1 then
		Notify(ply, 1, 4, "Changing your RP name is disabled on this server!")
		return ""
	end

	local len = string.len(args)
	local low = string.lower(args)

	if len > 30 then
		Notify(ply, 1, 4, "Please choose a name of 30 characters or less!")
		return ""
	elseif len < 3 then
		Notify(ply, 1, 4, "Please choose a name of 3 characters or more!")
		return ""
	end
	
	if string.find(args, " ") == 1 or string.find(args, " ") == 1 then--The first space is a normal space and the second one is a system space!
		Notify(ply, 1, 4, "Name cannot start with a space")
		return ""
	end
	
	if low == "ooc" or low == "shared" or low == "world" or low == "n/a" then
		Notify(ply, 1, 4, "That's not funny. Choose a proper RP name please.")
		return ""
	end
	
	--update the door names
	for k,v in pairs(ents.GetAll()) do
		if v:IsDoor() and v:GetNWInt("Ownerz") == ply:EntIndex() then
			v:SetNWString("OwnerName", ply:Nick())
		end
	end

	ply:SetRPName(args)
	NotifyAll(2, 6, "Steam player: " .. ply:SteamName() .. " changed his / her RP name to: " .. args)
	return ""
end
AddChatCommand("/rpname", RPName)
AddChatCommand("/name", RPName)
AddChatCommand("/nick", RPName)

function meta:SetRPName(name, firstRun)
	-- Make sure nobody on this server already has this RP name
	local lowername = string.lower(tostring(name))
	local rpNames = DB.RetrieveRPNames()
	local taken = false

	for id, row in pairs(rpNames) do
		if row.name and lowername == string.lower(row.name) and row.steam ~= self:SteamID() and row.steam ~= "STEAM_ID_PENDING" and row.steam ~= "UNKNOWN" then
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

function meta:RestoreRPName()
	local name = DB.RetrieveRPName(self)
	if not name or name == "" then name = self:SteamName() end

	self:SetRPName(name, true)
end

/*---------------------------------------------------------
 Admin/automatic stuff
 ---------------------------------------------------------*/
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

function meta:ResetDMCounter()
	if not ValidEntity(self) then return end
	self.kills = 0
	return true
end

function meta:TeamUnBan(Team)
	if not self.bannedfrom then self.bannedfrom = {} end
	self.bannedfrom[Team] = 0
end

function meta:TeamBan()
	if not self.bannedfrom then self.bannedfrom = {} end
	self.bannedfrom[self:Team()] = 1
	timer.Simple(CfgVars["demotetime"], self.TeamUnBan, self, self:Team())
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

local CSFiles = {}
function includeCS(dir)
	AddCSLuaFile(dir)
	table.insert(CSFiles, dir)
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

/*---------------------------------------------------------
 Teams/jobs
 ---------------------------------------------------------*/
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
			if CfgVars["max"..v.command.."s"] and team.NumPlayers(t) >= CfgVars["max"..v.command.."s"] then
				Notify(self, 1, 4,  "Max "..v.name.." reached")
				return
			end
			self:UpdateJob(v.name)
			DB.StoreSalary(self, v.salary)
			NotifyAll(1, 4, self:Name() .. " has been made a " .. v.name .. "!")
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
	if CfgVars["norespawn"] == 1 and self:Alive() then
		self:StripWeapons()
		local vPoint = self:GetShootPos() + Vector(0,0,50)
		local effectdata = EffectData()
		effectdata:SetEntity(self)
		effectdata:SetStart( vPoint ) -- not sure if we need a start and origin (endpoint) for this effect, but whatever
		effectdata:SetOrigin( vPoint )
		effectdata:SetScale(1)
		util.Effect( "entity_remove", effectdata)
		GAMEMODE:PlayerSetModel(self)
		GAMEMODE:PlayerLoadout(self)
	else
		self:KillSilent()
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

/*---------------------------------------------------------
 Money
 ---------------------------------------------------------*/
function meta:CanAfford(amount)
	if not amount then return false end
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

/*---------------------------------------------------------
 Jail/arrest
 ---------------------------------------------------------*/
function JailPos(ply)
	-- Admin or Chief can set the Jail Position
	if (ply:Team() == TEAM_CHIEF and CfgVars["chiefjailpos"] == 1) or ply:HasPriv(ADMIN) then
		DB.StoreJailPos(ply)
	else
		local str = "Admin only!"
		if CfgVars["chiefjailpos"] == 1 then
			str = "Chief or " .. str
		end

		Notify(ply, 1, 4, str)
	end
	return ""
end
AddChatCommand("/jailpos", JailPos)

function AddJailPos(ply)
	-- Admin or Chief can add Jail Positions
	if (ply:Team() == TEAM_CHIEF and CfgVars["chiefjailpos"] == 1) or ply:HasPriv(ADMIN) then
		DB.StoreJailPos(ply, true)
	else
		local str = "Admin only!"
		if CfgVars["chiefjailpos"] == 1 then
			str = "Chief or " .. str
		end

		Notify(ply, 1, 4, str)
	end
	return ""
end
AddChatCommand("/addjailpos", AddJailPos)

function meta:Arrest(time, rejoin)
	self:SetNetworkedBool("wanted", false)
	self:SetNWBool("warrant", false)
	self:SetNWBool("HasGunlicense", false)
	self:SetNWBool("Arrested", true)
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
		umsg.Start("GotArrested", ply)
		umsg.End()
	end
end

function meta:Unarrest(ID)
	self:SetNWBool("Arrested", false)
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
