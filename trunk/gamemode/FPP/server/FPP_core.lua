FPP = FPP or {}
--------------------------------------------------------------------------------------
--Setting owner when someone spawns something
--------------------------------------------------------------------------------------
if cleanup then
	FPP.oldcleanup = FPP.oldcleanup or cleanup.Add
	function cleanup.Add(ply, Type, ent)
		if ValidEntity(ply) and ValidEntity(ent) then
			--Set the owner of the entity
			ent.Owner = ply
			ent.OwnerID = ply:SteamID()
			if FPP.AntiSpam and Type ~= "constraints" and Type ~= "stacks" then
				FPP.AntiSpam.CreateEntity(ply, ent, Type == "duplicates")
			end
		end
		FPP.oldcleanup(ply, Type, ent)
	end
end

local PLAYER = FindMetaTable("Player")

if PLAYER.AddCount then
	FPP.oldcount = FPP.oldcount or PLAYER.AddCount
	function PLAYER:AddCount(Type, ent)
		--Set the owner of the entity
		ent.Owner = self
		ent.OwnerID = self:SteamID()
		return FPP.oldcount(self, Type, ent)
	end
end


--------------------------------------------------------------------------------------
--When you can't touch something
--------------------------------------------------------------------------------------
function FPP.CanTouch(ply, Type, Owner, Toggle)
	if not ValidEntity(ply) or not FPP.Settings[Type] or not tobool(FPP.Settings[Type].shownocross) then return false end
	if ply.FPP_LastCanTouch and ply.FPP_LastCanTouch > CurTime() - 0.5 then return end
	ply.FPP_LastCanTouch = CurTime()
	
	umsg.Start("FPP_CanTouch", ply)
		if type(Owner) == "string" then
			umsg.String(Owner)
		elseif ValidEntity(Owner) then
			umsg.String(Owner:Nick())
		else
			umsg.String("No owner!")
		end
		umsg.Bool(Toggle)
	umsg.End()
	
	return Toggle, Owner
end


--------------------------------------------------------------------------------------
--The protecting itself
--------------------------------------------------------------------------------------

FPP.Protect = {}

local function cantouchsingleEnt(ply, ent, Type1, Type2, TryingToShare)
	local Returnal 
	for k,v in pairs(FPP.Blocked[Type1]) do
		if tobool(FPP.Settings[Type2].iswhitelist) and string.find(string.lower(ent:GetClass()), string.lower(v)) then --If it's a whitelist and the entity is found in the whitelist
			return true
		elseif (not tobool(FPP.Settings[Type2].iswhitelist) and string.find(string.lower(ent:GetClass()), string.lower(v))) or -- if it's a banned prop( and the blocked list is not a whitlist)
		(tobool(FPP.Settings[Type2].iswhitelist) and not string.find(string.lower(ent:GetClass()), string.lower(v))) then -- or if it's a white list and that entity is NOT in the whitelist
			if ply:IsAdmin() and tobool(FPP.Settings[Type2].admincanblocked) then
				Returnal = true
			elseif tobool(FPP.Settings[Type2].canblocked) then
				Returnal = true
			else
				Returnal = false
			end	
		end
	end
	
	if Returnal ~= nil and (not ent.Owner or ent.Owner == ply) then return Returnal, "Blocked!" end
	
	if ent["Share"..Type1] then return true, ent.Owner end
	
	if not TryingToShare and ent.AllowedPlayers and table.HasValue(ent.AllowedPlayers, ply) then 
		return true, ent.Owner
	end
	
	if ent.Owner ~= ply then
		if not TryingToShare and ValidEntity(ent.Owner) and ent.Owner.Buddies and ent.Owner.Buddies[ply] and ent.Owner.Buddies[ply][string.lower(Type1)] then
			return true, ent.Owner
		elseif ent.Owner and ply:IsAdmin() and tobool(FPP.Settings[Type2].adminall) then -- if not world prop AND admin allowed
			return true, ent.Owner
		elseif ent == GetWorldEntity() or ent:GetClass() == "gmod_anchor" then
			return true
		elseif not ValidEntity(ent.Owner) then --If world prop or a prop belonging to someone who left
			local world = "World prop"
			if ent.Owner then world = "Disconnected player's prop" end
			if ply:IsAdmin() and tobool(FPP.Settings[Type2].adminworldprops) then -- if admin and admin allowed
				return true, world
			elseif tobool(FPP.Settings[Type2].worldprops) then -- if worldprop allowed
				return true, world
			end -- if not allowed then
			return false, world
		else -- You don't own this, simple
			return false, ent.Owner
		end
	end 
	return true
