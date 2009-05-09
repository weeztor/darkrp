includeCS("HungerMod/cl_init.lua")

include("HungerMod/player.lua")

HM = { }
FoodItems = { }

--[[ DB.SaveGlobal("hungermod", 0)       --Hunger mod is enabled or disabled

DB.SaveSetting("starverate", 3)      --How much health is taken away per second when starving
DB.SaveSetting("hungerspeed", 1)       --How much energy should deteriate every second
DB.SaveSetting("foodcost", 15)       --Cost of food
DB.SaveSetting("foodpay", 1)     --Whether there's a special spawning price for food
DB.SaveSetting("foodspawn", 1) ]]

concommand.Add("rp_hungerspeed", function(ply, cmd, args)
	if not ply:IsAdmin() then Notify(ply, 1, 4, "You're not an admin") return end
	if not args[1] then Notify(ply, 1, 4, "No arguments specified!") return end
	DB.SaveSetting("hungerspeed", tonumber(args[1]) / 10)
end)

function AddFoodItem(name, mdl, amount)
	FoodItems[name] = { model = mdl, amount = amount }
end

function HM.PlayerSpawn(ply)
	ply:SetNWInt("Energy", 100)
end
hook.Add("PlayerSpawn", "HM.PlayerSpawn", HM.PlayerSpawn)

function HM.PlayerSpawnProp(ply, model)
	for k, v in pairs(FoodItems) do
		if v.model == model then
			if GetGlobalInt("foodspawn") == 0 and ply:Team() ~= TEAM_COOK then return false end

			if (GetGlobalInt("hungermod") == 1 or ply:Team() == TEAM_COOK) and CfgVars["foodpay"] == 1 then
				if not GAMEMODE.BaseClass:PlayerSpawnProp(ply, model) then return false end

				if RPArrestedPlayers[ply:SteamID()] then return false end

				if (CfgVars["allowedprops"] == 0 and CfgVars["banprops"] == 0) or ply:HasPriv(ADMIN) then allowed = true end

				if CfgVars["propspawning"] == 0 then return false end

				if CfgVars["allowedprops"] == 1 then
					for n, m in pairs(AllowedProps) do
						if m == model then allowed = true end
					end
				end

				if CfgVars["banprops"] == 1 then
					for n, m in pairs(BannedProps) do
						if m == model then return false end
					end
				end

				local cost = CfgVars["foodcost"]

				if ply:CanAfford(cost) then
					ply:AddMoney(-cost)
				else
					Notify(ply, 1, 4, "Need " .. math.floor(cost) .. " bucks!")
					return false
				end
				Notify(ply, 1, 4, "You bought a "..k)
				
				local vStart = ply:GetShootPos() 
				local vForward = ply:GetAimVector() 
			   
				local trace = {} 
				trace.start = vStart 
				trace.endpos = vStart + (vForward * 2048) 
				trace.filter = ply 
				 
				local tr = util.TraceLine( trace )
				local food = ents.Create("spawned_food")
				local ang = ply:EyeAngles() 
				ang.yaw = ang.yaw + 180 // Rotate it 180 degrees in my favour 
				ang.roll = 0 
				ang.pitch = 0 
				food:SetModel( model ) 
				food:SetAngles( ang ) 
				food:SetPos( tr.HitPos ) 
				food:Spawn() 
				food:Activate() 
				food:SetNWString("Owner", "Shared")
				local vFlushPoint = tr.HitPos - ( tr.HitNormal * 512 )
				vFlushPoint = food:NearestPoint( vFlushPoint )
				vFlushPoint = food:GetPos() - vFlushPoint
				vFlushPoint = tr.HitPos + vFlushPoint	
				food:SetPos( vFlushPoint )
				//food:GetTable().FoodItem = 1
				food:GetTable().FoodEnergy = v.amount
				return false
			end
		end
	end
end
hook.Add("PlayerSpawnProp", "HM.PlayerSpawnProp", HM.PlayerSpawnProp)

function HM.Think()
	if GetGlobalInt("hungermod") ~= 1 then return end

	if CfgVars["hungerspeed"] == 0 then return end

	for k, v in pairs(player.GetAll()) do
		if v:Alive() and CurTime() - v:GetTable().LastHungerUpdate > 1 then
			v:HungerUpdate()
		end
	end
