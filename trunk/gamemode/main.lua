/*---------------------------------------------------------
 Variables
 ---------------------------------------------------------*/
local timeLeft = 10
local timeLeft2 = 10
local stormOn = false
local zombieOn = false
local maxZombie = 10
RPArrestedPlayersPositions = {}

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
			v:PrintMessage(HUD_PRINTCENTER, LANGUAGE.zombie_approaching)
			v:PrintMessage(HUD_PRINTTALK, LANGUAGE.zombie_approaching)
		end
	end
end

function ZombieEnd()
	for k, v in pairs(player.GetAll()) do
		if v:Alive() then
			v:PrintMessage(HUD_PRINTCENTER, LANGUAGE.zombie_leaving)
			v:PrintMessage(HUD_PRINTTALK, LANGUAGE.zombie_leaving)
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
	ply:SetDarkRPVar("numPoints", table.getn(zombieSpawns))

	for k, v in pairs(zombieSpawns) do
		local Sep = (string.Explode(" " ,v))
		ply:SetDarkRPVar("zPoints" .. k, Vector(tonumber(Sep[1]),tonumber(Sep[2]),tonumber(Sep[3])))
	end
end

function ReMoveZombie(ply, index)
	if ply:HasPriv(ADMIN) then
		if not index or zombieSpawns[tonumber(index)] == nil then
			Notify(ply, 1, 4, string.format(LANGUAGE.zombie_spawn_not_exist, tostring(index)))
		else
			DB.RetrieveZombies()
			Notify(ply, 1, 4, LANGUAGE.zombie_spawn_removed)
			table.remove(zombieSpawns,index)
			DB.StoreZombies()
			if ply.DarkRPVars.zombieToggle then
				LoadTable(ply)
			end
		end
	else
		Notify(ply, 1, 4, string.format(LANGUAGE.need_admin, "/removezombie"))
	end
	return ""
end
AddChatCommand("/removezombie", ReMoveZombie)

function AddZombie(ply)
	if ply:HasPriv(ADMIN) then
		DB.RetrieveZombies()
		table.insert(zombieSpawns, tostring(ply:GetPos()))
		DB.StoreZombies()
		if ply.DarkRPVars.zombieToggle then LoadTable(ply) end
		Notify(ply, 1, 4, LANGUAGE.zombie_spawn_added)
	else
		Notify(ply, 1, 6, string.format(LANGUAGE.need_admin, "/addzombie"))
	end
	return ""
end
AddChatCommand("/addzombie", AddZombie)

function ToggleZombie(ply)
	if ply:HasPriv(ADMIN) then
		if not ply.DarkRPVars.zombieToggle then
			DB.RetrieveZombies()
			ply:SetDarkRPVar("zombieToggle", true)
			LoadTable(ply)
		else
			ply:SetDarkRPVar("zombieToggle", false)
		end
	else
		Notify(ply, 1, 6, LANGUAGE.string.format(LANGUAGE.need_admin, "/showzombie"))
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
			Notify(ply, 1, 4, string.format(LANGUAGE.invalid_x, "argument", ""))
			return ""
		end
		maxZombie = tonumber(args)
		Notify(ply, 1, 4, string.format(LANGUAGE.zombie_maxset, args))
	end

	return ""
end
AddChatCommand("/zombiemax", ZombieMax)

function StartZombie(ply)
	if ply:HasPriv(ADMIN) then
		timer.Start("zombieControl")
		Notify(ply, 1, 4, LANGUAGE.zombie_enabled)
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
		Notify(ply, 1, 4, LANGUAGE.zombie_disabled)
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
			v:PrintMessage(HUD_PRINTCENTER, LANGUAGE.meteor_approaching)
			v:PrintMessage(HUD_PRINTTALK, LANGUAGE.meteor_approaching)
		end
	end
end

function StormEnd()
	for k, v in pairs(player.GetAll()) do
		if v:Alive() then
			v:PrintMessage(HUD_PRINTCENTER, LANGUAGE.meteor_passing)
			v:PrintMessage(HUD_PRINTTALK, LANGUAGE.meteor_passing)
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
		if math.random(0, 2) == 0 and v:Alive() then
			AttackEnt(v)
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
		Notify(ply, 1, 4, LANGUAGE.meteor_enabled)
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
		Notify(ply, 1, 4, LANGUAGE.meteor_disabled)
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
local lastmagnitudes = {} -- The magnitudes of the last tremors

local next_update_time
local tremor = ents.Create("env_physexplosion")
tremor:SetPos(Vector(0,0,0))
tremor:SetKeyValue("radius",9999999999)
tremor:SetKeyValue("spawnflags", 7)
tremor.nodupe = true
tremor:Spawn()

function TremorReport(mag)
	local mag = table.remove(lastmagnitudes, 1)
	if mag then
		if mag < 6.5 then
			NotifyAll(1, 3, string.format(LANGUAGE.earthtremor_report, tostring(mag)))
			return
		end
		NotifyAll(1, 3, string.format(LANGUAGE.earthquake_report, tostring(mag)))
	end
end

function EarthQuakeTest()
	if CfgVars["earthquakes"] ~= 1 or not CfgVars["quakechance"] then return end

	if CurTime() > (next_update_time or 0) then
		local en = ents.FindByClass("prop_physics")
		local plys = ents.FindByClass("player")
		if math.random(0, CfgVars["quakechance"]) < 1 then
			local force = math.random(10,1000)
			tremor:SetKeyValue("magnitude",force/6)
			for k,v in pairs(plys) do
				v:EmitSound("earthquake.mp3", force/6, 100)
			end
			tremor:Fire("explode","",0.5)
			util.ScreenShake(Vector(0,0,0), force, math.random(25,50), math.random(5,12), 9999999999)
			table.insert(lastmagnitudes, math.floor((force / 10) + .5) / 10)
			timer.Simple(10, TremorReport, alert)
			for k,e in pairs(en) do
				local rand = math.random(650,1000)
				if rand < force and rand % 2 == 0 then
					e:Fire("enablemotion","",0)
					constraint.RemoveAll(e)
				end
				if e:IsOnGround() then
					e:TakeDamage((force / 100) + 15, GetWorldEntity())
				end
			end
		end
		next_update_time = CurTime() + 1
	end
end

/*---------------------------------------------------------
 Flammable
 ---------------------------------------------------------*/
local FlammableProps = {"drug", "drug_lab", "food", "gunlab", "letter", "microwave", "money_printer", "spawned_shipment", "spawned_weapon", "cash_bundle", "prop_physics"}

local function IsFlammable(ent)
	local class = ent:GetClass()
	for k, v in pairs(FlammableProps) do
		if class == v then return true end
	end
	return false
end

