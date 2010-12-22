local function ScoreboardAddTeam(Name, color)
	local ScreenWidth, ScreenHeight = ScrW(), ScrH()
	
	local cat = vgui.Create("FAdminPlayerCatagory")
	cat:SetLabel("  "..Name)
	cat.CatagoryColor = color
	cat:SetWide((FAdmin.ScoreBoard.Width - 40)/2)
	
	function cat:Toggle()
	end
	
	local pan = vgui.Create("FAdminPanelList")
	pan:SetSpacing(2)
	pan:EnableHorizontal(true)
	pan:EnableVerticalScrollbar(true)
	pan:SizeToContents()
	
	cat:SetContents(pan)
	
	FAdmin.ScoreBoard.Main.Controls.FAdminPanelList:AddItem(cat)
	return cat, pan
end

function FAdmin.ScoreBoard.Main.PlayerIconView()
	local ScreenWidth, ScreenHeight = ScrW(), ScrH()
	if GAMEMODE.Name == "Sandbox" then
		local cats = {}
		for k, ply in pairs(player.GetAll()) do
			local root_user, rootColor = ply:GetNWString("usergroup") == "root_user", Color(130, 0, 0, 255)
			local superadmin, sadminColor = ply:IsSuperAdmin(), Color(30, 200, 50)
			local admin, adminColor = ply:IsAdmin() and not ply:IsSuperAdmin(), Color(0, 120, 130)
			local status, statusColor
			
			if admin then status, statusColor = "admin", adminColor
			elseif superadmin and not root_user then status, statusColor = "superadmin", sadminColor
			elseif root_user then status, statusColor = "root user", rootColor
			else status, statusColor = "user", Color(100, 150, 245) end
			
			local icon = vgui.Create("FAdminPlayerIcon")
			icon:SetPlayer(ply)
			icon:SetSize(96, 116)
			
			function icon:OnMouseReleased()
				FAdmin.ScoreBoard.ChangeView("Player", self.Player)
			end
			
			local cat
			if not cats[status] then
				cat, cats[status] = ScoreboardAddTeam(status, statusColor)
			end
			cats[status]:AddItem(icon)
			cats[status]:SizeToContents()
			
			local x, y, w, h, xtop = 5, 201, 96, 116, 20
			for k,v in pairs(cats[status].Items) do -- Special invalidate layout
				if x + w  > (FAdmin.ScoreBoard.Width - 40)/2 then
					xtop = (FAdmin.ScoreBoard.Width - 40)/2 //+ cats[status].Spacing
					x = 5
					y = y + h + cats[status].Spacing
				end
				cat.Header:SizeToContents()
				cat.Header:SetTall(25)
				
				xtop = math.Min(xtop + w + cats[status].Spacing, (FAdmin.ScoreBoard.Width - 40)/2 - cats[status].Spacing)//+ cats[status].Spacing)
				x = x + w + cats[status].Spacing
			end
			
			if cat then
				surface.SetFont("Trebuchet24")
				local HeaderSize = surface.GetTextSize(cat.Header:GetValue())
				cat:SetTall(y)
				cats[status]:SetTall(y-72)
				cat:SetWide(math.Max(xtop, HeaderSize))
			end
		end
	else
		for Team, TeamTable in SortedPairsByMemberValue(team.GetAllTeams(), "Name") do
			if #team.GetPlayers(Team) > 0 then
				local cat, pan = ScoreboardAddTeam(TeamTable.Name, TeamTable.Color)
				for _, ply in pairs(team.GetPlayers(Team)) do
					local icon = vgui.Create("FAdminPlayerIcon")
					icon:SetPlayer(ply)
					icon:SetSize(96, 116)
					function icon:OnMouseReleased(mcode)
						if mcode == MOUSE_LEFT then
							FAdmin.ScoreBoard.ChangeView("Player", self.Player)
						end
					end
					pan:AddItem(icon)
					pan:SizeToContents()
				end
				
				local x, y, w, h, xtop = 5, 201, 96, 116, 20
				for k,v in pairs(pan.Items) do -- Special invalidate layout
					if x + w  > (FAdmin.ScoreBoard.Width - 40)/2 then
						xtop = (FAdmin.ScoreBoard.Width - 40)/2 
						x = 5
						y = y + h + pan.Spacing
					end
					cat.Header:SizeToContents()
					cat.Header:SetTall(25)
					
					xtop = math.Min(xtop + w + pan.Spacing, (FAdmin.ScoreBoard.Width - 40)/2 - pan.Spacing)
					x = x + w + pan.Spacing
				end
				
				if cat then
					surface.SetFont("Trebuchet24")
					local HeaderSize = surface.GetTextSize(cat.Header:GetValue())
					cat:SetTall(y)
					pan:SetTall(y-72)
					cat:SetWide(math.Max(xtop, HeaderSize))
				end
			end
		end
	end
end

local function SortedPairsByFunction(Table, Sorted, SortDown)
	local CopyTable = {}
	for k,v in pairs(Table) do
		table.insert(CopyTable, {NAME = v:Nick(), PLY = v})
	end
	table.SortByMember(CopyTable, "NAME", SortDown)
	
	local SortedTable = {}
	for k,v in ipairs(CopyTable) do
		local SortBy = (Sorted ~= "Team" and v.PLY[Sorted](v.PLY)) or team.GetName(v.PLY[Sorted](v.PLY))
		SortedTable[SortBy] = SortedTable[SortBy] or {}
		table.insert(SortedTable[SortBy], v.PLY)
	end
	
	local SecondSort = {}
	for k,v in SortedPairs(SortedTable, SortDown) do
		table.insert(SecondSort, v)
	end
	
	CopyTable = {}
	for k,v in pairs(SecondSort) do
		for a,b in pairs(v) do
			table.insert(CopyTable, b)
		end
	end

	return ipairs(CopyTable)
end

function FAdmin.ScoreBoard.Main.PlayerListView(Sorted, SortDown)
	for k, ply in SortedPairsByFunction(player.GetAll(), Sorted, SortDown) do
		local Row = vgui.Create("FadminPlayerRow", FAdmin.ScoreBoard.Main.Controls.FAdminPanelList)
		Row:SetPlayer(ply)
		Row:InvalidateLayout()
		FAdmin.ScoreBoard.Main.Controls.FAdminPanelList:AddItem(Row)
	end
end