end

--Global cantouch function
function FPP.PlayerCanTouchEnt(ply, ent, Type1, Type2, TryingToShare, antiloop)
	local CanTouchSingleEnt, WHY = cantouchsingleEnt(ply, ent, Type1, Type2, TryingToShare)
	if not CanTouchSingleEnt then return CanTouchSingleEnt, WHY end
	
	if tobool(FPP.Settings[Type2].checkconstrained) then-- if we're ought to check the constraints, check every entity at once.
		local constrainted = constraint.GetAllConstrainedEntities(ent)
		if constrainted then
			for k,v in pairs(constraint.GetAllConstrainedEntities(ent)) do
				if v ~= ent then
					local cantouch, why = cantouchsingleEnt(ply, v, Type1, Type2, false)
					why = why or "World prop"
					if not cantouch then
						if type(why) == "Player" then why = why:Nick() end
						return false, "Constrained entity: "..why
					end 
				end
			end 
		end
	end
	return CanTouchSingleEnt, WHY
end

local function DoShowOwner(ply, ent, cantouch, why)
	umsg.Start("FPP_Owner", ply)
		umsg.Entity(ent)
		umsg.Bool(cantouch)
		umsg.String(tostring(why))
	umsg.End()
end

function FPP.ShowOwner()
	for _, ply in pairs(player.GetAll()) do
		local wep = ply:GetActiveWeapon()
		local trace = ply:GetEyeTrace()
		if ValidEntity(wep) and ValidEntity(trace.Entity) and trace.Entity ~= GetWorldEntity() and not trace.Entity:IsPlayer() and ply.FPP_LOOKINGAT ~= trace.Entity then
			ply.FPP_LOOKINGAT = trace.Entity -- Easy way to prevent spamming the usermessages
			local class, cantouch, why = wep:GetClass()
			if class == "weapon_physgun" then
				cantouch, why = FPP.PlayerCanTouchEnt(ply, trace.Entity, "Physgun", "FPP_PHYSGUN")
				why = why or trace.Entity.Owner or "World prop"
			elseif class == "weapon_physcannon" then
				cantouch, why = FPP.PlayerCanTouchEnt(ply, trace.Entity, "Gravgun", "FPP_GRAVGUN")
				why = why or trace.Entity.Owner or "World prop"
			elseif class == "gmod_tool" then
				cantouch, why = FPP.PlayerCanTouchEnt(ply, trace.Entity, "Toolgun", "FPP_TOOLGUN")
				why = why or trace.Entity.Owner or "World prop"
			else
				cantouch, why = FPP.PlayerCanTouchEnt(ply, trace.Entity, "EntityDamage", "FPP_ENTITYDAMAGE")
				why = why or trace.Entity.Owner or "World prop"
			end
			if type(why) == "Player" and why:IsValid() then why = why:Nick() end
			DoShowOwner(ply, trace.Entity, cantouch, why)
		elseif ply.FPP_LOOKINGAT ~= trace.Entity then
			ply.FPP_LOOKINGAT = nil
		end
	end
end
hook.Add("Think", "FPP_ShowOwner", FPP.ShowOwner)


