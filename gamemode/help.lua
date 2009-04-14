HELP_CATEGORY_CHATCMD = 1
HELP_CATEGORY_CONCMD = 2
HELP_CATEGORY_ADMINTOGGLE = 3
HELP_CATEGORY_ADMINCMD = 4

HelpCategories = { }
HelpLabels = { }

function AddHelpCategory(id, name)
	if id < 0 then
		id = #HelpCatagories + 1
	end

	umsg.Start("AddHelpCategory")
		umsg.Short(id)
		umsg.String(name)
	umsg.End()

	table.insert(HelpCategories, { id = id, name = name })
	return id
end

function ChangeHelpLabel(id, text)
	umsg.Start("ChangeHelpLabel")
		umsg.Short(id)
		umsg.String(text)
	umsg.End()

	for k, v in pairs(HelpLabels) do
		if v.id == id then
			v.text = text
			return
		end
	end
end

function RequestAllToggleCommands(ply,cmd,args)
	for k,v in pairs(ToggleCmds) do
		local found = false
		for a,b in pairs(HelpLabels) do 
			if string.find(b.text, k) then
				found = b.text
			end
		end
		
		if found then
			umsg.Start("SendAllToggleCommands", ply)
				umsg.String(k)
				umsg.String(found)
				if not v.global then
					if CfgVars[v.var] then
						umsg.Short(CfgVars[v.var])
					elseif CfgVars[string.sub(k, 4)] then
						umsg.Short(CfgVars[string.sub(k, 4)])
					end
				else
					umsg.Short(GetGlobalInt(v.var))
				end
			umsg.End()
		end
	end
end
concommand.Add("rp_RequestAllToggleCommands", RequestAllToggleCommands)

function RequestAllValueCommands(ply,cmd,args)
	for k,v in pairs(ValueCmds) do
		local found = false
		for a,b in pairs(HelpLabels) do 
			if string.find(b.text, k) then
				found = b.text
			end
		end
		
		if found then
			umsg.Start("SendAllValueCommands", ply)
				umsg.String(k)
				umsg.String(found)
				if not v.global then
					if CfgVars[v.var] then
						umsg.Short(CfgVars[v.var])
					elseif CfgVars[string.sub(k, 4)] then
						umsg.Short(CfgVars[string.sub(k, 4)])
					end
				else
					umsg.Short(GetGlobalInt(v.var))
				end
			umsg.End()
		end
	end
end
concommand.Add("rp_RequestAllValueCommands", RequestAllValueCommands)

function AddHelpLabel(id, category, text, constant)
	if id < 0 then
		id = #HelpLabels + 1
	end

	for k, v in pairs(HelpLabels) do
		if v.id == id then
			ChangeHelpLabel(id, text)
			return
		end
	end

	umsg.Start("AddHelpLabel")
		umsg.Short(id)
		umsg.Short(category)
		umsg.String(text)
		umsg.Short(constant or 0)
	umsg.End()

	table.insert(HelpLabels, { id = id, category = category, text = text, constant = (constant or 0) })
end

function NetworkHelpLabels(ply)
	if not ValidEntity(ply) then timer.Simple(1, NetworkHelpLabels, ply) return end
	local function tNetworkHelpCategories(ply, i)
		if not ValidEntity(ply) then return end
		umsg.Start("AddHelpCategory", ply)
			umsg.Short(i.id)
			umsg.String(i.name)
		umsg.End()
	end

	local function tNetworkHelpLabels(ply, i)
		if not ValidEntity(ply) then return end
		umsg.Start("AddHelpLabel", ply)
			umsg.Short(i.id)
			umsg.Short(i.category)
			umsg.String(i.text)
			umsg.Short(i.constant)
		umsg.End()
	end

	local n = 0
	for k, v in pairs(HelpCategories) do
		timer.Simple(n * .02, tNetworkHelpCategories, ply, v)
		n = n + 1
	end

	n = 0
	for k, v in pairs(HelpLabels) do
		timer.Simple(n * .02, tNetworkHelpLabels, ply, v)
		n = n + 1
	end
end

function GenerateChatCommandHelp()
	local p = GetGlobalString("cmdprefix")

	AddHelpLabel(1000, HELP_CATEGORY_CHATCMD, p .. "help - Bring up this menu")
	AddHelpLabel(1100, HELP_CATEGORY_CHATCMD, p .. "job <Job Name> - Set a custom job")
	AddHelpLabel(1200, HELP_CATEGORY_CHATCMD, p .. "w <Message> - Whisper a message")
	AddHelpLabel(1300, HELP_CATEGORY_CHATCMD, p .. "y <Message> - Yell a message")
	AddHelpLabel(1350, HELP_CATEGORY_CHATCMD, p .. "g <Message> - Group only message")
	AddHelpLabel(1400, HELP_CATEGORY_CHATCMD, "//, or /a, or /ooc - Out of Character speak", 1)
	AddHelpLabel(1500, HELP_CATEGORY_CHATCMD, "/x to close a help dialog", 1)
	AddHelpLabel(2700, HELP_CATEGORY_CHATCMD, p .. "pm <Name/Partial Name> <Message> - Send another player a PM.")
	AddHelpLabel(2500, HELP_CATEGORY_CHATCMD, "")
	AddHelpLabel(2650, HELP_CATEGORY_CHATCMD, "Letters - Press use key to read a letter.  Look away and press use key again to stop reading a letter.")
	AddHelpLabel(2550, HELP_CATEGORY_CHATCMD, p .. "write <Message> - Write a letter in handwritten font. Use // to go down a line.")
	AddHelpLabel(2600, HELP_CATEGORY_CHATCMD, p .. "type <Message> - Type a letter in computer font.  Use // to go down a line.")
	AddHelpLabel(1450, HELP_CATEGORY_CHATCMD, "")
	AddHelpLabel(1500, HELP_CATEGORY_CHATCMD, p .. "give <Amount> - Give a money amount")
	AddHelpLabel(1600, HELP_CATEGORY_CHATCMD, p .. "moneydrop or dropmoney <Amount> - Drop a money amount")
	AddHelpLabel(1650, HELP_CATEGORY_CHATCMD, "")
	AddHelpLabel(1700, HELP_CATEGORY_CHATCMD, p .. "title <Name> - Give a door you own, a title")
	AddHelpLabel(1800, HELP_CATEGORY_CHATCMD, p .. "addowner or ao <Name> - Allow another to player to own your door")
	AddHelpLabel(1825, HELP_CATEGORY_CHATCMD, p .. "removeowner <Name> - Remove an owner from your door")
	AddHelpLabel(1850, HELP_CATEGORY_CHATCMD, "")
	AddHelpLabel(1900, HELP_CATEGORY_CHATCMD, p .. "votecop - Vote to be a Cop")
	AddHelpLabel(2750, HELP_CATEGORY_CHATCMD, p .. "votemayor - Vote to be Mayor")
	AddHelpLabel(2100, HELP_CATEGORY_CHATCMD, p .. "citizen - Become a Citizen")
	AddHelpLabel(2111, HELP_CATEGORY_CHATCMD, p .. "hobo - Become a fucking hobo")
	AddHelpLabel(2000, HELP_CATEGORY_CHATCMD, p .. "mayor - Become Mayor if you're on the admin's Mayor list")
	AddHelpLabel(2200, HELP_CATEGORY_CHATCMD, p .. "cp - Become a Combine if you're on the admin's Cop list")
	AddHelpLabel(2250, HELP_CATEGORY_CHATCMD, "")
	AddHelpLabel(2300, HELP_CATEGORY_CHATCMD, p .. "cr <Message> - Request the CP's assistance")
end
