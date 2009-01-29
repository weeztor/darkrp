-- admins.lua v 2.0 by philxyz

RPAdmins = {}

---------------------------------------------------------------------------------------------------------------------------

-- Do not change anything above the line ^

-- If you set this to true, all permissions are cleared from the database
-- and only the players listed here are inserted, _every_ time you start DarkRP
reset_all_privileges_to_these_on_startup = true

-- To configure a player, assign permissions to them in the following way:
-- RPAdmins["STEAM_ID"] = {LIST, OF, PERMISSIONS}
-- e.g:

-- RPAdmins["STEAM_0:1:12345678"] = {ADMIN, MAYOR, CP, TOOL, PHYS, PROP}
-- RPAdmins["STEAM_0:1:9999999"] = {MAYOR, CP, PHYS}
-- etc.

-- HOW TO GET A STEAM ID:
-- 1. JOIN AN INTERNET SERVER (NOT YOURS, UNLESS IT IS DEDICATED AND NON LAN)
-- 2. TYPE status IN CONSOLE
-- 3. IT WILL LIST STEAM IDs

-- HOW TO GRANT PRIVILEGES TO PLAYERS WHEN IN-GAME:
-- Super admin can use rp_grant or rp_revoke [admin|mayor|cp|tool|phys|prop] <Player>
-- while in-game to assign and remove privileges during the game without restarting the server