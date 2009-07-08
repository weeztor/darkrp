CustomVehicles = {}
CustomShipments = {}
function AddCustomShipment(name, model, entity, price, Amount_of_guns_in_one_shipment, Sold_seperately, price_seperately, noshipment, classes, shipmodel)
	if not name or not model or not entity or not price or not Amount_of_guns_in_one_shipment or (Sold_seperately and not price_seperately) then
		local text = "One of the custom shipments is wrongly made! Attempt to give name of the wrongly made shipment!(if it's nil then I failed):\n" .. tostring(name)
		print(text)
		hook.Add("PlayerSpawn", "ShipmentError", function(ply)
			if ply:IsAdmin() then ply:ChatPrint("WARNING: "..text) end end)		
		return
	end
	if not util.IsValidModel(model) then
		local text = "The model of shipment "..name.." is incorrect! can not create custom shipment!"
		print(text) 
		hook.Add("PlayerSpawn", "ShipmentError", function(ply)
			if ply:IsAdmin() then ply:ChatPrint("WARNING: "..text) end end)		
		return
	end
	local AllowedClasses = classes or {}
	if not classes then
		for k,v in pairs(team.GetAllTeams()) do
			table.insert(AllowedClasses, k)
		end
	end
	local price = tonumber(price)
	local shipmentmodel = shipmodel or "models/Items/item_item_crate.mdl"
	table.insert(CustomShipments, {name = name, model = model, entity = entity, price = price, weight = 5, amount = Amount_of_guns_in_one_shipment, seperate = Sold_seperately, pricesep = price_seperately, noship = noshipment, allowed = AllowedClasses, shipmodel = shipmentmodel})
end

function AddCustomVehicle(Name_of_vehicle, price, Jobs_that_can_buy_it)
	local function warn(add)
		local text
		if Name_of_vehicle then text = Name_of_vehicle end
		text = text.." FAILURE IN CUSTOM VEHICLE!"
		print(text)
		hook.Add("PlayerSpawn", "VehicleError", function(ply)
			if ply:IsAdmin() then ply:ChatPrint("WARNING: "..text.." "..add) end end)		
	end
	if not Name_of_vehicle or not price then
		warn("The name or the price is invalid/missing")
		return
	end
	local found = false
	for k,v in pairs(list.Get("Vehicles")) do
		if string.lower(k) == string.lower(Name_of_vehicle) then found = true break end
	end
	if not found then
		warn("vehicle not found!")
		return
	end
	table.insert(CustomVehicles, {name = Name_of_vehicle, price = price, allowed = Jobs_that_can_buy_it})
end

hook.Add("InitPostEntity", "AddShipments", function()
	if file.Exists("CustomShipments.txt") then
		timer.Simple(2, RunString, file.Read("CustomShipments.txt"))
		if SERVER then resource.AddFile("data/CustomShipments.txt") end
		if CLIENT and not LocalPlayer():IsSuperAdmin() then file.Delete("CustomShipments.txt") end
	end
end)

AddCustomShipment("Desert eagle", "models/weapons/w_pist_deagle.mdl", "weapon_deagle2", 215, 10, true, 215, true)
AddCustomShipment("Fiveseven", "models/weapons/w_pist_fiveseven.mdl", "weapon_fiveseven2", 0, 10, true, 205, true)
AddCustomShipment("Glock", "models/weapons/w_pist_glock18.mdl", "weapon_glock2", 0, 10, true, 160, true)
AddCustomShipment("P228", "models/weapons/w_pist_p228.mdl", "weapon_p2282", 0, 10, true, 185, true)

