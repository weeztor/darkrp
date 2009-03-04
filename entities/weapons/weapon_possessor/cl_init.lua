include('shared.lua')

SWEP.PrintName = "Player posessor"
SWEP.Slot = 5
SWEP.SlotPos = 6
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = false 

/*--------------------------------------------------------- 
	Variables for in this script
---------------------------------------------------------*/ 
local FSTOOLTable = {}//All the tools so it won't have to reload them when you've opened it once
local AnnoyingOn = false//Is the annoying say panel on
local ToolSelected = false//If a tool is selected. against bugs
local FalcoToolMode = "weld"//The tool he's holding

/*--------------------------------------------------------- 
	Override the chat so he will say the stuff and not you.
---------------------------------------------------------*/ 
function FOverrideChat()
	local frame = vgui.Create("DFrame")
	local text = vgui.Create("DTextEntry", frame)
	
	frame:SetSize(300,80)
	frame:SetPos(ScrW() / 2 - 150, ScrH() - 80)
	frame.btnClose:SetVisible(true)
	frame:SetVisible(true)
	frame:MakePopup( )
	frame:SetTitle("You can say stuff here")
	
	text:SetPos(20, 40)
	text:SetSize(260, 20)
	local notagain = notagain or 0
	function text:OnEnter()
		if notagain < RealTime() then	
			notagain = RealTime() + 0.1
			local TheText = text:GetValue()
			LocalPlayer():ConCommand("FDoHimAnotherCommand say " .. TheText)
			frame:SetVisible(false)
		end				
	end
	text:RequestFocus( )
end
concommand.Add("FOpenOverrideChatThingey", FOverrideChat)

/*--------------------------------------------------------- 
	The annoying screen that makes the victim unable to move etc.
---------------------------------------------------------*/ 
function FVeryAnnoyingPanel()
	if !AnnoyingOn then
		LocalPlayer():ConCommand("cancelselect")
		AnnoyingOn = true
		local frame = vgui.Create("DFrame")
		local text = vgui.Create("DTextEntry", frame)
		
		frame:SetSize(300,80)
		frame:SetPos(ScrW() / 2 - 150, ScrH() - 80)
		frame.btnClose:SetVisible(false)
		frame:SetVisible(true)
		frame:MakePopup( );
		frame:SetTitle("You can say stuff here")
		
		text:SetPos(20, 40)
		text:SetSize(260, 20)
		local notagain = notagain or 0
		function text:OnEnter()
			if notagain < RealTime() then	
				notagain = RealTime() + 0.1
				local TheText = text:GetValue()
				RunConsoleCommand("say", TheText)
				text:SetText("")
				text:RequestFocus( )
			end				
		end
		text:RequestFocus( )
		
		local function CloseTheAnnoyingScreen()
			AnnoyingOn = false
			frame:SetVisible(false)
			frame:Remove()
		end
		usermessage.Hook("PlayerPossessorCloseTheScreen", CloseTheAnnoyingScreen) 
		
		local function FDisableContextMenuClicking()
			if AnnoyingOn then	return false end
		end
		hook.Add( "GUIMousePressed", "FDisableContextMenuClicking", FDisableContextMenuClicking )
		hook.Add( "GUIMouseReleased", "FDisableContextMenuClicking", FDisableContextMenuClicking )  
		hook.Add( "GUIMouseDoublePressed", "FDisableContextMenuClicking", FDisableContextMenuClicking )  
	end
end
concommand.Add("FOpenVeryAnnoyingScreen", FVeryAnnoyingPanel)

