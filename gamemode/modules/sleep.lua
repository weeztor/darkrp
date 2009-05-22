KnockoutTime = 5

function ResetKnockouts(player)
	player:SetNetworkedEntity("Ragdoll", NULL)
	player:SetNetworkedFloat("KnockoutTimer", 0)
end
hook.Add("PlayerSpawn", "Knockout", ResetKnockouts)


function KnockoutToggle(player, command, args, caller)
	if not player.SleepSound then
		player.SleepSound = CreateSound(player, "npc/ichthyosaur/water_breath.wav")
	end
	if player:Alive() then
		if player:GetNWFloat("KnockoutTimer") + KnockoutTime < CurTime() then
			if player:GetNWEntity("Ragdoll") ~= NULL then
				player.SleepSound:Stop()
				local ragdoll = player:GetNWEntity("Ragdoll")
				local health = player:Health()
				player:Spawn()
				player:SetHealth(health)
				player:SetPos(ragdoll:GetPos())
				player:SetAngles(Angle(0, ragdoll:GetPhysicsObjectNum(10):GetAngles().Yaw, 0))
				player:UnSpectate()
				player:StripWeapons()
				ragdoll:Remove()
				player:SetNetworkedBool("Knockedout", false)
				player:SetNetworkedEntity("Ragdoll", NULL)
				if player.WeaponsForSleep and player:GetTable().BeforeSleepTeam == player:Team() then
					for k,v in pairs(player.WeaponsForSleep) do
						player:Give(v)
					end
					local cl_defaultweapon = player:GetInfo( "cl_defaultweapon" )
					if ( player:HasWeapon( cl_defaultweapon )  ) then
						player:SelectWeapon( cl_defaultweapon ) 
					end
				else
					GAMEMODE:PlayerLoadout(player)
				end 
				player.WeaponsForSleep = {}
				local RP = RecipientFilter()
				RP:RemoveAllPlayers()
				RP:AddPlayer(player)
				umsg.Start("DarkRPEffects", RP)
					umsg.String("colormod")
					umsg.String("0")
				umsg.End()
				RP:AddAllPlayers()
				if command == true then
					player:Arrest()
				end
			else
				player.WeaponsForSleep = {}
				for k,v in pairs(player:GetWeapons( )) do
					player.WeaponsForSleep[k] = v:GetClass()
				end
				local ragdoll = ents.Create("prop_ragdoll")
				ragdoll:SetPos(player:GetPos())
				ragdoll:SetAngles(Angle(0,player:GetAngles().Yaw,0))
				ragdoll:SetModel(player:GetModel())
				ragdoll:Spawn()
				ragdoll:Activate()
				ragdoll:SetVelocity(player:GetVelocity())
				ragdoll:SetNWInt("OwnerINT", player:EntIndex())
				player:StripWeapons()
				player:Spectate(OBS_MODE_CHASE)
				player:SpectateEntity(ragdoll)
				player:SetNWInt("slp", 1)
				player:SetNetworkedEntity("Ragdoll", ragdoll)
				player:SetNetworkedBool("Knockedout", true)
				player:SetNetworkedFloat("KnockoutTimer", CurTime())
				player:GetTable().BeforeSleepTeam = player:Team()
				//Make sure noone can pick it up:
				SPropProtection.PlayerMakePropOwner(player, ragdoll)
				local RP = RecipientFilter()
				RP:RemoveAllPlayers()
				RP:AddPlayer(player)
				umsg.Start("DarkRPEffects",RP)
					umsg.String("colormod")
					umsg.String("1")
				umsg.End()
				RP:AddAllPlayers()
				player.SleepSound = CreateSound(ragdoll, "npc/ichthyosaur/water_breath.wav")
				player.SleepSound:PlayEx(0.10, 100)
			end
		end
		return ""
	else
		Notify(player, 1, 4, "Sleep is disabled when you are dead.")
		return ""
	end
end
AddChatCommand("/sleep", KnockoutToggle)
AddChatCommand("/wake", KnockoutToggle)
AddChatCommand("/wakeup", KnockoutToggle)

local function DamageSleepers(ent, inflictor, attacker, amount, dmginfo)
	local ownerint = ent:GetNWInt("OwnerINT")
	if ownerint and ownerint ~= 0 then
		for k,v in pairs(player.GetAll()) do 
			if v:EntIndex() == ownerint then
				if attacker == GetWorldEntity() then
					amount = 10
					dmginfo:ScaleDamage(0.1)
				end
				v:SetHealth(v:Health() - amount)
				if v:Health() <= 0 and v:Alive() then
					v:Spawn()
					v:UnSpectate()
					v:SetPos(ent:GetPos())
					v:SetHealth(1)
					v:TakeDamage(1, inflictor, attacker)
					if v.SleepSound then
						v.SleepSound:Stop()
					end
					ent:Remove()
				end
			end
		end
	end
end
hook.Add("EntityTakeDamage", "Sleepdamage", DamageSleepers)
