AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
	self.Entity:SetSolid(SOLID_VPHYSICS)
	local phys = self.Entity:GetPhysicsObject()

	if phys and phys:IsValid() then phys:Wake() end
end


function ENT:Use(activator,caller)
	local class = self.Entity.weaponclass
	local weapon = ents.Create(class)

	if not weapon:IsValid() then return false end

	weapon:SetAngles(self.Entity:GetAngles())
	weapon:SetPos(self.Entity:GetPos())
	weapon.ShareGravgun = true
	weapon.nodupe = true
	weapon:Spawn()
	self.Entity:Remove()
end
