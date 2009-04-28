local function MayorOptns()
	local MayCat = vgui.Create("DCollapsibleCategory")
	function MayCat:Paint()
		self:SetBGColor(team.GetColor(LocalPlayer():Team()))
	end
	MayCat:SetLabel("Mayor options")
		local maypanel = vgui.Create("DPanelList")
		maypanel:SetSpacing(5)
		maypanel:SetSize(740,170)
		maypanel:EnableHorizontal(false)
		maypanel:EnableVerticalScrollbar(true)
			local SearchWarrant = vgui.Create("DButton") 
			SearchWarrant:SetText("Get a search warrant for a player")
			SearchWarrant.DoClick = function()
				local menu = DermaMenu()
				for _,ply in pairs(player.GetAll()) do
					if not ply:GetNWBool("warrant") and ply ~= LocalPlayer() then
						menu:AddOption(ply:Nick(), function() LocalPlayer():ConCommand("say /warrant " .. tostring(ply:UserID())) end)
					end
				end
				if #menu.Panels == 0 then
					menu:AddOption("Noone available", function() end)
				end
				menu:Open()
			end
			maypanel:AddItem(SearchWarrant)
			
			local Warrant = vgui.Create("DButton") 
			Warrant:SetText("Make someone wanted")
			Warrant.DoClick = function()
				local menu = DermaMenu()
				for _,ply in pairs(player.GetAll()) do
					if not ply:GetNWBool("wanted") and ply ~= LocalPlayer() then
						menu:AddOption(ply:Nick(), function() LocalPlayer():ConCommand("say /wanted " .. tostring(ply:UserID())) end)
					end
				end
				if #menu.Panels == 0 then
					menu:AddOption("Noone available", function() end)
				end
				menu:Open()
			end
			maypanel:AddItem(Warrant)
			
			local UnWarrant = vgui.Create("DButton") 
			UnWarrant:SetText("Make someone unwanted")
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
			
			local Lottery = vgui.Create("DButton") 
			Lottery:SetText("Start a lottery")
			Lottery.DoClick = function()
				LocalPlayer():ConCommand("say /lottery")
			end
			maypanel:AddItem(Lottery)
			
			local GiveLicense = vgui.Create("DButton") 
			GiveLicense:SetText("Give <lookingat> a gun license")
			GiveLicense.DoClick = function()
				LocalPlayer():ConCommand("say /givelicense")
			end
			maypanel:AddItem(GiveLicense)
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
		CPpanel:SetSize(740,140)
		CPpanel:EnableHorizontal(false)
		CPpanel:EnableVerticalScrollbar(true)
			local SearchWarrant = vgui.Create("DButton") 
			SearchWarrant:SetText("Request a search warrant for a player")
			SearchWarrant.DoClick = function()
				local menu = DermaMenu()
				for _,ply in pairs(player.GetAll()) do
					if not ply:GetNWBool("warrant") and ply ~= LocalPlayer() then
						menu:AddOption(ply:Nick(), function() LocalPlayer():ConCommand("say /warrant " .. tostring(ply:UserID())) end)
					end
				end
				if #menu.Panels == 0 then
					menu:AddOption("Noone available", function() end)
				end
				menu:Open()
			end
			CPpanel:AddItem(SearchWarrant)
			
			local Warrant = vgui.Create("DButton") 
			Warrant:SetText("Warrant a player")
			Warrant.DoClick = function()
				local menu = DermaMenu()
				for _,ply in pairs(player.GetAll()) do
					if not ply:GetNWBool("wanted") and ply ~= LocalPlayer() then
						menu:AddOption(ply:Nick(), function() LocalPlayer():ConCommand("say /wanted " .. tostring(ply:UserID())) end)
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

