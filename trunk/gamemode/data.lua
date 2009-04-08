include("static_data.lua")
DB.privcache = {}
function DB.Init()
	sql.Begin()
		sql.Query("CREATE TABLE IF NOT EXISTS darkrp_settings('key' TEXT NOT NULL, 'value' INTEGER NOT NULL, PRIMARY KEY('key'));")
		sql.Query("CREATE TABLE IF NOT EXISTS darkrp_globals('key' TEXT NOT NULL, 'value' INTEGER NOT NULL, PRIMARY KEY('key'));")
		sql.Query("CREATE TABLE IF NOT EXISTS darkrp_tspawns('map' TEXT NOT NULL, 'team' INTEGER NOT NULL, 'x' NUMERIC NOT NULL, 'y' NUMERIC NOT NULL, 'z' NUMERIC NOT NULL, PRIMARY KEY('map', 'team'));")
		sql.Query("CREATE TABLE IF NOT EXISTS darkrp_privs('steam' TEXT NOT NULL, 'admin' INTEGER NOT NULL, 'mayor' INTEGER NOT NULL, 'cp' INTEGER NOT NULL, 'tool' INTEGER NOT NULL, 'phys' INTEGER NOT NULL, 'prop' INTEGER NOT NULL, PRIMARY KEY('steam'));")
		sql.Query("CREATE TABLE IF NOT EXISTS darkrp_salaries('steam' TEXT NOT NULL, 'salary' INTEGER NOT NULL, PRIMARY KEY('steam'));")
		sql.Query("CREATE TABLE IF NOT EXISTS darkrp_wallets('steam' TEXT NOT NULL, 'amount' INTEGER NOT NULL, PRIMARY KEY('steam'));")
		sql.Query("CREATE TABLE IF NOT EXISTS darkrp_jailpositions('map' TEXT NOT NULL, 'x' NUMERIC NOT NULL, 'y' NUMERIC NOT NULL, 'z' NUMERIC NOT NULL, 'lastused' NUMERIC NOT NULL, PRIMARY KEY('map', 'x', 'y', 'z'));")
		sql.Query("CREATE TABLE IF NOT EXISTS darkrp_rpnames('steam' TEXT NOT NULL, 'name' TEXT NOT NULL, PRIMARY KEY('steam'));")
		sql.Query("CREATE TABLE IF NOT EXISTS darkrp_zspawns('map' TEXT NOT NULL, 'x' NUMERIC NOT NULL, 'y' NUMERIC NOT NULL, 'z' NUMERIC NOT NULL);")
		sql.Query("CREATE TABLE IF NOT EXISTS darkrp_wiseguys('steam' TEXT NOT NULL, 'time' NUMERIC NOT NULL, PRIMARY KEY('steam'));")
		sql.Query("CREATE TABLE IF NOT EXISTS darkrp_disableddoors('map' TEXT NOT NULL, 'idx' INTEGER NOT NULL, 'title' TEXT NOT NULL, PRIMARY KEY('map', 'idx'));")
		sql.Query("CREATE TABLE IF NOT EXISTS darkrp_cpdoors('map' TEXT NOT NULL, 'idx' INTEGER NOT NULL, 'title' TEXT NOT NULL, PRIMARY KEY('map', 'idx'));")
	sql.Commit()

	DB.CreatePrivs()
	DB.CreateJailPos()
	DB.CreateSpawnPos()
	DB.CreateZombiePos()
	DB.SetUpNonOwnableDoors()
end

