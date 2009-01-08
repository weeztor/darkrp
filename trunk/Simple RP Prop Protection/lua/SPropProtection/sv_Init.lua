------------------------------------
--	Simple Prop Protection
--	By Spacetech
------------------------------------

SPropProtection["Props"] = {}
SPropProtection.AntiCopy = {"func_breakable_surf", "drug", "drug_lab", "food", "gunlab", "letter", "melon", "meteor", "microwave", "money_printer", "spawned_shipment", "spawned_weapon", "weapon", "stick", "door_ram", "lockpick", "med_kit", "keys", "gmod_tool"}
for k,v in pairs(weapons.GetList()) do
	table.insert(SPropProtection.AntiCopy, v.Classname)
end
//PrintTable(SPropProtection.AntiCopy)


function SPropProtection.SetupSettings()
	if(!sql.TableExists("spropprotection")) then
		sql.Query("CREATE TABLE IF NOT EXISTS spropprotection(toggle INTEGER NOT NULL, admin INTEGER NOT NULL, use INTEGER NOT NULL, edmg INTEGER NOT NULL, pgr INTEGER NOT NULL, awp INTEGER NOT NULL, dpd INTEGER NOT NULL, dae INTEGER NOT NULL, delay INTEGER NOT NULL);")
		sql.Query("CREATE TABLE IF NOT EXISTS spropprotectionbuddies(steamid TEXT NOT NULL PRIMARY KEY, bsteamid TEXT);")
		sql.Query("INSERT INTO spropprotection(toggle, admin, use, edmg, pgr, awp, dpd, dae, delay) VALUES(1, 1, 1, 1, 1, 1, 1, 0, 120)")
	end
	return sql.QueryRow("SELECT * FROM spropprotection LIMIT 1")
end

SPropProtection["Config"] = SPropProtection.SetupSettings()

function SPropProtection.NofityAll(Text)
	for k, ply in pairs(player.GetAll()) do
		ply:SendLua("GAMEMODE:AddNotify(\""..Text.."\", NOTIFY_GENERIC, 5); surface.PlaySound(\"ambient/water/drip"..math.random(1, 4)..".wav\")")
		ply:PrintMessage(HUD_PRINTCONSOLE, Text)
	end
	Msg(Text.."\n")
end

function SPropProtection.Nofity(ply, Text)
	ply:SendLua("GAMEMODE:AddNotify(\""..Text.."\", NOTIFY_GENERIC, 5); surface.PlaySound(\"ambient/water/drip"..math.random(1, 4)..".wav\")")
	ply:PrintMessage(HUD_PRINTCONSOLE, Text)
end

function SPropProtection.AdminReload(ply)
	if(ply) then
		for k, v in pairs(SPropProtection["Config"]) do
			ply:ConCommand("SPropProtection_"..k.." "..v.."\n")
		end
	else
		for k1, v1 in pairs(player.GetAll()) do
			for k2, v2 in pairs(SPropProtection["Config"]) do
				v1:ConCommand("SPropProtection_"..k2.." "..v2.."\n")
			end
		end
	end
end

function SPropProtection.LoadBuddies(ply)
	local PData = ply:GetPData("SPPBuddies", "")
	if(PData != "") then
		for k, v in pairs(string.Explode(";", PData)) do
			local String = string.Trim(v)
			if(String != "") then
				table.insert(SPropProtection[ply:SteamID()], String)
			end
		end
	end
end

function SPropProtection.PlayerMakePropOwner(ply, ent)
	if(ent:GetClass() == "transformer" and ent.spawned and !ent.Part) then
		for k, v in pairs(transpiece[ent]) do
			v.Part = true
			SPropProtection.PlayerMakePropOwner(ply, v)
		end
	end
	if(ent:IsPlayer()) then
		return false
	end
	SPropProtection["Props"][ent:EntIndex()] = {ply:SteamID(), ent, ply}
	ent:SetNetworkedString("Owner", ply:Nick())
	ent:SetNetworkedEntity("OwnerObj", ply)
	gamemode.Call("CPPIAssignOwnership", ply, ent)
	return true
