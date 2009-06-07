------------------------------------
--	Simple Prop Protection
--	By Spacetech edited by FPtje
------------------------------------

/*---------------------------------------------------------
Variables
---------------------------------------------------------*/
SPropProtection = {} -- Make a table for like every function and subvariable.
SPropProtection.Version = "DarkRP"
SPropProtection["Props"] = {} -- a table with the props that players own.
-- Table with RP objects that can't be copied:
SPropProtection.AntiCopy = {"func_breakable_surf", "drug", "drug_lab", "food", "gunlab", "letter", "meteor", "microwave", "money_printer", "spawned_shipment", "spawned_weapon", "weapon", "stick", "door_ram", "lockpick", "med_kit", "keys", "gmod_tool", "spawned_food"}
SPropProtection.WorldProps = {}
local Meta = FindMetaTable("Player")

-- Put all existing weapons in after 5 seconds
timer.Simple(5, function()
	for k,v in pairs(weapons.GetList()) do
		table.insert(SPropProtection.AntiCopy, v.Classname)
	end
end)

if cleanup then
	local Clean = cleanup.Add
	function cleanup.Add(Player, Type, Entity)
		if Entity then
			local Check = Player:IsPlayer()
			local Valid = Entity:IsValid()
		    if Check and Valid then
		        SPropProtection.PlayerMakePropOwner(Player, Entity)
		    end
		end
	    Clean(Player, Type, Entity)
	end
end

if Meta.AddCount then
	local Backup = Meta.AddCount
	function Meta:AddCount(Type, Entity)
		SPropProtection.PlayerMakePropOwner(self, Entity)
		Backup(self, Type, Entity)
	end
end

/*---------------------------------------------------------
Cleaning up
---------------------------------------------------------*/
function SPropProtection.DRemove(SteamID, PlayerName)
	for k, v in pairs(SPropProtection["Props"]) do
		if v[1] == SteamID and v[2]:IsValid() then
			v[2]:Remove()
			SPropProtection["Props"][k] = nil
		end
	end
	NotifyAll(1, 5, tostring(PlayerName).."'s props have been cleaned up")
end

function SPropProtection.CleanupDisconnectedProps(ply, cmd, args)
	if not ply:IsAdmin() then return end
	for k1, v1 in pairs(SPropProtection["Props"]) do
		local FoundUID = false
		for k2, v2 in pairs(player.GetAll()) do
			if v1[1] == v2:SteamID() then
				FoundUID = true
			end
		end
		if FoundUID == false and v1[2]:IsValid() then
			v1[2]:Remove()
			SPropProtection["Props"][k1] = nil
		end
	end
	NotifyAll(1, 4, "Disconnected players props have been cleaned up")
end
concommand.Add("SPropProtection_CleanupDisconnectedProps", SPropProtection.CleanupDisconnectedProps)

function SPropProtection.CleanupProps(ply, cmd, args)
	if not args[1] or args[1] == "" then
		for k, v in pairs(SPropProtection["Props"]) do
			if v[1] == ply:SteamID() then
				if v[2]:IsValid() then
					v[2]:Remove()
					SPropProtection["Props"][k] = nil
				end
			end
		end	
		Notify(ply, 1, 4, "Your props have been cleaned up")
	elseif ply:IsAdmin() then
		local find = FindPlayer(args[1])
		if not ValidEntity(find) then
			Notify(ply, 1, 4, "Could not find player "..args[1])
			return
		end
		
		for k,v in pairs(SPropProtection["Props"]) do
			if v[1] == find:SteamID() then
				if v[2]:IsValid() then v[2]:Remove() end
				SPropProtection["Props"][k] = nil
			end
		end
		NotifyAll(1, 4, find:Nick().."'s props have been cleaned up")
	end
end
concommand.Add("SPropProtection_CleanupProps", SPropProtection.CleanupProps)

/*---------------------------------------------------------
Hooks
---------------------------------------------------------*/
function SPropProtection.PlayerInitialSpawn(ply)
	SPropProtection[ply:SteamID()] = {}
	SPropProtection.LoadBuddies(ply)
	local TimerName = "SPropProtection.DRemove: "..ply:SteamID()
	if timer.IsTimer(TimerName) then
		timer.Remove(TimerName)
	end
