includeCS("PooPee/cl_init.lua")


PooPee = {}
SetGlobalInt("poopeemod", 0)

AddToggleCommand("rp_poopeemod", "poopeemod", true)
AddHelpLabel(-1, HELP_CATEGORY_HUNGERMOD, "rp_poopeemod <1 or 0> - Enable/disable poo pee mod")

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