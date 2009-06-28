FPP = FPP or {}
--------------------------------------------------------------------------------------
--Setting owner when someone spawns something
--------------------------------------------------------------------------------------
if cleanup then
	FPP.oldcleanup = FPP.oldcleanup or cleanup.Add
	function cleanup.Add(ply, Type, ent)
		if ValidEntity(ply) and ValidEntity(ent) then
			ent.Owner = ply
			ent.OwnerID = ply:SteamID()
		end
		FPP.oldcleanup(ply, Type, ent)
	end
end

local PLAYER = FindMetaTable("Player")

if PLAYER.AddCount then
	FPP.oldcount = FPP.oldcount or PLAYER.AddCount
	function PLAYER:AddCount(Type, ent)
		ent.Owner = self
		ent.OwnerID = self:SteamID()
		return FPP.oldcount(self, Type, ent)
	end
end


--------------------------------------------------------------------------------------
--When you can't touch something
--------------------------------------------------------------------------------------
function FPP.CanTouch(ply, Type, Owner, Toggle)
	if not ValidEntity(ply) or FPP.Settings[Type] or not tobool(FPP.Settings[Type].shownocross) then return false end
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
	return false 
end


--------------------------------------------------------------------------------------
--The protecting itself
--------------------------------------------------------------------------------------

FPP.Protect = {}

--Global cantouch function
function FPP.PlayerCanTouchEnt(ply, ent, Type1, Type2, TryingToShare)
	
	local Returnal 
	for k,v in pairs(FPP.Blocked[Type1]) do
		if tobool(FPP.Settings[Type2].iswhitelist) and string.find(string.lower(ent:GetClass()), v) then --If it's a whitelist and the entity is found in the whitelist
			return true
		elseif (not tobool(FPP.Settings[Type2].iswhitelist) and string.find(string.lower(ent:GetClass()), v)) or -- if it's a banned prop( and the blocked list is not a whitlist)
		(tobool(FPP.Settings[Type2].iswhitelist) and not string.find(string.lower(ent:GetClass()), v)) then -- or if it's a white list and that entity is NOT in the whitelist
			if ply:IsAdmin() and tobool(FPP.Settings[Type2].admincanblocked) then
				Returnal = true
			elseif tobool(FPP.Settings[Type2].canblocked) then
				Returnal = true
			else
				Returnal = false
			end	
		end
	end
	
	if Returnal ~= nil then FPP.CanTouch(ply, Type2, "Blocked!", Returnal) return Returnal end
	
	if not TryingToShare and ent.AllowedPlayers and table.HasValue(ent.AllowedPlayers, ply) then 
		FPP.CanTouch(ply, Type2, ent.Owner, true)
		return true 
	end
	
	if ent.Owner ~= ply then
		if not TryingToShare and ValidEntity(ent.Owner) and ent.Owner.Buddies and ent.Owner.Buddies[ply] and ent.Owner.Buddies[ply][string.lower(Type1)] then
			FPP.CanTouch(ply, Type2, ent.Owner, true)
			return true
		elseif ent.Owner and ply:IsAdmin() and tobool(FPP.Settings[Type2].adminall) then -- if not world prop AND admin allowed
			FPP.CanTouch(ply, Type2, ent.Owner, true)
			return true
		elseif not ValidEntity(ent.Owner) then --If world prop or a prop belonging to someone who left
			if ply:IsAdmin() and tobool(FPP.Settings[Type2].adminworldprops) then -- if admin and admin allowed
				return true
			elseif tobool(FPP.Settings[Type2].worldprops) then -- if worldprop allowed
				return true
			end -- if not allowed then
			return false
		else -- You don't own this, simple
			return false
		end
	end 
	return true
end

