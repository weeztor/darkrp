local timeLeft = 10
local timeLeft2 = 10
local stormOn = false
local zombieOn = false
local maxZombie = 10

RPArrestedPlayersPositions = {}
VoteCopOn = false

function ControlZombie()
	timeLeft2 = timeLeft2 - 1

	if timeLeft2 < 1 then
		if zombieOn then
			timeLeft2 = math.random(300,500)
			zombieOn = false
			timer.Stop("start2")
			ZombieEnd()
		else
			timeLeft2 = math.random(150,300)
			zombieOn = true
			timer.Start("start2")
			DB.RetrieveZombies()
			ZombieStart()
		end
	end
end

function ZombieStart()
	for k, v in pairs(player.GetAll()) do
		if v:Alive() then
			v:PrintMessage(HUD_PRINTCENTER, "WARNING: Zombies are approaching!")
			v:PrintMessage(HUD_PRINTTALK, "WARNING: Zombies are approaching!")
		end
	end
end

function ZombieEnd()
	for k, v in pairs(player.GetAll()) do
		if v:Alive() then
			v:PrintMessage(HUD_PRINTCENTER, "Zombies are leaving.")
			v:PrintMessage(HUD_PRINTTALK, "Zombies are leaving.")
		end
	end
end

function StormStart()
	for k, v in pairs(player.GetAll()) do
		if v:Alive() then
			v:PrintMessage(HUD_PRINTCENTER, "WARNING: Meteor storm approaching!")
			v:PrintMessage(HUD_PRINTTALK, "WARNING: Meteor storm approaching!")
		end
	end
end

function StormEnd()
	for k, v in pairs(player.GetAll()) do
		if v:Alive() then
			v:PrintMessage(HUD_PRINTCENTER, "Meteor storm passing.")
			v:PrintMessage(HUD_PRINTTALK, "Meteor storm passing.")
		end
	end
end

function ControlStorm()
	timeLeft = timeLeft - 1

	if timeLeft < 1 then
		if stormOn then
			timeLeft = math.random(300,500)
			stormOn = false
			timer.Stop("start")
			StormEnd()
		else
			timeLeft = math.random(60,90)
			stormOn = true
			timer.Start("start")
			StormStart()
		end
	end
end

function StartShower()
	timer.Adjust("start", math.random(.5,1.5), 0, StartShower)
	for k, v in pairs(player.GetAll()) do
		if math.random(0, 2) == 0 then
			if v:Alive() then
				AttackEnt(v)
			end
		end
	end
end

function DrugPlayer(ply)
	if not ValidEntity(ply) then return end
	local RP = RecipientFilter()
	RP:RemoveAllPlayers()
	RP:AddPlayer(ply)
	umsg.Start("DarkRPEffects", RP)
		umsg.String("Drugged")
		umsg.String("1")
	umsg.End()
	
	RP:AddAllPlayers()
	
	ply:SetJumpPower(300)
	GAMEMODE:SetPlayerSpeed(ply, CfgVars["wspd"] * 2, CfgVars["rspd"] * 2)
	
	local IDSteam = string.gsub(ply:SteamID(), ":", "")
	if not timer.IsTimer(IDSteam.."DruggedHealth") and not timer.IsTimer(IDSteam) then
		ply:SetHealth(ply:Health() + 100)
		timer.Create(IDSteam.."DruggedHealth", 60/(100 + 5), 100 + 5, function() ply:SetHealth(ply:Health() - 1) end)
		timer.Create(IDSteam, 60, 1, UnDrugPlayer, ply)
	end
end

function UnDrugPlayer(ply)
	if not ValidEntity(ply) then return end
	local RP = RecipientFilter()
	RP:RemoveAllPlayers()
	RP:AddPlayer(ply)
	local IDSteam = string.gsub(ply:SteamID(), ":", "")
	timer.Remove(IDSteam.."DruggedHealth")
	timer.Remove(IDSteam)
	umsg.Start("DarkRPEffects", RP)
		umsg.String("Drugged")
		umsg.String("0")
	umsg.End()
	RP:AddAllPlayers()
	ply:SetJumpPower(190)
	GAMEMODE:SetPlayerSpeed(ply, CfgVars["wspd"], CfgVars["rspd"] )	
end

function AttackEnt(ent)
	meteor = ents.Create("meteor")
	meteor.nodupe = true
	meteor:Spawn()
	meteor:SetTarget(ent)
end

function PlayerDist(npcPos)
	local playDis
	local currPlayer
	for k, v in pairs(player.GetAll()) do
		local tempPlayDis = v:GetPos():Distance(npcPos:GetPos())

		if playDis == nil then
			playDis = tempPlayDis
			currPlayer = v
		end

		if tempPlayDis < playDis then
			playDis = tempPlayDis
			currPlayer = v
		end
	end

	return currPlayer
end

function MoveZombie()
	local activePlayers = false

	for k, v in pairs(player.GetAll()) do
		activePlayers = true
	end

	if activePlayers then
		local tb1 = table.Add(ents.FindByClass("npc_antlion"),ents.FindByClass("npc_fastzombie"))
		local tb2 = table.Add(ents.FindByClass("npc_zombie"),ents.FindByClass("npc_headcrab_fast"))
		local tb3 = table.Add(tb1,tb2)
		local tb4 = table.Add(tb3,ents.FindByClass("npc_headcrab"))

		for a, b in pairs(tb4) do
			local newpos = b:GetPos() + ((PlayerDist(b):GetPos()-b:GetPos()):Normalize()*500)

			if PlayerDist(b):GetPos():Distance(b:GetPos()) > 500 then
				b:AddEntityRelationship(PlayerDist(b), 1, 99)
				b:SetLastPosition(newpos)
				b:SetSchedule(71)
			end
		end
	end
	timer.Create("move", .5, 0, MoveZombie)
	timer.Stop("move")
end

function LoadTable(ply)
	ply:SetNWInt("numPoints", table.getn(zombieSpawns))

	for k, v in pairs(zombieSpawns) do
		local Sep = (string.Explode(" " ,v))
		ply:SetNWVector("zPoints" .. k, Vector(tonumber(Sep[1]),tonumber(Sep[2]),tonumber(Sep[3])))
	end
end

function ReMoveZombie(ply, index)
	if ply:HasPriv(ADMIN) then
		if not index or zombieSpawns[tonumber(index)] == nil then
			Notify(ply, 1, 4, "Zombie Spawn " .. tostring(index) .. " does not exist.")
		else
			DB.RetrieveZombies()
			Notify(ply, 1, 4, "Zombie spawn removed.")
			table.remove(zombieSpawns,index)
			DB.StoreZombies()
			if ply:GetNWBool("zombieToggle") then
				LoadTable(ply)
			end
		end
	else
		Notify(ply, 1, 4, "Must be an admin.")
	end
	return ""
end
AddChatCommand("/removezombie", ReMoveZombie)

function AddZombie(ply)
	if ply:HasPriv(ADMIN) then
		DB.RetrieveZombies()
		table.insert(zombieSpawns, tostring(ply:GetPos()))
		DB.StoreZombies()
		if ply:GetNWBool("zombieToggle") then LoadTable(ply) end
		Notify(ply, 1, 4, "Zombie spawn added.")
	else
		Notify(ply, 1, 4, "Must be an admin.")
	end
	return ""
end
AddChatCommand("/addzombie", AddZombie)

function ToggleZombie(ply)
	if ply:HasPriv(ADMIN) then
		if not ply:GetNWBool("zombieToggle") then
			DB.RetrieveZombies()
			ply:SetNWBool("zombieToggle", true)
			LoadTable(ply)
			Notify(ply, 1, 4, "Show Zombies Enabled")
		else
			ply:SetNWBool("zombieToggle", false)
			Notify(ply, 1, 4, "Show Zombies Disabled")
		end
	else
		Notify(ply, 1, 4, "Must be an admin.")
	end
	return ""
end
AddChatCommand("/showzombie", ToggleZombie)

function SpawnZombie()
	timer.Start("move")
	if GetAliveZombie() < maxZombie then
		if table.getn(zombieSpawns) > 0 then
			local zombieType = math.random(2, 2)
			if zombieType == 1 then
				local zombie1 = ents.Create("npc_zombie")
				zombie1:SetPos(DB.RetrieveRandomZombieSpawnPos())
				zombie1.nodupe = true
				zombie1:Spawn()
				zombie1:Activate()
			elseif zombieType == 2 then
				local zombie2 = ents.Create("npc_fastzombie")
				zombie2:SetPos(DB.RetrieveRandomZombieSpawnPos())
				zombie2.nodupe = true
				zombie2:Spawn()
				zombie2:Activate()
			elseif zombieType == 3 then
				local zombie3 = ents.Create("npc_antlion")
				zombie3:SetPos(DB.RetrieveRandomZombieSpawnPos())
				zombie3.nodupe = true
				zombie3:Spawn()
				zombie3:Activate()
			elseif zombieType == 4 then
				local zombie4 = ents.Create("npc_headcrab_fast")
				zombie4:SetPos(DB.RetrieveRandomZombieSpawnPos())
				zombie4.nodupe = true
				zombie4:Spawn()
				zombie4:Activate()
			end
		end
	end
end

function GetAliveZombie()
	local zombieCount = 0

	for k, v in pairs(ents.FindByClass("npc_zombie")) do
		zombieCount = zombieCount + 1
	end

	for k, v in pairs(ents.FindByClass("npc_fastzombie")) do
		zombieCount = zombieCount + 1
	end

	for k, v in pairs(ents.FindByClass("npc_antlion")) do
		zombieCount = zombieCount + 1
	end

	for k, v in pairs(ents.FindByClass("npc_headcrab_fast")) do
		zombieCount = zombieCount + 1
	end

	return zombieCount
end

function ZombieMax(ply, args)
	if ply:HasPriv(ADMIN) then
		maxZombie = tonumber(args)
		Notify(ply, 1, 4, "Max zombies set.")
	end

	return ""
end
AddChatCommand("/zombiemax", ZombieMax)