AddCustomShipment("AK47", "models/weapons/w_rif_ak47.mdl", "weapon_ak472", 2450, 10, false, nil, false, {TEAM_GUN}) 
AddCustomShipment("MP5", "models/weapons/w_smg_mp5.mdl", "weapon_mp52", 2200, 10, false, nil, false, {TEAM_GUN}) 
AddCustomShipment("M4", "models/weapons/w_rif_m4a1.mdl", "weapon_m42", 2450, 10, false, nil, false, {TEAM_GUN}) 
AddCustomShipment("Mac 10", "models/weapons/w_smg_mac10.mdl", "weapon_mac102", 2150, 10, false, nil, false, {TEAM_GUN}) 
AddCustomShipment("Pump shotgun", "models/weapons/w_shot_m3super90.mdl", "weapon_pumpshotgun2", 1750, 10, false, nil, false, {TEAM_GUN}) 
AddCustomShipment("Sniper rifle", "models/weapons/w_snip_g3sg1.mdl", "ls_sniper", 3750, 10, false, nil, false, {TEAM_GUN}) 

/*
How to add custom vehicles:
FIRST
go ingame, type rp_getvehicles for available vehicles!
then:
AddCustomVehicle(<One of the vehicles from the rp_getvehicles list>, <Price of the vehicle>, <OPTIONAL jobs that can buy the vehicle>)
Examples:
AddCustomVehicle("Jeep", 100)
AddCustomVehicle("Airboat", 600, {TEAM_GUN})
AddCustomVehicle("Airboat", 600, {TEAM_GUN, TEAM_MEDIC})

Add those lines under your custom shipments. At the bottom of this file or in data/CustomShipments.txt

HOW TO ADD CUSTOM SHIPMENTS:
AddCustomShipment("<Name of the shipment(no spaces)>"," <the model that the shipment spawns(should be the world model...)>", "<the classname of the weapon>", <the price of one shipment>, <how many guns there are in one shipment>, <OPTIONAL: true/false sold seperately>, <OPTIONAL: price when sold seperately>, < true/false OPTIONAL: /buy only = true> , OPTIONAL which classes can buy the shipment, OPTIONAL: the model of the shipment)

Notes:
MODEL: you can go to Q and then props tab at the top left then search for w_ and you can find all world models of the weapons!
CLASSNAME OF THE WEAPON
there are half-life 2 weapons you can add:
weapon_pistol
weapon_smg1
weapon_ar2
weapon_rpg
weapon_crowbar
weapon_physgun
weapon_357
weapon_crossbow
weapon_slam
weapon_bugbait
weapon_frag
weapon_physcannon
weapon_shotgun
gmod_tool

But you can also add the classnames of Lua weapons by going into the weapons/ folder and look at the name of the folder of the weapon you want.
Like the player possessor swep in addons/Player Possessor/lua/weapons You see a folder called weapon_posessor 
This means the classname is weapon_posessor

YOU CAN ADD ITEMS/ENTITIES TOO! but to actually make the entity you have to press E on the thing that the shipment spawned, BUT THAT'S OK!
YOU CAN MAKE GUNDEALERS ABLE TO SELL MEDKITS!

true/false: Can the weapon be sold seperately?(with /buy name) if you want yes then say true else say no

the price of sold seperate is the price it is when you do /buy name. Of course you only have to fill this in when sold seperate is true.


EXAMPLES OF CUSTOM SHIPMENTS(remove the // to activate it): */

//AddCustomShipment("HL2pistol", "models/weapons/W_pistol.mdl", "weapon_pistol", 500, 10, false, 200, false, {TEAM_GUN, TEAM_MEDIC})

--EXAMPLE OF AN ENTITY(in this case a medkit)
--AddCustomShipment("bball", "models/Combine_Helicopter/helicopter_bomb01.mdl", "sent_ball", 100, 10, false, 10, false, {TEAM_GUN}, "models/props_c17/oildrum001_explosive.mdl")
--EXAMPLE OF A BOUNCY BALL:   		NOTE THAT YOU HAVE TO PRESS E REALLY QUICKLY ON THE BOMB OR YOU'LL EAT THE BALL LOL
--AddCustomShipment("bball", "models/Combine_Helicopter/helicopter_bomb01.mdl", "sent_ball", 100, 10, true, 10, true)
-- ADD CUSTOM SHIPMENTS HERE(next line):