-- FireSpread from SeriousRP
local function FireSpread(e)
	if e:IsOnFire() then
		if e:IsMoneyBag() then
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
function DropWeapon(ply)
	local ent = ply:GetActiveWeapon()
	if not ValidEntity(ent) then return "" end
	
	if CfgVars["RestrictDrop"] == 1 then
		local found = false
		for k,v in pairs(CustomShipments) do
			if v.entity == ent:GetClass() then
				found = true
				break
			end
		end
		if not found then
			Notify(ply, 1, 4, LANGUAGE.cannot_drop_weapon)
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
	Notify(ply, 1, 4, string.format(LANGUAGE.warrant_expired, target:Nick()))
end 

function SetWarrant(ply, target)
	target.warranted = true
	timer.Simple(CfgVars["searchtime"], UnWarrant, ply, target)
	for a, b in pairs(player.GetAll()) do
		b:PrintMessage(HUD_PRINTCENTER, string.format(LANGUAGE.warrant_approved, target:Nick()))
	end
	Notify(ply, 1, 4, LANGUAGE.warrant_approved2)
end

function FinishWarrant(choice, mayor, initiator, target)
	if choice == 1 then
		SetWarrant(initiator, target)
	else
		Notify(initiator, 1, 4, string.format(LANGUAGE.warrant_denied, mayor:Nick()))
	end
	return ""
end

function SearchWarrant(ply, args)
	local t = ply:Team()
	if not (t == TEAM_POLICE or t == TEAM_MAYOR or t == TEAM_CHIEF) then
		Notify(ply, 1, 4, string.format(LANGUAGE.must_be_x, "cop/mayor", "/warrant"))
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
					ques:Create(string.format(LANGUAGE.warrant_request, ply:Nick(), p:Nick()), p:EntIndex() .. "warrant", m, 40, FinishWarrant, ply, p)
					Notify(ply, 1, 4, string.format(LANGUAGE.warrant_request2, m:Nick()))
				else
					-- there is no mayor, CPs can set warrants.
					SetWarrant(ply, p)
				end
			end
		else
			Notify(ply, 1, 4, string.format(LANGUAGE.could_not_find, "player: "..tostring(args)))
		end
	end
	return ""
end
AddChatCommand("/warrant", SearchWarrant)
AddChatCommand("/warrent", SearchWarrant) -- Most players can't spell for some reason

function PlayerWanted(ply, args)
	local t = ply:Team()
	if not (t == TEAM_POLICE or t == TEAM_MAYOR or t == TEAM_CHIEF) then
		Notify(ply, 1, 6, string.format(LANGUAGE.must_be_x, "cop/mayor", "/wanted"))
	else
		local p = FindPlayer(args)
		if p and p:Alive() then
			p:SetDarkRPVar("wanted", true)
			for a, b in pairs(player.GetAll()) do
				b:PrintMessage(HUD_PRINTCENTER, string.format(LANGUAGE.wanted_by_police, p:Nick()))
				timer.Create(p:Nick() .. " wantedtimer", CfgVars["wantedtime"], 1, TimerUnwanted, ply, args)
			end
		else
			Notify(ply, 1, 4, string.format(LANGUAGE.could_not_find, "player: "..tostring(args)))
		end
	end
	return ""
end
AddChatCommand("/wanted", PlayerWanted)

function PlayerUnWanted(ply, args)
	local t = ply:Team()
	if not (t == TEAM_POLICE or t == TEAM_MAYOR or t == TEAM_CHIEF) then
		Notify(ply, 1, 6, string.format(LANGUAGE.must_be_x, "cop/mayor", "/unwanted"))
	else
		local p = FindPlayer(args)
		if p and p:Alive() and p.DarkRPVars.wanted then
			p:SetDarkRPVar("wanted", false)
			for a, b in pairs(player.GetAll()) do
				b:PrintMessage(HUD_PRINTCENTER, string.format(LANGUAGE.wanted_expired, p:Nick()))
				timer.Destroy(p:Nick() .. " wantedtimer")
			end
		else
			Notify(ply, 1, 4, string.format(LANGUAGE.could_not_find, "Player: "..tostring(args)))
		end
	end
	return ""
end
AddChatCommand("/unwanted", PlayerUnWanted)

function TimerUnwanted(ply, args)
	local p = FindPlayer(args)
	if p and p:Alive() and p.DarkRPVars.wanted then
		p:SetDarkRPVar("wanted", false)
		for a, b in pairs(player.GetAll()) do
			b:PrintMessage(HUD_PRINTCENTER, string.format(LANGUAGE.wanted_expired, p:Nick()))
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
			Notify(ply, 1, 4, string.format(LANGUAGE.created_spawnpos, v.name))
		end
	end

	if t then
		DB.StoreTeamSpawnPos(t, pos)
	else
		Notify(ply, 1, 4, string.format(LANGUAGE.could_not_find, "team: "..tostring(args)))
	end

	return ""
end
AddChatCommand("/setspawn", SetSpawnPos)

function AddSpawnPos(ply, args)
	if not ply:HasPriv(ADMIN) and not ply:IsAdmin() and not ply:IsSuperAdmin() then return "" end

	local pos = string.Explode(" ", tostring(ply:GetPos()))
	local selection = "citizen"
	local t
	
	for k,v in pairs(RPExtraTeams) do
		if args == v.command then
			t = k
			Notify(ply, 1, 4, string.format(LANGUAGE.updated_spawnpos, v.name))
		end
	end

	if t then
		DB.AddTeamSpawnPos(t, pos)
	else
		Notify(ply, 1, 4, string.format(LANGUAGE.could_not_find, "team: "..tostring(args)))
	end

	return ""
end
AddChatCommand("/addspawn", AddSpawnPos)

function RemoveSpawnPos(ply, args)
	if not ply:HasPriv(ADMIN) and not ply:IsAdmin() and not ply:IsSuperAdmin() then return "" end

	local pos = string.Explode(" ", tostring(ply:GetPos()))
	local selection = "citizen"
	local t
	
	for k,v in pairs(RPExtraTeams) do
		if args == v.command then
			t = k
			Notify(ply, 1, 4, string.format(LANGUAGE.updated_spawnpos, v.name))
		end
	end

	if t then
		DB.RemoveTeamSpawnPos(t, pos)
	else
		Notify(ply, 1, 4, string.format(LANGUAGE.could_not_find, "team: "..tostring(args)))
	end

	return ""
end
AddChatCommand("/removespawn", RemoveSpawnPos)



/*---------------------------------------------------------
 Helps
 ---------------------------------------------------------*/
function HelpCop(ply)
	ply:SetDarkRPVar("helpCop", not ply.DarkRPVars.helpCop)
	return ""
end
AddChatCommand("/cophelp", HelpCop)

function HelpMayor(ply)
	ply:SetDarkRPVar("helpMayor", not ply.DarkRPVars.helpMayor)
	return ""
