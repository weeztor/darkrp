local hints = {}
table.insert(hints, "Roleplay according to the Server Rules!")
table.insert(hints, "You can be arrested for buying or owning an illegal weapon!")
table.insert(hints, "Type /sleep to fall asleep.")
table.insert(hints, "You may own a handgun, but use it only in self defence.")
table.insert(hints, "All weapons can NOT shoot unless you see through the sight post!")
table.insert(hints, "If you are a cop, do your job properly or you could get demoted.")
table.insert(hints, "Type /buyshipment <Weapon name> to buy a shipment of weapons (e.g: /buyshipment ak47).")
table.insert(hints, "Type /buy <Pistol name/item name> to buy a pistol, e.g: /buy glock.")
table.insert(hints, "Type /buyammo <Ammo type> to buy ammo. Ammo types are: [rifle | shotgun | pistol]")
table.insert(hints, "If you wish to bail a friend out of jail, go to your designated Police Department and negotiate!")
table.insert(hints, "Press F1 to see RP help.")
table.insert(hints, "If you get arrested, don't worry - you will be auto unarrested in " .. GetGlobalInt("jailtimer") .. " seconds.")
table.insert(hints, "If you are a chief or admin, type /jailpos or /addjail to set the positions of the first (and extra) jails.")
table.insert(hints, "You will be teleported to jail if you get arrested!")
table.insert(hints, "If you're a cop and see someone with an illegal weapon, arrest them and confiscate it.")
table.insert(hints, "Type /sleep to fall asleep.")
table.insert(hints, "Your money and RP name are saved by the server.")
table.insert(hints, "Type /buyhealth to refil your health to 100%")
table.insert(hints, "Type /buydruglab to buy a druglab. be sure you sell your drugs!")
table.insert(hints, "Press F2 or reload with keys to open the keys menu")
table.insert(hints, "You will be teleported to a jail if you get arrested!")
table.insert(hints, "Type /price <Price> while looking at a druglab,  Gun Lab or a Microwave to set the customer purchase price.")
table.insert(hints, "Type /warrant [Nick|SteamID|UserID] to get a search warrant for a player.")
table.insert(hints, "Type /wanted or /unwanted [Nick|SteamID|UserID] to set a player as wanted/unwanted by the Police.")
table.insert(hints, "Type /drop to drop the weapon you are holding.")
table.insert(hints, "Type /gangster to become a Gangster.")
table.insert(hints, "Type /mobboss to become a Mob Boss.")
table.insert(hints, "Type /buymicrowave to buy a Microwave Oven that spawns food.")
table.insert(hints, "Type /dropmoney <Amount> to drop a money amount.")
table.insert(hints, "Type /buymoneyprinter to buy a Money Printer. Costs " .. CUR .. GetGlobalInt("mprintercost"))
table.insert(hints, "Type /medic - To become a Medic.")
table.insert(hints, "Type /gundealer - To become a Gun Dealer.")
table.insert(hints, "Type /buygunlab - to buy a Gun Lab.")
table.insert(hints, "Type /cook - to become a Cook.")
table.insert(hints, "Type /cophelp to see what you need to do as a cop.")
table.insert(hints, "Type /buyfood <Type> (e.g: /buyfood melon)")
table.insert(hints, "Type /rpname <Name> to choose your roleplay name.")

local function GiveHint()
	if CfgVars["advertisements"] ~= 1 then return end
	local text = hints[math.random(1, #hints)]

	for k,v in pairs(player.GetAll()) do
		TalkToPerson(v, Color(150,150,150,150), text)
	end
end

timer.Create("hints", 60, 0, GiveHint)
