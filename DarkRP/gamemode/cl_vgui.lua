if VoteVGUI then
	for k, v in pairs(VoteVGUI) do
		v:Remove()
		VoteVGUI[k] = nil
	end
end

if QuestionVGUI then
	for k, v in pairs(QuestionVGUI) do
		v:Remove()
		QuestionVGUI[k] = nil
	end
end

VoteVGUI = {}
QuestionVGUI = {}
PanelNum = 0

if LetterWritePanel then
	LetterWritePanel:Remove()
	LetterWritePanel = nil
end

function MsgDoVote(msg)
	local question = msg:ReadString()
	local voteid = msg:ReadString()
	if string.find(voteid, LocalPlayer():EntIndex()) then return end //If it's about you then go away
	local inputenabled = false

	if HelpToggled or GUIToggled then
		inputenabled = true
	end

	local panel = vgui.Create("Frame")
	panel:SetPos(3, ScrH() / 2 - 50)
	panel:SetName("Panel")
	panel:LoadControlsFromString([[
		"VotePanel"
		{
			"Panel"
			{
				"ControlName" "Panel"
				"fieldName" "Vote"
				"wide" "140"
				"tall" "140"
				"sizable" "0"
				"enabled" "1"
				"title" "VoteCop"
			}
		}
	]])
	panel:SetKeyboardInputEnabled(false)
	panel:SetMouseInputEnabled(inputenabled)
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

	_G["YesVoteFunc" .. voteid] = function(msg)
		LocalPlayer():ConCommand("vote " .. voteid .. " 1\n")
		KillVoteVGUI(voteid)
	end

	local ybutton = vgui.Create("Button")
	ybutton:SetParent(panel)
	ybutton:SetPos(15, 100)
	ybutton:SetSize(40, 20)
	ybutton:SetCommand("!")
	ybutton:SetText("Yes")
	ybutton:SetActionFunction(_G["YesVoteFunc" .. voteid])
	ybutton:SetVisible(true)

	table.insert(VoteVGUI, ybutton)

	_G["NoVoteFunc" .. voteid] = function(msg)
		LocalPlayer():ConCommand("vote " .. voteid .. " 2\n")
		KillVoteVGUI(voteid)
	end

	local nbutton = vgui.Create("Button")
	nbutton:SetParent(panel)
	nbutton:SetPos(60, 100)
	nbutton:SetSize(40, 20)
	nbutton:SetCommand("!")
	nbutton:SetText("No")
	nbutton:SetActionFunction(_G["NoVoteFunc" .. voteid])
	nbutton:SetVisible(true)

	table.insert(VoteVGUI, nbutton)

	PanelNum = PanelNum + 1
	VoteVGUI[voteid .. "vote"] = panel
end
usermessage.Hook("DoVote", MsgDoVote)

function KillVoteVGUI(msg)
	
	local id
	if type(msg) == "string"  then
		id = msg
	else 
		id = msg:ReadString()
	end
	if VoteVGUI[id .. "vote"] then
		for k, v in pairs(VoteVGUI) do
			if v:GetParent() == VoteVGUI[id .. "vote"] then
				v:Remove()
				VoteVGUI[k] = nil
			end
		end

		VoteVGUI[id .. "vote"]:Remove()
		VoteVGUI[id .. "vote"] = nil
		PanelNum = PanelNum - 1
	end
end
usermessage.Hook("KillVoteVGUI", KillVoteVGUI)