function MoneyTab()
	local FirstTabPanel = vgui.Create("DPanelList")
		function FirstTabPanel:Update()
			self:Clear(true)
			local MoneyCat = vgui.Create("DCollapsibleCategory")
			MoneyCat:SetLabel("Money")
				local MoneyPanel = vgui.Create("DPanelList")
				MoneyPanel:SetSpacing(5)
				MoneyPanel:SetSize(740,60)
				MoneyPanel:EnableHorizontal(false)
				MoneyPanel:EnableVerticalScrollbar(true)
				
				local GiveMoneyButton = vgui.Create("DButton")
				GiveMoneyButton:SetText("Give money at the one you're looking at")
				GiveMoneyButton.DoClick = function()
					Derma_StringRequest("Amount of money", "How much money do you want to give?", "", function(a) LocalPlayer():ConCommand("say /give " .. tostring(a)) end)
				end
				MoneyPanel:AddItem(GiveMoneyButton)
				
				local SpawnMoneyButton = vgui.Create("DButton")
				SpawnMoneyButton:SetText("Drop money")
				SpawnMoneyButton.DoClick = function()
					Derma_StringRequest("Amount of money", "How much money do you want to drop?", "", function(a) LocalPlayer():ConCommand("say /dropmoney " .. tostring(a)) end)
				end

				MoneyPanel:AddItem(SpawnMoneyButton)
			MoneyCat:SetContents(MoneyPanel)
		
		
			local Commands = vgui.Create("DCollapsibleCategory")
			Commands:SetLabel("Actions")
				local ActionsPanel = vgui.Create("DPanelList")
				ActionsPanel:SetSpacing(5)
				ActionsPanel:SetSize(740,160)
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
				
				local RequestLicense = vgui.Create("DButton")
					RequestLicense:SetText("Request gunlicense")
					RequestLicense.DoClick = function() LocalPlayer():ConCommand("say /requestlicense") end
				ActionsPanel:AddItem(RequestLicense)
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
		
		local function AddIcon(Model, name, description, Weapons, command, special, specialcommand)
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
				if special then
					local menu = DermaMenu()
					menu:AddOption("Vote", function() LocalPlayer():ConCommand("say "..command) hordiv:GetParent():GetParent():Close() end)
					menu:AddOption("Do not vote", function() LocalPlayer():ConCommand("say " .. specialcommand) hordiv:GetParent():GetParent():Close() end)
					menu:Open()
				else
					LocalPlayer():ConCommand("say " .. command)
					hordiv:GetParent():GetParent():Close()
				end
			end
			
			if icon:IsValid() then
				Panel:AddItem(icon)
			end
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
				]], "/votecop", LocalPlayer():IsAdmin() or LocalPlayer():GetNWBool("Privcp") or LocalPlayer():GetNWBool("Privadmin"), "/cp")
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
				, "/votemayor", LocalPlayer():IsAdmin() or LocalPlayer():GetNWBool("Privmayor") or LocalPlayer():GetNWBool("Privadmin"), "/mayor")
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
					if v.Vote then
						local condition = ((v.admin == 0 and LocalPlayer():IsAdmin()) or (v.admin == 1 and LocalPlayer():IsSuperAdmin()))
						AddIcon(v.model, v.name, v.Des, weps, "/vote"..v.command, condition, "/"..v.command)
					else
						AddIcon(v.model, v.name, v.Des, weps, "/"..v.command)
					end
				end
			end
		end
	end
	hordiv:Update()
	return hordiv
end