local weaponClasses = {}
weaponClasses["weapon_deagle2"] = "models/weapons/w_pist_deagle.mdl"
weaponClasses["weapon_fiveseven2"] = "models/weapons/w_pist_fiveseven.mdl"
weaponClasses["weapon_glock2"] = "models/weapons/w_pist_glock18.mdl"
weaponClasses["weapon_ak472"] = "models/weapons/w_rif_ak47.mdl"
weaponClasses["weapon_mp52"] = "models/weapons/w_smg_mp5.mdl"
weaponClasses["weapon_m42"] = "models/weapons/w_rif_m4a1.mdl"
weaponClasses["weapon_mac102"] = "models/weapons/w_smg_mac10.mdl"
weaponClasses["weapon_para2"] = "models/weapons/w_mach_m249para.mdl"
weaponClasses["weapon_pumpshotgun2"] = "models/weapons/w_shot_m3super90.mdl"
weaponClasses["weapon_tmp2"] = "models/weapons/w_smg_tmp.mdl"
weaponClasses["ls_sniper"] = "models/weapons/w_snip_g3sg1.mdl"
weaponClasses["weapon_usp2"] = "models/weapons/w_pist_usp.mdl"
weaponClasses["weapon_p2282"] = "models/weapons/w_pist_p228.mdl"
weaponClasses["weapon_p90"] = "models/weapons/w_smg_p90.mdl"
weaponClasses["weapon_knife2"] = "models/weapons/w_knife_t.mdl"

function DropWeapon(ply)
	local trace = {}
	
	trace.start = ply:EyePos()
	trace.endpos = trace.start + ply:GetAimVector() * 85
	trace.filter = ply

	local tr = util.TraceLine(trace)
	local ent = ply:GetActiveWeapon()
	if not ValidEntity(ent) then return "" end
	local class = ent:GetClass()
	
	local model = nil
	
	for k, v in pairs(weaponClasses) do
		if class == k then model = v end
	end
	
	if model then
		ply:StripWeapon(class)
		local weapon = ents.Create("spawned_weapon")
		weapon:SetModel(model)
		weapon:SetNWString("weaponclass", class)
		weapon:SetPos(tr.HitPos)
		weapon:SetNWString("Owner", "Shared")
		weapon.nodupe = true
		weapon:Spawn()
	else
		Notify(ply, 1, 4, "This weapon can not be dropped!")
	end
	return ""
end
AddChatCommand("/drop", DropWeapon)
AddChatCommand("/dropweapon", DropWeapon)
AddChatCommand("/weapondrop", DropWeapon)

function UnWarrant(ply, target)
	target:SetNWBool("warrant", false)
	Notify(ply, 1, 4, "Search warrant for " .. target:Nick() .. " has expired!")
end 

function SetWarrant(ply, target)
	target:SetNWBool("warrant", true)
	timer.Simple(CfgVars["searchtime"], UnWarrant, ply, target)
	for a, b in pairs(player.GetAll()) do
		b:PrintMessage(HUD_PRINTCENTER, "Search warrant approved for " .. target:Nick() .. "!")
	end
	Notify(ply, 1, 4, "You can search his house now.")
end

function FinishWarrant(choice, mayor, initiator, target)
	if choice == 1 then
		SetWarrant(initiator, target)
	else
		Notify(initiator, 1, 4, "Mayor " .. mayor:Nick() .. " has denied your search warrant request.")
	end
	return ""
end

function SearchWarrant(ply, args)
	local t = ply:Team()
	if not (t == TEAM_POLICE or t == TEAM_MAYOR or t == TEAM_CHIEF) then
		Notify(ply, 1, 4, "You must be a Cop or the Mayor.")
	else
		local p = FindPlayer(args)
		if p and p:Alive() then
			-- If we're the Mayor, set the search warrant
			if t == TEAM_MAYOR then
				SetWarrant(ply, p)
			else -- If we're CP or Chief
				-- Find the mayor
				local m = nil
				for k, v in pairs(player.GetAll()) do
					if v:Team() == TEAM_MAYOR then
						m = v
						break
					end
				end
				-- If we found the mayor
				if m ~= nil then
					-- request a search warrent for player "p"
					ques:Create(ply:Nick() .. " wants a search warrant for " .. p:Nick(), p:EntIndex() .. "warrant", m, 40, FinishWarrant, ply, p)
					Notify(ply, 1, 4, "Search warrant request sent to Mayor " .. m:Nick() .. "!")
				else
					-- there is no mayor, CPs can set warrants.
					SetWarrant(ply, p)
				end
			end
		else
			Notify(ply, 1, 4, "Player is dead or does not exist.")
		end
	end
	return ""
end
AddChatCommand("/warrant", SearchWarrant)
AddChatCommand("/warrent", SearchWarrant) -- Most players can't spell for some reason

function PlayerWanted(ply, args)
	local t = ply:Team()
	if not (t == TEAM_POLICE or t == TEAM_MAYOR or t == TEAM_CHIEF) then
		Notify(ply, 1, 4, "You must be a Cop or the Mayor.")
	else
		local p = FindPlayer(args)
		if p and p:Alive() then
			p:SetNWBool("wanted", true)
			for a, b in pairs(player.GetAll()) do
				b:PrintMessage(HUD_PRINTCENTER, p:Nick() .. " is wanted by the Police!")
				timer.Create(p:Nick() .. " wantedtimer", CfgVars["wantedtime"], 1, TimerUnwanted, ply, args)
			end
		else
			Notify(ply, 1, 4, "Player is dead or does not exist.")
		end
	end
	return ""
end
AddChatCommand("/wanted", PlayerWanted)

function PlayerUnWanted(ply, args)
	local t = ply:Team()
	if not (t == TEAM_POLICE or t == TEAM_MAYOR or t == TEAM_CHIEF) then
		Notify(ply, 1, 4, "You must be a Cop or the Mayor.")
	else
		local p = FindPlayer(args)
		if p and p:Alive() then
			p:SetNWBool("wanted", false)
			for a, b in pairs(player.GetAll()) do
				b:PrintMessage(HUD_PRINTCENTER, p:Nick() .. " is no longer wanted by the Police.")
				timer.Destroy(p:Nick() .. " wantedtimer")
			end
		else
			Notify(ply, 1, 4, "Player is dead or does not exist.")
		end
	end
	return ""
end
AddChatCommand("/unwanted", PlayerUnWanted)

function TimerUnwanted(ply, args)
	local p = FindPlayer(args)
	if p and p:Alive() then
		p:SetNWBool("wanted", false)
		for a, b in pairs(player.GetAll()) do
			b:PrintMessage(HUD_PRINTCENTER, "The wanted for " .. p:Nick() .. " has expired.")
			timer.Destroy(p:Nick() .. " wantedtimer")
		end
	else
		return ""
	end
end

function SetSpawnPos(ply, args)
	if not ply:HasPriv(ADMIN) and not ply:IsAdmin() and not ply:IsSuperAdmin() then return "" end

	local pos = string.Explode(" ", tostring(ply:GetPos()))
	local selection = "citizen"
	local t = 99

	if args == "citizen" then
		t = TEAM_CITIZEN
		Notify(ply, 1, 4,  "Citizen Spawn Position set.")
	elseif args == "cp" then
		t = TEAM_POLICE
		Notify(ply, 1, 4,  "CP Spawn Position set.")
	elseif args == "mayor" then
		t = TEAM_MAYOR
		Notify(ply, 1, 4,  "Mayor Spawn Position set.")
	elseif args == "gangster" then
		t = TEAM_GANG
		Notify(ply, 1, 4,  "Gangster Spawn Position set.")
	elseif args == "mobboss" then
		t = TEAM_MOB
		Notify(ply, 1, 4,  "Mob Boss Spawn Position set.")
	elseif args == "gundealer" then
		t = TEAM_GUN
		Notify(ply, 1, 4,  "Gun Dealer Spawn Position set.")
	elseif args == "medic" then
		t = TEAM_MEDIC
		Notify(ply, 1, 4,  "Medic Spawn Position set.")
	elseif args == "cook" then
		t = TEAM_COOK
		Notify(ply, 1, 4,  "Cook Spawn Position set.")
	elseif args == "chief" then
		t = TEAM_CHIEF
		Notify(ply, 1, 4,  "Chief Spawn Position set.")
	end
	
	for k,v in pairs(RPExtraTeams) do
		if args == v.command then
			t = 9 + k
			Notify(ply, 1, 4,  v.name .. " Spawn Position set.")
		end
	end

	if t ~= 99 then
		DB.StoreTeamSpawnPos(t, pos)
	end

	return ""
end
AddChatCommand("/setspawn", SetSpawnPos)

function StartStorm(ply)
	if ply:HasPriv(ADMIN) then
		timer.Start("stormControl")
		Notify(ply, 1, 4, "Meteor Storm enabled.")
	end
	return ""
end
AddChatCommand("/enablestorm", StartStorm)

function HelpCop(ply)
	ply:SetNWBool("helpCop", not ply:GetNWBool("helpCop"))
	return ""
end
AddChatCommand("/cophelp", HelpCop)

function HelpMayor(ply)
	ply:SetNWBool("helpMayor", not ply:GetNWBool("helpMayor"))
	return ""
end
AddChatCommand("/mayorhelp", HelpMayor)

function HelpZombie(ply)
	ply:SetNWBool("helpZombie", not ply:GetNWBool("helpZombie"))
	return ""
end
AddChatCommand("/zombiehelp", HelpZombie)

function HelpBoss(ply)
	ply:SetNWBool("helpBoss", not ply:GetNWBool("helpBoss"))
	return ""
end
AddChatCommand("/mobbosshelp", HelpBoss)

function HelpAdmin(ply)
	ply:SetNWBool("helpAdmin", not ply:GetNWBool("helpAdmin"))
	return ""
end
AddChatCommand("/adminhelp", HelpAdmin)

function closeHelp(ply)
	ply:SetNWBool("helpCop", false)
	ply:SetNWBool("helpBoss", false)
	ply:SetNWBool("helpMayor", false)
	ply:SetNWBool("helpZombie", false)
	ply:SetNWBool("helpAdmin", false)
	return ""
end
AddChatCommand("/x", closeHelp)

function RemoveItem(ply)
	local trace = ply:GetEyeTrace()
	if ValidEntity(trace.Entity) and trace.Entity.SID and (trace.Entity.SID == ply.SID or ply:HasPriv(ADMIN)) then
		trace.Entity:Remove()
	end
	return ""
end
AddChatCommand("/rm", RemoveItem)

function RemoveLetters(ply)
	for k, v in pairs(ents.FindByClass("letter")) do
		if v.SID == ply.SID then v:Remove() end
	end
	Notify(ply, 1, 4, "Your letters were cleaned up.")
	return ""
end
AddChatCommand("/removeletters", RemoveLetters)