function DB.CreatePrivs()
	sql.Begin()
	if reset_all_privileges_to_these_on_startup then
		sql.Query("DELETE FROM darkrp_privs;")
	end
	local already_inserted = {}
	for k, v in pairs(RPAdmins) do
		local admin = 0
		local mayor = 0
		local cp = 0
		local tool = 0
		local phys = 0
		local prop = 0
		for a, b in pairs(RPAdmins[k]) do
			if b == ADMIN then admin = 1 end
			if b == MAYOR then mayor = 1 end
			if b == CP then cp = 1 end
			if b == TOOL then tool = 1 end
			if b == PHYS then phys = 1 end
			if b == PROP then prop = 1 end
		end
		if already_inserted[RPAdmins[k]] then
			sql.Query("UPDATE darkrp_privs SET admin = " .. admin .. ", mayor = " .. mayor .. ", cp = " .. cp .. ", tool = " .. tool .. ", phys = " .. phys .. ", prop = " .. prop .. " WHERE steam = " .. sql.SQLStr(RPAdmins[k]) .. ";")
		else
			sql.Query("INSERT INTO darkrp_privs VALUES(" .. sql.SQLStr(k) .. ", " .. admin .. ", " .. mayor .. ", " .. cp .. ", " .. tool .. ", " .. phys .. ", " .. prop .. ");")
			already_inserted[RPAdmins[k]] = true
		end
	end
	sql.Commit()
end

function DB.CreateJailPos()
	if not jail_positions then return end
	local map = string.lower(game.GetMap())

	local once = false
	sql.Begin()
		for k, v in pairs(jail_positions) do
			if map == string.lower(v[1]) then
				if not once then
					sql.Query("DELETE FROM darkrp_jailpositions;")
					once = true
				end
				sql.Query("INSERT INTO darkrp_jailpositions VALUES(" .. sql.SQLStr(map) .. ", " .. v[2] .. ", " .. v[3] .. ", " .. v[4] .. ", " .. 0 .. ");")
			end
		end
	sql.Commit()
end

function DB.CreateSpawnPos()
	local map = string.lower(game.GetMap())
	if not team_spawn_positions then return end

	for k, v in pairs(team_spawn_positions) do
		if v[1] == map then
			DB.StoreTeamSpawnPos(v[2], Vector(v[3], v[4], v[5]))
		end
	end
end

function DB.CreateZombiePos()
	if not zombie_spawn_positions then return end
	local map = string.lower(game.GetMap())

	local once = false
	sql.Begin()

		for k, v in pairs(zombie_spawn_positions) do
			if map == string.lower(v[1]) then
				if not once then
					sql.Query("DELETE FROM darkrp_zspawns;")
					once = true
				end
				sql.Query("INSERT INTO darkrp_zspawns VALUES(" .. sql.SQLStr(map) .. ", " .. v[2] .. ", " .. v[3] .. ", " .. v[4] .. ");")
			end
		end
	sql.Commit()
end

function DB.Priv2Text(priv)
	if priv == ADMIN then
		return "admin"
	elseif priv == MAYOR then
		return "mayor"
	elseif priv == CP then
		return "cp"
	elseif priv == TOOL then
		return "tool"
	elseif priv == PHYS then
		return "phys"
	elseif priv == PROP then
		return "prop"
	else
		return nil
	end
end

function DB.HasPriv(ply, priv)
	local SteamID = ply:SteamID()
	if priv == ADMIN and (ply:EntIndex() == 0 or ply:IsAdmin()) then return true end

	local p = DB.Priv2Text(priv)
	if not p then return false end

	-- If there is a current cache of priveleges
	if DB.privcache[SteamID] and DB.privcache[SteamID][p] ~= nil then
		if DB.privcache[SteamID][p] == 1 then
			return true
		else
			return false
		end
	-- If there is no cache for this user
	else 
		local result = tonumber(sql.QueryValue("SELECT " .. sql.SQLStr(p) .. " FROM darkrp_privs WHERE steam = " .. sql.SQLStr(ply:SteamID()) .. ";"))
		if not DB.privcache[SteamID] then
			DB.privcache[SteamID] = {}
		end

		if result == 1 then
			DB.privcache[SteamID][p] = 1
			return true
		else
			DB.privcache[SteamID][p] = 0
			return false
		end
	end
end

function DB.GrantPriv(ply, priv)
	local steamID = ply:SteamID()
	local p = DB.Priv2Text(priv)
	if not p then return false end
	if tonumber(sql.QueryValue("SELECT COUNT(*) FROM darkrp_privs WHERE steam = " .. sql.SQLStr(steamID) .. ";")) > 0 then
		sql.Query("UPDATE darkrp_privs SET " .. p .. " = 1 WHERE steam = " .. sql.SQLStr(steamID) .. ";")
	else
		sql.Begin()
		sql.Query("INSERT INTO darkrp_privs VALUES(" .. sql.SQLStr(steamID) .. ", 0, 0, 0, 0, 0, 0);")
		sql.Query("UPDATE darkrp_privs SET " .. sql.SQLStr(p) .. " = 1 WHERE steam = " .. sql.SQLStr(steamID) .. ";")
		
		sql.Commit()
	end
	-- privelege structure altered, fix the goddamn cache

	if DB.privcache[steamID] == nil then
		DB.privcache[steamID] = {}
	end

	DB.privcache[steamID][p] = 1
	return true