--Physgun Pickup
function FPP.Protect.PhysgunPickup(ply, ent)
	if not tobool(FPP.Settings.FPP_PHYSGUN.toggle) then if FPP.UnGhost then FPP.UnGhost(ply, ent) end return end
	if not ent:IsValid() then return FPP.CanTouch(ply, "FPP_PHYSGUN", "Not valid!", false) end
	
	if ent:IsPlayer() then return end
	
	local cantouch, why = FPP.PlayerCanTouchEnt(ply, ent, "Physgun", "FPP_PHYSGUN")
	if why then
		FPP.CanTouch(ply, "FPP_PHYSGUN", why, cantouch)
	end

	if cantouch and FPP.UnGhost then 
		FPP.UnGhost(ply, ent)
	end
	
	if not cantouch then return false end
end
hook.Add("PhysgunPickup", "FPP.Protect.PhysgunPickup", FPP.Protect.PhysgunPickup)

/*
function FPP.Protect.PhysgunDrop(ply, DropEnt)
	if not tobool(FPP.Settings.FPP_PHYSGUN.antinoob) then return end --Antinoob only code in the physgundrop
	if DropEnt:GetClass() == "func_breakable_surf" then return end
end
hook.Add("PhysgunDrop", "FPP.Protect.PhysgunDrop", FPP.Protect.PhysgunDrop)*/

--Physgun reload
function FPP.Protect.PhysgunReload(weapon, ply)
	if not tobool(FPP.Settings.FPP_PHYSGUN.reloadprotection) then return end
	
	local ent = ply:GetEyeTrace().Entity
	
	if not ValidEntity(ent) then return end
	
	local cantouch, why = FPP.PlayerCanTouchEnt(ply, ent, "Physgun", "FPP_PHYSGUN")
	if why then
		FPP.CanTouch(ply, "FPP_PHYSGUN", why, cantouch)
	end
	
	if not cantouch then return false end
	return --If I return true, I will break the double reload
end
hook.Add("OnPhysgunReload", "FPP.Protect.PhysgunReload", FPP.Protect.PhysgunReload)

--Gravgun pickup
function FPP.Protect.GravGunPickup(ply, ent)
	if not tobool(FPP.Settings.FPP_GRAVGUN.toggle) then return end
	
	if not ValidEntity(ent) then return false end-- You don't want a cross when looking at the floor while holding right mouse
	
	if ent:IsPlayer() then return false end
	
	local cantouch, why = FPP.PlayerCanTouchEnt(ply, ent, "Gravgun", "FPP_GRAVGUN")
	if why then
		FPP.CanTouch(ply, "FPP_GRAVGUN", why, cantouch)
	end
	
	if FPP.UnGhost and cantouch then FPP.UnGhost(ply, ent) end
	return cantouch
end
hook.Add("GravGunPickupAllowed", "FPP.Protect.GravGunPickup", FPP.Protect.GravGunPickup)

--Gravgun punting
function FPP.Protect.GravGunPunt(ply, ent)
	if tobool(FPP.Settings.FPP_GRAVGUN.noshooting) then DropEntityIfHeld(ent) return false end
	
	if not ValidEntity(ent) then return FPP.CanTouch(ply, "FPP_GRAVGUN", "Not valid!", false) end
	
	local cantouch, why = FPP.PlayerCanTouchEnt(ply, ent, "Gravgun", "FPP_GRAVGUN")
	if why then
		FPP.CanTouch(ply, "FPP_GRAVGUN", why, cantouch)
	end
	
	if FPP.UnGhost and cantouch then FPP.UnGhost(ply, ent) end
	return cantouch
end
hook.Add("GravGunPunt", "FPP.Protect.GravGunPunt", FPP.Protect.GravGunPunt)

--PlayerUse
function FPP.Protect.PlayerUse(ply, ent)
	if not tobool(FPP.Settings.FPP_PLAYERUSE.toggle) then return end
	
	if not ValidEntity(ent) then return FPP.CanTouch(ply, "FPP_PLAYERUSE", "Not valid!", false) end
	
	local cantouch, why = FPP.PlayerCanTouchEnt(ply, ent, "PlayerUse", "FPP_PLAYERUSE")
	if why then
		FPP.CanTouch(ply, "FPP_PLAYERUSE", why, cantouch)
	end
	
	if FPP.UnGhost and cantouch then FPP.UnGhost(ply, ent) end
	return cantouch
