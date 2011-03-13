AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/props_wasteland/controlroom_monitor001b.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	
	self:SetUseType(SIMPLE_USE)
	
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then 
		phys:Wake() 
		phys:EnableMotion(false) 
	end
end

function ENT:OnTakeDamage(dmg)
	--Entity can't be damaged.
	return false
end

function ENT:Use(activator, caller)
	if activator:IsCP() and ValidEntity(self.dt.reporter) then
		local memory = math.random(60, 125)
		umsg.Start("darkrp_memory", activator)
			umsg.Entity(self)
			umsg.Bool(true)
			umsg.Short(memory)
		umsg.End()
	elseif not activator:IsCP() then
		Notify(activator, 1, 4, "You're not a cop")
	end
end

function ENT:Alarm()
	self.Sound = CreateSound(self, "ambient/alarms/alarm_citizen_loop1.wav")
	self.Sound:Play()
	
	self.dt.alarm = true
	timer.Simple(30, function()
		if self.Sound then self.Sound:Stop() end
		self.dt.alarm = false
		self.dt.reporter = 1
	end)
end

function ENT:PhysgunPickup(ply, ent)
	return ply:IsSuperAdmin()
end

local timeout = 0
function ENT:OnPhysgunFreeze(weapon, phys, ent, ply)
	if CurTime() - timeout < 0.5 then return end
	timeout = CurTime()
	if ply:IsSuperAdmin() then
		local pos = self:GetPos()
		local ang = self:GetAngles()
		
		local map, x, y, z, pitch, yaw, roll = 
			string.lower(game.GetMap()),
			pos.x, pos.y, pos.z,
			ang.p, ang.y, ang.r
			
		DB.Query("SELECT id FROM darkrp_consolespawns WHERE map = " .. sql.SQLStr(map) .. ";", function(data)
			if data then
				for k,v in pairs(data) do
					if tonumber(v.id) == tonumber(self.ID) then
						DB.Query([[UPDATE darkrp_consolespawns SET ]]
						.. "x = " .. SQLStr(x)..", "
						.. "y = " .. SQLStr(y)..", "
						.. "z = " .. SQLStr(z)..", "
						.. "pitch = " .. SQLStr(pitch)..", "
						.. "yaw = " .. SQLStr(yaw)..", "
						.. "roll = " .. SQLStr(roll)
						.. " WHERE id = "..v.id..";")
						
						Notify(ply, 0, 4, "CP console position updated!")
						return
					end
				end
			end
			
			local ID = 0
			local found = false
			for k,v in SortedPairs(data or {}) do
				if k == ID + 1 then
					ID = k
					found = true
				else
					ID = ID + 1
					found = false
					break
				end
			end
			if found or ID == 0 then ID = ID + 1 end
			DB.Query([[INSERT INTO darkrp_consolespawns VALUES(]].. (self.ID or ID) .. [[, ]]
			.. SQLStr(map)..", "
			.. SQLStr(x)..", "
			.. SQLStr(y)..", "
			.. SQLStr(z)..", "
			.. SQLStr(pitch)..", "
			.. SQLStr(yaw)..", "
			.. SQLStr(roll)
			.. ");")
			Notify(ply, 0, 4, "CP console position created!")
		end)
	end
end

function ENT:CanTool(ply, trace, tool, ENT)
	if ply:IsSuperAdmin() and tool == "remover" then
		self.CanRemove = true
		DB.Query("DELETE FROM darkrp_consolespawns WHERE id = "..self.ID..";") -- Remove from database if it's there
		Notify(ply, 0, 4, "CP console successfully removed!")
		return true
	end
	return false
end