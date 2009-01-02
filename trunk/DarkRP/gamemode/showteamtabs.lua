local function MayorOptns()
	local MayCat = vgui.Create("DCollapsibleCategory")
	function MayCat:Paint()
		self:SetBGColor(team.GetColor(LocalPlayer():Team()))
	end
	MayCat:SetLabel("Mayor options")
		local maypanel = vgui.Create("DPanelList")
		maypanel:SetSpacing(5)
		maypanel:SetSize(740,110)
		maypanel:EnableHorizontal(false)
		maypanel:EnableVerticalScrollbar(true)
			local Warrant = vgui.Create("DButton") 
			Warrant:SetText("Warrant a player")
			Warrant.DoClick = function()
				local menu = DermaMenu()
				for _,ply in pairs(player.GetAll()) do
					if not ply:GetNWBool("wanted") and ply ~= LocalPlayer() then
						menu:AddOption(ply:Nick(), function() LocalPlayer():ConCommand("say /warrant " .. tostring(ply:UserID())) end)
					end
				end
				if #menu.Panels == 0 then
					menu:AddOption("Noone available", function() end)
				end
				menu:Open()
			end
			maypanel:AddItem(Warrant)
			
			local UnWarrant = vgui.Create("DButton") 
			UnWarrant:SetText("Unwarrant a player")
			UnWarrant.DoClick = function()
				local menu = DermaMenu()
				for _,ply in pairs(player.GetAll()) do
					if ply:GetNWBool("wanted") and ply ~= LocalPlayer() then
						menu:AddOption(ply:Nick(), function() LocalPlayer():ConCommand("say /unwanted " .. tostring(ply:UserID())) end)
					end
				end
				if #menu.Panels == 0 then
					menu:AddOption("Noone available", function() end)
				end
				menu:Open()
			end
			maypanel:AddItem(UnWarrant)
			
			local Lockdown = vgui.Create("DButton") 
			Lockdown:SetText("Initiate a lockdown")
			Lockdown.DoClick = function()
				LocalPlayer():ConCommand("say /lockdown")
			end
			maypanel:AddItem(Lockdown)
			
			
			local UnLockdown = vgui.Create("DButton") 
			UnLockdown:SetText("Stop the lockdown")
			UnLockdown.DoClick = function()
				LocalPlayer():ConCommand("say /unlockdown")
			end
			maypanel:AddItem(UnLockdown)
	MayCat:SetContents(maypanel)
	return MayCat
end

local function CPOptns()
	local CPCat = vgui.Create("DCollapsibleCategory")
	function CPCat:Paint()
		self:SetBGColor(team.GetColor(LocalPlayer():Team()))
	end
	CPCat:SetLabel("Police options")
		local CPpanel = vgui.Create("DPanelList")
		CPpanel:SetSpacing(5)
		CPpanel:SetSize(740,110)
		CPpanel:EnableHorizontal(false)
		CPpanel:EnableVerticalScrollbar(true)
			local Warrant = vgui.Create("DButton") 
			Warrant:SetText("Warrant a player")
			Warrant.DoClick = function()
				local menu = DermaMenu()
				for _,ply in pairs(player.GetAll()) do
					if not ply:GetNWBool("wanted") and ply ~= LocalPlayer() then
						menu:AddOption(ply:Nick(), function() LocalPlayer():ConCommand("say /warrant " .. tostring(ply:UserID())) end)
					end
				end
				if #menu.Panels == 0 then
					menu:AddOption("Noone available", function() end)
				end
				menu:Open()
			end
			CPpanel:AddItem(Warrant)
			
			local UnWarrant = vgui.Create("DButton") 
			UnWarrant:SetText("Unwarrant a player")
			UnWarrant.DoClick = function()
				local menu = DermaMenu()
				for _,ply in pairs(player.GetAll()) do
					if ply:GetNWBool("wanted") and ply ~= LocalPlayer() then
						menu:AddOption(ply:Nick(), function() LocalPlayer():ConCommand("say /unwanted " .. tostring(ply:UserID())) end)
					end
				end
				if #menu.Panels == 0 then
					menu:AddOption("Noone available", function() end)
				end
				menu:Open()
			end
			CPpanel:AddItem(UnWarrant)
			
			if LocalPlayer():Team() == TEAM_CHIEF or LocalPlayer():IsAdmin() then
				local SetJailPos = vgui.Create("DButton") 
				SetJailPos:SetText("Set the jail position")
				SetJailPos.DoClick = function() LocalPlayer():ConCommand("say /jailpos") end
				CPpanel:AddItem(SetJailPos)
				
				local AddJailPos = vgui.Create("DButton") 
				AddJailPos:SetText("Add a jail position")
				AddJailPos.DoClick = function() LocalPlayer():ConCommand("say /addjailpos") end
				CPpanel:AddItem(AddJailPos)
			end
	CPCat:SetContents(CPpanel)
	return CPCat
