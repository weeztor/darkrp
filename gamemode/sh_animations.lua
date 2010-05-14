hook.Add("CalcMainActivity", "darkrp_animations", function(ply, velocity) -- Using hook.Add and not GM:CalcMainActivity to prevent animation problems
	-- Dropping weapons/money!
	if ply.anim_DroppingItem then
		ply:AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_ITEM_DROP)
		ply.anim_DroppingItem = nil
	end
	
	-- Giving items!
	if ply.anim_GivingItem then
		ply:AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_ITEM_GIVE)
		ply.anim_GivingItem = nil
	end
	
	
	if CLIENT and ply.SaidHi then
		ply:AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_SIGNAL_GROUP)
		ply.SaidHi = nil
	end
	
	if CLIENT and ply.ThrewPoop then
		ply:AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_ITEM_THROW)
		ply.ThrewPoop = nil
	end
	
	if CLIENT and ply.knocking then
		ply:AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_HL2MP_GESTURE_RANGE_ATTACK_FIST)
		ply.knocking = nil
	end
	
	if CLIENT and ply.usekeys then
		ply:AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_ITEM_PLACE)
		ply.usekeys = nil
	end
	
	if not SERVER then return end
	
	-- Hobo throwing poop!
	local Weapon = ply:GetActiveWeapon()
	if ply:Team() == TEAM_HOBO and not ply.ThrewPoop and ValidEntity(Weapon) and Weapon:GetClass() == "weapon_bugbait" and ply:KeyDown(IN_ATTACK) then
		ply.ThrewPoop = true
		ply:AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_ITEM_THROW)
		
		
		local RP = RecipientFilter()
		RP:AddAllPlayers()
		
		umsg.Start("anim_throwpoop", RP) 
			umsg.Entity(ply)
		umsg.End()
	elseif ply.ThrewPoop and not ply:KeyDown(IN_ATTACK) then
		ply.ThrewPoop = nil
	end
	
	-- saying hi to a player
	if not ply.SaidHi and ValidEntity(Weapon) and Weapon:GetClass() == "weapon_physgun" and ply:KeyDown(IN_ATTACK) then
		local ent = ply:GetEyeTrace().Entity
		if ValidEntity(ent) and ent:IsPlayer() then
			ply.SaidHi = true
			ply:AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_SIGNAL_GROUP)
			
			local RP = RecipientFilter()
			RP:AddAllPlayers()
			
			umsg.Start("anim_sayhi", RP) 
				umsg.Entity(ply)
			umsg.End()
		end
	elseif ply.SaidHi and not ply:KeyDown(IN_ATTACK) then
		ply.SaidHi = nil
	end
end)

if SERVER then return end

local function DropItem(um)
	local ply = um:ReadEntity()
	if not ValidEntity(ply) then return end
	
	ply.anim_DroppingItem = true
end
usermessage.Hook("anim_dropitem", DropItem)

local function GiveItem(um)
	local ply = um:ReadEntity()
	if not ValidEntity(ply) then return end
	
	ply.anim_GivingItem = true
end
usermessage.Hook("anim_giveitem", GiveItem)

local function ThrowPoop(um)
	local ply = um:ReadEntity()
	if not ValidEntity(ply) then return end
	
	ply.ThrewPoop = true
end
usermessage.Hook("anim_throwpoop", ThrowPoop)

local function PhysgunHi(um)
	local ply = um:ReadEntity()
	if not ValidEntity(ply) then return end
	
	ply.SaidHi = true
end
usermessage.Hook("anim_sayhi", PhysgunHi)

local function KeysAnims(um)
	local ply = um:ReadEntity()
	if not ValidEntity(ply) then return end
	local Type = um:ReadString()
	ply[Type] = true
end
usermessage.Hook("anim_keys", KeysAnims)