function MsgDoQuestion(msg)
	local question = msg:ReadString()
	local quesid = msg:ReadString()
	local inputenabled = false

	if HelpToggled or GUIToggled then
		inputenabled = true
	end

	local panel = vgui.Create("Frame")
	panel:SetPos(3, ScrH() / 2 - 50)
	panel:SetName("Panel")
	panel:LoadControlsFromString([[
		"QuestionPanel"
		{
			"Panel"
			{
				"ControlName" "Panel"
				"fieldName" "Question"
				"wide" "380"
				"tall" "140"
				"sizable" "0"
				"enabled" "1"
				"title" "Question"
			}
		}
	]])
	panel:SetKeyboardInputEnabled(false)
	panel:SetMouseInputEnabled(inputenabled)
	panel:SetVisible(true)

	local label = vgui.Create("Label")
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

	_G["YesQuesFunc" .. quesid] = function(msg)
		LocalPlayer():ConCommand("ans " .. quesid .. " 1\n")
	end

	local ybutton = vgui.Create("Button")
	ybutton:SetParent(panel)
	ybutton:SetPos(147, 100)
	ybutton:SetSize(40, 20)
	ybutton:SetCommand("!")
	ybutton:SetText("Yes")
	ybutton:SetActionFunction(_G["YesQuesFunc" .. quesid])
	ybutton:SetVisible(true)

	table.insert(QuestionVGUI, ybutton)

	_G["NoQuesFunc" .. quesid] = function(msg)
		LocalPlayer():ConCommand("ans " .. quesid .. " 2\n")
	end

	local nbutton = vgui.Create("Button")
	nbutton:SetParent(panel)
	nbutton:SetPos(192, 100)
	nbutton:SetSize(40, 20)
	nbutton:SetCommand("!")
	nbutton:SetText("No")
	nbutton:SetActionFunction(_G["NoQuesFunc" .. quesid])
	nbutton:SetVisible(true)

	table.insert(QuestionVGUI, nbutton)

	PanelNum = PanelNum + 1
	QuestionVGUI[quesid .. "ques"] = panel
end
usermessage.Hook("DoQuestion", MsgDoQuestion)

function KillQuestionVGUI(msg)
	local id = msg:ReadString()

	if QuestionVGUI[id .. "ques"] then
		for k, v in pairs(QuestionVGUI) do
			if v:GetParent() == QuestionVGUI[id .. "ques"] then
				v:Remove()
				QuestionVGUI[k] = nil
			end
		end

		QuestionVGUI[id .. "ques"]:Remove()
		QuestionVGUI[id .. "ques"] = nil
		PanelNum = PanelNum - 1
	end
end
usermessage.Hook("KillQuestionVGUI", KillQuestionVGUI)

function DoLetter(msg)
	LetterWritePanel = vgui.Create("Frame")
	LetterWritePanel:SetPos(ScrW() / 2 - 75, ScrH() / 2 - 100)
	LetterWritePanel:SetSize(150, 200)
	LetterWritePanel:SetMouseInputEnabled(true)
	LetterWritePanel:SetKeyboardInputEnabled(true)
	LetterWritePanel:SetVisible(true)
end
usermessage.Hook("DoLetter", DoLetter)

