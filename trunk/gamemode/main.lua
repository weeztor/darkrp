/*---------------------------------------------------------
 Variables
 ---------------------------------------------------------*/
local timeLeft = 10
local timeLeft2 = 10
local stormOn = false
local zombieOn = false
local maxZombie = 10
RPArrestedPlayersPositions = {}
VoteCopOn = false

/*---------------------------------------------------------
 Zombie
 ---------------------------------------------------------*/
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
			Notify(ply, 1, 4, "You have removed this zombie spawn.")
			table.remove(zombieSpawns,index)
			DB.StoreZombies()
			if ply:GetNWBool("zombieToggle") then
				LoadTable(ply)
			end
		end
	else
		Notify(ply, 1, 4, "You need admin privileges in order to be able to remove zombie positions.")
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
		Notify(ply, 1, 4, "You have added a zombie spawn.")
	else
		Notify(ply, 1, 6, "You need admin privileges in order to be able to add a zombie spawn.")
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
			Notify(ply, 1, 4, "You will now be able to see zombie spawns.")
		else
			ply:SetNWBool("zombieToggle", false)
			Notify(ply, 1, 4, "You will now be unable to see zombie spawns")
		end
	else
		Notify(ply, 1, 6, "You need admin privileges in order to be able to see the zombie spawns.")
	end
	return ""
end
AddChatCommand("/showzombie", ToggleZombie)

function SpawnZombie()
	timer.Start("move")
	if GetAliveZombie() < maxZombie then
		if table.getn(zombieSpawns) > 0 then
			local zombieType = math.random(1, 4)
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
		if not tonumber(args) then
			Notify(ply, 1, 4, "The number entered is invalid.")
			return ""
		end
		maxZombie = tonumber(args)
		Notify(ply, 1, 4, "Max zombies is now set to "..args..".")
	end

	return ""
end
AddChatCommand("/zombiemax", ZombieMax)

function StartZombie(ply)
	if ply:HasPriv(ADMIN) then
		timer.Start("zombieControl")
		Notify(ply, 1, 4, "Zombies are now enabled.")
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
		Notify(ply, 1, 4, "Zombies are now disabled.")
		return ""
	end
end
AddChatCommand("/disablezombie", StopZombie)

timer.Create("start2", 1, 0, SpawnZombie)
timer.Create("zombieControl", 1, 0, ControlZombie)
timer.Stop("start2")
timer.Stop("zombieControl")

/*---------------------------------------------------------
 Meteor storm
 ---------------------------------------------------------*/
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
	timer.Adjust("start", math.random(.1,1), 0, StartShower)
	for k, v in pairs(player.GetAll()) do
		if math.random(0, 2) == 0 then
			if v:Alive() then
				AttackEnt(v)
			end
		end
	end
end

function AttackEnt(ent)
	meteor = ents.Create("meteor")
	meteor.nodupe = true
	meteor:Spawn()
	meteor:SetTarget(ent)
end

function StartStorm(ply)
	if ply:HasPriv(ADMIN) then
		timer.Start("stormControl")
		Notify(ply, 1, 4, "Meteor Storms are now enabled.")
	end
	return ""
end
AddChatCommand("/enablestorm", StartStorm)

function StopStorm(ply)
	if ply:HasPriv(ADMIN) then
		timer.Stop("stormControl")
		stormOn = false
		timer.Stop("start")
		StormEnd()
		Notify(ply, 1, 4, "Meteor Storms are now disabled.")
		return ""
	end
end
AddChatCommand("/disablestorm", StopStorm)

timer.Create("start", 1, 0, StartShower)
timer.Create("stormControl", 1, 0, ControlStorm)

timer.Stop("start")
timer.Stop("stormControl")

/*---------------------------------------------------------
 Earthquake
 ---------------------------------------------------------*/
local tremor = ents.Create("env_physexplosion")
tremor:SetPos(Vector(0,0,0))
tremor:SetKeyValue("radius",9999999999)
tremor:SetKeyValue("spawnflags", 7)
tremor.nodupe = true
tremor:Spawn()

function TremorReport(alert)
	local mag = table.remove(lastmagnitudes, 1)
	if mag then
		local alert = "Earthquake"
		if mag < 6.5 then
			alert = "Earth Tremor"
		end
		NotifyAll(1, 3, alert .. " reported of magnitude " .. tostring(mag) .. "Mw")
	end
end

/*---------------------------------------------------------
 Flammable
 ---------------------------------------------------------*/
local FlammableProps = {"drug", "drug_lab", "food", "gunlab", "letter", "microwave", "money_printer", "spawned_shipment", "spawned_weapon", "cash_bundle", "prop_physics"}

function IsFlammable(ent)
	local class = ent:GetClass()
	for k, v in pairs(FlammableProps) do
		if class == v then return true end
	end
	return false
end

-- FireSpread from SeriousRP
function FireSpread(e)
	if e:IsOnFire() then
		if e:GetTable().MoneyBag then
			e:Remove()
		end
		local en = ents.FindInSphere(e:GetPos(), math.random(20, 90))
		local maxcount = 3
		local count = 1
		local rand = 0
		for k, v in pairs(en) do
			if IsFlammable(v) then
			if count >= maxcount then break end
				if math.random(0.0, 60000) < 1.0 then
					if not v.burned then
						v:Ignite(math.random(5,180), 0)
						v.burned = true
					else
						local r, g, b, a = v:GetColor()
						if (r - 51)>=0 then r = r - 51 end
						if (g - 51)>=0 then g = g - 51 end
						if (b - 51)>=0 then b = b - 51 end
						v:SetColor(r, g, b, a)
						math.randomseed((r / (g+1)) + b)
						if (r + g + b) < 103 and math.random(1, 100) < 35 then
							v:Fire("enablemotion","",0)
							constraint.RemoveAll(v)
						end
					end
					count = count + 1
				end
			end
		end
	end
end

function FlammablePropThink()
	for k, v in ipairs(FlammableProps) do
		local ens = ents.FindByClass(v)
		
		for a, b in pairs(ens) do
			FireSpread(b)
		end
	end
end

/*---------------------------------------------------------
 Drugs
 ---------------------------------------------------------*/
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

/*---------------------------------------------------------
 Shipments
 ---------------------------------------------------------*/
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
for k,v in pairs(CustomShipments) do
	weaponClasses[v.entity] = v.model
end

function DropWeapon(ply)
	local ent = ply:GetActiveWeapon()
	if not ValidEntity(ent) then return "" end
	
	if CfgVars["RestrictDrop"] == 1 then
		local found = false
		for k,v in pairs(weaponClasses) do
			if k == ent:GetClass() then
				found = true
				break
			end
		end
		if not found then
			Notify(ply, 1, 4, "Can't drop this weapon!")
			return "" 
		end
	end
	ply:DropWeapon(ent)
	return ""
end
AddChatCommand("/drop", DropWeapon)
AddChatCommand("/dropweapon", DropWeapon)
AddChatCommand("/weapondrop", DropWeapon)

/*---------------------------------------------------------
 Warrants/wanted
 ---------------------------------------------------------*/
function UnWarrant(ply, target)
	if not target.warranted then return end
	target.warranted = false
	Notify(ply, 1, 4, "The search warrant for " .. target:Nick() .. " has expired!")
end 

function SetWarrant(ply, target)
	target.warranted = true
	timer.Simple(CfgVars["searchtime"], UnWarrant, ply, target)
	for a, b in pairs(player.GetAll()) do
		b:PrintMessage(HUD_PRINTCENTER, "Search warrant approved for " .. target:Nick() .. "!")
	end
	Notify(ply, 1, 4, "You are now able to search his house.")
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
		Notify(ply, 1, 4, "You must be a cop or the Mayor in order to be able to make a warrant.")
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
					ques:Create(ply:Nick() .. " requests a search warrant for " .. p:Nick(), p:EntIndex() .. "warrant", m, 40, FinishWarrant, ply, p)
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
		Notify(ply, 1, 6, "You must be a Cop or the Mayor in order to be able to make someone wanted.")
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
		Notify(ply, 1, 6, "You must be a Cop or the Mayor in order to be able to make someone unwanted.")
	else
		local p = FindPlayer(args)
		if p and p:Alive() and p:GetNWBool("wanted") then
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
	if p and p:Alive() and p:GetNWBool("wanted") then
		p:SetNWBool("wanted", false)
		for a, b in pairs(player.GetAll()) do
			b:PrintMessage(HUD_PRINTCENTER, "The wanted for " .. p:Nick() .. " has expired.")
			timer.Destroy(p:Nick() .. " wantedtimer")
		end
	else
		return ""
	end
end

/*---------------------------------------------------------
Spawning 
 ---------------------------------------------------------*/
function SetSpawnPos(ply, args)
	if not ply:HasPriv(ADMIN) and not ply:IsAdmin() and not ply:IsSuperAdmin() then return "" end

	local pos = string.Explode(" ", tostring(ply:GetPos()))
	local selection = "citizen"
	local t
	
	for k,v in pairs(RPExtraTeams) do
		if args == v.command then
			t = k
			Notify(ply, 1, 4, "You have set the ".. v.name .. " Spawn Position.")
		end
	end

	if t then
		DB.StoreTeamSpawnPos(t, pos)
	else
		Notify(ply, 1, 4, "Team "..args.." not found!")
	end

	return ""
end
AddChatCommand("/setspawn", SetSpawnPos)

/*---------------------------------------------------------
 Helps
 ---------------------------------------------------------*/
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
	ply:SetNWBool("helpAdmin", false)
	return ""
end
AddChatCommand("/x", closeHelp)

function ShowSpare1(ply)
	ply:ConCommand("gm_showspare1\n")
end
concommand.Add("gm_spare1", ShowSpare1)

function ShowSpare2(ply)
	ply:ConCommand("gm_showspare2\n")
end
concommand.Add("gm_spare2", ShowSpare2)

function GM:ShowTeam(ply)
	ply:SendLua("KeysMenu(" ..tostring(ply:GetEyeTrace().Entity:IsVehicle()) .. ")")
end

function GM:ShowHelp(ply)
	umsg.Start("ToggleHelp", ply)
	umsg.End()
end

function LookPersonUp(ply, cmd, args)
	if not args[1] then 
		ply:PrintMessage(2, "argument invalid")
		return 
	end
	local P = FindPlayer(args[1])
	if not ValidEntity(P) then
		ply:PrintMessage(2, "Player not found!")
	end
	ply:PrintMessage(2, "Nick: ".. P:Nick())
	ply:PrintMessage(2, "Steam name: "..P:SteamName())
	ply:PrintMessage(2, "Steam ID: "..P:SteamID())
end
concommand.Add("rp_lookup", LookPersonUp)

/*---------------------------------------------------------
 Items
 ---------------------------------------------------------*/
