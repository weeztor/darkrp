includeCS("HungerMod/cl_init.lua")

include("HungerMod/player.lua")

local HM = { }
FoodItems = { }

concommand.Add("rp_hungerspeed", function(ply, cmd, args)
	if not ply:IsAdmin() then Notify(ply, 1, 4, string.format(LANGUAGE.need_admin, "rp_hungerspeed")) return end
	if not tonumber(args[1]) then Notify(ply, 1, 4, string.format(LANGUAGE.invalid_x, "argument", "")) return end
	DB.SaveSetting("hungerspeed", tonumber(args[1]) / 10)
end)

function AddFoodItem(name, mdl, amount)
	FoodItems[name] = { model = mdl, amount = amount }
end

function HM.PlayerSpawn(ply)
	ply:SetDarkRPVar("Energy", 100)
end
hook.Add("PlayerSpawn", "HM.PlayerSpawn", HM.PlayerSpawn)

function HM.Think()
	if GetConVarNumber("hungermod") ~= 1 then return end

	if GetConVarNumber("hungerspeed") == 0 then return end

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

HELP_CATEGORY_HUNGERMOD = 4

AddHelpCategory(HELP_CATEGORY_HUNGERMOD, "HungerMod - Rick Darkaliono")

AddToggleCommand("rp_hungermod", "hungermod", 0)
AddHelpLabel(-1, HELP_CATEGORY_HUNGERMOD, "rp_hungermod <1 or 0> - Enable/disable hunger mod")

AddToggleCommand("rp_foodspawn", "foodspawn", 1)
AddHelpLabel(-1, HELP_CATEGORY_ADMINTOGGLE, "rp_foodspawn - Whether players(non-cooks) can spawn food props or not")

AddToggleCommand("rp_foodspecialcost", "foodpay", 1)
AddHelpLabel(-1, HELP_CATEGORY_HUNGERMOD, "rp_foodspecialcost <1 or 0> - Enable/disable whether spawning food props have a special cost")

AddValueCommand("rp_foodcost", "foodcost", 15)
AddHelpLabel(-1, HELP_CATEGORY_HUNGERMOD, "rp_foodcost <Amount> - Set food cost")

AddValueCommand("rp_hungerspeed", "hungerspeed", 2)
AddHelpLabel(-1, HELP_CATEGORY_HUNGERMOD, "rp_hungerspeed <Amount> - Set the rate at which players will become hungry (2 is the default)")

AddValueCommand("rp_starverate", "starverate", 3)
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

local function BuyFood(ply, args)
	if args == "" then return "" end

	local trace = {}
	trace.start = ply:EyePos()
	trace.endpos = trace.start + ply:GetAimVector() * 85
	trace.filter = ply

	local tr = util.TraceLine(trace)

	if GetConVarNumber("hungermod") == 0 and ply:Team() ~= TEAM_COOK then
		Notify(ply, 1, 4, string.format(LANGUAGE.disabled, "hungermod", ""))
		return ""
	end

	if ply:Team() ~= TEAM_COOK and team.NumPlayers(TEAM_COOK) > 0 then
		Notify(ply, 1, 4, string.format(LANGUAGE.unable, "/buyfood", "cooks"))
		return ""
	end

	for k,v in pairs(FoodItems) do
		if string.lower(args) == k then
			local cost = GetConVarNumber("foodcost")		
			if ply:CanAfford(cost) then
				ply:AddMoney(-cost)
			else
				Notify(ply, 1, 4, string.format(LANGUAGE.cant_afford, ""))
				return ""
			end
			Notify(ply, 0, 4, string.format(LANGUAGE.you_bought_x, k, tostring(cost)))
			local SpawnedFood = ents.Create("spawned_food")
			SpawnedFood.dt.owning_ent = ply
			SpawnedFood.ShareGravgun = true
			SpawnedFood:SetPos(tr.HitPos)
			SpawnedFood.onlyremover = true
			SpawnedFood.SID = ply.SID
			SpawnedFood:SetModel(v.model)
			SpawnedFood.FoodEnergy = v.amount
			SpawnedFood:Spawn()
			return ""
		end
	end
	return ""
end
AddChatCommand("/buyfood", BuyFood)