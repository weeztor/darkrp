AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
	self.Entity:SetSolid(SOLID_VPHYSICS)
	self.Entity:SetUseType(SIMPLE_USE)
	local phys = self.Entity:GetPhysicsObject()

	if phys and phys:IsValid() then phys:Wake() end
	self:SetCollisionGroup(COLLISION_GROUP_INTERACTIVE_DEBRIS)
end


function ENT:Use(activator, caller)
	local class = self.Entity.weaponclass
	local weapon = ents.Create(class)

	if not weapon:IsValid() then return false end

	local CanPickup = hook.Call("PlayerCanPickupWeapon", GAMEMODE, activator, weapon)
	weapon:Remove()
	if not CanPickup then return end

	activator:Give(class)
	weapon = activator:GetWeapon(class)

	weapon:SetClip1(self.clip1 or 0)
	weapon:SetClip2(self.clip2 or -1)
	activator:SetAmmo(self.ammo or 0, weapon:GetPrimaryAmmoType())

	self.Entity:Remove()
end