local amountOfMoney = 2
function ChangeJobVGUI()
//vgui/dpanellist.lua:190: Tried to use invalid object (type Panel) (Object was NULL or not of the right type)

	local Frame = vgui.Create("DFrame")
	Frame:SetSize(770, 580)
	Frame:Center()
	Frame:SetVisible( true )
	Frame:MakePopup( )
	Frame:SetTitle("Change job")
	
	local Tabs = vgui.Create( "DPropertySheet", Frame)
	Tabs:SetPos(5, 25)
	Tabs:SetSize(760, 550)
	//FIRST TAB:
	local MoneyPanel = vgui.Create("DPanelList", Frame)
	MoneyPanel:SetSpacing(5)
	MoneyPanel:SetSize(740,510)
	MoneyPanel:EnableHorizontal( false )
	MoneyPanel:EnableVerticalScrollbar( true )
	local MoneyCat = vgui.Create("DCollapsibleCategory", Frame)
	MoneyCat:SetLabel("Money")
	MoneyPanel:AddItem(MoneyCat)
	local MoneyAmount = vgui.Create("DNumSlider", Frame)
	MoneyAmount:SetDecimals(0)
	MoneyAmount:SetMin(2)
	MoneyAmount:SetMax(LocalPlayer():GetNWInt("Money"))
	MoneyAmount:SetText("Amount of money")
	MoneyAmount:SetValue(math.Clamp(amountOfMoney, 2, LocalPlayer():GetNWInt("Money")))
	local Max = LocalPlayer():GetNWInt("Money")
	function MoneyPanel:Think()
		if LocalPlayer():GetNWInt("Money") ~= Max then
			MoneyAmount:SetMax(LocalPlayer():GetNWInt("Money"))
			Max = LocalPlayer():GetNWInt("Money")
		end
	end
	MoneyPanel:AddItem(MoneyAmount)
	
	local GiveMoneyButton = vgui.Create("DButton", Frame)
	GiveMoneyButton:SetText("Give amount at the player you're looking at")
	GiveMoneyButton.DoClick = function()
		LocalPlayer():ConCommand("say /give " .. tostring(MoneyAmount:GetValue()))
	end
	MoneyPanel:AddItem(GiveMoneyButton)
	
	local SpawnMoneyButton = vgui.Create("DButton", Frame)
	SpawnMoneyButton:SetText("Drop a money package with the selected amount of money")
	SpawnMoneyButton.DoClick = function()
		LocalPlayer():ConCommand("say /dropmoney " .. tostring(MoneyAmount:GetValue()))
	end

	MoneyPanel:AddItem(SpawnMoneyButton)
	Tabs:AddSheet("Money/Commands", MoneyPanel, "gui/silkicons/plugin", false, false)
	
	
	// SECON TAB: JOBS:
	local hordiv = vgui.Create("DHorizontalDivider", Frame)
	hordiv:SetLeftWidth(370)
	function hordiv.m_DragBar:OnMousePressed() end
	
	local Panel = vgui.Create( "DPanelList", Frame )
	Panel:SetPos(10,30)
	Panel:SetSize(370, 540)
	Panel:SetSpacing(1)
	Panel:EnableHorizontal( true )
	Panel:EnableVerticalScrollbar( true )
	
	local Information
	local Info = {}
	local model
	local modelpanel
	local function UpdateInfo(a)
		Information = vgui.Create( "DPanelList", Frame )
		Information:SetPos(390,0)
		Information:SetSize(370, 540)
		Information:SetSpacing(10)
		Information:EnableHorizontal( false )
		Information:EnableVerticalScrollbar( true )
		function Information:Rebuild() // YES IM OVERRIDING IT AND CHANGE ONLY ONE LINE BUT I HAVE A FUCKING GOOD REASON TO DO IT!
			local Offset = 0
			if ( self.Horizontal ) then
				local x, y = self.Padding, self.Padding;
				for k, panel in pairs( self.Items ) do
					local w = panel:GetWide()
					local h = panel:GetTall()
					if ( x + w  > self:GetWide() ) then
						x = self.Padding
						y = y + h + self.Spacing
					end
					panel:SetPos( x, y )
					x = x + w + self.Spacing
					Offset = y + h + self.Spacing
				end
			else
				for k, panel in pairs( self.Items ) do
					if not panel:IsValid() then return end
					panel:SetSize( self:GetCanvas():GetWide() - self.Padding * 2, panel:GetTall() )
					panel:SetPos( self.Padding, self.Padding + Offset )
					// Changing the width might ultimately change the height
					// So give the panel a chance to change its height now, 
					// so when we call GetTall below the height will be correct.
					// True means layout now.
					panel:InvalidateLayout( true )
					Offset = Offset + panel:GetTall() + self.Spacing
				end
				Offset = Offset + self.Padding	
			end
			self:GetCanvas():SetTall( Offset + (self.Padding) - self.Spacing ) 
		end
		
		if type(Info) == "table" and #Info > 0 then
			for k,v in ipairs(Info) do
				local label = vgui.Create("DLabel")
				label:SetText(v)
				label:SizeToContents()
				if label:IsValid() then
					Information:AddItem(label)
				end
			end
		end

		if model and type(model) == "string" and a ~= false then
			modelpanel = vgui.Create("DModelPanel")
			modelpanel:SetModel(model)
			modelpanel:SetSize(90,230)
			modelpanel:SetAnimated(true)
			modelpanel:SetFOV(90)
			modelpanel:SetAnimSpeed(1)
			if modelpanel:IsValid() then
				Information:AddItem(modelpanel)
			end
		end
		hordiv:SetLeft(Panel)
		hordiv:SetRight(Information)
	end
	UpdateInfo()
	
	local function AddIcon(Model, name, description, Weapons, command)
		local icon = vgui.Create("SpawnIcon", Frame)
		icon:SetModel(Model)
		icon:SetIconSize(120)
		icon:SetToolTip()
		icon.OnCursorEntered = function()
			icon.PaintOverOld = icon.PaintOver 
			icon.PaintOver = icon.PaintOverHovered
			Info[1] = "Name: " .. name
			Info[2] = "Description: " .. description
			Info[3] = "Weapons: " .. Weapons
			model = Model
			UpdateInfo()
		end
		icon.OnCursorExited = function()
			if ( icon.PaintOver == icon.PaintOverHovered ) then 
				icon.PaintOver = icon.PaintOverOld 
			end
			Info = {}
			if modelpanel and modelpanel:IsValid() and icon:IsValid() then
				modelpanel:Remove()
				UpdateInfo(false)
			end
		end
		
		icon.DoClick = function()
			LocalPlayer():ConCommand("say " .. command)
			Frame:Close()
		end
		
		if icon:IsValid() then
			Panel:AddItem(icon)
		end
	end
	
	
	if LocalPlayer():Team() ~= TEAM_HOBO then
		AddIcon("models/player/corpse1.mdl", "Hobo", [[The lowest member of society. All people see you laugh. 
		You have no home.
		Beg for your food and money
		Sing for everyone who passes to get money
		Make your own wooden home somewhere in a corner or 
		outside someone else's door]]
		, [[Keys
			Gravity gun
			camera
			]], "/hobo")
	end
	
	if LocalPlayer():Team() ~= TEAM_CITIZEN then
		AddIcon("models/player/Group01/male_02.mdl", "Citizen", [[The Citizen is the most basic level of society you can hold
		besides being a hobo. 
			You have no specific role in city life.]], [[Keys
			Gravity gun
			camera
			]], "/citizen")
	end

	
	if LocalPlayer():Team() ~= TEAM_COOK then
		AddIcon("models/player/mossman.mdl", "Cook", [[As a cook, it is your responsibility to feed the other members 
		of your city. 
		You can spawn a microwave and sell the food you make:
		/buymicrowave]]
			, [[Keys
			Gravity gun
			camera
			]], "/cook")
	end
	if LocalPlayer():Team() ~= TEAM_MEDIC then
		AddIcon("models/player/kleiner.mdl", "Medic", [[With your medical knowledge, you heal players to proper 
		health. 
		Without a medic, people cannot be healed. 
		Left click with the Medical Kit to heal other players.
		Right click with the Medical Kit to heal yourself.]]
			, [[Keys
			Gravity gun
			camera
			Medic kit
			]], "/medic")
	end
	if LocalPlayer():Team() ~= TEAM_GUN then
		AddIcon("models/player/monk.mdl", "Gundealer", [[A gun dealer is the only person who can sell guns to other 
			people. 
			However, make sure you aren't caught selling guns that are illegal to 
			the public.
			/buyshipment <name> to buy a  weapon shipment
			/buygunlab to buy a gunlab that spawns P228 pistols]]
			, [[Keys
			Gravity gun
			camera
			]], "/gundealer")
	end
	
	if LocalPlayer():Team() ~= TEAM_MOB then
		AddIcon("models/player/gman_high.mdl", "Mobboss", [[The Mobboss is the crimboss in the city. 
			With his power he coordinates the gangsters and forms an efficent crime
			organization. 
			He has the ability to break into houses by using a lockpick. 
			The Mobboss also can unarrest you.]]
			, [[Keys
			Gravity gun
			camera
			Lock pick
			]], "/mobboss")
	end
	if LocalPlayer():Team() ~= TEAM_GANG then
		AddIcon("models/player/group03/male_01.mdl", "Gangster", [[The lowest person of crime. 
		A gangster generally works for the Mobboss who runs the crime family. 
		The Mobboss sets your agenda and you follow it or you might be punished.]]
			, [[Keys
			Gravity gun
			camera
			]], "/gangster")
	end
	if LocalPlayer():Team() ~= TEAM_POLICE and LocalPlayer():Team() ~= TEAM_CHIEF then
		AddIcon("models/player/police.mdl", "Civil protection officer", [[The protector of every citizen that lives in the city . 
		You have the power to arrest criminals and protect innocents. 
		Hit them with your arrest baton to put them in jail
		Bash them with a stunstick and they might learn better than to disobey 
		the law.
		The Battering Ram can break down the door of a criminal with a warrant 
		for his/her arrest.
		The Battering Ram can also unfreeze frozen props(if enabled).
		Type /wanted <name> to alert the public to this criminal
			OR go to tab and warrant someone by clicking the warrant button
			]]
			, [[Keys
			Gravity gun
			camera
			Arrest baton
			Unarrest baton
			Glock
			Stun Stick
			Battering ram
			]], "/votecop")
	elseif LocalPlayer():Team() ~= TEAM_CHIEF then
		AddIcon("models/player/combine_soldier_prisonguard.mdl", "Civil protection Chief", [[The Chief is the leader of the Civil Protection unit. 
		Coordinate the police forces to bring law to the city
		Hit them with arrest baton to put them in jail
		Bash them with a stunstick and they might learn better than to 
		disobey the law.
		The Battering Ram can break down the door of a criminal with a 
		warrant for his/her arrest.
		Type /wanted <name> to alert the public to this criminal
		Type /jailpos to set the Jail Position]]
			, [[Keys
			Gravity gun
			camera
			Arrest baton
			Unarrest baton
			Desert Eagle
			Stun Stick
			Battering ram]]
			, "/chief")
	end
	
	if LocalPlayer():Team() ~= TEAM_MAYOR then
		AddIcon("models/player/breen.mdl", "Mayor", [[The Mayor of the city creates laws to serve the greater good 
		of the people.
		If you are the mayor you may create and accept warrants.
		Type /wanted <name>  to warrant a player
		Type /jailpos to set the Jail Position
		Type /lockdown initiate a lockdown of the city. 
		Everyone must be inside during a lockdown. 
		The cops patrol the area
		/unlockdown to end a lockdown]]
			, [[Keys
			Gravity gun
			camera
			]]
			, "/votemayor")
	end
	hordiv:SetLeft(Panel)
	hordiv:SetRight(Information)
	Tabs:AddSheet("Jobs", hordiv, "gui/silkicons/arrow_refresh", false, false)
end

local KeyFrameVisible = false
function KeysMenu()
	if not KeyFrameVisible then
		local trace = LocalPlayer():GetEyeTrace()
		local Frame = vgui.Create("DFrame")
		KeyFrameVisible = true
		Frame:SetSize(200, 360)
		Frame:Center()
		Frame:SetVisible(true)
		Frame:MakePopup()
		Frame:SetTitle("Door options")
		
		function Frame:Close()
			KeyFrameVisible = false
			self:SetVisible( false )
			self:Remove()
		end
		
		if trace.Entity:OwnedBy(LocalPlayer()) then
			local Owndoor = vgui.Create("DButton", Frame)
			Owndoor:SetPos(10, 30)
			Owndoor:SetSize(180, 100)
			Owndoor:SetText("Sell door")
			Owndoor.DoClick = function() LocalPlayer():ConCommand("say /toggleowndoor") Frame:Close() end
			
			local AddOwner = vgui.Create("DButton", Frame)
			AddOwner:SetPos(10, 140)
			AddOwner:SetSize(180, 100)
			AddOwner:SetText("Add owner")
			if not trace.Entity:IsMasterOwner(LocalPlayer()) then
				AddOwner.m_bDisabled = true
			end
				
			AddOwner.DoClick = function()
				local menu = DermaMenu()
				//menu:SetPos(gui.MouseX(), gui.MouseY())
				for k,v in pairs(player.GetAll()) do
					if not trace.Entity:OwnedBy(v) and not trace.Entity:AllowedToOwn(v) then
						menu:AddOption(v:Nick(), function() LocalPlayer():ConCommand("say /addowner " .. tostring(v:UserID())) end)
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
			if not trace.Entity:IsMasterOwner(LocalPlayer()) then
				RemoveOwner.m_bDisabled = true
			end
				
			RemoveOwner.DoClick = function()
				local menu = DermaMenu()
				//menu:SetPos(gui.MouseX(), gui.MouseY())
				for k,v in pairs(player.GetAll()) do
					if (trace.Entity:OwnedBy(v) and not trace.Entity:IsMasterOwner(v)) or trace.Entity:AllowedToOwn(v) then
						menu:AddOption(v:Nick(), function() LocalPlayer():ConCommand("say /ro " .. tostring(v:UserID())) end)
					end
				end
				if #menu.Panels == 0 then
					menu:AddOption("Noone available", function() end)
				end
				menu:Open()
			end
		elseif not trace.Entity:OwnedBy(LocalPlayer()) and trace.Entity:IsOwnable() and not trace.Entity:IsOwned() and not trace.Entity:GetNWBool("nonOwnable") then
			Frame:SetSize(200, 140)
			local Owndoor = vgui.Create("DButton", Frame)
			Owndoor:SetPos(10, 30)
			Owndoor:SetSize(180, 100)
			Owndoor:SetText("Buy door")
			Owndoor.DoClick = function() LocalPlayer():ConCommand("say /toggleowndoor") Frame:Close() end
			if LocalPlayer():IsSuperAdmin() then
				Frame:SetSize(200, 250)
				local DisableOwnage = vgui.Create("DButton", Frame)
				DisableOwnage:SetPos(10, 140)
				DisableOwnage:SetSize(180, 100)
				DisableOwnage:SetText("Disallow ownership")
				DisableOwnage.DoClick = function() Frame:Close() LocalPlayer():ConCommand("say /toggleownable") end
			end
		elseif not trace.Entity:OwnedBy(LocalPlayer()) and trace.Entity:AllowedToOwn(LocalPlayer()) then
			Frame:SetSize(200, 150)
			local Owndoor = vgui.Create("DButton", Frame)
			Owndoor:SetPos(10, 30)
			Owndoor:SetSize(180, 100)
			Owndoor:SetText("Co-own door")
			Owndoor.DoClick = function() LocalPlayer():ConCommand("say /toggleowndoor") Frame:Close() end
		elseif LocalPlayer():IsSuperAdmin() and trace.Entity:GetNWBool("nonOwnable") then
			Frame:SetSize(200, 140)
			local EnableOwnage = vgui.Create("DButton", Frame)
			EnableOwnage:SetPos(10, 30)
			EnableOwnage:SetSize(180, 100)
			EnableOwnage:SetText("Allow ownership")
			EnableOwnage.DoClick = function() Frame:Close() LocalPlayer():ConCommand("say /toggleownable") end
		elseif LocalPlayer():IsSuperAdmin() and not trace.Entity:OwnedBy(LocalPlayer()) and trace.Entity:IsOwned() and not trace.Entity:AllowedToOwn(LocalPlayer()) then
			Frame:SetSize(200, 140)
			local DisableOwnage = vgui.Create("DButton", Frame)
			DisableOwnage:SetPos(10, 30)
			DisableOwnage:SetSize(180, 100)
			DisableOwnage:SetText("Disallow ownership")
			DisableOwnage.DoClick = function() Frame:Close() LocalPlayer():ConCommand("say /toggleownable") end
		else
			Frame:Close()
			//LocalPlayer():ChatPrint("Door cannot be owned") 
		end
	end
end

