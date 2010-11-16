local function PM(ply, cmd, args)
	if not args[2] then return end
	
	local targets = FAdmin.FindPlayer(args[1])
	if #targets == 1 and not ValidEntity(targets[1]) then
		FAdmin.Messages.SendMessage(ply, 1, "Player not found")
		return
	end
	
	local text = table.concat(args, " ", 2, #args)
	local RP = RecipientFilter()
	
	for _, target in pairs(targets) do
		if ValidEntity(target) then
			RP:AddPlayer(target)
			if ply ~= target then RP:AddPlayer(ply) end
			umsg.Start("FAdmin_ReceivePM", RP)
				umsg.Entity(ply)
				umsg.String(text)
			umsg.End()
		end
	end
end

local function ToAdmins(ply, cmd, args)
	if not args[1] then return end
	
	local text = table.concat(args, " ")
	local RP = RecipientFilter()
	
	RP:AddPlayer(ply)
	for k,v in pairs(player.GetAll()) do
		if v:IsAdmin() then
			RP:AddPlayer(ply)
		end
	end
	
	umsg.Start("FAdmin_ReceiveAdminMessage", RP)
		umsg.Entity(ply)
		umsg.String(text)
	umsg.End()
end

FAdmin.StartHooks["Chatting"] = function()
	FAdmin.Commands.AddCommand("pm", PM)
	FAdmin.Commands.AddCommand("adminhelp", ToAdmins)
end