local AdminPanel
local BuddiesPanel
local BlockedLists = {}
local CatsOpened = {}
FPP = FPP or {}
function FPP.AdminMenu(Panel)
	AdminPanel = AdminPanel or Panel
	Panel:ClearControls()
	local superadmin = LocalPlayer():IsSuperAdmin()
	if not superadmin then
		Panel:AddControl("Label", {Text = "You are not a superadmin\nThe changes you make will not have any effect."})
	end
	
	local function MakeOption(Name)
		local cat = vgui.Create("DCollapsibleCategory")
		cat:SetLabel(Name)
		cat:SetExpanded(CatsOpened[Name])
		cat.oldtoggle = cat.Toggle
		function cat:Toggle()
			self:oldtoggle()
			CatsOpened[Name] = cat:GetExpanded()
		end
		
		local pan = vgui.Create("DPanelList")
		pan:SetSpacing(5)
		pan:EnableHorizontal(false)
		pan:EnableVerticalScrollbar(true)
		pan:SetAutoSize(true)
		cat:SetContents(pan)
		AdminPanel:AddPanel(cat)
		return cat, pan
	end
	
	local function addchk(label, command, plist)
		local box = vgui.Create("DCheckBoxLabel")
		box:SetText(label)
		box:SetValue(GetGlobalInt(command[1].."_"..command[2]))
		box.Button.Toggle = function()
			if not superadmin then return end--Hehe now you can't click it anymore non-admin!
			if box.Button:GetChecked() == nil or not box.Button:GetChecked() then 
				box.Button:SetValue( true ) 
			else 
				box.Button:SetValue( false ) 
			end 
			local tonum = {}
			tonum[false] = "0"
			tonum[true] = "1"
			RunConsoleCommand("FPP_Setting", command[1], command[2], tonum[box.Button:GetChecked()])
		end
		plist:AddItem(box)
	end
	
	local function addblock(pan, Type)
		local label = vgui.Create("DLabel")
		label:SetText("\n"..Type.." black/whitelist entities:")
		label:SizeToContents()
		pan:AddItem(label)
		
		local lview = vgui.Create("DListView")
		lview:AddColumn("Entity")
		pan:AddItem(lview)
		BlockedLists[string.lower(Type)] = lview
		RunConsoleCommand("FPP_sendblocked", Type)
		
		local RemoveSelected = vgui.Create("DButton")
		RemoveSelected:SetText("Remove Selected items from the list")
		RemoveSelected:SetDisabled(not superadmin)
		RemoveSelected.DoClick = function()
			for k,v in pairs(lview.Lines) do
				if v:GetSelected() then
					RunConsoleCommand("FPP_RemoveBlocked", Type, v.text)
					lview:RemoveLine(k)
					lview:SetTall(17 + #lview:GetLines() * 17)
					pan:InvalidateLayout()
					pan:GetParent():GetParent():InvalidateLayout()
				end
			end
		end
		pan:AddItem(RemoveSelected)
		
		local AddLA = vgui.Create("DButton")
		AddLA:SetText("Add the entity you're looking at")
		AddLA:SetDisabled(not superadmin)
		AddLA.DoClick = function()
			local ent = LocalPlayer():GetEyeTrace().Entity
			if not ValidEntity(ent) then return end
			for k,v in pairs(lview.Lines) do
				if v.text == string.lower(ent:GetClass()) then return end
			end
			RunConsoleCommand("FPP_AddBlocked", Type, ent:GetClass())
			
			lview:AddLine(ent:GetClass()).text = ent:GetClass()
			lview:SetTall(17 + #lview:GetLines() * 17)
			pan:InvalidateLayout()
			pan:GetParent():GetParent():InvalidateLayout()
		end
		pan:AddItem(AddLA)
		
		local AddManual = vgui.Create("DButton")
		AddManual:SetText("Add entity manually")
		AddManual:SetDisabled(not superadmin)
		AddManual.DoClick = function()
			Derma_StringRequest("Enter entity manually", "Enter the classname of the entity you would like to add.", nil, 
			function(a) 
			RunConsoleCommand("FPP_AddBlocked", Type, a)
			end, function() end )
		end
		pan:AddItem(AddManual)
	end
	
	local GeneralCat, general = MakeOption("General options")
	addchk("Cleanup disconnected players's entities", {"FPP_GLOBALSETTINGS", "cleanupdisconnected"}, general)
	addchk("Cleanup admin's entities on disconnect", {"FPP_GLOBALSETTINGS", "cleanupadmin"}, general)
		local deltime = vgui.Create("DNumSlider")
		deltime:SetMinMax(0, 300)
		deltime:SetDecimals(0)
		deltime:SetText("Deletion time")
		deltime:SetValue(GetGlobalInt("FPP_GLOBALSETTINGS_cleanupdisconnectedtime"))
		function deltime.Slider:OnMouseReleased()
			self:SetDragging( false ) 
			self:MouseCapture( false ) 
			if not superadmin then
				deltime:SetValue(GetGlobalInt("FPP_GLOBALSETTINGS_cleanupdisconnectedtime"))
				return
			end
			RunConsoleCommand("FPP_Setting", "FPP_GLOBALSETTINGS", "cleanupdisconnectedtime", deltime:GetValue())
		end
		function deltime.Wang:EndWang()
			self:MouseCapture( false ) 
			self.Dragging = false 
			self.HoldPos = nil 
			self.Wanger:SetCursor( "" ) 
			if ( ValidPanel( self.IndicatorT ) ) then self.IndicatorT:Remove() end 
			if ( ValidPanel( self.IndicatorB ) ) then self.IndicatorB:Remove() end
			if not superadmin then
				deltime:SetValue(GetGlobalInt("FPP_GLOBALSETTINGS_cleanupdisconnectedtime"))
				return
			end			
			RunConsoleCommand("FPP_Setting", "FPP_GLOBALSETTINGS", "cleanupdisconnectedtime", deltime:GetValue())
		end
		
		function deltime.Wang.TextEntry:OnEnter()
			if not superadmin then
				deltime:SetValue(GetGlobalInt("FPP_GLOBALSETTINGS_cleanupdisconnectedtime"))
				return
			end
			RunConsoleCommand("FPP_Setting", "FPP_GLOBALSETTINGS", "cleanupdisconnectedtime", deltime:GetValue())
		end
		general:AddItem(deltime)
		
		local delnow = vgui.Create("DButton")
		delnow:SetText("Delete disconnected players' entities")
		delnow:SetConsoleCommand("FPP_cleanup", "disconnected")
		delnow:SetDisabled(not superadmin)
		general:AddItem(delnow)
		
		local other = Label("\nDelete other player's entities:")
		other:SizeToContents()
		general:AddItem(other)
		
		local areplayers = false
		for k,v in pairs(player.GetAll()) do
			if v ~= LocalPlayer() then
				areplayers = true
				local rm = vgui.Create("DButton")
				rm:SetText(v:Nick())
				rm:SetConsoleCommand("FPP_Cleanup", v:UserID())
				rm:SetDisabled(not superadmin)
				general:AddItem(rm)
			end
		end
		if not areplayers then
			local nope = Label("<No players available>")
			nope:SizeToContents()
			general:AddItem(nope)
		end
	
	local physcat, physgun = MakeOption("Physgun options")
	addchk("Physgun protection enabled", {"FPP_PHYSGUN", "toggle"}, physgun)
	addchk("Admins can physgun all entities", {"FPP_PHYSGUN", "adminall"}, physgun)
	addchk("People can physgun world entities", {"FPP_PHYSGUN", "worldprops"}, physgun)
	addchk("Admins can physgun world entities", {"FPP_PHYSGUN", "adminworldprops"}, physgun)
	addchk("People can physgun blocked entities", {"FPP_PHYSGUN", "canblocked"}, physgun)
	addchk("Admins can physgun blocked entities", {"FPP_PHYSGUN", "admincanblocked"}, physgun)
	addchk("Show cross when unable to physgun entities", {"FPP_PHYSGUN", "shownocross"}, physgun)
	addchk("Check constrained entities", {"FPP_PHYSGUN", "checkconstrained"}, physgun)
	addchk("Prop surf/push/kill protection", {"FPP_PHYSGUN", "antinoob"}, physgun)
	addchk("Physgun reload protection enabled", {"FPP_PHYSGUN", "reloadprotection"}, physgun)
	addchk("The blocked list is a white list", {"FPP_PHYSGUN", "iswhitelist"}, physgun)
	addblock(physgun, "Physgun")
	
	local gravcat, gravgun = MakeOption("Gravity gun options")
	addchk("Gravity gun protection enabled", {"FPP_GRAVGUN", "toggle"}, gravgun)
	addchk("Admins can gravgun all entities", {"FPP_GRAVGUN", "adminall"}, gravgun)
	addchk("People can gravgun world entities", {"FPP_GRAVGUN", "worldprops"}, gravgun)
	addchk("Admins can gravgun world entities", {"FPP_GRAVGUN", "adminworldprops"}, gravgun)
	addchk("People can gravgun blocked entities", {"FPP_GRAVGUN", "canblocked"}, gravgun)
	addchk("Admins can gravgun blocked entities", {"FPP_GRAVGUN", "admincanblocked"}, gravgun)
	addchk("Show cross when unable to gravgun entities", {"FPP_GRAVGUN", "shownocross"}, gravgun)
	addchk("Check constrained entities", {"FPP_GRAVGUN", "checkconstrained"}, gravgun)
	addchk("People can't punt props", {"FPP_GRAVGUN", "noshooting"}, gravgun)
	addchk("The blocked list is a white list", {"FPP_GRAVGUN", "iswhitelist"}, gravgun)
	addblock(gravgun, "Gravgun")
	
	local toolcat, toolgun = MakeOption("Toolgun options")
	addchk("Toolgun protection enabled", {"FPP_TOOLGUN", "toggle"}, toolgun)
	addchk("Admins can use tool all entities", {"FPP_TOOLGUN", "adminall"}, toolgun)
	addchk("People can use tool on world entities", {"FPP_TOOLGUN", "worldprops"}, toolgun)
	addchk("Admins can use tool on world entities", {"FPP_TOOLGUN", "adminworldprops"}, toolgun)
	addchk("People can use tool on blocked entities", {"FPP_TOOLGUN", "canblocked"}, toolgun)
	addchk("Admins can use tool on blocked entities", {"FPP_TOOLGUN", "admincanblocked"}, toolgun)
	addchk("Show cross when unable to use tool on entities", {"FPP_TOOLGUN", "shownocross"}, toolgun)
	addchk("Check constrained entities", {"FPP_TOOLGUN", "checkconstrained"}, toolgun)
	addchk("People can't create(duplicate etc.) blocked entities(see Duplicator blocked entities)", {"FPP_TOOLGUN", "duplicatorprotect"}, toolgun)
	addchk("People can't duplicate weapons", {"FPP_TOOLGUN", "duplicatenoweapons"}, toolgun)
	addchk("The blocked list is a white list", {"FPP_TOOLGUN", "iswhitelist"}, toolgun)
	addchk("The blocked Duplicator list is a white list", {"FPP_TOOLGUN", "spawniswhitelist"}, toolgun)
	addblock(toolgun, "Toolgun")
	addblock(toolgun, "Spawning")
	
	local usecat, playeruse = MakeOption("Player use options")
	addchk("Use protection enabled", {"FPP_PLAYERUSE", "toggle"}, playeruse)
	addchk("Admins can use all entities", {"FPP_PLAYERUSE", "adminall"}, playeruse)
	addchk("People can use world entities", {"FPP_PLAYERUSE", "worldprops"}, playeruse)
	addchk("Admins can use world entities", {"FPP_PLAYERUSE", "adminworldprops"}, playeruse)
	addchk("People can use blocked entities", {"FPP_PLAYERUSE", "canblocked"}, playeruse)
	addchk("Admins can use blocked entities", {"FPP_PLAYERUSE", "admincanblocked"}, playeruse)
	addchk("Show cross when unable to use entities", {"FPP_PLAYERUSE", "shownocross"}, playeruse)
	addchk("Check constrained entities", {"FPP_PLAYERUSE", "checkconstrained"}, playeruse)
	addblock(playeruse, "PlayerUse")
	
	local damagecat, damage = MakeOption("Entity damage options")
	addchk("Damage protection enabled", {"FPP_ENTITYDAMAGE", "toggle"}, damage)
	addchk("Admins can damage all entities", {"FPP_ENTITYDAMAGE", "adminall"}, damage)
	addchk("People can damage world entities", {"FPP_ENTITYDAMAGE", "worldprops"}, damage)
	addchk("Admins can damage world entities", {"FPP_ENTITYDAMAGE", "adminworldprops"}, damage)
	addchk("People can damage blocked entities", {"FPP_ENTITYDAMAGE", "canblocked"}, damage)
	addchk("Admins can damage blocked entities", {"FPP_ENTITYDAMAGE", "admincanblocked"}, damage)
	addchk("Show cross when unable to damage entities", {"FPP_ENTITYDAMAGE", "shownocross"}, damage)
	addchk("Check constrained entities", {"FPP_ENTITYDAMAGE", "checkconstrained"}, damage)
	addchk("The blocked list is a white list", {"FPP_ENTITYDAMAGE", "iswhitelist"}, damage)
	addblock(damage, "EntityDamage")
	Panel:AddControl("Label", {Text = "\nFalco's Prop Protection\nMade by Falco A.K.A. FPtje"})
end

local function retrieveblocked(um)
	local Type = string.lower(um:ReadString())
	if not BlockedLists[Type] then return end
	local text = um:ReadString()
	local line = BlockedLists[Type]:AddLine(text)
	line.text = text
	BlockedLists[Type]:SetTall(18 + #BlockedLists[Type]:GetLines() * 17)
end
usermessage.Hook("FPP_blockedlist", retrieveblocked)

function FPP.BuddiesMenu(Panel)
	BuddiesPanel = BuddiesPanel or Panel
	Panel:ClearControls()
	
	Panel:AddControl("Label", {Text = "\nBuddies menu\nNote: Your buddies are saved and will work in all servers with FPP\nThe buddies list includes players that aren't here\n\nYour buddies:"})
	local BuddiesList = vgui.Create("DListView")
	BuddiesList:AddColumn("Steam ID")
	BuddiesList:AddColumn("Name")
	BuddiesList:SetTall(150)
	BuddiesList:SetMultiSelect(false)
	BuddiesPanel:AddPanel(BuddiesList)
	for k,v in pairs(FPP.Buddies) do
		BuddiesList:AddLine(k, v.name)
	end
	BuddiesList:SelectFirstItem()
	
	local remove = vgui.Create("DButton")
	remove:SetText("Remove selected buddy")
	remove.DoClick = function()
		local line = BuddiesList:GetLine(BuddiesList:GetSelectedLine())--Select the only selected line
		if not line then return end
		FPP.SaveBuddy(line.Columns[1]:GetValue(), line.Columns[2]:GetValue(), "remove")
		FPP.BuddiesMenu(BuddiesPanel) -- Restart the entire menu
	end
	BuddiesPanel:AddPanel(remove)
	
	local edit = vgui.Create("DButton")
	edit:SetText("Edit selected buddy")
	edit.DoClick = function()
		local line = BuddiesList:GetLine(BuddiesList:GetSelectedLine())--Select the only selected line
		if not line then return end
		local tmp = FPP.Buddies[line.Columns[1]:GetValue()]
		if not tmp then return end
		local data = {tmp.physgun, tmp.gravgun, tmp.toolgun, tmp.playeruse, tmp.entitydamage}
		FPP.SetBuddyMenu(line.Columns[1]:GetValue(), line.Columns[2]:GetValue(), data)
	end
	BuddiesPanel:AddPanel(edit)
	
	local AddManual = vgui.Create("DButton")
	AddManual:SetText("Add steamID manually")
	AddManual.DoClick = function()
		Derma_StringRequest("Add buddy manually",
		"Please enter the SteamID of the player you want to add in your buddies list",
		"",
		function(ID) 

			Derma_StringRequest("Name of buddy", 
			"What is the name of this buddy? (You can enter any name, it will change the next time you meet in a server with FPP)",
			"",
			function(Name) 
				FPP.SetBuddyMenu(ID, Name)
			end)
		end)
	end
	BuddiesPanel:AddPanel(AddManual)
	
	Panel:AddControl("Label", {Text = "\nAdd buddy:"})
	local AvailablePlayers = false
	for k,v in SortedPairs(player.GetAll(), function(a,b) return a:Nick() > b:Nick() end) do
		local cantadd = false
		if v == LocalPlayer() then cantadd = true end
		for a,b in pairs(FPP.Buddies) do 
			if a == v:SteamID()then
				cantadd = true
				break
			end
		end
		
		if not cantadd then
			local add = vgui.Create("DButton")
			add:SetText(v:Nick())
			add.DoClick = function()
				FPP.SetBuddyMenu(v:SteamID(), v:Nick())
			end
			BuddiesPanel:AddPanel(add)
			AvailablePlayers = true
		end
	end
	if not AvailablePlayers then
		Panel:AddControl("Label", {Text = "<No players available>"})
	end
end

function FPP.SetBuddyMenu(SteamID, Name, data)
	local frame = vgui.Create("DFrame")
	frame:SetTitle(Name)
	frame:MakePopup()
	frame:SetVisible( true )
	frame:SetSize(150, 130)
	frame:Center()
	
	local count = 1.5
	local function AddChk(name, Type, value)
		local box = vgui.Create("DCheckBoxLabel", frame)
		box:SetText(name .." buddy")
		
		box:SetPos(10, count * 20)
		count = count + 1
		box:SetValue(tobool(value))
		box.Button.Toggle = function()
			if box.Button:GetChecked() == nil or not box.Button:GetChecked() then 
				box.Button:SetValue( true ) 
			else 
				box.Button:SetValue( false ) 
			end 
			local tonum = {}
			tonum[false] = 0
			tonum[true] = 1
			
			FPP.SaveBuddy(SteamID, Name, Type, tonum[box.Button:GetChecked()])
			FPP.BuddiesMenu(BuddiesPanel) -- Restart the entire menu
		end
		box:SizeToContents()
	end
	
	data = data or {0,0,0,0,0}
	AddChk("Physgun", "physgun", data[1])
	AddChk("Gravgun", "gravgun", data[2])
	AddChk("Toolgun", "toolgun", data[3])
	AddChk("Use", "playeruse", data[4])
	AddChk("Entity damage", "entitydamage", data[5])
end

local function makeMenus()
	spawnmenu.AddToolMenuOption( "Utilities", "Falco's prop protection", "Falco's prop protection admin settings", "Admin settings", "", "", FPP.AdminMenu)
	spawnmenu.AddToolMenuOption( "Utilities", "Falco's prop protection", "Falco's prop protection buddies", "Buddies", "", "", FPP.BuddiesMenu)
end
hook.Add("PopulateToolMenu", "FPPMenus", makeMenus)

local function UpdateMenus()
	if AdminPanel then
		FPP.AdminMenu(AdminPanel)
	end
	if BuddiesPanel then
		FPP.BuddiesMenu(BuddiesPanel)
	end
end
hook.Add("SpawnMenuOpen", "FPPMenus", UpdateMenus)

function FPP.SharedMenu(um)
	local ent = um:ReadEntity()
	if not ValidEntity(ent) then frame:Close() return end
	local frame = vgui.Create("DFrame")
	frame:SetTitle("Share "..ent:GetClass())
	frame:MakePopup()
	frame:SetVisible( true )
	
	local count = 1.5
	local row = 1
	local function AddChk(name, Type, value)
		local box = vgui.Create("DCheckBoxLabel", frame)
		if type(name) == "string" then
			box:SetText(name .." share this entity")
		elseif name:IsPlayer() then
			box:SetText(name:Nick() .." can touch this")
		end
		
		if count * 20 - (row-1)*ScrH() > ScrH() - 30 - (row - 1)*50 then
			row = row + 1
		end
		box:SetPos(10 + (row - 1) * 155, count * 20 - (row - 1) * ScrH() + (row - 1)*40 )
		count = count + 1
		box:SetValue(value)
		box.Button.Toggle = function()
			if not ValidEntity(ent) then frame:Close() return end
			if box.Button:GetChecked() == nil or not box.Button:GetChecked() then 
				box.Button:SetValue( true ) 
			else 
				box.Button:SetValue( false ) 
			end 
			local tonum = {}
			tonum[false] = "0"
			tonum[true] = "1"
			RunConsoleCommand("FPP_ShareProp", ent:EntIndex(), Type, tonum[box.Button:GetChecked()])
		end
		box:SizeToContents()
	end
	AddChk("Physgun", "SharePhysgun", um:ReadBool())
	AddChk("Gravgun", "ShareGravgun", um:ReadBool())
	AddChk("Use", "SharePlayerUse", um:ReadBool())
	AddChk("Damage", "ShareDamage", um:ReadBool())
	AddChk("Toolgun", "ShareToolgun", um:ReadBool())
	
	local long = um:ReadLong()
	local SharedWith = {}
	
	if long > 0 then
		for i=1, long do
			table.insert(SharedWith, um:ReadEntity())
		end
	end
	
	if #player.GetAll() ~= 1 then
		count = count + 1
	end
	for k,v in pairs(player.GetAll()) do
		if v ~= LocalPlayer() then
			local IsShared = false
			if table.HasValue(SharedWith, v) then
				IsShared = true
			end
			AddChk(v, v:UserID(), IsShared)
		end
	end
	local height = count * 20
	if row > 1 then
		height = ScrH() - 20
	end
	frame:SetSize(math.Min(math.Max(165 + (row - 1) * 165, 165), ScrW()), height)
	frame:Center()
end
usermessage.Hook("FPP_ShareSettings", FPP.SharedMenu)