end
AddChatCommand("/mayorhelp", HelpMayor)

function HelpBoss(ply)
	ply:SetDarkRPVar("helpBoss", not ply.DarkRPVars.helpBoss)
	return ""
end
AddChatCommand("/mobbosshelp", HelpBoss)

function HelpAdmin(ply)
	ply:SetDarkRPVar("helpAdmin", not ply.DarkRPVars.helpAdmin)
	return ""
end
AddChatCommand("/adminhelp", HelpAdmin)

function closeHelp(ply)
	ply:SetDarkRPVar("helpCop", false)
	ply:SetDarkRPVar("helpBoss", false)
	ply:SetDarkRPVar("helpMayor", false)
	ply:SetDarkRPVar("helpAdmin", false)
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
		ply:PrintMessage(2, string.format(LANGUAGE.invalid_x, "argument", ""))
		return 
	end
	local P = FindPlayer(args[1])
	if not ValidEntity(P) then
		ply:PrintMessage(2, string.format(LANGUAGE.could_not_find, "player: "..tostring(args[1])))
	end
	ply:PrintMessage(2, "Nick: ".. P:Nick())
	ply:PrintMessage(2, "Steam name: "..P:SteamName())
	ply:PrintMessage(2, "Steam ID: "..P:SteamID())
end
concommand.Add("rp_lookup", LookPersonUp)

