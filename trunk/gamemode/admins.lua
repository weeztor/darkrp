-- admins.lua v 2.0 by philxyz

-- Player Priviliges
ADMIN = 0			-- DarkRP Admin
MAYOR = 1			-- Can become Mayor without a vote (Uses /mayor)
CP = 2					-- Can become CP without a vote (Uses /cp)
PTOOL = 3				-- Always spawns with the toolgun
PHYS = 4				-- Always spawns with the physgun
PROP = 5			-- Can always spawn props (unless jailed)


RPAdmins = {}


-- If you set this to true, all permissions are cleared from the database, so every admin gets lost, nothing gets saved
-- and only the players listed here are inserted, _every_ time you start DarkRP
-- NOTE TURNING THIS TO TRUE WILL BREAK THE SAVING ON RP_GRANT AND RP_REVOKE! 
-- SO KEEP YOUR HANDS OFF IT AND LEAVE IT TO FALSE IF YOU WANT TO USE RP_GRANT AND RP_REVOKE
-- YES THIS FILE STILL WORKS IF THIS IS SET TO FALSE
reset_all_privileges_to_these_on_startup = false

-- To configure a player, assign permissions to them in the following way:
-- RPAdmins["STEAM_ID"] = {LIST, OF, PERMISSIONS}


-- HOW TO GET A STEAM ID:
-- 1. JOIN AN INTERNET SERVER (NOT YOURS, UNLESS IT IS DEDICATED AND NON LAN)
-- 2. TYPE status IN CONSOLE
-- 3. IT WILL LIST STEAM IDs
-- 4. STEAM IDS ALWAYS START WITH STEAM_

-- HOW TO GRANT PRIVILEGES TO PLAYERS WHEN IN-GAME:
-- Super admin can use rp_grant or rp_revoke [admin|mayor|cp|tool|phys|prop] <Player>
-- while in-game to assign and remove privileges during the game without restarting the server


/*HERE IS HOW TO MAKE AN ADMIN IN THIS FILE IF YOU'RE TOO LAZY TO USE RP_GRANT OR RP_REVOKE:*/ --[[

DO NOT AdD ADMINS HERE, THESE ARE EXAMPLES:
RPAdmins["STEAM_1:0:12345678"] = {ADMIN, MAYOR, CP, PTOOL, PHYS, PROP}
RPAdmins["STEAM_1:0:9999999"] = {MAYOR, CP, PHYS}
END OF DO NOT ADD ADMINS HERE
-- etc.]]
-- Do not change anything above this line <--
-- ADD ADMINS/PRIVILEGES UNDER THIS LINE!
------------------------------------------------------------------------------------------------------