end

if(cleanup) then
	local Clean = cleanup.Add
	function cleanup.Add(Player, Type, Entity)
		if(Entity) then
			local Check = Player:IsPlayer()
			local Valid = Entity:IsValid()
		    if(Check and Valid) then
		        SPropProtection.PlayerMakePropOwner(Player, Entity)
		    end
		end
	    Clean(Player, Type, Entity)
	end
end

local Meta = FindMetaTable("Player")
if(Meta.AddCount) then
	local Backup = Meta.AddCount
	function Meta:AddCount(Type, Entity)
		SPropProtection.PlayerMakePropOwner(self, Entity)
		Backup(self, Type, Entity)
	end
end

function SPropProtection.IsBuddy(ply, ent)
	local Players = player.GetAll()
	if(table.Count(Players) == 1) then
		return true
	end
	for k, v in pairs(Players) do
		if(v and v:IsValid() and v != ply) then
	        if(SPropProtection["Props"][ent:EntIndex()][1] == v:SteamID()) then 
                if(table.HasValue(SPropProtection[v:SteamID()], ply:SteamID())) then
					return true
				else
					return false
				end
            end
		end
	end	
end

function SPropProtection.PlayerCanTouch(ply, ent)
	if(tonumber(SPropProtection["Config"]["toggle"]) == 0 or ent:GetClass() == "worldspawn") then
		return true
	end
	
	if(string.find(ent:GetClass(), "stone_") == 1 or string.find(ent:GetClass(), "rock_") == 1 or string.find(ent:GetClass(), "stargate_") == 0 or string.find(ent:GetClass(), "dhd_") == 0 or ent:GetClass() == "flag" or ent:GetClass() == "item") then
		if(!ent:GetNetworkedString("Owner") or ent:GetNetworkedString("Owner") == "") then
			ent:SetNetworkedString("Owner", "World")
		end
		if(ply:GetActiveWeapon():GetClass() != "weapon_physgun" and ply:GetActiveWeapon():GetClass() != "gmod_tool") then
			return true
		end
	end
	
	if(!ent:GetNetworkedString("Owner") or ent:GetNetworkedString("Owner") == "" and !ent:IsPlayer()) then
		SPropProtection.PlayerMakePropOwner(ply, ent)
		SPropProtection.Nofity(ply, "You now own this prop")
		return true
	end
	
	if(ent:GetNetworkedString("Owner") == "World") then
		if(ply:IsAdmin() and tonumber(SPropProtection["Config"]["awp"]) == 1 and tonumber(SPropProtection["Config"]["admin"]) == 1) then
			return true
		end
	elseif(ply:IsAdmin() and tonumber(SPropProtection["Config"]["admin"]) == 1) then
		return true
	end

	if(SPropProtection["Props"][ent:EntIndex()] != nil) then
		if(SPropProtection["Props"][ent:EntIndex()][1] == ply:SteamID() or SPropProtection.IsBuddy(ply, ent)) then
			return true
		end
	else
		for k, v in pairs(g_SBoxObjects) do
			for b, j in pairs(v) do
				for _, e in pairs(j) do
					if(k == ply:SteamID() and e == ent) then
						SPropProtection.PlayerMakePropOwner(ply, ent)
						SPropProtection.Nofity(ply, "You now own this prop")
						return true
					end
				end
			end
		end
		
		for k, v in pairs(GAMEMODE.CameraList) do
			for b, j in pairs(v) do
				if(j == ent) then
					if(k == ply:SteamID() and e == ent) then
						SPropProtection.PlayerMakePropOwner(ply, ent)
						SPropProtection.Nofity(ply, "You now own this prop")
						return true
					end
				end
			end
		end
	end
	
	if(game.GetMap() == "gm_construct" and ent:GetNetworkedString("Owner") == "World") then
		return true
	end
	return false
end

