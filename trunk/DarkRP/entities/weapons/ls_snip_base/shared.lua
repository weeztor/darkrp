if (SERVER) then
	AddCSLuaFile("cl_init.lua")
	AddCSLuaFile("shared.lua")
end

SWEP.DrawCrosshair = false
SWEP.Base = "weapon_cs_base"

SWEP.Spawnable = false
SWEP.AdminSpawnable = false

SWEP.Primary.Sound = Sound("Weapon_AK47.Single")
SWEP.Primary.Recoil = 1.5
SWEP.Primary.Damage = 100
SWEP.Primary.NumShots = 1
SWEP.Primary.Cone = 0.0001
SWEP.Primary.UnscopedCone = 0.5
SWEP.Primary.Delay = .7

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

SWEP.ViewModelFOV = 70

function SWEP:Initialize()
	if (SERVER) then
		self:SetWeaponHoldType(self.HoldType)
	end

	self.Weapon:SetNetworkedBool("Ironsights", false)
end

/*---------------------------------------------------------
	PrimaryAttack
---------------------------------------------------------*/
function SWEP:PrimaryAttack()
	if not ValidEntity(self.Owner) then return end
	self.Owner:LagCompensation(true)
	self.Weapon:SetNextSecondaryFire(CurTime())
	self.Weapon:SetNextPrimaryFire(CurTime() + self.Primary.Delay)

	if not self:CanPrimaryAttack() then return end

	-- Play shoot sound
	self.Weapon:EmitSound(self.Primary.Sound)

	-- Shoot the bullet
	if (self.Owner:GetNWInt("ScopeLevel", 0) > 0) then
		self:CSShootBullet(self.Primary.Damage, self.Primary.Recoil, self.Primary.NumShots, self.Primary.Cone)
	else
		self:CSShootBullet(self.Primary.Damage, self.Primary.Recoil, self.Primary.NumShots, self.Primary.UnscopedCone)
	end

	-- Remove 1 bullet from our clip
	self:TakePrimaryAmmo(1)

	-- Punch the player's view
	self.Owner:ViewPunch(Angle(math.Rand(-0.2,-0.1) * self.Primary.Recoil, math.Rand(-0.1,0.1) *self.Primary.Recoil, 0))

	-- In singleplayer this function doesn't get called on the client, so we use a networked float
	-- to send the last shoot time. In multiplayer this is predicted clientside so we don't need to
	-- send the float.
	if ((SinglePlayer() and SERVER) or CLIENT) then
		self.Weapon:SetNetworkedFloat("LastShootTime", CurTime())
	end

	--self.Owner:SetNetworkedInt("ScopeLevel", 0)

	--if (SERVER) then
	--  self.Owner:SetFOV(0, 0)
	--end

	--self:SetIronsights(false)
	self.Owner:LagCompensation(false)
end

/*---------------------------------------------------------
Name: SWEP:PrimaryAttack()
Desc: +attack1 has been pressed
---------------------------------------------------------*/

function SWEP:CSShootBullet(dmg, recoil, numbul, cone)
	if not ValidEntity(self.Owner) then return end
	numbul = numbul or 1
	cone = cone or 0.01

	local bullet = {}
	bullet.Num = numbul
	bullet.Src = self.Owner:GetShootPos()       -- Source
	bullet.Dir = self.Owner:GetAimVector()      -- Dir of bullet
	bullet.Spread = Vector(cone, cone, 0)       -- Aim Cone
	bullet.Tracer = 4     -- Show a tracer on every x bullets
	bullet.Force = 5        -- Amount of force to give to phys objects
	bullet.Damage = dmg

	self.Owner:FireBullets(bullet)
	self.Weapon:SendWeaponAnim(ACT_VM_PRIMARYATTACK)      -- View model animation
	self.Owner:MuzzleFlash()        -- Crappy muzzle light
	self.Owner:SetAnimation(PLAYER_ATTACK1)       -- 3rd Person Animation

	-- CUSTOM RECOIL !
	if ((SinglePlayer() and SERVER) or (not SinglePlayer() and CLIENT)) then
		local eyeang = self.Owner:EyeAngles()
		eyeang.pitch = eyeang.pitch - recoil
		self.Owner:SetEyeAngles(eyeang)
	end
end

local IRONSIGHT_TIME = 0.25