local function GiveHint()
	if CfgVars["advertisements"] ~= 1 then return end
	local text = LANGUAGE.hints[math.random(1, #LANGUAGE.hints)]

	for k,v in pairs(player.GetAll()) do
		TalkToPerson(v, Color(150,150,150,150), text)
	end
end

timer.Create("hints", 60, 0, GiveHint)

/*---------------------------------------------------------
 Items
 ---------------------------------------------------------*/
local function MakeLetter(ply, args, type)
	if CfgVars["letters"] == 0 then
		Notify(ply, 1, 4, string.format(LANGUAGE.disabled, "/write / /type", ""))
		return ""
	end

	if ply.maxletters and ply.maxletters >= CfgVars["maxletters"] then
		Notify(ply, 1, 4, string.format(LANGUAGE.limit, "letter"))
		return ""
	end

	if CurTime() - ply:GetTable().LastLetterMade < 3 then
		Notify(ply, 1, 4, string.format(LANGUAGE.have_to_wait, math.ceil(3 - (CurTime() - ply:GetTable().LastLetterMade)), "/write / /type"))
		return ""
	end

	ply:GetTable().LastLetterMade = CurTime()

	-- Instruct the player's letter window to open

	local ftext = string.gsub(args, "//", "\n")
	ftext = string.gsub(ftext, "\\n", "\n") .. "\n\nYours,\n"..ply:Nick()
	local length = string.len(ftext)

	local numParts = math.floor(length / 39) + 1

	local tr = {}
	tr.start = ply:EyePos()
	tr.endpos = ply:EyePos() + 95 * ply:GetAimVector()
	tr.filter = ply
	local trace = util.TraceLine(tr)

	local letter = ents.Create("letter")
	letter:SetModel("models/props_c17/paper01.mdl")
	letter.dt.owning_ent = ply
	letter.ShareGravgun = true
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

	PrintMessageAll(2, string.format(LANGUAGE.created_x, ply:Nick(), "mail"))
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
	Notify(ply, 1, 4, string.format(LANGUAGE.cleaned_up, "mails"))
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

	local class = tr.Entity:GetClass()
	if ValidEntity(tr.Entity) and (class == "gunlab" or class == "microwave" or class == "drug_lab") and tr.Entity.SID == ply.SID then
		tr.Entity.dt.price = b
	else
		Notify(ply, 1, 4, string.format(LANGUAGE.must_be_looking_at, "gunlab / druglab / microwave"))
	end
	return ""
end
AddChatCommand("/price", SetPrice)
AddChatCommand("/setprice", SetPrice)

function BuyPistol(ply, args)
	if args == "" then return "" end
	if RPArrestedPlayers[ply:SteamID()] then return "" end

	if CfgVars["enablebuypistol"] == 0 then
		Notify(ply, 1, 4, string.format(LANGUAGE.disabled, "/buy", ""))
		return ""
	end
	if CfgVars["noguns"] == 1 then
		Notify(ply, 1, 4, string.format(LANGUAGE.disabled, "/buy", ""))
		return ""
	end

	local trace = {}
	trace.start = ply:EyePos()
	trace.endpos = trace.start + ply:GetAimVector() * 85
	trace.filter = ply

	local tr = util.TraceLine(trace)
	
	local class = nil
	local model = nil
	
	local custom = false
	local price = 0
	for k,v in pairs(CustomShipments) do
		if v.seperate and string.lower(v.name) == string.lower(args) then
			custom = v
			class = v.entity
			model = v.model
			price = v.pricesep
			local canbuy = false			
			local RestrictBuyPistol = tonumber(GetGlobalInt("restrictbuypistol"))
			if (RestrictBuyPistol == 1 and ply:Team() == TEAM_GUN) or RestrictBuyPistol == 0 or (RestrictBuyPistol == 1 and (not v.allowed[1] or table.HasValue(v.allowed, ply:Team()))) then
				canbuy = true
			end
			
			if not canbuy then
				Notify(ply, 1, 4, string.format(LANGUAGE.incorrect_job, "/buy"))
				return ""
			end
		end
	end
	
	if not class then
		Notify(ply, 1, 4, string.format(LANGUAGE.unavailable, "weapon"))
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
		Notify(ply, 1, 4, string.format(LANGUAGE.cant_afford, "/buy"))
		return ""
	end
	
	ply:AddMoney(-price)
	
	Notify(ply, 1, 4, string.format(LANGUAGE.you_bought_x, args, tostring(price)))
	
	local weapon = ents.Create("spawned_weapon")
	weapon:SetModel(model)
	weapon.weaponclass = class
	weapon.ShareGravgun = true
	weapon:SetPos(tr.HitPos)
	weapon.nodupe = true
	weapon:Spawn()

	return ""
end
AddChatCommand("/buy", BuyPistol)

function BuyShipment(ply, args)
	if args == "" then return "" end

	local trace = {}
	trace.start = ply:EyePos()
	trace.endpos = trace.start + ply:GetAimVector() * 85
	trace.filter = ply

	local tr = util.TraceLine(trace)

	if RPArrestedPlayers[ply:SteamID()] then return "" end
	
	local found = false
	local foundKey
	for k,v in pairs(CustomShipments) do
		if string.lower(args) == string.lower(v.name) and not v.noship then
			found = v
			foundKey = k
			local canbecome = false
			for a,b in pairs(v.allowed) do
				if ply:Team() == b then
					canbecome = true
				end
			end
			if not canbecome then
				Notify(ply, 1, 4, string.format(LANGUAGE.incorrect_job, "/buyshipment"))
				return "" 
			end
		end
	end
	
	if not found then
		Notify(ply, 1, 4, string.format(LANGUAGE.unable, "/buyshipment", args))
		return ""
	end
	
	local cost = found.price
	
	if not ply:CanAfford(cost) then
		Notify(ply, 1, 4, string.format(LANGUAGE.cant_afford, "shipment"))
		return ""
	end
	
	ply:AddMoney(-cost)
	Notify(ply, 1, 4, string.format(LANGUAGE.you_bought_x, args, CUR .. tostring(cost)))
	local crate = ents.Create("spawned_shipment")
	crate.SID = ply.SID
	crate:SetContents(foundKey, found.amount, found.weight)
	
	crate:SetPos(Vector(tr.HitPos.x, tr.HitPos.y, tr.HitPos.z))
	crate.nodupe = true
	crate:Spawn()
	if found.shipmodel then
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
	if found.allowed and not table.HasValue(found.allowed, ply:Team()) then Notify(ply, 1, 4, string.format(LANGUAGE.incorrect_job, "/buyvehicle")) return ""  end 
	
	if not ply.Vehicles then ply.Vehicles = 0 end
	if CfgVars["maxvehicles"] ~= 0 and ply.Vehicles >= CfgVars["maxvehicles"] then
		Notify(ply, 1, 4, string.format(LANGUAGE.limit, "vehicle"))
		return ""
	end
	ply.Vehicles = ply.Vehicles + 1
	
	if not ply:CanAfford(found.price) then Notify(ply, 1, 4, string.format(LANGUAGE.cant_afford, "vehicle")) return "" end
	ply:AddMoney(-found.price)
	Notify(ply, 1, 4, string.format(LANGUAGE.you_bought_x, found.name, CUR .. found.price))
	
	local Vehicle = list.Get("Vehicles")[found.name]
	if not Vehicle then Notify(ply, 1, 4, string.format(LANGUAGE.invalid_x, "argument", "")) return "" end
	
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
	ent.Owner = ply
	ent:Spawn()
	ent:Activate()
	ent.SID = ply.SID
	ent.ClassOverride = Vehicle.Class
	ent:Own(ply)
	
	return ""
end
AddChatCommand("/buyvehicle", BuyVehicle)

for k,v in pairs(DarkRPEntities) do
	local function buythis(ply, args)
		if RPArrestedPlayers[ply:SteamID()] then return "" end
		if type(v.allowed) == "table" and not table.HasValue(v.allowed, ply:Team()) then
			Notify(ply, 1, 4, string.format(LANGUAGE.incorrect_job, v.cmd))
			return "" 
		end
		local cmdname = string.gsub(v.ent, " ", "_")
		local disabled = tobool(GetGlobalInt("disable"..cmdname))
		if disabled then
			Notify(ply, 1, 4, string.format(LANGUAGE.disabled, v.cmd, ""))
			return "" 
		end
		
		local max = GetGlobalInt("max"..cmdname)

		if not max or max == 0 then max = tonumber(v.max) end
		if ply["max"..cmdname] and tonumber(ply["max"..cmdname]) >= tonumber(max) then
			Notify(ply, 1, 4, string.format(LANGUAGE.limit, v.cmd))
			return ""
		end
		
		local price = GetGlobalInt(cmdname.."_price")
		if price == 0 then 
			price = v.price
		end
		
		if not ply:CanAfford(price) then
			Notify(ply, 1, 4,  string.format(LANGUAGE.cant_afford, v.cmd))
			return ""
		end
		ply:AddMoney(-price)
		
		local trace = {}
		trace.start = ply:EyePos()
		trace.endpos = trace.start + ply:GetAimVector() * 85
		trace.filter = ply
		
		local tr = util.TraceLine(trace)
		
		local item = ents.Create(v.ent)
		item.dt = item.dt or {}
		item.dt.owning_ent = ply
		item:SetPos(tr.HitPos)
		item.SID = ply.SID
		item.onlyremover = true
		item:Spawn()
		Notify(ply, 1, 4, string.format(LANGUAGE.you_bought_x, v.name, CUR..price))
		if not ply["max"..cmdname] then
			ply["max"..cmdname] = 0
		end
		ply["max"..cmdname] = ply["max"..cmdname] + 1
		return ""
	end
	AddChatCommand(v.cmd, buythis)
end

function BuyAmmo(ply, args)
	if args == "" then return "" end

	if RPArrestedPlayers[ply:SteamID()] then return "" end

	if CfgVars["noguns"] == 1 then
		Notify(ply, 1, 4, string.format(LANGUAGE.disabled, "ammo", ""))
		return ""
	end
	
	if args ~= "rifle" and args ~= "shotgun" and args ~= "pistol" then
		Notify(ply, 1, 4, string.format(LANGUAGE.unavailable, "ammo"))
	end
	
	if not ply:CanAfford(GetGlobalInt("ammo" .. args .. "cost")) then
		Notify(ply, 1, 4, string.format(LANGUAGE.cant_afford, "ammo"))
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

	Notify(ply, 1, 4, string.format(LANGUAGE.you_bought_x, args, CUR..tostring(cost)))
	ply:AddMoney(-cost)

	return ""
end
AddChatCommand("/buyammo", BuyAmmo)

function BuyHealth(ply)
	local cost = GetGlobalInt("healthcost")
	if not ply:Alive() then
		Notify(ply, 1, 4, string.format(LANGUAGE.unable, "/buyhealth", ""))
		return ""
	end
	if not ply:CanAfford(cost) then
		Notify(ply, 1, 4, string.format(LANGUAGE.cant_afford, "/buyhealth"))
		return ""
	end
	if ply:Team() ~= TEAM_MEDIC and team.NumPlayers(TEAM_MEDIC) > 0 then
		Notify(ply, 1, 4, string.format(LANGUAGE.unable, "/buyhealth", ""))
		return ""
	end
	if ply.StartHealth and ply:Health() >= ply.StartHealth then
		Notify(ply, 1, 4, string.format(LANGUAGE.unable, "/buyhealth", ""))
		return "" 
	end
	ply.StartHealth = ply.StartHealth or 100
	ply:AddMoney(-cost)
	Notify(ply, 1, 4,  string.format(LANGUAGE.you_bought_x, "health",  CUR .. tostring(cost)))
	ply:SetHealth(ply.StartHealth)
	return ""
end
AddChatCommand("/buyhealth", BuyHealth)

local function MakeACall(ply,args)
	local p = FindPlayer(args)
	if not ValidEntity(p) then return "" end
	if ValidEntity(ply.DarkRPVars.phone) or ValidEntity(p.DarkRPVars.phone) then
		Notify(ply, 1, 4, string.format(LANGUAGE.unable, "/call", "busy"))
		return "" 
	end
	if not p:Alive() or p == ply or not ply:Alive() then return "" end
	local trace = {}
	trace.start = p:EyePos()
	trace.endpos = trace.start + p:GetAimVector() * 85
	trace.filter = p
	local tr = util.TraceLine(trace)
	
	local banana = ents.Create("phone")
	
	banana.dt.owning_ent = p
	banana.ShareGravgun = true
	banana.Caller = ply
	
	banana:SetPos(tr.HitPos)
	banana.onlyremover = true
	banana.SID = p.SID
	banana:Spawn()
	
	
	local ownphone = ents.Create("phone")
	
	ownphone.dt.owning_ent = ply
	ownphone.ShareGravgun = true
	ownphone.dt.IsBeingHeld = true
	ply:SetDarkRPVar("phone", ownphone)
	
	ownphone:SetPos(ply:GetShootPos())
	ownphone.onlyremover = true
	ownphone.SID = ply.SID
	ownphone:Spawn()
	ownphone:Use(ply,ply)--Put it on the ear already, since you're the one who's calling...
	timer.Simple(20, function(ply, OtherPhone)
		local MyPhone = ply.DarkRPVars.phone
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
	if code == IN_USE and ValidEntity(ply.DarkRPVars.phone) then
		ply.DarkRPVars.phone:HangUp()
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
				Notify(v, 1, 4, LANGUAGE.agenda_updated)
				v:SetDarkRPVar("agenda", CfgVars["mobagenda"])
			end
		end
	else
		Notify(ply, 1, 6, string.format(LANGUAGE.must_be_x, team.GetName(TEAM_MOB), "/agenda"))
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
	
	if RPArrestedPlayers[ply:SteamID()] then
		Notify(ply, 1, 5, string.format(LANGUAGE.unable, "/job", ">2"))
		return ""
	end
	
	if ply.LastJob and 10 - (CurTime() - ply.LastJob) >= 0 then
		Notify(ply, 1, 4, string.format(LANGUAGE.have_to_wait,  math.ceil(10 - (CurTime() - ply.LastJob)), "/job"))
		return ""
	end
	ply.LastJob = CurTime()
	
	if not ply:Alive() then
		Notify(ply, 1, 4, string.format(LANGUAGE.unable, "/job", ""))
		return ""
	end

	if CfgVars["customjobs"] ~= 1 then
		Notify(ply, 1, 4, string.format(LANGUAGE.disabled, "/job", ""))
		return ""
	end

	local len = string.len(args)

	if len < 3 then
		Notify(ply, 1, 4, string.format(LANGUAGE.unable, "/job", ">2"))
		return ""
	end

	if len > 25 then
		Notify(ply, 1, 4, string.format(LANGUAGE.unable, "/job", "<26"))
		return ""
	end

	local jl = string.lower(args)
	local t = ply:Team()

	for k,v in pairs(RPExtraTeams) do
		if jl == v.name then
			ply:ChangeTeam(k)
		end
	end
	NotifyAll(2, 4, string.format(LANGUAGE.job_has_become, ply:Nick(), args))
	ply:UpdateJob(args)
	return ""
end
AddChatCommand("/job", ChangeJob)

local function FinishDemote(choice, v)
	if choice == 1 then
		v:TeamBan()
		if v:Alive() then
			v:ChangeTeam(TEAM_CITIZEN)
		else
			v.demotedWhileDead = true
		end

		NotifyAll(1, 4, string.format(LANGUAGE.demoted, v:Nick()))
	else
		NotifyAll(1, 4, string.format(LANGUAGE.demoted_not, v:Nick()))
	end
end

local function Demote(ply, args)
	local tableargs = string.Explode(" ", args)
	if #tableargs == 1 then
		Notify(ply, 1, 4, LANGUAGE.vote_specify_reason)
		return ""
	end
	local reason = ""
	for i = 2, #tableargs, 1 do
		reason = reason .. " " .. tableargs[i]
	end 
	reason = string.sub(reason, 2)
	if string.len(reason) > 22 then
		Notify(ply, 1, 4, string.format(LANGUAGE.unable, "/demote", "<23"))
		return "" 
	end
	local p = FindPlayer(tableargs[1])
	if p then
		if CurTime() - ply:GetTable().LastVoteCop < 80 then
			Notify(ply, 1, 4, string.format(LANGUAGE.have_to_wait, math.ceil(80 - (CurTime() - ply:GetTable().LastVoteCop)), "/demote"))
			return ""
		end
		if p:Team() == TEAM_CITIZEN then
			Notify(ply, 1, 4,  string.format(LANGUAGE.unable, "/demote", ""))
		else
			NotifyAll(1, 4, string.format(LANGUAGE.demote_vote_started, ply:Nick(), p:Nick()))
			vote:Create(p:Nick() .. ":\n"..string.format(LANGUAGE.demote_vote_text, reason), p:EntIndex() .. "votecop"..ply:EntIndex(), p, 20, FinishDemote, true)
			ply:GetTable().LastVoteCop = CurTime()
		end
		return ""
	else
		Notify(ply, 1, 4, string.format(LANGUAGE.could_not_find, "player: "..tostring(args)))
		return ""
	end
end
AddChatCommand("/demote", Demote)

local function ExecSwitchJob(answer, ent, ply, target)
	if answer ~= 1 then return end
	local Pteam = ply:Team()
	local Tteam = target:Team()
	ply:ChangeTeam(Tteam)
	target:ChangeTeam(Pteam)
	Notify(ply, 1, 4, LANGUAGE.team_switch)
	Notify(target, 1, 4, LANGUAGE.team_switch)
end

function SwitchJob(ply) --Idea by Godness.
	if CfgVars["allowjobswitch"] ~= 1 then return "" end
	local eyetrace = ply:GetEyeTrace()
	if not eyetrace or not eyetrace.Entity or not eyetrace.Entity:IsPlayer() then return "" end
	ques:Create("Switch job with "..ply:Nick().."?", "switchjob"..tostring(ply:EntIndex()), eyetrace.Entity, 30, ExecSwitchJob, ply, eyetrace.Entity)
	return ""
end
AddChatCommand("/switchjob", SwitchJob)
AddChatCommand("/switchjobs", SwitchJob)
AddChatCommand("/jobswitch", SwitchJob)
	

function DoTeamBan(ply, args, cmdargs)
	if not args or args == "" then return "" end
	if not ply:IsAdmin() then 
		Notify(ply, 1, 4, string.format(LANGUAGE.need_admin, "/teamban"))
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
		Notify(ply, 1, 4, string.format(LANGUAGE.could_not_find, "player!"))
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
		Notify(ply, 1, 4, string.format(LANGUAGE.could_not_find, "job!"))
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
		Notify(ply, 1, 4, string.format(LANGUAGE.need_admin, "/teamunban"))
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
		Notify(ply, 1, 4, string.format(LANGUAGE.could_not_find, "player!"))
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
		Notify(ply, 1, 4, string.format(LANGUAGE.could_not_find, "job!"))
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
		Notify(ply, 1, 4, string.format(LANGUAGE.could_not_find, "player: "..tostring(name)))
	end

	return ""
end
AddChatCommand("/pm", PM)

function Whisper(ply, args)
	TalkToRange(ply, "(".. LANGUAGE.whisper .. ") " .. ply:Nick(), args, 90)
	return ""
end
AddChatCommand("/w", Whisper)

function Yell(ply, args)
	TalkToRange(ply, "(".. LANGUAGE.yell .. ") " .. ply:Nick(), args, 550) 
	return ""
end
AddChatCommand("/y", Yell)

local function Me(ply, args)
	if args == "" then return "" end
	if GetGlobalInt("alltalk") == 1 then
		for _, target in pairs(player.GetAll()) do
			TalkToPerson(target, team.GetColor(ply:Team()), ply:Nick() .. " " .. args)
		end
	else
		TalkToRange(ply, ply:Nick() .. " " .. args, "", 250)
	end
	return ""
end
AddChatCommand("/me", Me)

function OOC(ply, args)
	if CfgVars["ooc"] == 0 then
		Notify(ply, 1, 4, string.format(LANGUAGE.disabled, "OOC", ""))
		return ""
	end

	if args == "" then return "" end
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
	if args == "" then return "" end
	for k,v in pairs(player.GetAll()) do
		local col = team.GetColor(ply:Team())
		TalkToPerson(v, col, LANGUAGE.advert ..ply:Nick(), Color(255,255,0,255), args, ply)
	end
	return ""
end
AddChatCommand("/advert", PlayerAdvertise)

function SetRadioChannel(ply,args)
	if tonumber(args) == nil or tonumber(args) < 0 or tonumber(args) > 99 then
		Notify(ply, 1, 4, string.format(LANGUAGE.unable, "/channel", "0<channel<100"))
		return ""
	end
	Notify(ply, 1, 4, "Channel set to "..args.."!")
	ply.RadioChannel = tonumber(args)
	return ""
end
AddChatCommand("/channel", SetRadioChannel)

function SayThroughRadio(ply,args)
	if not ply.RadioChannel then ply.RadioChannel = 1 end
	if not args or args == "" then
		Notify(ply, 1, 4, string.format(LANGUAGE.unable, "/radio", ""))
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
	if args == "" then return "" end
	local t = ply:Team()
	for k, v in pairs(player.GetAll()) do
		if v:Team() == TEAM_POLICE or v:Team() == TEAM_CHIEF or v == ply then
			TalkToPerson(v, team.GetColor(ply:Team()), LANGUAGE.request ..ply:Nick(), Color(255,0,0,255), args, ply)
		end
	end
	return ""
end
AddChatCommand("/cr", CombineRequest)

function GroupMsg(ply, args)
	if args == "" then return "" end
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
		TalkToPerson(v, col, LANGUAGE.group..ply:Nick(),Color(255,255,255,255), args, ply)
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
local function GiveMoney(ply, args)
	if args == "" then return "" end

	if not tonumber(args) then
		return ""
	end
	local trace = ply:GetEyeTrace()

	if ValidEntity(trace.Entity) and trace.Entity:IsPlayer() and trace.Entity:GetPos():Distance(ply:GetPos()) < 150 then
		local amount = math.floor(tonumber(args))

		if amount < 1 then
			Notify(ply, 1, 4, string.format(LANGUAGE.invalid_x, "argument", ""))
			return
		end

		if not ply:CanAfford(amount) then
			Notify(ply, 1, 4, string.format(LANGUAGE.cant_afford, ""))
			return ""
		end

		DB.PayPlayer(ply, trace.Entity, amount)

		Notify(trace.Entity, 0, 4, string.format(LANGUAGE.has_given, ply:Nick(), CUR .. tostring(amount)))
		Notify(ply, 0, 4, string.format(LANGUAGE.you_gave, trace.Entity:Nick(), CUR .. tostring(amount)))
	else
		Notify(ply, 1, 4, string.format(LANGUAGE.must_be_looking_at, "player"))
	end
	return ""
end
AddChatCommand("/give", GiveMoney)

local function DropMoney(ply, args)
	if args == "" then return "" end
	
	if not tonumber(args) then
		return ""
	end
	local amount = math.floor(tonumber(args))

	if amount <= 1 then
		Notify(ply, 1, 4, string.format(LANGUAGE.invalid_x, "argument", ""))
		return ""
	end

	if not ply:CanAfford(amount) then
		Notify(ply, 1, 4, string.format(LANGUAGE.cant_afford, ""))
		return ""
	end

	ply:AddMoney(-amount)

	local trace = {}
	trace.start = ply:EyePos()
	trace.endpos = trace.start + ply:GetAimVector() * 85
	trace.filter = ply

	local tr = util.TraceLine(trace)
	DarkRPCreateMoneyBag(tr.HitPos, amount)

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
			Notify(target, 1,4, string.format(LANGUAGE.cant_afford, "lottery"))
			return
		end
		table.insert(LotteryPeople, target)
		target:AddMoney(-CfgVars["lotterycommitcost"])
		Notify(target, 1,4, string.format(LANGUAGE.lottery_entered, CUR..tostring(CfgVars["lotterycommitcost"])))
	elseif answer and not table.HasValue(LotteryPeople, target) then
		Notify(target, 1,4, string.format(LANGUAGE.lottery_not_entered, target:Nick()))
	end
	
	if TimeIsUp then
		LotteryON = false
		CanLottery = CurTime() + 60
		if table.Count(LotteryPeople) == 0 then
			NotifyAll(1, 4, LANGUAGE.lottery_noone_entered)
			return
		end
		local chosen = LotteryPeople[math.random(1, #LotteryPeople)]
		chosen:AddMoney(#LotteryPeople * CfgVars["lotterycommitcost"])
		NotifyAll(1,10, string.format(LANGUAGE.lottery_won, chosen:Nick(), CUR .. tostring(#LotteryPeople * CfgVars["lotterycommitcost"]) ))
	end
end

function DoLottery(ply)
	if ply:Team() ~= TEAM_MAYOR then
		Notify(ply, 1, 4, string.format(LANGUAGE.incorrect_job, "/lottery"))
		return "" 
	end
	
	if CfgVars["lottery"] ~= 1 then
		Notify(ply, 1, 4, string.format(LANGUAGE.disabled, "/lottery", ""))
		return ""
	end
	
	if #player.GetAll() <= 2 or LotteryON then
		Notify(ply, 1, 6, string.format(LANGUAGE.unable, "/lottery", ""))
		return "" 
	end 

	if CanLottery > CurTime() then
		Notify(ply, 1, 5, string.format(LANGUAGE.have_to_wait,  tostring(CanLottery - CurTime()), "/lottery"))
		return "" 
	end
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

local lstat = false
local wait_lockdown = false
function Lockdown(ply)
	if not lstat then
		if ply:Team() == TEAM_MAYOR or ply:HasPriv(ADMIN) then
			for k,v in pairs(player.GetAll()) do
				v:ConCommand("play npc/overwatch/cityvoice/f_confirmcivilstatus_1_spkr.wav\n")
			end
			lstat = true
			PrintMessageAll(HUD_PRINTTALK , LANGUAGE.lockdown_started)
			SetGlobalInt("DarkRP_LockDown", 1)
			NotifyAll(4, 3, LANGUAGE.lockdown_started)
		end
	end
	return ""
end
concommand.Add("rp_lockdown", Lockdown)
AddChatCommand("/lockdown", Lockdown)

function UnLockdown(ply)
	if lstat and not wait_lockdown then
		if ply:Team() == TEAM_MAYOR or ply:HasPriv(ADMIN) then
			PrintMessageAll(HUD_PRINTTALK , LANGUAGE.lockdown_ended)
			NotifyAll(4, 3, LANGUAGE.lockdown_ended)
			wait_lockdown = true
			SetGlobalInt("DarkRP_LockDown", 0)
			timer.Create("spamlock", 20, 1, WaitLock, "")
		end
	end
	return ""
end
concommand.Add("rp_unlockdown", UnLockdown)
AddChatCommand("/unlockdown", UnLockdown)

function WaitLock()
	wait_lockdown = false
	lstat = false
	timer.Destroy("spamlock")
end

function MayorSetSalary(ply, cmd, args)
	if ply:EntIndex() == 0 then
		print("Console should use rp_setsalary instead.")
		return
	end

	if CfgVars["enablemayorsetsalary"] == 0 then
		ply:PrintMessage(2, string.format(LANGUAGE.disabled, "rp_setsalary", ""))
		Notify(ply, 1, 4, string.format(LANGUAGE.disabled, "rp_setsalary", ""))
		return 
	end

	if ply:Team() ~= TEAM_MAYOR then
		ply:PrintMessage(2, string.format(LANGUAGE.incorrect_job, "rp_setsalary"))
		return
	end

	local amount = math.floor(tonumber(args[2]))

	if not amount or amount < 0 then
		ply:PrintMessage(2, string.format(LANGUAGE.invalid_x, "salary", args[2]))
		return
	end

	if amount > GetGlobalInt("maxmayorsetsalary") then
		ply:PrintMessage(2, string.format(LANGUAGE.invalid_x, "salary", "< " .. GetGlobalInt("maxmayorsetsalary")))
		return
	end

	local plynick = ply:Nick()
	local target = FindPlayer(args[1])

	if target then
		local targetteam = target:Team()
		local targetnick = target:Nick()

		if targetteam == TEAM_MAYOR then
			Notify(ply, 1, 4, string.format(LANGUAGE.unable, "rp_setsalary", ""))
			return
		elseif targetteam == TEAM_POLICE or targetteam == TEAM_CHIEF then
			if amount > GetGlobalInt("maxcopsalary") then
				Notify(ply, 1, 4, string.format(LANGUAGE.invalid_x, "salary", "< " .. GetGlobalInt("maxcopsalary")))
				return
			else
				DB.StoreSalary(target, amount)
				ply:PrintMessage(2, "Set " .. targetnick .. "'s Salary to: " .. CUR .. amount)
				target:PrintMessage(2, plynick .. " set your Salary to: " .. CUR .. amount)
			end
		elseif targetteam == TEAM_CITIZEN or targetteam == TEAM_GUN or targetteam == TEAM_MEDIC or targetteam == TEAM_COOK then
			if amount > GetGlobalInt("maxnormalsalary") then
				Notify(ply, 1, 4, string.format(LANGUAGE.invalid_x, "salary", "< " .. GetGlobalInt("maxnormalsalary")))
				return
			else
				DB.StoreSalary(target, amount)
				ply:PrintMessage(2, "Set " .. targetnick .. "'s Salary to: " .. CUR .. amount)
				target:PrintMessage(2, plynick .. " set your Salary to: " .. CUR .. amount)
			end
		elseif targetteam == TEAM_GANG or targetteam == TEAM_MOB then
			Notify(ply, 1, 4, string.format(LANGUAGE.unable, "rp_setsalary", ""))
			return
		end
	else
		ply:PrintMessage(2, string.format(LANGUAGE.could_not_find, "player: "..tostring(args[1])))
	end
	return
end
concommand.Add("rp_mayor_setsalary", MayorSetSalary)

/*---------------------------------------------------------
 License
 ---------------------------------------------------------*/
function GrantLicense(answer, Ent, Initiator, Target)
	if answer == 1 then
		Notify(Initiator, 1, 4, string.format(LANGUAGE.gunlicense_granted, Initiator:Nick(), Target:Nick()))
		Notify(Target, 1, 4, string.format(LANGUAGE.gunlicense_granted, Initiator:Nick(), Target:Nick()))
		Initiator:SetDarkRPVar("HasGunlicense", true)
	else
		Notify(Initiator, 1, 4, string.format(LANGUAGE.gunlicense_denied, Initiator:Nick(), Target:Nick()))
	end
end

function RequestLicense(ply)
	if ply.DarkRPVars.HasGunlicense then
		Notify(ply, 1, 4, string.format(LANGUAGE.unable, "/requestlicense", ""))
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
		Notify(ply, 1, 4, string.format(LANGUAGE.unable, "/requestlicense", ""))
		return ""
	end
	
	if not ValidEntity(LookingAt) or not LookingAt:IsPlayer() or LookingAt:GetPos():Distance(ply:GetPos()) > 100 then
		Notify(ply, 1, 4, string.format(LANGUAGE.must_be_looking_at, "mayor/chief/cop"))
		return ""
	end
	
	if ismayor and LookingAt:Team() ~= TEAM_MAYOR then
		Notify(ply, 1, 4, string.format(LANGUAGE.must_be_looking_at, "mayor"))
		return ""
	elseif ischief and LookingAt:Team() ~= TEAM_CHIEF then
		Notify(ply, 1, 4, string.format(LANGUAGE.must_be_looking_at, "chief"))
		return ""
	elseif iscop and LookingAt:Team() ~= TEAM_POLICE then
		Notify(ply, 1, 4, string.format(LANGUAGE.must_be_looking_at, "cop"))
		return ""
	end
	
	Notify(ply, 1, 4, string.format(LANGUAGE.gunlicense_requested, ply:Nick(), LookingAt:Nick()))
	ques:Create(string.format(LANGUAGE.gunlicense_question_text, ply:Nick()), "Gunlicense"..ply:EntIndex(), LookingAt, 20, GrantLicense, ply, LookingAt)
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
		Notify(ply, 1, 4, string.format(LANGUAGE.incorrect_job, "/givelicense"))
		return ""
	elseif ischief and ply:Team() ~= TEAM_CHIEF then
		Notify(ply, 1, 4, string.format(LANGUAGE.incorrect_job, "/givelicense"))
		return ""
	elseif iscop and ply:Team() ~= TEAM_POLICE then
		Notify(ply, 1, 4, string.format(LANGUAGE.incorrect_job, "/givelicense"))
		return ""
	end
	
	local LookingAt = ply:GetEyeTrace().Entity
	if not ValidEntity(LookingAt) or not LookingAt:IsPlayer() or LookingAt:GetPos():Distance(ply:GetPos()) > 100 then
		Notify(ply, 1, 4, string.format(LANGUAGE.must_be_looking_at, "player"))
		return ""
	end
	Notify(LookingAt, 1, 4, string.format(LANGUAGE.gunlicense_granted, ply:Nick(), LookingAt:Nick())) 
	Notify(ply, 2, 4, string.format(LANGUAGE.gunlicense_granted, ply:Nick(), LookingAt:Nick()))
	LookingAt:SetDarkRPVar("HasGunlicense", true)
	return ""
end
AddChatCommand("/givelicense", GiveLicense)

function rp_GiveLicense(ply, cmd, args)
	if ply:EntIndex() ~= 0 and not ply:IsSuperAdmin() then
		ply:PrintMessage(2, string.format(LANGUAGE.need_sadmin, "rp_givelicense"))
		return
	end

	local target = FindPlayer(args[1])

	if target then
		target:SetDarkRPVar("HasGunlicense", true)

		if ply:EntIndex() ~= 0 then
			nick = ply:Nick()
		else
			nick = "Console"
		end

		Notify(target, 1, 4, string.format(LANGUAGE.gunlicense_granted, nick, target:Nick()))
		Notify(ply, 2, 4, string.format(LANGUAGE.gunlicense_granted, nick, target:Nick()))
		DB.Log(ply:SteamName().." ("..ply:SteamID()..") force-gave "..target:Nick().." a gun license")
		if ply:EntIndex() == 0 then
			DB.Log("Console force-gave "..target:Nick().." a gun license" )
		else
			DB.Log(ply:SteamName().." ("..ply:SteamID()..") force-gave "..target:Nick().." a gun license" )
		end
	else
		if ply:EntIndex() == 0 then
			print(string.format(LANGUAGE.could_not_find, "player: "..tostring(args[1])))
		else
			ply:PrintMessage(2, string.format(LANGUAGE.could_not_find, "player: "..tostring(args[1])))
		end
		return
	end
end
concommand.Add("rp_givelicense", rp_GiveLicense)

function rp_RevokeLicense(ply, cmd, args)
	if ply:EntIndex() ~= 0 and not ply:IsSuperAdmin() then
		ply:PrintMessage(2, string.format(LANGUAGE.need_sadmin, "rp_revokelicense"))
		return
	end

	local target = FindPlayer(args[1])

	if target then
		target:SetDarkRPVar("HasGunlicense", false)

		if ply:EntIndex() ~= 0 then
			nick = ply:Nick()
		else
			nick = "Console"
		end

		Notify(target, 1, 4, string.format(LANGUAGE.gunlicense_denied, nick, target:Nick()))
		Notify(ply, 2, 4, string.format(LANGUAGE.gunlicense_denied, nick, target:Nick()))
		DB.Log(ply:SteamName().." ("..ply:SteamID()..") force-removed "..target:Nick().."'s gun license")
		if ply:EntIndex() == 0 then
			DB.Log("Console force-removed "..target:Nick().."'s gun license" )
		else
			DB.Log(ply:SteamName().." ("..ply:SteamID()..") force-removed "..target:Nick().."'s gun license" )
		end
	else
		if ply:EntIndex() == 0 then
			print(string.format(LANGUAGE.could_not_find, "player: "..tostring(args[1])))
		else
			ply:PrintMessage(2, string.format(LANGUAGE.could_not_find, "player: "..tostring(args[1])))
		end
		return
	end
end
concommand.Add("rp_revokelicense", rp_RevokeLicense)

function FinishRevokeLicense(choice, v)
	if choice == 1 then
		v:SetDarkRPVar("HasGunlicense", false)
		v:StripWeapons()
		GAMEMODE:PlayerLoadout(v)
		NotifyAll(1, 4, string.format(LANGUAGE.gunlicense_removed, v:Nick()))
	else
		NotifyAll(1, 4, string.format(LANGUAGE.gunlicense_not_removed, v:Nick()))
	end
end

function VoteRemoveLicense(ply, args)
	local tableargs = string.Explode(" ", args)
	if #tableargs == 1 then
		Notify(ply, 1, 4, LANGUAGE.vote_specify_reason)
		return ""
	end
	local reason = ""
	for i = 2, #tableargs, 1 do
		reason = reason .. " " .. tableargs[i]
	end 
	reason = string.sub(reason, 2)
	if string.len(reason) > 22 then
		Notify(ply, 1, 4, string.format(LANGUAGE.unable, "/demotelicense", "<23"))
		return "" 
	end
	local p = FindPlayer(tableargs[1])
	if p then
		if CurTime() - ply:GetTable().LastVoteCop < 80 then
			Notify(ply, 1, 4, string.format(LANGUAGE.have_to_wait, math.ceil(80 - (CurTime() - ply:GetTable().LastVoteCop)), "/demotelicense"))
			return ""
		end
		if ply.DarkRPVars.HasGunlicense then
			Notify(ply, 1, 4,  string.format(LANGUAGE.unable, "/demotelicense", ""))
		else
			NotifyAll(1, 4, string.format(LANGUAGE.gunlicense_remove_vote_text, ply:Nick(), p:Nick()))
			vote:Create(p:Nick() .. ":\n"..string.format(LANGUAGE.gunlicense_remove_vote_text2, reason), p:EntIndex() .. "votecop"..ply:EntIndex(), p, 20, FinishRevokeLicense, true)
			ply:GetTable().LastVoteCop = CurTime()
			Notify(ply, 1, 4, LANGUAGE.vote_started)
		end
		return ""
	else
		Notify(ply, 1, 4, string.format(LANGUAGE.could_not_find, "player: "..tostring(args)))
		return ""
	end
end
AddChatCommand("/demotelicense", VoteRemoveLicense)
