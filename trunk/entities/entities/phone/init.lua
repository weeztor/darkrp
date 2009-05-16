
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include('shared.lua')

function ENT:Initialize()
	self:SetModel("models/weapons/w_camphone.mdl")
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
	self.Entity:SetSolid( SOLID_VPHYSICS )
	self.Entity:SetUseType( SIMPLE_USE )
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then phys:Wake() end
	
	if self:GetNWBool("IsBeingHeld") then return end--Don't make noise when already picked up
	
	self.sound = CreateSound(self, "ambient/alarms/city_firebell_loop1.wav")
	self.sound:PlayEx(0.6, 60)
	timer.Simple(2, function(ent) if ent and ent.sound then ent.sound:Stop() end end, self)
	local S = self.sound
	timer.Create("PhoneRinging"..tostring(self:EntIndex()), 3.5, 0, function(sound)
		sound:PlayEx(0.6, 60)
		timer.Simple(2, function(s) s:Stop() end, sound)
	end, S)
end


function ENT:Use( activator, caller )

	if ( !activator:IsPlayer() ) then return end
	
	// Someone is already using the phone
	if ( self.LastUser && self.LastUser:IsValid() ) then return end

	if ValidEntity(self:GetNWEntity("Caller")) and activator == self:GetNWEntity("Caller") then return end
	
	if self.sound then
		self.sound:Stop()
	end
	local VEC = activator:GetAimVector() 
	VEC:Rotate(Angle(0,90,0)) -- To the right
	local VEC2 = Angle(90, activator:GetAimVector().y, 0)
	local POS = activator:GetAttachment(activator:LookupAttachment("eyes") or 1)
	if POS then POS = activator:GetShootPos() + ((POS.Pos - activator:GetShootPos())/2) + (VEC * -5)
	POS.z = activator:GetShootPos().z - 5 else return end
	
	timer.Remove("PhoneRinging"..tostring(self:EntIndex()))
	self.Entity:SetSolid(SOLID_NONE)
	self:SetPos(POS)
	self:SetAngles(activator:EyeAngles() + Angle(180,90,180))
	self:SetParent(activator)
	self:SetNWBool("IsBeingHeld", true)
	
	if ValidEntity(self:GetNWEntity("Caller")) then // if you're BEING called and pick up the phone...
		local ply = self:GetNWEntity("Caller") -- the one who called you
		ply:GetNWEntity("phone"):SetNWEntity("Caller", activator) -- Make sure he knows YOU picked up the phone
		ply:GetNWEntity("phone"):SetNWBool("HePickedUp", true)
		
		activator:SetNWEntity("phone", self) -- This object is the phone you're holding
		
		activator:ConCommand("+voicerecord")
		ply:ConCommand("+voicerecord")
		timer.Create("PhoneCallCosts"..ply:EntIndex(), 20, 0, function(ply, ent) -- Make the caller pay!
			if ValidEntity(ply) and ply:CanAfford(1) then
				ply:AddMoney(-1)
			else
				ent:HangUp()
			end
		end, ply, self)
	end	
	
	self.LastUser = activator
end

function ENT:Think()
	if not self:GetNWEntity("owning_ent"):Alive() then
		self:HangUp()
	end
	if self:GetNWBool("HePickedUp") and not ValidEntity(self:GetNWEntity("Caller")) then
		self:HangUp(true)
	end
end

function ENT:HangUp(force)
	local ply = self:GetNWEntity("owning_ent")
	local him = self:GetNWEntity("Caller")
	local HisPhone = him:GetNWEntity("phone")

	timer.Remove("PhoneCallCosts"..ply:EntIndex())
	
	if ValidEntity(him) then
		timer.Remove("PhoneCallCosts"..him:EntIndex())
		him:ConCommand("-voicerecord")
	end
	
	if ValidEntity(ply) and ply:IsPlayer() then
		ply:ConCommand("-voicerecord")
	end
	
	if ValidEntity(HisPhone) then 
		self:EmitSound("buttons/combine_button2.wav", 50, 100)
		self:Remove()
		HisPhone:Remove()
	end
	
	if force then
		self:EmitSound("buttons/combine_button2.wav", 50, 100)
		self:Remove()
	end
end