end


local function CitOptns()
	local CitCat = vgui.Create("DCollapsibleCategory")
	function CitCat:Paint()
		self:SetBGColor(team.GetColor(LocalPlayer():Team()))
	end
	CitCat:SetLabel("Citizen options")
		local Citpanel = vgui.Create("DPanelList")
		Citpanel:SetSpacing(5)
		Citpanel:SetSize(740,110)
		Citpanel:EnableHorizontal(false)
		Citpanel:EnableVerticalScrollbar(true)
		
		local joblabel = vgui.Create("DLabel")
		joblabel:SetText("Set a custom job(press enter to activate)") 
		Citpanel:AddItem(joblabel)
		
		local jobentry = vgui.Create("DTextEntry")
		jobentry:SetValue(LocalPlayer():GetNWString("job"))
		jobentry.OnEnter = function()
			LocalPlayer():ConCommand("say /job " .. tostring(jobentry:GetValue()))
		end
		jobentry.OnLoseFocus = jobentry.OnEnter
		Citpanel:AddItem(jobentry)
		
	CitCat:SetContents(Citpanel)
	return CitCat
end


local function MobOptns()
	local MobCat = vgui.Create("DCollapsibleCategory")
	function MobCat:Paint()
		self:SetBGColor(team.GetColor(LocalPlayer():Team()))
	end
	MobCat:SetLabel("Mobboss options")
		local Mobpanel = vgui.Create("DPanelList")
		Mobpanel:SetSpacing(5)
		Mobpanel:SetSize(740,110)
		Mobpanel:EnableHorizontal(false)
		Mobpanel:EnableVerticalScrollbar(true)
		
		local agendalabel = vgui.Create("DLabel")
		agendalabel:SetText("Set the agenda(press enter to activate)") 
		Mobpanel:AddItem(agendalabel)
		
		local agendaentry = vgui.Create("DTextEntry")
		agendaentry:SetValue(LocalPlayer():GetNWString("agenda"))
		agendaentry.OnEnter = function()
			LocalPlayer():ConCommand("say /agenda " .. tostring(agendaentry:GetValue()))
		end
		agendaentry.OnLoseFocus = agendaentry.OnEnter
		Mobpanel:AddItem(agendaentry)
		
	MobCat:SetContents(Mobpanel)
	return MobCat
end
	