function StopStorm(ply)
	if ply:HasPriv(ADMIN) then
		timer.Stop("stormControl")
		stormOn = false
		timer.Stop("start")
		StormEnd()
		Notify(ply, 1, 4, "Meteor Storm disabled.")
		return ""
	end
end
AddChatCommand("/disablestorm", StopStorm)

function StartZombie(ply)
	if ply:HasPriv(ADMIN) then
		timer.Start("zombieControl")
		Notify(ply, 1, 4, "Zombies enabled.")
	end
	return ""
end
AddChatCommand("/enablezombie", StartZombie)

function StopZombie(ply)
	if ply:HasPriv(ADMIN) then
		timer.Stop("zombieControl")
		zombieOn = false
		timer.Stop("start2")
		ZombieEnd()
		Notify(ply, 1, 4, "Zombies disabled.")
		return ""
	end
end
AddChatCommand("/disablezombie", StopZombie)


function RPName(ply, args)
	if CfgVars["allowrpnames"] ~= 1 then
		Notify(ply, 1, 4, "Changing your RP name is disabled on this server!")
		return ""
	end

	local len = string.len(args)
	local low = string.lower(args)

	if len > 30 then
		Notify(ply, 1, 4, "Please choose a name of 30 characters or less!")
		return ""
	elseif len < 3 then
		Notify(ply, 1, 4, "Please choose a name of 3 characters or more!")
		return ""
	end

	if low == "ooc" or low == "shared" or low == "world" or low == "n/a" then
		Notify(ply, 1, 4, "That's not funny. Choose a proper RP name please.")
		return ""
	end
	
	//update the door names
	for k,v in pairs(ents.GetAll()) do
		if v:IsDoor() and v:GetNWInt("Ownerz") == ply:EntIndex() then
			v:SetNWString("OwnerName", ply:Nick())
		end
	end

	ply:SetRPName(args)
	NotifyAll(2, 6, "Steam player: " .. ply:SteamName() .. " changed his / her RP name to: " .. args)
	return ""
end
AddChatCommand("/rpname", RPName)
AddChatCommand("/name", RPName)
AddChatCommand("/nick", RPName)

function SetPrice(ply, args)
	if args == "" then return "" end

	local a = tonumber(args)
	if not a then return "" end
	local b = math.floor(a)
	if b < 0 then return "" end
	local trace = {}

	trace.start = ply:EyePos()
	trace.endpos = trace.start + ply:GetAimVector() * 85
	trace.filter = ply

	local tr = util.TraceLine(trace)

	if ValidEntity(tr.Entity) and (tr.Entity:GetNWBool("gunlab") or tr.Entity:GetNWBool("microwave") or tr.Entity:GetClass() == "drug_lab") and tr.Entity.SID == ply.SID then
		tr.Entity:SetNWInt("price", b)
	else
		Notify(ply, 1, 4, "Must be looking at a Gun Lab, druglab or Microwave!")
	end
	return ""
end
AddChatCommand("/price", SetPrice)
AddChatCommand("/setprice", SetPrice)

local buyPistols = {}
buyPistols["deagle"] = {}
buyPistols["deagle"]["weapon_deagle2"] = "models/weapons/w_pist_deagle.mdl"
buyPistols["fiveseven"] = {}
buyPistols["fiveseven"]["weapon_fiveseven2"] = "models/weapons/w_pist_fiveseven.mdl"
buyPistols["glock"] = {}
buyPistols["glock"]["weapon_glock2"] = "models/weapons/w_pist_glock18.mdl"
buyPistols["p228"] = {}
buyPistols["p228"]["weapon_p2282"] = "models/weapons/w_pist_p228.mdl"


