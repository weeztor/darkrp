AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
	//self.Entity:SetModel("models/props_junk/glassjug01.mdl")
	self.Entity:SetModel("models/props_lab/jar01a.mdl") 
	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
	self.Entity:SetSolid(SOLID_VPHYSICS)
	self.CanUse = true
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
	if not self.CanUse then return false end
	local Owner = self:GetNWEntity("owning_ent")
	//print(Owner, activator, caller)
	if activator ~= Owner then
		if not activator:CanAfford(self:GetNWInt("price")) then
			return false
		end
		DB.PayPlayer(activator, Owner, self:GetNWInt("price"))
		Notify(activator, 1, 4, "You have paid " .. CUR .. self:GetNWInt("price") .. " for using drugs.")
		Notify(Owner, 1, 4, "Recieved " .. CUR .. self:GetNWInt("price") .. " for selling drugs.")
	end
	DrugPlayer(caller)
	self.CanUse = false
	self.Entity:Remove()
end

function ENT:OnRemove()
	local ply = self.Entity:GetNWEntity("owning_ent")
	ply:SetNWInt("maxDrugs",ply:GetNWInt("maxDrugs") - 1)
end