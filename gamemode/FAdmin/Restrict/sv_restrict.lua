sql.Query("CREATE TABLE IF NOT EXISTS FADMIN_RESTRICTED('TYPE' TEXT NOT NULL PRIMARY KEY, 'ENTITY' TEXT NOT NULL, 'ADMIN_GROUP' TEXT NOT NULL);")

local Restricted = {}
Restricted.Weapons = {}

local function RetrieveRestricted()
	local Query = sql.Query("SELECT * FROM FADMIN_RESTRICTED") or {}
	for k,v in pairs(Query) do
		if Restricted[v.TYPE] then
			Restricted[v.TYPE][v.ENTITY] = v.ADMIN_GROUP
		end
	end
end RetrieveRestricted()

local function RestrictWeapons(ply, cmd, args)
	if not FAdmin.Access.PlayerHasPrivilege(ply, "Restrict") then FAdmin.Messages.SendMessage(ply, 5, "No access!") return end
	local Weapon = args[1]
	local Group = args[2]
	if not Group or not FAdmin.Access.Groups[Group] or not Weapon then return end
	
	if Restricted.Weapons[Weapon] then
		sql.Query("UPDATE FADMIN_RESTRICTED SET ADMIN_GROUP = "..sql.SQLStr(Group).." WHERE ENTITY = "..sql.SQLStr(Weapon).." AND TYPE = "..sql.SQLStr("Weapons")..";")
	else
		sql.Query("INSERT INTO FADMIN_RESTRICTED VALUES("..sql.SQLStr("Weapons")..", "..sql.SQLStr(Weapon)..", "..sql.SQLStr(Group)..");")
	end
	Restricted.Weapons[Weapon] = Group
end

local function RestrictWeapons(ply, Weapon, WeaponTable)
	local Group = ply:GetNWString("usergroup")
	if not FAdmin or not FAdmin.Access or not FAdmin.Access.Groups or not FAdmin.Access.Groups[Group] 
	or not FAdmin.Access.Groups[Restricted.Weapons[Weapon]] then return end
	local RequiredGroup = Restricted.Weapons[Weapon]
	
	if Group ~= RequiredGroup and FAdmin.Access.Groups[Group].ADMIN <= FAdmin.Access.Groups[RequiredGroup].ADMIN then return false end
end
hook.Add("PlayerGiveSWEP", "FAdmin_RestrictWeapons", RestrictWeapons)
hook.Add("PlayerSpawnSWEP", "FAdmin_RestrictWeapons", RestrictWeapons)

hook.Add("FAdmin_PluginsLoaded", "Restrict", function()
	FAdmin.Commands.AddCommand("RestrictWeapon", RestrictWeapons)
	
	FAdmin.Access.AddPrivilege("Restrict", 3)
end)