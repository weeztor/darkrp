AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	self.Entity:SetModel("models/props_junk/garbage_takeoutcarton001a.mdl")
	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
	self.Entity:SetSolid(SOLID_VPHYSICS)
	local phys = self.Entity:GetPhysicsObject()

	if phys and phys:IsValid() then phys:Wake() end

	self.Entity:SetNWInt("damage",10)
end

function ENT:OnTakeDamage(dmg)
	self.Entity:SetNWInt("damage",self.Entity:GetNWInt("damage") - dmg:GetDamage())

	if (self.Entity:GetNWInt("damage") <= 0) then
		local effectdata = EffectData()
		effectdata:SetOrigin(self.Entity:GetPos())
		effectdata:SetMagnitude(2)
		effectdata:SetScale(2)
		effectdata:SetRadius(3)
		util.Effect("Sparks", effectdata)
		self.Entity:Remove()
	end
end

function ENT:Use(activator,caller)
	PooPee.AteFood(caller, "models/props_junk/garbage_takeoutcarton001a.mdl")
	FoodHeal(caller, 100)
	self.Entity:Remove()
end

function ENT:OnRemove()
	local ply = self.Entity:GetNWEntity("owning_ent")
	ply:SetNWInt("maxFoods",ply:GetNWInt("maxFoods") - 1)
end