function SPropProtection.DRemove(SteamID, PlayerName)
	for k, v in pairs(SPropProtection["Props"]) do
		if(v[1] == SteamID and v[2]:IsValid()) then
			v[2]:Remove()
			SPropProtection["Props"][k] = nil
		end
	end
	SPropProtection.NofityAll(tostring(PlayerName).."'s props have been cleaned up")
end

function SPropProtection.PlayerInitialSpawn(ply)
	ply:SetNWString("SPPSteamID", string.gsub(ply:SteamID(), ":", "_"))
	SPropProtection[ply:SteamID()] = {}
	SPropProtection.LoadBuddies(ply)
	SPropProtection.AdminReload(ply)
	local TimerName = "SPropProtection.DRemove: "..ply:SteamID()
	if(timer.IsTimer(TimerName)) then
		timer.Remove(TimerName)
	end
end
hook.Add("PlayerInitialSpawn", "SPropProtection.PlayerInitialSpawn", SPropProtection.PlayerInitialSpawn)

function SPropProtection.Disconnect(ply)
	if(tonumber(SPropProtection["Config"]["dpd"]) == 1) then
		if(ply:IsAdmin() and tonumber(SPropProtection["Config"]["dae"]) == 0) then return end
		timer.Create("SPropProtection.DRemove: "..ply:SteamID(), tonumber(SPropProtection["Config"]["delay"]), 1, SPropProtection.DRemove, ply:SteamID(), ply:Nick())
	end
end
hook.Add("PlayerDisconnected", "SPropProtection.Disconnect", SPropProtection.Disconnect)
//a
function SPropProtection.PhysGravGunPickup(ply, ent)
	if not ValidEntity(ent) then return end
	local class = ent:GetClass()
	if ent:IsPlayer() or (class == "func_door" or class == "func_door_rotating" or class == "prop_door_rotating" or class == "func_breakable_surf") then return false end
	for k,v in pairs(SPropProtection.AntiCopy) do
		if ent:GetClass() == v and not ply:IsAdmin() then return false end
	end
	
	for k,v in pairs(constraint.GetAllConstrainedEntities(ent)) do
		if v ~= ent then
			if v:IsWeapon() or string.find(v:GetClass(), "weapon") then
				SPropProtection.Nofity(ply, "Weapons are attached to your prop")
				return false
			end
			local class = v:GetClass()
			if (class == "func_door" or class == "func_door_rotating" or class == "prop_door_rotating") then
				return false
			end
			for a,b in pairs(SPropProtection.AntiCopy) do
				if string.find(v:GetClass(), b) then
					//SPropProtection.Nofity(ply, "Cannot touch because it has wrong entities attached to it")
					return false
				end
			end
			if not SPropProtection.PlayerCanTouch(ply, v) then
				//SPropProtection.Nofity(ply, "One of the entities attached to that entity isn't yours")
				return false
			end
		end
	end

	if(ply:IsAdmin() and tonumber(SPropProtection["Config"]["admin"]) == 1) then return true end
	if(ent:GetNetworkedString("Owner") == "Shared" or ent:GetNetworkedString("Owner") == ply:Nick()) then return true end
	if(!ent:IsValid() or !SPropProtection.PlayerCanTouch(ply, ent)) then
		return false
	end
	return true
end
hook.Add("PhysgunPickup", "SPropProtection.PhysgunPickup", SPropProtection.PhysGravGunPickup)

function SPropProtection.GravGunThings(ply, ent)
	if ply:KeyDown(IN_ATTACK) then
		local entphys = ent:GetPhysicsObject()
		-- it was launched
		entphys:EnableMotion(false)
		local curpos = ent:GetPos()
		timer.Simple(.01, entphys.EnableMotion, entphys, true)
		timer.Simple(.01, entphys.Wake, entphys)
		timer.Simple(.01, ent.SetPos, ent, curpos)
	end
	if not ValidEntity(ent) then return true end
	for k,v in pairs(SPropProtection.AntiCopy) do
		if ent:GetClass() == v then return true end
	end
	if(ply:IsAdmin() and tonumber(SPropProtection["Config"]["admin"]) == 1) then return true end
	
	if(ent:GetNetworkedString("Owner") == "Shared" or ent:GetNetworkedString("Owner") == ply:Nick()) then return true end
	if(!ent:IsValid() or !SPropProtection.PlayerCanTouch(ply, ent)) then
		return false
	end
	return true
