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

function ChangeJobVGUI()
//vgui/dpanellist.lua:190: Tried to use invalid object (type Panel) (Object was NULL or not of the right type)

	local Frame = vgui.Create("DFrame")
	Frame:SetSize(770, 580)
	Frame:Center()
	Frame:SetVisible( true )
	Frame:MakePopup( )
	Frame:SetTitle("Change job")
	
	local Information
	local Info = {}
	local model
	local modelpanel
	local function UpdateInfo(a)
		Information = vgui.Create( "DPanelList", Frame )
		Information:SetPos(390,30)
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
			modelpanel:SetSize(150,300)
			modelpanel:SetAnimated(true)
			modelpanel:SetFOV(90)
			modelpanel:SetAnimSpeed(1)
			if modelpanel:IsValid() then
				Information:AddItem(modelpanel)
			end
		end
	end
	UpdateInfo()
	
	local Panel = vgui.Create( "DPanelList", Frame )
	Panel:SetPos(10,30)
	Panel:SetSize(370, 540)
	Panel:SetSpacing(1)
	Panel:EnableHorizontal( true )
	Panel:EnableVerticalScrollbar( true )
	
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
		AddIcon("models/player/corpse1.mdl", "Hobo", [[The ULTIMATE downgrade
		Be homeless and poor
		Beg for money
		sing through your microphone for money
		Make your own wooden home somewhere in a corner or outside someone's door]]
		, [[Keys
			Gravity gun
			camera
			]], "/hobo")
	end
	
	if LocalPlayer():Team() ~= TEAM_CITIZEN then
		AddIcon("models/player/Group01/male_02.mdl", "Citizen", "Downgrade to citizen and have no job", [[Keys
			Gravity gun
			camera
			]], "/citizen")
	end

	
	if LocalPlayer():Team() ~= TEAM_COOK then
		AddIcon("models/player/mossman.mdl", "Cook", [[The cook cooks food for everyone who's hungry
		You can spawn a microwave by saying:
		/buymicrowave]]
			, [[Keys
			Gravity gun
			camera
			]], "/cook")
	end
	if LocalPlayer():Team() ~= TEAM_MEDIC then
		AddIcon("models/player/kleiner.mdl", "Medic", [[The medic provides health for the ones who need it
		Tip: Do not give health for free...
		Left mouse with the health kit to heal someone
		Right mouse with the health kit to heal yourself]]
			, [[Keys
			Gravity gun
			camera
			Medic kit
			]], "/medic")
	end
	if LocalPlayer():Team() ~= TEAM_GUN then
		AddIcon("models/player/monk.mdl", "Gundealer", [[The gundealer is able to buy shipments and sell guns. 
			/buyshipment <name> to buy a shipment
			/buygunlab to buy a gunlab]]
			, [[Keys
			Gravity gun
			camera
			]], "/gundealer")
	end
	
	if LocalPlayer():Team() ~= TEAM_MOB then
		AddIcon("models/player/gman_high.mdl", "Mobboss", [[The Mobboss is the boss of the gangsters
			With a lock pick he breaks in houses and steals money and other things]]
			, [[Keys
			Gravity gun
			camera
			Lock pick
			]], "/mobboss")
	end
	if LocalPlayer():Team() ~= TEAM_GANG then
		AddIcon("models/player/group03/male_01.mdl", "Gangster", [[The gangster is a servant of the mobboss(if he's there)
			When you're a gangster, do what the agenda says or be an overall bad guy]]
			, [[Keys
			Gravity gun
			camera
			]], "/gangster")
	end
	if LocalPlayer():Team() ~= TEAM_POLICE and LocalPlayer():Team() ~= TEAM_CHIEF then
		AddIcon("models/player/police.mdl", "Civil protection officer", [[The civil protection unit takes out all the criminals!
			Hit them with arrest baton to jail them!
			Hitting them with a stunstick might teach them a lesson...
			The Battering ram can ram a door of a wanted player
			/wanted <name> to warrant someone
			OR go to tab and warrant someone by clicking the button
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
		AddIcon("models/player/combine_soldier_prisonguard.mdl", "Civil protection Chief", [[The civil protection Chief is the leader of the cops!
			Use are the same as the civil protection except for this:
			/jailpos to set the jailpos
			]]
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
		AddIcon("models/player/breen.mdl", "Mayor", [[The mayor of town.
			You approve warrants of cops and you can make them yourself
			/wanted <player>  to warrant a player
			/jailpos to set the jailpos
			/lockdown to start a lockdown to make everyone go home
			/unlockdown to end a lockdown]]
			, [[Keys
			Gravity gun
			camera
			]]
			, "/votemayor")
	end
end
