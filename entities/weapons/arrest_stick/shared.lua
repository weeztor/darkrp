if SERVER then
	AddCSLuaFile("shared.lua")
end

if CLIENT then
	SWEP.PrintName = "Arrest Baton"
	SWEP.Slot = 1
	SWEP.SlotPos = 3
	SWEP.DrawAmmo = false
	SWEP.DrawCrosshair = false
end

SWEP.Base = "weapon_cs_base2"

SWEP.Author = "Rick Darkaliono, philxyz"
SWEP.Instructions = "Left or right click to arrest"
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
	if trace.Entity:GetClass() == "prop_ragdoll" then
		for k,v in pairs(player.GetAll()) do
			if trace.Entity.OwnerINT and trace.Entity.OwnerINT == v:EntIndex() then
				KnockoutToggle(v, true)
				return
			end
		end
	end
		
	if not ValidEntity(trace.Entity) or (self.Owner:EyePos():Distance(trace.Entity:GetPos()) > 115) or (not trace.Entity:IsPlayer() and not trace.Entity:IsNPC()) then
		return
	end
	
	if not tobool(GetConVarNumber("npcarrest")) and trace.Entity:IsNPC() then
		return
	end

	if GetConVarNumber("needwantedforarrest") == 1 and not trace.Entity:IsNPC() and not trace.Entity.DarkRPVars.wanted then
		Notify(self.Owner, 1, 5, "The player must be wanted in order to be able to arrest them.")
		return
	end
	
	if FAdmin and trace.Entity:IsPlayer() and trace.Entity:FAdmin_GetGlobal("fadmin_jailed") then
		Notify(self.Owner, 1, 5, "You cannot arrest a player who has been jailed by an admin.")
		return
	end
	
	local jpc = DB.CountJailPos()

	if not jpc or jpc == 0 then
		Notify(self.Owner, 1, 4, "You cannot arrest people since there are no jail positions set!")
	else
		-- Send NPCs to Jail
		if trace.Entity:IsNPC() then
			trace.Entity:SetPos(DB.RetrieveJailPos())
		else
			if not trace.Entity.Babygod then
				trace.Entity:Arrest()
				Notify(trace.Entity, 0, 20, "You've been arrested by " .. self.Owner:Nick())
				
				if self.Owner.SteamName then
					DB.Log(self.Owner:SteamName().." ("..self.Owner:SteamID()..") arrested "..trace.Entity:Nick())
				end
			else
				Notify(self.Owner, 1, 4, "You can't arrest players who are spawning.")
			end
		end
	end
end

function SWEP:SecondaryAttack()
	self:PrimaryAttack()
end