end
hook.Add("PlayerUse", "FPP.Protect.PlayerUse", FPP.Protect.PlayerUse)

--EntityDamage
function FPP.Protect.EntityDamage(ent, inflictor, attacker, amount, dmginfo)
	if ent:IsPlayer() then
		if tobool(FPP.Settings.FPP_PHYSGUN.antinoob) and not dmginfo:IsBulletDamage() and 
		((ValidEntity(attacker.Owner) and attacker.Owner != ent) or 
			(ValidEntity(inflictor.Owner) and inflictor.Owner != ent) or 
			(attacker == GetWorldEntity() and amount == 200)) then -- Somehow when you prop kill someone while using world spawn(You push someone against the wall) The damage is ALWAYS 200.
			dmginfo:SetDamage(0)
		end
		return 
	end
	
	if not tobool(FPP.Settings.FPP_ENTITYDAMAGE.toggle) then return end
	
	if not attacker:IsPlayer() then 
		if ValidEntity(attacker.Owner) and ValidEntity(ent.Owner) then
			local cantouch, why = FPP.PlayerCanTouchEnt(attacker.Owner, ent, "EntityDamage", "FPP_ENTITYDAMAGE")
			if why then
				FPP.CanTouch(attacker.Owner, "FPP_ENTITYDAMAGE", why, cantouch)
			end
			if not cantouch then 
				dmginfo:SetDamage(0)
				ent.FPPAntiDamageWorld = ent.FPPAntiDamageWorld or 0
				ent.FPPAntiDamageWorld = ent.FPPAntiDamageWorld + 1
				timer.Simple(1, function(ent) 
					if not ent.FPPAntiDamageWorld then return end
					ent.FPPAntiDamageWorld = ent.FPPAntiDamageWorld - 1 
					if ent.FPPAntiDamageWorld == 0 then 
						ent.FPPAntiDamageWorld = nil 
					end 
				end, ent)
			end
			return
		end
		
		if attacker == GetWorldEntity() and ent.FPPAntiDamageWorld then
			dmginfo:SetDamage(0)
		end
		return
	end
	
	if not ValidEntity(ent) then return FPP.CanTouch(attacker, "FPP_ENTITYDAMAGE", "Not valid!", false) end
	
	local cantouch, why = FPP.PlayerCanTouchEnt(attacker, ent, "EntityDamage", "FPP_ENTITYDAMAGE")
	if why /*and (not ValidEntity(attacker:GetActiveWeapon()) or (ValidEntity(attacker:GetActiveWeapon()) and attacker:GetActiveWeapon():GetClass() == "weapon_physcannon")) */then
		FPP.CanTouch(attacker, "FPP_ENTITYDAMAGE", why, cantouch)
	end
	
	if FPP.Settings.FPP_PHYSGUN.antinoob and ValidEntity(attacker.Owner) and attacker.Owner ~= ent and ent:IsPlayer() then
		cantouch = false
	end
	
	if not cantouch then dmginfo:SetDamage(0) end
	return
end
hook.Add("EntityTakeDamage", "FPP.Protect.EntityTakeDamage", FPP.Protect.EntityDamage)

--Toolgun
local allweapons = {"weapon_crowbar", "weapon_physgun", "weapon_physcannon", "weapon_pistol", "weapon_stunstick", "weapon_357", "weapon_smg1",
	"weapon_ar2", "weapon_shotgun", "weapon_crossbow", "weapon_frag", "weapon_rpg", "gmod_camera", "gmod_tool", "weapon_bugbait"} --for advanced duplicator, you can't use any IsWeapon...
timer.Simple(5, function()
	for k,v in pairs(weapons.GetList()) do
		if v.ClassName then table.insert(allweapons, v.ClassName) end
	end
end)

