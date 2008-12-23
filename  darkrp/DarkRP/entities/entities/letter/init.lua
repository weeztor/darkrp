AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	self.Entity:SetModel("models/props_c17/paper01.mdl")
	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
	self.Entity:SetSolid(SOLID_VPHYSICS)
	local phys = self.Entity:GetPhysicsObject()

	if phys and phys:IsValid() then phys:Wake() end
	local ply = self.Entity:GetNWEntity("owning_ent")
end

function ENT:OnRemove()
	local ply = self.Entity:GetNWEntity("owning_ent")
	ply:SetNWInt("maxletters", ply:GetNWInt("maxletters") - 1)
end
