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
SWEP.Instructions = "Left click to pick up, right click to drop"
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
	
	if self.Owner:EyePos():Distance(trace.Entity:GetPos()) > 65 then
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

	table.insert(self.Owner:GetTable().Pocket, {
	class = trace.Entity:GetClass(), 
	model = trace.Entity:GetModel(), 
	Owner = trace.Entity:GetNWString("Owner"), 
	gettable = trace.Entity:GetTable(), 
	weaponclass = trace.Entity:GetNWString("weaponclass"),
	shipcontent = trace.Entity:GetNWString("contents"),
	shipcount = trace.Entity:GetNWInt("count"),
	price = trace.Entity:GetNWInt("price")})
	
	trace.Entity:Remove()
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
	
	local trace = {}
	trace.start = self.Owner:EyePos()
	trace.endpos = trace.start + self.Owner:GetAimVector() * 85
	trace.filter = self.Owner
	local tr = util.TraceLine(trace)
	local spawn = ents.Create(ent.class)
	spawn:SetPos(tr.HitPos)
	spawn:SetModel(ent.model)
	if ent.Owner ~= "" then
		spawn:SetNWString("Owner", ent.Owner)
		undo.Create("Pocket Entity")
			undo.AddEntity( spawn )
			undo.SetPlayer( self.Owner )
		undo.Finish()
	else
		spawn:SetNWString("Owner", "Shared")
	end
	spawn:Spawn()
	for k,v in pairs(ent.gettable) do
		spawn:GetTable()[k] = v
	end
	spawn:GetTable().Entity = spawn
	spawn:SetNWString("weaponclass", ent.weaponclass)
	spawn:SetNWString("contents", ent.shipcontent)
	spawn:SetNWInt("count", ent.shipcount)
	spawn:SetNWInt("price", ent.price)
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
	
	local SendToClient = {}
	for k,v in pairs(self.Owner:GetTable().Pocket) do
		table.insert(SendToClient, v.model) -- only send the model!
	end
	datastream.StreamToClients({self.Owner}, "PocketMenu", SendToClient)
end

if CLIENT then
	require("datastream")
	local frame
	local function PocketMenu(handler, id, encoded, decoded)
		if frame and frame:IsValid() and frame:IsVisible() then return end
		frame = vgui.Create( "DFrame" )
		frame:SetTitle( "Drop item" )
		frame:SetVisible( true )
		frame:MakePopup( )
		
		local function Reload()
			frame:SetSize( #decoded * 64, 90 ) 
			frame:Center()
			for k,v in pairs(decoded) do
				local icon = vgui.Create("SpawnIcon", frame)
				icon:SetPos((k-1) * 64, 25)
				icon:SetModel(v)
				icon:SetIconSize(64)
				icon:SetToolTip()
				icon.DoClick = function()
					RunConsoleCommand("_RPSpawnPocketItem", k)
					decoded[k] = nil
					if #decoded == 0 then
						frame:Close()
						return
					end
					decoded = table.ClearKeys(decoded)
					Reload()
				end
			end
		end
		Reload()
	end
	datastream.Hook( "PocketMenu", PocketMenu )
elseif SERVER then
	local function Spawn(ply, cmd, args)
		if ply:GetActiveWeapon():GetClass() ~= "pocket" then
			return
		end
		if ply:GetTable().Pocket and ply:GetTable().Pocket[tonumber(args[1])] then
			local ent = ply:GetTable().Pocket[tonumber(args[1])]
			ply:GetTable().Pocket[tonumber(args[1])] = nil
			ply:GetTable().Pocket = table.ClearKeys(ply:GetTable().Pocket)
			
			local trace = {}
			trace.start = ply:EyePos()
			trace.endpos = trace.start + ply:GetAimVector() * 85
			trace.filter = ply
			local tr = util.TraceLine(trace)
			local spawn = ents.Create(ent.class)
			spawn:SetPos(tr.HitPos)
			spawn:SetModel(ent.model)
			if ent.Owner ~= "" then
				spawn:SetNWString("Owner", ent.Owner)
				undo.Create("Pocket Entity")
					undo.AddEntity( spawn )
					undo.SetPlayer( ply )
				undo.Finish()
			else
				spawn:SetNWString("Owner", "Shared")
			end
			spawn:SetNWString("weaponclass", ent.weaponclass)
			spawn:SetNWString("contents", ent.shipcontent)
			spawn:SetNWInt("count", ent.shipcount)
			spawn:SetNWInt("price", ent.price)
			spawn:Spawn()
			for k,v in pairs(ent.gettable) do
				spawn:GetTable()[k] = v
			end
			spawn:GetTable().Entity = spawn
		end
	end
	concommand.Add("_RPSpawnPocketItem", Spawn)
end