end
hook.Add("GravGunPunt", "SPropProtection.GravGunPunt", SPropProtection.GravGunThings)
hook.Add("GravGunPickupAllowed", "SPropProtection.GravGunPickupAllowed", SPropProtection.GravGunThings)
//v:UniqueIDTable( "Duplicator" ).Entities
function SPropProtection.CanTool(ply, tr, toolgun)
	local ent = tr.Entity
	for k,v in pairs(SPropProtection.AntiCopy) do
		if ValidEntity(ent) and ent:GetClass() == v then return false end
	end
	if string.find(toolgun, "duplicator") then
		//NORMAL DUPLICATOR
		local Ents = ply:UniqueIDTable( "Duplicator" ).Entities
		if Ents then
			for k,v in pairs(Ents) do
				if (ValidEntity(v.Entity) and (v.Entity:IsWeapon() or string.find(v.Entity:GetClass(), "weapon"))) or (v.Classname and string.find(v.Classname, "weapon")) or ValidEntity(v.Weapon) then
					SPropProtection.Nofity(ply, "YOU ARE NOT ALLOWED TO DUPLICATE WEAPONS!!!!!!!!")
					ply:UniqueIDTable( "Duplicator" ).Entities = nil
					return false
				end
				for a,b in pairs(SPropProtection.AntiCopy) do 
					if ValidEntity(v.Entity) and string.find(v.Entity:GetClass(), b) then
						SPropProtection.Nofity(ply, "YOU ARE NOT ALLOWED TO DUPLICATE THIS ENTITY!!!!!")
						ply:UniqueIDTable( "Duplicator" ).Entities = nil
						return false
					end
				end
			end
		end
		
		//ADVANCED DUPLICATOR:
		print(toolgun, ply:GetActiveWeapon():GetToolObject().Entities)
		if toolgun == "adv_duplicator" and ply:GetActiveWeapon():GetToolObject().Entities then
			for k,v in pairs(ply:GetActiveWeapon():GetToolObject().Entities) do
				for a, b in pairs(v) do
					for c,d in pairs(SPropProtection.AntiCopy) do 
						if v.Class and string.find(string.lower(v.Class), string.lower(d)) then
							SPropProtection.Nofity(ply,"YOU ARE NOT ALLOWED TO DUPLICATE THIS!!!!!!!!")
							ply:GetActiveWeapon():GetToolObject():ClearClipBoard()
							return false
						end
					end
				end
			end
		end
	end
	
	if(ValidEntity(ent) and (ent:IsPlayer() or ent:IsWeapon())) then return false end
	if ValidEntity(ent) and (ent:IsWeapon() or string.find(ent:GetClass(), "weapon")) then return false end
		
	if(!SPropProtection.PlayerCanTouch(ply, ent)) then
		return false
	elseif string.find(toolgun, "nail") then
		local Trace = {}
		Trace.start = tr.HitPos
		Trace.endpos = tr.HitPos + (ply:GetAimVector() * 16.0)
		Trace.filter = {ply, tr.Entity}
		local tr2 = util.TraceLine(Trace)
		if(tr2.Hit and !tr2.Entity:IsPlayer()) then
			if(!SPropProtection.PlayerCanTouch(ply, tr2.Entity)) then
				return false
			end
		end

	--[[ elseif string.find(toolgun, "slider") or string.find(toolgun, "hydraulic") or string.find(toolgun, "muscle") or string.find(toolgun, "winch") then
		local trace = {} 
		trace.start = tr.HitPos 
		//print(tr.HitNormal, tr.start)
		trace.endpos = trace.start + (tr.HitNormal * 16384) 
		trace.filter = {}  
		trace.filter[1] = tr.Entity
		local tr3 = util.TraceLine( trace )
		if (tr3.Entity:IsValid()) then 
			if(!SPropProtection.PlayerCanTouch(ply, tr3.Entity)) then
				SPropProtection.Nofity(ply, "Error, please change the angle of the prop and try again")
				return false
			end
			for k,v in pairs(SPropProtection.AntiCopy) do
				if tr3.Entity:GetClass() == v then
					SPropProtection.Nofity(ply, "Error, please change the angle of the prop and try again")
					return false
				end
			end
		end  ]]
	end
	if ValidEntity(ent) then
		for k,v in pairs(constraint.GetAllConstrainedEntities(ent)) do
			if v:IsWeapon() or string.find(v:GetClass(), "weapon") then
				SPropProtection.Nofity(ply, "Weapons are attached to your prop")
				return false
			end
			local class = v:GetClass()
			if (class == "func_door" or class == "func_door_rotating" or class == "prop_door_rotating") then
				return false
			end
			for a,b in pairs(SPropProtection.AntiCopy) do
				if string.find(v:GetClass(), b) then
					SPropProtection.Nofity(ply, "Cannot touch because it has wrong entities attached to it")
					return false
				end
			end
			if not SPropProtection.PlayerCanTouch(ply, v) then
				SPropProtection.Nofity(ply, "One of the entities attached to that entity isn't yours")
				return false
			end
		end
	end