function FPP.Protect.CanTool(ply, trace, tool, ENT)
	-- Toolgun restrict
	local ignoreGeneralRestrictTool = false
	local SteamID = ply:SteamID()
	
	if not FPP.RestrictedToolsPlayers then FPP.RestrictedToolsPlayers = {} end
	if FPP.RestrictedToolsPlayers[tool] and FPP.RestrictedToolsPlayers[tool][SteamID] ~= nil then--Player specific
		if FPP.RestrictedToolsPlayers[tool][SteamID] == false then
			FPP.CanTouch(ply, "FPP_TOOLGUN", "Toolgun restricted for you!", false)
			return false
		elseif FPP.RestrictedToolsPlayers[tool][SteamID] == true then
			ignoreGeneralRestrictTool = true --If someone is allowed, then he's allowed even though he's not admin, so don't check for further restrictions
		end
	end
	
	if not ignoreGeneralRestrictTool then
		local Group = FPP.Groups[FPP.GroupMembers[SteamID] or "default"] -- What group is the player in. If not in a special group, then he's in default group
		
		local CanGroup = true
		if Group and ((Group.allowdefault and table.HasValue(Group.tools, tool)) or -- If the tool is on the BLACKLIST or
			(not Group.allowdefault and not table.HasValue(Group.tools, tool))) then -- If the tool is NOT on the WHITELIST
			CanGroup = false
		end
		
		if FPP.RestrictedTools[tool] then
			if tonumber(FPP.RestrictedTools[tool].admin) == 1 and not ply:IsAdmin() then
				FPP.CanTouch(ply, "FPP_TOOLGUN", "Toolgun restricted! Admin only!", false)
				return false
			elseif tonumber(FPP.RestrictedTools[tool].admin) == 2 and not ply:IsSuperAdmin() then
				FPP.CanTouch(ply, "FPP_TOOLGUN", "Toolgun restricted! Superadmin only!", false)
				return false
			elseif (tonumber(FPP.RestrictedTools[tool].admin) == 1 and ply:IsAdmin()) or (tonumber(FPP.RestrictedTools[tool].admin) == 2 and ply:IsSuperAdmin()) then
				CanGroup = true -- If the person is not in the group BUT has admin access, he should be able to use the tool
			end
			
			if FPP.RestrictedTools[tool]["team"] and #FPP.RestrictedTools[tool]["team"] > 0 and not table.HasValue(FPP.RestrictedTools[tool]["team"], ply:Team())
			and not FPP.GroupMembers[SteamID]/*Is in default group*/ and CanGroup/*Has group access*/ then
				FPP.CanTouch(ply, "FPP_TOOLGUN", "Toolgun restricted! incorrect team!", false)
				return false
			end
		end
		
		if not CanGroup then 
			FPP.CanTouch(ply, "FPP_TOOLGUN", "Toolgun restricted! incorrect group!", false)
			return false
		end
	end
	
	-- Anti model server crash
	if ValidEntity(ply:GetActiveWeapon()) and ply:GetActiveWeapon().GetToolObject and ply:GetActiveWeapon():GetToolObject() and 
	(string.find(ply:GetActiveWeapon():GetToolObject():GetClientInfo( "model" ), "*") or 
	string.find(ply:GetActiveWeapon():GetToolObject():GetClientInfo( "material" ), "*") or
	string.find(ply:GetActiveWeapon():GetToolObject():GetClientInfo( "model" ), "\\")
	/*or string.find(ply:GetActiveWeapon():GetToolObject():GetClientInfo( "tool" ), "/")*/) then
		FPP.Notify(ply, "The material/model of the tool is invalid!", false)
		FPP.CanTouch(ply, "FPP_TOOLGUN", "The material/model of the tool is invalid!", false)
		return false
	end	
	
	local ent = ENT or trace.Entity
	
	if tobool(FPP.Settings.FPP_TOOLGUN.toggle) and ValidEntity(ent) then
		
		local cantouch, why = FPP.PlayerCanTouchEnt(ply, ent, "Toolgun", "FPP_TOOLGUN")
		if why then
			FPP.CanTouch(ply, "FPP_TOOLGUN", why, cantouch)
		end
		if not cantouch then return false end	
	end

	if tool ~= "adv_duplicator" and tool ~= "duplicator" then return end
	if not FPP.AntiSpam.DuplicatorSpam(ply) then return false end
	if tool == "adv_duplicator" and ply:GetActiveWeapon():GetToolObject().Entities then
		for k,v in pairs(ply:GetActiveWeapon():GetToolObject().Entities) do
			if tobool(FPP.Settings.FPP_TOOLGUN.duplicatenoweapons) then
				for c, d in pairs(allweapons) do
					if string.lower(v.Class) == string.lower(d) then
						FPP.CanTouch(ply, "FPP_TOOLGUN", "Duplicating blocked entity", false)
						ply:GetActiveWeapon():GetToolObject().Entities[k] = nil
					end
				end
			end
			if tobool(FPP.Settings.FPP_TOOLGUN.duplicatorprotect) then
				local setspawning = tobool(FPP.Settings.FPP_TOOLGUN.spawniswhitelist)
				for c, d in pairs(FPP.Blocked.Spawning) do
					if not tobool(FPP.Settings.FPP_TOOLGUN.spawniswhitelist) and string.find(v.Class, d) then
						FPP.CanTouch(ply, "FPP_TOOLGUN", "Duplicating blocked entity", false)
						ply:GetActiveWeapon():GetToolObject().Entities[k] = nil
						break
					end
					if tobool(FPP.Settings.FPP_TOOLGUN.spawniswhitelist) and string.find(v.Class, d) then -- if the whitelist is on you can't spawn it unless it's found
						setspawning = false
						break
					end
				end
				if setspawning then
					FPP.CanTouch(ply, "FPP_TOOLGUN", "Duplicating blocked entity", false)
					ply:GetActiveWeapon():GetToolObject().Entities[k] = nil
				end
			end
		end
		return --No further questions sir!
	end
	
	if tool == "duplicator" and ply:UniqueIDTable( "Duplicator" ).Entities then
		local Ents = ply:UniqueIDTable( "Duplicator" ).Entities
		for k,v in pairs(Ents) do
			if tobool(FPP.Settings.FPP_TOOLGUN.duplicatenoweapons) then
				for c, d in pairs(allweapons) do
					if string.lower(v.Class) == string.lower(d) then
						FPP.CanTouch(ply, "FPP_TOOLGUN", "Duplicating blocked entity", false)
						ply:UniqueIDTable( "Duplicator" ).Entities[k] = nil
					end
				end
			end
			if tobool(FPP.Settings.FPP_TOOLGUN.duplicatorprotect) then
				local setspawning = tobool(FPP.Settings.FPP_TOOLGUN.spawniswhitelist)
				for c, d in pairs(FPP.Blocked.Spawning) do
					if not tobool(FPP.Settings.FPP_TOOLGUN.spawniswhitelist) and string.find(v.Class, d) then
						FPP.CanTouch(ply, "FPP_TOOLGUN", "Duplicating blocked entity", false)
						ply:UniqueIDTable( "Duplicator" ).Entities[k] = nil
						break
					end
					if tobool(FPP.Settings.FPP_TOOLGUN.spawniswhitelist) and string.find(v.Class, d) then -- if the whitelist is on you can't spawn it unless it's found
						FPP.CanTouch(ply, "FPP_TOOLGUN", "Duplicating blocked entity", false)
						setspawning = false
						break
					end
				end
				if setspawning then
					FPP.CanTouch(ply, "FPP_TOOLGUN", "Duplicating blocked entity", false)
					ply:UniqueIDTable( "Duplicator" ).Entities[k] = nil
				end
			end
		end
	end
	return GAMEMODE:CanTool(ply, trace, tool)