end
hook.Add("Think", "HM.Think", HM.Think)

function HM.PlayerInitialSpawn(ply)
	ply:NewHungerData()
end
hook.Add("PlayerInitialSpawn", "HM.PlayerInitialSpawn", HM.PlayerInitialSpawn)

for k, v in pairs(player.GetAll()) do
	v:NewHungerData()
end

HELP_CATEGORY_HUNGERMOD = #HelpCategories + 1

AddHelpCategory(HELP_CATEGORY_HUNGERMOD, "HungerMod - Rick Darkaliono")

AddToggleCommand("rp_hungermod", "hungermod", true)
AddHelpLabel(-1, HELP_CATEGORY_HUNGERMOD, "rp_hungermod <1 or 0> - Enable/disable hunger mod")

AddToggleCommand("rp_foodspawn", "foodspawn", true)
AddHelpLabel(-1, HELP_CATEGORY_ADMINTOGGLE, "rp_foodspawn - Whether players(non-cooks) can spawn food props or not")

AddToggleCommand("rp_foodspecialcost", "foodpay", false)
AddHelpLabel(-1, HELP_CATEGORY_HUNGERMOD, "rp_foodspecialcost <1 or 0> - Enable/disable whether spawning food props have a special cost")

AddValueCommand("rp_foodcost", "foodcost", false)
AddHelpLabel(-1, HELP_CATEGORY_HUNGERMOD, "rp_foodcost <Amount> - Set food cost")

AddValueCommand("rp_hungerspeed", "hungerspeed", false)
AddHelpLabel(-1, HELP_CATEGORY_HUNGERMOD, "rp_hungerspeed <Amount> - Set the rate at which players will become hungry (2 is the default)")

AddValueCommand("rp_starverate", "starverate", false)
AddHelpLabel(-1, HELP_CATEGORY_HUNGERMOD, "rp_starverate <Amount> - How much health that is taken away every second the player is starving  (3 is the default)")


AddFoodItem("banana", "models/props/cs_italy/bananna.mdl", 10)
AddFoodItem("bananabunch", "models/props/cs_italy/bananna_bunch.mdl", 20)
AddFoodItem("melon", "models/props_junk/watermelon01.mdl", 20)
AddFoodItem("glassbottle", "models/props_junk/GlassBottle01a.mdl", 20)
AddFoodItem("popcan", "models/props_junk/PopCan01a.mdl", 5)
AddFoodItem("plasticbottle", "models/props_junk/garbage_plasticbottle003a.mdl", 15)
AddFoodItem("milk", "models/props_junk/garbage_milkcarton002a.mdl", 20)
AddFoodItem("bottle1", "models/props_junk/garbage_glassbottle001a.mdl", 10)
AddFoodItem("bottle2", "models/props_junk/garbage_glassbottle002a.mdl", 10)
AddFoodItem("bottle3", "models/props_junk/garbage_glassbottle003a.mdl", 10)
AddFoodItem("orange", "models/props/cs_italy/orange.mdl", 20)

function BuyFood(ply, args)
	if args == "" then return "" end

	local trace = {}
	trace.start = ply:EyePos()
	trace.endpos = trace.start + ply:GetAimVector() * 85
	trace.filter = ply

	local tr = util.TraceLine(trace)

	if GetGlobalInt("hungermod") == 0 and ply:Team() ~= TEAM_COOK then
		Notify(ply, 1, 4, "/buyfood is disabled unless you're a cook or Hunger Mod is enabled.")
		return ""
	end

	if ply:Team() ~= TEAM_COOK and team.NumPlayers(TEAM_COOK) > 0 then
		Notify(ply, 1, 4, "/buyfood is disabled because there are Cooks.")
		return ""
	end

	for k,v in pairs(FoodItems) do
		if string.lower(args) == k then
			if not ply:CanAfford(CfgVars["foodcost"]) then
				Notify(ply, 1, 4, "Can not afford this!")
				return ""
			end
			ply:ConCommand("gm_spawn " .. v.model)
		end
	end
	return ""
end
AddChatCommand("/buyfood", BuyFood)

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