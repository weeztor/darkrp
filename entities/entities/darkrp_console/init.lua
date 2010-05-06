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
		Notify(ply, 1, 4, "You're not a cop")
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