local function MakeLetter(ply, args, type)
	if CfgVars["letters"] == 0 then
		Notify(ply, 1, 4, "Letter writing is disabled.")
		return ""
	end

	if ply.maxletters and ply.maxletters >= CfgVars["maxletters"] then
		Notify(ply, 1, 4, "You have reached the letters limit.")
		return ""
	end

	if CurTime() - ply:GetTable().LastLetterMade < 3 then
		Notify(ply, 1, 4, "You need to wait another " .. math.ceil(3 - (CurTime() - ply:GetTable().LastLetterMade)) .. " seconds before writing another letter!")
		return ""
	end

	ply:GetTable().LastLetterMade = CurTime()

	-- Instruct the player's letter window to open

	local ftext = string.gsub(args, "//", "\n")
	ftext = string.gsub(args, "\\n", "\n")
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
	letter.type = type
	letter.numPts = numParts

	local startpos = 1
	local endpos = 39
	letter.Parts = {}
	for k=1, numParts do
		table.insert(letter.Parts, string.sub(ftext, startpos, endpos))
		startpos = startpos + 39
		endpos = endpos + 39
	end
	letter.SID = ply.SID

	PrintMessageAll(2, ply:Nick() .. " created a letter.")
	if not ply.maxletters then
		ply.maxletters = 0
	end
	ply.maxletters = ply.maxletters + 1
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

function RemoveLetters(ply)
	for k, v in pairs(ents.FindByClass("letter")) do
		if v.SID == ply.SID then v:Remove() end
	end
	Notify(ply, 1, 4, "Your letters were cleaned up.")
	return ""
end
AddChatCommand("/removeletters", RemoveLetters)

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
		Notify(ply, 1, 4, "You need to be looking at a Gun Lab, druglab or Microwave!")
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

	if CfgVars["enablebuypistol"] == 0 then
		Notify(ply, 1, 4, "/buy is disabled!")
		return ""
	end
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
		Notify(ply, 1, 4, "This weapon is not available!")
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
		Notify(ply, 1, 4, "You You can not afford this!")
		return ""
	end
	
	ply:AddMoney(-price)
	
	Notify(ply, 1, 4, "You have bought a " .. args .. " for " .. CUR .. tostring(price))
	
	local weapon = ents.Create("spawned_weapon")
	weapon:SetModel(model)
	weapon.weaponclass = class
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
				Notify(ply, 1, 4, "You must be a Gun Dealer to buy gun shipments!")
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
				Notify(ply, 1, 4, "You can not buy this shipment because you don't have the correct class!")
				return "" 
			end
		end
	end
	
	if not found then
		Notify(ply, 1, 4, "This weapon is not available!")
		return ""
	end
	
	local cost
	if found == true then
		cost = GetGlobalInt(args .. "cost")
	else
		cost = found.price
	end
	
	if not ply:CanAfford(cost) then
		Notify(ply, 1, 4, "You You can not afford this!")
		return ""
	end
	
	ply:AddMoney(-cost)
	Notify(ply, 1, 4, "You have bought a Shipment of " .. args .. "s for " .. CUR .. tostring(cost))
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
	local phys = crate:GetPhysicsObject()
	if phys and phys:IsValid() then phys:Wake() end
	return ""
end
AddChatCommand("/buyshipment", BuyShipment)

function BuyVehicle(ply, args)
	if RPArrestedPlayers[ply:SteamID()] then return "" end
	if args == "" then return "" end
	local found = false
	for k,v in pairs(CustomVehicles) do
		if string.lower(v.name) == string.lower(args) then found = CustomVehicles[k] break end
	end
	if not found then return "" end
	if found.allowed and not table.HasValue(found.allowed, ply:Team()) then Notify(ply, 1, 4, "You don't have the right job!") return ""  end
	
	if not ply.Vehicles then ply.Vehicles = 0 end
	if CfgVars["maxvehicles"] ~= 0 and ply.Vehicles >= CfgVars["maxvehicles"] then
		Notify(ply, 1, 4, "You are unable to buy a vehicle as the limit is reached.")
		return ""
	end
	ply.Vehicles = ply.Vehicles + 1
	
	if not ply:CanAfford(found.price) then Notify(ply, 1, 4, "need "..CUR..found.price.."!") return "" end
	ply:AddMoney(-found.price)
	Notify(ply, 1, 4, "You have bought a "..found.name.." for " .. CUR .. found.price)
	
	local Vehicle = list.Get("Vehicles")[found.name]
	if not Vehicle then Notify(ply, 1, 4, "This is an invalid vehicle!") return "" end
	
	local trace = {}
	trace.start = ply:EyePos()
	trace.endpos = trace.start + ply:GetAimVector() * 85
	trace.filter = ply
	local tr = util.TraceLine(trace)
	
	local ent = ents.Create(Vehicle.Class)
	if not ent then return "" end
	ent:SetModel(Vehicle.Model)
	if Vehicle.KeyValues then
		for k, v in pairs( Vehicle.KeyValues ) do
			ent:SetKeyValue( k, v )
		end            
	end
	
	local Angles = ply:GetAngles()
	Angles.pitch = 0
	Angles.roll = 0
	Angles.yaw = Angles.yaw + 180
	ent:SetAngles(Angles)
	ent:SetPos(tr.HitPos)
	ent.VehicleName = found.Name
	ent.VehicleTable = found
	ent:SetNWString("Owner", ply:Nick())
	ent:Spawn()
	ent:Activate()
	ent.SID = ply.SID
	ent.ClassOverride = Vehicle.Class
	ent:Own(ply)
	return ""
end
AddChatCommand("/buyvehicle", BuyVehicle)