/*---------------------------------------------------------
Name: GetViewModelPosition
Desc: Allows you to re-position the view model
---------------------------------------------------------*/
function SWEP:GetViewModelPosition(pos, ang)
	if (not self.IronSightsPos) then return pos, ang end

	local bIron = self.Weapon:GetNWBool("Ironsights")

	if (bIron != self.bLastIron) then
		self.bLastIron = bIron
		self.fIronTime = CurTime()

		if (bIron) then
			self.SwayScale = 0.3
			self.BobScale = 0.1
		else
			self.SwayScale = 1.0
			self.BobScale = 1.0
		end
	end

	local fIronTime = self.fIronTime or 0

	if (not bIron and fIronTime < CurTime() - IRONSIGHT_TIME) then
		return pos, ang
	end

	local Mul = 1.0

	if (fIronTime > CurTime() - IRONSIGHT_TIME) then
		Mul = math.Clamp((CurTime() - fIronTime) / IRONSIGHT_TIME, 0, 1)
		if not bIron then Mul = 1 - Mul end
	end

	local Offset	= self.IronSightsPos

	if (self.IronSightsAng) then
		ang = ang * 1
		ang:RotateAroundAxis(ang:Right(), self.IronSightsAng.x * Mul)
		ang:RotateAroundAxis(ang:Up(),  self.IronSightsAng.y * Mul)
		ang:RotateAroundAxis(ang:Forward(), self.IronSightsAng.z * Mul)
	end

	local Right = ang:Right()
	local Up = ang:Up()
	local Forward = ang:Forward()

	pos = pos + Offset.x * Right * Mul
	pos = pos + Offset.y * Forward * Mul
	pos = pos + Offset.z * Up * Mul

	return pos, ang
end


/*---------------------------------------------------------
SetIronsights
---------------------------------------------------------*/
function SWEP:SetIronsights(b)
	if (self.Weapon:GetNWBool("Ironsights") == b) then return end
	self.Weapon:SetNetworkedBool("Ironsights", b)
end

SWEP.NextSecondaryAttack = 0

/*---------------------------------------------------------
SecondaryAttack
---------------------------------------------------------*/

function SWEP:SecondaryAttack()
	if not ValidEntity(self.Owner) then return end
	if not self.IronSightsPos then return end

	if (self.NextSecondaryAttack > CurTime()) then return end

	self.NextSecondaryAttack = CurTime() + 0.3

	if (self.Owner:GetNWInt("ScopeLevel") == nil) then
		self.Owner:SetNetworkedInt("ScopeLevel", 0)
	end

	if (self.Owner:GetNWInt("ScopeLevel") == 0) then
		if (SERVER) then
			self.Owner:SetFOV(25, 0)
		end

		self.Owner:SetNetworkedInt("ScopeLevel", 1)
		self:SetIronsights(true)
	else
		if (self.Owner:GetNWInt("ScopeLevel") == 1) then
			if (SERVER) then
				self.Owner:SetFOV(5, 0)
			end

			self.Owner:SetNetworkedInt("ScopeLevel", 2)
			self:SetIronsights(true)
		else
			if (SERVER) then
				self.Owner:SetFOV(0, 0)
			end

			self.Owner:SetNetworkedInt("ScopeLevel", 0)
			self:SetIronsights(false)
		end
	end
end

function SWEP:Holster()
	if not ValidEntity(self.Owner) then return end
	if (SERVER) then
		self.Owner:SetFOV(0, 0)
	end

	self.Owner:SetNetworkedInt("ScopeLevel", 0)
	self:SetIronsights(false)

	return true
end

function SWEP:Deploy()
	if not ValidEntity(self.Owner) then return end
	self.Owner:SetNetworkedInt("ScopeLevel", 0)
	self:SetIronsights(false)

	return true
end

function SWEP:Reload()
	if not ValidEntity(self.Owner) then return end
	if (SERVER) then
		self.Owner:SetFOV(0, 0)
	end

	self.Owner:SetNetworkedInt("ScopeLevel", 0)
	self.Weapon:DefaultReload(ACT_VM_RELOAD)
	self:SetIronsights(false)

	return true
end

function SWEP:DrawHUD()
	-- No crosshair when ironsights is on
	if (self.Weapon:GetNWBool("Ironsights")) then return end

	-- gets the center of the screen
	local x = ScrW() / 2.0
	local y = ScrH() / 2.0

	-- set the drawcolor
	surface.SetDrawColor(0, 0, 0, 255)
	local gap = 10
	local length = gap + 15

	-- draw the crosshair
	surface.DrawLine(x - length, y, x - gap, y)
	surface.DrawLine(x + length, y, x + gap, y)
	surface.DrawLine(x, y - length, x, y - gap)
	surface.DrawLine(x, y + length, x, y + gap)
end

/*---------------------------------------------------------
Checks the objects before any action is taken
This is to make sure that the entities haven't been removed
---------------------------------------------------------*/
function SWEP:DrawWeaponSelection(x, y, wide, tall, alpha)
	draw.SimpleText(self.IconLetter, "CSSelectIcons", x + wide/2, y + tall*0.2, Color(255, 210, 0, 255), TEXT_ALIGN_CENTER)

	-- try to fool them into thinking they're playing a Tony Hawks game
	draw.SimpleText(self.IconLetter, "CSSelectIcons", x + wide/2 + math.Rand(-4, 4), y + tall*0.2+ math.Rand(-14, 14), Color(255, 210, 0, math.Rand(10, 120)), TEXT_ALIGN_CENTER)
	draw.SimpleText(self.IconLetter, "CSSelectIcons", x + wide/2 + math.Rand(-4, 4), y + tall*0.2+ math.Rand(-9, 9), Color(255, 210, 0, math.Rand(10, 120)), TEXT_ALIGN_CENTER)
end