CustomShipments = {}
function AddCustomShipment(name, model, entity, price, Amount_of_guns_in_one_shipment)
	table.insert(CustomShipments, {name = name, model = model, entity = entity, price = price, weight = 5, amount = Amount_of_guns_in_one_shipment})
end

/*
HOW TO ADD CUSTOM SHIPMENTS:
AddCustomShipment("<Name of the shipment(no spaces)>"," <the model that the shipment spawns(should be the world model...)>", "<the classname of the weapon>", <the price of one shipment>, <how many guns there are in one shipment>)

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


EXAMPLES OF CUSTOM SHIPMENTS(remove the -- to activate it): */

--AddCustomShipment("HL2pistol", "models/weapons/W_pistol.mdl", "weapon_pistol", 500, 10)

--EXAMPLE OF AN ENTITY(in this case a medkit)
--AddCustomShipment("medkit", "models/Combine_Helicopter/helicopter_bomb01.mdl", "item_healthkit", 100, 10)
--EXAMPLE OF A BOUNCY BALL:   		NOTE THAT YOU HAVE TO PRESS E REALLY QUICKLY ON THE BOMB OR YOU'LL EAT THE BALL LOL
--AddCustomShipment("bball", "models/Combine_Helicopter/helicopter_bomb01.mdl", "sent_ball", 100, 10)