end
hook.Add("PlayerInitialSpawn", "SPropProtection.PlayerInitialSpawn", SPropProtection.PlayerInitialSpawn)

function SPropProtection.Disconnect(ply)
	if tonumber(CfgVars["spp_propdeletion"]) == 1 then
		if ply:IsAdmin() and tonumber(CfgVars["spp_deleteadminents"]) == 0 then return end
		timer.Create("SPropProtection.DRemove: "..ply:SteamID(), tonumber(CfgVars["spp_deletedelay"]), 1, SPropProtection.DRemove, ply:SteamID(), ply:Nick())
	end
end
hook.Add("PlayerDisconnected", "SPropProtection.Disconnect", SPropProtection.Disconnect)

function SPropProtection.PhysGravGunPickup(ply, ent)
	if not ValidEntity(ent) then return SPropProtection.CanNotTouch(ply) end
	local class = ent:GetClass()
	if ent:IsPlayer() then return false end
	if class == "func_door" or class == "func_door_rotating" or class == "prop_door_rotating" or class == "func_breakable_surf" then return SPropProtection.CanNotTouch(ply) end
	if ent:IsVehicle() and not ply:IsAdmin() then return SPropProtection.CanNotTouch(ply) end
	
	if SPropProtection.AntiCopy then
		for k,v in pairs(SPropProtection.AntiCopy) do
			if ent:GetClass() == v and not ply:IsAdmin() then return SPropProtection.CanNotTouch(ply) end
		end
	end
	
	if not SPropProtection.PlayerCanTouch(ply, ent) then
		return SPropProtection.CanNotTouch(ply)
	end
	
	if constraint.GetAllConstrainedEntities(ent) then
		for k,v in pairs(constraint.GetAllConstrainedEntities(ent)) do
			if v ~= ent then
				if v:IsWeapon() or string.find(v:GetClass(), "weapon") then
					return SPropProtection.CanNotTouch(ply)
				end
				local Class = v:GetClass()
				if Class == "func_door" or Class == "func_door_rotating" or Class == "prop_door_rotating" then
					return SPropProtection.CanNotTouch(ply)
				end
				for a,b in pairs(SPropProtection.AntiCopy) do
					if string.find(v:GetClass(), b) and not string.find(v:GetClass(), "cameraprop") then
						return SPropProtection.CanNotTouch(ply)
					end
				end
				if not SPropProtection.PlayerCanTouch(ply, v) then
					return SPropProtection.CanNotTouch(ply)
				end
			end
		end
	end
	return true
end
hook.Add("PhysgunPickup", "SPropProtection.PhysgunPickup", SPropProtection.PhysGravGunPickup)

function SPropProtection.PhysgGunDrop(ply, ent)
	if CfgVars["DropEntitiesAfterPhysGunDrop"] == 1 then
		local phys = ent:GetPhysicsObject()
		if not phys:IsValid() then return end
		phys:SetVelocity(Vector(0,0,0))
	end
end
hook.Add("PhysgunDrop", "SPropProtection.PhysgGunDrop", SPropProtection.PhysgGunDrop)

function SPropProtection.GravGunThings(ply, ent)
	if not ValidEntity(ent) then return false end
	if ent:IsVehicle() then return SPropProtection.CanNotTouch(ply) end
	if string.find(ent:GetClass(), "func_") then return false end
	for k,v in pairs(SPropProtection.AntiCopy) do
		if ent:GetClass() == v then return true end
	end
	if not SPropProtection.PlayerCanTouch(ply, ent) then
		return SPropProtection.CanNotTouch(ply)
	end
	return true
end
hook.Add("GravGunPickupAllowed", "SPropProtection.GravGunPickupAllowed", SPropProtection.GravGunThings)

function SPropProtection.GravGunPunt(ply, ent)
	if not ValidEntity(ent) then return SPropProtection.CanNotTouch(ply) end
	if ent:IsVehicle() then return SPropProtection.CanNotTouch(ply) end
	if string.find(ent:GetClass(), "func_") then return SPropProtection.CanNotTouch(ply) end
	DropEntityIfHeld(ent)
	return false
end
hook.Add("GravGunPunt", "SPropProtection.GravGunPunt", SPropProtection.GravGunPunt)