/*--------------------------------------------------------- 
	The right mouse on the swep executes this command
---------------------------------------------------------*/ 
function ChoosePlayerWithoutShooting()
	if table.Count(player.GetAll()) <= 1 then
		GAMEMODE:AddNotify("You're the only one in the server", 1, 5)
		surface.PlaySound( "ambient/water/drip2.wav")
		return false
	end
	local frame = vgui.Create("DFrame")
	local button = {}
	local PosSize = {}
	
	frame:SetSize( 200, 500 )
	frame:Center()
	frame:SetVisible(true)
	frame:MakePopup()
	frame:SetTitle("Choose a player")
	
	PosSize[0] = 5
	for k,v in pairs(player.GetAll()) do
		if v == LocalPlayer() then
			PosSize[k] = PosSize[k-1]
		elseif v!= LocalPlayer() then
			PosSize[k] = PosSize[k-1] + 30
			frame:SetSize(200, PosSize[k] + 40)
			button[k] = vgui.Create("DButton", frame)
			button[k]:SetPos( 20, PosSize[k])
			button[k]:SetSize( 160, 20 )
			button[k]:SetText( v:Nick())
			frame:Center()
			button[k]["DoClick"] = function()
				LocalPlayer():GetActiveWeapon().SelectedPlayer = v
				frame:SetVisible(false)
				RunConsoleCommand("FSelectTarget", tostring(v:UserID()))
				LocalPlayer():GetActiveWeapon():DoControl()
			end
		end
	end
end

