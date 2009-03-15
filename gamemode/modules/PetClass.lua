if not TEAM_PET then return end
// CREDITS FOR THE MODEL GO TO RAPTOR!
resource.AddFile("materials/models/renamon/rena_light.vmt")
resource.AddFile("materials/models/renamon/rena_light_n.vtf")
resource.AddFile("materials/models/renamon/rena_light.vtf")
resource.AddFile("materials/models/renamon/rena_lightwarp.vtf")
resource.AddFile("models/player/renamon_b5.mdl")

resource.AddFile("sound/Pet/Angry.wav")
resource.AddFile("sound/Pet/Cry.wav")
resource.AddFile("sound/Pet/Growl.wav")
resource.AddFile("sound/Pet/Happy.wav")
resource.AddFile("sound/Pet/Howl.wav")
resource.AddFile("sound/Pet/Meow.wav")
resource.AddFile("sound/Pet/Lick.wav")
resource.AddFile("sound/Pet/Lost.wav")
resource.AddFile("sound/Pet/Question.wav")
resource.AddFile("sound/Pet/Please.wav")

function MakePetSound(ply,cmd,args)
	if ply:Team() == TEAM_PET and (string.find(args[1], "Pet") or string.find(args[1], "vo/sandwicheat09.wav")) then
		ply:EmitSound(args[1], 500,100)
	end
end
concommand.Add("_DoMakeAnimalSound", MakePetSound)

hook.Add("PlayerLoadout", "rp_PetLoadout", function(ply)
	if ply:Team() == TEAM_PET then
		timer.Simple(0.1, function() if not ply:IsAdmin() then ply:StripWeapon("gmod_tool") end end, ply)
	end
end)

hook.Add("PlayerSpawn", "rp_PetPlayerSpawn", function(ply)
	if ply:Team() ~= TEAM_PET then ply:SetNWInt("LocalHungerMod", 0) return end
//	print("PLAYERSPAN!")
	ply:SetNWInt("LocalHungerMod", 1)
	//print(ply:GetNWInt("LocalHungerMod"))
	ply:SetHealth(200)
	ply:SetJumpPower(190 * 1.4)
	timer.Simple(0.1, function() GAMEMODE:SetPlayerSpeed(ply, CfgVars["wspd"] * 1.7, CfgVars["rspd"] * 1.7) end, ply)
end)

//if not HM then return end
function PetThink()
	//print("THINK")
	local found = false
	for k,v in pairs(player.GetAll()) do 
		if v:GetNWInt("LocalHungerMod") == 1 then
			if v:Team() ~= TEAM_PET then
				v:SetJumpPower(190)
				v:SetNWInt("LocalHungerMod", 0)
				v:SetHealth(100)
				timer.Simple(0.1, function() GAMEMODE:SetPlayerSpeed(v, CfgVars["wspd"], CfgVars["rspd"]) end, v)
			end
			found = true break
		elseif v:GetNWInt("LocalHungerMod") ~= 1 and v:Team() == TEAM_PET then
			v:SetJumpPower(190 * 1.4)
			v:SetNWInt("LocalHungerMod", 1)
			v:SetHealth(200)
			timer.Simple(0.1, function() GAMEMODE:SetPlayerSpeed(v, CfgVars["wspd"] * 1.7, CfgVars["rspd"] * 1.7) end, v)
		end
	end
	if GetGlobalInt("hungermod") == 0 and not found then return end

	if CfgVars["hungerspeed"] == 0 then return end

	for k, v in pairs(player.GetAll()) do
		if GetGlobalInt("hungermod") == 0 and v:GetNWInt("LocalHungerMod") == 1 and v:Alive() and CurTime() - v:GetTable().LastHungerUpdate > 1  then
			v:HungerUpdate()
			//print("HUNGERUPDATE")
		elseif GetGlobalInt("hungermod") ~= 0 and v:Alive() and CurTime() - v:GetTable().LastHungerUpdate > 1  then
			v:HungerUpdate()
		end
	end
end
hook.Remove("Think", "HM.Think")// remove the old one to make the new one
hook.Add("Think", "HM.Think", PetThink)

local allowedweps = {"weapon_physgun", "gmod_tool", "gmod_camera", "keys", "bite", "weapon_physcannon"}
function PetsCantPickupWeapons(ply,weapon)
	if ply:Team() == TEAM_PET and not ply:IsAdmin() then
		local found = false
		for k,v in pairs(allowedweps) do if string.lower(weapon:GetClass()) == v then found = true return true end end
		if not found then weapon:Remove() return false end
	end
	return
end
hook.Add("PlayerCanPickupWeapon", "PetsCantPickupWeapons",  PetsCantPickupWeapons)

function CanPlayerEnterVehicle(ply, vehicle, role)
	if ply:Team() == TEAM_PET then return false end
end