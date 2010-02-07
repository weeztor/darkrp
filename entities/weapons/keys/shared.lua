if SERVER then
	AddCSLuaFile("shared.lua")
end

if CLIENT then
	SWEP.PrintName = "Keys"
	SWEP.Slot = 1
	SWEP.SlotPos = 3
	SWEP.DrawAmmo = false
	SWEP.DrawCrosshair = false
end

SWEP.Author = "Rick Darkaliono, philxyz"
SWEP.Instructions = "Left click to lock. Right click to unlock"
SWEP.Contact = ""
SWEP.Purpose = ""

SWEP.ViewModelFOV = 62
SWEP.ViewModelFlip = false
SWEP.AnimPrefix	 = "rpg"

SWEP.Spawnable = false
SWEP.AdminSpawnable = true
SWEP.Sound = "doors/door_latch3.wav"
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = 0
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = ""

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = 0
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = ""

if CLIENT then
	SWEP.FrameVisible = false
end

function SWEP:Initialize()
	if SERVER then self:SetWeaponHoldType("normal") end
end

function SWEP:Deploy()
	if SERVER then
		self.Owner:DrawViewModel(false)
		self.Owner:DrawWorldModel(false)
	end
end

function SWEP:PrimaryAttack()
	if CLIENT then return end

	local trace = self.Owner:GetEyeTrace()
	
	if not ValidEntity(trace.Entity) or not trace.Entity:IsOwnable() or (trace.Entity.DoorData and trace.Entity.DoorData.NonOwnable) then
		return
	end
	
	trace.Entity.DoorData = trace.Entity.DoorData or {}
	
	if trace.Entity:IsDoor() and self.Owner:EyePos():Distance(trace.Entity:GetPos()) > 65 then
		return
	end

	if trace.Entity:IsVehicle() and self.Owner:EyePos():Distance(trace.Entity:GetPos()) > 100 then
		return
	end
	
	local Team = self.Owner:Team()
	
	if trace.Entity:OwnedBy(self.Owner) or (trace.Entity.DoorData.GroupOwn and table.HasValue(RPExtraTeamDoors[trace.Entity.DoorData.GroupOwn], Team))  then
		trace.Entity:Fire("lock", "", 0)
		self.Owner:EmitSound(self.Sound)
		self.Weapon:SetNextPrimaryFire(CurTime() + 0.3)
	else
		if trace.Entity:IsVehicle() then
			Notify(self.Owner, 1, 3, "You don't own this vehicle!")
		else
			self.Owner:EmitSound("physics/wood/wood_crate_impact_hard2.wav", 100, math.random(90, 110))
		end
		self.Weapon:SetNextPrimaryFire(CurTime() + 0.2)
	end
end

function SWEP:SecondaryAttack()
	if CLIENT then return end

	local trace = self.Owner:GetEyeTrace()

	if not ValidEntity(trace.Entity) or not trace.Entity:IsOwnable() or trace.Entity.DoorData.NonOwnable then
		return
	end

	if trace.Entity:IsDoor() and self.Owner:EyePos():Distance(trace.Entity:GetPos()) > 65 then
		return
	end

	if trace.Entity:IsVehicle() and self.Owner:EyePos():Distance(trace.Entity:GetPos()) > 100 then
		return
	end

	local Team = self.Owner:Team()
	if trace.Entity:OwnedBy(self.Owner) or (trace.Entity.DoorData.GroupOwn and table.HasValue(RPExtraTeamDoors[trace.Entity.DoorData.GroupOwn], Team)) then
		trace.Entity:Fire("unlock", "", 0)

		self.Owner:EmitSound(self.Sound)
		self.Weapon:SetNextSecondaryFire(CurTime() + 0.3)
	else
		if trace.Entity:IsVehicle() then
			Notify(self.Owner, 1, 3, "You don't own this vehicle!")
		else
			self.Owner:EmitSound("physics/wood/wood_crate_impact_hard3.wav", 100, math.random(95, 105))
		end
		self.Weapon:SetNextSecondaryFire(CurTime() + 0.2)
	end
end

SWEP.OnceReload = false
function SWEP:Reload()
	local trace = self.Owner:GetEyeTrace()
	if not ValidEntity(trace.Entity) or (ValidEntity(trace.Entity) and ((not trace.Entity:IsDoor() and not trace.Entity:IsVehicle()) or self.Owner:EyePos():Distance(trace.HitPos) > 200)) then
		if not self.OnceReload then
			if SERVER then Notify(self.Owner, 1, 3, "You need to be looking at a door/vehicle in order to bring up the menu") end
			self.OnceReload = true
			timer.Simple(3, function() self.OnceReload = false end)
		end
		return
	end
	if SERVER then
		if trace.Entity:IsVehicle() then
			self.Owner:SendLua("KeysMenu(true)")
		else
			self.Owner:SendLua("KeysMenu(false)")
		end
	end
end