end

function DB.RevokePriv(ply, priv)
	local steamID = ply:SteamID()	
	local p = DB.Priv2Text(priv)
	local val = tonumber(sql.QueryValue("SELECT COUNT(*) FROM darkrp_privs WHERE steam = " .. sql.SQLStr(steamID) .. ";"))
	if not p or val < 1 then return false end
	sql.Query("UPDATE darkrp_privs SET " .. p .. " = 0 WHERE steam = " .. sql.SQLStr(steamID) .. ";")
	
	-- privelege structure altered, alter the cache
	if DB.privcache[steamID] == nil then
		DB.privcache[steamID] = {}
	end
	DB.privcache[steamID][p] = 0
	return true
end

function DB.StoreJailPos(ply, addingPos)
	local map = string.lower(game.GetMap())
	local pos = string.Explode(" ", tostring(ply:GetPos()))
	local already = tonumber(sql.QueryValue("SELECT COUNT(*) FROM darkrp_jailpositions WHERE map = " .. sql.SQLStr(map) .. ";"))
	if not already or already == 0 then
		sql.Query("INSERT INTO darkrp_jailpositions VALUES(" .. sql.SQLStr(map) .. ", " .. pos[1] .. ", " .. pos[2] .. ", " .. pos[3] .. ", " .. 0 .. ");")
		Notify(ply, 1, 4,  "First jail position created!")
	else
		if addingPos then
			sql.Query("INSERT INTO darkrp_jailpositions VALUES(" .. sql.SQLStr(map) .. ", " .. pos[1] .. ", " .. pos[2] .. ", " .. pos[3] .. ", " .. 0 .. ");")
			Notify(ply, 1, 4,  "Extra jail position added!")
		else
			sql.Begin()
			sql.Query("DELETE FROM darkrp_jailpositions WHERE map = " .. sql.SQLStr(map) .. ";")
			sql.Query("INSERT INTO darkrp_jailpositions VALUES(" .. sql.SQLStr(map) .. ", " .. pos[1] .. ", " .. pos[2] .. ", " .. pos[3] .. ", " .. 0 .. ");")
			sql.Commit()
			Notify(ply, 1, 5,  "Removed all jail positions and added a new one here")
		end
	end
end

function DB.RetrieveJailPos()
	local map = string.lower(game.GetMap())
	local r = sql.Query("SELECT x, y, z, lastused FROM darkrp_jailpositions WHERE map = " .. sql.SQLStr(map) .. ";")
	if not r then return Vector(0,0,0) end

	-- Retrieve the least recently used jail position
	local now = CurTime()
	local oldest = 0
	local ret = nil

	for _, row in pairs(r) do
		if (now - tonumber(row.lastused)) > oldest then
			oldest = (now - tonumber(row.lastused))
			ret = row
		end
	end

	-- Mark that position as having been used just now
	sql.Query("UPDATE darkrp_jailpositions SET lastused = " .. CurTime() .. " WHERE map = " .. sql.SQLStr(map) .. " AND x = " .. ret.x .. " AND y = " .. ret.y .. " AND z = " .. ret.z .. ";")

	return Vector(ret.x, ret.y, ret.z)
end

function DB.CountJailPos()
	return tonumber(sql.QueryValue("SELECT COUNT(*) FROM darkrp_jailpositions WHERE map = " .. sql.SQLStr(string.lower(game.GetMap())) .. ";"))
end

