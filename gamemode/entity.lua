/*---------------------------------------------------------
 Shared part
 ---------------------------------------------------------*/
local meta = FindMetaTable("Entity")

function meta:IsOwnable()
	local class = self:GetClass()

	if (class == "func_door" or class == "func_door_rotating" or class == "prop_door_rotating") or
		class == "prop_vehicle_jeep" or class == "prop_vehicle_airboat" then
			return true
		end
	return false
end

function meta:IsDoor()
	local class = self:GetClass()

	if class == "func_door" or
		class == "func_door_rotating" or
		class == "prop_door_rotating" or
		class == "prop_dynamic" then
		return true
	end
	return false
end

function meta:IsOwned()
	local num = 0
	for n = 1, self:GetNWInt("OwnerCount") do
		if self:GetNWInt("Ownersz" .. n) > -1 then
			num = num + 1
		end
	end

	if ValidEntity(self:GetNWEntity("TheOwner")) or num > 0 then return true end

	return false
end

function meta:GetDoorOwner()
	return self:GetNWEntity("TheOwner")
end

function meta:IsMasterOwner(ply)
	if ply == self:GetDoorOwner() then
		return true
	end

	return false
end

function meta:OwnedBy(ply)
	if ply == self:GetDoorOwner() then return true end

	local num = self:GetNWInt("OwnerCount")

	for n = 1, num do
		if ply:EntIndex() == self:GetNWInt("Ownersz" .. n) then
			return true
		end
	end

	return false
end

function meta:AllowedToOwn(ply)
	local num = self:GetNWInt("AllowedNum")

	for n = 1, num do
		if self:GetNWInt("Allowed" .. n) == ply:EntIndex() then
			return true
		end
	end

	return false
end

/*---------------------------------------------------------
 Serverside part
 ---------------------------------------------------------*/
if not SERVER then return end

local time = false
local function SetDoorOwnable(ply)
	if time then return "" end
	time = true
	timer.Simple(0.1, function()  time = false end)
	local trace = ply:GetEyeTrace()
	if not ValidEntity(trace.Entity) then return "" end
	local ent = trace.Entity
	if ply:IsSuperAdmin() and ent:IsDoor() and ply:GetPos():Distance(ent:GetPos()) < 115 then
		ent:SetNWBool("nonOwnable", not ent:GetNWBool("nonOwnable"))
		-- Save it for future map loads
		DB.StoreDoorOwnability(ent)
	end
	ent:UnOwn()
	return ""
end
AddChatCommand("/toggleownable", SetDoorOwnable)

local time3 = false
local function SetDoorCPOwnable(ply)
	if time3 then return "" end
	time3 = true
	timer.Simple(0.1, function()  time3 = false end)
	local trace = ply:GetEyeTrace()
	if not ValidEntity(trace.Entity) then return "" end
	local ent = trace.Entity
	if ply:IsSuperAdmin() and ent:IsDoor() and ply:GetPos():Distance(ent:GetPos()) < 115 then
		for k,v in pairs(player.GetAll()) do ent:UnOwn(v) end
		ent:SetNWBool("CPOwnable", not ent:GetNWBool("CPOwnable"))
		-- Save it for future map loads
		DB.StoreCPDoorOwnability(ent)
	end
	ent:UnOwn()
	return ""
end
AddChatCommand("/togglecpownable", SetDoorCPOwnable)

