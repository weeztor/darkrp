if SERVER then
	AddCSLuaFile("shared.lua")
end

if CLIENT then
	SWEP.PrintName = "Keys"
	SWEP.Slot = 1
	SWEP.SlotPos = 1
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

	if not ValidEntity(trace.Entity) or not trace.Entity:IsOwnable() or trace.Entity:GetNWBool("nonOwnable") then
		return
	end

	if trace.Entity:IsDoor() and self.Owner:EyePos():Distance(trace.Entity:GetPos()) > 65 then
		return
	end

	if trace.Entity:IsVehicle() and self.Owner:EyePos():Distance(trace.Entity:GetPos()) > 100 then
		return
	end

	if trace.Entity:OwnedBy(self.Owner) then
		trace.Entity:Fire("lock", "", 0)
		self.Owner:EmitSound(self.Sound)
		self.Weapon:SetNextPrimaryFire(CurTime() + 1.0)
	else
		if trace.Entity:IsVehicle() then
			Notify(self.Owner, 1, 3, "You don't own this vehicle!")
		else
			Notify(self.Owner, 1, 3, "You don't own this door!")
		end
		self.Weapon:SetNextPrimaryFire(CurTime() + .5)
	end
end

function SWEP:SecondaryAttack()
	if CLIENT then return end

	local trace = self.Owner:GetEyeTrace()

	if not ValidEntity(trace.Entity) or not trace.Entity:IsOwnable() or trace.Entity:GetNWBool("nonOwnable") then
		return
	end

	if trace.Entity:IsDoor() and self.Owner:EyePos():Distance(trace.Entity:GetPos()) > 65 then
		return
	end

	if trace.Entity:IsVehicle() and self.Owner:EyePos():Distance(trace.Entity:GetPos()) > 100 then
		return
	end

	if trace.Entity:OwnedBy(self.Owner) then
		trace.Entity:Fire("unlock", "", 0)

		self.Owner:EmitSound(self.Sound)
		self.Weapon:SetNextPrimaryFire(CurTime() + 1.0)
	else
		if trace.Entity:IsVehicle() then
			Notify(self.Owner, 1, 3, "You don't own this vehicle!")
		else
			Notify(self.Owner, 1, 3, "You don't own this door!")
		end
		self.Weapon:SetNextPrimaryFire(CurTime() + .5)
	end
end

