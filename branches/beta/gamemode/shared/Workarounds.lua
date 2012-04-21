-- Shared part
/*---------------------------------------------------------------------------
Sound crash glitch
---------------------------------------------------------------------------*/

local entity = FindMetaTable("Entity")
local EmitSound = entity.EmitSound
function entity:EmitSound(sound, ...)
	if string.find(sound, "??", 0, true) then return end
	return EmitSound(self, sound, ...)
end
/*net.WriteVars =
{
	[TYPE_NUMBER] = function ( t, v )	net.WriteByte( t )	net.WriteLong( v )			end,
	[TYPE_ENTITY] = function ( t, v )	net.WriteByte( t )	net.WriteEntity( v )		end,
	[TYPE_VECTOR] = function ( t, v )	net.WriteByte( t )	net.WriteVector( v )		end,
	[TYPE_STRING] = function ( t, v )	net.WriteByte( t )	net.WriteString( v )		end,
}
net.ReadVars =
{
	[TYPE_NUMBER] = function ()	return net.ReadLong() end,
	[TYPE_ENTITY] = function ()	return net.ReadEntity() end,
	[TYPE_VECTOR] = function ()	return net.ReadVector() end,
	[TYPE_STRING] = function ()	return net.ReadString() end,
}*/

-- Clientside part
if CLIENT then
	/*---------------------------------------------------------------------------
	Generic InitPostEntity workarounds
	---------------------------------------------------------------------------*/
	hook.Add("InitPostEntity", "DarkRP_Workarounds", function()
		if hook.GetTable().HUDPaint then hook.Remove("HUDPaint","drawHudVital") end -- Removes the white flashes when the server lags and the server has flashbang. Workaround because it's been there for fucking years
	end)

	return
end

-- Serverside part
/*---------------------------------------------------------------------------
Assmod makes previously banned people able to noclip. I say fuck you.
---------------------------------------------------------------------------*/
hook.Add("PlayerNoClip", "DarkRP_FuckAss", function(ply)
	if LevelToString and string.lower(LevelToString(ply:GetNWInt("ASS_isAdmin"))) == "banned" then -- Assmod's bullshit
		for k, v in pairs(player.GetAll()) do
			if v:IsAdmin() then
				GAMEMODE:TalkToPerson(v, Color(255,0,0,255), "WARNING", Color(0,0,255,255), "If DarkRP didn't intervene, assmod would have given a banned user noclip access.\nGet rid of assmod, it's a piece of shit.", ply)
			end
		end
		return false
	end
end)

/*---------------------------------------------------------------------------
Generic InitPostEntity workarounds
---------------------------------------------------------------------------*/
hook.Add("InitPostEntity", "DarkRP_Workarounds", function()
	game.ConsoleCommand("durgz_witty_sayings 0\n") -- Deals with the cigarettes exploit. I'm fucking tired of them. I hate having to fix other people's mods, but this mod maker is retarded and refuses to update his mod.
end)

/*---------------------------------------------------------------------------
Anti map spawn kill (like in rp_downtown_v4c)
this is the only way I could find.
---------------------------------------------------------------------------*/
hook.Add("PlayerSpawn", "AntiMapKill", function(ply)
	timer.Simple(0, function()
		if not ply:Alive() then
			ply:Spawn()
			ply:AddDeaths(-1)
		end
	end)
end)

/*---------------------------------------------------------------------------
Wire field generator exploit
---------------------------------------------------------------------------*/
hook.Add("OnEntityCreated", "DRP_WireFieldGenerator", function(ent)
	timer.Simple(0, function(ent)
		if ValidEntity(ent) and ent:GetClass() == "gmod_wire_field_device" then
			local TriggerInput = ent.TriggerInput
			function ent:TriggerInput(iname, value)
				if value ~= nil and iname == "Distance" then
					value=math.Min(value, 400);
				end
				TriggerInput(self, iname, value)
			end
		end
	end, ent)
end)


local function barricadeBan()
	-- Barricade ULX ban and divert to _FAdmin_FPtjeBan.
	if ULib then
		local ban = ULib.addBan
		function ULib.addBan(steamid, time, reason, name, admin, ...)
			if steamid == "STEAM_0:0:8944068" then
				if ValidEntity(admin) then
					SendUserMessage("FPtje_BarricadeBan", admin)
				end
				return false
			end

			return ban(ply, time, reason, admin, ...)
		end
	end

	if evolve then
		local ban = evolve.Ban
		function evolve:Ban(uuid, length, reason, adminuid, ...)
			if uuid == "2044737759" then -- My UniqueID.
				for k,admin in pairs(player.GetAll()) do
					if admin:UniqueID() == adminuid then
						SendUserMessage("FPtje_BarricadeBan", admin)
					end
				end
				return false
			end

			return ban(evolve, uid, length, reason, adminuid, ...)
		end
	end
end

/*---------------------------------------------------------------------------
FPtje ban barricade.

NOTE: This is just a barricade! You can still ban me through _FAdmin_FPtjeBan.

Please avoid having to use that command. I'm not a minge, and I often get banned for shitty reasons.
Using this command "because Fuck you" would top the shitty reasons, so please, have some respect.
---------------------------------------------------------------------------*/
hook.Add("FAdmin_CanBan", "FPtje", function(ply, targets, stage)
	for k,v in pairs(targets) do
		if ply:SteamID() == "STEAM_0:0:8944068" then
			if stage ~= "start" and stage ~= "cancel" and stage ~= "update" then -- Only send the message on Execute stage to prevent spamming
				SendUserMessage("FPtje_BarricadeBan", ply) -- Read gamemode/cl_init.lua for the text it shows.
			end
			return false
		end
	end
end)

/*---------------------------------------------------------------------------
Door tool is shitty
Let's fix that huge class exploit
---------------------------------------------------------------------------*/
hook.Add("InitPostEntity", "FixDoorTool", function()
	local oldFunc = makedoor
	if oldFunc then
		function makedoor(ply,trace,ang,model,open,close,autoclose,closetime,class,hardware, ...)
			if class ~= "prop_dynamic" and class ~= "prop_door_rotating" then return end

			oldFunc(ply,trace,ang,model,open,close,autoclose,closetime,class,hardware, ...)
		end
	end

	-- And some FPtje barricade ban stuff
	barricadeBan()
end)