function BuyPistol(ply, args)
	if args == "" then return "" end
	if RPArrestedPlayers[ply:SteamID()] then return "" end

	if CfgVars["noguns"] == 1 then
		Notify(ply, 1, 4, "Guns are disabled!")
		return ""
	end

	local trace = {}
	trace.start = ply:EyePos()
	trace.endpos = trace.start + ply:GetAimVector() * 85
	trace.filter = ply

	local tr = util.TraceLine(trace)
	
	local class = nil
	local model = nil
	for k, v in pairs(buyPistols) do
		if k == args then
			for cls, mdl in pairs(v) do
				class = cls
				model = mdl
			end
		end
	end
	local custom = false
	local price = 0
	for k,v in pairs(CustomShipments) do
		if v.seperate and v.name == args then
			custom = v
			class = v.entity
			model = v.model
			price = v.pricesep
			local canbuy = false
			if #v.allowed == 0 then canbuy = true end
			for a,b in pairs(v.allowed) do
				if ply:Team() == b then
					canbuy = true
				end
			end
			
			if not canbuy then
				Notify(ply, 1, 4, "You do not have the correct class to buy this pistol!")
				return ""
			end
		end
	end
	
	if not class then
		Notify(ply, 1, 4, "Weapon not available!")
		return ""
	end
	
	if (not custom or (#custom.allowed == 1 and custom[1] == TEAM_GUN)) and CfgVars["restrictbuypistol"] ~= 0 and ply:Team() ~= TEAM_GUN and team.NumPlayers(TEAM_GUN) > 0 then
		Notify(ply, 1, 4, "/buy is disabled because there are Gun Dealers.")
		return ""
	end
	if not custom then
		if ply:Team() == TEAM_GUN then
			price = math.ceil(GetGlobalInt(args .. "cost") * 0.88)
		else
			price = GetGlobalInt(args .. "cost")
		end
	end
	
	if not ply:CanAfford(price) then
		Notify(ply, 1, 4, "Can not afford this!")
		return ""
	end
	
	ply:AddMoney(-price)
	
	Notify(ply, 1, 4, "You bought a " .. args .. " for " .. CUR .. tostring(price))
	
	local weapon = ents.Create("spawned_weapon")
	weapon:SetModel(model)
	weapon:SetNWString("weaponclass", class)
	weapon:SetNWString("Owner", "Shared")
	weapon:SetPos(tr.HitPos)
	weapon.nodupe = true
	weapon:Spawn()

	return ""
end
AddChatCommand("/buy", BuyPistol)

local rifleWeights = {}
rifleWeights["ak47"] = 4.0
rifleWeights["mp5"] = 3.0
rifleWeights["m16"] = 3.0
rifleWeights["mac10"] = 2.5
rifleWeights["shotgun"] = 3.3
rifleWeights["sniper"] = 5.9

function BuyShipment(ply, args)
	if args == "" then return "" end

	local trace = {}
	trace.start = ply:EyePos()
	trace.endpos = trace.start + ply:GetAimVector() * 85
	trace.filter = ply

	local tr = util.TraceLine(trace)

	if RPArrestedPlayers[ply:SteamID()] then return "" end
	
	local found = false
	for k, v in pairs(rifleWeights) do
		if k == args then found = true 
			if ply:Team() ~= TEAM_GUN then
				Notify(ply, 1, 4, "Must be a Gun Dealer to buy gun shipments!")
				return ""
			end
		end
	end
	for k,v in pairs(CustomShipments) do
		if string.lower(args) == string.lower(v.name) and not v.noship then
			found = v
			local canbecome = false
			for a,b in pairs(v.allowed) do
				if ply:Team() == b then
					canbecome = true
				end
			end
			if not canbecome then
				Notify(ply, 1, 4, "Cannot buy this shipment because you don't have the correct class!")
				return "" 
			end
		end
	end
	
	if not found then
		Notify(ply, 1, 4, "Weapon not available!")
		return ""
	end
	
	local cost
	if found == true then
		cost = GetGlobalInt(args .. "cost")
	else
		cost = found.price
	end
	
	if not ply:CanAfford(cost) then
		Notify(ply, 1, 4, "Can not afford this!")
		return ""
	end
	
	ply:AddMoney(-cost)
	Notify(ply, 1, 4, "You bought a Shipment of " .. args .. "s for " .. CUR .. tostring(cost))
	local crate = ents.Create("spawned_shipment")
	crate.SID = ply.SID
	if found == true then
		crate:SetContents(args, 10, rifleWeights[args])
	else
		crate:SetContents(found.name, found.amount, found.weight)
	end
	crate:SetPos(Vector(tr.HitPos.x, tr.HitPos.y, tr.HitPos.z))
	crate.nodupe = true
	crate:Spawn()
	if type(found) == "table" and found.shipmodel then
		crate:SetModel(found.shipmodel)
		crate:PhysicsInit(SOLID_VPHYSICS)
		crate:SetMoveType(MOVETYPE_VPHYSICS)
		crate:SetSolid(SOLID_VPHYSICS)
	end
	
	return ""
end
AddChatCommand("/buyshipment", BuyShipment)

function BuyDrugLab(ply)
	if args == "" then return "" end

	local trace = {}
	trace.start = ply:EyePos()
	trace.endpos = trace.start + ply:GetAimVector() * 85
	trace.filter = ply

	if RPArrestedPlayers[ply:SteamID()] then return "" end
	
	if ply:Team() ~= TEAM_GANG and ply:Team() ~= TEAM_MOB then
		Notify(ply, 1, 4, "Must be a gangster or mobboss!")
		return "" 
	end

	local tr = util.TraceLine(trace)

	local cost = GetGlobalInt("druglabcost")
	if not ply:CanAfford(cost) then
		Notify(ply, 1, 4, "Can not afford this!")
		return ""
	end
	if ply:GetNWInt("maxDrug") == CfgVars["maxdruglabs"] then
		Notify(ply, 1, 4, "Max Drug Labs reached!")
		return ""
	end
	ply:AddMoney(-cost)
	Notify(ply, 1, 4, "You bought a Drug Lab for " .. CUR .. tostring(cost))
	local druglab = ents.Create("drug_lab")
	druglab:SetNWEntity("owning_ent", ply)
	druglab:SetNWString("Owner", ply:Nick())
	druglab:SetPos(tr.HitPos)
	druglab.SID = ply.SID
	druglab.onlyremover = true
	druglab:Spawn()
	return ""
end
AddChatCommand("/buydruglab", BuyDrugLab)

function BuyMicrowave(ply)
	if args == "" then return "" end

	local trace = {}
	trace.start = ply:EyePos()
	trace.endpos = trace.start + ply:GetAimVector() * 85
	trace.filter = ply

	if RPArrestedPlayers[ply:SteamID()] then return "" end
	local tr = util.TraceLine(trace)

	local cost = GetGlobalInt("microwavecost")

	if not ply:CanAfford(cost) then
		Notify(ply, 1, 4, "Can not afford this!")
		return ""
	end

	if ply:GetNWInt("maxmicrowaves") == CfgVars["maxmicrowaves"] then
		Notify(ply, 1, 4, "Max Microwaves reached!")
		return ""
	end

	if ply:Team() == TEAM_COOK then
		ply:AddMoney(-cost)
		Notify(ply, 1, 4, "You bought a Microwave for " .. CUR .. tostring(cost))
		local microwave = ents.Create("microwave")
		microwave:SetNWInt("price", GetGlobalInt("microwavefoodcost"))
		microwave:SetNWEntity("owning_ent", ply)
		microwave:SetNWString("Owner", ply:Nick())
		microwave:SetNWBool("microwave", true)
		microwave:SetPos(tr.HitPos)
		microwave.nodupe = true
		microwave:Spawn()
		microwave.SID = ply.SID
		return ""
	else
		Notify(ply, 1, 4, "You must be a Cook to buy this!")
	end
	return ""
end
AddChatCommand("/buymicrowave", BuyMicrowave)

function BuyGunlab(ply)
	if args == "" then return "" end

	local trace = {}
	trace.start = ply:EyePos()
	trace.endpos = trace.start + ply:GetAimVector() * 85
	trace.filter = ply

	if RPArrestedPlayers[ply:SteamID()] then return "" end
	local tr = util.TraceLine(trace)

	local cost = GetGlobalInt("gunlabcost")

	if not ply:CanAfford(cost) then
		Notify(ply, 1, 4, "Can not afford this!")
		return ""
	end
	if ply:GetNWInt("maxgunlabs") == CfgVars["maxgunlabs"] then
		Notify(ply, 1, 4, "Max Gun Labs reached!")
		return ""
	end
	if ply:Team() == TEAM_GUN then
		ply:AddMoney(-cost)
		Notify(ply, 1, 4, "You bought a Gun Lab for " .. CUR .. tostring(cost))
		local gunlab = ents.Create("gunlab")
		gunlab:SetNWEntity("owning_ent", ply)
		gunlab:SetNWString("Owner", ply:Nick())
		gunlab:SetNWInt("price", GetGlobalInt("p228cost"))
		gunlab:SetNWBool("gunlab", true)
		gunlab:SetPos(tr.HitPos)
		gunlab.nodupe = true
		gunlab:Spawn()
		gunlab.SID = ply.SID
		return ""
	else
		Notify(ply, 1, 4, "Must be a Gun Dealer!")
	end
	return ""
end
AddChatCommand("/buygunlab", BuyGunlab)

function BuyMoneyPrinter(ply, args)
	if RPArrestedPlayers[ply:SteamID()] then return "" end

	local trace = {}
	trace.start = ply:EyePos()
	trace.endpos = trace.start + ply:GetAimVector() * 85
	trace.filter = ply
	local tr = util.TraceLine(trace)

	local cost = GetGlobalInt("mprintercost")
	if cost == 0 then cost = 1000 end
	if not ply:CanAfford(cost) then
		Notify(ply, 1, 4, "Can not afford this!")
		return ""
	end

	if ply:GetNWInt("maxmprinters") >= CfgVars["maxmprinters"] then
		Notify(ply, 1, 4, "Max Money Printers reached!")
		return ""
	end

	ply:AddMoney(-cost)
	Notify(ply, 1, 4, "You bought a Money Printer for " .. CUR .. tostring(cost))
	local moneyprinter = ents.Create("money_printer")
	moneyprinter:SetNWEntity("owning_ent", ply)
	moneyprinter:SetNWString("Owner", "Shared") -- So people can run off with them!
	moneyprinter:SetPos(tr.HitPos)
	moneyprinter.onlyremover = true
	moneyprinter.SID = ply.SID
	moneyprinter:Spawn()
	return ""
end
AddChatCommand("/buymoneyprinter", BuyMoneyPrinter)

function BuyAmmo(ply, args)
	if args == "" then return "" end

	if RPArrestedPlayers[ply:SteamID()] then return "" end

	if CfgVars["noguns"] == 1 then
		Notify(ply, 1, 4, "Guns are disabled so why buy ammo?!")
		return ""
	end
	
	if args ~= "rifle" and args ~= "shotgun" and args ~= "pistol" then
		Notify(ply, 1, 4, "That ammo is not available!")
	end
	
	if not ply:CanAfford(GetGlobalInt("ammo" .. args .. "cost")) then
		Notify(ply, 1, 4, "Can not afford this!")
		return ""
	end
	
	if args == "rifle" then
		ply:GiveAmmo(80, "smg1")
	elseif args == "shotgun" then
		ply:GiveAmmo(50, "buckshot")
	elseif args == "pistol" then
		ply:GiveAmmo(50, "pistol")
	end

	local cost = GetGlobalInt("ammo" .. args .. "cost")

	Notify(ply, 1, 4, "You bought some " .. args .. " ammo for " .. CUR .. tostring(cost))
	ply:AddMoney(-cost)

	return ""
end
AddChatCommand("/buyammo", BuyAmmo)

function BuyHealth(ply)
	local cost = GetGlobalInt("healthcost")
	if not ply:CanAfford(cost) then
		Notify(ply, 1, 4, "Can not afford this!")
		return ""
	end
	if ply:Team() ~= TEAM_MEDIC and team.NumPlayers(TEAM_MEDIC) > 0 then
		Notify(ply, 1, 4, "/buyhealth is disabled because there are Medics.")
	else
		ply:AddMoney(-cost)
		Notify(ply, 1, 4, "You bought Health for " .. CUR .. tostring(cost))
		ply:SetHealth(100)
	end
	return ""
end
AddChatCommand("/buyhealth", BuyHealth)

function JailPos(ply)
	-- Admin or Chief can set the Jail Position
	if (ply:Team() == TEAM_CHIEF and CfgVars["chiefjailpos"] == 1) or ply:HasPriv(ADMIN) then
		DB.StoreJailPos(ply)
	else
		local str = "Admin only!"
		if CfgVars["chiefjailpos"] == 1 then
			str = "Chief or " .. str
		end

		Notify(ply, 1, 4, str)
	end
	return ""
end
AddChatCommand("/jailpos", JailPos)

function AddJailPos(ply)
	-- Admin or Chief can add Jail Positions
	if (ply:Team() == TEAM_CHIEF and CfgVars["chiefjailpos"] == 1) or ply:HasPriv(ADMIN) then
		DB.StoreJailPos(ply, true)
	else
		local str = "Admin only!"
		if CfgVars["chiefjailpos"] == 1 then
			str = "Chief or " .. str
		end

		Notify(ply, 1, 4, str)
	end
	return ""
end
AddChatCommand("/addjailpos", AddJailPos)

function MakeGangster(ply)
	ply:ChangeTeam(TEAM_GANG)
	return ""
end
AddChatCommand("/gangster", MakeGangster)

function MakeMobBoss(ply)
	ply:ChangeTeam(TEAM_MOB)
	return ""
end
AddChatCommand("/mobboss", MakeMobBoss)

function CreateAgenda(ply, args)
	if ply:Team() == TEAM_MOB then
		CfgVars["mobagenda"] = string.gsub(args, "//", "\n")

		for k, v in pairs(player.GetAll()) do
			local t = v:Team()
			if t == TEAM_GANG or t == TEAM_MOB then
				Notify(v, 1, 4, "Mob Boss updated the agenda!")
				v:SetNWString("agenda", CfgVars["mobagenda"])
			end
		end
	else
		Notify(ply, 1, 4, "Must be a Mob Boss to use this command.")
	end
	return ""
end
AddChatCommand("/agenda", CreateAgenda)

timer.Create("start", 1, 0, StartShower)
timer.Create("stormControl", 1, 0, ControlStorm)
timer.Create("start2", 1, 0, SpawnZombie)
timer.Create("zombieControl", 1, 0, ControlZombie)
timer.Stop("start")
timer.Stop("stormControl")
timer.Stop("start2")
timer.Stop("zombieControl")

function GetHelp(ply, args)
	umsg.Start("ToggleHelp", ply)
	umsg.End()
	return ""
end
AddChatCommand("/help", GetHelp)

local function MakeLetter(ply, args, type)
	if CfgVars["letters"] == 0 then
		Notify(ply, 1, 4, "Letter writing is disabled.")
		return ""
	end

	if ply:GetNWInt("maxletters") >= CfgVars["maxletters"] then
		Notify(ply, 1, 4, "Max Letters reached!")
		return ""
	end

	if CurTime() - ply:GetTable().LastLetterMade < 3 then
		Notify(ply, 1, 4, "Wait another " .. math.ceil(3 - (CurTime() - ply:GetTable().LastLetterMade)) .. " seconds before writing another letter!")
		return ""
	end

	ply:GetTable().LastLetterMade = CurTime()

	-- Instruct the player's letter window to open

	local ftext = string.gsub(args, "//", "\n")
	local length = string.len(ftext)

	local numParts = math.floor(length / 39) + 1

	local tr = {}
	tr.start = ply:EyePos()
	tr.endpos = ply:EyePos() + 95 * ply:GetAimVector()
	tr.filter = ply
	local trace = util.TraceLine(tr)

	local letter = ents.Create("letter")
	letter:SetModel("models/props_c17/paper01.mdl")
	letter:SetNWEntity("owning_ent", ply)
	letter:SetNWString("Owner", "Shared")
	letter:SetPos(trace.HitPos)
	letter.nodupe = true
	letter:Spawn()

	letter:GetTable().Letter = true
	letter:SetNWInt("type", type)
	letter:SetNWInt("numPts", numParts)

	local startpos = 1
	local endpos = 39
	for k=1, numParts do
		letter:SetNWString("part" .. tostring(k), string.sub(ftext, startpos, endpos))
		startpos = startpos + 39
		endpos = endpos + 39
	end
	letter.SID = ply.SID

	PrintMessageAll(2, ply:Nick() .. " created a letter.")
	ply:SetNWInt("maxletters", ply:GetNWInt("maxletters") + 1)
	timer.Simple(600, function() if ValidEntity(letter) then letter:Remove() end end)
end

function WriteLetter(ply, args)
	if args == "" then return "" end
	MakeLetter(ply, args, 1)
	return ""
end
AddChatCommand("/write", WriteLetter)

function TypeLetter(ply, args)
	if args == "" then return "" end
	MakeLetter(ply, args, 2)
	return ""
end
AddChatCommand("/type", TypeLetter)

function ChangeJob(ply, args)
	if args == "" then return "" end

	if CfgVars["customjobs"] ~= 1 then
		Notify(ply, 1, 4, "Custom Jobs are disabled!")
		return ""
	end

	local len = string.len(args)

	if len < 3 then
		Notify(ply, 1, 4, "Job must be at least 3 characters!")
		return ""
	end

	if len > 25 then
		Notify(ply, 1, 4, "Job is restricted to 25 characters!")
		return ""
	end

	local jl = string.lower(args)
	local t = ply:Team()

	if (jl == "cp" or jl == "cop" or jl == "police" or jl == "civil protection" or jl == "civilprotection") and t ~= TEAM_POLICE then
		if ply:HasPriv(CP) or ply:HasPriv(ADMIN) or ply:HasPriv(MAYOR) then
			if VoteCopOn then
				Notify(ply, 1, 4,  "Please wait for the vote to finish first.")
			else
				ply:ChangeTeam(TEAM_POLICE)
			end
		else
			Notify(ply, 1, 4, "You have to be on the CP or Mayor List or Admin!")
		end
		return ""
	elseif jl == "mayor" and t ~= TEAM_MAYOR then
		if ply:HasPriv(ADMIN) or ply:HasPriv(MAYOR) then
			if VoteCopOn then
				Notify(ply, 1, 4,  "Please wait for the vote to finish first.")
			else
				ply:ChangeTeam(TEAM_MAYOR)
			end
		else
			Notify(ply, 1, 4, "You Must be on the Mayor List or Admin!")
		end
		return ""
	elseif jl == "gangster" and t ~= TEAM_GANG then
		ply:ChangeTeam(TEAM_GANG)
		return ""
	elseif jl == "citizen" and t ~= TEAM_CITIZEN then
		ply:ChangeTeam(TEAM_CITIZEN)
		return ""
	elseif (jl == "mob boss" or jl == "mobboss") and t ~= TEAM_MOB then
		ply:ChangeTeam(TEAM_MOB)
		return ""
	elseif (jl == "gun dealer" or jl == "gundealer") and t ~= TEAM_GUN then
		ply:ChangeTeam(TEAM_GUN)
		return ""
	elseif jl == "medic" and t ~= TEAM_MEDIC then
		ply:ChangeTeam(TEAM_MEDIC)
		return ""
	elseif jl == "cook" and t ~= TEAM_COOK then
		ply:ChangeTeam(TEAM_COOK)
		return ""
	elseif (jl == "chief" or jl == "cheif" or jl == "civil protection chief") and t ~= TEAM_CHIEF then
		ply:ChangeTeam(TEAM_CHIEF)
		return ""
	elseif (jl == "bum" or jl == "unemployed") and t ~= TEAM_CITIZEN then
		ply:ChangeTeam(TEAM_CITIZEN)
		-- Don't return here because we want to run the notify below.
	end
	for k,v in pairs(RPExtraTeams) do
		if jl == v.name then
			ply:ChangeTeam(9 + k)
		end
	end
	NotifyAll(2, 4, ply:Nick() .. " has set their job to '" .. args .. "'")
	ply:UpdateJob(args)
	return ""
end
AddChatCommand("/job", ChangeJob)

function GroupMsg(ply, args)
	local t = ply:Team()
	local audience = {}

	if t == TEAM_POLICE or t == TEAM_CHIEF or t == TEAM_MAYOR then
		for k, v in pairs(player.GetAll()) do
			local vt = v:Team()
			if vt == TEAM_POLICE or vt == TEAM_CHIEF or vt == TEAM_MAYOR then table.insert(audience, v) end
		end
	elseif t == TEAM_MOB or t == TEAM_GANG then
		for k, v in pairs(player.GetAll()) do
			local vt = v:Team()
			if vt == TEAM_MOB or vt == TEAM_GANG then table.insert(audience, v) end
		end
	end

	for k, v in pairs(audience) do
		v:PrintMessage(2, ply:Nick() .. ": (GROUP) " .. args)
		Notify(v, 1, 10, ply:Nick() .. ": (GROUP) " .. args)
		v:PrintMessage(3, ply:Nick() .. ": (GROUP) " .. args)
	end
	return ""
end
AddChatCommand("/g", GroupMsg)

function PM(ply, args)
	local namepos = string.find(args, " ")
	if not namepos then return "" end

	local name = string.sub(args, 1, namepos - 1)
	local msg = string.sub(args, namepos + 1)

	target = FindPlayer(name)

	if target then
		target:PrintMessage(2, ply:Nick() .. ": (PM) " .. msg)
		target:PrintMessage(3, ply:Nick() .. ": (PM) " .. msg)
		Notify(target, 1, 10, ply:Nick() .. ": (PM) " .. args)
		
		Notify(ply, 1, 10, ply:Nick() .. ": (PM) " .. args)
		ply:PrintMessage(2, ply:Nick() .. ": (PM) " .. msg)
		ply:PrintMessage(3, ply:Nick() .. ": (PM) " .. msg)
	else
		Notify(ply, 1, 4, "Could not find player: " .. name)
	end

	return ""
end
AddChatCommand("/pm", PM)

function Whisper(ply, args)
	TalkToRange("(WHISPER)" .. ply:Nick() .. ": " .. args, ply:EyePos(), 90)
	return ""
end
AddChatCommand("/w", Whisper)

function Yell(ply, args)
	TalkToRange("(YELL)" .. ply:Nick() .. ": " .. args, ply:EyePos(), 550)
	return ""
end
AddChatCommand("/y", Yell)

function OOC(ply, args)
	if CfgVars["ooc"] == 0 then
		Notify(ply, 1, 4, "OOC is disabled")
		return ""
	end

	return "(OOC) " .. args
end
AddChatCommand("//", OOC, true)
AddChatCommand("/a", OOC, true)
AddChatCommand("/ooc", OOC, true)

function PlayerAdvertise(ply, args)
	for k,v in pairs(player.GetAll()) do
		v:ChatPrint("[ADVERT] ("..ply:Nick()..")"..args)
	end
	return ""
end
AddChatCommand("/advert", PlayerAdvertise)

function SetRadioChannel(ply,args)
	if tonumber(args) == nil or tonumber(args) < 0 or tonumber(args) > 99 then
		Notify(ply, 1, 4, "Please set the channel between 0 and 100")
		return ""
	end
	Notify(ply, 1, 4, "Channel set to "..args.."!")
	ply:SetNWInt("RadioChannel", tonumber(args))
	return ""
end
AddChatCommand("/channel", SetRadioChannel)

function SayThroughRadio(ply,args)
	if not args or args == "" then
		Notify(ply, 1, 4, "Please enter a message!")
		return ""
	end
	for k,v in pairs(player.GetAll()) do
		if v:GetNWInt("RadioChannel") == ply:GetNWInt("RadioChannel") then
			v:ChatPrint("Radio ".. tostring(ply:GetNWInt("RadioChannel")) .. " ("..ply:Nick().."): ".. args)
		end
	end
	return ""
end
AddChatCommand("/radio", SayThroughRadio)

function GiveMoney(ply, args)
	if args == "" then return "" end

	if not tonumber(args) then
		return ""
	end
	local trace = ply:GetEyeTrace()

	if ValidEntity(trace.Entity) and trace.Entity:IsPlayer() and trace.Entity:GetPos():Distance(ply:GetPos()) < 150 then
		local amount = math.floor(tonumber(args))

		if amount <= 1 then
			Notify(ply, 1, 4, "Invalid amount of money! Must be at least " .. CUR .. "2!")
			return
		end

		if not ply:CanAfford(amount) then
			Notify(ply, 1, 4, "Can not afford this!")
			return ""
		end

		DB.PayPlayer(ply, trace.Entity, amount)

		Notify(trace.Entity, 0, 4, ply:Nick() .. " has given you " .. CUR .. tostring(amount))
		Notify(ply, 0, 4, "Gave " .. trace.Entity:Nick() .. " " .. CUR .. tostring(amount))
	else
		Notify(ply, 1, 4, "Must be looking at and standing close to another player!")
	end
	return ""
end
AddChatCommand("/give", GiveMoney)

function DropMoney(ply, args)
	if args == "" then return "" end
	
	if not tonumber(args) then
		return ""
	end
	local amount = math.floor(tonumber(args))

	if amount <= 1 then
		Notify(ply, 1, 4, "Invalid amount of money! Must be at least " .. CUR .. "2!")
		return ""
	end

	if not ply:CanAfford(amount) then
		Notify(ply, 1, 4, "Can not afford this!")
		return ""
	end

	ply:AddMoney(-amount)

	local trace = {}
	trace.start = ply:EyePos()
	trace.endpos = trace.start + ply:GetAimVector() * 85
	trace.filter = ply

	local tr = util.TraceLine(trace)
	local moneybag = ents.Create("prop_physics")
	moneybag:SetModel("models/props/cs_assault/money.mdl")
	moneybag:SetNWString("Owner", "Shared")
	moneybag:SetPos(tr.HitPos)
	moneybag.nodupe = true
	moneybag:Spawn()
	moneybag:GetTable().MoneyBag = true
	moneybag:GetTable().Amount = amount

	return ""
end
AddChatCommand("/dropmoney", DropMoney)
AddChatCommand("/moneydrop", DropMoney)

function SetDoorTitle(ply, args)
	local trace = ply:GetEyeTrace()

	if ValidEntity(trace.Entity) and trace.Entity:IsOwnable() and ply:GetPos():Distance(trace.Entity:GetPos()) < 110 then
		if ply:IsSuperAdmin() then
			if trace.Entity:GetNWBool("nonOwnable") then
				DB.StoreNonOwnableDoorTitle(trace.Entity, args)
				return ""
			end
		else
			if trace.Entity:GetNWBool("nonOwnable") then
				Notify(ply, 1, 4, "Admin only!")
			end
		end

		if trace.Entity:OwnedBy(ply) then
			trace.Entity:SetNWString("title", args)
		else
			Notify(ply, 1, 4, "You don't own this!")
		end
	end

	return ""
end
AddChatCommand("/title", SetDoorTitle)

function RemoveDoorOwner(ply, args)
	local trace = ply:GetEyeTrace()

	if ValidEntity(trace.Entity) and trace.Entity:IsOwnable() and ply:GetPos():Distance(trace.Entity:GetPos()) < 110 then
		target = FindPlayer(args)

		if trace.Entity:GetNWBool("nonOwnable") then
			Notify(ply, 1, 4, "Can not remove owners while Door is non-ownable!")
		end

		if target then
			if trace.Entity:OwnedBy(ply) then
				if trace.Entity:AllowedToOwn(target) then
					trace.Entity:RemoveAllowed(target)
				end

				if trace.Entity:OwnedBy(target) then
					trace.Entity:RemoveOwner(target)
				end
			else
				Notify(ply, 1, 4, "You don't own this!")
			end
		else
			Notify(ply, 1, 4, "Could not find player: " .. args)
		end
	end
	return ""
end
AddChatCommand("/removeowner", RemoveDoorOwner)
AddChatCommand("/ro", RemoveDoorOwner)

local function AddDoorOwner(ply, args)
	local trace = ply:GetEyeTrace()

	if ValidEntity(trace.Entity) and trace.Entity:IsOwnable() and ply:GetPos():Distance(trace.Entity:GetPos()) < 110 then
		target = FindPlayer(args)
		if target then
			if trace.Entity:GetNWBool("nonOwnable") then
				Notify(ply, 1, 4, "Can not add owners while Door is non-ownable!")
				return ""
			end

			if trace.Entity:OwnedBy(ply) then
				if not trace.Entity:OwnedBy(target) and not trace.Entity:AllowedToOwn(target) then
					trace.Entity:AddAllowed(target)
				else
					Notify(ply, 1, 4, "Player already owns (or is allowed to own) this!")
				end
			else
				Notify(ply, 1, 4, "You don't own this!")
			end
		else
			Notify(ply, 1, 4, "Could not find player: " .. args)
		end
	end
	return ""
end
AddChatCommand("/addowner", AddDoorOwner)
AddChatCommand("/ao", AddDoorOwner)

local function FinishDemote(choice, v)
	VoteCopOn = false

	if choice == 1 then
		v:TeamBan()
		if v:Alive() then
			v:ChangeTeam(TEAM_CITIZEN)
		else
			v.demotedWhileDead = true
		end

		NotifyAll(1, 4, v:Nick() .. " has been demoted!")
	else
		NotifyAll(1, 4, v:Nick() .. " has not been demoted!")
	end
end

local function Demote(ply, args)
	local tableargs = string.Explode(" ", args)
	if #tableargs == 1 then
		Notify(ply, 1, 4, "You need to specify a reason!")
		return ""
	end
	local reason = ""
	for i = 2, #tableargs, 1 do
		reason = reason .. " " .. tableargs[i]
	end 
	reason = string.sub(reason, 2)
	if string.len(reason) > 22 then
		Notify(ply, 1, 4, "Reason must be 22 characters or less")
		return "" 
	end
	local p = FindPlayer(tableargs[1])
	if p then
		if CurTime() - ply:GetTable().LastVoteCop < 80 then
			Notify(ply, 1, 4, "Please wait another " .. math.ceil(80 - (CurTime() - ply:GetTable().LastVoteCop)) .. " seconds before demoting.")
			return ""
		end
		if p:Team() == TEAM_CITIZEN then
			Notify(ply, 1, 4,  p:Nick() .." is a Citizen - can't be demoted any further!")
		else
			NotifyAll(1, 4, ply:Nick() .. " has started a vote for the demotion of " .. p:Nick())
			vote:Create(p:Nick() .. ":\nDemotion Nominee:\n"..reason, p:EntIndex() .. "votecop"..ply:EntIndex(), p, 20, FinishDemote, true)
			ply:GetTable().LastVoteCop = CurTime()
			VoteCopOn = true
			Notify(ply, 1, 4, "Demotion Vote started!")
		end
		return ""
	else
		Notify(ply, 1, 4, "Player does not exist!")
		return ""
	end
end
AddChatCommand("/demote", Demote)



local function FinishVoteMayor(choice, ply)
	VoteCopOn = false

	if choice == 1 then
		ply:ChangeTeam(TEAM_MAYOR)
	else
		NotifyAll(1, 4, ply:Nick() .. " has not been made Mayor!")
	end
end

local function FinishVoteCop(choice, ply)
	VoteCopOn = false

	if choice == 1 then
		ply:ChangeTeam(TEAM_POLICE)
	else
		NotifyAll(1, 4, ply:Nick() .. " has not been made Civil Protection!")
	end
end

local function DoVoteMayor(ply, args)
	
	if #player.GetAll() == 1 then
		Notify(ply, 1, 4, "You're the only one in the server so you won the vote")
		ply:ChangeTeam(TEAM_MAYOR)
		return ""
	end
	
	if CfgVars["mayorvoting"] == 0 then
		Notify(ply, 1, 4,  "Mayor voting is disabled!")
		return ""
	end

	if not ply:ChangeAllowed(TEAM_MAYOR) then
		Notify(ply, 1, 4, "Cannot become mayor. You're either banned from the team or you were demoted.")
		return ""
	end

	if CurTime() - ply:GetTable().LastVoteCop < 80 then
		Notify(ply, 1, 4, "Wait another " .. math.ceil(80 - (CurTime() - ply:GetTable().LastVoteCop)) .. " seconds before using /votemayor!")
		return ""
	end

	if VoteCopOn then
		Notify(ply, 1, 4,  "There is already a vote!")
		return ""
	end

	if CfgVars["cptomayoronly"] == 1 then
		if ply:Team() ~= TEAM_POLICE and ply:Team() ~= TEAM_CHIEF then
			Notify(ply, 1, 4,  "You have to be in the Civil Protection!")
			return ""
		end
	end

	if ply:Team() == TEAM_MAYOR then
		Notify(ply, 1, 4,  "You're already Mayor!")
		return ""
	end

	if team.NumPlayers(TEAM_MAYOR) >= 1 then
		Notify(ply, 1, 4,  "There can only be one Mayor at a time!")
		return ""
	end

	vote:Create(ply:Nick() .. ":\nwants to be Mayor", ply:EntIndex() .. "votecop", ply, 20, FinishVoteMayor)
	ply:GetTable().LastVoteCop = CurTime()
	VoteCopOn = true

	return ""
end
AddChatCommand("/votemayor", DoVoteMayor)

local function DoVoteCop(ply, args)	
	if CfgVars["cpvoting"] == 0 then
		Notify(ply, 1, 4,  "Cop voting is disabled!")
		return ""
	end

	if not ply:ChangeAllowed(TEAM_POLICE) then
		Notify(ply, 1, 4, "You're either banned from this class or you were demoted.")
		return ""
	end

	if CurTime() - ply:GetTable().LastVoteCop < 60 then
		Notify(ply, 1, 4, "Wait another " .. math.ceil(60 - (CurTime() - ply:GetTable().LastVoteCop)) .. " seconds to vote for Cop.")
		return ""
	end
	
	if #player.GetAll() == 1 then
		Notify(ply, 1, 4, "You're the only one in the server so you won the vote")
		ply:ChangeTeam(TEAM_POLICE)
		return ""
	end

	if VoteCopOn then
		Notify(ply, 1, 4,  "There is already a vote for Cop!")
		return ""
	end

	if ply:Team() == TEAM_POLICE then
		Notify(ply, 1, 4,  "You're already in the Civil Protection!")
		return ""
	end

	if team.NumPlayers(TEAM_POLICE) >= CfgVars["maxcps"] then
		Notify(ply, 1, 4,  "Max number of CP's are: " .. CfgVars["maxcps"])
		return ""
	end

	vote:Create(ply:Nick() .. ":\nwants to be a Cop", ply:EntIndex() .. "votecop", ply, 20, FinishVoteCop)
	ply:GetTable().LastVoteCop = CurTime()
	VoteCopOn = true

	return ""
end
AddChatCommand("/votecop", DoVoteCop)

function MakeMayor(ply, args)
	if ply:HasPriv(ADMIN) or ply:HasPriv(MAYOR) or ply:IsAdmin() then
		if VoteCopOn then
			Notify(ply, 1, 4,  "Please wait for the vote to finish first.")
		else
			ply:ChangeTeam(TEAM_MAYOR)
		end
	else
		Notify(ply, 1, 4, "You must be on the Mayor list or Admin!")
	end
	return ""
end
AddChatCommand("/mayor", MakeMayor)

function MakeCitizen(ply, args)
	ply:ChangeTeam(TEAM_CITIZEN)
	return ""
end
AddChatCommand("/citizen", MakeCitizen)

function MakeCP(ply, args)
	if ply:HasPriv(CP) or ply:HasPriv(ADMIN) or ply:HasPriv(MAYOR) or ply:IsAdmin() then
		if VoteCopOn then
			Notify(ply, 1, 4,  "Please wait for the vote to finish first.")
		else
			ply:ChangeTeam(TEAM_POLICE)
		end
	else
		Notify(ply, 1, 4, "You must be on the CP or the Mayor list or Admin!")
	end
	return ""
end
AddChatCommand("/cp", MakeCP)

function MakeDealer(ply, args)
	ply:ChangeTeam(TEAM_GUN)
	return ""
end
AddChatCommand("/gundealer", MakeDealer)

function MakePDChief(ply, args)
	ply:ChangeTeam(TEAM_CHIEF)
	return ""
end
AddChatCommand("/chief", MakePDChief)

function MakeMedic(ply, args)
	ply:ChangeTeam(TEAM_MEDIC)
	return ""
end
AddChatCommand("/medic", MakeMedic)

function MakeCook(ply, args)
	ply:ChangeTeam(TEAM_COOK)
	return ""
end
AddChatCommand("/cook", MakeCook)

for k,v in pairs(RPExtraTeams) do
	if v.Vote then
		AddChatCommand("/vote"..v.command, function(ply)
			if #player.GetAll() == 1 then
				Notify(ply, 1, 4, "You're the only one in the server so you won the vote")
				ply:ChangeTeam(k+9)
				return ""
			end
			if not ply:ChangeAllowed(9 + k) then
				Notify(ply, 1, 4, "You're either banned from this team or you were demoted.)")
				return ""
			end
			if CurTime() - ply:GetTable().LastVoteCop < 80 then
				Notify(ply, 1, 4, "Wait another " .. math.ceil(80 - (CurTime() - ply:GetTable().LastVoteCop)) .. " seconds before using /vote"..v.command.."!")
				return ""
			end
			if VoteCopOn then
				Notify(ply, 1, 4,  "There is already a vote!")
				return ""
			end
			if ply:Team() == (k + 9) then
				Notify(ply, 1, 4,  "You're already "..v.name.."!")
				return ""
			end
			if team.NumPlayers(9 + k) >= v.max then
				Notify(ply, 1, 4,  "There can only be "..tostring(v.max).." "..v.name.." at a time!")
				return ""
			end
			vote:Create(ply:Nick() .. ":\nwants to be "..v.name, ply:EntIndex() .. "votecop", ply, 20, function(choice, ply)
				VoteCopOn = false
				if choice == 1 then
					ply:ChangeTeam(k + 9)
				else
					NotifyAll(1, 4, ply:Nick() .. " has not been made "..v.name.."!")
				end
			end)
			ply:GetTable().LastVoteCop = CurTime()
			VoteCopOn = true
			return ""
		end)
		AddChatCommand("/"..v.command, function(ply)
			if v.admin == 0 and not ply:IsAdmin() then
				Notify(ply, 1, 4, "You must be an admin/make a vote to become "..v.name.."!")
				return ""
			elseif v.admin == 1 and ply:IsAdmin() and not ply:IsSuperAdmin() then
				Notify(ply, 1, 4, "You have to make a vote to become "..v.name.."!")
				return ""
			elseif v.admin == 2 and ply:IsSuperAdmin() then
				Notify(ply, 1, 4, "You have to make a vote to become "..v.name.."!")
				return ""
			elseif v.admin == 2 and ply:IsAdmin() then
				Notify(ply, 1, 4, "You can't become "..v.name.."!")
				return "" 
			end
			ply:ChangeTeam(9 + k)
			return ""
		end)
	else
		AddChatCommand("/"..v.command, function(ply)
			if v.admin == 1 and not ply:IsAdmin() then
				Notify(ply, 1, 4, "You must be an admin to become "..v.name.."!")
				return ""
			end
			if v.admin > 1 and not ply:IsSuperAdmin() then
				Notify(ply, 1, 4, "You must be a super admin to become "..v.name.."!")
				return ""
			end
			ply:ChangeTeam(9 + k)
			return ""
		end)
	end
end

function CombineRequest(ply, args)
	local t = ply:Team()
	for k, v in pairs(player.GetAll()) do
		if v:Team() == TEAM_POLICE or v:Team() == TEAM_CHIEF or v == ply then
			v:ChatPrint(ply:Nick() .. ": (REQUEST!) " .. args)
			v:PrintMessage(2, ply:Nick() .. ": (REQUEST!) " .. args)
		end
	end
	return ""
end
AddChatCommand("/cr", CombineRequest)

local LotteryPeople = {}
local LotteryON = false
local CanLottery = CurTime()
function EnterLottery(answer, ent, initiator, target, TimeIsUp)
	if answer == 1 and not table.HasValue(LotteryPeople, target) then
		if not target:CanAfford(CfgVars["lotterycommitcost"]) then
			Notify(target, 1,4, "Cannot afford the lottery!")
			return
		end
		table.insert(LotteryPeople, target)
		target:AddMoney(-CfgVars["lotterycommitcost"])
		Notify(target, 1,4, "You entered the lottery for "..CUR..tostring(CfgVars["lotterycommitcost"]))
	elseif answer and not table.HasValue(LotteryPeople, target) then
		Notify(target, 1,4, "You did NOT enter the lottery!")
	end
	
	if TimeIsUp then
		LotteryON = false
		CanLottery = CurTime() + 60
		if #LotteryPeople == 0 then
			NotifyAll(1,4, "Noone entered the lottery")
			return
		end
		local chosen = LotteryPeople[math.random(1, #LotteryPeople)]
		chosen:AddMoney(#LotteryPeople * CfgVars["lotterycommitcost"])
		Notify(chosen, 1,10, "Congratulations! you've won the lottery! You have won " .. CUR .. tostring(#LotteryPeople * CfgVars["lotterycommitcost"]))
		NotifyAll(1,10, chosen:Nick() .. " has won the lottery! He has won "  .. CUR .. tostring(#LotteryPeople * CfgVars["lotterycommitcost"]) )
	end
end


function DoLottery(ply)
	if ply:Team() ~= TEAM_MAYOR then
		Notify(ply, 1, 4, "You're not the mayor!")
		return "" 
	end
	
	if CfgVars["lottery"] ~= 1 then
		Notify(ply, 1, 4, "Lotteries are disabled!")
		return ""
	end
	
	if #player.GetAll() <= 2 then
		Notify(ply, 1, 4, "Not enough people in the server")
		return "" 
	end 
	
	if LotteryON then
		Notify(ply, 1, 4, "There already is a lottery ongoing!")
		return "" 
	end
	if CanLottery > CurTime() then
		Notify(ply, 1, 5, "You have to wait "..tostring(CanLottery - CurTime()).." seconds to start a lottery again.")
		return "" 
	end
	Notify(ply, 1, 4, "You started a lottery!!")
	LotteryON = true
	LotteryPeople = {}
	for k,v in pairs(player.GetAll()) do 
		if v ~= ply then
			ques:Create("There is a lottery! Participate for " ..CUR.. tostring(CfgVars["lotterycommitcost"]) .. "?", "lottery"..tostring(k), v, 30, EnterLottery, ply, v)
		end
	end	
	timer.Create("Lottery", 30, 1, EnterLottery, nil, nil, nil, nil, true)
	return ""
end
AddChatCommand("/lottery", DoLottery)

function FoodHeal(ply)
	if GetGlobalInt("hungermod") == 0 then
		ply:SetHealth(ply:Health() + (100 - ply:Health()))
	else
		ply:SetNWInt("Energy", math.Clamp(ply:GetNWInt("Energy") + 100, 0, 100))
		umsg.Start("AteFoodIcon", ply)
		umsg.End()
	end
	return ""
end

function Lockdown(ply)
	if GetGlobalInt("lstat") ~= 1 then
		if ply:Team() == TEAM_MAYOR or ply:HasPriv(ADMIN) then
			for k,v in pairs(player.GetAll()) do
				v:ConCommand("play npc/overwatch/cityvoice/f_confirmcivilstatus_1_spkr.wav\n")
			end
			SetGlobalInt("lstat", 1)
			PrintMessageAll(HUD_PRINTTALK , "Lockdown in progress, please return to your homes!")
			NotifyAll(4, 3, ply:Nick() .. " has initiated a Lockdown, please return to your homes!")
		end
	end
	return ""
end
concommand.Add("rp_lockdown", Lockdown)
AddChatCommand("/lockdown", Lockdown)

function UnLockdown(ply)
	if GetGlobalInt("lstat") == 1 and GetGlobalInt("ulstat") == 0 then
		if ply:Team() == TEAM_MAYOR or ply:HasPriv(ADMIN) then
			PrintMessageAll(HUD_PRINTTALK , "Lockdown has ended.")
			NotifyAll(4, 3, ply:Nick() .. " has ended the Lockdown.")
			SetGlobalInt("ulstat", 1)
			timer.Create("spamlock", 20, 1, WaitLock, "")
		end
	end
	return ""
end
concommand.Add("rp_unlockdown", UnLockdown)
AddChatCommand("/unlockdown", UnLockdown)

function WaitLock()
	SetGlobalInt("ulstat", 0)
	SetGlobalInt("lstat", 0)
	timer.Destroy("spamlock")
end

function RefreshGlobals()
	if CfgVars["refreshglobals"] ~= 1 then
		SetGlobalInt("ak47cost", 2450)
		SetGlobalInt("mp5cost", 2200)
		SetGlobalInt("m16cost", 2450)
		SetGlobalInt("mac10cost", 2150)
		SetGlobalInt("shotguncost", 1750)
		SetGlobalInt("snipercost", 3750)
		SetGlobalInt("deaglecost", 215)
		SetGlobalInt("fivesevencost", 205)
		SetGlobalInt("glockcost", 160)
		SetGlobalInt("p228cost", 185)
		SetGlobalInt("druglabcost", 400)
		SetGlobalInt("gunlabcost", 500)
		SetGlobalInt("mprintercost", 1000)
		SetGlobalInt("mprintamount", 250)
		SetGlobalInt("microwavecost", 400)
		SetGlobalInt("drugpayamount", 15)
		SetGlobalInt("ammopistolcost", 30)
		SetGlobalInt("ammoriflecost", 60)
		SetGlobalInt("ammoshotguncost", 70)
		SetGlobalInt("healthcost", 60)
		SetGlobalInt("jailtimer", 120)
		SetGlobalInt("microwavefoodcost", 30)
		SetGlobalInt("maxcopsalary", 100)
		SetGlobalInt("maxdrugfood", 2)
		SetGlobalInt("npckillpay", 10)
		SetGlobalInt("nametag", 1)
		SetGlobalInt("jobtag", 1)
		SetGlobalInt("globalshow", 0)
		SetGlobalInt("deathnotice", 1)
	end
	CfgVars["refreshglobals"] = 1
	timer.Simple(30, refwait)
end

function VerifyGlobals(ply)
	if not ply:HasPriv(ADMIN) then
		ply:PrintMessage(2, "Must be an Admin to refresh the Global Variables!")
		return
	else
		local nick = ""
		if ply:EntIndex() == 0 then
			nick = "Console"
		else
			nick = ply:Nick()
		end
		NotifyAll(0, 6, nick .. " refreshed the Global Variables.")
		RefreshGlobals()
	end
end
concommand.Add("refresh_int", VerifyGlobals)

function refwait()
	CfgVars["refreshglobals"] = 0
end

function GM:PlayerSpawnProp(ply, model)
	if not self.BaseClass:PlayerSpawnProp(ply, model) then return false end

	local allowed = false

	if RPArrestedPlayers[ply:SteamID()] then return false end

	-- Banned props take precedence over allowed props
	if CfgVars["banprops"] == 1 then
		for k, v in pairs(BannedProps) do
			if v == model then return false end
		end
	end

	-- If prop spawning is enabled or the user has admin or prop privileges
	if CfgVars["propspawning"] == 1 or ply:HasPriv(ADMIN) or ply:HasPriv(PROP) then
		-- If we are specifically allowing certain props, if it's not in the list, allowed will remain false
		if CfgVars["allowedprops"] == 1 then
			for k, v in pairs(AllowedProps) do
				if v == model then allowed = true end
			end
		else
			-- allowedprops is not enabled, so assume that if it wasn't banned above, it's allowed
			allowed = true
		end
	end

	if allowed then
		if CfgVars["proppaying"] == 1 then
			if ply:CanAfford(CfgVars["propcost"]) then
				Notify(ply, 1, 4, "Deducted " .. CUR .. CfgVars["propcost"])
				ply:AddMoney(-CfgVars["propcost"])
				return true
			else
				Notify(ply, 1, 4, "Need " .. CUR .. CfgVars["propcost"])
				return false
			end
		else
			return true
		end
	end
	return false
end

function GM:PlayerSpawnSENT(ply, model)
	return self.BaseClass:PlayerSpawnSENT(ply, model) and not RPArrestedPlayers[ply:SteamID()]
end

function GM:PlayerSpawnSWEP(ply, model)
	return self.BaseClass:PlayerSpawnSWEP(ply, model) and not RPArrestedPlayers[ply:SteamID()]
end

function GM:PlayerSpawnEffect(ply, model)
	return self.BaseClass:PlayerSpawnEffect(ply, model) and not RPArrestedPlayers[ply:SteamID()]
end

function GM:PlayerSpawnVehicle(ply, model)
	return self.BaseClass:PlayerSpawnVehicle(ply, model) and not RPArrestedPlayers[ply:SteamID()]
end

function GM:PlayerSpawnNPC(ply, model)
	return self.BaseClass:PlayerSpawnNPC(ply, model) and not RPArrestedPlayers[ply:SteamID()]
end

function GM:PlayerSpawnRagdoll(ply, model)
	return self.BaseClass:PlayerSpawnRagdoll(ply, model) and not RPArrestedPlayers[ply:SteamID()]
end

function GM:PlayerSpawnedProp(ply, model, ent)
	self.BaseClass:PlayerSpawnedProp(ply, model, ent)
	ent.SID = ply.SID
	ent:SetNetworkedEntity("TheFingOwner", ply)
end

function GM:PlayerSpawnedSWEP(ply, model, ent)
	self.BaseClass:PlayerSpawnedSWEP(ply, model, ent)
	ent.SID = ply.SID
end

function GM:PlayerSpawnedRagdoll(ply, model, ent)
	self.BaseClass:PlayerSpawnedRagdoll(ply, model, ent)
	ent.SID = ply.SID
end

function GM:ShowSpare1(ply)
	umsg.Start("ToggleClicker", ply)
	umsg.End()
end

function GM:ShowSpare2(ply)
	ply:SendLua("ChangeJobVGUI()")
end

function GM:OnNPCKilled(victim, ent, weapon)
	-- If something killed the npc
	if ent then
		if ent:IsVehicle() and ent:GetDriver():IsPlayer() then ent = ent:GetDriver() end

		-- if it wasn't a player directly, find out who owns the prop that did the killing
		if not ent:IsPlayer() then
			ent = FindPlayerBySID(ent.SID)
		end

		-- if we know by now who killed the NPC, pay them.
		if ent and CfgVars["npckillpay"] > 0 then
			ent:AddMoney(CfgVars["npckillpay"])
			Notify(ent, 1, 4, CUR .. CfgVars["npckillpay"] .. " For killing an NPC!")
		end
	end
end

function GM:KeyPress(ply, code)
	self.BaseClass:KeyPress(ply, code)

	if code == IN_USE then
		local trace = { }
		trace.start = ply:EyePos()
		trace.endpos = trace.start + ply:GetAimVector() * 95
		trace.filter = ply
		local tr = util.TraceLine(trace)

		if ValidEntity(tr.Entity) and not ply:KeyDown(IN_ATTACK) then
			if tr.Entity:GetTable().Letter then
				umsg.Start("ShowLetter", ply)
					umsg.Short(tr.Entity:GetNWInt("type"))
					umsg.Vector(tr.Entity:GetPos())
					local numParts = tr.Entity:GetNWInt("numPts")
					umsg.Short(numParts)
					for k=1, numParts do umsg.String(tr.Entity:GetNWString("part" .. tostring(k))) end
				umsg.End()
			end

			if tr.Entity:GetTable().MoneyBag then
				Notify(ply, 0, 4, "You found " .. CUR .. tr.Entity:GetTable().Amount .. "!")
				ply:AddMoney(tr.Entity:GetTable().Amount)
				tr.Entity:Remove()
			end
		else
			umsg.Start("KillLetter", ply)
			umsg.End()
		end
	end
end

function MayorSetSalary(ply, cmd, args)
	if ply:EntIndex() == 0 then
		print("Console should use rp_setsalary instead.")
		return
	end

	if CfgVars["mayorsetsalary"] == 0 then
		ply:PrintMessage(2, "Mayor SetSalary disabled by Admin!")
		Notify(ply, 1, 4, "Mayor SetSalary disabled by Admin!")
		return "Mayor SetSalary disabled by Admin!"
	end

	if ply:Team() ~= TEAM_MAYOR then
		ply:PrintMessage(2, "You must be the Mayor to use this function!")
		return
	end

	local amount = math.floor(tonumber(args[2]))

	if not amount or amount < 0 then
		ply:PrintMessage(2, "Invalid Salary: " .. args[2])
		return
	end

	if amount > GetGlobalInt("mayorsetsalary") then
		ply:PrintMessage(2, "Salary must be less than or equal to " .. CUR .. CfgVars["maxmayorsetsalary"] .."!")
		return
	end

	local plynick = ply:Nick()
	local target = FindPlayer(args[1])

	if target then
		local targetteam = target:Team()
		local targetnick = target:Nick()

		if targetteam == TEAM_MAYOR then
			Notify(ply, 1, 4, "Can not set your own salary!")
			return
		elseif targetteam == TEAM_POLICE or targetteam == TEAM_CHIEF then
			if amount > GetGlobalInt("maxcopsalary") then
				Notify(ply, 1, 4, "Civil Protection salary limit: " .. CUR .. GetGlobalInt("maxcopsalary") .. "!")
				return
			else
				DB.StoreSalary(target, amount)
				ply:PrintMessage(2, "Set " .. targetnick .. "'s Salary to: " .. CUR .. amount)
				target:PrintMessage(2, plynick .. " set your Salary to: " .. CUR .. amount)
			end
		elseif targetteam == TEAM_CITIZEN or targetteam == TEAM_GUN or targetteam == TEAM_MEDIC or targetteam == TEAM_COOK then
			if amount > GetGlobalInt("maxnormalsalary") then
				Notify(ply, 1, 4, "Normal Player salary limit: " .. CUR .. GetGlobalInt("maxnormalsalary") .. "!")
				return
			else
				DB.StoreSalary(target, amount)
				ply:PrintMessage(2, "Set " .. targetnick .. "'s Salary to: " .. CUR .. amount)
				target:PrintMessage(2, plynick .. " set your Salary to: " .. CUR .. amount)
			end
		elseif targetteam == TEAM_GANG or targetteam == TEAM_MOB then
			Notify(ply, 1, 4, "Mayor can not set the salary of a Mob Boss or a Gang member.")
			return
		end
	else
		ply:PrintMessage(2, "Could not find player: " .. args[1])
	end
	return
end
concommand.Add("mayor_setsalary", MayorSetSalary)

function DoTeamBan(ply, args, cmdargs)
	if not ply:IsAdmin() then 
		ply:ChatPrint("You're not an admin")
		return ""
	end
	
	local ent = args
	local Team = args
	if cmdargs then
		if not cmdargs[1] then
			ply:PrintMessage(HUD_PRINTNOTIFY, "rp_teamban [player name/ID] [team name/id] Use this to ban a player from a certain team")
			return ""
		end
		ent = cmdargs[1]
		Team = cmdargs[2]
	else
		ent = string.sub(args, 1, string.find(args, " "))
		Team = string.gsub(args, ent, "")
	end
	
	local target = FindPlayer(ent)
	if not target or not ValidEntity(target) then 
		ply:ChatPrint("Player was not found!")
		return ""
	end
	

	local found = false
	for k,v in pairs(team.GetAllTeams()) do
		if string.lower(v.Name) == string.lower(Team) then
			Team = k
			found = true
			break
		end
		if k == Team then
			found = true
			break
		end
	end
	
	if not found then
		ply:ChatPrint("Team not found!")
		return ""
	end
	if not target.bannedfrom then target.bannedfrom = {} end
	target.bannedfrom[Team] = 1
	NotifyAll(1, 5, ply:Nick() .. " has banned " ..target:Nick() .. " from being a " .. team.GetName(Team))
	return ""
end
AddChatCommand("/teamban", DoTeamBan)
concommand.Add("rp_teamban", DoTeamBan)

function DoTeamUnBan(ply, args, cmdargs)
	if not ply:IsAdmin() then 
		ply:ChatPrint("You're not an admin")
		return ""
	end
	
	local ent = args
	local Team = args
	if cmdargs then
		if not cmdargs[1] then
			ply:PrintMessage(HUD_PRINTNOTIFY, "rp_teamunban [player name/ID] [team name/id] Use this to unban a player from a certain team")
			return ""
		end
		ent = cmdargs[1]
		Team = cmdargs[2]
	else
		ent = string.sub(args, 1, string.find(args, " "))
		Team = string.gsub(args, ent, "")
	end
	
	local target = FindPlayer(ent)
	if not target or not ValidEntity(target) then 
		ply:ChatPrint("Player was not found!")
		return ""
	end
	

	local found = false
	for k,v in pairs(team.GetAllTeams()) do
		if string.lower(v.Name) == string.lower(Team) then
			Team = k
			found = true
			break
		end
		if k == Team then
			found = true
			break
		end
	end
	
	if not found then
		ply:ChatPrint("Team not found!")
		return ""
	end
	if not target.bannedfrom then target.bannedfrom = {} end
	target.bannedfrom[Team] = 0
	NotifyAll(1, 5, ply:Nick() .. " has unbanned " ..target:Nick() .. " from being a " .. team.GetName(Team))
	return ""
end
AddChatCommand("/teamunban", DoTeamUnBan)
concommand.Add("rp_teamunban", DoTeamUnBan)

//local nospamtime = CurTime()
function MakeZombieSoundsAsHobo(ply)
	if not ply.nospamtime then 
		ply.nospamtime = CurTime() - 2
	end
	if not TEAM_HOBO or ply:Team() ~= TEAM_HOBO or CurTime() < (ply.nospamtime + 1.3) then
		return
	end
	ply.nospamtime = CurTime()
	local ran = math.random(1,3)
	if ran == 1 then
		ply:EmitSound("npc/zombie/zombie_voice_idle"..tostring(math.random(1,14))..".wav", 100,100)
	elseif ran == 2 then
		ply:EmitSound("npc/zombie/zombie_pain"..tostring(math.random(1,6))..".wav", 100,100)
	elseif ran == 3 then
		ply:EmitSound("npc/zombie/zombie_alert"..tostring(math.random(1,3))..".wav", 100,100)
	end
end
concommand.Add("_hobo_emitsound", MakeZombieSoundsAsHobo)