SWEP.OnceReload = false
function SWEP:Reload()
	local WEAPON = self
	local trace = self.Owner:GetEyeTrace()

	if  not ValidEntity(trace.Entity) or ( ValidEntity(trace.Entity) and (not trace.Entity:IsDoor() or self.Owner:EyePos():Distance(trace.Entity:GetPos()) > 65))  then
		if not self.OnceReload then
			if SERVER then Notify(self.Owner, 1, 3, "You must be looking at a door to bring up the menu") end
			self.OnceReload = true
			timer.Simple(3, function() self.OnceReload = false end)
		end
		return
	end
	if CLIENT and not self.FrameVisible then
		local Frame = vgui.Create("DFrame")
		self.FrameVisible = true
		Frame:SetSize(200, 360)
		Frame:Center()
		Frame:SetVisible(true)
		Frame:MakePopup()
		Frame:SetTitle("Door options")
		
		function Frame:Close()
			WEAPON.FrameVisible = false
			self:SetVisible( false )
			self:Remove()
		end
		
		if trace.Entity:OwnedBy(LocalPlayer()) then
			local Owndoor = vgui.Create("DButton", Frame)
			Owndoor:SetPos(10, 30)
			Owndoor:SetSize(180, 100)
			Owndoor:SetText("Sell door")
			Owndoor.DoClick = function() LocalPlayer():ConCommand("say /toggleowndoor") Frame:Close() end
			
			local AddOwner = vgui.Create("DButton", Frame)
			AddOwner:SetPos(10, 140)
			AddOwner:SetSize(180, 100)
			AddOwner:SetText("Add owner")
			if not trace.Entity:IsMasterOwner(LocalPlayer()) then
				AddOwner.m_bDisabled = true
			end
				
			AddOwner.DoClick = function()
				local menu = DermaMenu()
				//menu:SetPos(gui.MouseX(), gui.MouseY())
				for k,v in pairs(player.GetAll()) do
					if not trace.Entity:OwnedBy(v) and not trace.Entity:AllowedToOwn(v) then
						menu:AddOption(v:Nick(), function() LocalPlayer():ConCommand("say /addowner " .. tostring(v:UserID())) end)
					end
				end
				if #menu.Panels == 0 then
					menu:AddOption("Noone available", function() end)
				end
				menu:Open()
			end
			
			local RemoveOwner = vgui.Create("DButton", Frame)
			RemoveOwner:SetPos(10, 250)
			RemoveOwner:SetSize(180, 100)
			RemoveOwner:SetText("Remove owner")
			if not trace.Entity:IsMasterOwner(LocalPlayer()) then
				RemoveOwner.m_bDisabled = true
			end
				
			RemoveOwner.DoClick = function()
				local menu = DermaMenu()
				//menu:SetPos(gui.MouseX(), gui.MouseY())
				for k,v in pairs(player.GetAll()) do
					if (trace.Entity:OwnedBy(v) and not trace.Entity:IsMasterOwner(v)) or trace.Entity:AllowedToOwn(v) then
						menu:AddOption(v:Nick(), function() LocalPlayer():ConCommand("say /ro " .. tostring(v:UserID())) end)
					end
				end
				if #menu.Panels == 0 then
					menu:AddOption("Noone available", function() end)
				end
				menu:Open()
			end
		elseif not trace.Entity:OwnedBy(LocalPlayer()) and trace.Entity:IsOwnable() and not trace.Entity:IsOwned() and not trace.Entity:GetNWBool("nonOwnable") then
			Frame:SetSize(200, 140)
			local Owndoor = vgui.Create("DButton", Frame)
			Owndoor:SetPos(10, 30)
			Owndoor:SetSize(180, 100)
			Owndoor:SetText("Buy door")
			Owndoor.DoClick = function() LocalPlayer():ConCommand("say /toggleowndoor") Frame:Close() end
			if LocalPlayer():IsSuperAdmin() then
				Frame:SetSize(200, 250)
				local DisableOwnage = vgui.Create("DButton", Frame)
				DisableOwnage:SetPos(10, 140)
				DisableOwnage:SetSize(180, 100)
				DisableOwnage:SetText("Disallow ownership")
				DisableOwnage.DoClick = function() Frame:Close() LocalPlayer():ConCommand("say /toggleownable") end
			end
		elseif not trace.Entity:OwnedBy(LocalPlayer()) and trace.Entity:AllowedToOwn(LocalPlayer()) then
			Frame:SetSize(200, 150)
			local Owndoor = vgui.Create("DButton", Frame)
			Owndoor:SetPos(10, 30)
			Owndoor:SetSize(180, 100)
			Owndoor:SetText("Co-own door")
			Owndoor.DoClick = function() LocalPlayer():ConCommand("say /toggleowndoor") Frame:Close() end
		elseif LocalPlayer():IsSuperAdmin() and trace.Entity:GetNWBool("nonOwnable") then
			Frame:SetSize(200, 140)
			local EnableOwnage = vgui.Create("DButton", Frame)
			EnableOwnage:SetPos(10, 30)
			EnableOwnage:SetSize(180, 100)
			EnableOwnage:SetText("Allow ownership")
			EnableOwnage.DoClick = function() Frame:Close() LocalPlayer():ConCommand("say /toggleownable") end
		elseif LocalPlayer():IsSuperAdmin() and not trace.Entity:OwnedBy(LocalPlayer()) and trace.Entity:IsOwned() and not trace.Entity:AllowedToOwn(LocalPlayer()) then
			Frame:SetSize(200, 140)
			local DisableOwnage = vgui.Create("DButton", Frame)
			DisableOwnage:SetPos(10, 30)
			DisableOwnage:SetSize(180, 100)
			DisableOwnage:SetText("Disallow ownership")
			DisableOwnage.DoClick = function() Frame:Close() LocalPlayer():ConCommand("say /toggleownable") end
		else
			Frame:Close()
			//LocalPlayer():ChatPrint("Door cannot be owned") 
		end

	end
end
