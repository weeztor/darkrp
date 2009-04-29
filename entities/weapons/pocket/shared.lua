require("datastream")
if SERVER then
	AddCSLuaFile("shared.lua")
end

if CLIENT then
	SWEP.PrintName = "Pocket"
	SWEP.Slot = 1
	SWEP.SlotPos = 1
	SWEP.DrawAmmo = false
	SWEP.DrawCrosshair = false
end

SWEP.Author = "FPtje"
SWEP.Instructions = "Left click to pick up, right click to drop, reload for menu"
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

function SWEP:Initialize()
	if SERVER then self:SetWeaponHoldType("normal") end
end

function SWEP:Deploy()
	if SERVER then
		self.Owner:DrawViewModel(false)
		self.Owner:DrawWorldModel(false)
	end
end

local blacklist = {"drug_lab", "money_printer", "meteor", "door", "func_", "player", "beam", "worldspawn", "env_", "path_"/*, "spawned_weapon"*/}
function SWEP:PrimaryAttack()
	if CLIENT then return end

	self.Weapon:SetNextPrimaryFire(CurTime() + 0.2)
	local trace = self.Owner:GetEyeTrace()

	if not ValidEntity(trace.Entity) then
		return
	end
	
	if self.Owner:EyePos():Distance(trace.HitPos) > 65 then
		return
	end
	
	local phys = trace.Entity:GetPhysicsObject()
	if not phys:IsValid() then return end
	local mass = phys:GetMass()
	
	if /*trace.Entity:IsWeapon() or */not SPropProtection.GravGunThings(self.Owner, trace.Entity) then
		Notify(self.Owner, 1, 4, "Cannot put in pocket!")
		return
	end
	for k,v in pairs(blacklist) do 
		if string.find(string.lower(trace.Entity:GetClass()), v) then
			Notify(self.Owner, 1, 4, "Cannot put "..v.." in pocket!")
			return
		end
	end
	
	if mass > 100 then
		Notify(self.Owner, 1, 4, "Too heavy!")
		return
	end
	
	if not self.Owner:GetTable().Pocket then self.Owner:GetTable().Pocket = {} end
	if not CfgVars["pocketitems"] then CfgVars["pocketitems"] = 10 end
	if #self.Owner:GetTable().Pocket >= CfgVars["pocketitems"] then
		Notify(self.Owner, 1, 4, "Pocket is full!")
		return
	end

	
	umsg.Start("Pocket_AddItem", self.Owner)
		umsg.Short(trace.Entity:EntIndex())
	umsg.End()
	
	table.insert(self.Owner:GetTable().Pocket, trace.Entity)
	trace.Entity:SetNoDraw(true)
	trace.Entity:SetCollisionGroup(0)
	local phys = trace.Entity:GetPhysicsObject()
	if phys:IsValid() then
		phys:EnableCollisions(false)
		trace.Entity:SetMoveType(MOVETYPE_VPHYSICS)
		phys:Wake()
	end
end

function SWEP:SecondaryAttack()
	if CLIENT then return end
	self.Weapon:SetNextSecondaryFire(CurTime() + 0.2)
	
	if not self.Owner:GetTable().Pocket or #self.Owner:GetTable().Pocket <= 0 then
		Notify(self.Owner, 1, 4, "No items in pocket!")
		return
	end
	local ent = self.Owner:GetTable().Pocket[#self.Owner:GetTable().Pocket]
	self.Owner:GetTable().Pocket[#self.Owner:GetTable().Pocket] = nil
	if not ValidEntity(ent) then Notify(self.Owner, 1, 4, "No items in pocket!") return end
	local trace = {}
	trace.start = self.Owner:EyePos()
	trace.endpos = trace.start + self.Owner:GetAimVector() * 85
	trace.filter = self.Owner
	local tr = util.TraceLine(trace)
	ent:SetMoveType(MOVETYPE_VPHYSICS)
	ent:SetNoDraw(false)
	ent:SetCollisionGroup(4)
	ent:SetPos(tr.HitPos)
	local phys = ent:GetPhysicsObject()
	if phys:IsValid() then
		phys:EnableCollisions(true)
		phys:Wake()
	end
end

SWEP.OnceReload = false
function SWEP:Reload()
	if CLIENT or self.Weapon.OnceReload then return end
	self.Weapon.OnceReload = true
	timer.Simple(0.5, function() self.Weapon.OnceReload = false end)
	
	if not self.Owner:GetTable().Pocket or #self.Owner:GetTable().Pocket <= 0 then
		Notify(self.Owner, 1, 4, "No items in pocket!")
		return
	end
	
	umsg.Start("StartPocketMenu", self.Owner)
	umsg.End()
end

if CLIENT then
	local function StorePocketItem(um)
		if not LocalPlayer():GetTable().Pocket then
			LocalPlayer():GetTable().Pocket = {}
		end
		local ent = Entity(um:ReadShort())
		if ValidEntity(ent) then
			table.insert(LocalPlayer():GetTable().Pocket, ent)
		end
	end
	usermessage.Hook("Pocket_AddItem", StorePocketItem)
	local frame
	local function PocketMenu()
		if frame and frame:IsValid() and frame:IsVisible() then return end
		if LocalPlayer():GetActiveWeapon():GetClass() ~= "pocket" then return end
		if not LocalPlayer():GetTable().Pocket then LocalPlayer():GetTable().Pocket = {} return end
		if #LocalPlayer():GetTable().Pocket <= 0 then return end
		frame = vgui.Create( "DFrame" )
		frame:SetTitle( "Drop item" )
		frame:SetVisible( true )
		frame:MakePopup( )
		
		local items = LocalPlayer():GetTable().Pocket
		local function Reload()
			frame:SetSize( #items * 64, 90 ) 
			frame:Center()
			for k,v in pairs(items) do
				local icon = vgui.Create("SpawnIcon", frame)
				icon:SetPos((k-1) * 64, 25)
				icon:SetModel(v:GetModel())
				icon:SetIconSize(64)
				icon:SetToolTip()
				icon.DoClick = function()
					icon:SetToolTip()
					RunConsoleCommand("_RPSpawnPocketItem", v:EntIndex())
					items[k] = nil
					if #items == 0 then
						frame:Close()
						return
					end
					items = table.ClearKeys(items)
					Reload()
				end
			end
		end
		Reload()
	end
	usermessage.Hook("StartPocketMenu", PocketMenu)
elseif SERVER then
	local function Spawn(ply, cmd, args)
		if ply:GetActiveWeapon():GetClass() ~= "pocket" then
			return
		end
		if ply:GetTable().Pocket and Entity(tonumber(args[1])) then
			local ent = Entity(tonumber(args[1]))
			for k,v in pairs(ply:GetTable().Pocket) do 
				if v == ent then
					ply:GetTable().Pocket[k] = nil
				end
			end
			ply:GetTable().Pocket = table.ClearKeys(ply:GetTable().Pocket)
			
			local trace = {}
			trace.start = ply:EyePos()
			trace.endpos = trace.start + ply:GetAimVector() * 85
			trace.filter = ply
			local tr = util.TraceLine(trace)
			ent:SetMoveType(MOVETYPE_VPHYSICS)
			ent:SetNoDraw(false)
			ent:SetCollisionGroup(4)
			ent:SetPos(tr.HitPos)
			local phys = ent:GetPhysicsObject()
			if phys:IsValid() then
				phys:EnableCollisions(true)
				phys:Wake()
			end
		end
	end
	concommand.Add("_RPSpawnPocketItem", Spawn)
end