local function FindOutOwner(ply, key)
	if key == IN_ATTACK2 and not ply:KeyDown(IN_ATTACK) and ValidEntity(ply:GetActiveWeapon()) and ply:GetActiveWeapon():GetClass() == "weapon_physgun" and ValidEntity(ply:GetEyeTrace().Entity) then
		local ent = ply:GetEyeTrace().Entity
		if ent.SharePhysgun  then
			return FPP.CanTouch(ply, ent, "FPP_PHYSGUN", ent.Owner, true)
		elseif not FPP.PlayerCanTouchEnt(ply, ent, "Physgun", "FPP_PHYSGUN") then
			return FPP.CanTouch(ply, "FPP_PHYSGUN", ent.Owner, false)
		elseif tobool(FPP.Settings.FPP_PHYSGUN.checkconstrained) then
			for k,v in pairs(constraint.GetAllConstrainedEntities(ent)) do
				if v ~= ent and not FPP.PlayerCanTouchEnt(ply, v, "Physgun", "FPP_PHYSGUN") then
					return FPP.CanTouch(ply, "FPP_PHYSGUN", ent.Owner, false)
				end
			end
		end
		FPP.CanTouch(ply, "FPP_PHYSGUN", ent.Owner, true)
	end
end
hook.Add("KeyPress", "FPP_FindOutOwner", FindOutOwner)

local function AntiNoob(ent)
	if not tobool(FPP.Settings.FPP_PHYSGUN.antinoob) then return end 
	ent:SetNotSolid(true)
	ent:SetRenderMode(RENDERMODE_TRANSALPHA)
	ent:DrawShadow(false)
	ent.OldColor = {ent:GetColor()}
	ent.StartPos = ent:GetPos()
	ent:SetColor(ent.OldColor[1], ent.OldColor[2], ent.OldColor[3], ent.OldColor[4] - 155)
end

--Physgun Pickup
function FPP.Protect.PhysgunPickup(ply, ent)
	if not tobool(FPP.Settings.FPP_PHYSGUN.toggle) then return end
	if not ent:IsValid() then return FPP.CanTouch(ply, "FPP_PHYSGUN", "Not valid!", false) end
	
	if ent:IsPlayer() then return end
	if ent.SharePhysgun then AntiNoob(ent) return true end
	
	if not FPP.PlayerCanTouchEnt(ply, ent, "Physgun", "FPP_PHYSGUN") then
		return FPP.CanTouch(ply, "FPP_PHYSGUN", ent.Owner, false)
	end
	
	if tobool(FPP.Settings.FPP_PHYSGUN.checkconstrained) then-- if we're ought to check the constraints
		for k,v in pairs(constraint.GetAllConstrainedEntities(ent)) do
			if v ~= ent and not FPP.PlayerCanTouchEnt(ply, v, "Physgun", "FPP_PHYSGUN") and not v.SharePhysgun then
				return FPP.CanTouch(ply, "FPP_PHYSGUN", ent.Owner, false)
			end
		end
	end 
	AntiNoob(ent)
	return true
end
hook.Add("PhysgunPickup", "FPP.Protect.PhysgunPickup", FPP.Protect.PhysgunPickup)

function FPP.Protect.PhysgunDrop(ply,ent)
	if not tobool(FPP.Settings.FPP_PHYSGUN.antinoob) then return end --Antinoob only code in the physgundrop
	ent:SetNotSolid(false)
	ent:DrawShadow(true)
	local phys = ent:GetPhysicsObject()
	if phys:IsValid() and phys:IsMoveable() then
		ent:SetCollisionGroup(COLLISION_GROUP_WEAPON)--Collides with everything but players -> No prop killing!
	else
		ent:SetCollisionGroup(COLLISION_GROUP_INTERACTIVE)
	end
	if ent.OldColor then
		ent:SetColor(ent.OldColor[1], ent.OldColor[2], ent.OldColor[3], ent.OldColor[4])
	end
	
	local tr = {}
	tr.start = ent.StartPos
	tr.endpos = ent:GetPos()
	tr.filter = player.GetAll()
	local trace = util.TraceLine(tr)
	tr.start = ply:GetShootPos()
	local trace2 = util.TraceLine(tr)
	if trace2.Entity ~= ent then
		local vFlushPoint = trace.HitPos - ( trace.HitNormal * 512 )  // Find a point that is definitely out of the object in the direction of the floor
		vFlushPoint = ent:NearestPoint( vFlushPoint )                   // Find the nearest point inside the object to that point
		vFlushPoint = ent:GetPos() - vFlushPoint                                // Get the difference
		vFlushPoint = trace.HitPos + vFlushPoint                                   // Add it to our target pos
		ent:SetPos(vFlushPoint)
	end
