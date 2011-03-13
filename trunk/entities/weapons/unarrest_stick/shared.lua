if SERVER then
	AddCSLuaFile("shared.lua")
end

if CLIENT then
	SWEP.PrintName = "Unarrest Baton"
	SWEP.Slot = 1
	SWEP.SlotPos = 3
	SWEP.DrawAmmo = false
	SWEP.DrawCrosshair = false
end

SWEP.Base = "weapon_cs_base2"

SWEP.Author = "Rick Darkaliono, philxyz"
SWEP.Instructions = "Left or right click to unarrest"
SWEP.Contact = ""
SWEP.Purpose = ""
SWEP.IconLetter = ""

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
end

function SWEP:PrimaryAttack()
	if CurTime() < self.NextStrike then return end
	
	self.Owner:SetAnimation(PLAYER_ATTACK1)
	self.Weapon:EmitSound(self.Sound)
	self.Weapon:SendWeaponAnim(ACT_VM_HITCENTER)

	self.NextStrike = CurTime() + .4
	
	if CLIENT then return end
	
	self:SendHoldType("melee")
	timer.Simple(0.3, function(wep) if wep:IsValid() then wep:SendHoldType("normal") end end, self)

	local trace = self.Owner:GetEyeTrace()

	if not ValidEntity(trace.Entity) or not trace.Entity:IsPlayer() or (self.Owner:EyePos():Distance(trace.Entity:GetPos()) > 115) or not trace.Entity.DarkRPVars.Arrested then
		return
	end

	trace.Entity:Unarrest()
	Notify(trace.Entity, 0, 4, "You were unarrested by " .. self.Owner:Nick())
	
	if self.Owner.SteamName then
		DB.Log(self.Owner:SteamName().." ("..self.Owner:SteamID()..") unarrested "..trace.Entity:Nick())
	end
end

function SWEP:SecondaryAttack()
	self:PrimaryAttack()
end