function DB.StoreJailStatus(ply, time)
	local steamID = ply:SteamID()
	-- Is there an existing outstanding jail sentence for this player?
	local r = tonumber(sql.QueryValue("SELECT time FROM darkrp_wiseguys WHERE steam = " .. sql.SQLStr(steamID) .. ";"))

	
	if not r and time ~= 0 then
		-- If there is no jail record for this player and we're not trying to clear an existing one
		sql.Query("INSERT INTO darkrp_wiseguys VALUES(" .. sql.SQLStr(steamID) .. ", " .. time .. ");")
	else
		-- There is a jail record for this player
		if time == 0 then
			-- If we are reducing their jail time to zero, delete their record
			sql.Query("DELETE FROM darkrp_wiseguys WHERE steam = " .. sql.SQLStr(steamID) .. ";")
		else
			-- Increase this player's sentence by the amount specified
			sql.Query("UPDATE darkrp_wiseguys SET time = " .. r + time .. " WHERE steam = " .. sql.SQLStr(steamID) .. ");")
		end
	end
end

function DB.RetrieveJailStatus(ply)
	-- How much time does this player owe in jail?
	local r = tonumber(sql.QueryValue("SELECT time FROM darkrp_wiseguys WHERE steam = " .. sql.SQLStr(ply:SteamID()) .. ";"))
	if r then
		return r
	else
		return 0
	end
end

function DB.StoreRPName(ply, name)
	if not name or string.len(name) < 3 then return end
	local r = sql.QueryValue("SELECT name FROM darkrp_rpnames WHERE steam = " .. sql.SQLStr(ply:SteamID()) .. ";")
	if r then
		sql.Query("UPDATE darkrp_rpnames SET name = " .. sql.SQLStr(name) .. " WHERE steam = " .. sql.SQLStr(ply:SteamID()) .. ";")
	else
		sql.Query("INSERT INTO darkrp_rpnames VALUES(" .. sql.SQLStr(ply:SteamID()) .. ", " .. sql.SQLStr(name) .. ");")
	end

	-- Change the owner of all props to the new name
	for k, v in pairs(ents.FindByClass("prop_*")) do
		if v:GetNWString("Owner") == ply:Name() then
			v:SetNWString("Owner", name)
		end
	end
	ply:SetNWString("rpname", name)
end

function DB.RetrieveRPNames()
	local r = sql.Query("SELECT * FROM darkrp_rpnames;")
	if r then return r else return {} end
end

function DB.RetrieveRPName(ply)
	return sql.QueryValue("SELECT name FROM darkrp_rpnames WHERE steam = " .. sql.SQLStr(ply:SteamID()) .. ";")
end

function DB.StoreTeamSpawnPos(t, pos)
	local map = string.lower(game.GetMap())
	local already = tonumber(sql.QueryValue("SELECT COUNT(*) FROM darkrp_tspawns WHERE team = " .. t .. " AND map = " .. sql.SQLStr(map) .. ";"))
	if not already or already == 0 then
		sql.Query("INSERT INTO darkrp_tspawns VALUES(" .. sql.SQLStr(map) .. ", " .. t .. ", " .. pos[1] .. ", " .. pos[2] .. ", " .. pos[3] .. ");")
		print(team.GetName(t).."'s spawn position created.")
	else
		sql.Query("UPDATE darkrp_tspawns SET x = " .. pos[1] .. ", y = " .. pos[2] .. ", z = " .. pos[3] .. " WHERE team = " .. t .. " AND map = " .. sql.SQLStr(map) .. ";")
		print(team.GetName(t).."'s spawn position updated.")
	end
end

function DB.RetrieveTeamSpawnPos(ply)
	local map = string.lower(game.GetMap())
	local t = ply:Team()
	
	-- this should return a map name.
	local r = sql.QueryValue("SELECT x FROM darkrp_tspawns WHERE team = " .. t .. " AND map = ".. sql.SQLStr(map)..";")
	if not r then return nil end
	
	local x = sql.QueryValue("SELECT x FROM darkrp_tspawns WHERE team = " .. t .. " AND map = ".. sql.SQLStr(map)..";")
	local y = sql.QueryValue("SELECT y FROM darkrp_tspawns WHERE team = " .. t .. " AND map = ".. sql.SQLStr(map)..";")
	local z = sql.QueryValue("SELECT z FROM darkrp_tspawns WHERE team = " .. t .. " AND map = ".. sql.SQLStr(map)..";")
	return Vector(x,y,z)
