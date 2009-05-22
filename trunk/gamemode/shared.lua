-- Teams
TEAM_CITIZEN = 1 -- Normal Citizens
TEAM_POLICE = 2 -- Police Officers (CPs)
TEAM_MAYOR = 3 -- Mayors
TEAM_GANG = 4 -- Gangsters
TEAM_MOB = 5 -- mob bosses
TEAM_GUN = 6 -- Gun Dealers
TEAM_MEDIC = 7 -- Medics
TEAM_COOK = 8 -- Cooks
TEAM_CHIEF = 9 -- Police Chiefs (CP Chiefs)

team.SetUp(TEAM_CITIZEN, "Citizen", Color(20, 150, 20, 255))
team.SetUp(TEAM_POLICE, "Civil Protection", Color(25, 25, 170, 255))
team.SetUp(TEAM_MAYOR, "Mayor", Color(150, 20, 20, 255))
team.SetUp(TEAM_GANG, "Gangster", Color(75, 75, 75, 255))
team.SetUp(TEAM_MOB, "mob boss", Color(25, 25, 25, 255))
team.SetUp(TEAM_GUN, "Gun Dealer", Color(255, 140, 0, 255))
team.SetUp(TEAM_MEDIC, "Medic", Color(47, 79, 79, 255))
team.SetUp(TEAM_COOK, "Cook", Color(238, 99, 99, 255))
team.SetUp(TEAM_CHIEF, "Civil Protection Chief", Color(20, 20, 255, 255))

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
	team.SetUp(9 + #RPExtraTeams, Name, color)
	local Team = 9 + #RPExtraTeams
	if SERVER then
		timer.Simple(0.1, function(CustomTeam) AddTeamCommands(CustomTeam) end, CustomTeam)
	end
	return Team
end

hook.Add("InitPostEntity", "AddTeams", function()
	if file.Exists("CustomTeams.txt") then
		RunString(file.Read("CustomTeams.txt"))
		if SERVER then resource.AddFile("data/CustomTeams.txt") end
		if CLIENT and not LocalPlayer():IsSuperAdmin() then file.Delete("CustomTeams.txt") end
	end
end)

/*
--------------------------------------------------------
HOW TO MAKE AN EXTRA CLASS!!!!
--------------------------------------------------------

You can make extra classes here. Set everything up here and the rest will be done for you! no more editing 100 files without knowing what you're doing!!!
Ok here's how:

To make an extra class do this:
AddExtraTeam( "<NAME OF THE CLASS>", Color(<red>, <Green>, <blue>, 255), "<Player model>" , [[<the description(it can have enters)>]], { "<first extra weapon>","<second extra weapon>", etc...}, "<chat command to become it(WITHOUT THE /!)>", <maximum amount of this team> <the salary he gets>, 0/1/2 = public /admin only / superadmin only, <1/0/true/false Do you have to vote to become it>,  true/false DOES THIS TEAM HAVE A GUN LICENSE?, TEAM: Which team you need to be to become this team)

The real example is here: it's the Hobo:		*/

--VAR without /!!!			The name    the color(what you see in tab)                   the player model					The description
TEAM_HOBO = AddExtraTeam("Hobo", Color(80, 45, 0, 255), "models/player/corpse1.mdl", [[The lowest member of society. All people see you laugh. 
You have no home.
Beg for your food and money
Sing for everyone who passes to get money
Make your own wooden home somewhere in a corner or 
outside someone else's door]], {"weapon_bugbait"}, "hobo", 5, 0, 0, false)
//No extra weapons           say /hobo to become hobo  Maximum hobo's = 5		his salary = 0 because hobo's don't earn money.          0 = everyone can become hobo ,      false = you don't have to vote to become hobo
// MAKE SURE THAT THERE IS NO / IN THE TEAM NAME OR IN THE TEAM COMMAND:
// TEAM_/DUDE IS WROOOOOONG !!!!!!
// HAVING "/dude" IN THE COMMAND FIELD IS WROOOOOOOONG!!!!
//ADD TEAMS UNDER THIS LINE:
