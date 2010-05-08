RPExtraTeams = {}
function AddExtraTeam( Name, color, model, Description, Weapons, command, maximum_amount_of_this_class, Salary, admin, Vote, Haslicense, NeedToChangeFrom)
	if not Name or not color or not model or not Description or not Weapons or not command or not maximum_amount_of_this_class or not Salary or not admin or Vote == nil then
		local text = "One of the custom teams is wrongly made! Attempt to give name of the wrongly made team!(if it's nil then I failed):\n" .. tostring(Name)
		print(text)
		hook.Add("PlayerSpawn", "TeamError", function(ply)
			if ply:IsAdmin() then ply:ChatPrint("WARNING: "..text) end
		end)	
	end
	local CustomTeam = {name = Name, model = model, Des = Description, Weapons = Weapons, command = command, max = maximum_amount_of_this_class, salary = Salary, admin = admin or 0, Vote = tobool(Vote), NeedToChangeFrom = NeedToChangeFrom, Haslicense = Haslicense}
	table.insert(RPExtraTeams, CustomTeam)
	team.SetUp(#RPExtraTeams, Name, color)
	local Team = #RPExtraTeams
	if SERVER then
		timer.Simple(0, function(CustomTeam, maximum_amount_of_this_class) AddTeamCommands(CustomTeam, maximum_amount_of_this_class) end, CustomTeam, maximum_amount_of_this_class)
	end
	return Team
end

RPExtraTeamDoors = {}

function AddDoorGroup(name, ...)
	RPExtraTeamDoors[name] = {...}
end

hook.Add("InitPostEntity", "AddTeams", function()
	if file.Exists("CustomTeams.txt") then
		RunString(file.Read("CustomTeams.txt"))
		if SERVER then resource.AddFile("data/CustomTeams.txt") end
		if CLIENT and not LocalPlayer():IsSuperAdmin() then file.Delete("CustomTeams.txt") end
	end
end)

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

function AddCustomVehicle(Name_of_vehicle, model, price, Jobs_that_can_buy_it)
	local function warn(add)
		local text
		if Name_of_vehicle then text = Name_of_vehicle end
		text = text.." FAILURE IN CUSTOM VEHICLE!"
		print(text)
		hook.Add("PlayerSpawn", "VehicleError", function(ply)
			if ply:IsAdmin() then ply:ChatPrint("WARNING: "..text.." "..add) end end)		
	end
	if not Name_of_vehicle or not price or not model then
		warn("The name, model or the price is invalid/missing")
		return
	end
	local found = false
	for k,v in pairs(list.Get("Vehicles")) do
		if string.lower(k) == string.lower(Name_of_vehicle) then found = true break end
	end
	if not found and SERVER then
		warn("vehicle not found!")
		return
	end
	table.insert(CustomVehicles, {name = Name_of_vehicle, model = model, price = price, allowed = Jobs_that_can_buy_it})
end

DarkRPEntities = {}
function AddEntity(name, entity, model, price, max, command, classes)
	if not name or not entity or not price or not command then 
		hook.Add("PlayerSpawn", "ItemError", function(ply)
		if ply:IsAdmin() then ply:ChatPrint("WARNING: Item made incorrectly, failed to load!") end end) 
		return 
	end
	if type(classes) == "number" then
		classes = {classes}
	end
	table.insert(DarkRPEntities, {name = name, ent = entity, model = model, price = price, max = max, cmd = command, allowed = classes})
	AddEntityCommands(name, entity, max, price)
end

hook.Add("InitPostEntity", "AddShipments", function()
	if file.Exists("CustomShipments.txt") then
		timer.Simple(2, RunString, file.Read("CustomShipments.txt"))
		if SERVER then resource.AddFile("data/CustomShipments.txt") end
		if CLIENT and not LocalPlayer():IsSuperAdmin() then file.Delete("CustomShipments.txt") end
	end
end)

DarkRPAgendas = {}

function AddAgenda(Title, Manager, Listeners)
	DarkRPAgendas[Manager] = {Title = Title, Listeners = Listeners} 
end

	