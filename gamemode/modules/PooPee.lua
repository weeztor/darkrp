if SERVER then includeCS("PooPee.lua") end

PooPee = {}

AddToggleCommand("rp_poopeemod", "poopeemod", true)
AddHelpLabel(-1, HELP_CATEGORY_HUNGERMOD, "rp_poopeemod <1 or 0> - Enable/disable poo pee mod")
if SERVER then
	function PooPee.UpdatePoop(ply)
		if not ValidEntity(ply) then return end
		ply:SetNWInt("Poop", math.Clamp(ply:GetNWInt("Poop") + 1, 0, 100))
		if ply:GetNWInt("Poop") >= 100 then
			GAMEMODE:SetPlayerSpeed(ply, CfgVars["wspd"] * 0.5, CfgVars["rspd"] * 0.5)
		end
	end

	function PooPee.UpdatePee(ply)
		if not ValidEntity(ply) or GetGlobalInt("poopeemod") ~= 1 then return end
		ply:SetNWInt("Pee", math.Clamp(ply:GetNWInt("Pee") + 1, 0, 100) )
		if ply:GetNWInt("Pee") >= 100 then
			PooPee.DoPee(ply)
		end
	end

	function PooPee.PlayerSpawn(ply)
		ply:SetNWInt("Poop", 0)
		ply:SetNWInt("Pee", 0)
		ply:GetTable().LastPeeUpdate = CurTime()
		ply:GetTable().LastPoopUpdate = CurTime()
	end
	hook.Add("PlayerSpawn", "PooPee.PlayerSpawn", PooPee.PlayerSpawn)

	function PooPee.AteFood(ply, food)
		local food2 = string.lower(food)
		if string.find(food2, "milk") or string.find(food2, "bottle") or string.find(food2, "popcan") then
			ply:SetNWInt("Pee", math.Clamp(ply:GetNWInt("Pee") + 9, 0, 100))
			PooPee.UpdatePee(ply)
		else
			ply:SetNWInt("Poop", math.Clamp(ply:GetNWInt("Poop") + 9, 0, 100))
			PooPee.UpdatePoop(ply)
		end
	end

	function PooPee.Think()
		if GetGlobalInt("poopeemod") ~= 1 then return end

		for k, v in pairs(player.GetAll()) do
			if not v:GetTable().LastPeeUpdate then
				v:GetTable().LastPeeUpdate = CurTime()
			end
			
			if not v:GetTable().LastPoopUpdate then
				v:GetTable().LastPoopUpdate = CurTime()
			end
			
			if v:Alive() and CurTime() - v:GetTable().LastPoopUpdate > 12 then
				PooPee.UpdatePoop(v)
				v:GetTable().LastPoopUpdate = CurTime()
			end
			
			if v:Alive() and CurTime() - v:GetTable().LastPeeUpdate > 6  then
				PooPee.UpdatePee(v)
				v:GetTable().LastPeeUpdate = CurTime()
			end
		end
	end
	hook.Add("Think", "PooPee.Think", PooPee.Think)


	function PooPee.DoPoo(ply)
		if GetGlobalInt("poopeemod") ~= 1 or not ply:Alive() or ply:GetNWInt("Poop") < 30 then
			Notify(ply,1,4, "Can't poop!")
			return ""
		end
		local turd = ents.Create("prop_physics")
		turd:SetModel("models/Gibs/HGIBS_spine.mdl")
		turd:SetNWString("Owner", "Shared")
		turd:SetPos(ply:GetPos() + Vector(0,0,32))
		turd:Spawn()
		turd:SetColor(80, 45, 0, 255)
		turd:SetMaterial("models/props_pipes/pipeset_metal") 
		ply:SetNWInt("Poop", 0)
		ply:EmitSound("ambient/levels/canals/swamp_bird2.wav", 50, 80)
		GAMEMODE:SetPlayerSpeed(ply, CfgVars["wspd"] , CfgVars["rspd"] )
		timer.Simple(30, function() if turd:IsValid() then turd:Remove() end end)
		return ""
	end
	AddChatCommand("/poo", PooPee.DoPoo)
	AddChatCommand("/poop", PooPee.DoPoo)

	function PooPee.DoPee(ply)
		if GetGlobalInt("poopeemod") ~= 1 then
			Notify(ply,1,4, "Poo pee mod is disabled")
			return ""
		end
		if not ply:Alive() then return "" end
		
		umsg.Start("PlayerPeeParticles") // usermessage to everyone
			umsg.Entity(ply)
			umsg.Long(ply:GetNWInt("Pee"))
		umsg.End()
		
		local sound = CreateSound(ply, "ambient/water/leak_1.wav")
		sound:Play()
		timer.Simple(ply:GetNWInt("Pee")/10, function() sound:Stop() ply:SetNWInt("Pee", 0) end)
		return "" 
	end
	AddChatCommand("/pee", PooPee.DoPee)
	
	return //The server doesn't have anything more to do in this file. so KTHXBAI
