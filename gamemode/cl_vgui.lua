local VoteVGUI = {}
local QuestionVGUI = {}
local PanelNum = 0
local LetterWritePanel

local function MsgDoVote(msg)
	local question = msg:ReadString()
	local voteid = msg:ReadString()
	local timeleft = msg:ReadFloat()
	if timeleft == 0 then
		timeleft = 100
	end
	local OldTime = CurTime()
	if string.find(voteid, LocalPlayer():EntIndex()) then return end --If it's about you then go away

	LocalPlayer():EmitSound("Town.d1_town_02_elevbell1", 100, 100)
	local panel = vgui.Create("DFrame")
	panel:SetPos(3 + PanelNum, ScrH() / 2 - 50)
	panel:SetTitle("Vote")
	panel:SetSize(140, 140)
	panel:SetSizable(false)
	panel.btnClose:SetVisible(false)
	panel:SetDraggable(false)
	function panel:Close()
		PanelNum = PanelNum - 140
		VoteVGUI[voteid .. "vote"] = nil
		
		local num = 0
		for k,v in SortedPairs(VoteVGUI) do
			v:SetPos(num, ScrH() / 2 - 50)
			num = num + 140
		end
		
		for k,v in SortedPairs(QuestionVGUI) do
			v:SetPos(num, ScrH() / 2 - 50)
			num = num + 300
		end
		self:Remove()
	end
	
	function panel:Think()
		self:SetTitle("Time: ".. tostring(math.Clamp(math.ceil(timeleft - (CurTime() - OldTime)), 0, 9999)))
		if timeleft - (CurTime() - OldTime) <= 0 then 
			panel:Close()
		end
	end

	panel:SetKeyboardInputEnabled(false)
	panel:SetMouseInputEnabled(true)
	panel:SetVisible(true)

	local label = vgui.Create("Label")
	label:SetParent(panel)
	label:SetPos(5, 30)
	label:SetSize(180, 40)
	label:SetText(question)
	label:SetVisible(true)

	local divider = vgui.Create("Divider")
	divider:SetParent(panel)
	divider:SetPos(2, 80)
	divider:SetSize(180, 2)
	divider:SetVisible(true)

	local ybutton = vgui.Create("Button")
	ybutton:SetParent(panel)
	ybutton:SetPos(25, 100)
	ybutton:SetSize(40, 20)
	ybutton:SetCommand("!")
	ybutton:SetText("Yes")
	ybutton:SetVisible(true)
	ybutton.DoClick = function()
		LocalPlayer():ConCommand("vote " .. voteid .. " 1\n")
		panel:Close()
	end

	local nbutton = vgui.Create("Button")
	nbutton:SetParent(panel)
	nbutton:SetPos(70, 100)
	nbutton:SetSize(40, 20)
	nbutton:SetCommand("!")
	nbutton:SetText("No")
	nbutton:SetVisible(true)
	nbutton.DoClick = function()
		LocalPlayer():ConCommand("vote " .. voteid .. " 2\n")
		panel:Close()
	end

	PanelNum = PanelNum + 140
	VoteVGUI[voteid .. "vote"] = panel
	panel:SetSkin("DarkRP")
end
usermessage.Hook("DoVote", MsgDoVote)

local function KillVoteVGUI(msg)
	local id = msg:ReadString()
	
	if VoteVGUI[id .. "vote"] and VoteVGUI[id .. "vote"]:IsValid() then
		VoteVGUI[id.."vote"]:Close()

	end
end
usermessage.Hook("KillVoteVGUI", KillVoteVGUI)