function BuyDrugLab(ply)
	if args == "" then return "" end
	if RPArrestedPlayers[ply:SteamID()] then return "" end
	
	local trace = {}
	trace.start = ply:EyePos()
	trace.endpos = trace.start + ply:GetAimVector() * 85
	trace.filter = ply
	
	if ply:Team() ~= TEAM_GANG and ply:Team() ~= TEAM_MOB then
		Notify(ply, 1, 4, "You must be a gangster or mobboss!")
		return "" 
	end

	local tr = util.TraceLine(trace)

	local cost = GetGlobalInt("druglabcost")
	if not ply:CanAfford(cost) then
		Notify(ply, 1, 4, "You You can not afford this!")
		return ""
	end
	if ply.maxDrug and ply.maxDrug == CfgVars["maxdruglabs"] then
		Notify(ply, 1, 4, "You have reached the limit of druglabs.")
		return ""
	end
	ply:AddMoney(-cost)
	Notify(ply, 1, 4, "You have bought a Drug Lab for " .. CUR .. tostring(cost))
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
		Notify(ply, 1, 4, "You You can not afford this!")
		return ""
	end

	if ply:GetNWInt("maxmicrowaves") == CfgVars["maxmicrowaves"] then
		Notify(ply, 1, 4, "You have reached the limit of microwaves.")
		return ""
	end

	if ply:Team() == TEAM_COOK then
		ply:AddMoney(-cost)
		Notify(ply, 1, 4, "You have bought a Microwave for " .. CUR .. tostring(cost))
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
		Notify(ply, 1, 4, "You need to be a Cook to be able to buy this!")
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
		Notify(ply, 1, 4, "You You can not afford this!")
		return ""
	end
	if ply.maxgunlabs and ply.maxgunlabs == CfgVars["maxgunlabs"] then
		Notify(ply, 1, 4, "You have reached the limit of gunlabs!")
		return ""
	end
	if ply:Team() == TEAM_GUN then
		ply:AddMoney(-cost)
		Notify(ply, 1, 4, "You have bought a Gun Lab for " .. CUR .. tostring(cost))
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
		Notify(ply, 1, 4, "You need to be a Gun Dealer!")
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
		Notify(ply, 1, 4, "You You can not afford this!")
		return ""
	end

	if ply.maxmprinters and ply.maxmprinters >= CfgVars["maxmprinters"] then
		Notify(ply, 1, 4, "You have reached the limit of money printers!")
		return ""
	end

	ply:AddMoney(-cost)
	Notify(ply, 1, 4, "You have bought a Money Printer for " .. CUR .. tostring(cost))
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
		Notify(ply, 1, 4, "You can not buy ammo because guns are disabled.")
		return ""
	end
	
	if args ~= "rifle" and args ~= "shotgun" and args ~= "pistol" then
		Notify(ply, 1, 4, "That ammo type is not available!")
	end
	
	if not ply:CanAfford(GetGlobalInt("ammo" .. args .. "cost")) then
		Notify(ply, 1, 4, "You can not afford this!")
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

	Notify(ply, 1, 4, "You have bought some " .. args .. " ammo for " .. CUR .. tostring(cost))
	ply:AddMoney(-cost)

	return ""
end
AddChatCommand("/buyammo", BuyAmmo)

function BuyHealth(ply)
	local cost = GetGlobalInt("healthcost")
	if not ply:CanAfford(cost) then
		Notify(ply, 1, 4, "You can not afford this!")
		return ""
	end
	if ply:Team() ~= TEAM_MEDIC and team.NumPlayers(TEAM_MEDIC) > 0 then
		Notify(ply, 1, 4, "/buyhealth is disabled since there are Medics.")
		return ""
	end
	if ply.StartHealth and ply:Health() >= ply.StartHealth then
		Notify(ply, 1, 4, "You have too much health to buy health!")
		return "" 
	end
	ply.StartHealth = ply.StartHealth or 100
	ply:AddMoney(-cost)
	Notify(ply, 1, 4, "You have bought Health for " .. CUR .. tostring(cost))
	ply:SetHealth(ply.StartHealth)
	return ""
end
AddChatCommand("/buyhealth", BuyHealth)

local function MakeACall(ply,args)
	local p = FindPlayer(args)
	if not ValidEntity(p) then return "" end
	if ValidEntity(ply:GetNWEntity("phone")) or ValidEntity(p:GetNWEntity("phone")) then
		Notify(ply, 1, 4, "He's already in a conversation!")
		return "" 
	end
	if not p:Alive() or p == ply or not ply:Alive() then return "" end
	local trace = {}
	trace.start = p:EyePos()
	trace.endpos = trace.start + p:GetAimVector() * 85
	trace.filter = p
	local tr = util.TraceLine(trace)
	
	local banana = ents.Create("phone")
	
	banana:SetNWEntity("owning_ent", p)
	banana:SetNWString("Owner", "Shared") 
	banana.Caller = ply
	
	banana:SetPos(tr.HitPos)
	banana.onlyremover = true
	banana.SID = p.SID
	banana:Spawn()
	
	
	local ownphone = ents.Create("phone")
	
	ownphone:SetNWEntity("owning_ent", ply)
	ownphone:SetNWString("Owner", "Shared") 
	ownphone:SetNWBool("IsBeingHeld", true)
	ply:SetNWEntity("phone", ownphone)
	
	ownphone:SetPos(ply:GetShootPos())
	ownphone.onlyremover = true
	ownphone.SID = ply.SID
	ownphone:Spawn()
	ownphone:Use(ply,ply)--Put it on the ear already, since you're the one who'se calling...
	timer.Simple(20, function(ply, OtherPhone)
		local MyPhone = ply:GetNWEntity("phone")
		local WhoPickedItUp = MyPhone.Caller
		if ValidEntity(MyPhone) and ValidEntity(OtherPhone) and not ValidEntity(WhoPickedItUp) then -- if noone picked up the phone then hang up :)
			MyPhone:Remove()
			OtherPhone:Remove()
		end
	end, ply, banana)
	return ""
end
AddChatCommand("/call", MakeACall)

local function HangUp(ply, code)
	if code == IN_USE and ValidEntity(ply:GetNWEntity("phone")) then
		ply:GetNWEntity("phone"):HangUp()
	end
