FPP = FPP or {}

sql.Begin()
	sql.Query("CREATE TABLE IF NOT EXISTS FPP_BLOCKED('id' INTEGER NOT NULL, 'key' TEXT NOT NULL, 'value' TEXT NOT NULL, PRIMARY KEY('id'));")
	sql.Query("CREATE TABLE IF NOT EXISTS FPP_PHYSGUN('key' TEXT NOT NULL, 'value' INTEGER NOT NULL, PRIMARY KEY('key'));")
	sql.Query("CREATE TABLE IF NOT EXISTS FPP_GRAVGUN('key' TEXT NOT NULL, 'value' INTEGER NOT NULL, PRIMARY KEY('key'));")
	sql.Query("CREATE TABLE IF NOT EXISTS FPP_TOOLGUN('key' TEXT NOT NULL, 'value' INTEGER NOT NULL, PRIMARY KEY('key'));")
	sql.Query("CREATE TABLE IF NOT EXISTS FPP_PLAYERUSE('key' TEXT NOT NULL, 'value' INTEGER NOT NULL, PRIMARY KEY('key'));")
	sql.Query("CREATE TABLE IF NOT EXISTS FPP_ENTITYDAMAGE('key' TEXT NOT NULL, 'value' INTEGER NOT NULL, PRIMARY KEY('key'));")
	
	sql.Query("CREATE TABLE IF NOT EXISTS FPP_GLOBALSETTINGS('key' TEXT NOT NULL, 'value' INTEGER NOT NULL, PRIMARY KEY('key'));")
	sql.Query("CREATE TABLE IF NOT EXISTS FPP_ANTISPAM('key' TEXT NOT NULL, 'value' INTEGER NOT NULL, PRIMARY KEY('key'));")
	
sql.Commit()

FPP.Blocked = {}
	FPP.Blocked.Physgun = {}
	FPP.Blocked.Spawning = {}
	FPP.Blocked.Gravgun = {}
	FPP.Blocked.Toolgun = {}
	FPP.Blocked.PlayerUse = {}
	FPP.Blocked.EntityDamage = {}

FPP.Settings = {}
	FPP.Settings.FPP_PHYSGUN = {
		toggle = 1,
		adminall = 1,
		worldprops = 0, 
		adminworldprops = 1,
		canblocked = 0,
		admincanblocked = 0,
		shownocross = 1,
		checkconstrained = 1,
		antinoob = 0,
		reloadprotection = 1,
		iswhitelist = 0}
	FPP.Settings.FPP_GRAVGUN = {
		toggle = 1,
		adminall = 1,
		worldprops = 1, 
		adminworldprops = 1,
		canblocked = 0,
		admincanblocked = 0,
		shownocross = 1,
		checkconstrained = 1,
		noshooting = 1,
		iswhitelist = 0}
	FPP.Settings.FPP_TOOLGUN = {
		toggle = 1,
		adminall = 1,
		worldprops = 1, 
		adminworldprops = 1,
		canblocked = 0,
		admincanblocked = 0,
		shownocross = 1,
		checkconstrained = 1,
		duplicatorprotect = 1,
		duplicatenoweapons = 1,
		iswhitelist = 0,
		spawniswhitelist = 0}
	FPP.Settings.FPP_PLAYERUSE = {
		toggle = 0,
		adminall = 1,
		worldprops = 1, 
		adminworldprops = 1,
		canblocked = 0,
		admincanblocked = 1,
		shownocross = 1,
		checkconstrained = 0,
		iswhitelist = 0}
	FPP.Settings.FPP_ENTITYDAMAGE = {
		toggle = 1,
		protectpropdamage = 1,
		adminall = 1,
		worldprops = 1, 
		adminworldprops = 1,
		canblocked = 0,
		admincanblocked = 0,
		shownocross = 1,
		checkconstrained = 0,
		iswhitelist = 0}
	FPP.Settings.FPP_GLOBALSETTINGS = {
		cleanupdisconnected = 1,
		cleanupdisconnectedtime = 120,
		cleanupadmin = 1,
		antispeedhack = 0}
	FPP.Settings.FPP_ANTISPAM = {
		toggle = 1,
		antispawninprop = 1,
		bigpropsize = 5.85,
		bigpropwait = 1.5,
		smallpropdowngradecount = 3,
		smallpropghostlimit = 2,
		smallpropdenylimit = 6,
		duplicatorlimit = 3}

