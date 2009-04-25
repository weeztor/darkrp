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
	
	local col = team.GetColor(ply:Team())
	local col2 = Color(255,255,255,255)
	if not ply:Alive() then
		col2 = Color(200,200,200,255)
		col = col2
	end
	for k,v in pairs(player.GetAll()) do
		TalkToPerson(v, col, ply:Name(), col2, text)
	end
	return ""
end

function GM:PlayerCanSeePlayersChat(text, teamonly, listener, speaker)
	if GetGlobalInt("alltalk") == 0 and listener:GetShootPos():Distance(speaker:GetShootPos()) < 250 then
		return true
	elseif GetGlobalInt("alltalk") == 0 then
		return false
	end
	return true
end
