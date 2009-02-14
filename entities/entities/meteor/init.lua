AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	self.Entity:SetModel("models/props_junk/Rock001a.mdl")
	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
	self.Entity:SetSolid(SOLID_VPHYSICS)
	self.Entity:Ignite(20,0)
	local phys = self.Entity:GetPhysicsObject()
	if phys and phys:IsValid() then
		phys:Wake()
	end

	self.Entity:GetPhysicsObject():EnableMotion(true)
	self.Entity:GetPhysicsObject():SetMass(1000)
	self.Entity:GetPhysicsObject():EnableGravity(false)
end

function ENT:findSky(ply)
	local foundSky = util.IsInWorld(ply:GetPos())
	local zPos = ply:GetPos().z

	while fountSky == true do
		zPos = zPos + 100
		foundSky = util.IsInWorld(Vector(ply:GetPos().x ,ply:GetPos().y ,zPos))
		print("My Z: " .. ply.GeyPos().z .. " -- zPos: " .. zPos .. " -- Is in world: " .. foundSky)
	end

	return zPos - 20
end


function ENT:SetTarget(ent)
	local foundSky = util.IsInWorld(ent:GetPos())
	local zPos = ent:GetPos().z

	for a = 1, 30, 1 do
		zPos = zPos + 100
		foundSky = util.IsInWorld(Vector(ent:GetPos().x ,ent:GetPos().y ,zPos))
		if (foundSky == false) then
			zPos = zPos - 120
			break
		end
	end

	self.Entity:SetPos(Vector(ent:GetPos().x + math.random(-4000,4000),ent:GetPos().y + math.random(-4000,4000), zPos))
	local speed = 100000000
	local VNormal = (Vector(ent:GetPos().x + math.random(-500,500),ent:GetPos().y + math.random(-500,500),ent:GetPos().z) - self.Entity:GetPos()):GetNormal()
	meteor:GetPhysicsObject():ApplyForceCenter(VNormal * speed)
end

function ENT:Destruct()
	util.BlastDamage(self.Entity, self.Entity, self.Entity:GetPos(), 200, 60)

	local vPoint = self.Entity:GetPos()
	local effectdata = EffectData()
	effectdata:SetStart(vPoint)
	effectdata:SetOrigin(vPoint)
	effectdata:SetScale(1)
	util.Effect("Explosion", effectdata)
end

function ENT:Destruct2()
	local vPoint = self.Entity:GetPos()
	local effectdata = EffectData()
	effectdata:SetStart(vPoint)
	effectdata:SetOrigin(vPoint)
	effectdata:SetScale(10)
	util.Effect("Explosion", effectdata)
end

function ENT:OnTakeDamage(dmg)
	if (dmg:GetDamage() > 5) then
		self.Entity:Destruct2()
		self.Entity:Remove()
	end
end

function ENT:PhysicsCollide(data, physobj)
	self.Entity:Destruct()
	self.Entity:Remove()
end
