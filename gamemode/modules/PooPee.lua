if SERVER then includeCS("PooPee.lua") end

PooPee = {}

AddToggleCommand("rp_poopeemod", "poopeemod", true)
AddHelpLabel(-1, HELP_CATEGORY_HUNGERMOD, "rp_poopeemod <1 or 0> - Enable/disable poo pee mod")
if SERVER then
	function PooPee.UpdatePoop(ply)
		if not ValidEntity(ply) then return end
		ply:SetDarkRPVar("Poop", math.Clamp((ply.DarkRPVars.Poop or 0) + 1, 0, 100))
		if ply.DarkRPVars.Poop >= 100 then
			GAMEMODE:SetPlayerSpeed(ply, CfgVars["wspd"] * 0.5, CfgVars["rspd"] * 0.5)
		end
	end

	function PooPee.UpdatePee(ply)
		if not ValidEntity(ply) or GetGlobalInt("poopeemod") ~= 1 then return end
		ply:SetDarkRPVar("Pee", math.Clamp((ply.DarkRPVars.Pee or 0) + 1, 0, 100) )
		if ply.DarkRPVars.Pee >= 100 then
			PooPee.DoPee(ply)
		end
	end

	function PooPee.PlayerSpawn(ply)
		ply:GetTable().LastPeeUpdate = CurTime()
		ply:GetTable().LastPoopUpdate = CurTime()
	end
	hook.Add("PlayerSpawn", "PooPee.PlayerSpawn", PooPee.PlayerSpawn)

	function PooPee.AteFood(ply, food)
		if GetGlobalInt("poopeemod") ~= 1 then return end
		local food2 = string.lower(food)
		if string.find(food2, "milk") or string.find(food2, "bottle") or string.find(food2, "popcan") then
			ply:SetDarkRPVar("Pee", math.Clamp(ply.DarkRPVars.Pee + 9, 0, 100))
			PooPee.UpdatePee(ply)
		else
			ply:SetDarkRPVar("Poop", math.Clamp(ply.DarkRPVars.Poop + 9, 0, 100))
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
		if not ply:Alive() or ply.DarkRPVars.Poop < 30 then
			Notify(ply,1,6, string.format(LANGUAGE.unable, "/poo", ""))
			return ""
		end
		local turd = ents.Create("prop_physics")
		turd:SetModel("models/Gibs/HGIBS_spine.mdl")
		turd.ShareGravgun = true
		turd:SetPos(ply:GetPos() + Vector(0,0,32))
		turd:Spawn()
		turd:SetColor(80, 45, 0, 255)
		turd:SetMaterial("models/props_pipes/pipeset_metal") 
		ply:SetDarkRPVar("Poop", 0)
		ply:EmitSound("ambient/levels/canals/swamp_bird2.wav", 50, 80)
		GAMEMODE:SetPlayerSpeed(ply, CfgVars["wspd"] , CfgVars["rspd"] )
		timer.Simple(30, function() if turd:IsValid() then turd:Remove() end end)
		return ""
	end
	AddChatCommand("/poo", PooPee.DoPoo)
	AddChatCommand("/poop", PooPee.DoPoo)

	function PooPee.DoPee(ply)
		if GetGlobalInt("poopeemod") ~= 1 then
			Notify(ply,1,4, string.format(LANGUAGE.disabled, "/pee", ""))
			return ""
		end
		if not ply:Alive() then return "" end
		
		umsg.Start("PlayerPeeParticles") -- usermessage to everyone
			umsg.Entity(ply)
			umsg.Long(ply.DarkRPVars.Pee)
		umsg.End()
		
		local sound = CreateSound(ply, "ambient/water/leak_1.wav")
		sound:Play()
		timer.Simple(ply.DarkRPVars.Pee/10, function() sound:Stop() ply:SetDarkRPVar("Pee", 0) end)
		return "" 
	end
	AddChatCommand("/pee", PooPee.DoPee)
	
	return --The server doesn't have anything more to do in this file. so KTHXBAI
end

function PooPee.HUDPaint()
	if (GetGlobalInt("poopeemod") or 0) == 1 then 
		LocalPlayer().DarkRPVars = LocalPlayer().DarkRPVars or {}
		local x = 7
		local y = ScrH() - 110 - GetConVarNumber("HudHeight")
		local y2 = y + 10
		local poop = LocalPlayer().DarkRPVars.Poop or 0
		local pee = LocalPlayer().DarkRPVars.Pee or 0
		
		draw.RoundedBox(4, x - 1, y - 1, GetConVarNumber("HudWidth") , 9, Color(0, 0, 0, 255))
		draw.RoundedBox(4, x, y, GetConVarNumber("HudWidth") * (math.Clamp(poop, 0, 100) / 100), 7, Color(80, 45, 0, 255))
		draw.DrawText("poop: "..math.ceil(poop) .. "%", "DefaultSmall", GetConVarNumber("HudWidth") / 2, y - 2, Color(255, 255, 255, 255), 1)
		
		draw.RoundedBox(4, x - 1, y2 - 1, GetConVarNumber("HudWidth") , 9, Color(0, 0, 0, 255))
		draw.RoundedBox(4, x, y2, GetConVarNumber("HudWidth") * (math.Clamp(pee, 0, 100) / 100), 7, Color(215, 255, 0, 255))
		draw.DrawText("pee: "..math.ceil(pee) .. "%", "DefaultSmall", GetConVarNumber("HudWidth") / 2, y2 - 2, Color(255, 255, 255, 255), 1)
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