local function MsgDoQuestion(msg)
	local question = msg:ReadString()
	local quesid = msg:ReadString()
	local timeleft = msg:ReadFloat()
	if timeleft == 0 then
		timeleft = 100
	end
	local OldTime = CurTime()
	LocalPlayer():EmitSound("Town.d1_town_02_elevbell1", 100, 100)
	local panel = vgui.Create("DFrame")
	panel:SetPos(3 + PanelNum, ScrH() / 2 - 50)--Times 140 because if the quesion is the second screen, the first screen is always a vote screen.
	panel:SetSize(300, 140)
	panel:SetSizable(false)
	panel.btnClose:SetVisible(false)
	panel:SetKeyboardInputEnabled(false)
	panel:SetMouseInputEnabled(true)
	panel:SetVisible(true)
	
	function panel:Close()
		PanelNum = PanelNum - 300
		QuestionVGUI[quesid .. "ques"] = nil
		local num = 0
		for k,v in SortedPairs(VoteVGUI) do
			v:SetPos(num, ScrH() / 2 - 50)
			num = num + 140
		end
		
		for k,v in SortedPairs(QuestionVGUI) do
			v:SetPos(num, ScrH() / 2 - 50)
			num = num + 300
		end
		
		self:Remove()
	end
	
	function panel:Think()
		self:SetTitle("Time: ".. tostring(math.Clamp(math.ceil(timeleft - (CurTime() - OldTime)), 0, 9999)))
		if timeleft - (CurTime() - OldTime) <= 0 then 
			panel:Close()
		end
	end

	local label = vgui.Create("DLabel")
	label:SetParent(panel)
	label:SetPos(5, 30)
	label:SetSize(380, 40)
	label:SetText(question)
	label:SetVisible(true)

	local divider = vgui.Create("Divider")
	divider:SetParent(panel)
	divider:SetPos(2, 80)
	divider:SetSize(380, 2)
	divider:SetVisible(true)

	local ybutton = vgui.Create("DButton")
	ybutton:SetParent(panel)
	ybutton:SetPos(/*147*/105, 100)
	ybutton:SetSize(40, 20)
	ybutton:SetText("Yes")
	ybutton:SetVisible(true)
	ybutton.DoClick = function()
		LocalPlayer():ConCommand("ans " .. quesid .. " 1\n")
		panel:Close()
	end
	
	local nbutton = vgui.Create("DButton")
	nbutton:SetParent(panel)
	nbutton:SetPos(155, 100)
	nbutton:SetSize(40, 20)
	nbutton:SetText("No")
	nbutton:SetVisible(true)
	nbutton.DoClick = function()
		LocalPlayer():ConCommand("ans " .. quesid .. " 2\n")
		panel:Close()
	end

	PanelNum = PanelNum + 300
	QuestionVGUI[quesid .. "ques"] = panel
	
	panel:SetSkin("DarkRP")
end
usermessage.Hook("DoQuestion", MsgDoQuestion)

local function KillQuestionVGUI(msg)
	local id = msg:ReadString()

	if QuestionVGUI[id .. "ques"] and QuestionVGUI[id .. "ques"]:IsValid() then
		QuestionVGUI[id .. "ques"]:Close()
	end
end
usermessage.Hook("KillQuestionVGUI", KillQuestionVGUI)

local function DoVoteAnswerQuestion(ply, cmd, args)
	if not args[1] then return end
	
	local vote = 2
	if tonumber(args[1]) == 1 or string.lower(args[1]) == "yes" or string.lower(args[1]) == "true" then vote = 1 end
	
	for k,v in pairs(VoteVGUI) do
		if ValidPanel(v) then
			local ID = string.sub(k, 1, -5)
			VoteVGUI[k]:Close()
			RunConsoleCommand("vote", ID, vote)
			return
		end
	end
	
	for k,v in pairs(QuestionVGUI) do
		if ValidPanel(v) then
			local ID = string.sub(k, 1, -5)
			QuestionVGUI[k]:Close()
			RunConsoleCommand("ans", ID, vote)
			return
		end
	end
end
concommand.Add("rp_vote", DoVoteAnswerQuestion)

local function DoLetter(msg)
	LetterWritePanel = vgui.Create("Frame")
	LetterWritePanel:SetPos(ScrW() / 2 - 75, ScrH() / 2 - 100)
	LetterWritePanel:SetSize(150, 200)
	LetterWritePanel:SetMouseInputEnabled(true)
	LetterWritePanel:SetKeyboardInputEnabled(true)
	LetterWritePanel:SetVisible(true)
end
usermessage.Hook("DoLetter", DoLetter)