function FPP.Notify(ply, text, bool)
	umsg.Start("FPP_Notify", ply)
		umsg.String(text)
		umsg.Bool(bool)
	umsg.End()
end

function FPP.NotifyAll(text, bool)
	umsg.Start("FPP_Notify")
		umsg.String(text)
		umsg.Bool(bool)
	umsg.End()
end

local function FPP_SetSetting(ply, cmd, args)
	if ply:EntIndex() == 0 then print("Please set the settings ingame in the menu") return end
	if not ply:IsSuperAdmin() then ply:PrintMessage(HUD_PRINTCONSOLE, "You need superadmin privileges in order to be able to use this command") return end
	if not args[1] or not args[3] or not FPP.Settings[args[1]] then ply:PrintMessage(HUD_PRINTCONSOLE, "Argument(s) invalid") return end
	if not FPP.Settings[args[1]][args[2]] then ply:PrintMessage(HUD_PRINTCONSOLE, "Argument invalid") return end
	
	FPP.Settings[args[1]][args[2]] = tonumber(args[3])
	SetGlobalInt(args[1].."_"..args[2], tonumber(args[3]))
	
	local data = sql.QueryValue("SELECT value FROM ".. args[1] .. " WHERE key = "..sql.SQLStr(args[2])..";")
	if not data then
		sql.Query("INSERT INTO ".. args[1] .. " VALUES(" .. sql.SQLStr(args[2]) .. ", " .. args[3] .. ");")
	elseif tonumber(data) ~= args[3] then
		sql.Query("UPDATE ".. args[1] .. " SET value = " .. args[3] .. " WHERE key = " .. sql.SQLStr(args[2]) .. ";")
	end

	FPP.NotifyAll(ply:Nick().. " set ".. string.lower(string.gsub(args[1], "FPP_", "")) .. " "..args[2].." to " .. tostring(args[3]), util.tobool(tonumber(args[3])))
end
concommand.Add("FPP_setting", FPP_SetSetting)