local amountOfMoney = 2
function MoneyTab()
	local FirstTabPanel = vgui.Create("DPanelList")
		function FirstTabPanel:Update()
			self:Clear()
			local MoneyCat = vgui.Create("DCollapsibleCategory")
			MoneyCat:SetLabel("Money")
				local MoneyPanel = vgui.Create("DPanelList")
				MoneyPanel:SetSpacing(5)
				MoneyPanel:SetSize(740,100)
				MoneyPanel:EnableHorizontal(false)
				MoneyPanel:EnableVerticalScrollbar(true)
				
				
				local MoneyAmount = vgui.Create("DNumSlider")
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
				
				local GiveMoneyButton = vgui.Create("DButton")
				GiveMoneyButton:SetText("Give amount at the player you're looking at")
				GiveMoneyButton.DoClick = function()
					LocalPlayer():ConCommand("say /give " .. tostring(MoneyAmount:GetValue()))
				end
				MoneyPanel:AddItem(GiveMoneyButton)
				
				local SpawnMoneyButton = vgui.Create("DButton")
				SpawnMoneyButton:SetText("Drop a money package with the selected amount of money")
				SpawnMoneyButton.DoClick = function()
					LocalPlayer():ConCommand("say /dropmoney " .. tostring(MoneyAmount:GetValue()))
				end

				MoneyPanel:AddItem(SpawnMoneyButton)
			MoneyCat:SetContents(MoneyPanel)
		
		
			local Commands = vgui.Create("DCollapsibleCategory")
			Commands:SetLabel("Actions")
				local ActionsPanel = vgui.Create("DPanelList")
				ActionsPanel:SetSpacing(5)
				ActionsPanel:SetSize(740,140)
				ActionsPanel:EnableHorizontal( false )
				ActionsPanel:EnableVerticalScrollbar(true)
					local rpnamelabel = vgui.Create("DLabel")
					rpnamelabel:SetText("Change your DarkRP name(press Enter to change your name)")
				ActionsPanel:AddItem(rpnamelabel) 
					
					local rpnameTextbox = vgui.Create("DTextEntry")
					rpnameTextbox:SetText(LocalPlayer():Nick())
					rpnameTextbox.OnEnter = function() LocalPlayer():ConCommand("say /rpname " .. tostring(rpnameTextbox:GetValue())) end
					rpnameTextbox.OnLoseFocus = function() LocalPlayer():ConCommand("say /rpname " .. tostring(rpnameTextbox:GetValue())) end
					
					ActionsPanel:AddItem(rpnameTextbox)
				
					local sleep = vgui.Create("DButton")
					sleep:SetText("Toggle sleep mode")
					sleep.DoClick = function()
						LocalPlayer():ConCommand("say /sleep")
					end	
				ActionsPanel:AddItem(sleep)
					local Drop = vgui.Create("DButton")
					Drop:SetText("Drop current weapon(must be an RP weapon)")
					Drop.DoClick = function() LocalPlayer():ConCommand("say /drop") end
				ActionsPanel:AddItem(Drop)
					local health = vgui.Create("DButton")
					health:SetText("Buy health(".. CUR .. tostring(GetGlobalInt("healthcost")) .. ")")
					health.DoClick = function() LocalPlayer():ConCommand("say /Buyhealth") end
				ActionsPanel:AddItem(health)
				
			Commands:SetContents(ActionsPanel)
		FirstTabPanel:AddItem(MoneyCat)
		FirstTabPanel:AddItem(Commands)
		
		if LocalPlayer():Team() == TEAM_MAYOR then
			FirstTabPanel:AddItem(MayorOptns())
		elseif LocalPlayer():Team() == TEAM_CITIZEN then
			FirstTabPanel:AddItem(CitOptns())
		elseif LocalPlayer():Team() == TEAM_POLICE or LocalPlayer():Team() == TEAM_CHIEF then
			FirstTabPanel:AddItem(CPOptns())
		elseif LocalPlayer():Team() == TEAM_MOB then
			FirstTabPanel:AddItem(MobOptns())
		end
	end
	FirstTabPanel:Update()
	return FirstTabPanel	
end
	
