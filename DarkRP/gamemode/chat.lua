ChatCommands = {}

function AddChatCommand(cmd, callback, prefixconst)
	table.insert(ChatCommands, { cmd = cmd, callback = callback, prefixconst = prefixconst })
	//if callback == OOC() or callback == Whisper() then return end
	//concommand.Add(cmd, callback)
end

function GM:PlayerSay(ply, text)
	self.BaseClass:PlayerSay(ply, text)

	for k, v in pairs(ChatCommands) do
		if v.cmd == string.Explode(" ", string.lower(text))[1] then
			return v.callback(ply, "" .. string.sub(text, string.len(v.cmd) + 2, string.len(text)))
		end
	end

	if GetGlobalInt("alltalk") == 0 then
		TalkToRange(ply:Name() .. ": " .. text, ply:GetPos(), 250)
		return ""
	end
	
	if ply:GetNWString("rpname") == ply:SteamName() then
		return text
	else
		return "(" .. ply:Name() .. ") " .. text
	end
end