end

function DB.StoreZombies()
	local map = string.lower(game.GetMap())
	sql.Begin()
	sql.Query("DELETE FROM darkrp_zspawns WHERE map = " .. sql.SQLStr(map) .. ";")

	for k, v in pairs(zombieSpawns) do
		local s = string.Explode(" ", v)
		sql.Query("INSERT INTO darkrp_zspawns VALUES(" .. sql.SQLStr(map) .. ", " .. s[1] .. ", " .. s[2] .. ", " .. s[3] .. ");")
	end
	sql.Commit()
end

function DB.RetrieveZombies()
	zombieSpawns = {}
	local r = sql.Query("SELECT * FROM darkrp_zspawns WHERE map = " .. sql.SQLStr(string.lower(game.GetMap())) .. ";")
	if not r then return end
	for map, row in pairs(r) do
		zombieSpawns[map] = tostring(row.x) .. " " .. tostring(row.y) .. " " .. tostring(row.z)
	end
end
--[[ 
function DB.RetrieveRandomZombieSpawnPos()
	local map = string.lower(game.GetMap())
	local r = false
	local c = tonumber(sql.QueryValue("SELECT COUNT(*) FROM darkrp_zspawns WHERE map = " .. sql.SQLStr(map) .. ";"))
	if c and c >= 1 then
		r = sql.QueryRow("SELECT * FROM darkrp_zspawns WHERE map = " .. sql.SQLStr(map) .. ";", math.random(1, c))
		return Vector(r.x, r.y, r.z)
	else
		return Vector(0,0,0)
	end
end
 ]]
 
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

function DB.RetrieveRandomZombieSpawnPos()
	local map = string.lower(game.GetMap())
	local r = false
	local c = tonumber(sql.QueryValue("SELECT COUNT(*) FROM darkrp_zspawns WHERE map = " .. sql.SQLStr(map) .. ";"))
    
	if c and c >= 1 then
		r = sql.QueryRow("SELECT * FROM darkrp_zspawns WHERE map = " .. sql.SQLStr(map) .. ";", math.random(1, c))
        if not IsEmpty(Vector(r.x, r.y, r.z)) then
			local found = false
			for i = 40, 200, 10 do
				if IsEmpty(Vector(r.x, r.y, r.z) + Vector(i, 0, 0)) then
					found = true
					return Vector(r.x, r.y, r.z) + Vector(i, 0, 0)
				end
			end
			
			if not found then
				for i = 40, 200, 10 do
					if IsEmpty(Vector(r.x, r.y, r.z) + Vector(0, i, 0)) then
						found = true
						return Vector(r.x, r.y, r.z) + Vector(0, i, 0)
					end
				end
			end
			
			if not found then
				for i = 40, 200, 10 do
					if IsEmpty(Vector(r.x, r.y, r.z) + Vector(-i, 0, 0)) then
						found = true
						return Vector(r.x, r.y, r.z) + Vector(-i, 0, 0)
					end
				end
			end
			
			if not found then
				for i = 40, 200, 10 do
					if IsEmpty(Vector(r.x, r.y, r.z) + Vector(0, -i, 0)) then
						found = true
						return Vector(r.x, r.y, r.z) + Vector(0, -i, 0)
					end
				end
			end
		else
			return Vector(r.x, r.y, r.z)
		end
    end  
	return Vector(r.x, r.y, r.z) + Vector(0,0,70)        
end

function DB.StoreMoney(ply, amount)
	if not ValidEntity(ply) then return end
	if amount < 0  then return end
	local steamID = ply:SteamID()
	local r = sql.QueryValue("SELECT amount FROM darkrp_wallets WHERE steam = " .. sql.SQLStr(steamID) .. ";")
	if r then
		sql.Query("UPDATE darkrp_wallets SET amount = " .. math.floor(amount) .. " WHERE steam = " .. sql.SQLStr(steamID) .. ";")
	else
		sql.Query("INSERT INTO darkrp_wallets VALUES(" .. sql.SQLStr(steamID) .. ", " .. math.floor(amount) .. ");")
	end
	ply:SetNWInt("money", math.floor(amount))
