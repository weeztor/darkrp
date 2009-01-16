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
	local timeleft = msg:ReadFloat() // 30
	if timeleft == 0 then
		timeleft = 100
	end
	local OldTime = CurTime() // 100  Nieuw = 110
	if string.find(voteid, LocalPlayer():EntIndex()) then return end //If it's about you then go away
	local inputenabled = false

	if HelpToggled or GUIToggled then
		inputenabled = true
	end

	local panel = vgui.Create("DFrame")
	panel:SetPos(3, ScrH() / 2 - 50)
	panel:SetName("Panel")
	panel:SetTitle("Vote")
	panel:SetSize(140, 140)
	panel:SetSizable(false)
	panel.btnClose:SetVisible(false)
	panel:SetDraggable(false)
	
	function panel:Think()
		self:SetTitle("Time: ".. tostring(math.ceil(timeleft - (CurTime() - OldTime))))
		if timeleft - (CurTime() - OldTime) <= 0 then 
			panel:Remove()
		end
	end
	/*panel:LoadControlsFromString([[
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
				"title" "Vote"
			}
		}
	]]) */
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
			if v:IsValid() and v:GetParent() == VoteVGUI[id .. "vote"] then
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


local F4Menu  
//local LastF4Tab 
local F4MenuTabs
local F4Tabs
function ChangeJobVGUI()
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
	else
		F4Menu:SetVisible(true)
	end
	
	//local money, jobs, entities = MoneyTab(), JobsTab(), EntitiesTab()
	
	if not F4MenuTabs or not F4MenuTabs:IsValid() then
		F4MenuTabs = vgui.Create( "DPropertySheet", F4Menu)
		F4MenuTabs:SetPos(5, 25)
		F4MenuTabs:SetSize(760, 550)
		//FIRST TAB:
		F4MenuTabs:AddSheet("Money/Commands", F4Tabs[1], "gui/silkicons/plugin", false, false)
		
		// SECON TAB: JOBS:
		// OMG IT'S GONE
		//don't worry it has moved to shoteamtabs.lua :)
		F4MenuTabs:AddSheet("Jobs", F4Tabs[2], "gui/silkicons/arrow_refresh", false, false)
		
		F4MenuTabs:AddSheet("Entities/weapons", F4Tabs[3], "gui/silkicons/application_view_tile", false, false)
		
		F4MenuTabs:AddSheet("HUD", F4Tabs[4], "gui/silkicons/user", false, false)
		if LocalPlayer():IsAdmin() then
			F4MenuTabs:AddSheet("Admin", F4Tabs[5], "gui/silkicons/wrench", false, false)
		end
	end
	for _, panel in pairs(F4Tabs) do panel:Update() end

 	function F4Menu:Close()
		F4Menu:SetVisible(false)
	end 
end

