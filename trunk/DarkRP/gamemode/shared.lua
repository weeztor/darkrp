

-- Teams
TEAM_CITIZEN = 1 -- Normal Citizens
TEAM_POLICE = 2 -- Police Officers (CPs)
TEAM_MAYOR = 3 -- Mayors
TEAM_GANG = 4 -- Gangsters
TEAM_MOB = 5 -- Mob Bosses
TEAM_GUN = 6 -- Gun Dealers
TEAM_MEDIC = 7 -- Medics
TEAM_COOK = 8 -- Cooks
TEAM_CHIEF = 9 -- Police Chiefs (CP Chiefs)
//TEAM_HOBO = 10

team.SetUp(TEAM_CITIZEN, "Citizen", Color(20, 150, 20, 255))
team.SetUp(TEAM_POLICE, "Civil Protection", Color(25, 25, 170, 255))
team.SetUp(TEAM_MAYOR, "Mayor", Color(150, 20, 20, 255))
team.SetUp(TEAM_GANG, "Gangster", Color(75, 75, 75, 255))
team.SetUp(TEAM_MOB, "Mob Boss", Color(25, 25, 25, 255))
team.SetUp(TEAM_GUN, "Gun Dealer", Color(255, 140, 0, 255))
team.SetUp(TEAM_MEDIC, "Medic", Color(47, 79, 79, 255))
team.SetUp(TEAM_COOK, "Cook", Color(238, 99, 99, 255))
team.SetUp(TEAM_CHIEF, "Civil Protection Chief", Color(20, 20, 255, 255))
//team.SetUp(TEAM_HOBO, "Hobo", Color(80, 45, 0, 255))

RPExtraTeams = {}
function AddExtraTeam( Name, color, model, Description, Weapons, command, maximum_amount_of_this_class, Salary, admin, Vote)
	table.insert(RPExtraTeams, {name = Name, model = model, Des = Description, Weapons = Weapons, command = command, max = maximum_amount_of_this_class, salary = Salary, admin = admin or 0, Vote = tobool(Vote)})
	team.SetUp(9 + #RPExtraTeams, Name, color)
end

/*
--------------------------------------------------------
HOW TO MAKE AN EXTRA CLASS!!!!
--------------------------------------------------------

You can make extra classes here. Set everything up here and the rest will be done for you! no more editing 100 files without knowing what you're doing!!!
Ok here's how:

To make an extra class do this:
AddExtraTeam( "<NAME OF THE CLASS>", Color(<red>, <Green>, <blue>, 255), "<Player model>" , [[<the description(it can have enters)>]], { "<first extra weapon>","<second extra weapon>", etc...}, "<chat command to become it(WITHOUT THE /!)>", <maximum amount of this team> <the salary he gets>, 0/1/2 = public /admin only / superadmin only, <1/0/true/false Do you have to vote to become it>)

The real example is here: it's the Hobo:		*/

			//The name    the color(what you see in tab)                   the player model					The description
AddExtraTeam("Hobo", Color(80, 45, 0, 255), "models/player/corpse1.mdl", [[The lowest member of society. All people see you laugh. 
You have no home.
Beg for your food and money
Sing for everyone who passes to get money
Make your own wooden home somewhere in a corner or 
outside someone else's door]], {"weapon_bugbait"}, "hobo", 5, 0, 0, false)
			//No extra weapons           say /hobo to become hobo  Maximum hobo's = 5		his salary = 0 because hobo's don't earn money.          0 = everyone can become hobo ,      false = you don't have to vote to become hobo
//ADD TEAMS HERE:
AddExtraTeam("minge", Color(0, 130, 255, 255), "models/player/soldier_stripped.mdl", [[Weird guy]], {"weapon_possessor", "stunstick"}, "minge",1, 999, 0, true)
