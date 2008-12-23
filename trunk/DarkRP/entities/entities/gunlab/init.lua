-- =======================
-- =          Crate SENT by Mahalis
-- =======================

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	self.Entity:SetModel("models/props_c17/TrapPropeller_Engine.mdl")
	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
	self.Entity:SetSolid(SOLID_VPHYSICS)
	local phys = self.Entity:GetPhysicsObject()

	if phys and phys:IsValid() then phys:Wake() end

	self.Entity:SetNWBool("sparking",false)
	self.Entity:SetNWInt("damage",100)
	local ply = self.Entity:GetNWEntity("owning_ent")
	ply:SetNWInt("maxgunlabs",ply:GetNWInt("maxgunlabs") + 1)
end

function ENT:OnTakeDamage(dmg)
	self.Entity:SetNWInt("damage",self.Entity:GetNWInt("damage") - dmg:GetDamage())
	if (self.Entity:GetNWInt("damage") <= 0) then
		self.Entity:Destruct()
		self.Entity:Remove()
	end
end

function ENT:Destruct()
	local vPoint = self.Entity:GetPos()
	local effectdata = EffectData()
	effectdata:SetStart(vPoint)
	effectdata:SetOrigin(vPoint)
	effectdata:SetScale(1)
	util.Effect("Explosion", effectdata)
end

function ENT:SalePrice(activator)
	local owner = self.Entity:GetNWEntity("owning_ent")
	local discounted = math.ceil(GetGlobalInt("p228cost") * 0.88)

	if activator == owner then
		if activator:Team() == TEAM_GUN then
			return discounted
		else
			return math.floor(GetGlobalInt("p228cost"))
		end
	else
		return self:GetNWInt("price")
	end
end

ENT.Once = false
function ENT:Use(activator)
	local owner = self.Entity:GetNWEntity("owning_ent")
	local discounted = math.ceil(GetGlobalInt("p228cost") * 0.88)
	local cash = self:SalePrice(activator)
	
	self.Entity:SetNWEntity("user", activator)
	if not activator:CanAfford(self:SalePrice(activator)) then
		Notify(activator, 1, 3, "Can not afford this!")
		return ""
	end
	local diff = (self:SalePrice(activator) - self:SalePrice(owner))
	if diff < 0 and not owner:CanAfford(math.abs(diff)) then
		Notify(activator, 1, 3, "Gun Lab owner is too poor to subsidize this sale!")
		return ""
	end
	self.Entity:SetNWBool("sparking", true)
	
	if not self.Once then
		self.Once = true
		activator:AddMoney(cash * -1)
		Notify(activator, 1, 3, "You bought a P228 for " .. CUR .. tostring(cash) .. "!")
		
		if activator ~= owner then
			local gain = 0
			if owner:Team() == TEAM_GUN then
				gain = math.floor(self:GetNWInt("price") - discounted)
			else
				gain = math.floor(self:GetNWInt("price") - GetGlobalInt("p228cost"))
			end
			if gain == 0 then
				Notify(owner, 1, 3, "You sold a P228 but made no profit!")
			else
				owner:AddMoney(gain)
				local word = "profit"
				if gain < 0 then word = "loss" end
				Notify(owner, 1, 3, "You made a " .. word .. " of " .. CUR .. tostring(math.abs(gain)) .. " by selling a P228 from a Gun Lab!")
			end
		end
	end
	timer.Create(self.Entity:EntIndex() .. "spawned_weapon", 1, 1, self.createGun, self)
end

function ENT:createGun()
	self.Once = false
	local gun = ents.Create("spawned_weapon")
	gun = ents.Create("spawned_weapon")
	gun:SetModel("models/weapons/w_pist_p228.mdl")
	gun:SetNWString("weaponclass", "weapon_p2282")
	local gunPos = self.Entity:GetPos()
	gun:SetPos(Vector(gunPos.x, gunPos.y, gunPos.z + 27))
	gun:SetNetworkedString("Owner", "Shared")
	gun.nodupe = true
	gun:Spawn()
	self.Entity:SetNWBool("sparking", false)
end

function ENT:Think()
	if (self.Entity:GetNWBool("sparking") == true) then
		local effectdata = EffectData()
		effectdata:SetOrigin(self.Entity:GetPos())
		effectdata:SetMagnitude(1)
		effectdata:SetScale(1)
		effectdata:SetRadius(2)
		util.Effect("Sparks", effectdata)
	end
end

function ENT:OnRemove()
	timer.Destroy(self.Entity)
	local ply = self.Entity:GetNWEntity("owning_ent")
	ply:SetNWInt("maxgunlabs",ply:GetNWInt("maxgunlabs") - 1)
end