local KeyFrameVisible = false
function KeysMenu(Vehicle)
	if not KeyFrameVisible then
		local trace = LocalPlayer():GetEyeTrace()
		local Frame = vgui.Create("DFrame")
		local CPOnly = trace.Entity:GetNWBool("CPOwnable")
		KeyFrameVisible = true
		Frame:SetSize(200, 470)
		Frame:Center()
		Frame:SetVisible(true)
		Frame:MakePopup()
		Frame:SetTitle("Door options")
		function Frame:Think()
			local ent = LocalPlayer():GetEyeTrace().Entity
			if not ValidEntity(ent) or not ent:IsDoor() or ent:GetPos():Distance(LocalPlayer():GetPos()) > 120 then
				self:Close()
			end
			if (!self.Dragging) then return end  
			local x = gui.MouseX() - self.Dragging[1] 
			local y = gui.MouseY() - self.Dragging[2] 
			// Lock to screen bounds if screenlock is enabled 
			x = math.Clamp( x, 0, ScrW() - self:GetWide() ) 
			y = math.Clamp( y, 0, ScrH() - self:GetTall() ) 
			self:SetPos( x, y ) 
		end
		local Entiteh = "door"
		if Vehicle then
			Entiteh = "vehicle"
		end
		
		function Frame:Close()
			KeyFrameVisible = false
			self:SetVisible( false )
			self:Remove()
		end
		
		if trace.Entity:OwnedBy(LocalPlayer()) then
			local Owndoor = vgui.Create("DButton", Frame)
			Owndoor:SetPos(10, 30)
			Owndoor:SetSize(180, 100)
			Owndoor:SetText("Sell " .. Entiteh)
			Owndoor.DoClick = function() LocalPlayer():ConCommand("say /toggleown") Frame:Close() end
			
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
			
			local DoorTitle = vgui.Create("DButton", Frame)
			DoorTitle:SetPos(10, 360)
			DoorTitle:SetSize(180, 100)
			DoorTitle:SetText("Set door title")
			if not trace.Entity:IsMasterOwner(LocalPlayer()) then
				RemoveOwner.m_bDisabled = true
			end
			DoorTitle.DoClick = function()
				Derma_StringRequest("Set door title", "Set the title of the door you're looking at", "", function(text) LocalPlayer():ConCommand("say /title "..text) Frame:Close() end, function() end, "OK!", "CANCEL!")
			end
			
			if LocalPlayer():IsSuperAdmin() then
				Frame:SetSize(200, Frame:GetTall() + 110)
				local SetCopsOnly = vgui.Create("DButton", Frame)
				SetCopsOnly:SetPos(10, Frame:GetTall() - 110)
				SetCopsOnly:SetSize(180, 100)
				if CPOnly then
					SetCopsOnly:SetText("Available for everyone")
				else
					SetCopsOnly:SetText("Set cops and mayor only")
				end
				SetCopsOnly.DoClick = function() LocalPlayer():ConCommand("say /togglecpownable") Frame:Close() end
			end	
		elseif not trace.Entity:OwnedBy(LocalPlayer()) and trace.Entity:IsOwnable() and not trace.Entity:IsOwned() and not trace.Entity:GetNWBool("nonOwnable") then
			if not CPOnly then
				Frame:SetSize(200, 140)
				local Owndoor = vgui.Create("DButton", Frame)
				Owndoor:SetPos(10, 30)
				Owndoor:SetSize(180, 100)
				Owndoor:SetText("Buy " .. Entiteh)
				Owndoor.DoClick = function() LocalPlayer():ConCommand("say /toggleown") Frame:Close() end
			elseif not LocalPlayer():IsSuperAdmin() then
				Frame:Close()
			end
			if LocalPlayer():IsSuperAdmin() then
				if CPOnly then
					Frame:SetSize(200, 250)
				else
					Frame:SetSize(200, 360)
				end
				local DisableOwnage = vgui.Create("DButton", Frame)
				DisableOwnage:SetPos(10, Frame:GetTall() - 220)
				DisableOwnage:SetSize(180, 100)
				DisableOwnage:SetText("Disallow ownership")
				DisableOwnage.DoClick = function() Frame:Close() LocalPlayer():ConCommand("say /toggleownable") end
				
				local SetCopsOnly = vgui.Create("DButton", Frame)
				SetCopsOnly:SetPos(10, Frame:GetTall() - 110)
				SetCopsOnly:SetSize(180, 100)
				if CPOnly then
					SetCopsOnly:SetText("Set available for everyone")
				else
					SetCopsOnly:SetText("Set cops and mayor only")
				end
				SetCopsOnly.DoClick = function() LocalPlayer():ConCommand("say /togglecpownable") Frame:Close() end
			end
		elseif not trace.Entity:OwnedBy(LocalPlayer()) and trace.Entity:AllowedToOwn(LocalPlayer()) then
			Frame:SetSize(200, 140)
			local Owndoor = vgui.Create("DButton", Frame)
			Owndoor:SetPos(10, 30)
			Owndoor:SetSize(180, 100)
			Owndoor:SetText("Co-own " .. Entiteh)
			Owndoor.DoClick = function() LocalPlayer():ConCommand("say /toggleown") Frame:Close() end
			
			if LocalPlayer():IsSuperAdmin() then
				Frame:SetSize(200, Frame:GetTall() + 100)
				local SetCopsOnly = vgui.Create("DButton", Frame)
				SetCopsOnly:SetPos(10, Frame:GetTall() - 110)
				SetCopsOnly:SetSize(180, 100)
				if CPOnly then
					SetCopsOnly:SetText("Set available for everyone")
				else
					SetCopsOnly:SetText("Set cops and mayor only")
				end
				SetCopsOnly.DoClick = function() LocalPlayer():ConCommand("say /togglecpownable") Frame:Close() end
			end	
		elseif LocalPlayer():IsSuperAdmin() and trace.Entity:GetNWBool("nonOwnable") then
			Frame:SetSize(200, 140)
			local EnableOwnage = vgui.Create("DButton", Frame)
			EnableOwnage:SetPos(10, 30)
			EnableOwnage:SetSize(180, 100)
			EnableOwnage:SetText("Allow ownership")
			EnableOwnage.DoClick = function() Frame:Close() LocalPlayer():ConCommand("say /toggleownable") end
		elseif LocalPlayer():IsSuperAdmin() and not trace.Entity:OwnedBy(LocalPlayer()) and trace.Entity:IsOwned() and not trace.Entity:AllowedToOwn(LocalPlayer()) then
			Frame:SetSize(200, 250)
			local DisableOwnage = vgui.Create("DButton", Frame)
			DisableOwnage:SetPos(10, 30)
			DisableOwnage:SetSize(180, 100)
			DisableOwnage:SetText("Disallow ownership")
			DisableOwnage.DoClick = function() Frame:Close() LocalPlayer():ConCommand("say /toggleownable") end
			
			local SetCopsOnly = vgui.Create("DButton", Frame)
			SetCopsOnly:SetPos(10, Frame:GetTall() - 110)
			SetCopsOnly:SetSize(180, 100)
			if CPOnly then
				SetCopsOnly:SetText("Set available for everyone")
			else
				SetCopsOnly:SetText("Set cops and mayor only")
			end
			SetCopsOnly.DoClick = function() LocalPlayer():ConCommand("say /togglecpownable") Frame:Close() end
		else
			Frame:Close()
			//LocalPlayer():ChatPrint("Door cannot be owned") 
		end
	end
end