end
hook.Add("PhysgunDrop", "FPP.Protect.PhysgunDrop", FPP.Protect.PhysgunDrop)

--Physgun reload
function FPP.Protect.PhysgunReload(weapon, ply)
	if not tobool(FPP.Settings.FPP_PHYSGUN.reloadprotection) then return end
	
	local ent = ply:GetEyeTrace().Entity
	
	if ent.SharePhysgun then return true end
	
	if not ValidEntity(ent) then return end
	
	if not FPP.PlayerCanTouchEnt(ply, ent, "Physgun", "FPP_PHYSGUN") then 
		return FPP.CanTouch(ply, "FPP_PHYSGUN", ent.Owner, false)
	end
	
	if tobool(FPP.Settings.FPP_PHYSGUN.checkconstrained) then-- if we're ought to check the constraints
		for k,v in pairs(constraint.GetAllConstrainedEntities(ent)) do
			if not FPP.PlayerCanTouchEnt(ply, v, "Physgun", "FPP_PHYSGUN") and not v.SharePhysgun then
				return FPP.CanTouch(ply, "FPP_PHYSGUN", ent.Owner, false)
			end
		end
	end
	return
end
hook.Add("OnPhysgunReload", "FPP.Protect.PhysgunReload", FPP.Protect.PhysgunReload)

--Gravgun pickup
function FPP.Protect.GravGunPickup(ply, ent)
	if not tobool(FPP.Settings.FPP_GRAVGUN.toggle) then return end
	
	if not ValidEntity(ent) then return false end-- You don't want a cross when looking at the floor while holding right mouse
	
	if ent.ShareGravgun then return true end
	
	if ent:IsPlayer() then return false end
	
	if not FPP.PlayerCanTouchEnt(ply, ent, "Gravgun", "FPP_GRAVGUN") then
		return FPP.CanTouch(ply, "FPP_GRAVGUN", ent.Owner, false)
	end
	
	if tobool(FPP.Settings.FPP_GRAVGUN.checkconstrained) then-- if we're ought to check the constraints
		for k,v in pairs(constraint.GetAllConstrainedEntities(ent)) do
			if v ~= ent and not FPP.PlayerCanTouchEnt(ply, v, "Gravgun", "FPP_GRAVGUN") and not v.ShareGravgun then
				return FPP.CanTouch(ply, "FPP_GRAVGUN", ent.Owner, false)
			end
		end
	end
	return true
end
hook.Add("GravGunPickupAllowed", "FPP.Protect.GravGunPickup", FPP.Protect.GravGunPickup)

--Gravgun punting
function FPP.Protect.GravGunPunt(ply, ent)
	if tobool(FPP.Settings.FPP_GRAVGUN.noshooting) then DropEntityIfHeld(ent) return false end
	
	if not ValidEntity(ent) then return FPP.CanTouch(ply, "FPP_GRAVGUN", "Not valid!", false) end
	
	if ent.ShareGravgun then return true end
	
	if not FPP.PlayerCanTouchEnt(ply, ent, "Gravgun", "FPP_GRAVGUN") then
		return FPP.CanTouch(ply, "FPP_GRAVGUN", ent.Owner, false)
	end
	
	if tobool(FPP.Settings.FPP_GRAVGUN.checkconstrained) then-- if we're ought to check the constraints
		for k,v in pairs(constraint.GetAllConstrainedEntities(ent)) do
			if v ~= ent and not FPP.PlayerCanTouchEnt(ply, v, "Gravgun", "FPP_GRAVGUN") and not v.ShareGravgun then
				return FPP.CanTouch(ply, "FPP_GRAVGUN", ent.Owner, false)
			end
		end
	end
	return true
