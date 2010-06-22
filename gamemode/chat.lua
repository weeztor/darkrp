ChatCommands = {}

function AddChatCommand(cmd, callback, prefixconst)
	for k,v in pairs(ChatCommands) do 
		if cmd == v.cmd then return end
	end
	table.insert(ChatCommands, { cmd = cmd, callback = callback, prefixconst = prefixconst })
end

function RP_PlayerChat(ply, text)
	DB.Log(ply:SteamName().." ("..ply:SteamID().."): "..text )
	local callback = "" 
	local DoSayFunc
	for k, v in pairs(ChatCommands) do
		if string.lower(v.cmd) == string.Explode(" ", string.lower(text))[1] then
			callback, DoSayFunc = v.callback(ply, string.sub(text, string.len(v.cmd) + 2, string.len(text)))
			if callback == "" then 
				return "", "" , DoSayFunc
			end
			text = string.sub(text, string.len(v.cmd) + 2, string.len(text)).. " "
		end
	end
	if callback ~= "" then callback = (callback or "").." " end
	return text, callback, DoSayFunc
end

function RP_ActualDoSay(ply, text, callback)
	callback = callback or ""
	if text == "" then return "" end
	local col = team.GetColor(ply:Team())
	local col2 = Color(255,255,255,255)
	if not ply:Alive() then
		col2 = Color(255,200,200,255)
		col = col2
	end
	
	if GetConVarNumber("alltalk") == 1 then
		for k,v in pairs(player.GetAll()) do
			TalkToPerson(v, col, callback..ply:Name(), col2, text, ply)
		end
	else
		TalkToRange(ply, callback..ply:Name(), text, 250)
	end
	return "" 
end
