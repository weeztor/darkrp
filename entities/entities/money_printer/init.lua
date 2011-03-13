-- RRPX Money Printer reworked for DarkRP by philxyz
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

local PrintMore
function ENT:Initialize()
	self:SetModel("models/props_c17/consolebox01a.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then phys:Wake() end
	self.sparking = false
	self.damage = 100
	self.IsMoneyPrinter = true
	timer.Simple(27, PrintMore, self)
end

function ENT:OnTakeDamage(dmg)
	if self.burningup then return end

	self.damage = (self.damage or 100) - dmg:GetDamage()
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
	Notify(self.dt.owning_ent, 1, 4, "Your money printer has exploded!")
end

function ENT:BurstIntoFlames()
	Notify(self.dt.owning_ent, 0, 4, "Your money printer is overheating!")
	self.burningup = true
	local burntime = math.random(8, 18)
	self:Ignite(burntime, 0)
	timer.Simple(burntime, self.Fireball, self)
end

function ENT:Fireball()
	if not self:IsOnFire() then self.burningup = false return end
	local dist = math.random(20, 280) -- Explosion radius
	self:Destruct()
	for k, v in pairs(ents.FindInSphere(self:GetPos(), dist)) do
		if not v:IsPlayer() and not v.IsMoneyPrinter then v:Ignite(math.random(5, 22), 0) end
	end
	self:Remove()
end

PrintMore = function(ent)
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
	
	local amount = GetConVarNumber("mprintamount")
	if amount == 0 then
		amount = 250
	end

	DarkRPCreateMoneyBag(Vector(MoneyPos.x + 15, MoneyPos.y, MoneyPos.z + 15), amount)
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
