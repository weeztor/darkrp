if SERVER then
	AddCSLuaFile("shared.lua")
end

if CLIENT then
	SWEP.PrintName = "Weapon checker"
	SWEP.Slot = 1
	SWEP.SlotPos = 9
	SWEP.DrawAmmo = false
	SWEP.DrawCrosshair = false
end

SWEP.Author = "Rick Darkaliono, philxyz"
SWEP.Instructions = "Left click to Check weapons, right click to confiscate guns"
SWEP.Contact = ""
SWEP.Purpose = ""

SWEP.ViewModelFOV = 62
SWEP.ViewModelFlip = false
SWEP.AnimPrefix	 = "rpg"

SWEP.Spawnable = false
SWEP.AdminSpawnable = true
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

local NoStripWeapons = {"weapon_physgun", "weapon_physcannon", "keys", "gmod_camera", "gmod_tool", "weaponchecker"}
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
	self.Weapon:SetNextPrimaryFire(CurTime() + 0.2)

	local trace = self.Owner:GetEyeTrace()

	if not ValidEntity(trace.Entity) or (not trace.Entity:IsPlayer() and not trace.Entity:IsNPC()) then
		return
	end
	
	local result = "" 
	for k,v in pairs(trace.Entity:GetWeapons()) do
		if v:IsValid() then
			result = result..", "..v:GetClass()
		end
	end
	self.Owner:EmitSound("npc/combine_soldier/gear5.wav", 50, 100)
	timer.Simple(0.3, function(ply) ply:EmitSound("npc/combine_soldier/gear5.wav", 50, 100) end, self.Owner)
	self.Owner:ChatPrint(trace.Entity:Nick() .."'s weapons:")
	self.Owner:ChatPrint(string.sub(result, 3))
end

function SWEP:SecondaryAttack()
	if CLIENT then return end
	self.Weapon:SetNextSecondaryFire(CurTime() + 0.2)

	local trace = self.Owner:GetEyeTrace()

	if not ValidEntity(trace.Entity) or (not trace.Entity:IsPlayer() and not trace.Entity:IsNPC()) then
		return
	end
	
	local result = "" 
	for k,v in pairs(trace.Entity:GetWeapons()) do
		if not table.HasValue(NoStripWeapons, string.lower(v:GetClass())) then
			trace.Entity:StripWeapon(v:GetClass())
			result = result..", "..v:GetClass()
		end
	end
	if result == "" then
		self.Owner:ChatPrint(trace.Entity:Nick() .. " has no illegal weapons")
		self.Owner:EmitSound("npc/combine_soldier/gear5.wav", 50, 100)
		timer.Simple(0.3, function(ply) ply:EmitSound("npc/combine_soldier/gear5.wav", 50, 100) end, self.Owner)
	else
		local endresult = string.sub(result, 3)
		self.Owner:EmitSound("ambient/energy/zap1.wav", 50, 100)
		self.Owner:ChatPrint("Confisquated these weapons:")
		if string.len(endresult) >= 126 then
			local amount = math.ceil(string.len(endresult) / 126)
			for i = 1, amount, 1 do
				self.Owner:ChatPrint(string.sub(endresult, (i-1) * 126, i * 126 - 1))
			end
		else		
			self.Owner:ChatPrint(string.sub(result, 3))
		end
	end
end

function SWEP:Reload()
end
