function Notify(ply, msgtype, len, msg)
	if not ValidEntity(ply) then return end
	umsg.Start("_Notify", ply)
		umsg.String(msg)
		umsg.Short(msgtype)
		umsg.Long(len)
	umsg.End()
end

function NotifyAll(msgtype, len, msg)
	for k, v in pairs(player.GetAll()) do
		Notify(v, msgtype, len, msg)
	end
end

function PrintMessageAll(msgtype, msg)
	for k, v in pairs(player.GetAll()) do
		v:PrintMessage(msgtype, msg)
	end
end

function TalkToRange(ply, PlayerName, Message, size)
	local ents = ents.FindInSphere(ply:EyePos(), size)
	local col = team.GetColor(ply:Team())
	for k, v in pairs(ents) do
		if v:IsPlayer() then	
			v:SendLua("chat.AddText(Color("..col.r..","..col.g..","..col.b.."), '"..PlayerName.."', Color(255,255,255,255), ': "..Message.."')")
		end
	end
end

function TalkToPerson(reciever, col1, text1, col2, text2, ...)
	local extra = {...}//TODO
	if not col2 then
		reciever:SendLua("chat.AddText(Color("..col1.r..","..col1.g..","..col1.b.."), '"..text1.."')")
		return
	end
	reciever:SendLua("chat.AddText(Color("..col1.r..","..col1.g..","..col1.b.."), '"..text1.."', Color("..col2.r..","..col2.g..","..col2.b.."), ': "..text2.."')")
end

function FindPlayer(info)
	local pls = player.GetAll()

	-- Find by Index Number (status in console)
	for k, v in pairs(pls) do
		if tonumber(info) == v:UserID() then
			return v
		end
	end

	-- Find by Steam ID
	for k, v in pairs(pls) do
		if info == v:SteamID() then
			return v
		end
	end

	-- Find by RP Name
	for k, v in pairs(pls) do
		if string.find(string.lower(v:GetNWString("rpname")), string.lower(tostring(info))) ~= nil then
			return v
		end
	end

	-- Find by Partial Nick
	for k, v in pairs(pls) do
		if string.find(string.lower(v:Name()), string.lower(tostring(info))) ~= nil then
			return v
		end
	end
	return nil
end

function FindPlayerBySID(sid)
	for k, v in pairs(player.GetAll()) do
		if v.SID == sid then return v end
	end
end