end

function DB.RetrieveMoney(ply)
	if not ValidEntity(ply) then return 0 end
	local steamID = ply:SteamID()
	local startingAmount = 500
		
	local r = sql.QueryValue("SELECT amount FROM darkrp_wallets WHERE steam = " .. sql.SQLStr(ply:SteamID()) .. ";")
	if r then
		ply:SetNWInt("money", math.floor(r))
		return r
	else
		-- No record yet, setting starting cash to 500
		DB.StoreMoney(ply, startingAmount)
		return startingAmount
	end
end

function DB.PayPlayer(ply1, ply2, amount)
	if not ValidEntity(ply1) or not ValidEntity(ply2) then return end
	local sid1 = ply1:SteamID()
	local sid2 = ply2:SteamID()
	sql.Begin() -- Transaction
		sql.Query("UPDATE darkrp_wallets SET amount = amount - " ..  amount .. " WHERE steam = " .. sql.SQLStr(sid1) .. ";")
		sql.Query("UPDATE darkrp_wallets SET amount = amount + " ..  amount .. " WHERE steam = " .. sql.SQLStr(sid2) .. ";")
	sql.Commit()
	DB.RetrieveMoney(ply1)
	DB.RetrieveMoney(ply2)
end

function DB.StoreSalary(ply, amount)
	local steamID = ply:SteamID()
	local already = tonumber(sql.QueryValue("SELECT COUNT(*) FROM darkrp_salaries WHERE steam = " .. sql.SQLStr(steamID) .. ";"))
	if not already or already == 0 then
		sql.Query("INSERT INTO darkrp_salaries VALUES(" .. sql.SQLStr(steamID) .. ", " .. math.floor(amount) .. ");")
	else
		sql.Query("UPDATE darkrp_salaries SET salary = " .. math.floor(amount) .. " WHERE steam = " .. sql.SQLStr(steamID) .. ";")
	end
	ply:SetNWInt("salary", math.floor(amount))
	return amount
end

function DB.RetrieveSalary(ply)
	if not ValidEntity(ply) then return 0 end
	local steamID = ply:SteamID()
	local normal = GetGlobalInt("normalsalary")

	local r = sql.QueryValue("SELECT salary FROM darkrp_salaries WHERE steam = " .. sql.SQLStr(steamID) .. ";")
	if not r then
		DB.StoreSalary(ply, normal)
		return normal
	else
		return r
	end
end

function DB.StoreDoorOwnability(ent)
	local map = string.lower(game.GetMap())
	local nonOwnable = ent:GetNWBool("nonOwnable")
	local r = tonumber(sql.QueryValue("SELECT COUNT(*) FROM darkrp_disableddoors WHERE map = " .. sql.SQLStr(map) .. " AND idx = " .. ent:EntIndex() .. ";"))
	if not r then return end

	if r > 0 and not nonOwnable then
		sql.Query("DELETE FROM darkrp_disableddoors WHERE map = " .. sql.SQLStr(map) .. " AND idx = " .. ent:EntIndex() .. ";")
	elseif r == 0 and nonOwnable then
		sql.Query("INSERT INTO darkrp_disableddoors VALUES(" .. sql.SQLStr(map) .. ", " .. ent:EntIndex() .. ", " .. sql.SQLStr("Non-Ownable Door") .. ");")
	end
end

function DB.StoreNonOwnableDoorTitle(ent, text)
	sql.Query("UPDATE darkrp_disableddoors SET title = " .. sql.SQLStr(text) .. " WHERE map = " .. sql.SQLStr(string.lower(game.GetMap())) .. " AND idx = " .. ent:EntIndex() .. ";")
	ent:SetNWString("dTitle", text)
end

function DB.SetUpNonOwnableDoors()
	local r = sql.Query("SELECT idx, title FROM darkrp_disableddoors WHERE map = " .. sql.SQLStr(string.lower(game.GetMap())) .. ";")
	if not r then return end

	for _, row in pairs(r) do
		local e = ents.GetByIndex(tonumber(row.idx))
		e:SetNWBool("nonOwnable", true)
		e:SetNWString("dTitle", row.title)
	end
end