end
hook.Add("KeyPress", "HangUpPhone", HangUp)

/*---------------------------------------------------------
 Jobs
 ---------------------------------------------------------*/
function CreateAgenda(ply, args)
	if ply:Team() == TEAM_MOB then
		CfgVars["mobagenda"] = string.gsub(string.gsub(args, "//", "\n"), "\\n", "\n")

		for k, v in pairs(player.GetAll()) do
			local t = v:Team()
			if t == TEAM_GANG or t == TEAM_MOB then
				Notify(v, 1, 4, "The mob boss has updated the agenda!")
				v:SetNWString("agenda", CfgVars["mobagenda"])
			end
		end
	else
		Notify(ply, 1, 6, "You need to be a mob boss to be able to use this command.")
	end
	return ""
end
AddChatCommand("/agenda", CreateAgenda)

function GetHelp(ply, args)
	umsg.Start("ToggleHelp", ply)
	umsg.End()
	return ""
end
AddChatCommand("/help", GetHelp)

function ChangeJob(ply, args)
	if args == "" then return "" end
	
	if ply.LastJob and 60 - (CurTime() - ply.LastJob) >= 0 then
		Notify(ply, 1, 4, "Please wait ".. math.ceil(60 - (CurTime() - ply.LastJob)).." seconds before changing your job")
		return ""
	end
	ply.LastJob = CurTime()
	
	if not ply:Alive() then
		Notify(ply, 1, 4, "You can not change job as a dead person.")
		return ""
	end

	if CfgVars["customjobs"] ~= 1 then
		Notify(ply, 1, 4, "You can not change job as they are disabled.")
		return ""
	end

	local len = string.len(args)

	if len < 3 then
		Notify(ply, 1, 4, "The job name needs to be at least 3 characters!")
		return ""
	end

	if len > 25 then
		Notify(ply, 1, 4, "The job name is restricted to 25 characters!")
		return ""
	end

	local jl = string.lower(args)
	local t = ply:Team()

	for k,v in pairs(RPExtraTeams) do
		if jl == v.name then
			ply:ChangeTeam(k)
		end
	end
	NotifyAll(2, 4, ply:Nick() .. " has set his/her job to '" .. args .. "'")
	ply:UpdateJob(args)
	return ""
end
AddChatCommand("/job", ChangeJob)

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
		Notify(ply, 1, 4, "The reason needs to be 22 characters or less")
		return "" 
	end
	local p = FindPlayer(tableargs[1])
	if p then
		if CurTime() - ply:GetTable().LastVoteCop < 80 then
			Notify(ply, 1, 4, "Please wait another " .. math.ceil(80 - (CurTime() - ply:GetTable().LastVoteCop)) .. " seconds before demoting.")
			return ""
		end
		if p:Team() == TEAM_CITIZEN then
			Notify(ply, 1, 4,  p:Nick() .." is already Citizen, he can't be demoted any further!")
		else
			NotifyAll(1, 4, ply:Nick() .. " has started a vote for the demotion of " .. p:Nick())
			vote:Create(p:Nick() .. ":\nDemotion Nominee:\n"..reason, p:EntIndex() .. "votecop"..ply:EntIndex(), p, 20, FinishDemote, true)
			ply:GetTable().LastVoteCop = CurTime()
			VoteCopOn = true
			Notify(ply, 1, 4, "The demotion vote has started!")
		end
		return ""
	else
		Notify(ply, 1, 4, "This player does not exist!")
		return ""
	end
end
AddChatCommand("/demote", Demote)

function DoTeamBan(ply, args, cmdargs)
	if not ply:IsAdmin() then 
		Notify(ply, 1, 4, "You need admin privileges in order to be able to ban someone from a job.")
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
		local a,b = string.find(args, " ")
		ent = string.sub(args, 1, a - 1)
		Team = string.sub(args,  a + 1)
	end
	
	local target = FindPlayer(ent)
	if not target or not ValidEntity(target) then 
		Notify(ply, 1, 4, "This player was not found!")
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
		Notify(ply, 1, 4, "This job was not found!")
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
		Notify(ply, 1, 4, "You need admin privileges in order to be able to unban someone from a job.")
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
		local a,b = string.find(args, " ")
		ent = string.sub(args, 1, a - 1)
		Team = string.sub(args,  a + 1)
	end
	
	local target = FindPlayer(ent)
	if not target or not ValidEntity(target) then 
		Notify(ply, 1, 4, "This player was not found!")
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
		Notify(ply, 1, 4, "This job was not found!")
		return ""
	end
	if not target.bannedfrom then target.bannedfrom = {} end
	target.bannedfrom[Team] = 0
	NotifyAll(1, 5, ply:Nick() .. " has unbanned " ..target:Nick() .. " from being a " .. team.GetName(Team))
	return ""
end
AddChatCommand("/teamunban", DoTeamUnBan)
concommand.Add("rp_teamunban", DoTeamUnBan)
/*---------------------------------------------------------
Talking 
 ---------------------------------------------------------*/
function PM(ply, args)
	local namepos = string.find(args, " ")
	if not namepos then return "" end

	local name = string.sub(args, 1, namepos - 1)
	local msg = string.sub(args, namepos + 1)
	if msg == "" then return "" end
	target = FindPlayer(name)

	if target then
		local col = team.GetColor(ply:Team())
		TalkToPerson(target, col, "(PM) "..ply:Nick(),Color(255,255,255,255), msg, ply)
		TalkToPerson(ply, col, "(PM) "..ply:Nick(), Color(255,255,255,255), msg, ply)
	else
		Notify(ply, 1, 4, "Could not find player: " .. name)
	end

	return ""
