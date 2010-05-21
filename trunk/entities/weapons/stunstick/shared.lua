if SERVER then
	AddCSLuaFile("shared.lua")
end

if CLIENT then
	SWEP.PrintName = "Stun Stick"
	SWEP.Slot = 0
	SWEP.SlotPos = 5
	SWEP.DrawAmmo = false
	SWEP.DrawCrosshair = false
end

SWEP.Author = "Rick Darkaliono, philxyz"
SWEP.Instructions = "Left click to discipline, right click to kill"
SWEP.Contact = ""
SWEP.Purpose = ""

SWEP.ViewModelFOV = 62
SWEP.ViewModelFlip = false
SWEP.AnimPrefix = "stunstick"

SWEP.Spawnable = false
SWEP.AdminSpawnable = true

SWEP.NextStrike = 0

SWEP.ViewModel = Model("models/weapons/v_stunstick.mdl")
SWEP.WorldModel = Model("models/weapons/w_stunbaton.mdl")

SWEP.Sound = Sound("weapons/stunstick/stunstick_swing1.wav")

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = 0
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = ""

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = 0
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = ""

function SWEP:Initialize()
	self:SetWeaponHoldType("normal")

	self.Hit = {
		Sound("weapons/stunstick/stunstick_impact1.wav"),
		Sound("weapons/stunstick/stunstick_impact2.wav")
	}

	self.FleshHit = {
		Sound("weapons/stunstick/stunstick_fleshhit1.wav"),
		Sound("weapons/stunstick/stunstick_fleshhit2.wav")
	}
end

function SWEP:DoFlash(ply)
	umsg.Start("StunStickFlash", ply)
	umsg.End()
end

function SWEP:PrimaryAttack()
	if CurTime() < self.NextStrike then return end

	self:SetWeaponHoldType("melee")
	timer.Simple(0.3, function(wep) if wep:IsValid() then wep:SetWeaponHoldType("normal") end end, self)
		
	self.Owner:SetAnimation(PLAYER_ATTACK1)
	self.Weapon:EmitSound(self.Sound)
	self.Weapon:SendWeaponAnim(ACT_VM_HITCENTER)

	self.NextStrike = CurTime() + .3

	if CLIENT then return end

	local trace = self.Owner:GetEyeTrace()

	if not ValidEntity(trace.Entity) or (self.Owner:EyePos():Distance(trace.Entity:GetPos()) > 100) then return end

	if not trace.Entity:IsDoor() then
		trace.Entity:SetVelocity((trace.Entity:GetPos() - self.Owner:GetPos()) * 7)
	end

	if trace.Entity:IsPlayer() or trace.Entity:IsNPC() then
		timer.Simple(.3, self.DoFlash, self, trace.Entity)
		self.Owner:EmitSound(self.FleshHit[math.random(1,#self.FleshHit)])
	else
		self.Owner:EmitSound(self.Hit[math.random(1,#self.Hit)])
		if FPP and FPP.PlayerCanTouchEnt(ply, self, "EntityDamage", "FPP_ENTITYDAMAGE") then
			trace.Entity:TakeDamage(1000, self.Owner, self) -- for illegal entities
		end
	end
end

function SWEP:SecondaryAttack()
	if CurTime() < self.NextStrike then return end

	self:SetWeaponHoldType("melee")
	timer.Simple(0.3, function(wep) if wep:IsValid() then wep:SetWeaponHoldType("normal") end end, self)
	self.Owner:SetAnimation(PLAYER_ATTACK1)
	self.Weapon:EmitSound(self.Sound)
	self.Weapon:SendWeaponAnim(ACT_VM_HITCENTER)

	self.NextStrike = CurTime() + .3

	if CLIENT then return end

	local trace = self.Owner:GetEyeTrace()

	if (not ValidEntity(trace.Entity) or (self.Owner:EyePos():Distance(trace.Entity:GetPos()) > 100)) then return end

	if SERVER then
		if not trace.Entity:IsDoor() then
			trace.Entity:SetVelocity((trace.Entity:GetPos() - self.Owner:GetPos()) * 7)
		end
		
		trace.Entity:TakeDamage(10, self.Owner, self)
		
		if trace.Entity:IsPlayer() then
			timer.Simple(.3, self.DoFlash, self, trace.Entity)
			self.Owner:EmitSound(self.FleshHit[math.random(1,#self.FleshHit)])
		elseif trace.Entity:IsNPC() then
			self.Owner:EmitSound(self.FleshHit[math.random(1,#self.FleshHit)])
		else
			self.Owner:EmitSound(self.Hit[math.random(1,#self.Hit)])
			if FPP and FPP.PlayerCanTouchEnt(ply, self, "EntityDamage", "FPP_ENTITYDAMAGE") then
				trace.Entity:TakeDamage(990, self.Owner, self)
			end
		end
	end
end