function SPropProtection.CanTool(ply, tr, toolgun)
	if string.find(toolgun, "duplicator") then
		--NORMAL DUPLICATOR
		local Ents = ply:UniqueIDTable( "Duplicator" ).Entities
		if Ents then
			for k,v in pairs(Ents) do
				if not string.find(v.Entity:GetClass(), "gmod_cameraprop") and (ValidEntity(v.Entity) and (v.Entity:IsWeapon() or string.find(v.Entity:GetClass(), "weapon"))) or (v.Classname and string.find(v.Classname, "weapon")) or ValidEntity(v.Weapon) then
					print(ply:Nick(), "tried to spawn a ", v.Entity:GetClass(), ", He failed")
					for NUMBER, PLAYER in pairs(player.GetAll()) do
						if PLAYER:IsAdmin() then
							PLAYER:ChatPrint(ply:Nick().. " tried to spawn a " .. v.Entity:GetClass() .. " with adv.duplicator, He failed")
						end
					end
					Notify(ply, 1, 4, "You are not allowed to duplicate weapons!")
					ply:UniqueIDTable( "Duplicator" ).Entities = nil
					return SPropProtection.CanNotTouch(ply)
				end
				for a,b in pairs(SPropProtection.AntiCopy) do 
					if ValidEntity(v.Entity) and string.find(v.Entity:GetClass(), b) then
						print(ply:Nick(), "tried to spawn a ", v.Entity:GetClass(), ", He failed")
						for NUMBER, PLAYER in pairs(player.GetAll()) do
							if PLAYER:IsAdmin() then
								PLAYER:ChatPrint(ply:Nick().. " tried to spawn a " .. v.Entity:GetClass() .. " with adv.duplicator, He failed")
							end
						end
						Notify(ply, 1, 4, "You are not allowed to duplicate this entity!")
						ply:UniqueIDTable( "Duplicator" ).Entities = nil
						return SPropProtection.CanNotTouch(ply)
					end
				end
			end
		end
		
		--ADVANCED DUPLICATOR:
		if toolgun == "adv_duplicator" and ply:GetActiveWeapon():GetToolObject().Entities then
			for k,v in pairs(ply:GetActiveWeapon():GetToolObject().Entities) do
				for a, b in pairs(v) do
					for c,d in pairs(SPropProtection.AntiCopy) do 
						if v.Class and not string.find(v.Class, "gmod_cameraprop") and string.find(string.lower(v.Class), string.lower(d)) then
							print(ply:Nick(), "tried to spawn a ", v.Class, " with adv.duplicator, He failed")
							for NUMBER, PLAYER in pairs(player.GetAll()) do
								if PLAYER:IsAdmin() then
									PLAYER:ChatPrint(ply:Nick().. " tried to spawn a " .. v.Class .. " with adv.duplicator, He failed")
								end
							end
							Notify(ply, 1, 4, "You are not allowed to duplicate this!")
							ply:GetActiveWeapon():GetToolObject():ClearClipBoard()
							return SPropProtection.CanNotTouch(ply)
						end
					end
				end
			end
		end
	end
	
	local ent = tr.Entity
	if not ValidEntity(ent) then return true end
	if ent:GetClass() == "func_breakable_surf" and ply:IsAdmin() then return true end
	for k,v in pairs(SPropProtection.AntiCopy) do
		if ent:GetClass() == v then return SPropProtection.CanNotTouch(ply) end
	end
	if ent:IsWeapon() then return SPropProtection.CanNotTouch(ply) end
	if ent:IsWeapon() or string.find(ent:GetClass(), "weapon") then return SPropProtection.CanNotTouch(ply) end
	if ent:IsDoor() then return SPropProtection.CanNotTouch(ply) end
		
	if not SPropProtection.PlayerCanTouch(ply, ent) then
		return SPropProtection.CanNotTouch(ply)
	elseif string.find(toolgun, "nail") then
		local Trace = {}
		Trace.start = tr.HitPos
		Trace.endpos = tr.HitPos + (ply:GetAimVector() * 16.0)
		Trace.filter = {ply, tr.Entity}
		local tr2 = util.TraceLine(Trace)
		if tr2.Hit and not tr2.Entity:IsPlayer() then
			if not SPropProtection.PlayerCanTouch(ply, tr2.Entity) then
				return SPropProtection.CanNotTouch(ply)
			end
		end
	end
	
	for k,v in pairs(constraint.GetAllConstrainedEntities(ent)) do
		if v ~= ent then
			if v:IsWeapon() or string.find(v:GetClass(), "weapon") then
				Notify(ply, 1, 6, "You can not use the tool on taht as weapons are attached to your prop")
				return SPropProtection.CanNotTouch(ply)
			end
			local class = v:GetClass()
			if class == "func_door" or class == "func_door_rotating" or class == "prop_door_rotating" then
				return SPropProtection.CanNotTouch(ply)
			end
			for a,b in pairs(SPropProtection.AntiCopy) do
				if string.find(v:GetClass(), b) and not string.find(v:GetClass(), "cameraprop") then
					Notify(ply, 1, 4, "You can not touch because it has wrong entities attached to it")
					return SPropProtection.CanNotTouch(ply)
				end
			end
			if not SPropProtection.PlayerCanTouch(ply, v) then
				Notify(ply, 1, 4, "One of the entities attached to that entity isn't yours")
				return SPropProtection.CanNotTouch(ply)
			end
		end
	end
