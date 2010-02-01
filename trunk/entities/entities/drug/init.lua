AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
	self.Entity:SetModel("models/props_lab/jar01a.mdl") 
	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
	self.Entity:SetSolid(SOLID_VPHYSICS)
	self.CanUse = true
	local phys = self.Entity:GetPhysicsObject()

	if phys and phys:IsValid() then phys:Wake() end

	self.damage = 10
	self.dt.price = self.dt.price or 100
end



function ENT:OnTakeDamage(dmg)
	self.damage = self.damage - dmg:GetDamage()

	if (self.damage <= 0) then
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
	if not self.CanUse then return false end
	local Owner = self.dt.owning_ent
	if activator ~= Owner then
		if not activator:CanAfford(self.dt.price) then
			return false
		end
		DB.PayPlayer(activator, Owner, self.dt.price)
		Notify(activator, 1, 4, "You have paid " .. CUR .. self.dt.price .. " for using drugs.")
		Notify(Owner, 1, 4, "You have received " .. CUR .. self.dt.price .. " for selling drugs.")
	end
	DrugPlayer(caller)
	self.CanUse = false
	self.Entity:Remove()
end

function ENT:OnRemove()
	local ply = self.dt.owning_ent
	if not ValidEntity(ply) then return end
	ply.maxDrugs = ply.maxDrugs - 1
end