local function AddBlocked(ply, cmd, args)
	if ply:EntIndex() == 0 then print("Please set the settings ingame in the menu") return end
	if not ply:IsSuperAdmin() then ply:PrintMessage(HUD_PRINTCONSOLE, "You need superadmin privileges in order to be able to use this command") return end
	if not args[1] or not args[2] or not FPP.Blocked[args[1]] then ply:PrintMessage(HUD_PRINTCONSOLE, "Argument(s) invalid") return end
	if table.HasValue(FPP.Blocked[args[1]], string.lower(args[2])) then return end
	table.insert(FPP.Blocked[args[1]], string.lower(args[2]))
	
	local data = sql.Query("SELECT * FROM FPP_BLOCKED;")
	if type(data) == "table" then
		local found = false
		for k,v in pairs(data) do
			if v.key == args[1] and v.value == args[2] then
				found = true
			end
		end
		if not found then
			sql.Query("INSERT INTO FPP_BLOCKED VALUES("..#data + 1 ..", " .. sql.SQLStr(args[1]) .. ", " .. sql.SQLStr(args[2]) .. ");")
		end
	else
		--insert
		sql.Query("INSERT INTO FPP_BLOCKED VALUES(1, " .. sql.SQLStr(args[1]) .. ", " .. sql.SQLStr(args[2]) .. ");")
	end
	
	FPP.NotifyAll(ply:Nick().. " added ".. args[2] .. " to the "..args[1] .. " black/whitelist", true)
end
concommand.Add("FPP_AddBlocked", AddBlocked)

local function RemoveBlocked(ply, cmd, args)
	if ply:IsPlayer() then
		if ply:EntIndex() == 0 then print("Please set the settings ingame in the menu") return end
		if not ply:IsSuperAdmin() then ply:PrintMessage(HUD_PRINTCONSOLE, "You need superadmin privileges in order to be able to use this command") return end
		if not args[1] or not args[2] or not FPP.Blocked[args[1]] then ply:PrintMessage(HUD_PRINTCONSOLE, "Argument(s) invalid") return end
	end
	
	for k,v in pairs(FPP.Blocked[args[1]]) do
		if v == args[2] then
			table.remove(FPP.Blocked[args[1]], k)
		end
	end
	
	local data = sql.Query("SELECT * FROM FPP_BLOCKED;")
	
	if type(data) == "table" then
		for k,v in ipairs(data) do
			if v.key == args[1] and v.value == args[2] then
				sql.Query("DELETE FROM FPP_BLOCKED WHERE key = "..sql.SQLStr(v.key) .. " AND value = "..sql.SQLStr(v.value)..";") 
			end
		end
	end
	
	data = sql.Query("SELECT * FROM FPP_BLOCKED;")
	if type(data) == "table" then
	--I know I'm doing a loop twice, but I can't do this in the other loop since this effects the changed database
		for k,v in ipairs(data) do
			sql.Query("UPDATE FPP_BLOCKED SET id = "..sql.SQLStr(k).." WHERE key = "..sql.SQLStr(v.key).. " AND value = "..sql.SQLStr(v.value)..";")
		end
	end
	FPP.NotifyAll(ply:Nick().. " removed ".. args[2] .. " from the "..args[1] .. " black/whitelist", false)
end
concommand.Add("FPP_RemoveBlocked", RemoveBlocked)

local function ShareProp(ply, cmd, args)
	if not args[1] or not ValidEntity(Entity(args[1])) or not args[2] then ply:PrintMessage(HUD_PRINTCONSOLE, "Argument(s) invalid") return end
	local ent = Entity(args[1])
	
	if not FPP.PlayerCanTouchEnt(ply, ent, "Toolgun", "FPP_TOOLGUN", true) then --Note: This returns false when it's someone elses shared entity, so that's not a glitch
		ply:PrintMessage(HUD_PRINTCONSOLE, "You do not have the right to share this entity.")
		return
	end
	
	if not ValidEntity(Player(args[2])) then -- This is for sharing prop per utility
		ent[args[2]] = util.tobool(args[3])
	else -- This is for sharing prop per player
		local target = Player(args[2])
		local toggle = util.tobool(args[3])
		if not ent.AllowedPlayers and toggle then -- Make the table if it isn't there
			ent.AllowedPlayers = {target}
		else
			if toggle and not table.HasValue(ent.AllowedPlayers, target) then
				table.insert(ent.AllowedPlayers, target)
				FPP.Notify(target, ply:Nick().. " shared an entity with you!", true)
			elseif not toggle then
				for k,v in pairs(ent.AllowedPlayers) do
					if v == target then
						table.remove(ent.AllowedPlayers, k)
						FPP.Notify(target, ply:Nick().. " unshared an entity with you!", false)
					end
				end
			end
		end
	end
end
concommand.Add("FPP_ShareProp", ShareProp)

local function RetrieveSettings()	
	for k,v in pairs(FPP.Settings) do
		local data = sql.Query("SELECT key, value FROM "..k..";")
		if data then
			for key, value in pairs(data) do
				FPP.Settings[k][value.key] = tonumber(value.value)
			end
		end
		for a,b in pairs(v) do
			SetGlobalInt(k.."_"..a, b)
		end
	end	
end
RetrieveSettings()

function FRetrieveBlocked()
	local data = sql.Query("SELECT * FROM FPP_BLOCKED;")
	if type(data) == "table" then
		for k,v in pairs(data) do
			table.insert(FPP.Blocked[v.key], v.value)
		end
	else
		data = sql.Query("CREATE TABLE IF NOT EXISTS FPP_BLOCKED('id' INTEGER NOT NULL, 'key' TEXT NOT NULL, 'value' TEXT NOT NULL, PRIMARY KEY('id'));")
		FPP.Blocked.Physgun = {
			"func_breakable_surf",
			"func_brush",
			"func_door",
			"prop_door_rotating",
			"drug", 
			"drug_lab", 
			"food", 
			"gunlab", 
			"letter", 
			"meteor", 
			"microwave", 
			"money_printer", 
			"spawned_shipment", 
			"spawned_weapon",  
			"spawned_food",}
		FPP.Blocked.Spawning = {}
		FPP.Blocked.Gravgun = {"func_breakable_surf", "vehicle_"}
		FPP.Blocked.Toolgun = {"func_breakable_surf",
			"player",
			"func_door",
			"prop_door_rotating",
			"drug", 
			"drug_lab", 
			"food", 
			"gunlab", 
			"letter", 
			"meteor", 
			"microwave", 
			"money_printer", 
			"spawned_shipment", 
			"spawned_weapon",  
			"spawned_food"}
		FPP.Blocked.PlayerUse = {}
		FPP.Blocked.EntityDamage = {}
		
		local count = 0
		sql.Begin()
		for k,v in pairs(FPP.Blocked) do
			for a,b in pairs(v) do
				count = count + 1
				sql.Query("INSERT INTO FPP_BLOCKED VALUES(".. count ..", " .. sql.SQLStr(k) .. ", " .. sql.SQLStr(b) .. ");")
			end 
		end
		sql.Commit()
	end
end
FRetrieveBlocked()

local function SendBlocked(ply, cmd, args)
	--I don't need an admin check here since people should be able to find out without having admin
	if not args[1] or not FPP.Blocked[args[1]] then return end
	for k,v in pairs(FPP.Blocked[args[1]]) do
		umsg.Start("FPP_blockedlist", ply)
			umsg.String(args[1])
			umsg.String(v)
		umsg.End()
	end
end
concommand.Add("FPP_sendblocked", SendBlocked)

--Buddies!
local function SetBuddy(ply, cmd, args)
	if not args[6] then ply:PrintMessage(HUD_PRINTCONSOLE, "Argument(s) invalid") return end
	local buddy = Player(args[1])
	if not ValidEntity(buddy) then ply:PrintMessage(HUD_PRINTCONSOLE, "Player invalid") return end
	
	ply.Buddies = ply.Buddies or {}
	for k,v in pairs(args) do args[k] = tonumber(v) end
	ply.Buddies[buddy] = {physgun = util.tobool(args[2]), gravgun = util.tobool(args[3]), toolgun = util.tobool(args[4]), playeruse = util.tobool(args[5]), entitydamage = util.tobool(args[6])}
end
concommand.Add("FPP_SetBuddy", SetBuddy)

local function CleanupDisconnected(ply, cmd, args)
	if ply:EntIndex() == 0 or not ply:IsAdmin() then ply:PrintMessage(HUD_PRINTCONSOLE, "You can't clean up") return end
	if not args[1] then ply:PrintMessage(HUD_PRINTCONSOLE, "Invalid argument") return end
	if args[1] == "disconnected" then
		for k,v in pairs(ents.GetAll()) do
			if v.Owner and not ValidEntity(v.Owner) then
				v:Remove()
			end
		end
		FPP.NotifyAll(ply:Nick() .. " removed all disconnected players' props", true)
		return
	elseif not ValidEntity(Player(args[1])) then ply:PrintMessage(HUD_PRINTCONSOLE, "Invalid player") return 
	end
	
	for k,v in pairs(ents.GetAll()) do
		if v.Owner == Player(args[1]) and not v:IsWeapon() then
			v:Remove()
		end
	end
	FPP.NotifyAll(ply:Nick() .. " removed "..Player(args[1]):Nick().. "'s entities", true)
end
concommand.Add("FPP_Cleanup", CleanupDisconnected)