end
hook.Add("CanTool", "SPropProtection.CanTool", SPropProtection.CanTool)

function SPropProtection.EntityTakeDamage(ent, inflictor, attacker, amount, dmginfo)
	if tonumber(CfgVars["spp_entdamage"]) == 0 then return end
	if not ValidEntity(ent) then return SPropProtection.CanNotTouch(attacker) end
    if ent:IsPlayer() or not attacker:IsPlayer() then return end
	if not SPropProtection.PlayerCanTouch(attacker, ent) then
		dmginfo:SetDamage(0)
		return SPropProtection.CanNotTouch(attacker)
	end
end
hook.Add("EntityTakeDamage", "SPropProtection.EntityTakeDamage", SPropProtection.EntityTakeDamage)

function SPropProtection.PlayerUse(ply, ent)
	if not ValidEntity(ent) then return true end
	local class = ent:GetClass()
	if class == "func_door" or class == "func_door_rotating" or class == "prop_door_rotating" or ent:IsVehicle() then
		return true
	end
	for k,v in pairs(SPropProtection.AntiCopy) do 
		if class == v then	
			return true
		end
	end
	if ent:IsValid() and tonumber(CfgVars["spp_use"]) == 1 and not SPropProtection.PlayerCanTouch(ply, ent) and table.HasValue(SPropProtection.WorldProps, ent) then
		return SPropProtection.CanNotTouch(ply)
	end
end
hook.Add("PlayerUse", "SPropProtection.PlayerUse", SPropProtection.PlayerUse)

function SPropProtection.OnPhysgunReload(weapon, ply)
	if tonumber(CfgVars["spp_physreload"]) == 0 then return end
	local tr = util.TraceLine(util.GetPlayerTrace(ply))
	if not tr.HitNonWorld or not tr.Entity:IsValid() or tr.Entity:IsPlayer() then return end
	
	if not SPropProtection.PlayerCanTouch(ply, tr.Entity) then
		return SPropProtection.CanNotTouch(ply)
	end

	for k,v in pairs(constraint.GetAllConstrainedEntities(tr.Entity)) do
		if v ~= tr.Entity then
			if v:IsWeapon() or string.find(v:GetClass(), "weapon") then
				Notify(ply, 1, 4, "You can not touch this since weapons are attached to your prop")
				return SPropProtection.CanNotTouch(ply)
			end
			local class = v:GetClass()
			if class == "func_door" or class == "func_door_rotating" or class == "prop_door_rotating" then
				return SPropProtection.CanNotTouch(ply)
			end
			for a,b in pairs(SPropProtection.AntiCopy) do
				if string.find(v:GetClass(), b) and not string.find(v:GetClass(), "cameraprop") then
					Notify(ply, 1, 4, "You can not touch this since it has wrong entities attached to it")
					return SPropProtection.CanNotTouch(ply)
				end
			end
			if not SPropProtection.PlayerCanTouch(ply, v) then
				Notify(ply, 1, 4, "You can not touch this since some of the entities attached to this aren't yours")
				return SPropProtection.CanNotTouch(ply)
			end
		end
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