end
hook.Add("GravGunPunt", "FPP.Protect.GravGunPunt", FPP.Protect.GravGunPunt)

--PlayerUse
function FPP.Protect.PlayerUse(ply, ent)
	if not tobool(FPP.Settings.FPP_PLAYERUSE.toggle) then return end
	
	if not ValidEntity(ent) then return FPP.CanTouch(ply, "FPP_PLAYERUSE", "Not valid!", false) end
	
	if ent.SharePlayerUse then return true end
	
	if not FPP.PlayerCanTouchEnt(ply, ent, "PlayerUse", "FPP_PLAYERUSE") then
		return FPP.CanTouch(ply, "FPP_PLAYERUSE", ent.Owner, false)
	end
	
	if tobool(FPP.Settings.FPP_PLAYERUSE.checkconstrained) then-- if we're ought to check the constraints
		for k,v in pairs(constraint.GetAllConstrainedEntities(ent)) do
			if v ~= ent and not FPP.PlayerCanTouchEnt(ply, v, "PlayerUse", "FPP_PLAYERUSE") and not v.SharePlayerUse then
				return FPP.CanTouch(ply, "FPP_PLAYERUSE", ent.Owner, false)
			end
		end
	end
	return true
end
hook.Add("PlayerUse", "FPP.Protect.PlayerUse", FPP.Protect.PlayerUse)

--EntityDamage
function FPP.Protect.EntityDamage(ent, inflictor, attacker, amount, dmginfo)
	if not tobool(FPP.Settings.FPP_ENTITYDAMAGE.toggle) then return end
	if not attacker:IsPlayer() then return end
	if ent:IsPlayer() then return end
	
	if not ValidEntity(ent) then return FPP.CanTouch(attacker, "FPP_ENTITYDAMAGE", "Not valid!", false) end
	
	if ent.ShareDamage then return end
	
	if not FPP.PlayerCanTouchEnt(attacker, ent, "EntityDamage", "FPP_ENTITYDAMAGE") then
		dmginfo:SetDamage(0)
		
		if ValidEntity(attacker:GetActiveWeapon()) and attacker:GetActiveWeapon():GetClass() == "weapon_physcannon" then -- Bug fix that you get the no cross when gravgunning someone else's entity while you can punt it
			return false
		end
		return FPP.CanTouch(attacker, "FPP_ENTITYDAMAGE", ent.Owner, false)
	end
	
	if tobool(FPP.Settings.FPP_ENTITYDAMAGE.checkconstrained) then-- if we're ought to check the constraints
		for k,v in pairs(constraint.GetAllConstrainedEntities(ent)) do
			if v ~= ent and not FPP.PlayerCanTouchEnt(attacker, v, "EntityDamage", "FPP_ENTITYDAMAGE") and not v.ShareDamage then
				dmginfo:SetDamage(0)
				return FPP.CanTouch(attacker, "FPP_ENTITYDAMAGE", ent.Owner, false)
			end
		end
	end
end
hook.Add("EntityTakeDamage", "FPP.Protect.EntityTakeDamage", FPP.Protect.EntityDamage)

--Toolgun
local allweapons = {"weapon_crowbar", "weapon_physgun", "weapon_physcannon", "weapon_pistol", "weapon_stunstick", "weapon_357", "weapon_smg1",
	"weapon_ar2", "weapon_shotgun", "weapon_crossbow", "weapon_frag", "weapon_rpg", "gmod_camera", "gmod_tool", "weapon_bugbait"} --for advanced duplicator, you can't use any IsWeapon...
for k,v in pairs(weapons.GetList()) do
	if v.ClassName then table.insert(allweapons, v.ClassName) end
end