local F4Menu  
local F4MenuTabs
local F4Tabs
local hasReleasedF4 = false
local function ChangeJobVGUI()
	if not F4Menu or not F4Menu:IsValid() then
		F4Menu = vgui.Create("DFrame")
		F4Menu:SetSize(770, 580)
		F4Menu:Center()
		F4Menu:SetVisible( true )
		F4Menu:MakePopup( )
		F4Menu:SetTitle("Options menu")
		F4Tabs = {MoneyTab(), JobsTab(), EntitiesTab(), RPHUDTab()}
		if LocalPlayer():IsAdmin() then
			table.insert(F4Tabs, RPAdminTab())
		end
		if LocalPlayer():IsSuperAdmin() then
			table.insert(F4Tabs, RPLicenseWeaponsTab())
		end
		F4Menu:SetSkin("DarkRP")
	else
		F4Menu:SetVisible(true)
		F4Menu:SetSkin("DarkRP")
	end
	
	hasReleasedF4 = false
	
	function F4Menu:Think()
		
		if input.IsKeyDown(KEY_F4) and hasReleasedF4 then
			self:Close()
		elseif not input.IsKeyDown(KEY_F4) then
			hasReleasedF4 = true
		end
		if (!self.Dragging) then return end 
		local x = gui.MouseX() - self.Dragging[1] 
		local y = gui.MouseY() - self.Dragging[2] 
		x = math.Clamp( x, 0, ScrW() - self:GetWide() ) 
		y = math.Clamp( y, 0, ScrH() - self:GetTall() ) 
		self:SetPos( x, y )
	end
	
	if not F4MenuTabs or not F4MenuTabs:IsValid() then
		F4MenuTabs = vgui.Create( "DPropertySheet", F4Menu)
		F4MenuTabs:SetPos(5, 25)
		F4MenuTabs:SetSize(760, 550)
		--The tabs: Look in showteamtabs.lua for more info
		F4MenuTabs:AddSheet("Money/Commands", F4Tabs[1], "gui/silkicons/plugin", false, false)
		F4MenuTabs:AddSheet("Jobs", F4Tabs[2], "gui/silkicons/arrow_refresh", false, false)
		F4MenuTabs:AddSheet("Entities/weapons", F4Tabs[3], "gui/silkicons/application_view_tile", false, false)
		F4MenuTabs:AddSheet("HUD", F4Tabs[4], "gui/silkicons/user", false, false)
		if LocalPlayer():IsAdmin() or LocalPlayer().DarkRPVars.Privadmin then
			F4MenuTabs:AddSheet("Admin", F4Tabs[5], "gui/silkicons/wrench", false, false)
		end
		if LocalPlayer():IsSuperAdmin() then
			F4MenuTabs:AddSheet("License weapons", F4Tabs[6], "gui/silkicons/wrench", false, false)
		end
	end

	for _, panel in pairs(F4Tabs) do panel:Update() panel:SetSkin("DarkRP") end

 	function F4Menu:Close()
		F4Menu:SetVisible(false)
		F4Menu:SetSkin("DarkRP")
	end 

	F4Menu:SetSkin("DarkRP")
end
usermessage.Hook("ChangeJobVGUI", ChangeJobVGUI)