/*---------------------------------------------------------
Buddies
---------------------------------------------------------*/
function SPropProtection.LoadBuddies(ply)
	local PData = ply:GetPData("SPPBuddies", "")
	if PData ~= "" then
		for k, v in pairs(string.Explode(";", PData)) do
			local String = string.Trim(v)
			if String ~= "" then
				table.insert(SPropProtection[ply:SteamID()], String)
			end
		end
	end
end

function SPropProtection.IsBuddy(ply, ent)
	local Players = player.GetAll()
	if table.Count(Players) == 1 then
		return true
	end
	for k, v in pairs(Players) do
		if v and ValidEntity(v) and v ~= ply then
	        if SPropProtection["Props"][ent:EntIndex()][1] == v:SteamID() then 
                if SPropProtection[v:SteamID()] and table.HasValue(SPropProtection[v:SteamID()], ply:SteamID()) then
					return true
				else
					return false
				end
            end
		end
	end	
end

function SPropProtection.ApplyBuddySettings(ply, cmd, args)
	local Players = player.GetAll()
	if #Players > 1 then
		local ChangedFriends = false
		for k, v in pairs(Players) do
			local PlayersSteamID = v:SteamID()
			local PData = ply:GetPData("SPPBuddies", "")
			if tonumber(ply:GetInfo("SPropProtection_BuddyUp_"..v:UserID())) == 1 then
				if not table.HasValue(SPropProtection[ply:SteamID()], PlayersSteamID) then
					ChangedFriends = true
					table.insert(SPropProtection[ply:SteamID()], PlayersSteamID)
					if PData == "" then
						ply:SetPData("SPPBuddies", PlayersSteamID..";")
					else
						ply:SetPData("SPPBuddies", PData..PlayersSteamID..";")
					end
				end
			else
				if table.HasValue(SPropProtection[ply:SteamID()], PlayersSteamID) then
					for k2, v2 in pairs(SPropProtection[ply:SteamID()]) do
						if v2 == PlayersSteamID then
							ChangedFriends = true
							table.remove(SPropProtection[ply:SteamID()], k2)
							ply:SetPData("SPPBuddies", string.gsub(PData, PlayersSteamID..";", ""))
						end
					end
				end
			end
		end
		
		if ChangedFriends then
			local Table = {}
			for k, v in pairs(SPropProtection[ply:SteamID()]) do
				for k2, v2 in pairs(player.GetAll()) do
					if v == v2:SteamID() then
						table.insert(Table, v2)
					end
				end
			end
			gamemode.Call("CPPIFriendsChanged", ply, Table)
		end
	end
	Notify(ply, 1, 4, "Your buddies have been updated")
end
concommand.Add("SPropProtection_ApplyBuddySettings", SPropProtection.ApplyBuddySettings)

function SPropProtection.ClearBuddies(ply, cmd, args)
	local PData = ply:GetPData("SPPBuddies", "")
	if PData ~= "" then
		for k, v in pairs(string.Explode(";", PData)) do
			local String = string.Trim(v)
			if String ~= "" then
				ply:ConCommand("SPropProtection_BuddyUp_"..string.gsub(String, ":", "_").." 0\n")
			end
		end
		ply:SetPData("SPPBuddies", "")
	end
	
	for k, v in pairs(SPropProtection[ply:SteamID()]) do
		ply:ConCommand("SPropProtection_BuddyUp_"..string.gsub(v, ":", "_").." 0\n")
	end
	SPropProtection[ply:SteamID()] = {}
	
	Notify(ply, 1, 4, "Your buddies have been cleared")
end
concommand.Add("SPropProtection_ClearBuddies", SPropProtection.ClearBuddies)

/*---------------------------------------------------------
Touching
---------------------------------------------------------*/
function SPropProtection.CanNotTouch(ply)
	if not ValidEntity(ply) then return end
	umsg.Start("SPPCantTouch", ply)
	umsg.End()
	return false
end

