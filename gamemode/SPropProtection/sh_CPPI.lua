------------------------------------
--	Simple Prop Protection
--	By Spacetech
------------------------------------
CPPI = {}
CPPI_NOTIMPLEMENTED = 26
CPPI_DEFER = 16

function CPPI:GetName()
	return "Simple RP Prop Protection"
end

function CPPI:GetVersion()
	return SPropProtection.Version
end

function CPPI:GetInterfaceVersion()
	return 1.1
end

function CPPI:GetNameFromUID(uid)
	return CPPI_NOTIMPLEMENTED
end

local Player = FindMetaTable("Player")
if not Player then
	print("EXTREME ERROR 1")
	return
end

function Player:CPPIGetFriends()
	if SERVER then
		local Table = {}
		for k, v in pairs(player.GetAll()) do
			if table.HasValue(SPropProtection[self:SteamID()], v:SteamID()) then
				table.insert(Table, v)
			end
		end
		return Table
	else
		return CPPI_NOTIMPLEMENTED
	end
end

local Entity = FindMetaTable("Entity")
if not Entity then
	print("EXTREME ERROR 2")
	return
end

function Entity:CPPIGetOwner()
	local Player = self:GetNWString("Owner")
	
	if SERVER then
		Player = SPropProtection["Props"][self:EntIndex()][3]
	end
	
	if not Player then
		return nil, CPPI_NOTIMPLEMENTED
	end
	
	local UID = CPPI_NOTIMPLEMENTED
	
	if SERVER then
		UID = Player
	end
	
	return Player, UID
end

if SERVER then
	function Entity:CPPISetOwner(ply)
		if not ply or not ply:IsValid() or not ply:IsPlayer() then
			return false
		end
		return SPropProtection.PlayerMakePropOwner(ply, self)
	end
	
	function Entity:CPPISetOwnerUID(uid)
		if not uid then
			return false
		end
		
		local ply = player.GetByUniqueID(tostring(uid))
		if not ply then
			return false
		end
		
		return SPropProtection.PlayerMakePropOwner(ply, self)
	end
	
	function Entity:CPPICanTool(ply, toolmode)
		if not ply or not ply:IsValid() or not ply:IsPlayer() or not toolmode then
			return false
		end
		return SPropProtection.PlayerCanTouch(ply, self)
	end
	
	function Entity:CPPICanPhysgun(ply)
		if not ply or not ply:IsValid() or not ply:IsPlayer() then
			return false
		end
		if SPropProtection.PhysGravGunPickup(ply, self) == false then
			return false
		end
		return true
	end
	
	function Entity:CPPICanPickup(ply)
		if not ply or not ply:IsValid() or not ply:IsPlayer() then
			return false
		end
		if SPropProtection.PhysGravGunPickup(ply, self) == false then
			return false
		end
		return true
	end
	
	function Entity:CPPICanPunt(ply)
		if not ply or not ply:IsValid() or not ply:IsPlayer() then
			return false
		end
		if SPropProtection.PhysGravGunPickup(ply, self) == false then
			return false
		end
		return true
	end
end

local function CPPIInitGM()
	function GAMEMODE:CPPIAssignOwnership(ply, ent)
	end
	function GAMEMODE:CPPIFriendsChanged(ply, ent)
	end
end
hook.Add("Initialize", "CPPIInitGM", CPPIInitGM)

AddToggleCommand("rp_spp_on", "spp_on", false)
AddToggleCommand("rp_spp_admin", "spp_admin", false)
AddToggleCommand("rp_spp_use", "spp_use", false)
AddToggleCommand("rp_spp_entdamage", "spp_entdamage", false)
AddToggleCommand("rp_spp_physreload", "spp_physreload", false)
AddToggleCommand("rp_spp_touchworldprops", "spp_touchworldprops", false)
AddToggleCommand("rp_spp_propdeletion", "spp_propdeletion", false)
AddToggleCommand("rp_spp_deleteadminents", "spp_deleteadminents", false)
AddValueCommand("rp_spp_deletedelay", "spp_deletedelay", false)