/*--------------------------------------------------------- 
	The alternate Q menu
---------------------------------------------------------*/ 
function FControlMenu()
	local notagain = notagain or 0
	local ContextOnOff = false
	//Controls
	local frame = vgui.Create("DFrame")
	local FalcoPanel = vgui.Create( "DPanelList", frame )
	local killbutton = vgui.Create("DButton", frame)
	local ThirdSlider = vgui.Create("DNumSlider", frame)
	local FixButton = vgui.Create("DButton", frame)
	local PrintLabel = vgui.Create("DLabel", frame)
	local PrintEntry = vgui.Create("DTextEntry", frame)
	local OtherCommandLabel = vgui.Create("DLabel", frame)
	local OtherCommandEntry = vgui.Create("DTextEntry", frame)
	local StopControlButton = vgui.Create("DButton", frame)
	local GiveSWEPbutton = vgui.Create("DButton", frame)
	local ToolModeButton = vgui.Create("DButton", frame)
	local OpenContext = vgui.Create("DButton", frame)
	local PropMenuButton = vgui.Create("DButton", frame)
	local PropSpawnButton = vgui.Create("DButton", frame)
	local NPCSpawnButton = vgui.Create("DButton", frame)
	local VehicleSpawnButton = vgui.Create("DButton", frame)
	local SENTSpawnButton = vgui.Create("DButton", frame)
	
	
	/*--------------------------------------------------------- 
		The frame itself
	---------------------------------------------------------*/ 
	frame:SetSize( 160, 500 )
	frame:Center()
	frame:SetVisible(true)
	frame:MakePopup()
	frame:SetTitle("Control menu")
	function frame.btnClose:OnMousePressed()
		frame:SetVisible(false)
		if ContextOnOff then
			RunConsoleCommand("-menu_context")
		end
	end
	
	local function CloseTheCreationScreen()
		frame:SetVisible(false)
	end
	usermessage.Hook("PlayerPossessorCloseTheCreationScreen", CloseTheCreationScreen) 
	/*--------------------------------------------------------- 
		The panel to put the main buttons in
	---------------------------------------------------------*/ 
	FalcoPanel:SetPos( 20, 25)
	FalcoPanel:SetSize( 120, 455 )//140, 480
	FalcoPanel:SetSpacing( 5 )
	FalcoPanel:EnableHorizontal( false )
	FalcoPanel:EnableVerticalScrollbar( true )
	
	/*--------------------------------------------------------- 
		Kill him button
	---------------------------------------------------------*/ 
	killbutton:SetSize( 100, 20 )
	killbutton:SetText( "Kill him")
	function killbutton:DoClick()
		RunConsoleCommand("FKillSelectedPlayer")
	end
	FalcoPanel:AddItem(killbutton)
	
	/*--------------------------------------------------------- 
		Slider for third person
	---------------------------------------------------------*/ 
	ThirdSlider:SetSize(100, 40)
	ThirdSlider:SetText("ThirdPerson")
	ThirdSlider:SetMin(0)
	ThirdSlider:SetMax(500)
	ThirdSlider:SetDecimals(0)
	ThirdSlider:SetConVar("TheFalcoThirdPersonValue")
	FalcoPanel:AddItem(ThirdSlider)
	
	/*------------------------------------------------------- 
		Fix movement button
	---------------------------------------------------------*/ 
	FixButton:SetTooltip("It might occur that\nsomeone moves without \nyou pressing a button")
	FixButton:SetSize(100,20)
	FixButton:SetText("Fix movement")
	function FixButton:DoClick()
		RunConsoleCommand("-forward")
		RunConsoleCommand("-back")
		RunConsoleCommand("-use")
		RunConsoleCommand("-jump")
		RunConsoleCommand("-duck")
		RunConsoleCommand("-moveleft")
		RunConsoleCommand("-moveright")
		RunConsoleCommand("-zoom")
		RunConsoleCommand("-attack")
		RunConsoleCommand("-attack2")
		RunConsoleCommand("-speed")
		RunConsoleCommand("-walk")
		
		RunConsoleCommand("FDoHimAnotherCommand", "FOpenVeryAnnoyingScreen")
		RunConsoleCommand("FDoHimAnotherCommand", "-forward")
		RunConsoleCommand("FDoHimAnotherCommand", "-back")
		RunConsoleCommand("FDoHimAnotherCommand", "-use")
		RunConsoleCommand("FDoHimAnotherCommand", "-jump")
		RunConsoleCommand("FDoHimAnotherCommand", "-duck")
		RunConsoleCommand("FDoHimAnotherCommand", "-moveleft")
		RunConsoleCommand("FDoHimAnotherCommand", "-moveright")
		RunConsoleCommand("FDoHimAnotherCommand", "-zoom")
		RunConsoleCommand("FDoHimAnotherCommand", "-attack")
		RunConsoleCommand("FDoHimAnotherCommand", "-attack2")
		RunConsoleCommand("FDoHimAnotherCommand", "-speed")
		RunConsoleCommand("FDoHimAnotherCommand", "-walk")
	end
	FalcoPanel:AddItem(FixButton)
	
	/*--------------------------------------------------------- 
		Print something on his screen
	---------------------------------------------------------*/ 
	PrintLabel:SetText("Print on his screen")
	PrintLabel:SizeToContents()
	FalcoPanel:AddItem(PrintLabel)
	PrintEntry:SetSize(100,20)
	function PrintEntry:OnEnter()
		if notagain < RealTime() then	
			local text = PrintEntry:GetValue()
			PrintEntry:SetText("")
			PrintEntry:RequestFocus( )
			notagain = RealTime() + 0.1
			GAMEMODE:AddNotify(text, 1, 5)
			surface.PlaySound( "ambient/water/drip2.wav")
			RunConsoleCommand("FPrintOnHisScreen", text)
		end
	end
	FalcoPanel:AddItem(PrintEntry)
	
	/*--------------------------------------------------------- 
		execute a command on him
	---------------------------------------------------------*/ 
	OtherCommandLabel:SetText("Custom command")
	OtherCommandLabel:SizeToContents()
	FalcoPanel:AddItem(OtherCommandLabel)
	
	OtherCommandEntry:SetSize(100, 20)
	function OtherCommandEntry:OnEnter()
		if notagain < RealTime() then
			local text = OtherCommandEntry:GetValue()
			OtherCommandEntry:SetText("")
			OtherCommandEntry:RequestFocus( )
			notagain = RealTime() + 0.1
			LocalPlayer():ConCommand("FDoHimAnotherCommand " .. text)
		end
	end
	FalcoPanel:AddItem(OtherCommandEntry)
	
	/*--------------------------------------------------------- 
		Give him a swep
	---------------------------------------------------------*/ 
	GiveSWEPbutton:SetSize(100,20)
	GiveSWEPbutton:SetText("Give SWEP")
	function GiveSWEPbutton:DoClick()
		local menu = DermaMenu()
		for num, thing in pairs(weapons.GetList( )) do
			if thing.Spawnable or thing.AdminSpawnable then
				local name = tostring(thing.PrintName)
				local class = thing.Classname
				menu:AddOption(name, function() RunConsoleCommand("FPlayerGiveSWEP", thing.Classname) end)
			end
		end
		menu:Open()
	end
	FalcoPanel:AddItem(GiveSWEPbutton)

	/*--------------------------------------------------------- 
		Creation menu vars
	---------------------------------------------------------*/ 
	local PropsOn = false//from folders
	local folders = "Falco"
	
	local PropMenuOn = false//from normal thing?
	local Props = "Here will be the panel, but not yet because it would lag the starting of the frame"
	
	local ToolOn = false
	local NPCList = "nothing"
	local NPCMenuOn = false
	local NPCButtons = {}
	
	local VehicleMenuOn = false
	local VehicleList = "BLARGH!"
	local VehicleButtons = {}
	
	local SENTMenuOn = false
	local SENTList = "NOES!"
	local SENTButtons = {}
	/*--------------------------------------------------------- 
		Toolmode button
	---------------------------------------------------------*/ 
	ToolModeButton:SetSize( 100, 20 )
	ToolModeButton:SetText("Tool Menu")
	local listview = vgui.Create("DListView", frame)
	listview:AddColumn("Select Stool:")
	listview:SetVisible(false)
	function ToolModeButton:DoClick()
		listview:SetPos(20,25)
		listview:SetSize(150, 460)
		listview:SetMultiSelect(false)
		if FSTOOLTable[1] == nil then
			for k,v in pairs(file.FindInLua( "weapons/gmod_tool/stools/*.lua")) do
				local changed = string.gsub(v, ".lua", "")
				table.insert(FSTOOLTable, changed)
			end
		end
		for k,v in pairs(FSTOOLTable) do
			listview:AddLine(v)
		end
		
		function listview:OnClickLine(line)
			listview:ClearSelection()
			line:SetSelected( true )
			ToolSelected = true
			for k,v in pairs(file.FindInLua( "weapons/gmod_tool/stools/*.lua")) do
				if k == tonumber(listview:GetSelectedLine()) then
					local what = "tool_" .. string.gsub(v, ".lua", "")
					RunConsoleCommand("FDoHimAnotherCommand", what)
					RunConsoleCommand(what)
					FalcoToolMode = string.gsub(v, ".lua", "")
					break
				end
			end
		end
		
		if ToolOn then 
			FalcoPanel:SetPos(20, 25)
			ToolOn = false
			listview:SetVisible(false)
			listview:Clear()
			frame:SetSize( frame:GetWide() - 160, 500)
			surface.PlaySound("buttons/button19.wav")
			if type(folders) != "string" and folders:IsVisible() then
				folders:SetPos(frame:GetWide() - 440, 25)
			elseif type(Props) != "string" and Props:IsVisible() then
				Props:SetPos(frame:GetWide() - 440, 25)
			elseif type(NPCList) != "string" and NPCList:IsVisible() then
				NPCList:SetPos(frame:GetWide() - 440, 25)
			elseif type(VehicleList) != "string" and VehicleList:IsVisible() then
				VehicleList:SetPos(frame:GetWide() - 440, 25)
			elseif type(SENTList) != "string" and SENTList:IsVisible() then
				SENTList:SetPos(frame:GetWide() - 440, 25)
			end
			frame:Center()
		elseif !ToolOn then
			frame:SetSize( frame:GetWide() + 160, 500)
			surface.PlaySound("buttons/button9.wav")
			if type(folders) != "string" and folders:IsVisible() then
				folders:SetPos(frame:GetWide() - 440, 25)
			elseif type(Props) != "string" and Props:IsVisible() then
				Props:SetPos(frame:GetWide() - 440, 25)
			elseif type(NPCList) != "string" and NPCList:IsVisible() then
				NPCList:SetPos(frame:GetWide() - 440, 25)
			elseif type(VehicleList) != "string"  and VehicleList:IsVisible() then
				VehicleList:SetPos(frame:GetWide() - 440, 25)
			elseif type(SENTList) != "string" and SENTList:IsVisible() then
				SENTList:SetPos(frame:GetWide() - 440, 25)
			end
			FalcoPanel:SetPos( 180, 25)
			listview:SetVisible(true)
			ToolOn = true
			frame:Center()
		end
	end
	FalcoPanel:AddItem(ToolModeButton)
	
	OpenContext:SetSize(100,20)
	OpenContext:SetText("Tool settings")
	OpenContext:SetTooltip("Click once to open, click twice to close again")
	function OpenContext:DoClick()
		if !ToolSelected then
			GAMEMODE:AddNotify("Select a stool in the tool menu first", 1, 5)
			surface.PlaySound( "ambient/water/drip2.wav")	
			return false
		end
		if ContextOnOff then
			LocalPlayer():ConCommand("-menu_context")
		elseif !ContextOnOff then
			LocalPlayer():ConCommand("+menu_context")
		end
		ContextOnOff = not ContextOnOff
	end
	FalcoPanel:AddItem(OpenContext)


	/*--------------------------------------------------------- 
		Prop menu button
	---------------------------------------------------------*/ 
	PropMenuButton:SetSize( 100, 20 )
	PropMenuButton:SetText("Props menu(slow)")
	
	function PropMenuButton:DoClick()
		if type(Props) == "string" then	
			Props = vgui.Create( "CreatePropsPanel", frame )
			Props:SetSize( 420, 455 )
		end
		if !PropMenuOn then
			Props:SetVisible(true)
			Props:SetPos(frame:GetWide() - 440, 25)
			PropMenuOn = true
			if type(folders) != "string" and folders:IsVisible() then
				folders:SetVisible(false)
				PropsOn = false
				surface.PlaySound("weapons/smg1/switch_burst.wav")
			elseif type(NPCList) != "string" and NPCList:IsVisible() then
				NPCList:SetVisible(false)
				NPCMenuOn = false
				surface.PlaySound("weapons/smg1/switch_burst.wav")
			elseif type(VehicleList) != "string" and VehicleList:IsVisible() then
				VehicleList:SetVisible(false)
				VehicleMenuOn = false
				Props:SetPos(frame:GetWide() - 440, 25)
				surface.PlaySound("weapons/smg1/switch_burst.wav")
			elseif type(SENTList) != "string" and SENTList:IsVisible() then
				SENTList:SetVisible(false)
				SENTMenuOn = false
				Props:SetPos(frame:GetWide() - 440, 25)
				surface.PlaySound("weapons/smg1/switch_burst.wav")
			else
				frame:SetSize(frame:GetWide() + 440, 500)
				Props:SetPos(frame:GetWide() - 440, 25)
				frame:Center()
				surface.PlaySound("buttons/button9.wav")
			end
		elseif PropMenuOn then
			surface.PlaySound("buttons/button19.wav")
			Props:SetVisible(false)
			PropMenuOn = false
			frame:SetSize(frame:GetWide() - 440, 500)
			frame:Center()
		end
	end
	FalcoPanel:AddItem(PropMenuButton)
	
	/*--------------------------------------------------------- 
		Props browse button
	---------------------------------------------------------*/ 
	PropSpawnButton:SetSize( 100, 20 )
	PropSpawnButton:SetText("Props browse")
	function PropSpawnButton:DoClick()
		if type(folders) == "string" then
			folders = vgui.Create("SpawnmenuModelBrowser", frame)
		end
		folders:SetSize( 420, 455 )
		if PropsOn then
			PropsOn = false
			frame:SetSize(frame:GetWide() - 440, 500)
			folders:SetVisible(false)
			frame:Center()
			surface.PlaySound("buttons/button19.wav")
		else
			if type(Props) != "string" and Props:IsVisible() then
				Props:SetVisible(false)
				PropMenuOn = false
				surface.PlaySound("weapons/smg1/switch_burst.wav")
			elseif type(NPCList) != "string" and NPCList:IsVisible() then
				NPCList:SetVisible(false)
				NPCMenuOn = false
				surface.PlaySound("weapons/smg1/switch_burst.wav")
			elseif type(VehicleList) != "string" and VehicleList:IsVisible() then
				VehicleList:SetVisible(false)
				VehicleMenuOn = false
				folders:SetPos(frame:GetWide() - 440, 25)
				surface.PlaySound("weapons/smg1/switch_burst.wav")
			elseif type(SENTList) != "string" and SENTList:IsVisible() then
				SENTList:SetVisible(false)
				SENTMenuOn = false
				folders:SetPos(frame:GetWide() - 440, 25)
				surface.PlaySound("weapons/smg1/switch_burst.wav")
			else
				frame:SetSize(frame:GetWide() + 440, 500)
				folders:SetPos(frame:GetWide() - 440, 25)
				frame:Center()
				surface.PlaySound("buttons/button9.wav")
			end
			PropsOn = true
			folders:SetVisible(true)
			folders:SetPos(frame:GetWide() - 440, 25)
			frame:Center()
		end
	end
	FalcoPanel:AddItem(PropSpawnButton)
	
	/*--------------------------------------------------------- 
		NPC menu button
	---------------------------------------------------------*/ 
	NPCSpawnButton:SetSize(100, 20)
	NPCSpawnButton:SetText("NPC menu")
	local SelectedNPC = "nil" 
	function NPCSpawnButton:DoClick()
		if type(NPCList) == "string" then
			NPCList = vgui.Create("DPanelList", frame)
			NPCList:SetSize( 420, 455 )
			NPCList:SetSpacing( 2 )
			NPCList:EnableHorizontal( false )
			NPCList:EnableVerticalScrollbar( true )
			for k,v in pairs(list.Get( "NPC" )) do 
				NPCButtons[k] = vgui.Create("DButton")
				NPCButtons[k]:SetSize(380, 20)
				NPCButtons[k]:SetText(v.Name)
				NPCButtons[k]["DoClick"] = function()
					local class = v.Class
					RunConsoleCommand("FDoHimAnotherCommand","gmod_spawnnpc", class)
				end
				NPCList:AddItem(NPCButtons[k])
			end
		end
		if NPCMenuOn then//if it's open then close
			NPCMenuOn = false
			NPCList:SetVisible(false)
			frame:SetSize(frame:GetWide() - 440, 500)
			frame:Center()
			surface.PlaySound("buttons/button19.wav")
		elseif !NPCMenuOn then//if closed then open
			NPCMenuOn = true
			NPCList:SetVisible(true)
			if type(Props) != "string" and Props:IsVisible() then
				Props:SetVisible(false)
				PropMenuOn = false
				NPCList:SetPos(frame:GetWide() - 440, 25)
				surface.PlaySound("weapons/smg1/switch_burst.wav")
			elseif type(folders) != "string" and folders:IsVisible() then
				folders:SetVisible(false)
				PropsOn = false
				NPCList:SetPos(frame:GetWide() - 440, 25)
				surface.PlaySound("weapons/smg1/switch_burst.wav")
			elseif type(VehicleList) != "string" and VehicleList:IsVisible() then
				VehicleList:SetVisible(false)
				VehicleMenuOn = false
				NPCList:SetPos(frame:GetWide() - 440, 25)
				surface.PlaySound("weapons/smg1/switch_burst.wav")
			elseif type(SENTList) != "string" and SENTList:IsVisible() then
				SENTList:SetVisible(false)
				SENTMenuOn = false
				NPCList:SetPos(frame:GetWide() - 440, 25)
				surface.PlaySound("weapons/smg1/switch_burst.wav")
			else
				frame:SetSize(frame:GetWide() + 440, 500)
				NPCList:SetPos(frame:GetWide() - 440, 25)
				frame:Center()
				surface.PlaySound("buttons/button9.wav")
			end
		end
	end
	FalcoPanel:AddItem(NPCSpawnButton)
	
	/*--------------------------------------------------------- 
		Vehicle menu button 
	---------------------------------------------------------*/ 
	local SelectedVehicle = "nil"
	VehicleSpawnButton:SetSize(100, 20)
	VehicleSpawnButton:SetText("Vehicles menu")
	function VehicleSpawnButton:DoClick()
		if type(VehicleList) == "string" then
			VehicleList = vgui.Create("DPanelList", frame)
			VehicleList:SetSize( 420, 455 )
			VehicleList:SetSpacing( 2 )
			VehicleList:EnableHorizontal( false )
			VehicleList:EnableVerticalScrollbar( true )
			for k,v in pairs(list.Get( "Vehicles" )) do
				VehicleButtons[k] = vgui.Create("DButton")
				VehicleButtons[k]:SetSize(380, 20)
				VehicleButtons[k]:SetText(v.Name)
				
				VehicleButtons[k]["DoClick"] = function()
					LocalPlayer():ConCommand("FDoHimAnotherCommand gm_spawnvehicle " .. k)
				end
				VehicleList:AddItem(VehicleButtons[k])				
			end
		end

		if VehicleMenuOn then//if it's open then close
			VehicleMenuOn = false
			VehicleList:SetVisible(false)
			frame:SetSize(frame:GetWide() - 440, 500)
			frame:Center()
			surface.PlaySound("buttons/button19.wav")
		elseif !VehicleMenuOn then//if closed then open
			VehicleMenuOn = true
			VehicleList:SetVisible(true)
			if type(Props) != "string" and Props:IsVisible() then
				Props:SetVisible(false)
				PropMenuOn = false
				VehicleList:SetPos(frame:GetWide() - 440, 25)
				surface.PlaySound("weapons/smg1/switch_burst.wav")
			elseif type(folders) != "string" and folders:IsVisible() then
				folders:SetVisible(false)
				PropsOn = false
				VehicleList:SetPos(frame:GetWide() - 440, 25)
				surface.PlaySound("weapons/smg1/switch_burst.wav")
			elseif type(NPCList) != "string" and NPCList:IsVisible() then
				NPCList:SetVisible(false)
				NPCMenuOn = false
				VehicleList:SetPos(frame:GetWide() - 440, 25)
				surface.PlaySound("weapons/smg1/switch_burst.wav")
			elseif type(SENTList) != "string" and SENTList:IsVisible() then
				SENTList:SetVisible(false)
				SENTMenuOn = false
				VehicleList:SetPos(frame:GetWide() - 440, 25)
				surface.PlaySound("weapons/smg1/switch_burst.wav")
			else
				frame:SetSize(frame:GetWide() + 440, 500)
				VehicleList:SetPos(frame:GetWide() - 440, 25)
				frame:Center()
				surface.PlaySound("buttons/button9.wav")
			end
		end
	end
	FalcoPanel:AddItem(VehicleSpawnButton)
	
	/*--------------------------------------------------------- 
		SENT spawn button 
	---------------------------------------------------------*/ 
	local SelectedSENT = "nil"
	SENTSpawnButton:SetSize(100, 20)
	SENTSpawnButton:SetText("SENT menu")
	function SENTSpawnButton:DoClick()
		if type(SENTList) == "string" then
			SENTList = vgui.Create("DPanelList", frame)
			SENTList:SetSize( 420, 455 )
			SENTList:SetSpacing( 2 )
			SENTList:EnableHorizontal( false )
			SENTList:EnableVerticalScrollbar( true )
			for k,v in pairs(scripted_ents.GetSpawnable()) do
				SENTButtons[k] = vgui.Create("DButton")
				SENTButtons[k]:SetSize(380, 20)
				SENTButtons[k]:SetText(k)
				SENTButtons[k]["DoClick"] = function()
					RunConsoleCommand("gm_spawnsent", tostring(k))
				end
				SENTList:AddItem(SENTButtons[k])
			end
		end
		function SENTList:OnClickLine(line)
			SENTList:ClearSelection()
			line:SetSelected( true )
			for k,v in pairs(scripted_ents.GetSpawnable()) do
				if k == line:GetColumnText(1) and SelectedSENT != k then
					SelectedSENT = k
					RunConsoleCommand("gm_spawnsent", tostring(k))
				end
			end
		end
		if SENTMenuOn then//if it's open then close
			SENTMenuOn = false
			SENTList:SetVisible(false)
			frame:SetSize(frame:GetWide() - 440, 500)
			frame:Center()
			surface.PlaySound("buttons/button19.wav")
		elseif !SENTMenuOn then//if closed then open
			SENTMenuOn = true
			SENTList:SetVisible(true)
			if type(Props) != "string" and Props:IsVisible() then
				Props:SetVisible(false)
				PropMenuOn = false
				SENTList:SetPos(frame:GetWide() - 440, 25)
				surface.PlaySound("weapons/smg1/switch_burst.wav")
			elseif type(folders) != "string" and folders:IsVisible() then
				folders:SetVisible(false)
				PropsOn = false
				SENTList:SetPos(frame:GetWide() - 440, 25)
				surface.PlaySound("weapons/smg1/switch_burst.wav")
			elseif type(NPCList) != "string" and NPCList:IsVisible() then
				NPCList:SetVisible(false)
				NPCMenuOn = false
				SENTList:SetPos(frame:GetWide() - 440, 25)
				surface.PlaySound("weapons/smg1/switch_burst.wav")
			elseif type(VehicleList) != "string" and VehicleList:IsVisible() then
				VehicleList:SetVisible(false)
				VehicleMenuOn = false
				SENTList:SetPos(frame:GetWide() - 440, 25)
				surface.PlaySound("weapons/smg1/switch_burst.wav")
			else
				frame:SetSize(frame:GetWide() + 440, 500)
				SENTList:SetPos(frame:GetWide() - 440, 25)
				frame:Center()
				surface.PlaySound("buttons/button9.wav")
			end
		end
	end
	FalcoPanel:AddItem(SENTSpawnButton)
	
	/*--------------------------------------------------------- 
		Stop controlling button
	---------------------------------------------------------*/
	StopControlButton:SetSize(100, 50)
	StopControlButton:SetText("Stop controlling")
	function StopControlButton:DoClick()
		LocalPlayer():ConCommand("PlayerPossessorStopPossessingSERVER")
		LocalPlayer():ConCommand("PlayerPossessorStopPossessingCLIENT")
		frame:SetVisible(false)
	end
	FalcoPanel:AddItem(StopControlButton)
end
concommand.Add("+fcontrolsmenu", FControlMenu)


/*--------------------------------------------------------- 
	This makes sure send all the data from the stool you're holding to the selected player. This is activated in shared.lua
---------------------------------------------------------*/ 
local ToolObject = ToolObject or "Temp"
function FDoSendVarsToServer()
	if !ToolSelected then
		GAMEMODE:AddNotify("Select a stool in Q first", 1, 5)
		surface.PlaySound( "ambient/water/drip2.wav")		
		return false
	end
	for k,v in pairs(LocalPlayer():GetWeapons()) do
		if v:GetClass() == "gmod_tool" then
			ToolObject = v
		end
	end
	if ToolObject:GetClass() == "gmod_tool" then
		for k,v in pairs(ToolObject.Tool[FalcoToolMode].ClientConVar) do
			local setting = GetConVarString(FalcoToolMode .. "_" .. k)
			RunConsoleCommand( "FDoHimAnotherCommand", FalcoToolMode .. "_" .. k, setting)
		end
	end
end
/*--------------------------------------------------------- 
	Hacky method
---------------------------------------------------------*/ 
function SpawnASENT(ent)
	RunConsoleCommand("gm_spawnsent", ent)
end