end

function PooPee.HUDPaint()
	if GetGlobalInt("poopeemod") == 1 then 
		local x = 7
		local y = ScrH() - 110 - GetConVarNumber("HudHeight")
		local y2 = y + 10
		
		draw.RoundedBox(4, x - 1, y - 1, GetConVarNumber("HudWidth") , 9, Color(0, 0, 0, 255))
		draw.RoundedBox(4, x, y, GetConVarNumber("HudWidth") * (math.Clamp(LocalPlayer():GetNWInt("Poop"), 0, 100) / 100), 7, Color(80, 45, 0, 255))
		draw.DrawText("poop: "..math.ceil(LocalPlayer():GetNWInt("Poop")) .. "%", "DefaultSmall", GetConVarNumber("HudWidth") / 2, y - 2, Color(255, 255, 255, 255), 1)
		
		draw.RoundedBox(4, x - 1, y2 - 1, GetConVarNumber("HudWidth") , 9, Color(0, 0, 0, 255))
		draw.RoundedBox(4, x, y2, GetConVarNumber("HudWidth") * (math.Clamp(LocalPlayer():GetNWInt("Pee"), 0, 100) / 100), 7, Color(215, 255, 0, 255))
		draw.DrawText("pee: "..math.ceil(LocalPlayer():GetNWInt("Pee")) .. "%", "DefaultSmall", GetConVarNumber("HudWidth") / 2, y2 - 2, Color(255, 255, 255, 255), 1)
	end
end
hook.Add("HUDPaint", "PooPee.HUDPaint", PooPee.HUDPaint)

local function collideback(Particle, HitPos, Normal)
	Particle:SetAngleVelocity(Angle(0, 0, 0))
	local Ang = Normal:Angle()
	Ang:RotateAroundAxis(Normal, Particle:GetAngles().y)
	Particle:SetAngles(Ang)
	
	Particle:SetBounce(1)
	Particle:SetVelocity(Vector(0, 0, -100))
	Particle:SetGravity(Vector(0, 0, -100))
	
	Particle:SetLifeTime(0)
	Particle:SetDieTime(30)
	
	Particle:SetStartSize(10)
	Particle:SetEndSize(0)
	
	Particle:SetStartAlpha(255)
	Particle:SetEndAlpha(0)
end

function PooPee.DoPee(umsg)
	local ply = umsg:ReadEntity()
	local time = umsg:ReadLong()
	if not ValidEntity(ply) then return end
	local centr = ply:GetPos() + Vector(0,0,32)
	local em = ParticleEmitter(centr) 
	for i=1, time * 10 do 
		timer.Simple(i/100, function()
			if not ply:IsValid() then return end
			local part = em:Add("sprites/orangecore2",ply:GetPos() + Vector(0,0,32)) 
			if part then 
				//part:SetColor(215,255,0,255) 
				part:SetVelocity(ply:GetAimVector() * 1000 + Vector(math.random(-50,50),math.random(-50,50),0) ) 
				part:SetDieTime(30) 
				part:SetLifeTime(1) 
				part:SetStartSize(10) 
				part:SetAirResistance( 100 )
				part:SetRoll( math.Rand(0, 360) )
				part:SetRollDelta( math.Rand(-200, 200) )
				part:SetGravity( Vector( 0, 0, -600 ) )
				part:SetCollideCallback(collideback)
				part:SetCollide(true)
				part:SetEndSize(0) 
			end 
		end)
	end 
	em:Finish() 
end
usermessage.Hook("PlayerPeeParticles", PooPee.DoPee)