-- =======================
-- =          Crate SENT by Mahalis
-- =======================

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/props_combine/combine_mine01.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	local phys = self:GetPhysicsObject()
	if phys and phys:IsValid() then phys:Wake() end
	timer.Create(self, 60, 0, self.giveMoney, self)
	self:SetNWBool("sparking",false)
	self:SetNWInt("damage",100)
	local ply = self:GetNWEntity("owning_ent")
	self:SetNetworkedString("Owner", ply:Nick())
	ply:SetNWInt("maxDrug",ply:GetNWInt("maxDrug") + 1)
end

function ENT:OnTakeDamage(dmg)
	self:SetNWInt("damage", self:GetNWInt("damage") - dmg:GetDamage())
	if (self:GetNWInt("damage") <= 0) then
		self:Destruct()
		self:Remove()
	end
end

function ENT:giveMoney()
	local ply = self:GetNWEntity("owning_ent")
	if ValidEntity(ply) then
		if ply:Alive() and not RPArrestedPlayers[ply:SteamID()] then
			ply:AddMoney(GetGlobalInt("drugpayamount"))
			Notify(ply, 1, 3, "Paid " .. CUR .. GetGlobalInt("drugpayamount") .. " for selling drugs.")
		end
	else
		self:Remove()
	end
end

function ENT:Destruct()
	local vPoint = self:GetPos()
	local effectdata = EffectData()
	effectdata:SetStart(vPoint)
	effectdata:SetOrigin(vPoint)
	effectdata:SetScale(1)
	util.Effect("Explosion", effectdata)
end

function ENT:Use(activator,caller)
	self:SetNWEntity("drug_user", activator)
	if (activator:GetNWInt("maxDrugs") >= CfgVars["maxdrugs"]) then
		Notify(activator, 1, 3, "Reached Max Drugs")
	else
		self:SetNWBool("sparking",true)
		timer.Create(self:EntIndex() .. "drug", 1, 1, self.createDrug, self)
	end
end

function ENT:createDrug()
	local userb = self:GetNWEntity("drug_user")
	local drugPos = self:GetPos()
	drug = ents.Create("drug")
	drug:SetPos(Vector(drugPos.x,drugPos.y,drugPos.z + 10))
	drug:SetNWEntity("owning_ent", userb)
	drug:SetNWString("Owner", "Shared")
	drug.nodupe = true
	drug:Spawn()
	userb:SetNWInt("maxDrugs",userb:GetNWInt("maxDrugs") + 1)
	self:SetNWBool("sparking",false)
end

function ENT:Think()
	if (self:GetNWBool("sparking") == true) then
		local effectdata = EffectData()
		effectdata:SetOrigin(self:GetPos())
		effectdata:SetMagnitude(1)
		effectdata:SetScale(1)
		effectdata:SetRadius(2)
		util.Effect("Sparks", effectdata)
	end
end

function ENT:OnRemove()
	timer.Destroy(self)
	local ply = self:GetNWEntity("owning_ent")
	if ValidEntity(ply) then ply:SetNWInt("maxDrug",ply:GetNWInt("maxDrug") - 1) end
end