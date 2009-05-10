ChatCommands = {}

function AddChatCommand(cmd, callback, prefixconst)
	for k,v in pairs(ChatCommands) do 
		if cmd == v.cmd then return end
	end
	table.insert(ChatCommands, { cmd = cmd, callback = callback, prefixconst = prefixconst })
end

function RP_PlayerChat(ply, text)
	print(ply, text)
	local callback = "" 
	for k, v in pairs(ChatCommands) do
		if string.lower(v.cmd) == string.Explode(" ", string.lower(text))[1] then
			callback = v.callback(ply, string.sub(text, string.len(v.cmd) + 2, string.len(text)))
			if callback == "" then return "" end
			text = string.sub(text, string.len(v.cmd) + 2, string.len(text)).. " "
		end
	end
	if callback ~= "" then callback = callback.." " end
	
	local col = team.GetColor(ply:Team())
	local col2 = Color(255,255,255,255)
	if not ply:Alive() then
		col2 = Color(255,200,200,255)
		col = col2
	end
	
	if GetGlobalInt("alltalk") == 1 then
		for k,v in pairs(player.GetAll()) do
			TalkToPerson(v, col, callback..ply:Name(), col2, text, ply)
		end
	else
		TalkToRange(ply, callback..ply:Name(), text, 250)
	end
	return ""
end