end
hook.Add("CanTool", "SPropProtection.CanTool", SPropProtection.CanTool)

function SPropProtection.EntityTakeDamage(ent, inflictor, attacker, amount)
	if(tonumber(SPropProtection["Config"]["edmg"]) == 0) then return end
	if(!ent:IsValid()) then return end
    if(ent:IsPlayer() or !attacker:IsPlayer()) then return end
	if(!SPropProtection.PlayerCanTouch(attacker, ent)) then
		local Total = ent:Health() + amount
		if(ent:GetMaxHealth() > Total) then 
			ent:SetMaxHealth(Total)
		else
			ent:SetHealth(Total)
		end
	end
end
hook.Add("EntityTakeDamage", "SPropProtection.EntityTakeDamage", SPropProtection.EntityTakeDamage)

function SPropProtection.PlayerUse(ply, ent)
	if not ValidEntity(ent) then return true end
	local class = ent:GetClass()
	if (class == "func_door" or class == "func_door_rotating" or class == "prop_door_rotating") then
		return true
	end
	for k,v in pairs(SPropProtection.AntiCopy) do 
		if ent:GetClass() == v then	
			return true
		end
	end
	if(ent:IsValid() and tonumber(SPropProtection["Config"]["use"]) == 1) then
		if(!SPropProtection.PlayerCanTouch(ply, ent) and
                        ent:GetNetworkedString("Owner") != ply:Nick() and
                        ent:GetNetworkedString("Owner") != "World" and
                        ent:GetNetworkedString("Owner") != "Shared") then
			return false
		end
	end
end
hook.Add("PlayerUse", "SPropProtection.PlayerUse", SPropProtection.PlayerUse)

function SPropProtection.OnPhysgunReload(weapon, ply)
	if(tonumber(SPropProtection["Config"]["pgr"]) == 0) then return end
	local tr = util.TraceLine(util.GetPlayerTrace(ply))
	if(!tr.HitNonWorld or !tr.Entity:IsValid() or tr.Entity:IsPlayer()) then return end
	
	for k,v in pairs(constraint.GetAllConstrainedEntities(tr.Entity)) do
		if v ~= ent then
			if v:IsWeapon() or string.find(v:GetClass(), "weapon") then
				SPropProtection.Nofity(ply, "Weapons are attached to your prop")
				return false
			end
			local class = v:GetClass()
			if (class == "func_door" or class == "func_door_rotating" or class == "prop_door_rotating") then
				return false
			end
			for a,b in pairs(SPropProtection.AntiCopy) do
				if string.find(v:GetClass(), b) then
					SPropProtection.Nofity(ply, "Cannot touch because it has wrong entities attached to it")
					return false
				end
			end
			if not SPropProtection.PlayerCanTouch(ply, v) then
				SPropProtection.Nofity(ply, "One of the entities attached to that entity isn't yours")
				return false
			end
		end
	end
	if(!SPropProtection.PlayerCanTouch(ply, tr.Entity)) then
		return false
	end