end
AddChatCommand("/pm", PM)

function Whisper(ply, args)
	TalkToRange(ply, "(WHISPER) " .. ply:Nick(), args, 90)
	return ""
end
AddChatCommand("/w", Whisper)

function Yell(ply, args)
	TalkToRange(ply, "(YELL) " .. ply:Nick(), args, 550)
	return ""
end
AddChatCommand("/y", Yell)

function OOC(ply, args)
	if CfgVars["ooc"] == 0 then
		Notify(ply, 1, 4, "OOC is disabled")
		return ""
	end

	local col = team.GetColor(ply:Team())
	local col2 = Color(255,255,255,255)
	if not ply:Alive() then
		col2 = Color(255,200,200,255)
		col = col2
	end
	for k,v in pairs(player.GetAll()) do
		TalkToPerson(v, col, "(OOC) "..ply:Name(), col2, args, ply)
	end
	return ""
end
AddChatCommand("//", OOC, true)
AddChatCommand("/a", OOC, true)
AddChatCommand("/ooc", OOC, true)

function PlayerAdvertise(ply, args)
	for k,v in pairs(player.GetAll()) do
		local col = team.GetColor(ply:Team())
		TalkToPerson(v, col, "[ADVERT] "..ply:Nick(), Color(255,255,0,255), args, ply)
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
	ply.RadioChannel = tonumber(args)
	return ""
end
AddChatCommand("/channel", SetRadioChannel)

function SayThroughRadio(ply,args)
	print(args)
	if not ply.RadioChannel then ply.RadioChannel = 1 end
	if not args or args == "" then
		Notify(ply, 1, 4, "Please enter a message!")
		return ""
	end
	for k,v in pairs(player.GetAll()) do
		if v.RadioChannel == ply.RadioChannel then
			TalkToPerson(v, Color(180,180,180,255), "Radio ".. tostring(ply.RadioChannel), Color(180,180,180,255), args, ply)
		end
	end
	return ""
end
AddChatCommand("/radio", SayThroughRadio)

function CombineRequest(ply, args)
	local t = ply:Team()
	for k, v in pairs(player.GetAll()) do
		if v:Team() == TEAM_POLICE or v:Team() == TEAM_CHIEF or v == ply then
			TalkToPerson(ply, team.GetColor(ply:Team()), "(REQUEST!) "..ply:Nick(), Color(255,0,0,255), args, ply)
			TalkToPerson(v, team.GetColor(ply:Team()), "(REQUEST!) "..ply:Nick(), Color(255,0,0,255), args, ply)
		end
	end
	return ""
end
AddChatCommand("/cr", CombineRequest)

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
		local col = team.GetColor(ply:Team())
		TalkToPerson(v, col, "(GROUP) "..ply:Nick(),Color(255,255,255,255), args, ply)
	end
	return ""
end
AddChatCommand("/g", GroupMsg)

-- here's the new easter egg. Easier to find, more subtle, doesn't only credit FPtje and unib5
local CreditsWait = true
function GetDarkRPAuthors(ply)
	if not CreditsWait then Notify(ply, 1, 4, "Wait with that") return "" end
	CreditsWait = false
	timer.Simple(60, function() CreditsWait = true end)--so people don't spam it
	for k,v in pairs(player.GetAll()) do
		TalkToPerson(v, Color(255,0,0,255), "CREDITS FOR DARKRP", Color(0,0,255,255),
		"\nRickster\nPicwizdan\nSibre\nPhilXYZ\n[GNC] Matt\nChromebolt A.K.A. unib5 (STEAM_0:1:19045957)\n(FPtje) Falco A.K.A. FPtje (STEAM_0:0:8944068)", ply)
	end
	return ""
end
AddChatCommand("/credits", GetDarkRPAuthors)

/*---------------------------------------------------------
 Money
 ---------------------------------------------------------*/
function GiveMoney(ply, args)
	if args == "" then return "" end

	if not tonumber(args) then
		return ""
	end
	local trace = ply:GetEyeTrace()

	if ValidEntity(trace.Entity) and trace.Entity:IsPlayer() and trace.Entity:GetPos():Distance(ply:GetPos()) < 150 then
		local amount = math.floor(tonumber(args))

		if amount < 1 then
			Notify(ply, 1, 4, "Invalid amount of money! Must be at least " .. CUR .. "1!")
			return
		end

		if not ply:CanAfford(amount) then
			Notify(ply, 1, 4, "You can not afford this!")
			return ""
		end

		DB.PayPlayer(ply, trace.Entity, amount)

		Notify(trace.Entity, 0, 4, ply:Nick() .. " has given you " .. CUR .. tostring(amount))
		Notify(ply, 0, 4, "You gave " .. trace.Entity:Nick() .. " " .. CUR .. tostring(amount))
	else
		Notify(ply, 1, 4, "You need to be looking at and standing close to another player!")
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
		Notify(ply, 1, 4, "You can not afford this!")
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

/*---------------------------------------------------------
 Mayor stuff
 ---------------------------------------------------------*/
