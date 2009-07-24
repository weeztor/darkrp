-- 700 000
FPP = FPP or {}
FPP.AntiSpam = {}


local function GhostFreeze(ent, phys)
	ent:SetRenderMode(RENDERMODE_TRANSALPHA)
	ent:DrawShadow(false)
	ent.OldColor = ent.OldColor or {ent:GetColor()}
	ent.StartPos = ent:GetPos()
	ent:SetColor(ent.OldColor[1], ent.OldColor[2], ent.OldColor[3], ent.OldColor[4] - 155)

	ent:SetCollisionGroup( COLLISION_GROUP_WORLD )
	ent.CollisionGroup = COLLISION_GROUP_WORLD
	
	ent.FPPAntiSpamMotionEnabled = phys:IsMoveable()
	phys:EnableMotion(false)
	
	ent.FPPAntiSpamIsGhosted = true
end

local function UnGhost(ply, ent)
	if ent.FPPAntiSpamIsGhosted then
		ent.FPPAntiSpamIsGhosted = nil
		ent:DrawShadow(true)
		if ent.OldCollisionGroup then ent:SetCollisionGroup(ent.OldCollisionGroup) ent.OldCollisionGroup = nil end
		
		if ent.OldColor then
			ent:SetColor(ent.OldColor[1], ent.OldColor[2], ent.OldColor[3], ent.OldColor[4])
		end
		ent.OldColor = nil
		
		
		ent:SetCollisionGroup( COLLISION_GROUP_NONE )
		ent.CollisionGroup = COLLISION_GROUP_NONE
		
		local phys = ent:GetPhysicsObject()
		if phys:IsValid() then 
			phys:EnableMotion(ent.FPPAntiSpamMotionEnabled)
		end
	end
end
hook.Add("PhysgunPickup", "FPP.AntiSpam.Unghost", UnGhost)
hook.Add("GravGunPickupAllowed", "FPP.AntiSpam.Unghost", UnGhost)
hook.Add("PlayerUse", "FPP.AntiSpam.Unghost", UnGhost)
hook.Add("GravGunPunt", "FPP.AntiSpam.Unghost", UnGhost)


function FPP.AntiSpam.CreateEntity(ply, ent, IsDuplicate)
	if not tobool(FPP.Settings.FPP_ANTISPAM.toggle) then return end
	local phys = ent:GetPhysicsObject()
	if not phys:IsValid() then return end
	
	print("volume: ",phys:GetVolume())
	print("ENT ",ent, phys)
	local class = ent:GetClass()
	if phys:GetVolume() and phys:GetVolume() > 700000 and not string.find(class, "constraint") and not string.find(class, "hinge") then
		ply.FPPAntispamBigProp = ply.FPPAntispamBigProp or 0
		ply.FPPAntispamBigProp = ply.FPPAntispamBigProp + 1
		timer.Simple(10*FPP.Settings.FPP_ANTISPAM.bigpropwait, function(ply)
			ply.FPPAntispamBigProp = ply.FPPAntispamBigProp or 0
			ply.FPPAntispamBigProp = math.Max(ply.FPPAntispamBigProp - 1, 0)
		end, ply)
		
		if ply.FPPAntiSpamLastBigProp and ply.FPPAntiSpamLastBigProp > (CurTime() - (FPP.Settings.FPP_ANTISPAM.bigpropwait * ply.FPPAntispamBigProp)) then
			FPP.Notify(ply, "Please wait " .. FPP.Settings.FPP_ANTISPAM.bigpropwait * ply.FPPAntispamBigProp ../*string.sub(tostring(2 - (CurTime() - ply.FPPAntiSpamLastBigProp)), 1, 3) ..*/ " Seconds before spawning a big prop again", false)
			ply.FPPAntiSpamLastBigProp = CurTime()
			ent:Remove()
			return
		end
		
		if not IsDuplicate then
			ply.FPPAntiSpamLastBigProp = CurTime()
		end
		GhostFreeze(ent, phys)
		FPP.Notify(ply, "Your prop is ghosted because it is too big. Interract with it to unghost it.", true)
		return
	end

	if not IsDuplicate then
		ply.FPPAntiSpamCount = ply.FPPAntiSpamCount or 0
		ply.FPPAntiSpamCount = ply.FPPAntiSpamCount + 1
		timer.Simple(ply.FPPAntiSpamCount / FPP.Settings.FPP_ANTISPAM.smallpropdowngradecount, function(ply) if ValidEntity(ply) then ply.FPPAntiSpamCount = ply.FPPAntiSpamCount - 1 end end, ply)
		if ply.FPPAntiSpamCount >= FPP.Settings.FPP_ANTISPAM.smallpropghostlimit and ply.FPPAntiSpamCount <= FPP.Settings.FPP_ANTISPAM.smallpropdenylimit then
			GhostFreeze(ent, phys)
			FPP.Notify(ply, "Your prop is ghosted for antispam, interract with it to unghost it.", true)
			return
		elseif ply.FPPAntiSpamCount > FPP.Settings.FPP_ANTISPAM.smallpropdenylimit then
			ent:Remove()
			FPP.Notify(ply, "Prop removed due to spam", false)
			return
		end
	end
end

function FPP.AntiSpam.DuplicatorSpam(ply)
	ply.FPPAntiSpamLastDuplicate = ply.FPPAntiSpamLastDuplicate or 0
	ply.FPPAntiSpamLastDuplicate = ply.FPPAntiSpamLastDuplicate + 1
	
	timer.Simple(ply.FPPAntiSpamLastDuplicate / FPP.Settings.FPP_ANTISPAM.duplicatorlimit, function(ply) if ValidEntity(ply) then ply.FPPAntiSpamLastDuplicate = ply.FPPAntiSpamLastDuplicate - 1 end end, ply)
	
	if ply.FPPAntiSpamLastDuplicate >= FPP.Settings.FPP_ANTISPAM.duplicatorlimit then
		FPP.Notify(ply, "Can't duplicate due to spam", false)
		return false
	end
	return true
end