end
hook.Add("OnPhysgunReload", "SPropProtection.OnPhysgunReload", SPropProtection.OnPhysgunReload)

function SPropProtection.EntityRemoved(ent)
	SPropProtection["Props"][ent:EntIndex()] = nil
end
hook.Add("EntityRemoved", "SPropProtection.EntityRemoved", SPropProtection.EntityRemoved)

function SPropProtection.PlayerSpawnedSENT(ply, ent)
	SPropProtection.PlayerMakePropOwner(ply, ent)
end
hook.Add("PlayerSpawnedSENT", "SPropProtection.PlayerSpawnedSENT", SPropProtection.PlayerSpawnedSENT)

function SPropProtection.PlayerSpawnedVehicle(ply, ent)
	SPropProtection.PlayerMakePropOwner(ply, ent)
end
hook.Add("PlayerSpawnedVehicle", "SPropProtection.PlayerSpawnedVehicle", SPropProtection.PlayerSpawnedVehicle)

function SPropProtection.CleanupDisconnectedProps(ply, cmd, args)
	if(!ply:IsAdmin()) then return end
	for k1, v1 in pairs(SPropProtection["Props"]) do
		local FoundUID = false
		for k2, v2 in pairs(player.GetAll()) do
			if(v1[1] == v2:SteamID()) then
				FoundUID = true
			end
		end
		if(FoundUID == false and v1[2]:IsValid()) then
			v1[2]:Remove()
			SPropProtection["Props"][k1] = nil
		end
	end
	SPropProtection.NofityAll("Disconnected players props have been cleaned up")
end
concommand.Add("SPropProtection_CleanupDisconnectedProps", SPropProtection.CleanupDisconnectedProps)

function SPropProtection.CleanupProps(ply, cmd, args)
	if(!args[1] or args[1] == "") then
		for k, v in pairs(SPropProtection["Props"]) do
			if(v[1] == ply:SteamID()) then
				if(v[2]:IsValid()) then
					v[2]:Remove()
					SPropProtection["Props"][k] = nil
				end
			end
		end	
		SPropProtection.Nofity(ply, "Your props have been cleaned up")
	elseif(ply:IsAdmin()) then
		for k1, v1 in pairs(player.GetAll()) do
			local NWSteamID = v1:GetNWString("SPPSteamID")
			if(args[1] == NWSteamID or args[2] == NWSteamID or string.find(string.Implode(" ", args), NWSteamID) != nil) then
				for k2, v2 in pairs(SPropProtection["Props"]) do
					if(v2[1] == v1:SteamID()) then
						if(v2[2]:IsValid()) then
							v2[2]:Remove()
							SPropProtection["Props"][k2] = nil
						end
					end
				end
				SPropProtection.NofityAll(v1:Nick().."'s props have been cleaned up")
			end
		end
	end
end
concommand.Add("SPropProtection_CleanupProps", SPropProtection.CleanupProps)

function SPropProtection.ApplyBuddySettings(ply, cmd, args)
	local Players = player.GetAll()
	if(table.Count(Players) > 1) then
		local ChangedFriends = false
		for k, v in pairs(Players) do
			local PlayersSteamID = v:SteamID()
			local PData = ply:GetPData("SPPBuddies", "")
			if(tonumber(ply:GetInfo("SPropProtection_BuddyUp_"..v:GetNWString("SPPSteamID"))) == 1) then
				if(!table.HasValue(SPropProtection[ply:SteamID()], PlayersSteamID)) then
					ChangedFriends = true
					table.insert(SPropProtection[ply:SteamID()], PlayersSteamID)
					if(PData == "") then
						ply:SetPData("SPPBuddies", PlayersSteamID..";")
					else
						ply:SetPData("SPPBuddies", PData..PlayersSteamID..";")
					end
				end
			else
				if(table.HasValue(SPropProtection[ply:SteamID()], PlayersSteamID)) then
					for k2, v2 in pairs(SPropProtection[ply:SteamID()]) do
						if(v2 == PlayersSteamID) then
							ChangedFriends = true
							table.remove(SPropProtection[ply:SteamID()], k2)
							ply:SetPData("SPPBuddies", string.gsub(PData, PlayersSteamID..";", ""))
						end
					end
				end
			end
		end
		
		if(ChangedFriends) then
			local Table = {}
			for k, v in pairs(SPropProtection[ply:SteamID()]) do
				for k2, v2 in pairs(player.GetAll()) do
					if(v == v2:SteamID()) then
						table.insert(Table, v2)
					end
				end
			end
			gamemode.Call("CPPIFriendsChanged", ply, Table)
		end
	end
	
	SPropProtection.Nofity(ply, "Your buddies have been updated")