end
hook.Add("CanTool", "FPP.Protect.CanTool", FPP.Protect.CanTool)

--Player disconnect, not part of the Protect table.
function FPP.PlayerDisconnect(ply)
	if ValidEntity(ply) and tobool(FPP.Settings.FPP_GLOBALSETTINGS.cleanupdisconnected) and FPP.Settings.FPP_GLOBALSETTINGS.cleanupdisconnectedtime then
		if ply:IsAdmin() and not tobool(FPP.Settings.FPP_GLOBALSETTINGS.cleanupadmin) then return end
		timer.Simple(FPP.Settings.FPP_GLOBALSETTINGS.cleanupdisconnectedtime, function(SteamID)
			for k,v in pairs(player.GetAll()) do
				if v:SteamID() == SteamID then
					return
				end
			end
			for k,v in pairs(ents.GetAll()) do
				if ValidEntity(v) and v.OwnerID == SteamID then
					v:Remove()
				end
			end
		end, ply:SteamID())
	end
end
hook.Add("PlayerDisconnected", "FPP.PlayerDisconnect", FPP.PlayerDisconnect)

--PlayerInitialspawn, the props he had left before will now be his again
function FPP.PlayerInitialSpawn(ply)
	local RP = RecipientFilter()
	
	timer.Simple(5, function(ply)
		if not ValidEntity(ply) then return end
		RP:AddAllPlayers()
		RP:RemovePlayer(ply)
		umsg.Start("FPP_CheckBuddy", RP)--Message everyone that a new player has joined
			umsg.Entity(ply)
		umsg.End()
	end, ply)
	
	for k,v in pairs(ents.GetAll()) do
		if ValidEntity(v) and v.OwnerID == ply:SteamID() then
			v.Owner = ply
		end
	end
	
	----------------------------------------------------------------
	-- AntiSpeedHack, Thanks Eusion(bloodychef) for the idea.
	---------------------------------------------------------------
	if not tobool(FPP.Settings.FPP_GLOBALSETTINGS.antispeedhack) then return end
	ply:SendLua([[local function a()
		if GetConVarNumber("host_timescale") ~= 1 or GetConVarNumber("host_framerate") ~= 0 then
			LocalPlayer():Remove()
		end
	end
	local function b()
		a()
		timer.Simple(0.1, b)
	end
	timer.Simple(0.1, b)]])--I know Lua scripters can get around this, but at least this protects from the noobs with speedhacks ^^
