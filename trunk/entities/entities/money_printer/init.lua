-- RRPX Money Printer reworked for DarkRP by philxyz
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/props_c17/consolebox01a.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then phys:Wake() end
	self:SetNWBool("money_printer", true)
	self.sparking = false
	self.damage = 100
	self.IsMoneyPrinter = true
	local ply = self:GetNWEntity("owning_ent")
	if not ply.maxmprinters then
		ply.maxmprinters = 0
	end
	ply.maxmprinters = ply.maxmprinters + 1
	timer.Simple(30, self.CreateMoneybag, self)
end

function ENT:OnTakeDamage(dmg)
	if self.burningup then return end

	self.damage = self.damage - dmg:GetDamage()
	if self.damage <= 0 then
		local rnd = math.random(1, 10)
		if rnd < 3 then
			self:BurstIntoFlames()
		else
			self:Destruct()
			self:Remove()
		end
	end
end

function ENT:Destruct()
	local vPoint = self:GetPos()
	local effectdata = EffectData()
	effectdata:SetStart(vPoint)
	effectdata:SetOrigin(vPoint)
	effectdata:SetScale(1)
	util.Effect("Explosion", effectdata)
	Notify(self:GetNWEntity("owning_ent"), 1, 4, "Your money printer has exploded!")
end

function ENT:BurstIntoFlames()
	Notify(self:GetNWEntity("owning_ent"), 1, 4, "Your money printer is overheating!")
	self.burningup = true
	local burntime = math.random(8, 18)
	self:Ignite(burntime, 0)
	timer.Simple(burntime, self.Fireball, self)
end

function ENT:Fireball()
	local dist = math.random(20, 280) -- Explosion radius
	self:Destruct()
	for k, v in pairs(ents.FindInSphere(self:GetPos(), dist)) do
		if not v:IsPlayer() and not v.IsMoneyPrinter then v:Ignite(math.random(5, 22), 0) end
	end
	self:Remove()
end

local function PrintMore(ent)
	if ValidEntity(ent) then
		ent.sparking = true
		timer.Simple(3, ent.CreateMoneybag, ent)
	end
end

function ENT:CreateMoneybag()
	if not ValidEntity(self) then return end
	if self:IsOnFire() then return end
	local MoneyPos = self:GetPos()

	if math.random(1, 22) == 3 then self:BurstIntoFlames() end
	local moneybag = ents.Create("prop_physics")
	moneybag:SetModel("models/props/cs_assault/money.mdl")
	moneybag:SetNWString("Owner", "Shared")
	moneybag:SetPos(Vector(MoneyPos.x + 15, MoneyPos.y, MoneyPos.z + 15))
	moneybag.nodupe = true
	moneybag:Spawn()
	moneybag:GetTable().MoneyBag = true
	local amount = GetGlobalInt("mprintamount")
	if amount == 0 then
		amount = 250
	end
	moneybag:GetTable().Amount = amount
	self.sparking = false
	timer.Simple(math.random(100, 350), PrintMore, self)
end

function ENT:Think()
	if not self.sparking then return end

	local effectdata = EffectData()
	effectdata:SetOrigin(self:GetPos())
	effectdata:SetMagnitude(1)
	effectdata:SetScale(1)
	effectdata:SetRadius(2)
	util.Effect("Sparks", effectdata)
end

function ENT:OnRemove()
	local ply = self:GetNWEntity("owning_ent")
	if not ValidEntity(ply) then return end
	if not ply.maxmprinters then
		ply.maxmprinters = 0
		return
	end
	ply.maxmprinters = ply.maxmprinters - 1
end