local time2 = false
local function OwnDoor(ply)
	if time2 then return "" end
	time2 = true
	timer.Simple(0.1, function()  time2 = false end)
	
	local trace = ply:GetEyeTrace()

	if ValidEntity(trace.Entity) and trace.Entity:IsOwnable() and ply:GetPos():Distance(trace.Entity:GetPos()) < 200 then
		if RPArrestedPlayers[ply:SteamID()] then
			Notify(ply, 1, 5, LANGUAGE.door_unown_arrested)
			return ""
		end

		if trace.Entity:GetNWBool("nonOwnable") or trace.Entity:GetNWBool("CPOwnable") then
			Notify(ply, 1, 5, LANGUAGE.door_unownable)
			return ""
		end

		if trace.Entity:OwnedBy(ply) then
			Notify(ply, 1, 4, string.format(LANGUAGE.door_sold,  CUR .. math.floor(((CfgVars["doorcost"] * 0.66666666666666)+0.5))))
			trace.Entity:Fire("unlock", "", 0)
			trace.Entity:UnOwn(ply)
			ply:GetTable().Ownedz[trace.Entity:EntIndex()] = nil
			ply:GetTable().OwnedNumz = ply:GetTable().OwnedNumz - 1
			ply:AddMoney(math.floor(((CfgVars["doorcost"] * 0.66666666666666)+0.5)))
		else
			if trace.Entity:IsOwned() and not trace.Entity:AllowedToOwn(ply) then
				Notify(ply, 1, 4, LANGUAGE.door_already_owned)
				return ""
			end
			if trace.Entity:GetClass() == "prop_vehicle_jeep" or trace.Entity:GetClass() == "prop_vehicle_airboat" then
				if not ply:CanAfford(CfgVars["vehiclecost"]) then
					Notify(ply, 1, 4, LANGUAGE.vehicle_cannot_afford)
					return ""
				end
			else
				if not ply:CanAfford(CfgVars["doorcost"]) then
					Notify(ply, 1, 4, LANGUAGE.door_cannot_afford)
					return ""
				end
			end

			if trace.Entity:GetClass() == "prop_vehicle_jeep" or trace.Entity:GetClass() == "prop_vehicle_airboat" then
				ply:AddMoney(-CfgVars["vehiclecost"])
				Notify(ply, 1, 4, string.format(LANGUAGE.vehicle_bought, CUR .. math.floor(CfgVars["vehiclecost"])))
			else
				ply:AddMoney(-CfgVars["doorcost"])
				Notify(ply, 1, 4, string.format(LANGUAGE.door_bought, CUR .. math.floor(CfgVars["doorcost"])))
			end
			trace.Entity:Own(ply)

			if ply:GetTable().OwnedNumz == 0 then
				timer.Create(ply:SteamID() .. "propertytax", 270, 0, ply.DoPropertyTax, ply)
			end

			ply:GetTable().OwnedNumz = ply:GetTable().OwnedNumz + 1

			ply:GetTable().Ownedz[trace.Entity:EntIndex()] = trace.Entity
		end
		return ""
	end
	Notify(ply, 1, 4, string.format(LANGUAGE.must_be_looking_at, "vehicle/door"))
	return ""
end
AddChatCommand("/toggleown", OwnDoor)

function meta:UnOwn(ply)

	if not ply then
		ply = self:GetDoorOwner()

		if not ValidEntity(ply) then return end
	end

	if self:IsMasterOwner(ply) then
		self:SetNWEntity("TheOwner", NULL)
	else
		self:RemoveOwner(ply)
	end

	local num = 0

	for n = 1, self:GetNWInt("OwnerCount") do
		if self:GetNWInt("Ownersz" .. n) > -1 then
			num = num + 1
		end
	end

	if not self:GetDoorOwner():IsValid() and num == 0 then
		num = self:GetNWInt("AllowedNum")
		for n = 1, num do
			self:SetNWInt("Allowed" .. n, -1)
		end
	end
end

function meta:AddAllowed(ply)
	local num = self:GetNWInt("AllowedNum")
	num = num + 1

	self:SetNWInt("AllowedNum", num)
	self:SetNWInt("Allowed" .. num, ply:EntIndex())
end

function meta:RemoveAllowed(ply)
	local num = self:GetNWInt("AllowedNum")

	for n = 1, num do
		if self:GetNWInt("Allowed" .. n) == ply:EntIndex() then
			self:SetNWInt("Allowed" .. n, -1)
			break
		end
	end
end