function JobsTab()
	local hordiv = vgui.Create("DHorizontalDivider")
	hordiv:SetLeftWidth(370)
	function hordiv.m_DragBar:OnMousePressed() end
	hordiv.m_DragBar:SetCursor("none")
	local Panel
	local Information
	function hordiv:Update()
		if Panel and Panel:IsValid() then
			Panel:Remove()
		end
		Panel = vgui.Create( "DPanelList")
		//Panel:SetPos(10,30)
		Panel:SetSize(370, 540)
		Panel:SetSpacing(1)
		Panel:EnableHorizontal( true )
		Panel:EnableVerticalScrollbar( true )
		
		
		local Info = {}
		local model
		local modelpanel
		local function UpdateInfo(a)
			if Information and Information:IsValid() then
				Information:Remove()
			end
			Information = vgui.Create( "DPanelList" )
			Information:SetPos(378,0)
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
			local icon = vgui.Create("SpawnIcon")
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
				
				hordiv:GetParent():GetParent():Close() //SetVisible(false)
			end
			
			if icon:IsValid() then
				Panel:AddItem(icon)
			end
		end
		
		
		/*if LocalPlayer():Team() ~= TEAM_HOBO then
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
		end*/
		
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
			/Buymicrowave]]
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
				/Buyshipment <name> to Buy a  weapon shipment
				/Buygunlab to Buy a gunlab that spawns P228 pistols]]
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
		for k,v in pairs(RPExtraTeams) do
			if LocalPlayer():Team() ~= (9 + k) then
				local nodude = true
				if v.admin == 1 and not LocalPlayer():IsAdmin() then
					nodude = false
				end
				if v.admin > 1 and not LocalPlayer():IsSuperAdmin() then
					nodude = false
				end
				if nodude then
					local weps = "no extra weapons"
					if #v.Weapons > 0 then
						weps = table.concat(v.Weapons, "\n")
					end
					AddIcon(v.model, v.name, v.Des, weps, "/"..v.command)
				end
			end
		end
		//hordiv:SetLeft(Panel)
		//hordiv:SetRight(Information)
	end
	hordiv:Update()
	return hordiv
end

