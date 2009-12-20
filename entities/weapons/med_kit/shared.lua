if (SERVER) then
	AddCSLuaFile("shared.lua")
end

SWEP.PrintName = "Medic Kit"
SWEP.Author = "Jake Johnson"
SWEP.Slot = 4
SWEP.SlotPos = 3
SWEP.Description = "Heals the wounded."
SWEP.Contact = ""
SWEP.Purpose = ""
SWEP.Instructions = "Left Click to heal player infront of user."

SWEP.Spawnable = true       -- Change to false to make Admin only.
SWEP.AdminSpawnable = true

SWEP.ViewModel = "models/weapons/v_c4.mdl"
SWEP.WorldModel = "models/weapons/w_package.mdl"

SWEP.Primary.Recoil = 0
SWEP.Primary.ClipSize  = -1
SWEP.Primary.DefaultClip = 1
SWEP.Primary.Automatic  = true
SWEP.Primary.Delay = 0.1
SWEP.Primary.Ammo = "none"

SWEP.Secondary.Recoil = 0
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = 1
SWEP.Secondary.Automatic = true
SWEP.Secondary.Delay = 0.3
SWEP.Secondary.Ammo = "none"

function SWEP:PrimaryAttack()
	self.Weapon:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
	trace = {}
	trace.start = self.Owner:GetShootPos()
	trace.endpos = trace.start + (self.Owner:GetAimVector() * 85)
	trace.filter = { self.Owner, self.Weapon }
	tr = util.TraceLine(trace)

	if (tr.HitNonWorld) and SERVER then
		local enthit = tr.Entity
		local maxhealth = enthit.StartHealth or 100
		if enthit:IsPlayer() and enthit:Health() < maxhealth then
			enthit:SetHealth(enthit:Health() + 1)
			self.Owner:EmitSound("hl1/fvox/boop.wav", 150, enthit:Health())
		end
	end
end

function SWEP:SecondaryAttack()
	self.Weapon:SetNextSecondaryFire(CurTime() + self.Secondary.Delay)
	local maxhealth = self.Owner.StartHealth or 100
	if self.Owner:Health() < maxhealth and SERVER then
		self.Owner:SetHealth(self.Owner:Health() + 1)
		self.Owner:EmitSound("hl1/fvox/boop.wav", 150, self.Owner:Health())
	end
end