function DB.StoreCPDoorOwnability(ent)
	local map = string.lower(game.GetMap())
	local CPOwnable = ent:GetNWBool("CPOwnable")
	local r = tonumber(sql.QueryValue("SELECT COUNT(*) FROM darkrp_cpdoors WHERE map = " .. sql.SQLStr(map) .. " AND idx = " .. ent:EntIndex() .. ";"))
	if not r then return end

	if r > 0 and not CPOwnable then
		sql.Query("DELETE FROM darkrp_cpdoors WHERE map = " .. sql.SQLStr(map) .. " AND idx = " .. ent:EntIndex() .. ";")
	elseif r == 0 and CPOwnable then
		sql.Query("INSERT INTO darkrp_cpdoors VALUES(" .. sql.SQLStr(map) .. ", " .. ent:EntIndex() .. ", " .. sql.SQLStr("CP-Ownable Door") .. ");")
	end
end

function DB.StoreCPOwnableDoorTitle(ent, text)
	sql.Query("UPDATE darkrp_cpdoors SET title = " .. sql.SQLStr(text) .. " WHERE map = " .. sql.SQLStr(string.lower(game.GetMap())) .. " AND idx = " .. ent:EntIndex() .. ";")
	ent:SetNWString("dTitle", text)
end

function DB.SetUpCPOwnableDoors()
	local r = sql.Query("SELECT idx, title FROM darkrp_cpdoors WHERE map = " .. sql.SQLStr(string.lower(game.GetMap())) .. ";")
	if not r then return end

	for _, row in pairs(r) do
		local e = ents.GetByIndex(tonumber(row.idx))
		e:SetNWBool("CPOwnable", true)
		e:SetNWString("dTitle", row.title)
	end
end

function DB.RetrieveSettings()
	local r = sql.Query("SELECT key, value FROM darkrp_settings;")
	if not r then return false end
	
	for k, v in pairs(r) do
		CfgVars[v.key] = tonumber(v.value)
	end
	return true
end

function DB.SaveSetting(key, value)
	local r = sql.QueryValue("SELECT value FROM darkrp_settings WHERE key = "..sql.SQLStr(key)..";")
	if not r then
		sql.Query("INSERT INTO darkrp_settings VALUES(" .. sql.SQLStr(key) .. ", " .. value .. ");")
		print("Created", key, "=", value)
	elseif tonumber(r) ~= value then
		sql.Query("UPDATE darkrp_settings SET value = " .. value .. " WHERE key = " .. sql.SQLStr(key) .. ";")
		print("updated", key, "to", value)
	end
	CfgVars[key] = value
end

function DB.RemoveSettings()
	sql.Query("DELETE FROM darkrp_settings;")
end

function DB.RetrieveGlobals()
	local r = sql.Query("SELECT key, value FROM darkrp_globals;")
	if not r then return false end
	
	for k, v in pairs(r) do
		SetGlobalInt(v.key, tonumber(v.value))
	end
	if #r < 30 then
		RefreshGlobals()
	end
	return r
end

function DB.SaveGlobal(key, value)
	local r = sql.QueryValue("SELECT value FROM darkrp_globals WHERE key = "..sql.SQLStr(key)..";")
	if not r then
		sql.Query("INSERT INTO darkrp_globals VALUES(" .. sql.SQLStr(key) .. ", " .. value .. ");")
		print("Created", key, "=", value)
	elseif tonumber(r) ~= value then
		sql.Query("UPDATE darkrp_globals SET value = " .. value .. " WHERE key = " .. sql.SQLStr(key) .. ";")
		print("updated", key, "to", value)
	end
	SetGlobalInt(key, value)
end

function DB.RemoveGlobals()
	sql.Query("DELETE FROM darkrp_globals;")
end

function SendGlobalIntsOnSpawn(ply)
	for k,v in pairs(GlobalInts) do
		if v ~= 0 then
			umsg.Start("FRecieveGlobalInt", ply)
				umsg.Long(v)
				umsg.String(k)
			umsg.End()
		else
			GlobalInts[k] = nil
		end
	end
end
hook.Add("PlayerInitialSpawn", "SendGlobalIntsOnSpawn", SendGlobalIntsOnSpawn)