local KeyFrameVisible = false
local function KeysMenu(um)
	local Vehicle = um:ReadBool()
	if KeyFrameVisible then return end
	local trace = LocalPlayer():GetEyeTrace()
	local Frame = vgui.Create("DFrame")
	KeyFrameVisible = true
	Frame:SetSize(200, 470)
	Frame:Center()
	Frame:SetVisible(true)
	Frame:MakePopup()
	
	function Frame:Think()
		local ent = LocalPlayer():GetEyeTrace().Entity
		if not ValidEntity(ent) or (not ent:IsDoor() and not string.find(ent:GetClass(), "vehicle")) or ent:GetPos():Distance(LocalPlayer():GetPos()) > 200 then
			self:Close()
		end
		if (!self.Dragging) then return end  
		local x = gui.MouseX() - self.Dragging[1] 
		local y = gui.MouseY() - self.Dragging[2] 
		x = math.Clamp( x, 0, ScrW() - self:GetWide() ) 
		y = math.Clamp( y, 0, ScrH() - self:GetTall() ) 
		self:SetPos( x, y ) 
	end
	local Entiteh = "door"
	if Vehicle then
		Entiteh = "vehicle"
	end
	Frame:SetTitle(Entiteh .. " options")
	
	function Frame:Close()
		KeyFrameVisible = false
		self:SetVisible( false )
		self:Remove()
	end
	
	if trace.Entity:OwnedBy(LocalPlayer()) then
		if not trace.Entity.DoorData then return end -- Don't open the menu when the door settings are not loaded yet
		local Owndoor = vgui.Create("DButton", Frame)
		Owndoor:SetPos(10, 30)
		Owndoor:SetSize(180, 100)
		Owndoor:SetText("Sell " .. Entiteh)
		Owndoor.DoClick = function() RunConsoleCommand("say", "/toggleown") Frame:Close() end
		
		local AddOwner = vgui.Create("DButton", Frame)
		AddOwner:SetPos(10, 140)
		AddOwner:SetSize(180, 100)
		AddOwner:SetText("Add owner")			
		AddOwner.DoClick = function()
			local menu = DermaMenu()
			for k,v in pairs(player.GetAll()) do
				if not trace.Entity:OwnedBy(v) and not trace.Entity:AllowedToOwn(v) then
					menu:AddOption(v:Nick(), function() LocalPlayer():ConCommand("say /ao ".. v:UserID()) end)
				end
			end
			if #menu.Panels == 0 then
				menu:AddOption("Noone available", function() end)
			end
			menu:Open()
		end
		
		local RemoveOwner = vgui.Create("DButton", Frame)
		RemoveOwner:SetPos(10, 250)
		RemoveOwner:SetSize(180, 100)
		RemoveOwner:SetText("Remove owner")			
		RemoveOwner.DoClick = function()
			local menu = DermaMenu()
			for k,v in pairs(player.GetAll()) do
				if (trace.Entity:OwnedBy(v) and not trace.Entity:IsMasterOwner(v)) or trace.Entity:AllowedToOwn(v) then
					menu:AddOption(v:Nick(), function() LocalPlayer():ConCommand("say /ro ".. v:UserID()) end)
				end
			end
			if #menu.Panels == 0 then
				menu:AddOption("Noone available", function() end)
			end
			menu:Open()
		end
		
		local DoorTitle = vgui.Create("DButton", Frame)
		DoorTitle:SetPos(10, 360)
		DoorTitle:SetSize(180, 100)
		DoorTitle:SetText("Set "..Entiteh.." title")
		if not trace.Entity:IsMasterOwner(LocalPlayer()) then
			RemoveOwner.m_bDisabled = true
		end
		DoorTitle.DoClick = function()
			Derma_StringRequest("Set door title", "Set the title of the "..Entiteh.." you're looking at", "", function(text) LocalPlayer():ConCommand("say /title ".. text) Frame:Close() end, function() end, "OK!", "CANCEL!")
		end
		
		if LocalPlayer():IsSuperAdmin() and not Vehicle then
			Frame:SetSize(200, Frame:GetTall() + 110)
			local SetCopsOnly = vgui.Create("DButton", Frame)
			SetCopsOnly:SetPos(10, Frame:GetTall() - 110)
			SetCopsOnly:SetSize(180, 100)
			SetCopsOnly:SetText("(Re)set door group")
			SetCopsOnly.DoClick = function() 
				local menu = DermaMenu()
				menu:AddOption("No group", function() RunConsoleCommand("say", "/togglegroupownable") Frame:Close() end)
				for k,v in pairs(RPExtraTeamDoors) do
					menu:AddOption(k, function() RunConsoleCommand("say", "/togglegroupownable "..k) Frame:Close() end)
				end
				menu:Open()
			end
		end	
	elseif not trace.Entity:OwnedBy(LocalPlayer()) and trace.Entity:IsOwnable() and not trace.Entity:IsOwned() and not trace.Entity.DoorData.NonOwnable then
		if not trace.Entity.DoorData.GroupOwn then
			Frame:SetSize(200, 140)
			local Owndoor = vgui.Create("DButton", Frame)
			Owndoor:SetPos(10, 30)
			Owndoor:SetSize(180, 100)
			Owndoor:SetText("Buy " .. Entiteh)
			Owndoor.DoClick = function() RunConsoleCommand("say", "/toggleown") Frame:Close() end
		elseif not LocalPlayer():IsSuperAdmin() then
			Frame:Close()
		end
		if LocalPlayer():IsSuperAdmin() then
			if trace.Entity.DoorData.GroupOwn then
				Frame:SetSize(200, 250)
			else
				Frame:SetSize(200, 360)
			end
			local DisableOwnage = vgui.Create("DButton", Frame)
			DisableOwnage:SetPos(10, Frame:GetTall() - 220)
			DisableOwnage:SetSize(180, 100)
			DisableOwnage:SetText("Disallow ownership")
			DisableOwnage.DoClick = function() Frame:Close() RunConsoleCommand("say", "/toggleownable") end
			
			local SetCopsOnly = vgui.Create("DButton", Frame)
			SetCopsOnly:SetPos(10, Frame:GetTall() - 110)
			SetCopsOnly:SetSize(180, 100)
			SetCopsOnly:SetText("(Re)set door group")
			SetCopsOnly.DoClick = function() 
				local menu = DermaMenu()
				menu:AddOption("No group", function() RunConsoleCommand("say", "/togglegroupownable") if ValidPanel(Frame) then Frame:Close()  end end)
				for k,v in pairs(RPExtraTeamDoors) do
					menu:AddOption(k, function() RunConsoleCommand("say", "/togglegroupownable "..k) if ValidPanel(Frame) then Frame:Close()  end end)
				end
				menu:Open()
			end
		elseif not trace.Entity.DoorData.GroupOwn then
			RunConsoleCommand("say", "/toggleown")
			Frame:Close()
			KeyFrameVisible = true
			timer.Simple(0.3, function() KeyFrameVisible = false end)
		end
	elseif not trace.Entity:OwnedBy(LocalPlayer()) and trace.Entity:AllowedToOwn(LocalPlayer()) then
		Frame:SetSize(200, 140)
		local Owndoor = vgui.Create("DButton", Frame)
		Owndoor:SetPos(10, 30)
		Owndoor:SetSize(180, 100)
		Owndoor:SetText("Co-own " .. Entiteh)
		Owndoor.DoClick = function() RunConsoleCommand("say", "/toggleown") Frame:Close() end
		
		if LocalPlayer():IsSuperAdmin() then
			Frame:SetSize(200, Frame:GetTall() + 110)
			local SetCopsOnly = vgui.Create("DButton", Frame)
			SetCopsOnly:SetPos(10, Frame:GetTall() - 110)
			SetCopsOnly:SetSize(180, 100)
			SetCopsOnly:SetText("(Re)set door group")
			SetCopsOnly.DoClick = function() 
				local menu = DermaMenu()
				menu:AddOption("No group", function() RunConsoleCommand("say", "/togglegroupownable") Frame:Close() end)
				for k,v in pairs(RPExtraTeamDoors) do
					menu:AddOption(k, function() RunConsoleCommand("say", "/togglegroupownable "..k) Frame:Close() end)
				end
				menu:Open() 
			end
		else
			RunConsoleCommand("say", "/toggleown")
			Frame:Close()
			KeyFrameVisible = true
			timer.Simple(0.3, function() KeyFrameVisible = false end)
		end	
	elseif LocalPlayer():IsSuperAdmin() and trace.Entity.DoorData.NonOwnable then
		Frame:SetSize(200, 250)
		local EnableOwnage = vgui.Create("DButton", Frame)
		EnableOwnage:SetPos(10, 30)
		EnableOwnage:SetSize(180, 100)
		EnableOwnage:SetText("Allow ownership")
		EnableOwnage.DoClick = function() Frame:Close() RunConsoleCommand("say", "/toggleownable") end
		
		local DoorTitle = vgui.Create("DButton", Frame)
		DoorTitle:SetPos(10, Frame:GetTall() - 110)
		DoorTitle:SetSize(180, 100)
		DoorTitle:SetText("Set "..Entiteh.." title")
		DoorTitle.DoClick = function()
			Derma_StringRequest("Set door title", "Set the title of the "..Entiteh.." you're looking at", "", function(text) LocalPlayer():ConCommand("say /title ".. text) Frame:Close() end, function() end, "OK!", "CANCEL!")
		end
	elseif LocalPlayer():IsSuperAdmin() and not trace.Entity:OwnedBy(LocalPlayer()) and trace.Entity:IsOwned() and not trace.Entity:AllowedToOwn(LocalPlayer()) then
		Frame:SetSize(200, 250)
		local DisableOwnage = vgui.Create("DButton", Frame)
		DisableOwnage:SetPos(10, 30)
		DisableOwnage:SetSize(180, 100)
		DisableOwnage:SetText("Disallow ownership")
		DisableOwnage.DoClick = function() Frame:Close() RunConsoleCommand("say", "/toggleownable") end
		
		local SetCopsOnly = vgui.Create("DButton", Frame)
		SetCopsOnly:SetPos(10, Frame:GetTall() - 110)
		SetCopsOnly:SetSize(180, 100)
		SetCopsOnly:SetText("(Re)set door group")
			SetCopsOnly.DoClick = function() 
				local menu = DermaMenu()
				menu:AddOption("No group", function() RunConsoleCommand("say", "/togglegroupownable") Frame:Close() end)
				for k,v in pairs(RPExtraTeamDoors) do
					menu:AddOption(k, function() RunConsoleCommand("say", "/togglegroupownable "..k) Frame:Close() end)
				end
				menu:Open()
			end
	else
		Frame:Close()
	end
	
	Frame:SetSkin("DarkRP")