local LotteryPeople = {}
local LotteryON = false
local CanLottery = CurTime()
function EnterLottery(answer, ent, initiator, target, TimeIsUp)
	if answer == 1 and not table.HasValue(LotteryPeople, target) then
		if not target:CanAfford(CfgVars["lotterycommitcost"]) then
			Notify(target, 1,4, "You can not afford the commitment cost of the lottery!")
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
			NotifyAll(1,4, "Noone has entered the lottery")
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
		Notify(ply, 1, 4, "You need to be the mayor in order to be able to start a lottery.")
		return "" 
	end
	
	if CfgVars["lottery"] ~= 1 then
		Notify(ply, 1, 4, "You can not start a lottery as they are disabled.")
		return ""
	end
	
	if #player.GetAll() <= 2 then
		Notify(ply, 1, 6, "There are not enough people in the server for a lottery to be successful")
		return "" 
	end 
	
	if LotteryON then
		Notify(ply, 1, 4, "There already is a lottery ongoing!")
		return "" 
	end
	if CanLottery > CurTime() then
		Notify(ply, 1, 5, "You have to wait "..tostring(CanLottery - CurTime()).." seconds to be able to start a lottery again.")
		return "" 
	end
	Notify(ply, 1, 4, "You have started a lottery!")
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

function Lockdown(ply)
	if GetGlobalInt("lstat") ~= 1 then
		if ply:Team() == TEAM_MAYOR or ply:HasPriv(ADMIN) then
			for k,v in pairs(player.GetAll()) do
				v:ConCommand("play npc/overwatch/cityvoice/f_confirmcivilstatus_1_spkr.wav\n")
			end
			DB.SaveGlobal("lstat", 1)
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
			DB.SaveGlobal("ulstat", 1)
			timer.Create("spamlock", 20, 1, WaitLock, "")
		end
	end
	return ""
end
concommand.Add("rp_unlockdown", UnLockdown)
AddChatCommand("/unlockdown", UnLockdown)

function WaitLock()
	DB.SaveGlobal("ulstat", 0)
	DB.SaveGlobal("lstat", 0)
	timer.Destroy("spamlock")
end

function MayorSetSalary(ply, cmd, args)
	if ply:EntIndex() == 0 then
		print("Console should use rp_setsalary instead.")
		return
	end

	if CfgVars["enablemayorsetsalary"] == 0 then
		ply:PrintMessage(2, "Can not set salary as it is disabled.")
		Notify(ply, 1, 4, "Can not set salary as it is disabled.")
		return "Can not set salary as it is disabled."
	end

	if ply:Team() ~= TEAM_MAYOR then
		ply:PrintMessage(2, "You need to be the mayor to be able to set someone's salary.")
		return
	end

	local amount = math.floor(tonumber(args[2]))

	if not amount or amount < 0 then
		ply:PrintMessage(2, "Invalid Salary: " .. args[2])
		return
	end

	if amount > GetGlobalInt("maxmayorsetsalary") then
		ply:PrintMessage(2, "Salary must be less than or equal to " .. CUR .. GetGlobalInt("maxmayorsetsalary") .."!")
		return
	end

	local plynick = ply:Nick()
	local target = FindPlayer(args[1])

	if target then
		local targetteam = target:Team()
		local targetnick = target:Nick()

		if targetteam == TEAM_MAYOR then
			Notify(ply, 1, 4, "You can not set your own salary!")
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
			Notify(ply, 1, 4, "The mayor can not set the salary of a mob boss or a Gang member.")
			return
		end
	else
		ply:PrintMessage(2, "Could not find player: " .. args[1])
	end
	return
end
concommand.Add("rp_mayor_setsalary", MayorSetSalary)

/*---------------------------------------------------------
 License
 ---------------------------------------------------------*/
function GrantLicense(answer, Ent, Initiator, Target)
	if answer == 1 then
		Notify(Initiator, 1, 4, Target:Nick().. " has granted you a gun license")
		Notify(Target, 1, 4, "You have granted ".. Initiator:Nick().. " a gun license")
		Initiator:SetNWBool("HasGunlicense", true)
	else
		Notify(Initiator, 1, 4, Target:Nick().. " has denied your gun license request")
	end
end

function RequestLicense(ply)
	if ply:GetNWBool("HasGunlicense") then
		Notify(ply, 1, 4, "You already have a license!")
		return ""
	end
	local LookingAt = ply:GetEyeTrace().Entity
	
	local ismayor--first look if there's a mayor
	local ischief-- then if there's a chief
	local iscop-- and then if there's a cop to ask
	for k,v in pairs(player.GetAll()) do
		if v:Team() == TEAM_MAYOR then
			ismayor = true
			break
		end
	end
	
	if not ismayor then
		for k,v in pairs(player.GetAll()) do
			if v:Team() == TEAM_CHIEF then
				ischief = true
				break
			end
		end
	end
	
	if not ischief and not ismayor then
		for k,v in pairs(player.GetAll()) do
			if v:Team() == TEAM_POLICE then
				iscop = true
				break
			end
		end
	end
	
	if not ismayor and not ischief and not iscop then
		Notify(ply, 1, 4, "There's noone to ask for a license!")
		return ""
	end
	
	if not ValidEntity(LookingAt) or not LookingAt:IsPlayer() or LookingAt:GetPos():Distance(ply:GetPos()) > 100 then
		Notify(ply, 1, 4, "You need to be looking at a mayor/chief/cop")
		return ""
	end
	
	if ismayor and LookingAt:Team() ~= TEAM_MAYOR then
		Notify(ply, 1, 4, "You need to be looking at the mayor!")
		return ""
	elseif ischief and LookingAt:Team() ~= TEAM_CHIEF then
		Notify(ply, 1, 4, "You need to be looking at the chief!")
		return ""
	elseif iscop and LookingAt:Team() ~= TEAM_POLICE then
		Notify(ply, 1, 4, "You need to be looking at a cop!")
		return ""
	end
	
	Notify(ply, 1, 4, "You have requested a gun license!")
	ques:Create("Grant "..ply:Nick().." a gun license?", "Gunlicense"..ply:EntIndex(), LookingAt, 20, GrantLicense, ply, LookingAt)
	return ""
end
AddChatCommand("/requestlicense", RequestLicense)

