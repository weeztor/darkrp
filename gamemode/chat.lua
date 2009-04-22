ChatCommands = {}

function AddChatCommand(cmd, callback, prefixconst)
	for k,v in pairs(ChatCommands) do 
		if cmd == v.cmd then return end
	end
	table.insert(ChatCommands, { cmd = cmd, callback = callback, prefixconst = prefixconst })
end

function GM:PlayerSay(ply, text)
	self.BaseClass:PlayerSay(ply, text)

	for k, v in pairs(ChatCommands) do
		if string.lower(v.cmd) == string.Explode(" ", string.lower(text))[1] then
			return v.callback(ply, "" .. string.sub(text, string.len(v.cmd) + 2, string.len(text)))
		end
	end

	if ply:GetNWString("rpname") == ply:SteamName() or CfgVars["allowrpnames"] == 0 then
		return text
	else
		return "(" .. ply:Name() .. ") " .. text
	end
end

function GM:PlayerCanSeePlayersChat(text, teamonly, listener, speaker)
	if GetGlobalInt("alltalk") == 0 and listener:GetShootPos():Distance(speaker:GetShootPos()) < 250 then
		return true
	elseif GetGlobalInt("alltalk") == 0 then
		return false
	end
	return true
end
