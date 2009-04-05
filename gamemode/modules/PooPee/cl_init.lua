local PooPee = {}

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