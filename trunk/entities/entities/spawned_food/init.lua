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

function ENT:OnTakeDamage(dmg)
	self.Entity:Remove()
end

function ENT:Use(activator,caller)
	activator:SetDarkRPVar("Energy", math.Clamp(activator.DarkRPVars.Energy + self.Entity:GetTable().FoodEnergy, 0, 100))
	umsg.Start("AteFoodIcon", activator)
	umsg.End()
	if PooPee then PooPee.AteFood(activator, self.Entity:GetModel()) end
	self.Entity:Remove()
	activator:EmitSound("vo/sandwicheat09.wav", 100, 100)
end
