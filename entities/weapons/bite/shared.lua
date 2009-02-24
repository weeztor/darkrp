if SERVER then
	AddCSLuaFile("shared.lua")
end

if CLIENT then
	SWEP.PrintName = "Bite"
	SWEP.Slot = 1
	SWEP.SlotPos = 4
	SWEP.DrawAmmo = false
	SWEP.DrawCrosshair = false
end

SWEP.Author = "FPtje + GoDNeSS"
SWEP.Instructions = "Left click to bite. Right click to hit with your claws. Reload to make a funneh sound"
SWEP.Contact = ""
SWEP.Purpose = ""

SWEP.ViewModelFOV = 62
SWEP.ViewModelFlip = false
SWEP.AnimPrefix	 = "rpg"

SWEP.Spawnable = false
SWEP.AdminSpawnable = true
//SWEP.Sound = "doors/door_latch3.wav"
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

	if not ValidEntity(trace.Entity) then
		return
	end

	if self.Owner:EyePos():Distance(trace.Entity:GetPos()) > 200 then
		return
	end

	trace.Entity:SetHealth(trace.Entity:Health() - 5)
	if trace.Entity:Health() <= 0 and trace.Entity:IsPlayer() then trace.Entity:Kill() end
	self.Owner:EmitSound("npc/fast_zombie/gurgle_loop1.wav", 100,100)
	local mysound = CreateSound(self.Owner, Sound("npc/fast_zombie/gurgle_loop1.wav") ) 
	mysound:Play() // starts the sound 
	timer.Simple(0.7, function() mysound:Stop() end) // stops the sound  
	self.Weapon:SetNextPrimaryFire(CurTime() + 0.5)
	self.Owner:ViewPunch(Angle(-10, 3, 10))
	if trace.Entity:IsPlayer() then
		trace.Entity:ViewPunch(Angle(-10, 10, 10))
	end
end

function SWEP:SecondaryAttack()
	if CLIENT then return end

	local trace = self.Owner:GetEyeTrace()

	if not ValidEntity(trace.Entity) then
		return
	end
	
	if self.Owner:EyePos():Distance(trace.Entity:GetPos()) > 300 then
		return
	end
	
	trace.Entity:SetHealth(trace.Entity:Health() - 10)
	if trace.Entity:Health() <= 0 and trace.Entity:IsPlayer() then trace.Entity:Kill() end
	self.Weapon:SetNextSecondaryFire(CurTime() + 0.8)
	self.Owner:ViewPunch(Angle(-10, 10, 10))
	if trace.Entity:IsPlayer() then
		trace.Entity:ViewPunch(Angle(-10, 10, 10))
	end
	trace.Entity:EmitSound("npc/zombie/zombie_hit.wav", 100,100)
end

SWEP.OnceReload = false
local moods = {
{"Happy","npc/headcrab/idle3.wav"},
{"Angry", "npc/headcrab/attack2.wav"},
{"Sad","npc/headcrab_poison/ph_wallpain1.wav"},
{"Howl", "npc/headcrab_fast/alert1.wav"},
{"Afraid", "ambient/creatures/town_scared_sob1.wav"},
{"Question", "ambient/creatures/teddy.wav"}
}

SWEP.NoReload = CurTime()
function SWEP:Reload()
	if CLIENT and self.Weapon.NoReload < CurTime() + 1 then
		local frame = vgui.Create("DFrame")
		local button = {}
		local PosSize = {}

		frame:SetSize( 200, 500 )
		frame:Center()
		frame:SetVisible(true)
		frame:MakePopup()
		frame:SetTitle("Choose a mood")

		PosSize[0] = 5
		for k,v in pairs(moods) do
			PosSize[k] = PosSize[k-1] + 30
			frame:SetSize(200, PosSize[k] + 40)
			button[k] = vgui.Create("DButton", frame)
			button[k]:SetPos( 20, PosSize[k])
			button[k]:SetSize( 160, 20 )
			button[k]:SetText(v[1])
			frame:Center()
			button[k]["DoClick"] = function()
				RunConsoleCommand("_DoMakeAnimalSound", v[2])
				frame:Close()
			end
			button[k]:SetKeyboardInputEnabled(false)
		end
		frame:SetKeyboardInputEnabled(false)
	end
	self.Weapon.NoReload = CurTime() + 2
end
