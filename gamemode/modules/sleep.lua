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
				player:Spawn()
				player:SetPos(ragdoll:GetPos())
				player:SetAngles(Angle(0, ragdoll:GetPhysicsObjectNum(10):GetAngles().Yaw, 0))
				player:UnSpectate()
				player:StripWeapons()
				ragdoll:Remove()
				player:SetNetworkedBool("Knockedout", false)
				player:SetNetworkedEntity("Ragdoll", NULL)
				if player.WeaponsForSleep then
					for k,v in pairs(player.WeaponsForSleep) do
						player:Give(v)
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
		Notify(player, 1, 4, "Sleep Disabled When You Are Dead.")
		return ""
	end
end

AddChatCommand("/sleep", KnockoutToggle)
AddChatCommand("/wake", KnockoutToggle)
AddChatCommand("/wakeup", KnockoutToggle)