function SPropProtection.PlayerCanTouch(ply, ent)
	if tonumber(CfgVars["spp_on"]) == 0 or ent:GetClass() == "worldspawn" then
		return true
	end
	local class = ent:GetClass()
	
	if string.find(class, "stone_") == 1 or string.find(class, "rock_") == 1 or string.find(class, "stargate_") == 0 or string.find(class, "dhd_") == 0 or class == "flag" or class == "item" then
		if not ent:GetNetworkedString("Owner") or ent:GetNetworkedString("Owner") == "" then
			SPropProtection.WorldProps[ent:EntIndex()] = ent
		end
		if ply:GetActiveWeapon():GetClass() ~= "weapon_physgun" and ply:GetActiveWeapon():GetClass() ~= "gmod_tool" then
			return true
		end
	end
	
	if ent:GetNetworkedString("Owner") == "" and not ent:IsPlayer() and not table.HasValue(SPropProtection.WorldProps, ent) then
		SPropProtection.PlayerMakePropOwner(ply, ent)
		Notify(ply, 1, 4, "You now own this prop")
		return true
	end
	
	if SPropProtection["Props"][ent:EntIndex()] ~= nil then
		if SPropProtection["Props"][ent:EntIndex()][1] == ply:SteamID() or SPropProtection.IsBuddy(ply, ent) then
			return true
		end
	else
		for k, v in pairs(g_SBoxObjects) do
			for b, j in pairs(v) do
				for _, e in pairs(j) do
					if k == ply:SteamID() and e == ent then
						SPropProtection.PlayerMakePropOwner(ply, ent)
						Notify(ply, 1, 4, "You now own this prop")
						return true
					end
				end
			end
		end
		for k, v in pairs(GAMEMODE.CameraList) do
			for b, j in pairs(v) do
				if j == ent then
					if k == ply:SteamID() and e == ent then
						SPropProtection.PlayerMakePropOwner(ply, ent)
						Notify(ply, 1, 4, "You now own this prop")
						return true
					end
				end
			end
		end
	end
	

	if ent:GetNetworkedString("Owner") == "Shared" or ent:GetNetworkedString("Owner") == ply:Nick() then return true end

	if game.GetMap() == "gm_construct" and table.HasValue(SPropProtection.WorldProps, ent) then
		return true
	end

	if table.HasValue(SPropProtection.WorldProps, ent) then
		if (tonumber(CfgVars["spp_touchworldprops"]) == 1 or (ply:IsAdmin() and tonumber(CfgVars["spp_admin"]) == 1)) and (string.lower(class) == "prop_physics" or  string.lower(class) == "func_physbox" or string.lower(class) == "prop_physics_multiplayer") then
			return true
		end
	elseif ply:IsAdmin() and tonumber(CfgVars["spp_admin"]) == 1 then
		return true
	elseif ply:IsAdmin() and tonumber(CfgVars["spp_admin"]) == 0 then
		return false
	end
	return false
end

/*---------------------------------------------------------
Prop owning
---------------------------------------------------------*/
function SPropProtection.PlayerMakePropOwner(ply, ent)
	if ent:GetClass() == "transformer" and ent.spawned and not ent.Part then
		for k, v in pairs(transpiece[ent]) do
			v.Part = true
			SPropProtection.PlayerMakePropOwner(ply, v)
		end
	end
	if ent:IsPlayer() then
		return false
	end
	SPropProtection["Props"][ent:EntIndex()] = {ply:SteamID(), ent, ply}
	ent:SetNetworkedString("Owner", ply:Nick())
	gamemode.Call("CPPIAssignOwnership", ply, ent)
	return true
end

function SPropProtection.WorldOwner()
	local WorldEnts = 0
	for k, v in pairs(ents.FindByClass("*")) do
		if not v:IsPlayer() and v:GetNWString("Owner") == "" then
			SPropProtection.WorldProps[v:EntIndex()] = v
			WorldEnts = WorldEnts + 1
		end
	end
	Msg("=================================================\n")
	Msg("Simple RP Prop Protection: "..tostring(WorldEnts).." props belong to world\n")
	Msg("=================================================\n")
end
timer.Simple(10, SPropProtection.WorldOwner) 

function SPropProtection.UnOwnProp(ply)
	local ent = ply:GetEyeTrace().Entity
	if not ent:IsValid() then Notify(ply, 1, 4, "You have to be looking at an entity!") return end
	if ent:GetNWString("Owner") ~= ply:Nick() then Notify(ply, 1, 4, "You have to own this entity!") return end
	ent:SetNWString("Owner", "Shared")
	Notify(ply, 1, 4, "Unowned this entity!")
end
concommand.Add("SPropProtection_unown", SPropProtection.UnOwnProp)