function EntitiesTab()
	local EntitiesPanel = vgui.Create("DPanelList")
		function EntitiesPanel:Update()
			self:Clear(true)
			local WepCat = vgui.Create("DCollapsibleCategory")
			WepCat:SetLabel("Weapons")
				local WepPanel = vgui.Create("DPanelList")
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
					AddIcon("models/weapons/w_pist_glock18.mdl", "Buy a glock: " .. CUR .. tostring(GetGlobalInt("glockcost")), "/buy glock")
					AddIcon("models/weapons/w_pist_deagle.mdl", "Buy a Desert eagle: " .. CUR .. tostring(GetGlobalInt("deaglecost")), "/buy deagle")
					AddIcon("models/weapons/w_pist_fiveseven.mdl", "Buy a fiveseven: " .. CUR .. tostring(GetGlobalInt("fivesevencost")), "/buy fiveseven")
					AddIcon("models/weapons/w_pist_p228.mdl", "Buy a P228: " .. CUR .. tostring(GetGlobalInt("p228cost")), "/buy p228")
					
					for k,v in pairs(CustomShipments) do
						if v.seperate and (table.HasValue(v.allowed, LocalPlayer():Team()) or #v.allowed == 0) then
							AddIcon(v.model, "Buy a "..v.name..": "..CUR..v.pricesep, "/buy "..v.name)
						end
					end
					
					AddIcon("models/Items/BoxSRounds.mdl", "Buy pistol ammo: " .. CUR .. tostring(GetGlobalInt("ammopistolcost")), "/buyammo pistol")
					AddIcon("models/Items/BoxMRounds.mdl", "Buy rifle ammo: " .. CUR .. tostring(GetGlobalInt("ammoriflecost")), "/buyammo rifle")
					AddIcon("models/Items/BoxBuckshot.mdl", "Buy shotgun ammo: " .. CUR .. tostring(GetGlobalInt("ammoshotguncost")), "/buyammo shotgun")
			WepCat:SetContents(WepPanel)
			self:AddItem(WepCat)
			
			local EntCat = vgui.Create("DCollapsibleCategory")
			EntCat:SetLabel("Entities")
				local EntPanel = vgui.Create("DPanelList")
				EntPanel:SetSize(470, 200)
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
					if LocalPlayer():Team() == TEAM_GANG or LocalPlayer():Team() == TEAM_MOB then
						AddEntIcon("models/props_lab/crematorcase.mdl", "Buy a druglab " .. CUR .. tostring(GetGlobalInt("druglabcost")), "/Buydruglab")
					end
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
					if  FoodItems and (GetGlobalInt("foodspawn") ~= 0 or LocalPlayer():Team() == TEAM_COOK) and (GetGlobalInt("hungermod") == 1 or LocalPlayer():Team() == TEAM_COOK) then
						for k,v in pairs(FoodItems) do
							AddEntIcon(v.model, "Buy a(n) ".. k .. " for a few bucks", "/buyfood "..k)
						end
					end
					for k,v in pairs(CustomShipments) do
						if not v.noship and table.HasValue(v.allowed, LocalPlayer():Team()) then
							AddEntIcon(v.model, "Buy a "..v.name.." shipment " .. CUR .. tostring(v.price), "/buyshipment "..v.name)
						end
					end
			EntCat:SetContents(EntPanel)
			self:AddItem(EntCat)
		end
	EntitiesPanel:Update()	
	return EntitiesPanel
end

function RPHUDTab()
	local HUDTABpanel = vgui.Create("DPanelList")
	HUDTABpanel:SetSpacing(21)
	HUDTABpanel:SetSize(750, 550)
	HUDTABpanel:EnableHorizontal( true	)
	HUDTABpanel:EnableVerticalScrollbar( true )
	function HUDTABpanel:Update()
		self:Clear(true)
		
		backgrndcat = vgui.Create("DCollapsibleCategory")
		backgrndcat:SetSize(230, 130)
		function backgrndcat.Header:OnMousePressed() end
		backgrndcat:SetLabel("HUD background")
			local backgrndpanel = vgui.Create("DPanelList")
			backgrndpanel:SetTall(130)
				local backgrnd = vgui.Create("CtrlColor")
				backgrnd:SetConVarR("backgroundr")
				backgrnd:SetConVarG("backgroundg")
				backgrnd:SetConVarB("backgroundb")
				backgrnd:SetConVarA("backgrounda")
			backgrndpanel:AddItem(backgrnd)
			
			local resetbackgrnd = vgui.Create("DButton")
			resetbackgrnd:SetText("Reset")
			resetbackgrnd:SetSize(230, 20)
			resetbackgrnd.DoClick = function()
				LocalPlayer():ConCommand("backgroundr 0")
				LocalPlayer():ConCommand("backgroundg 0")
				LocalPlayer():ConCommand("backgroundb 0")
				LocalPlayer():ConCommand("backgrounda 100")
			end
			backgrndpanel:AddItem(resetbackgrnd)
		backgrndcat:SetContents(backgrndpanel)
		HUDTABpanel:AddItem(backgrndcat)
		
		hforegrndcat = vgui.Create("DCollapsibleCategory")
		hforegrndcat:SetSize(230, 130)
		function hforegrndcat.Header:OnMousePressed() end
		hforegrndcat:SetLabel("Health bar foreground")
			local hforegrndpanel = vgui.Create("DPanelList")
			hforegrndpanel:SetTall(130)
				local hforegrnd = vgui.Create("CtrlColor")
				hforegrnd:SetConVarR("Healthforegroundr")
				hforegrnd:SetConVarG("Healthforegroundg")
				hforegrnd:SetConVarB("Healthforegroundb")
				hforegrnd:SetConVarA("Healthforegrounda")
			hforegrndpanel:AddItem(hforegrnd)
			
			local resethforegrnd = vgui.Create("DButton")
			resethforegrnd:SetText("Reset")
			resethforegrnd:SetSize(230, 20)
			resethforegrnd.DoClick = function()
				LocalPlayer():ConCommand("Healthforegroundr 140")
				LocalPlayer():ConCommand("Healthforegroundg 0")
				LocalPlayer():ConCommand("Healthforegroundb 0")
				LocalPlayer():ConCommand("Healthforegrounda 180")
			end
			hforegrndpanel:AddItem(resethforegrnd)
		hforegrndcat:SetContents(hforegrndpanel)
		HUDTABpanel:AddItem(hforegrndcat)
		
		
		hbackgrndcat = vgui.Create("DCollapsibleCategory")
		hbackgrndcat:SetSize(230, 130)
		function hbackgrndcat.Header:OnMousePressed() end
		hbackgrndcat:SetLabel("Health bar background")
			local hbackgrndpanel = vgui.Create("DPanelList")
			hbackgrndpanel:SetTall(130)
				local hbackgrnd = vgui.Create("CtrlColor")
				hbackgrnd:SetConVarR("Healthbackgroundr")
				hbackgrnd:SetConVarG("Healthbackgroundg")
				hbackgrnd:SetConVarB("Healthbackgroundb")
				hbackgrnd:SetConVarA("Healthbackgrounda")
			hbackgrndpanel:AddItem(hbackgrnd)
			
			local resethbackgrnd = vgui.Create("DButton")
			resethbackgrnd:SetText("Reset")
			resethbackgrnd:SetSize(230, 20)
			resethbackgrnd.DoClick = function()
				LocalPlayer():ConCommand("Healthbackgroundr 0")
				LocalPlayer():ConCommand("Healthbackgroundg 0")
				LocalPlayer():ConCommand("Healthbackgroundb 0")
				LocalPlayer():ConCommand("Healthbackgrounda 200")
			end
			hbackgrndpanel:AddItem(resethbackgrnd)
		hbackgrndcat:SetContents(hbackgrndpanel)
		HUDTABpanel:AddItem(hbackgrndcat)
		
		hTextcat = vgui.Create("DCollapsibleCategory")
		hTextcat:SetSize(230, 130)
		function hTextcat.Header:OnMousePressed() end
		hTextcat:SetLabel("Health bar text")
			local hTextpanel = vgui.Create("DPanelList")
			hTextpanel:SetTall(130)
				local hText = vgui.Create("CtrlColor")
				hText:SetConVarR("HealthTextr")
				hText:SetConVarG("HealthTextg")
				hText:SetConVarB("HealthTextb")
				hText:SetConVarA("HealthTexta")
			hTextpanel:AddItem(hText)
			
			local resethText = vgui.Create("DButton")
			resethText:SetText("Reset")
			resethText:SetSize(230, 20)
			resethText.DoClick = function()
				LocalPlayer():ConCommand("HealthTextr 255")
				LocalPlayer():ConCommand("HealthTextg 255")
				LocalPlayer():ConCommand("HealthTextb 255")
				LocalPlayer():ConCommand("HealthTexta 200")
			end
			hTextpanel:AddItem(resethText)
		hTextcat:SetContents(hTextpanel)
		HUDTABpanel:AddItem(hTextcat)
		
		jobs1cat = vgui.Create("DCollapsibleCategory")
		jobs1cat:SetSize(230, 130)
		function jobs1cat.Header:OnMousePressed() end
		jobs1cat:SetLabel("Jobs/wallet foreground")
			local jobs1panel = vgui.Create("DPanelList")
			jobs1panel:SetTall(130)
				local jobs1 = vgui.Create("CtrlColor")
				jobs1:SetConVarR("Job2r")
				jobs1:SetConVarG("Job2g")
				jobs1:SetConVarB("Job2b")
				jobs1:SetConVarA("Job2a")
			jobs1panel:AddItem(jobs1)
			
			local resetjobs1 = vgui.Create("DButton")
			resetjobs1:SetText("Reset")
			resetjobs1:SetSize(230, 20)
			resetjobs1.DoClick = function()
				LocalPlayer():ConCommand("Job2r 0")
				LocalPlayer():ConCommand("Job2g 0")
				LocalPlayer():ConCommand("Job2b 150")
				LocalPlayer():ConCommand("Job2a 200")
			end
			jobs1panel:AddItem(resetjobs1)
		jobs1cat:SetContents(jobs1panel)
		HUDTABpanel:AddItem(jobs1cat)
		
		jobs2cat = vgui.Create("DCollapsibleCategory")
		jobs2cat:SetSize(230, 130)
		function jobs2cat.Header:OnMousePressed() end
		jobs2cat:SetLabel("Jobs/wallet background")
			local jobs2panel = vgui.Create("DPanelList")
			jobs2panel:SetSize(230, 130)
				local jobs2 = vgui.Create("CtrlColor")
				jobs2:SetConVarR("Job1r")
				jobs2:SetConVarG("Job1g")
				jobs2:SetConVarB("Job1b")
				jobs2:SetConVarA("Job1a")
			jobs2panel:AddItem(jobs2)
			
			local resetjobs2 = vgui.Create("DButton")
			resetjobs2:SetText("Reset")
			resetjobs2:SetSize(230, 20)
			resetjobs2.DoClick = function()
				LocalPlayer():ConCommand("Job1r 0")
				LocalPlayer():ConCommand("Job1g 0")
				LocalPlayer():ConCommand("Job1b 0")
				LocalPlayer():ConCommand("Job1a 255")
			end
			jobs2panel:AddItem(resetjobs2) 
		jobs2cat:SetContents(jobs2panel)
		HUDTABpanel:AddItem(jobs2cat)
		
		salary1cat = vgui.Create("DCollapsibleCategory")
		salary1cat:SetSize(230, 130)
		function salary1cat.Header:OnMousePressed() end
		salary1cat:SetLabel("Salary foreground")
			local salary1panel = vgui.Create("DPanelList")
			salary1panel:SetSize(230, 130)
				local salary1 = vgui.Create("CtrlColor")
				salary1:SetConVarR("salary2r")
				salary1:SetConVarG("salary2g")
				salary1:SetConVarB("salary2b")
				salary1:SetConVarA("salary2a")
			salary1panel:AddItem(salary1)
			
			local resetsalary1 = vgui.Create("DButton")
			resetsalary1:SetText("Reset")
			resetsalary1:SetSize(230, 20)
			resetsalary1.DoClick = function()
				LocalPlayer():ConCommand("salary2r 0")
				LocalPlayer():ConCommand("salary2g 0")
				LocalPlayer():ConCommand("salary2b 0")
				LocalPlayer():ConCommand("salary2a 255")
			end
			salary1panel:AddItem(resetsalary1)
		salary1cat:SetContents(salary1panel)
		HUDTABpanel:AddItem(salary1cat)
		
		salary2cat = vgui.Create("DCollapsibleCategory")
		salary2cat:SetSize(230, 130)
		function salary2cat.Header:OnMousePressed() end
		salary2cat:SetLabel("Salary background")
			local salary2panel = vgui.Create("DPanelList")
			salary2panel:SetSize(230, 130)
				local salary2 = vgui.Create("CtrlColor")
				salary2:SetConVarR("salary1r")
				salary2:SetConVarG("salary1g")
				salary2:SetConVarB("salary1b")
				salary2:SetConVarA("salary1a")
			salary2panel:AddItem(salary2)
			
			local resetsalary2 = vgui.Create("DButton")
			resetsalary2:SetText("Reset")
			resetsalary2:SetSize(230, 20)
			resetsalary2.DoClick = function()
				LocalPlayer():ConCommand("salary1r 0")
				LocalPlayer():ConCommand("salary1g 150")
				LocalPlayer():ConCommand("salary1b 0")
				LocalPlayer():ConCommand("salary1a 200")
			end
			salary2panel:AddItem(resetsalary2)
		salary2cat:SetContents(salary2panel)
		HUDTABpanel:AddItem(salary2cat)
		
		local HudWidthCat = vgui.Create("DCollapsibleCategory")
		HudWidthCat:SetSize(230, 130)
		function HudWidthCat.Header:OnMousePressed() end
		HudWidthCat:SetLabel("HUD width")
		local HudWidthpanel = vgui.Create("DPanelList")
			HudWidthpanel:SetSize(230, 130)
				local HudWidth = vgui.Create("DNumSlider")
				HudWidth:SetMinMax(0, ScrW() - 30)
				HudWidth:SetDecimals(0)
				HudWidth:SetConVar("HudWidth")
			HudWidthpanel:AddItem(HudWidth)
			
			local resetHudWidth = vgui.Create("DButton")
			resetHudWidth:SetText("Reset")
			resetHudWidth:SetSize(230, 20)
			resetHudWidth.DoClick = function()
				LocalPlayer():ConCommand("HudWidth 190")
			end
			HudWidthpanel:AddItem(resetHudWidth)
		HudWidthCat:SetContents(HudWidthpanel)
		HUDTABpanel:AddItem(HudWidthCat)
		
		local HudHeightCat = vgui.Create("DCollapsibleCategory")
		HudHeightCat:SetSize(230, 130)
		function HudHeightCat.Header:OnMousePressed() end
		HudHeightCat:SetLabel("HUD Height")
		local HudHeightpanel = vgui.Create("DPanelList")
			HudHeightpanel:SetSize(230, 130)
				local HudHeight = vgui.Create("DNumSlider")
				HudHeight:SetMinMax(1, ScrW() - 20)
				HudHeight:SetDecimals(0)
				HudHeight:SetConVar("HudHeight")
			HudHeightpanel:AddItem(HudHeight)
			
			local resetHudHeight = vgui.Create("DButton")
			resetHudHeight:SetText("Reset")
			resetHudHeight:SetSize(230, 20)
			resetHudHeight.DoClick = function()
				LocalPlayer():ConCommand("HudHeight 10")
			end
			HudHeightpanel:AddItem(resetHudHeight)
		HudHeightCat:SetContents(HudHeightpanel)
		HUDTABpanel:AddItem(HudHeightCat)
	end
	return HUDTABpanel
end

function RPAdminTab()
	local AdminPanel = vgui.Create("DPanelList")
	AdminPanel:SetSpacing(1)
	AdminPanel:EnableHorizontal( false	)
	AdminPanel:EnableVerticalScrollbar( true )
		function AdminPanel:Update()
			self:Clear(true)
			local ToggleCat = vgui.Create("DCollapsibleCategory")
			ToggleCat:SetLabel("Toggle commands")
				local TogglePanel = vgui.Create("DPanelList")
				TogglePanel:SetSize(470, 230)
				TogglePanel:SetSpacing(1)
				TogglePanel:EnableHorizontal(false)
				TogglePanel:EnableVerticalScrollbar(true)
				
				local ValueCat = vgui.Create("DCollapsibleCategory")
				ValueCat:SetLabel("Value commands")
				local ValuePanel = vgui.Create("DPanelList")
				ValuePanel:SetSize(470, 230)
				ValuePanel:SetSpacing(1)
				ValuePanel:EnableHorizontal(false)
				ValuePanel:EnableVerticalScrollbar(true)
				
				local toggles = table.ClearKeys(ToggleCmds)
				table.SortByMember(toggles, "var", function(a, b) return a > b end)
				for k, v in pairs(toggles) do
					local found = false
					for a,b in pairs(HelpLabels) do
						if string.find(b.text, v.var) then
							found = b.text
							break
						end
					end
					if found then
						local checkbox = vgui.Create("DCheckBoxLabel")
						checkbox:SetValue(GetGlobalInt(v.var))
						checkbox:SetText(found)
						function checkbox.Button:Toggle()
							if ( self:GetChecked() == nil || !self:GetChecked() ) then 
								self:SetValue( true ) 
							else 
								self:SetValue( false ) 
							end 
							local tonum = {}
							tonum[false] = "0"
							tonum[true] = "1"
							LocalPlayer():ConCommand("rp_"..v.var .. " " .. tonum[self:GetChecked()])
						end
						TogglePanel:AddItem(checkbox)
					end
				end
			ToggleCat:SetContents(TogglePanel)
			self:AddItem(ToggleCat)
			function ToggleCat:Toggle()
				self:SetExpanded( !self:GetExpanded() ) 
				self.animSlide:Start( self:GetAnimTime(), { From = self:GetTall() } ) 
				if not self:GetExpanded() and ValueCat:GetExpanded() then
					ValuePanel:SetTall(470)
				elseif self:GetExpanded() and ValueCat:GetExpanded() then
					ValuePanel:SetTall(230)
					TogglePanel:SetTall(230)
				elseif self:GetExpanded() and not ValueCat:GetExpanded() then
					TogglePanel:SetTall(470)
				end 
				self:InvalidateLayout( true ) 
				self:GetParent():InvalidateLayout() 
				self:GetParent():GetParent():InvalidateLayout() 
				local cookie = '1' 
				if ( !self:GetExpanded() ) then cookie = '0' end 
				self:SetCookie( "Open", cookie )
			end  
			
			function ValueCat:Toggle()
				self:SetExpanded( !self:GetExpanded() ) 
				self.animSlide:Start( self:GetAnimTime(), { From = self:GetTall() } ) 

				if not self:GetExpanded() and ToggleCat:GetExpanded() then
					TogglePanel:SetTall(470)
				elseif self:GetExpanded() and ToggleCat:GetExpanded() then
					TogglePanel:SetTall(230)
					ValuePanel:SetTall(230)
				elseif self:GetExpanded() and not ToggleCat:GetExpanded() then
					ValuePanel:SetTall(470)
				end 
				self:InvalidateLayout( true ) 
				self:GetParent():InvalidateLayout() 
				self:GetParent():GetParent():InvalidateLayout()
				local cookie = '1' 
				if ( !self:GetExpanded() ) then cookie = '0' end 
				self:SetCookie( "Open", cookie )
			end  
				local values = table.ClearKeys(ValueCmds)
				table.SortByMember(values, "var", function(a, b) return a > b end)
				for k, v in pairs(values) do
					local found = false
					for a,b in pairs(HelpLabels) do
						if string.find(b.text, v.var) then
							found = b.text
							break
						end
					end
					if found then
						local slider = vgui.Create("DNumSlider")
						slider:SetDecimals(0)
						slider:SetMin(0)
						slider:SetMax(3000)
						slider:SetText(found)
						slider:SetValue(GetGlobalInt(v.var))
						
						function slider.Slider:OnMouseReleased()
							self:SetDragging( false ) 
							self:MouseCapture( false ) 
							LocalPlayer():ConCommand("rp_"..v.var .. " " .. slider:GetValue())
						end
						function slider.Wang:EndWang()
							self:MouseCapture( false ) 
							self.Dragging = false 
							self.HoldPos = nil 
							self.Wanger:SetCursor( "" ) 
							if ( ValidPanel( self.IndicatorT ) ) then self.IndicatorT:Remove() end 
							if ( ValidPanel( self.IndicatorB ) ) then self.IndicatorB:Remove() end 
							LocalPlayer():ConCommand("rp_"..v.var .. " " .. self:GetValue())
						end
						function slider.Wang.TextEntry:OnEnter()
							LocalPlayer():ConCommand("rp_"..v.var .. " " .. self:GetValue())
						end
						ValuePanel:AddItem(slider)
					end
				end
			ValueCat:SetContents(ValuePanel)
			self:AddItem(ValueCat)
		end
		AdminPanel:Update()
	return AdminPanel
end

local DefaultWeapons = {
{name = "GravGun",class = "weapon_physcannon"},
{name = "Physgun",class = "weapon_physgun"},
{name = "Crowbar",class = "weapon_crowbar"},
{name = "Stunstick",class = "weapon_stunstick"},
{name = "Pistol",class = "weapon_pistol"},
{name = "357",	class = "weapon_357"},
{name = "SMG", class = "weapon_smg1"},
{name = "Shotgun", class = "weapon_shotgun"},
{name = "Crossbow", class = "weapon_crossbow"},
{name = "AR2", class = "weapon_ar2"},
{name = "BugBait",	class = "weapon_bugbait"},
{name = "RPG", class = "weapon_rpg"}
}

function RPLicenseWeaponsTab()
	local weaponspanel = vgui.Create("DPanelList")
	weaponspanel:SetSpacing(1)
	weaponspanel:EnableHorizontal(false)
	weaponspanel:EnableVerticalScrollbar(true)
		function weaponspanel:Update()
			self:Clear(true)
			local Explanation = vgui.Create("DLabel")
			Explanation:SetText("License weapons\n\nTick the weapons you think people DO NOT need a license for\nUntick the weapons you think people DO need a license for\n\nDefault weapons:\n") 
			Explanation:SizeToContents()
			self:AddItem(Explanation)
			
			for k,v in pairs(DefaultWeapons) do
				local checkbox = vgui.Create("DCheckBoxLabel")
				checkbox:SetText(v.name)
				checkbox:SetValue(GetGlobalInt("licenseweapon_"..v.class))
				function checkbox.Button:Toggle()
					if ( self:GetChecked() == nil || !self:GetChecked() ) then 
						self:SetValue( true ) 
					else 
						self:SetValue( false ) 
					end 
					local tonum = {}
					tonum[false] = "0"
					tonum[true] = "1"
					RunConsoleCommand("rp_licenseweapon_".. v.class, tonum[self:GetChecked()])
				end
				self:AddItem(checkbox)
			end
			
			local OtherWeps = vgui.Create("DLabel")
			OtherWeps:SetText("\nOther weapons:\n") 
			OtherWeps:SizeToContents()
			self:AddItem(OtherWeps)
			for k,v in pairs(weapons.GetList()) do
				if v.Classname and not string.find(string.lower(v.Classname), "base") and v.Classname ~= "" then
					local checkbox = vgui.Create("DCheckBoxLabel")
					checkbox:SetText(v.PrintName)
					checkbox:SetValue(GetGlobalInt("licenseweapon_"..v.Classname))
					function checkbox.Button:Toggle()
						if ( self:GetChecked() == nil || !self:GetChecked() ) then 
							self:SetValue( true ) 
						else 
							self:SetValue( false ) 
						end 
						local tonum = {}
						tonum[false] = "0"
						tonum[true] = "1"
						RunConsoleCommand("rp_licenseweapon_".. string.lower(v.Classname), tonum[self:GetChecked()])
					end
					self:AddItem(checkbox)
				end
			end
		end
	weaponspanel:Update()
	return weaponspanel
end
