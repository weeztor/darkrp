if (SERVER) then
	AddCSLuaFile("shared.lua")
end

if (CLIENT) then
	SWEP.PrintName = "Stunstick"
	SWEP.Slot = 0
	SWEP.SlotPos = 5
	SWEP.DrawAmmo = false
	SWEP.DrawCrosshair = false
end

-- Variables that are used on both client and server

SWEP.Author = "Rickster"
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

SWEP.Primary.ClipSize	 = -1       -- Size of a clip
SWEP.Primary.DefaultClip = 0     -- Default number of bullets in a clip
SWEP.Primary.Automatic = false      -- Automatic/Semi Auto
SWEP.Primary.Ammo = ""

SWEP.Secondary.ClipSize = -1        -- Size of a clip
SWEP.Secondary.DefaultClip = 0      -- Default number of bullets in a clip
SWEP.Secondary.Automatic = false        -- Automatic/Semi Auto
SWEP.Secondary.Ammo = ""

/*---------------------------------------------------------
Name: SWEP:Initialize()
Desc: Called when the weapon is first loaded
---------------------------------------------------------*/
function SWEP:Initialize()
	if (SERVER) then
		self:SetWeaponHoldType("melee")
	end

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

/*---------------------------------------------------------
Name: SWEP:PrimaryAttack()
Desc: +attack1 has been pressed
---------------------------------------------------------*/
function SWEP:PrimaryAttack()
	if (CurTime() < self.NextStrike) then return end

	self.Owner:SetAnimation(PLAYER_ATTACK1)
	self.Weapon:EmitSound(self.Sound)
	self.Weapon:SendWeaponAnim(ACT_VM_HITCENTER)
	self.NextStrike = (CurTime() + .3)

	if (CLIENT) then return end

	local trace = self.Owner:GetEyeTrace()

	if ((not ValidEntity(trace.Entity)) or (self.Owner:EyePos():Distance(trace.Entity:GetPos()) > 100)) then return end

	if (SERVER) then
		local hp = trace.Entity:Health()
		hp = hp - math.random(4, 8)

		if (hp <= 0) then hp = 1 end

		trace.Entity:SetHealth(hp)

		if (not trace.Entity:IsDoor()) then
			trace.Entity:SetVelocity((trace.Entity:GetPos() - self.Owner:GetPos()) * 7)
		end

		if (trace.Entity:IsPlayer()) then
			timer.Simple(.3, self.DoFlash, self, trace.Entity)
			self.Owner:EmitSound(self.FleshHit[math.random(1,#self.FleshHit)])
		else
			self.Owner:EmitSound(self.Hit[math.random(1,#self.Hit)])
		end
	end
end

/*---------------------------------------------------------
SecondaryAttack
---------------------------------------------------------*/
function SWEP:SecondaryAttack()
	if (CurTime() < self.NextStrike) then return end

	self.Owner:SetAnimation(PLAYER_ATTACK1)
	self.Weapon:EmitSound(self.Sound)
	self.Weapon:SendWeaponAnim(ACT_VM_HITCENTER)

	self.NextStrike = (CurTime() + .3)

	if (CLIENT) then return end

	local trace = self.Owner:GetEyeTrace()

	if ((not ValidEntity(trace.Entity)) or (self.Owner:EyePos():Distance(trace.Entity:GetPos()) > 100)) then return end

	if (SERVER) then
		trace.Entity:SetHealth(trace.Entity:Health() - math.random(4, 8))

		if (not trace.Entity:IsDoor()) then
			trace.Entity:SetVelocity((trace.Entity:GetPos() - self.Owner:GetPos()) * 7)
		end

		if (trace.Entity:IsPlayer()) then
			timer.Simple(.3, self.DoFlash, self, trace.Entity)
			self.Owner:EmitSound(self.FleshHit[math.random(1,#self.FleshHit)])
		else
			self.Owner:EmitSound(self.Hit[math.random(1,#self.Hit)])
		end
	end
end