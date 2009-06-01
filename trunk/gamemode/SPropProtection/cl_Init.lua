------------------------------------
--	Simple Prop Protection
--	By Spacetech, edited by FPtje
------------------------------------

local CantTouchAlpha = 0
function SPPCanNotTouch()
	if CantTouchAlpha ~= 0 then return end
	for i = 1, 510, 1 do
		timer.Simple(i/510, function(i)
			if i <= 255 then
				CantTouchAlpha = i
			else
				CantTouchAlpha = 255 - (i-255)
			end
		end, i)
	end
end
usermessage.Hook("SPPCantTouch", SPPCanNotTouch)

function SPropProtection.HUDPaint()
	if not LocalPlayer() or not LocalPlayer():IsValid() then
		return
	end
	local tr = util.TraceLine(util.GetPlayerTrace(LocalPlayer()))
	if tr.HitNonWorld then
		if tr.Entity:IsValid() and not tr.Entity:IsPlayer() and not LocalPlayer():InVehicle() then
			local PropOwner = "Owner: "
			local OwnerObj = tr.Entity:GetNetworkedEntity("OwnerObj", false)
			if OwnerObj and OwnerObj:IsValid() then
				PropOwner = PropOwner..OwnerObj:Name()
			else
				PropOwner = PropOwner..tostring(tr.Entity:GetNetworkedString("Owner", "N/A"))
			end
			
			surface.SetFont("Default")
			local Width, Height = surface.GetTextSize(PropOwner)
			Width = Width + 25
			local r,g,b,a = GetConVarNumber("backgroundr"), GetConVarNumber("backgroundg"), GetConVarNumber("backgroundb"), GetConVarNumber("backgrounda")
			draw.RoundedBox(4, 0, ScrH() - GetConVarNumber("HudHeight")-123, Width, Height, Color(r,g,b,a))
			draw.SimpleText(PropOwner, "Default", Width / 2, ScrH() - GetConVarNumber("HudHeight")-115, Color(255, 255, 255, 255), 1, 1)
		end
	end
	if CantTouchAlpha ~= 0 then
		local QuadTable = {}  
		
		QuadTable.texture 	= surface.GetTextureID( "gui/silkicons/check_off" ) 
		QuadTable.color		= Color( 255, 255, 255, CantTouchAlpha )  
		
		QuadTable.x = ScrW()/2 - 8
		QuadTable.y = ScrH()/2 - 8
		QuadTable.w = 16
		QuadTable.h = 16
		draw.TexturedQuad( QuadTable )
	end
end
hook.Add("HUDPaint", "SPropProtection.HUDPaint", SPropProtection.HUDPaint)

function SPropProtection.AdminPanel(Panel)
	Panel:ClearControls()
	
	if not LocalPlayer():IsAdmin() then
		Panel:AddControl("Label", {Text = "You need to be admin in order to be able to view this menu."})
		return
	end
	
	if not SPropProtection.AdminCPanel then
		SPropProtection.AdminCPanel = Panel
	end
	
	Panel:AddControl("Label", {Text = "Admin Panel - Simple Prop Protection by Spacetech"})
	
	local function DoToggle(chkbx, command)
		if chkbx:GetChecked() == nil or not chkbx:GetChecked() then 
			chkbx:SetValue( true ) 
		else 
			chkbx:SetValue( false ) 
		end 
		local tonum = {}
		tonum[false] = "0"
		tonum[true] = "1"
		RunConsoleCommand(command, tonum[chkbx:GetChecked()])
	end
	
	local function AddOption(text, command, value)
		local box = vgui.Create("DCheckBoxLabel")
		box:SetText(text)
		box:SetValue(util.tobool(GetGlobalInt(value)))
		function box.Button:Toggle() DoToggle(self, command) end
		Panel:AddPanel(box)
	end
	
	AddOption("Prop Protection On/Off", "rp_spp_on", "spp_on")
	AddOption("Admins Can Do Everything On/Off", "rp_spp_admin", "spp_admin")
	AddOption("Use Protection On/Off", "rp_spp_use", "spp_use")
	AddOption("Entity Damage Protection On/Off", "rp_spp_entdamage", "spp_entdamage")
	AddOption("Physgun Reload Protection On/Off", "rp_spp_physreload", "spp_physreload")
	AddOption("People can Touch World Props On/Off", "rp_spp_touchworldprops", "spp_touchworldprops")
	AddOption("Disconnect Prop Deletion On/Off", "rp_spp_propdeletion", "spp_propdeletion")
	AddOption("Delete Admin Entities On/Off", "rp_spp_deleteadminents", "spp_deleteadminents")

	Panel:AddControl("Label", {Text = "Cleanup Panel"})
	
	for k, ply in pairs(player.GetAll()) do
		if ply and ply:IsValid() then
			Panel:AddControl("Button", {Text = ply:Nick(), Command = "SPropProtection_CleanupProps "..ply:UserID()})
		end
	end
	
	Panel:AddControl("Label", {Text = "Other Cleanup Options"})
	Panel:AddControl("Button", {Text = "Cleanup Disconnected Players Props", Command = "SPropProtection_CleanupDisconnectedProps"})
end

function SPropProtection.ClientPanel(Panel)
	Panel:ClearControls()
	
	if not SPropProtection.ClientCPanel then
		SPropProtection.ClientCPanel = Panel
	end
	
	Panel:AddControl("Label", {Text = "Client Panel - Simple Prop Protection by Spacetech"})
	
	Panel:AddControl("Button", {Text = "Cleanup All Props", Command = "SPropProtection_CleanupProps"})
	Panel:AddControl("Label", {Text = "Buddies Panel"})
	
	local Players = player.GetAll()
	if table.Count(Players) == 1 then
		Panel:AddControl("Label", {Text = "No Other Players Are Online"})
	else
		for k, ply in pairs(Players) do
			if(ply and ply:IsValid() and ply ~= LocalPlayer()) then
				local BCommand = "SPropProtection_BuddyUp_"..ply:UserID()
				if not LocalPlayer():GetInfo(BCommand) then
					CreateClientConVar(BCommand, 0, false, true)
				end
				Panel:AddControl("CheckBox", {Label = ply:Nick(), Command = BCommand})
			end
		end
		Panel:AddControl("Button", {Text  = "Apply Settings", Command = "SPropProtection_ApplyBuddySettings"})
	end
	Panel:AddControl("Button", {Text  = "Clear All Buddies", Command = "SPropProtection_ClearBuddies"})
end

function SPropProtection.SpawnMenuOpen()
	if SPropProtection.AdminCPanel then
		SPropProtection.AdminPanel(SPropProtection.AdminCPanel)
	end
	
	if SPropProtection.ClientCPanel then
		SPropProtection.ClientPanel(SPropProtection.ClientCPanel)
	end
end
hook.Add("SpawnMenuOpen", "SPropProtection.SpawnMenuOpen", SPropProtection.SpawnMenuOpen)

function SPropProtection.PopulateToolMenu()
	spawnmenu.AddToolMenuOption("Utilities", "Simple Prop Protection", "Admin", "Admin", "", "", SPropProtection.AdminPanel)
	spawnmenu.AddToolMenuOption("Utilities", "Simple Prop Protection", "Client", "Client", "", "", SPropProtection.ClientPanel)
end
hook.Add("PopulateToolMenu", "SPropProtection.PopulateToolMenu", SPropProtection.PopulateToolMenu)