end
concommand.Add("SPropProtection_ApplyBuddySettings", SPropProtection.ApplyBuddySettings)

function SPropProtection.ClearBuddies(ply, cmd, args)
	local PData = ply:GetPData("SPPBuddies", "")
	if(PData != "") then
		for k, v in pairs(string.Explode(";", PData)) do
			local String = string.Trim(v)
			if(String != "") then
				ply:ConCommand("SPropProtection_BuddyUp_"..string.gsub(String, ":", "_").." 0\n")
			end
		end
		ply:SetPData("SPPBuddies", "")
	end
	
	for k, v in pairs(SPropProtection[ply:SteamID()]) do
		ply:ConCommand("SPropProtection_BuddyUp_"..string.gsub(v, ":", "_").." 0\n")
	end
	SPropProtection[ply:SteamID()] = {}
	
	SPropProtection.Nofity(ply, "Your buddies have been cleared")
end
concommand.Add("SPropProtection_ClearBuddies", SPropProtection.ClearBuddies)

function SPropProtection.ApplySettings(ply, cmd, args)
	if(!ply:IsAdmin()) then
		return
	end
	
	local toggle = tonumber(ply:GetInfo("SPropProtection_toggle") or 1)
	local admin = tonumber(ply:GetInfo("SPropProtection_admin") or 1)
	local use = tonumber(ply:GetInfo("SPropProtection_use") or 1)
	local edmg = tonumber(ply:GetInfo("SPropProtection_edmg") or 1)
	local pgr = tonumber(ply:GetInfo("SPropProtection_pgr") or 1)
	local awp = tonumber(ply:GetInfo("SPropProtection_awp") or 1)
	local dpd = tonumber(ply:GetInfo("SPropProtection_dpd") or 1)
	local dae = tonumber(ply:GetInfo("SPropProtection_dae") or 1)
	local delay = math.Clamp(tonumber(ply:GetInfo("SPropProtection_delay") or 120), 1, 500)
	
	sql.Query("UPDATE spropprotection SET toggle = "..toggle..", admin = "..admin..", use = "..use..", edmg = "..edmg..", pgr = "..pgr..", awp = "..awp..", dpd = "..dpd..", dae = "..dae..", delay = "..delay)
	
	SPropProtection["Config"] = sql.QueryRow("SELECT * FROM spropprotection LIMIT 1")
	
	timer.Simple(2, SPropProtection.AdminReload)
	
	SPropProtection.Nofity(ply, "Admin settings have been updated")
end
concommand.Add("SPropProtection_ApplyAdminSettings", SPropProtection.ApplySettings)

function SPropProtection.WorldOwner()
	local WorldEnts = 0
	for k, v in pairs(ents.FindByClass("*")) do
		if(!v:IsPlayer() and !v:GetNetworkedString("Owner", false)) then
			v:SetNetworkedString("Owner", "World")
			WorldEnts = WorldEnts + 1
		end
	end
	Msg("=================================================\n")
	Msg("Simple Prop Protection: "..tostring(WorldEnts).." props belong to world\n")
	Msg("=================================================\n")
end
timer.Simple(10, SPropProtection.WorldOwner)
