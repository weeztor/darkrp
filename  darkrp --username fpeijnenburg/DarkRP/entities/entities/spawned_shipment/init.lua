-- ========================
-- =          Crate SENT by Mahalis
-- ========================

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

local weaponClasses = {}
weaponClasses["ak47"] = {}
weaponClasses["ak47"]["weapon_ak472"] = "models/weapons/w_rif_ak47.mdl"
weaponClasses["mp5"] = {}
weaponClasses["mp5"]["weapon_mp52"] = "models/weapons/w_smg_mp5.mdl"
weaponClasses["m16"] = {}
weaponClasses["m16"]["weapon_m42"] = "models/weapons/w_rif_m4a1.mdl"
weaponClasses["mac10"] = {}
weaponClasses["mac10"]["weapon_mac102"] = "models/weapons/w_smg_mac10.mdl"
weaponClasses["shotgun"] = {}
weaponClasses["shotgun"]["weapon_pumpshotgun2"] = "models/weapons/w_shot_m3super90.mdl"
weaponClasses["sniper"] = {}
weaponClasses["sniper"]["ls_sniper"] = "models/weapons/w_snip_g3sg1.mdl"

function ENT:Initialize()
	self.Entity:SetModel("models/Items/item_item_crate.mdl")
	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
	self.Entity:SetSolid(SOLID_VPHYSICS)
	self.Entity:SetNWBool("shipment", true)
	self.locked = false
	local phys = self.Entity:GetPhysicsObject()
	if phys and phys:IsValid() then phys:Wake() end
	self.Entity:SetNWInt("damage",100)
	self.Entity:SetNWString("Owner", "Shared")
end

function ENT:OnTakeDamage(dmg)
	self.Entity:SetNWInt("damage",self.Entity:GetNWInt("damage") - dmg:GetDamage())
	if self.Entity:GetNWInt("damage") <= 0 then
		self.Entity:Destruct()
	end
end

function ENT:SetContents(s, c, w)
	self.Entity:SetNWString("contents", s)
	self.Entity:SetNWInt("count", c)
	if w and w > 0 then
		local phys = self.Entity:GetPhysicsObject()
		if phys and phys:IsValid() then phys:SetMass(math.floor((((w * c) + 15)*100)+0.5)/100) end
	end
	self.Entity:SetNWFloat("itemWt", w)
end

function ENT:Use()
	if not self.locked then
		self.locked = true -- One activation per second
		self.Entity:SetNWBool("sparking",true)
		timer.Create(self.Entity:EntIndex() .. "crate", 1, 1, self.SpawnItem, self)
	end
end

function ENT:SpawnItem()
	timer.Destroy(self.Entity:EntIndex() .. "crate")
	self.Entity:SetNWBool("sparking",false)
	local count = self.Entity:GetNWInt("count")
	local pos = self:GetPos()
	if count <= 1 then self.Entity:Remove() end
	local contents = self.Entity:GetNWString("contents")
	local weapon = ents.Create("spawned_weapon")
	for ent, mdl in pairs(weaponClasses[contents]) do
		weapon:SetNWString("weaponclass", ent)
		weapon:SetModel(mdl)
	end
	weapon:SetNWString("Owner", "Shared")
	weapon:SetPos(pos + Vector(0,0,35))
	weapon.nodupe = true
	weapon:Spawn()
	count = count - 1
	self.Entity:SetNWInt("count", count)
	local newmass = math.floor((((count*self.Entity:GetNWFloat("itemWt")) + 15) * 100) + 0.5) / 100
	if newmass and newmass > 0 then
		local phys = self.Entity:GetPhysicsObject()
		if phys and phys:IsValid() then phys:SetMass(newmass) end
	end
	self.locked = false
end

function ENT:Think()
	if self.Entity:GetNWBool("sparking") then
		local effectdata = EffectData()
		effectdata:SetOrigin(self.Entity:GetPos())
		effectdata:SetMagnitude(1)
		effectdata:SetScale(1)
		effectdata:SetRadius(2)
		util.Effect("Sparks", effectdata)
	end
end

function ENT:Destruct()
	local vPoint = self.Entity:GetPos()
	local contents = self.Entity:GetNWString("contents")
	local count = self.Entity:GetNWInt("count")
	self.Entity:Remove()
	
	local class = nil
	local model = nil
	
	for k, v in pairs(weaponClasses) do
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
		weapon:SetNWString("weaponclass", class)
		weapon:SetNWString("Owner", "Shared")
		weapon:SetPos(Vector(vPoint.x, vPoint.y, vPoint.z + (i*5)))
		weapon.nodupe = true
		weapon:Spawn()
	end
end
