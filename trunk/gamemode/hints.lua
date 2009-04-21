local function GiveHint()
	if CfgVars["advertisements"] ~= 1 then return end
	local hint = math.random(1, 38)

	for k,v in pairs(player.GetAll()) do
		if hint == 1 then
			TalkToPerson(v, Color(150,150,150,150), "Roleplay according to the Server Rules!")
		elseif hint == 2 then
			TalkToPerson(v, Color(150,150,150,150), "You can be arrested for buying or owning an illegal weapon!")
		elseif hint == 3 then
			TalkToPerson(v, Color(150,150,150,150), "Type /sleep to fall asleep.")
		elseif hint == 4 then
			TalkToPerson(v, Color(150,150,150,150), "You may own a handgun, but use it only in self defence.")
		elseif hint == 5 then
			TalkToPerson(v, Color(150,150,150,150), "Press F2 to open the keys menu")
		elseif hint == 6 then
			TalkToPerson(v, Color(150,150,150,150), "All weapons are very inaccurate, unless you right click to see through the sight post.")
		elseif hint == 7 then
			TalkToPerson(v, Color(150,150,150,150), "If you are a cop, do your job properly or you could get demoted.")
		elseif hint == 8 then
			TalkToPerson(v, Color(150,150,150,150), "Type /buyshipment <Weapon name> to buy a shipment of weapons (e.g: /buyshipment ak47).")
		elseif hint == 9 then
			TalkToPerson(v, Color(150,150,150,150), "Type /buy <Pistol name/item name> to buy a pistol, e.g: /buy glock.")
		elseif hint == 10 then
			TalkToPerson(v, Color(150,150,150,150), "Type /buyammo <Ammo type> to buy ammo. Ammo types are: [rifle | shotgun | pistol]")
		elseif hint == 11 then
			TalkToPerson(v, Color(150,150,150,150), "If you wish to bail a friend out of jail, go to your designated Police Department and negotiate!")
		elseif hint == 12 then
			TalkToPerson(v, Color(150,150,150,150), "Press F1 to see RP help.")
		elseif hint == 13 then
			TalkToPerson(v, Color(150,150,150,150), "If you get arrested, don't worry - you will be auto unarrested in " .. GetGlobalInt("jailtimer") .. " seconds.")
		elseif hint == 14 then
			TalkToPerson(v, Color(150,150,150,150), "If you are a chief or admin, type /jailpos or /addjail to set the positions of the first (and extra) jails.")
		elseif hint == 15 then
			TalkToPerson(v, Color(150,150,150,150), "You will be teleported to jail if you get arrested!")
		elseif hint == 16 then
			TalkToPerson(v, Color(150,150,150,150), "If you're a cop and see someone with an illegal weapon, arrest them and confiscate it.")
		elseif hint == 17 then
			TalkToPerson(v, Color(150,150,150,150), "Type /sleep to fall asleep.")
		elseif hint == 18 then
			TalkToPerson(v, Color(150,150,150,150), "Your money and RP name are saved by the server.")
		elseif hint == 19 then
			TalkToPerson(v, Color(150,150,150,150), "Type /buyhealth to refil your health to 100%")
		elseif hint == 20 then
			TalkToPerson(v, Color(150,150,150,150), "Type /buydruglab to buy a druglab. be sure you sell your drugs!")
		elseif hint == 21 then
			TalkToPerson(v, Color(150,150,150,150), "Press F2 to open the keys menu")
		elseif hint == 22 then
			TalkToPerson(v, Color(150,150,150,150), "You will be teleported to a jail if you get arrested!")
		elseif hint == 23 then
			TalkToPerson(v, Color(150,150,150,150), "Type /price <Price> while looking at a druglab,  Gun Lab or a Microwave to set the customer purchase price.")
		elseif hint == 24 then
			TalkToPerson(v, Color(150,150,150,150), "Type /warrant [Nick|SteamID|UserID] to get a search warrant for a player.")
		elseif hint == 25 then
			TalkToPerson(v, Color(150,150,150,150), "Type /wanted or /unwanted [Nick|SteamID|UserID] to set a player as wanted/unwanted by the Police.")
		elseif hint == 26 then
			TalkToPerson(v, Color(150,150,150,150), "Type /drop to drop the weapon you are holding.")
		elseif hint == 27 then
			TalkToPerson(v, Color(150,150,150,150), "Type /gangster to become a Gangster.")
		elseif hint == 28 then
			TalkToPerson(v, Color(150,150,150,150), "Type /mobboss to become a Mob Boss.")
		elseif hint == 29 then
			TalkToPerson(v, Color(150,150,150,150), "Type /buymicrowave to buy a Microwave Oven that spawns food.")
		elseif hint == 30 then
			TalkToPerson(v, Color(150,150,150,150), "Type /dropmoney <Amount> to drop a money amount.")
		elseif hint == 31 then
			TalkToPerson(v, Color(150,150,150,150), "Type /buymoneyprinter to buy a Money Printer. Costs " .. CUR .. GetGlobalInt("mprintercost"))
		elseif hint == 32 then
			TalkToPerson(v, Color(150,150,150,150), "Type /medic - To become a Medic.")
		elseif hint == 33 then
			TalkToPerson(v, Color(150,150,150,150), "Type /gundealer - To become a Gun Dealer.")
		elseif hint == 34 then
			TalkToPerson(v, Color(150,150,150,150), "Type /buygunlab - to buy a Gun Lab.")
		elseif hint == 35 then
			TalkToPerson(v, Color(150,150,150,150), "Type /cook - to become a Cook.")
		elseif hint == 36 then
			TalkToPerson(v, Color(150,150,150,150), "Type /cophelp to see what you need to do as a cop.")
		elseif hint == 37 then
			TalkToPerson(v, Color(150,150,150,150), "Type /buyfood <Type> (e.g: /buyfood melon)")
		elseif hint == 38 then
			TalkToPerson(v, Color(150,150,150,150), "Type /rpname <Name> to choose your roleplay name.")
		end
	end
end

timer.Create("hints", 60, 0, GiveHint)
