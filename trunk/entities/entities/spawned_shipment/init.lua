-- ========================
-- =          Crate SENT by Mahalis
-- ========================

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

ShipmentWeaponClasses["ak47"] = {}
ShipmentWeaponClasses["ak47"]["weapon_ak472"] = "models/weapons/w_rif_ak47.mdl"
ShipmentWeaponClasses["mp5"] = {}
ShipmentWeaponClasses["mp5"]["weapon_mp52"] = "models/weapons/w_smg_mp5.mdl"
ShipmentWeaponClasses["m16"] = {}
ShipmentWeaponClasses["m16"]["weapon_m42"] = "models/weapons/w_rif_m4a1.mdl"
ShipmentWeaponClasses["mac10"] = {}
ShipmentWeaponClasses["mac10"]["weapon_mac102"] = "models/weapons/w_smg_mac10.mdl"
ShipmentWeaponClasses["shotgun"] = {}
ShipmentWeaponClasses["shotgun"]["weapon_pumpshotgun2"] = "models/weapons/w_shot_m3super90.mdl"
ShipmentWeaponClasses["sniper"] = {}
ShipmentWeaponClasses["sniper"]["ls_sniper"] = "models/weapons/w_snip_g3sg1.mdl"

function ENT:Initialize()
	self.Entity.Destructed = false
	self.Entity:SetModel("models/Items/item_item_crate.mdl")
	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
	self.Entity:SetSolid(SOLID_VPHYSICS)
	self.Entity:SetNWBool("shipment", true)
	self.locked = false
	self.damage = 100
	self.Entity.ShareGravgun = true
	local phys = self.Entity:GetPhysicsObject()
	if phys and phys:IsValid() then phys:Wake() end
end

function ENT:OnTakeDamage(dmg)
	self.damage = self.damage - dmg:GetDamage()
	if self.damage <= 0 then
		self.Entity:Destruct()
	end
end

function ENT:SetContents(s, c, w)
	self.Entity:SetNWString("contents", s)
	self.Entity:SetNWInt("count", c)
end

function ENT:Use()
	if not self.locked then
		self.locked = true -- One activation per second
		self.sparking = true
		timer.Create(self.Entity:EntIndex() .. "crate", 1, 1, self.SpawnItem, self)
	end
end

function ENT:SpawnItem()
	if not ValidEntity(self.Entity) then return end
	timer.Destroy(self.Entity:EntIndex() .. "crate")
	self.sparking = false
	local count = self.Entity:GetNWInt("count")
	local pos = self:GetPos()
	if count <= 1 then self.Entity:Remove() end
	local contents = self.Entity:GetNWString("contents")
	local weapon = ents.Create("spawned_weapon")
	if not ShipmentWeaponClasses[contents] then return end
	for ent, mdl in pairs(ShipmentWeaponClasses[contents]) do
		weapon.weaponclass = ent
		weapon:SetModel(mdl)
	end
	weapon.ShareGravgun = true
	weapon:SetPos(pos + Vector(0,0,35))
	weapon.nodupe = true
	weapon:Spawn()
	count = count - 1
	self.Entity:SetNWInt("count", count)
	self.locked = false
end

function ENT:Think()
	if self.sparking then
		local effectdata = EffectData()
		effectdata:SetOrigin(self.Entity:GetPos())
		effectdata:SetMagnitude(1)
		effectdata:SetScale(1)
		effectdata:SetRadius(2)
		util.Effect("Sparks", effectdata)
	end
end


function ENT:Destruct()
	if self.Entity.Destructed then return end
	self.Entity.Destructed = true
	local vPoint = self.Entity:GetPos()
	local contents = self.Entity:GetNWString("contents")
	local count = self.Entity:GetNWInt("count")
	local class = nil
	local model = nil
	
	for k, v in pairs(ShipmentWeaponClasses) do
		if k == contents then
			for cls, mdl in pairs(v) do
				class = cls
				model = mdl
			end
		end
	end
	
	for i=1, count, 1 do
		local weapon = ents.Create("spawned_weapon")
		weapon:SetModel(model)
		weapon.weaponclass = class
		weapon.ShareGravgun = true
		weapon:SetPos(Vector(vPoint.x, vPoint.y, vPoint.z + (i*5)))
		weapon.nodupe = true
		weapon:Spawn()
	end
	self.Entity:Remove()
end
