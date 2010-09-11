local ContinueNewGroup

local function RetrievePrivs(um)
	local Priv = um:ReadString()
	if not Priv then return end
	LocalPlayer().FADMIN_PRIVS = LocalPlayer().FADMIN_PRIVS or {}
	table.insert(LocalPlayer().FADMIN_PRIVS, Priv)
end
usermessage.Hook("FADMIN_RetrievePrivs", RetrievePrivs)


hook.Add("FAdmin_PluginsLoaded", "1SetAccess", function() -- 1 in hook name so it will be executed first.
	FAdmin.Commands.AddCommand("setaccess", nil, "<Player>", "<Group name>", "[new group based on (number)]", "[new group privileges]")
	
	FAdmin.ScoreBoard.Player:AddActionButton("Set access", "FAdmin/icons/access", Color(255, 0, 0, 255), 
	function(ply) return FAdmin.Access.PlayerHasPrivilege(LocalPlayer(), "SetAccess") end, function(ply)
		local menu = DermaMenu()
		local Title = vgui.Create("DLabel")
		Title:SetText("  Set access:\n")
		Title:SetFont("UiBold")
		Title:SizeToContents()
		Title:SetTextColor(color_black)
		
		menu:AddPanel(Title)
		
		for k,v in SortedPairsByMemberValue(FAdmin.Access.Groups, "ADMIN", true) do
			menu:AddOption(k, function() RunConsoleCommand("_FAdmin", "setaccess", ply:UserID(), k) end)
		end
		
		RunConsoleCommand("_FAdmin_SendUserGroups")
		
		local Other = menu:AddSubMenu("Other")
		local NoOthers = Other:AddOption("Loading/no other groups")
		local function ReceiveGroup(um)
			local GroupName = um:ReadString()
			if not FAdmin.Access.Groups[GroupName] then
				Other:AddOption(GroupName, function() RunConsoleCommand("_FAdmin", "setaccess", ply:UserID(), GroupName) end)
				
				for k,v in pairs(Other.Panels) do
					if v:GetValue() == "Loading/no other groups" then Other.Panels[k] = nil v:Remove() break end
				end
			end
		end
		usermessage.Hook("FADMIN_RetrieveGroup", ReceiveGroup)
		
		menu:AddOption("New...", function()
			local name = ""
			
			Derma_StringRequest("Set name", 
			"What will be the name of the new group?",
			"",
			function(text)
				if text == "" then return end
				name = text 
				Derma_Query("On what access will this team be based? (the new group will inherit all the privileges from the group)", "Admin access",
					"user", function() ContinueNewGroup(ply, name, 0) end,
					"admin", function() ContinueNewGroup(ply, name, 1) end,
					"superadmin", function() ContinueNewGroup(ply, name, 2) end,
					"root user", function() ContinueNewGroup(ply, name, 3) end)
			end)
		end)
		menu:Open()
	end)
	
	--Removing groups
	FAdmin.ScoreBoard.Server:AddPlayerAction("Remove custom group", "FAdmin/icons/access", Color(0, 155, 0, 255), true, function(button)
		local Panel = vgui.Create("DListView")
		Panel:AddColumn("Group names:")
		Panel:SetPos(gui.MouseX(), gui.MouseY())
		Panel:SetSize(150, 200)
		function Panel:Think()
			if not FAdmin.ScoreBoard.Visible then self:Remove() return end
			if input.IsMouseDown(MOUSE_FIRST) then 
				local X, Y = self:GetPos()
				local W, H = self:GetWide(), self:GetTall()
				local MX, MY = gui.MouseX(), gui.MouseY()
				if MX < X or MY < Y
				or MX > X+W or MY > Y+H then
					self:Remove() 
				end
			end
		end
		
		RunConsoleCommand("_FAdmin_SendUserGroups")
		local NoOthers = Panel:AddLine("Loading/no custom groups")
		local RemoveFirst = true
		local function ReceiveGroup(um)
			local GroupName = um:ReadString()
			
			if not FAdmin.Access.Groups[GroupName] then
				if RemoveFirst then Panel:RemoveLine(1) end -- remove the "Loading/no custom groups" line
				RemoveFirst = false
				
				local Line = Panel:AddLine(GroupName)
				function Line:OnSelect()
					RunConsoleCommand("_FAdmin", "RemoveGroup", self:GetValue(1))
					Panel:RemoveLine(self:GetID())
				end
			end
		end
		usermessage.Hook("FADMIN_RetrieveGroup", ReceiveGroup)
	end)
end)

ContinueNewGroup = function(ply, name, admin_access)
	local privs = {}
	
	local Window = vgui.Create( "DFrame" )
	Window:SetTitle( "Set the privileges" )
	Window:SetDraggable(false)
	Window:ShowCloseButton(true)
	Window:SetBackgroundBlur(true)
	Window:SetDrawOnTop(true)
	Window:SetSize(120, 400)
	gui.EnableScreenClicker(true)
	function Window:Close()
		gui.EnableScreenClicker(false)
		self:Remove()
	end
	
	local TickBoxPanel = vgui.Create("DPanelList", Window)
	TickBoxPanel:StretchToParent(5, 25, 5, 5)
	TickBoxPanel:EnableHorizontal(false)
	TickBoxPanel:EnableVerticalScrollbar()
	TickBoxPanel:SetSpacing(5)
	
	for Pname, Padmin_access in SortedPairs(FAdmin.Access.Privileges) do
		local chkBox = vgui.Create("DCheckBoxLabel")
		chkBox:SetText(Pname)
		chkBox:SizeToContents()
		
		if Padmin_access <= admin_access then
			chkBox:SetValue(true)
			chkBox:SetDisabled(true)
		end
		
		function chkBox.Button:Toggle()
			if ( self:GetChecked() == nil || !self:GetChecked() ) then
				self:SetValue( true )
				table.insert(privs, Pname)
			else
				self:SetValue( false )
				for k,v in pairs(privs) do
					if v == Pname then
						table.remove(privs, k)
					end
				end
			end
		end
		
		TickBoxPanel:AddItem(chkBox)
	end
	TickBoxPanel:SetTall(math.Min(#TickBoxPanel.Items*20, ScrH() - 30))
	Window:SetTall(math.Min(#TickBoxPanel.Items*20 + 30 + 30, ScrH()))
	Window:Center()
	
	local OKButton = vgui.Create("DButton", Window)
	OKButton:SetText("OK")
	OKButton:StretchToParent(5, #TickBoxPanel.Items*20 + 30, Window:GetWide()/2 + 2 , 5)
	function OKButton:DoClick()
		RunConsoleCommand("_FAdmin", "setaccess", ply:UserID(), name, admin_access, unpack(privs))
		Window:Close()
	end
	
	local CancelButton = vgui.Create("DButton", Window)
	CancelButton:SetText("Cancel")
	CancelButton:StretchToParent(Window:GetWide()/2 + 2, #TickBoxPanel.Items*20 + 30, 5, 5)
	function CancelButton:DoClick()
		Window:Close()
	end
end