function meta:AddOwner(ply)
	local num = self:GetNWInt("OwnerCount")
	num = num + 1

	self:SetNWInt("OwnerCount", num)
	self:SetNWInt("Ownersz" .. num, ply:EntIndex())
	self:RemoveAllowed(ply)
end

function meta:RemoveOwner(ply)
	local num = self:GetNWInt("OwnerCount")
	for n = 1, num do
		if ply:EntIndex() == self:GetNWInt("Ownersz" .. n) then
			self:SetNWInt("Ownersz" .. n, -1)
			break
		end
	end
end

function meta:Own(ply)

	if self:AllowedToOwn(ply) then
		self:AddOwner(ply)
		return
	end

	if not self:IsOwned() and not self:OwnedBy(ply) then
		self:SetNWEntity("TheOwner", ply)
	end
end

function SetDoorTitle(ply, args)
	local trace = ply:GetEyeTrace()

	if ValidEntity(trace.Entity) and trace.Entity:IsOwnable() and ply:GetPos():Distance(trace.Entity:GetPos()) < 110 then
		if ply:IsSuperAdmin() then
			if trace.Entity:GetNWBool("nonOwnable") then
				DB.StoreNonOwnableDoorTitle(trace.Entity, args)
				return ""
			end
		else
			if trace.Entity:GetNWBool("nonOwnable") then
				Notify(ply, 1, 6, string.format(LANGUAGE.need_admin, "/title"))
			end
		end

		if trace.Entity:OwnedBy(ply) then
			trace.Entity:SetNWString("title", args)
		else
			Notify(ply, 1, 6, string.format(LANGUAGE.door_need_to_own, "/title"))
		end
	end

	return ""
end
AddChatCommand("/title", SetDoorTitle)

function RemoveDoorOwner(ply, args)
	local trace = ply:GetEyeTrace()

	if ValidEntity(trace.Entity) and trace.Entity:IsOwnable() and ply:GetPos():Distance(trace.Entity:GetPos()) < 110 then
		target = FindPlayer(args)

		if trace.Entity:GetNWBool("nonOwnable") then
			Notify(ply, 1, 4, LANGUAGE.door_rem_owners_unownable)
		end

		if target then
			if trace.Entity:OwnedBy(ply) then
				if trace.Entity:AllowedToOwn(target) then
					trace.Entity:RemoveAllowed(target)
				end

				if trace.Entity:OwnedBy(target) then
					trace.Entity:RemoveOwner(target)
				end
			else
				Notify(ply, 1, 4, LANGUAGE.do_not_own_ent)
			end
		else
			Notify(ply, 1, 4, string.format(LANGUAGE.could_not_find, "player: "..tostring(args)))
		end
	end
	return ""
end
AddChatCommand("/removeowner", RemoveDoorOwner)
AddChatCommand("/ro", RemoveDoorOwner)

local function AddDoorOwner(ply, args)
	local trace = ply:GetEyeTrace()

	if ValidEntity(trace.Entity) and trace.Entity:IsOwnable() and ply:GetPos():Distance(trace.Entity:GetPos()) < 110 then
		target = FindPlayer(args)
		if target then
			if trace.Entity:GetNWBool("nonOwnable") then
				Notify(ply, 1, 4, LANGUAGE.door_add_owners_unownable)
				return ""
			end

			if trace.Entity:OwnedBy(ply) then
				if not trace.Entity:OwnedBy(target) and not trace.Entity:AllowedToOwn(target) then
					trace.Entity:AddAllowed(target)
				else
					Notify(ply, 1, 4, string.format(LANGUAGE.rp_addowner_already_owns_door, ply:Nick()))
				end
			else
				Notify(ply, 1, 4, LANGUAGE.do_not_own_ent)
			end
		else
			Notify(ply, 1, 4, string.format(LANGUAGE.could_not_find, "player: "..tostring(args)))
		end
	end
	return ""
end
AddChatCommand("/addowner", AddDoorOwner)
AddChatCommand("/ao", AddDoorOwner)