function EntitiesTab()
	local EntitiesPanel = vgui.Create("DPanelList")
		function EntitiesPanel:Update()
			self:Clear()
			local WepCat = vgui.Create("DCollapsibleCategory")
			WepCat:SetLabel("Weapons")
			//WepCat:InvalidateLayout( true ) 
			//WepCat:SetExpanded(false)
			//WepCat:Toggle()
				local WepPanel = vgui.Create("DPanelList")
				//WepPanel:InvalidateLayout( true ) 
				WepPanel:SetSize(470, 100)
				WepPanel:SetSpacing(1)
				WepPanel:EnableHorizontal(true)
				WepPanel:EnableVerticalScrollbar(true)
					local function AddIcon(Model, description, command)
						local icon = vgui.Create("SpawnIcon")
						icon:InvalidateLayout( true ) 
						icon:SetModel(Model)
						icon:SetIconSize(64)
						icon:SetToolTip(description)
						icon.DoClick = function() LocalPlayer():ConCommand("say "..command) end
						WepPanel:AddItem(icon)
					end
					AddIcon("models/weapons/w_pist_glock18.mdl", "Buy a glock: " .. CUR .. tostring(GetGlobalInt("glockcost")), "/Buypistol glock")
					AddIcon("models/weapons/w_pist_deagle.mdl", "Buy a Desert eagle: " .. CUR .. tostring(GetGlobalInt("deaglecost")), "/Buypistol deagle")
					AddIcon("models/weapons/w_pist_fiveseven.mdl", "Buy a fiveseven: " .. CUR .. tostring(GetGlobalInt("fivesevencost")), "/Buypistol fiveseven")
					AddIcon("models/weapons/w_pist_p228.mdl", "Buy a P228: " .. CUR .. tostring(GetGlobalInt("p228cost")), "/Buypistol p228")
					
					AddIcon("models/Items/BoxSRounds.mdl", "Buy pistol ammo: " .. CUR .. tostring(GetGlobalInt("ammopistolcost")), "/buyammo pistol")
					AddIcon("models/Items/BoxMRounds.mdl", "Buy rifle ammo: " .. CUR .. tostring(GetGlobalInt("ammoriflecost")), "/buyammo rifle")
					AddIcon("models/Items/BoxBuckshot.mdl", "Buy shotgun ammo: " .. CUR .. tostring(GetGlobalInt("ammoshotguncost")), "/buyammo shotgun")
			WepCat:SetContents(WepPanel)
			self:AddItem(WepCat)
			
			local EntCat = vgui.Create("DCollapsibleCategory")
			EntCat:SetLabel("Entities")
				local EntPanel = vgui.Create("DPanelList")
				EntPanel:SetSize(470, 100)
				EntPanel:SetSpacing(1)
				EntPanel:EnableHorizontal(true)
				EntPanel:EnableVerticalScrollbar(true)
					local function AddEntIcon(Model, description, command)
						local icon = vgui.Create("SpawnIcon")
						icon:InvalidateLayout( true ) 
						icon:SetModel(Model)
						icon:SetIconSize(64)
						icon:SetToolTip(description)
						icon.DoClick = function() LocalPlayer():ConCommand("say "..command) end
						EntPanel:AddItem(icon)
					end
					AddEntIcon("models/props_combine/combine_mine01.mdl", "Buy a druglab " .. CUR .. tostring(GetGlobalInt("druglabcost")), "/Buydruglab")
					AddEntIcon("models/props_c17/consolebox01a.mdl", "Buy a Money printer " .. CUR .. tostring(GetGlobalInt("mprintercost")), "/Buymoneyprinter")
					if LocalPlayer():Team() == TEAM_GUN then
						AddEntIcon("models/props_c17/trappropeller_engine.mdl", "Buy a gunlab " .. CUR .. tostring(GetGlobalInt("gunlabcost")), "/Buygunlab")
						AddEntIcon("models/weapons/w_rif_m4a1.mdl", "Buy an M16 shipment " .. CUR .. tostring(GetGlobalInt("m16cost")), "/buyshipment m16")
						AddEntIcon("models/weapons/w_rif_ak47.mdl", "Buy an AK47 shipment " .. CUR .. tostring(GetGlobalInt("ak47cost")), "/buyshipment ak47")
						AddEntIcon("models/weapons/w_snip_g3sg1.mdl", "Buy a sniper shipment " .. CUR .. tostring(GetGlobalInt("snipercost")), "/buyshipment sniper")
						AddEntIcon("models/weapons/w_smg_mp5.mdl", "Buy an mp5 shipment " .. CUR .. tostring(GetGlobalInt("mp5cost")), "/buyshipment mp5")
						AddEntIcon("models/weapons/w_shot_m3super90.mdl", "Buy a shotgun shipment " .. CUR .. tostring(GetGlobalInt("shotguncost")), "/buyshipment shotgun")
						AddEntIcon("models/weapons/w_smg_mac10.mdl", "Buy a mac10 shipment " .. CUR .. tostring(GetGlobalInt("mac10cost")), "/buyshipment mac10")
					elseif LocalPlayer():Team() == TEAM_COOK then
						AddEntIcon("models/props/cs_office/microwave.mdl", "Buy a microwave " .. CUR .. tostring(GetGlobalInt("microwavecost")) , "/Buymicrowave")
					end
			EntCat:SetContents(EntPanel)
			self:AddItem(EntCat)
		end
	EntitiesPanel:Update()	
	return EntitiesPanel
end

--[[ local SKIN = {}
	SKIN.bg_color 					= Color( 100, 100, 100, 255 ) 
	SKIN.bg_color_sleep 			= Color( 0, 65, 255, 255 ) 
	SKIN.bg_color_dark				= Color( 5, 5, 5, 255 ) 
	SKIN.bg_color_bright			= Color( 220, 220, 220, 255  ) 
derma.DefineSkin("F4Menu", "For the F4 menu...", SKIN)

function GM:ForceDermaSkin()
	return "F4Menu"
end ]]