function GiveLicense(ply)
	local ismayor--first look if there's a mayor
	local ischief-- then if there's a chief
	local iscop-- and then if there's a cop to ask
	for k,v in pairs(player.GetAll()) do
		if v:Team() == TEAM_MAYOR then
			ismayor = true
			break
		end
	end
	
	if not ismayor then
		for k,v in pairs(player.GetAll()) do
			if v:Team() == TEAM_CHIEF then
				ischief = true
				break
			end
		end
	end
	
	if not ischief and not ismayor then
		for k,v in pairs(player.GetAll()) do
			if v:Team() == TEAM_POLICE then
				iscop = true
				break
			end
		end
	end
	
	if ismayor and ply:Team() ~= TEAM_MAYOR then
		Notify(ply, 1, 4, "Must be the mayor!")
		return ""
	elseif ischief and ply:Team() ~= TEAM_CHIEF then
		Notify(ply, 1, 4, "Must be the chief/the mayor!")
		return ""
	elseif iscop and ply:Team() ~= TEAM_POLICE then
		Notify(ply, 1, 4, "Must be a cop/chief/mayor!")
		return ""
	end
	
	local LookingAt = ply:GetEyeTrace().Entity
	if not ValidEntity(LookingAt) or not LookingAt:IsPlayer() or LookingAt:GetPos():Distance(ply:GetPos()) > 100 then
		Notify(ply, 1, 4, "You need to be looking at a player!")
		return ""
	end
	Notify(LookingAt, 1, 4, ply:Nick().. " has granted you a gun license")
	Notify(ply, 2, 4, "You have granted ".. LookingAt:Nick().. " a gun license")
	LookingAt:SetNWBool("HasGunlicense", true)
	return ""
end
AddChatCommand("/givelicense", GiveLicense)

function rp_GiveLicense(ply, cmd, args)
	if ply:EntIndex() ~= 0 and not ply:IsSuperAdmin() then
		ply:PrintMessage(2, "You need to be superadin in order to be able to give a license.")
		return
	end

	local target = FindPlayer(args[1])

	if target then
		target:SetNWBool("HasGunlicense", true)

		if ply:EntIndex() ~= 0 then
			nick = ply:Nick()
		else
			nick = "Console"
		end

		Notify(target, 1, 4, nick .. " gave you a gun license")
		Notify(ply, 2, 4, "Gave "..target:Nick().." a gun license!")
		DB.Log(ply:SteamName().." ("..ply:SteamID()..") force-gave "..target:Nick().." a gun license")
		if ply:EntIndex() == 0 then
			DB.Log("Console force-gave "..target:Nick().." a gun license" )
		else
			DB.Log(ply:SteamName().." ("..ply:SteamID()..") force-gave "..target:Nick().." a gun license" )
		end
	else
		if ply:EntIndex() == 0 then
			print("Could not find player: " .. args[1])
		else
			ply:PrintMessage(2, "Could not find player: " .. args[1])
		end
		return
	end
end
concommand.Add("rp_givelicense", rp_GiveLicense)

function rp_RevokeLicense(ply, cmd, args)
	if ply:EntIndex() ~= 0 and not ply:IsSuperAdmin() then
		ply:PrintMessage(2, "You need to be superadmin in order to be able to revoke a license.")
		return
	end

	local target = FindPlayer(args[1])

	if target then
		target:SetNWBool("HasGunlicense", false)

		if ply:EntIndex() ~= 0 then
			nick = ply:Nick()
		else
			nick = "Console"
		end

		Notify(target, 1, 4, nick .. " revoked your gun license")
		Notify(ply, 2, 4, "Revoked "..target:Nick().."'s gun license!")
		DB.Log(ply:SteamName().." ("..ply:SteamID()..") force-removed "..target:Nick().."'s gun license")
		if ply:EntIndex() == 0 then
			DB.Log("Console force-removed "..target:Nick().."'s gun license" )
		else
			DB.Log(ply:SteamName().." ("..ply:SteamID()..") force-removed "..target:Nick().."'s gun license" )
		end
	else
		if ply:EntIndex() == 0 then
			print("Could not find player: " .. args[1])
		else
			ply:PrintMessage(2, "Could not find player: " .. args[1])
		end
		return
	end
end
concommand.Add("rp_revokelicense", rp_RevokeLicense)

function FinishRevokeLicense(choice, v)
	VoteCopOn = false
	if choice == 1 then
		v:SetNWBool("HasGunlicense", false)
		v:StripWeapons()
		GAMEMODE:PlayerLoadout(v)
		NotifyAll(1, 4, v:Nick() .. "'s license has been removed!")
	else
		NotifyAll(1, 4, v:Nick() .. "'s license has NOT been removed!")
	end
end

function VoteRemoveLicense(ply, args)
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
			Notify(ply, 1, 4, "Please wait another " .. math.ceil(80 - (CurTime() - ply:GetTable().LastVoteCop)) .. " seconds before demoting license.")
			return ""
		end
		if ply:GetNWBool("HasGunlicense") then
			Notify(ply, 1, 4,  p:Nick() .." doesn't have a license!")
		else
			NotifyAll(1, 4, ply:Nick() .. " has started a vote for the gun license removal of " .. p:Nick())
			vote:Create(p:Nick() .. ":\nGun license remove:\n"..reason, p:EntIndex() .. "votecop"..ply:EntIndex(), p, 20, FinishRevokeLicense, true)
			ply:GetTable().LastVoteCop = CurTime()
			VoteCopOn = true
			Notify(ply, 1, 4, "Gun license removal vote started!")
		end
		return ""
	else
		Notify(ply, 1, 4, "This player does not exist!")
		return ""
	end
end
AddChatCommand("/demotelicense", VoteRemoveLicense)
