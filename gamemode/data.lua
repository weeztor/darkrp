include("static_data.lua")

/*---------------------------------------------------------------------------
MySQL and SQLite connectivity
---------------------------------------------------------------------------*/
if file.Exists("../lua/includes/modules/gmsv_mysqloo.dll") or file.Exists("../lua/includes/modules/gmsv_mysqloo_i486.dll") then
	require("mysqloo")
end

local CONNECTED_TO_MYSQL = false
DB.MySQLDB = nil

function DB.Begin()
	if not CONNECTED_TO_MYSQL then sql.Begin() end
end
function DB.Commit()
	if not CONNECTED_TO_MYSQL then sql.Commit() end
end

function DB.Query(query, callback)
	if CONNECTED_TO_MYSQL then 
		if DB.MySQLDB and DB.MySQLDB:status() == mysqloo.DATABASE_NOT_CONNECTED then
			DB.ConnectToMySQL(RP_MySQLConfig.Host, RP_MySQLConfig.Username, RP_MySQLConfig.Password, RP_MySQLConfig.Database_name, RP_MySQLConfig.Database_port)
		end
		
		local query = DB.MySQLDB:query(query)
		local data
		query.onData = function(Q, D)
			data = data or {}
			data[#data + 1] = D
		end
		
		query.onError = function(Q, E) Error(E) callback() DB.Log("MySQL Error: ".. E) end
		query.onSuccess = function()
			if callback then callback(data) end 
		end
		query:start()
		return
	end
	sql.Begin()
	local Result = sql.Query(query)
	sql.Commit() -- Otherwise it won't save, don't ask me why
	if callback then callback(Result) end
	return Result
end

function DB.QueryValue(query, callback)
	if CONNECTED_TO_MYSQL then
		if DB.MySQLDB and DB.MySQLDB:status() == mysqloo.DATABASE_NOT_CONNECTED then
			DB.ConnectToMySQL(RP_MySQLConfig.Host, RP_MySQLConfig.Username, RP_MySQLConfig.Password, RP_MySQLConfig.Database_name, RP_MySQLConfig.Database_port)
		end
		
		local query = DB.MySQLDB:query(query)
		local data
		query.onData = function(Q, D)
			data = D
		end
		query.onSuccess = function()
			for k,v in pairs(data or {}) do
				callback(v)
				return
			end
			callback()
		end
		query.onError = function(Q, E) Error(E) callback() DB.Log("MySQL Error: ".. E) end
		query:start()
		return
	end
	callback(sql.QueryValue(query))
end

function DB.ConnectToMySQL(host, username, password, database_name, database_port)
	if not mysqloo then Error("MySQL modules aren't installed properly!") DB.Log("MySQL Error: MySQL modules aren't installed properly!") end
	local databaseObject = mysqloo.connect(host, username, password, database_name, database_port)
	
	databaseObject.onConnectionFailed = function(msg)
		Error("Connection failed! " ..tostring(msg))
		DB.Log("MySQL Error: Connection failed! "..tostring(msg))
	end
	
	databaseObject.onConnected = function()
		DB.Log("MySQL: Connection to external database "..host.." succeeded!")
		CONNECTED_TO_MYSQL = true
		
		DB.Init() -- Initialize database
	end
	databaseObject:connect() 
	DB.MySQLDB = databaseObject
end

/*---------------------------------------------------------
 Database initialize
 ---------------------------------------------------------*/
function DB.Init()
	DB.Begin()
		DB.Query("CREATE TABLE IF NOT EXISTS darkrp_cvars(var char(20) NOT NULL, value INTEGER NOT NULL, PRIMARY KEY(var));")
		DB.Query("CREATE TABLE IF NOT EXISTS darkrp_tspawns(id INTEGER NOT NULL, map char(30) NOT NULL, team INTEGER NOT NULL, x NUMERIC NOT NULL, y NUMERIC NOT NULL, z NUMERIC NOT NULL, PRIMARY KEY(id));")
		DB.Query("CREATE TABLE IF NOT EXISTS darkrp_salaries(steam char(20) NOT NULL, salary INTEGER NOT NULL, PRIMARY KEY(steam));")
		DB.Query("CREATE TABLE IF NOT EXISTS darkrp_wallets(steam char(20) NOT NULL, amount INTEGER NOT NULL, PRIMARY KEY(steam));")
		DB.Query("CREATE TABLE IF NOT EXISTS darkrp_jailpositions(map char(30) NOT NULL, x NUMERIC NOT NULL, y NUMERIC NOT NULL, z NUMERIC NOT NULL, lastused NUMERIC NOT NULL, PRIMARY KEY(map, x, y, z));")
		DB.Query("CREATE TABLE IF NOT EXISTS darkrp_rpnames(steam char(20) NOT NULL, name char(35) NOT NULL, PRIMARY KEY(steam));")
		DB.Query("CREATE TABLE IF NOT EXISTS darkrp_zspawns(map char(30) NOT NULL, x NUMERIC NOT NULL, y NUMERIC NOT NULL, z NUMERIC NOT NULL);")
		DB.Query("CREATE TABLE IF NOT EXISTS darkrp_doors(map char(30) NOT NULL, idx INTEGER NOT NULL, title char(25), locked INTEGER(1), disabled INTEGER(1), PRIMARY KEY(map, idx));")
		DB.Query("CREATE TABLE IF NOT EXISTS darkrp_groupdoors(map char(30) NOT NULL, idx INTEGER NOT NULL, teams char(50) NOT NULL, title char(25) NOT NULL, PRIMARY KEY(map, idx));")
		DB.Query("CREATE TABLE IF NOT EXISTS darkrp_consolespawns(id INTEGER NOT NULL PRIMARY KEY, map char(30) NOT NULL, x NUMERIC NOT NULL, y NUMERIC NOT NULL, z NUMERIC NOT NULL, pitch NUMERIC NOT NULL, yaw NUMERIC NOT NULL, roll NUMERIC NOT NULL);")
	DB.Commit()

	DB.CreateJailPos()
	DB.CreateSpawnPos()
	DB.CreateZombiePos()
	DB.SetUpNonOwnableDoors()
	DB.SetUpGroupOwnableDoors()
	DB.LoadConsoles()
	
	DB.Query("SELECT * FROM darkrp_cvars;", function(settings)
		if settings then
			local reset = false -- For the old SQLite Databases that had the "key" column instead of "var"
			for k,v in pairs(settings) do
				if v.key then reset = true end
				RunConsoleCommand(v.var or v.key, v.value)
			end
			if reset then -- Renaming the column is impossible in SQLite, so do it the hard way
				DB.Begin()
					DB.Query("ALTER TABLE darkrp_cvars RENAME TO darkrp_cvars2;")
					DB.Query("CREATE TABLE darkrp_cvars (var char(20) NOT NULL, value INTEGER NOT NULL, PRIMARY KEY(var));")
					DB.Query("INSERT INTO darkrp_cvars SELECT * FROM darkrp_cvars2;")
					DB.Query("DROP TABLE darkrp_cvars2;")
				DB.Commit()
			end
		end
	end)
	
	-- Set the lastused of all jailpositions to 0 because the server just started
	DB.Query("UPDATE darkrp_jailpositions SET lastused = 0;")
	
	DB.JailPos = {}
	DB.Query("SELECT * FROM darkrp_jailpositions;", function(jailpos) DB.JailPos = jailpos end)
	
	DB.TeamSpawns = {}
	DB.Query("SELECT * FROM darkrp_tspawns;", function(data) DB.TeamSpawns = data or {} end)
	
	if CONNECTED_TO_MYSQL then -- In a listen server, the connection with the external database is often made AFTER the listen server host has joined, 
								--so he walks around with the settings from the SQLite database
		for k,v in pairs(player.GetAll()) do
			local SteamID = sql.SQLStr(v:SteamID())
			DB.Query([[SELECT amount, salary, name FROM darkrp_wallets 
				LEFT OUTER JOIN darkrp_salaries ON darkrp_wallets.steam = darkrp_salaries.steam
				LEFT OUTER JOIN darkrp_rpnames ON darkrp_wallets.steam = darkrp_rpnames.steam
				WHERE darkrp_wallets.steam = ]].. SteamID ..[[
			;]], function(data)
				local Data = data[1]
				if Data.name then
					v:SetDarkRPVar("rpname", Data.name)
				end
				if Data.salary then
					v:SetDarkRPVar("salary", Data.salary)
				end
				if Data.amount then
					v:SetDarkRPVar("money", Data.amount)
				end
			end)
		end
	end
end

/*---------------------------------------------------------
 positions
 ---------------------------------------------------------*/
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
	DB.Begin()
		for k, v in pairs(zombie_spawn_positions) do
			if map == string.lower(v[1]) then
				if not once then
					DB.Query("DELETE FROM darkrp_zspawns;")
					once = true
				end
				DB.Query("INSERT INTO darkrp_zspawns VALUES(" .. sql.SQLStr(map) .. ", " .. v[2] .. ", " .. v[3] .. ", " .. v[4] .. ");")
			end
		end
	DB.Commit()
end

function DB.StoreZombies()
	local map = string.lower(game.GetMap())
	DB.Begin()
	DB.Query("DELETE FROM darkrp_zspawns WHERE map = " .. sql.SQLStr(map) .. ";", function()
		for k, v in pairs(zombieSpawns) do
			local s = string.Explode(" ", v)
			DB.Query("INSERT INTO darkrp_zspawns VALUES(" .. sql.SQLStr(map) .. ", " .. s[1] .. ", " .. s[2] .. ", " .. s[3] .. ");")
		end
	end)
	DB.Commit()
end

local FirstZombieSpawn = true
function DB.RetrieveZombies(callback)
	if zombieSpawns and table.Count(zombieSpawns) > 0 and not FirstZombieSpawn then callback() return zombieSpawns end
	FirstZombieSpawn = false
	zombieSpawns = {}
	DB.Query("SELECT * FROM darkrp_zspawns WHERE map = " .. sql.SQLStr(string.lower(game.GetMap())) .. ";", function(r)
		if not r then callback() return end
		for map, row in pairs(r) do
			zombieSpawns[map] = tostring(Vector(row.x, row.y, row.z))
		end
		callback()
	end)
end

function DB.RetrieveRandomZombieSpawnPos()
	if #zombieSpawns < 1 then return end
	local r = string.Explode(" ", table.Random(zombieSpawns))
	r = Vector(r[1], r[2], r[3])
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
	
	return Vector(r.x, r.y, r.z) + Vector(0,0,70)        
end

function DB.CreateJailPos()
	if not jail_positions then return end
	local map = string.lower(game.GetMap())

	local once = false
	DB.Begin()
		for k, v in pairs(jail_positions) do
			if map == string.lower(v[1]) then
				if not once then
					DB.Query("DELETE FROM darkrp_jailpositions;", function()
						DB.Query("INSERT INTO darkrp_jailpositions VALUES(" .. sql.SQLStr(map) .. ", " .. v[2] .. ", " .. v[3] .. ", " .. v[4] .. ", " .. 0 .. ");")
					end)
					DB.JailPos = {}
					once = true
					return
				end
				DB.Query("INSERT INTO darkrp_jailpositions VALUES(" .. sql.SQLStr(map) .. ", " .. v[2] .. ", " .. v[3] .. ", " .. v[4] .. ", " .. 0 .. ");")
			end
		end
	DB.Commit()
end

function DB.StoreJailPos(ply, addingPos)
	local map = string.lower(game.GetMap())
	local pos = string.Explode(" ", tostring(ply:GetPos()))
	DB.QueryValue("SELECT COUNT(*) FROM darkrp_jailpositions WHERE map = " .. sql.SQLStr(map) .. ";", function(already)
		if not already or already == 0 then
			DB.Query("INSERT INTO darkrp_jailpositions VALUES(" .. sql.SQLStr(map) .. ", " .. pos[1] .. ", " .. pos[2] .. ", " .. pos[3] .. ", " .. 0 .. ");", function()
				DB.Query("SELECT * FROM darkrp_jailpositions;", function(jailpos) DB.JailPos = jailpos end)
			end)
			Notify(ply, 0, 4,  LANGUAGE.created_first_jailpos)
		else
			if addingPos then
				DB.Query("INSERT INTO darkrp_jailpositions VALUES(" .. sql.SQLStr(map) .. ", " .. pos[1] .. ", " .. pos[2] .. ", " .. pos[3] .. ", " .. 0 .. ");", function()
					DB.Query("SELECT * FROM darkrp_jailpositions;", function(jailpos) DB.JailPos = jailpos end)
				end)
				Notify(ply, 0, 4,  LANGUAGE.added_jailpos)
			else
				DB.Begin()
				DB.Query("DELETE FROM darkrp_jailpositions WHERE map = " .. sql.SQLStr(map) .. ";")
				DB.Query("INSERT INTO darkrp_jailpositions VALUES(" .. sql.SQLStr(map) .. ", " .. pos[1] .. ", " .. pos[2] .. ", " .. pos[3] .. ", " .. 0 .. ");", function()
					DB.Query("SELECT * FROM darkrp_jailpositions;", function(jailpos) DB.JailPos = jailpos end)
				end)
				DB.Commit()
				Notify(ply, 0, 5,  LANGUAGE.reset_add_jailpos)
			end
		end
	end)
end

function DB.RetrieveJailPos()
	local map = string.lower(game.GetMap())
	local r = DB.JailPos
	if not r then return Vector(0,0,0) end
	
	-- Retrieve the least recently used jail position
	local now = CurTime()
	local oldest = 0
	local ret
	
	for k, row in pairs(r) do
		if row.map == map and (now - tonumber(row.lastused)) > oldest then
			oldest = (now - tonumber(row.lastused))
			ret = row
		elseif row.map == map and oldest == 0 then
			ret = row
		end
	end
	-- Mark that position as having been used just now
	if ret then DB.Query("UPDATE darkrp_jailpositions SET lastused = " .. CurTime() .. " WHERE map = " .. sql.SQLStr(map) .. " AND x = " .. ret.x .. " AND y = " .. ret.y .. " AND z = " .. ret.z .. ";", function()
		DB.Query("SELECT * FROM darkrp_jailpositions;", function(jailpos) DB.JailPos = jailpos end)
	end) end
	return ret and Vector(ret.x, ret.y, ret.z)
end

function DB.SaveSetting(setting, value)
	DB.Query("SELECT value FROM darkrp_cvars WHERE var = "..sql.SQLStr(setting)..";", function(Data)
		if Data then
			DB.Query("UPDATE darkrp_cvars set Value = " .. sql.SQLStr(value) .." WHERE var = " .. sql.SQLStr(setting)..";")
		else
			DB.Query("INSERT INTO darkrp_cvars VALUES("..sql.SQLStr(setting)..","..sql.SQLStr(value)..");")
		end
	end)
end

function DB.CountJailPos()
	return table.Count(DB.JailPos or {})
end

local function FixDarkRPTspawnsTable() -- SQLite only
	local FixTable = sql.Query("SELECT * FROM darkrp_tspawns;")
	if not FixTable or (FixTable and FixTable[1] and not FixTable[1].id) then -- The old tspawns table didn't have an 'id' column, this checks if the table is out of date
		sql.Query("DROP TABLE IF EXISTS darkrp_tspawns;") -- Remove the table and remake it
		sql.Query("CREATE TABLE IF NOT EXISTS darkrp_tspawns(id INTEGER NOT NULL, map TEXT NOT NULL, team INTEGER NOT NULL, x NUMERIC NOT NULL, y NUMERIC NOT NULL, z NUMERIC NOT NULL, PRIMARY KEY(id));")
		for k,v in pairs(FixTable or {}) do -- Put back the old data in the new format so the end user will not notice any changes, if there was nothing in the old table then loop through nothing
			sql.Query("INSERT INTO darkrp_tspawns VALUES(NULL, "..sql.SQLStr(v.map)..", "..v.team..", "..v.x..", "..v.y..", "..v.z..");")
		end
	end
end

function DB.StoreTeamSpawnPos(t, pos)
	if not CONNECTED_TO_MYSQL then FixDarkRPTspawnsTable() end -- Check if the server doesn't use an out of date version of this table
	local map = string.lower(game.GetMap())
	DB.QueryValue("SELECT COUNT(*) FROM darkrp_tspawns WHERE team = " .. t .. " AND map = " .. sql.SQLStr(map) .. ";", function(already)
		already = tonumber(already)
		local ID = 0
		local found = false
		for k,v in SortedPairs(DB.TeamSpawns or {}) do 
			if tonumber(v.id) == ID + 1 then
				ID = tonumber(v.id)
				found = true
			else
				ID = ID + 1
				found = false
				break
			end
		end
		if found or ID == 0 then ID = ID + 1 end
		
		if not already or already == 0 then
			DB.Query("INSERT INTO darkrp_tspawns VALUES(".. ID .. ", ".. sql.SQLStr(map) .. ", " .. t .. ", " .. pos[1] .. ", " .. pos[2] .. ", " .. pos[3] .. ");", function()
				DB.Query("SELECT * FROM darkrp_tspawns;", function(data) DB.TeamSpawns = data or {} end) end)
			print(string.format(LANGUAGE.created_spawnpos, team.GetName(t)))
		else
			DB.RemoveTeamSpawnPos(t, function() -- Remove everything and create new
				DB.Query("INSERT INTO darkrp_tspawns VALUES(".. ID .. ", ".. sql.SQLStr(map) .. ", " .. t .. ", " .. pos[1] .. ", " .. pos[2] .. ", " .. pos[3] .. ");", function()
					DB.Query("SELECT * FROM darkrp_tspawns;", function(data) DB.TeamSpawns = data or {} end) end)
			end)
			print(string.format(LANGUAGE.updated_spawnpos, team.GetName(t)))
		end
	end)
end

function DB.AddTeamSpawnPos(t, pos)
	if not CONNECTED_TO_MYSQL then FixDarkRPTspawnsTable() end -- Check if the server doesn't use an out of date version of this table
	local map = string.lower(game.GetMap())
	local ID = 0
	local found = false
	for k,v in SortedPairs(DB.TeamSpawns or {}) do 
		if tonumber(v.id) == ID + 1 then
			ID = tonumber(v.id)
			found = true
		else
			ID = ID + 1
			found = false
			break
		end
	end
	if found or ID == 0 then ID = ID + 1 end
	
	DB.Query("INSERT INTO darkrp_tspawns VALUES(".. ID .. ", " .. sql.SQLStr(map) .. ", " .. t .. ", " .. pos[1] .. ", " .. pos[2] .. ", " .. pos[3] .. ");", function()
		DB.Query("SELECT * FROM darkrp_tspawns;", function(data) DB.TeamSpawns = data or {} end) end)
end

function DB.RemoveTeamSpawnPos(t, callback)
	local map = string.lower(game.GetMap())
	DB.Query("DELETE FROM darkrp_tspawns WHERE team = "..t..";", function()
		DB.Query("SELECT * FROM darkrp_tspawns;", function(data) DB.TeamSpawns = data or {} end)
		if callback then callback() end
	end)
end
	
function DB.RetrieveTeamSpawnPos(ply)
	local map = string.lower(game.GetMap())
	local t = ply:Team()
	
	local returnal = {}
	
	if DB.TeamSpawns then
		for k,v in pairs(DB.TeamSpawns) do
			if v.map == map and tonumber(v.team) == t then
				table.insert(returnal, Vector(v.x, v.y, v.z))
			end
		end
		return (table.Count(returnal) > 0 and returnal) or nil
	end
end

/*---------------------------------------------------------
Players 
 ---------------------------------------------------------*/
function DB.StoreRPName(ply, name)
	if not name or string.len(name) < 2 then return end
	ply:SetDarkRPVar("rpname", name)
	DB.QueryValue("SELECT name FROM darkrp_rpnames WHERE steam = " .. sql.SQLStr(ply:SteamID()) .. ";", function(r)
		if r then
			DB.Query("UPDATE darkrp_rpnames SET name = " .. sql.SQLStr(name) .. " WHERE steam = " .. sql.SQLStr(ply:SteamID()) .. ";")
		else
			DB.Query("INSERT INTO darkrp_rpnames VALUES(" .. sql.SQLStr(ply:SteamID()) .. ", " .. sql.SQLStr(name) .. ");")
		end
	end)
end

function DB.RetrieveRPNames(ply, name, callback)
	DB.Query("SELECT COUNT(*) AS count FROM darkrp_rpnames WHERE name = "..sql.SQLStr(name)..
	" AND steam <> 'UNKNOWN' AND steam <> 'STEAM_ID_PENDING'"..
	" AND steam <> "..sql.SQLStr(ply:SteamID())..";", function(r)
		callback(tonumber(r[1].count) > 0)
	end)
end

function DB.RetrieveRPName(ply, callback)
	DB.QueryValue("SELECT name FROM darkrp_rpnames WHERE steam = " .. sql.SQLStr(ply:SteamID()) .. ";", callback)
end

function DB.StoreMoney(ply, amount)
	if not ValidEntity(ply) then return end
	if amount < 0  then return end
	ply:SetDarkRPVar("money", math.floor(amount))
	
	local steamID = ply:SteamID()
	DB.QueryValue("SELECT amount FROM darkrp_wallets WHERE steam = " .. sql.SQLStr(steamID) .. ";", function(r)
		if r then
			DB.Query("UPDATE darkrp_wallets SET amount = " .. math.floor(amount) .. " WHERE steam = " .. sql.SQLStr(steamID) .. ";")
		else
			DB.Query("INSERT INTO darkrp_wallets VALUES(" .. sql.SQLStr(steamID) .. ", " .. math.floor(amount) .. ");")
		end
	end)
end

function DB.RetrieveMoney(ply) -- This is only run once when the player joins, there's no need for a cache unless the player keeps rejoining.
	if not ValidEntity(ply) then return 0 end
	local steamID = ply:SteamID()
	local startingAmount = GetConVarNumber("startingmoney") or 500
		
	DB.QueryValue("SELECT amount FROM darkrp_wallets WHERE steam = " .. sql.SQLStr(ply:SteamID()) .. ";", function(r)
		if r then
			ply:SetDarkRPVar("money", math.floor(r))
		else
			-- No record yet, setting starting cash to 500
			DB.StoreMoney(ply, startingAmount)
		end
	end)
end

function DB.ResetAllMoney(ply,cmd,args)
	if not ply:IsSuperAdmin() then return end
	DB.Query("DELETE FROM darkrp_wallets;")
	for k,v in pairs(player.GetAll()) do
		v:SetDarkRPVar("money", GetConVarNumber("startingmoney") or 500)
	end
	if ply:IsPlayer() then
		NotifyAll(0,4, string.format(LANGUAGE.reset_money, ply:Nick()))
	else
		NotifyAll(0,4, string.format(LANGUAGE.reset_money, "Console"))
	end
end
concommand.Add("rp_resetallmoney", DB.ResetAllMoney)

function DB.PayPlayer(ply1, ply2, amount)
	if not ValidEntity(ply1) or not ValidEntity(ply2) then return end
	ply1:AddMoney(-amount)
	ply2:AddMoney(amount)
end

function DB.StoreSalary(ply, amount)
	local steamID = ply:SteamID()
	ply:SetDarkRPVar("salary", math.floor(amount))
	DB.QueryValue("SELECT COUNT(*) FROM darkrp_salaries WHERE steam = " .. sql.SQLStr(steamID) .. ";", function(already)
		if not already or already == 0 then
			DB.Query("INSERT INTO darkrp_salaries VALUES(" .. sql.SQLStr(steamID) .. ", " .. math.floor(amount) .. ");")
		else
			DB.Query("UPDATE darkrp_salaries SET salary = " .. math.floor(amount) .. " WHERE steam = " .. sql.SQLStr(steamID) .. ";")
		end
	end)
	
	return amount
end

function DB.RetrieveSalary(ply, callback)
	if not ValidEntity(ply) then return 0 end
	local steamID = ply:SteamID()
	local normal = GetConVarNumber("normalsalary")
	if ply.DarkRPVars.salary then return callback and callback(ply.DarkRPVars.salary) end -- First check the cache.

	DB.QueryValue("SELECT salary FROM darkrp_salaries WHERE steam = " .. sql.SQLStr(steamID) .. ";", function(r)
		if not r then
			ply:SetDarkRPVar("salary", normal)
			callback(normal)
		else
			callback(r)
		end
	end)
end

/*---------------------------------------------------------
 Doors
 ---------------------------------------------------------*/
function DB.StoreDoorOwnability(ent)
	local map = string.lower(game.GetMap())
	ent.DoorData = ent.DoorData or {}
	local nonOwnable = ent.DoorData.NonOwnable
	DB.QueryValue("SELECT locked FROM darkrp_doors WHERE map = " .. sql.SQLStr(map) .. " AND idx = " .. ent:EntIndex() .. ";", function(r)
		print(r)
		if r and not nonOwnable then
			DB.Query("UPDATE darkrp_doors SET disabled = 0 WHERE map = " .. sql.SQLStr(map) .. " AND idx = " .. ent:EntIndex() .. ";")
		elseif nonOwnable then
			DB.Query("REPLACE INTO darkrp_doors VALUES(" .. sql.SQLStr(map) .. ", " .. ent:EntIndex() .. ", " .. sql.SQLStr(ent.DoorData.title or "") .. ", "..(tobool(r) and 1 or 0)..", 1);")
		end
	end)
end

function DB.StoreNonOwnableDoorTitle(ent, text)
	ent.DoorData = ent.DoorData or {}
	ent.DoorData.title = text
	DB.Query("UPDATE darkrp_doors SET title = " .. sql.SQLStr(text) .. " WHERE map = " .. sql.SQLStr(string.lower(game.GetMap())) .. " AND idx = " .. ent:EntIndex() .. ";")
end

function DB.SetUpNonOwnableDoors()
	DB.Query("SELECT idx, title, locked, disabled FROM darkrp_doors WHERE map = " .. sql.SQLStr(string.lower(game.GetMap())) .. ";", function(r)
		if not r then return end

		for _, row in pairs(r) do
			local e = ents.GetByIndex(tonumber(row.idx))
			if ValidEntity(e) then
				e.DoorData = e.DoorData or {}
				e.DoorData.NonOwnable = tobool(row.disabled)
				e:Fire((tobool(row.locked) and "" or "un").."lock", "", 0)
				e.DoorData.title = row.title
			end
		end
	end)
end

function DB.StoreGroupDoorOwnability(ent)
	local map = string.lower(game.GetMap())
	ent.DoorData = ent.DoorData or {}
	
	DB.QueryValue("SELECT COUNT(*) FROM darkrp_groupdoors WHERE map = " .. sql.SQLStr(map) .. " AND idx = " .. ent:EntIndex() .. ";", function(r)
		r = tonumber(r)
		if not r then return end

		if r > 0 and not ent.DoorData.GroupOwn then
			DB.Query("DELETE FROM darkrp_groupdoors WHERE map = " .. sql.SQLStr(map) .. " AND idx = " .. ent:EntIndex() .. ";")
		elseif r == 0 and ent.DoorData.GroupOwn then
			DB.Query("INSERT INTO darkrp_groupdoors VALUES(" .. sql.SQLStr(map) .. ", " .. ent:EntIndex() .. ", " .. sql.SQLStr(ent.DoorData.GroupOwn) .. ", " .. sql.SQLStr(ent.DoorData.title or "") .. ");")
		elseif r == 1 then
			DB.Query("UPDATE darkrp_groupdoors SET teams = "..sql.SQLStr(ent.DoorData.GroupOwn) .. " WHERE map = " .. sql.SQLStr(map) .. " AND idx = " .. ent:EntIndex() .. ";")
		end
	end)
end

function DB.StoreGroupOwnableDoorTitle(ent, text)
	DB.Query("UPDATE darkrp_groupdoors SET title = " .. sql.SQLStr(text) .. " WHERE map = " .. sql.SQLStr(string.lower(game.GetMap())) .. " AND idx = " .. ent:EntIndex() .. ";")
	e.DoorData = e.DoorData or {}
	ent.DoorData.title = text
end

function DB.SetUpGroupOwnableDoors()
	DB.Query("SELECT idx, title, teams FROM darkrp_groupdoors WHERE map = " .. sql.SQLStr(string.lower(game.GetMap())) .. ";", function(r)
		if not r then return end

		for _, row in pairs(r) do
			local e = ents.GetByIndex(tonumber(row.idx))
			if ValidEntity(e) then
				e.DoorData = e.DoorData or {}
				e.DoorData.title = row.title
				e.DoorData.GroupOwn = row.teams
			end
		end
	end)
end

function DB.LoadConsoles()
	local map = string.lower(game.GetMap())
	DB.Query("SELECT * FROM darkrp_consolespawns WHERE map = " .. sql.SQLStr(map) .. ";", function(data)
		if data then
			for k, v in pairs(data) do
				local console = ents.Create("darkrp_console")
				console:SetPos(Vector(tonumber(v.x), tonumber(v.y), tonumber(v.z)))
				console:SetAngles(Angle(tonumber(v.pitch), tonumber(v.yaw), tonumber(v.roll)))
				console:Spawn()
				console.ID = v.id
			end
		else -- If there are no custom positions in the database, use the presets.
			for k,v in pairs(RP_ConsolePositions) do
				if v[1] == map then
					local console = ents.Create("darkrp_console")
					console:SetPos(Vector(RP_ConsolePositions[k][2], RP_ConsolePositions[k][3], RP_ConsolePositions[k][4]))
					console:SetAngles(Angle(RP_ConsolePositions[k][5], RP_ConsolePositions[k][6], RP_ConsolePositions[k][7]))
					console:Spawn()
					console:Activate()
					
					console.ID = "0"
				end
			end
		end
	end)
end

function DB.CreateConsole(ply, cmd, args)
	if not ply:IsSuperAdmin() then return end
	
	local tr = {}
	tr.start = ply:EyePos()
	tr.endpos = ply:EyePos() + 95 * ply:GetAimVector()
	tr.filter = ply
	local trace = util.TraceLine(tr)
	
	local console = ents.Create("darkrp_console")
	console:SetPos(trace.HitPos)
	console:Spawn()
	console:Activate()
	
	DB.QueryValue("SELECT MAX(id) FROM darkrp_consolespawns;", function(Data)
		console.ID = (tonumber(Data) and tostring(tonumber(Data) + 1)) or "1"	
	end)
	
	ply:ChatPrint("Console spawned, move and freeze it to save it!")
end
concommand.Add("rp_CreateConsole", DB.CreateConsole)

function DB.RemoveConsoles(ply, cmd, args)
	if not ply:IsSuperAdmin() then return end
	DB.Query("DELETE FROM darkrp_consolespawns WHERE map = " .. sql.SQLStr(string.lower(game.GetMap())) .. ";")
end
concommand.Add("rp_removeallconsoles", DB.RemoveConsoles)

/*---------------------------------------------------------
 Logging
 ---------------------------------------------------------*/
function DB.Log(text, force)
	if (not util.tobool(GetConVarNumber("logging")) or not text) and not force then return end
	if not DB.File then -- The log file of this session, if it's not there then make it!
		if not file.IsDir("DarkRP_logs") then
			file.CreateDir("DarkRP_logs")
		end
		DB.File = "DarkRP_logs/"..os.date("%m_%d_%Y %I_%M %p")..".txt"
		file.Write(DB.File, os.date().. "\t".. text)
		return
	end
	file.Write(DB.File, (file.Read(DB.File) or "").."\n"..os.date().. "\t"..(text or ""))
end