end
usermessage.Hook("KeysMenu", KeysMenu)

--Begin Client-side trade system - By Eusion.
local TradeMenus = {}
local function TradeMenuClient(handler, id, encoded, decoded)
	local items = decoded
	
	local TradeFrame = vgui.Create("DFrame")
	TradeFrame:SetSize((#items * 64)+20, 110)
	TradeFrame:Center()
	TradeFrame:SetTitle("Initialize a trade")
	TradeFrame:MakePopup()
	TradeFrame:SetSkin("DarkRP")
	
	local ItemsForm = vgui.Create("DPanelList", TradeFrame)
	ItemsForm:SetSize((#items * 64), 64)
	ItemsForm:SetPos(10, 31)
	ItemsForm:SetSpacing(0)
	ItemsForm:EnableHorizontal(true)
	ItemsForm:EnableVerticalScrollbar(true)
	
	for k, v in pairs(items) do
		if ValidEntity(v) then
			local k = vgui.Create("SpawnIcon")
			k:SetModel(v:GetModel())
			k.DoClick = function()
				LocalPlayer():ConCommand("rp_tradeitem " .. v:EntIndex())
				TradeFrame:Close()
				CloseDermaMenus()
			end
			k:SetToolTip(v:GetClass())
			k:SetIconSize(64)
			ItemsForm:AddItem(k)
		end
	end
end
datastream.Hook("darkrp_trade", TradeMenuClient)

local function TradeMenuRecipient(um)
	local client = um:ReadEntity()
	local recipient = um:ReadEntity()
	local trade = um:ReadEntity()
	local id = um:ReadShort()
	
	if not ValidEntity(client) then return end
	if not ValidEntity(recipient) then return end
	if not ValidEntity(trade) then return end

	local TradeFrame = vgui.Create("DFrame")
	TradeFrame:SetSize(ScrW()/4, 250)
	TradeFrame:Center()
	TradeFrame:SetTitle("Trade interface")
	TradeFrame:MakePopup()
	TradeFrame:SetSkin("DarkRP")
	function TradeFrame:Close()
		LocalPlayer():ConCommand("rp_killtrade " .. id)
		self:Remove()
	end
	
	local ItemsForm = vgui.Create("DPanel", TradeFrame)
	ItemsForm:SetSize((TradeFrame:GetWide())-20, 209)
	ItemsForm:SetPos(10, 31)
	ItemsForm.Paint = function()
		surface.DrawLine(ItemsForm:GetWide()/2, 21, (ItemsForm:GetWide()/2), 209)
	end
	
	local ClientLabel = vgui.Create("DLabel", ItemsForm)
	ClientLabel:SetText("Trade: " .. client:Name())
	ClientLabel:SetPos(5, 5)
	ClientLabel:SizeToContents()
	
	local RecipientLabel = vgui.Create("DLabel", ItemsForm)
	RecipientLabel:SetText("Trade: " .. recipient:Name())
	RecipientLabel:SetPos((ItemsForm:GetWide()/2)+15, 5)
	RecipientLabel:SizeToContents()
	
	local TradeClient = vgui.Create("SpawnIcon", ItemsForm)
	TradeClient:SetModel(trade:GetModel())
	TradeClient:SetToolTip(trade:GetClass())
	TradeClient:SetPos(5, 10+ClientLabel:GetTall())
	
	TradeRecipient = vgui.Create("SpawnIcon", ItemsForm)
	TradeRecipient:SetModel(trade:GetModel())
	TradeRecipient:SetToolTip(trade:GetClass())
	TradeRecipient:SetPos((ItemsForm:GetWide()/2)+15, 10+RecipientLabel:GetTall())
	
	if LocalPlayer() == recipient then
		
	end
end
usermessage.Hook("darkrp_trade", TradeMenuRecipient)

local function TradeRequest(um)
	local id = um:ReadShort()
	local client = um:ReadEntity()
	local trade = um:ReadEntity()

	LocalPlayer():EmitSound("Town.d1_town_02_elevbell1", 100, 100)
	local panel = vgui.Create("DFrame")
	panel:SetPos(3 + PanelNum, ScrH() / 2 - 50)
	panel:SetTitle("Trade")
	panel:SetSize(140, 140)
	panel:SetSizable(false)
	panel.btnClose:SetVisible(false)
	panel:SetDraggable(false)
	function panel:Close()
		PanelNum = PanelNum - 140
		VoteVGUI[id .. "_trade"] = nil
		
		local num = 0
		for k,v in SortedPairs(VoteVGUI) do
			v:SetPos(num, ScrH() / 2 - 50)
			num = num + 140
		end
		
		for k,v in SortedPairs(QuestionVGUI) do
			v:SetPos(num, ScrH() / 2 - 50)
			num = num + 300
		end
		
		LocalPlayer():ConCommand("rp_killtrade " .. id)
		self:Remove()
	end

	panel:SetKeyboardInputEnabled(false)
	panel:SetMouseInputEnabled(true)
	panel:SetVisible(true)

	local label = vgui.Create("Label")
	label:SetParent(panel)
	label:SetPos(5, 30)
	label:SetSize(180, 40)
	label:SetText(client:Name() .. "\nWants to trade:\n" .. trade:GetClass())
	label:SetVisible(true)

	local divider = vgui.Create("Divider")
	divider:SetParent(panel)
	divider:SetPos(2, 80)
	divider:SetSize(180, 2)
	divider:SetVisible(true)

	local ybutton = vgui.Create("Button")
	ybutton:SetParent(panel)
	ybutton:SetPos(25, 100)
	ybutton:SetSize(40, 20)
	ybutton:SetCommand("!")
	ybutton:SetText("Yes")
	ybutton:SetVisible(true)
	ybutton.DoClick = function()
		LocalPlayer():ConCommand("rp_tradevote " .. id .. " yes")
		panel:Close()
	end

	local nbutton = vgui.Create("Button")
	nbutton:SetParent(panel)
	nbutton:SetPos(70, 100)
	nbutton:SetSize(40, 20)
	nbutton:SetCommand("!")
	nbutton:SetText("No")
	nbutton:SetVisible(true)
	nbutton.DoClick = function()
		LocalPlayer():ConCommand("rp_tradevote " .. id .. " no")
		panel:Close()
	end

	PanelNum = PanelNum + 140
	VoteVGUI[id .. "_trade"] = panel
	panel:SetSkin("DarkRP")
	
	timer.Simple(20, function()
		LocalPlayer():ConCommand("rp_tradevote " .. id .. " no")
		panel:Close()
	end)
end
usermessage.Hook("darkrp_treq", TradeRequest)

local function KillTrade(um)
	
end
usermessage.Hook("darkrp_killtrade", KillTrade)