function FPP.Protect.CanTool(ply, trace, tool)
	local ent = trace.Entity
	
	if tobool(FPP.Settings.FPP_TOOLGUN.toggle) then
		if ValidEntity(ent) and ent.ShareToolgun then return true end
		
		if ValidEntity(ent) and not FPP.PlayerCanTouchEnt(ply, ent, "Toolgun", "FPP_TOOLGUN") then
			return FPP.CanTouch(ply, "FPP_TOOLGUN", ent.Owner, false)
		end
		
		if ValidEntity(ent) and tobool(FPP.Settings.FPP_TOOLGUN.checkconstrained) then-- if we're ought to check the constraints
			for k,v in pairs(constraint.GetAllConstrainedEntities(ent)) do
				if v ~= ent and not FPP.PlayerCanTouchEnt(ply, v, "Toolgun", "FPP_TOOLGUN") and not v.ShareToolgun then
					return FPP.CanTouch(ply, "FPP_TOOLGUN", ent.Owner, false)
				end
			end
		end
	end

	if tool ~= "adv_duplicator" and tool ~= "duplicator" then return true end
	if tool == "adv_duplicator" and ply:GetActiveWeapon():GetToolObject().Entities then
		for k,v in pairs(ply:GetActiveWeapon():GetToolObject().Entities) do
			if tobool(FPP.Settings.FPP_TOOLGUN.duplicatenoweapons) then
				for c, d in pairs(allweapons) do
					if string.lower(v.Class) == string.lower(d) then
						ply:GetActiveWeapon():GetToolObject().Entities[k] = nil
					end
				end
			end
			if tobool(FPP.Settings.FPP_TOOLGUN.duplicatorprotect) then
				local setspawning = tobool(FPP.Settings.FPP_TOOLGUN.spawniswhitelist)
				for c, d in pairs(FPP.Blocked.Spawning) do
					if not tobool(FPP.Settings.FPP_TOOLGUN.spawniswhitelist) and string.find(v.Class, d) then
						ply:GetActiveWeapon():GetToolObject().Entities[k] = nil
						break
					end
					if tobool(FPP.Settings.FPP_TOOLGUN.spawniswhitelist) and string.find(v.Class, d) then -- if the whitelist is on you can't spawn it unless it's found
						setspawning = false
						break
					end
				end
				if setspawning then
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
						ply:UniqueIDTable( "Duplicator" ).Entities[k] = nil
					end
				end
			end
			if tobool(FPP.Settings.FPP_TOOLGUN.duplicatorprotect) then
				local setspawning = tobool(FPP.Settings.FPP_TOOLGUN.spawniswhitelist)
				for c, d in pairs(FPP.Blocked.Spawning) do
					if not tobool(FPP.Settings.FPP_TOOLGUN.spawniswhitelist) and string.find(v.Class, d) then
						ply:UniqueIDTable( "Duplicator" ).Entities[k] = nil
						break
					end
					if tobool(FPP.Settings.FPP_TOOLGUN.spawniswhitelist) and string.find(v.Class, d) then -- if the whitelist is on you can't spawn it unless it's found
						setspawning = false
						break
					end
				end
				if setspawning then
					ply:UniqueIDTable( "Duplicator" ).Entities[k] = nil
				end
			end
		end
	end
end
hook.Add("CanTool", "FPP.Protect.CanTool", FPP.Protect.CanTool)

--Player disconnect, not part of the Protect table.
function FPP.PlayerDisconnect(ply)
	if tobool(FPP.Settings.FPP_GLOBALSETTINGS.cleanupdisconnected) and FPP.Settings.FPP_GLOBALSETTINGS.cleanupdisconnectedtime then
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
	ply:SetNWString("SteamID", ply:SteamID())--Hacky way to get the steam ID clientside, just because Garry refuses to make it shared
	local RP = RecipientFilter()
	
	timer.Simple(1, function(ply)
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
end
hook.Add("PlayerInitialSpawn", "FPP.PlayerInitialSpawn", FPP.PlayerInitialSpawn)