end
hook.Add("PlayerInitialSpawn", "FPP.PlayerInitialSpawn", FPP.PlayerInitialSpawn)

local ENTITY = FindMetaTable("Entity")
local backup = ENTITY.FireBullets
local blockedEffects = {"particleeffect", "smoke", "vortdispel", "helicoptermegabomb"}

function ENTITY:FireBullets(bullet, ...)
	if not bullet.TracerName then return backup(self, bullet, ...) end
	if table.HasValue(blockedEffects, string.lower(bullet.TracerName)) then
		bullet.TracerName = ""
	end
	return backup(self, bullet, ...)
end

function FPP.Protect.LeaveVehicle(ply, vehicle)
	local pos = vehicle:GetPos()
	timer.Simple(0.1, function(pos)
		if not ply:IsValid() then return end 
		
		local PlyPos = ply:GetPos()
		local diff = pos - PlyPos
		
		local trace = {}
		trace.start = pos	
		trace.endpos = PlyPos
		trace.filter = {ply,vehicle}
		trace.mask = -1
		local TraceResult = util.TraceLine(trace)
		
		if not TraceResult.Hit then
			return
		end
		

		trace.endpos = pos + diff
		TraceResult = util.TraceLine(trace)
		if not TraceResult.Hit then
			ply:SetPos(pos + diff)
			return
		end

		ply:SetPos(pos + Vector(0,0,50) + 0.1 * diff)
	end, pos)
end
hook.Add("PlayerLeaveVehicle", "FPP.PlayerLeaveVehicle", FPP.Protect.LeaveVehicle)