CreateClientConVar("FAdmin_IsScoreboard", 1, true, false) -- Set if it's a scoreboard or not

function FAdmin.ScoreBoard.ChangeView(newView, ...)
	if FAdmin.ScoreBoard.CurrentView == newView then return end
	for k,v in pairs(FAdmin.ScoreBoard[FAdmin.ScoreBoard.CurrentView].Controls) do
		v:SetVisible(false)
	end
	
	FAdmin.ScoreBoard.CurrentView = newView
	FAdmin.ScoreBoard[newView].Show(...)
	FAdmin.ScoreBoard.ChangeGmodLogo(FAdmin.ScoreBoard[newView].Logo)
	
	FAdmin.ScoreBoard.Controls.BackButton = FAdmin.ScoreBoard.Controls.BackButton or vgui.Create("DButton")
	FAdmin.ScoreBoard.Controls.BackButton:SetVisible(true)
	FAdmin.ScoreBoard.Controls.BackButton:SetPos(FAdmin.ScoreBoard.X, FAdmin.ScoreBoard.Y)
	FAdmin.ScoreBoard.Controls.BackButton:SetText("")
	FAdmin.ScoreBoard.Controls.BackButton:SetToolTip("Click me to go back!")
	FAdmin.ScoreBoard.Controls.BackButton:SetCursor("hand")
	FAdmin.ScoreBoard.Controls.BackButton:SetSize(100,90)
	
	function FAdmin.ScoreBoard.Controls.BackButton:DoClick()
		FAdmin.ScoreBoard.ChangeView("Main")
	end
	FAdmin.ScoreBoard.Controls.BackButton.Paint = function()end
	
	if newView == "Main" then FAdmin.ScoreBoard.Controls.BackButton:SetVisible(false) end
end

local GmodLogo, TempGmodLogo, GmodLogoColor = surface.GetTextureID("gui/gmod_logo"), surface.GetTextureID("gui/gmod_logo"), Color(255,255,255,255)//"FAdmin/back", gui/gmod_tool
function FAdmin.ScoreBoard.ChangeGmodLogo(new)
	if surface.GetTextureID(new) == TempGmodLogo then return end
	TempGmodLogo = surface.GetTextureID(new)
	for i = 0, 0.5, 0.01 do
		timer.Simple(i, function() GmodLogoColor = Color(255,255,255,GmodLogoColor.a-5.1) end)
	end
	timer.Simple(0.5, function() GmodLogo = surface.GetTextureID(new) end, new)
	for i = 0.5, 1, 0.01 do
		timer.Simple(i, function() GmodLogoColor = Color(255,255,255,GmodLogoColor.a+5.1) end)
	end
end

local BackgroundTexture = surface.GetTextureID("console/background01")
function FAdmin.ScoreBoard.Background()
	local ScreenWidth, ScreenHeight = ScrW(), ScrH()
	surface.SetDrawColor(255,255,255,100)
	surface.SetTexture(BackgroundTexture)
	surface.DrawTexturedRect(FAdmin.ScoreBoard.X, FAdmin.ScoreBoard.Y, FAdmin.ScoreBoard.Width, FAdmin.ScoreBoard.Height)
	
	surface.SetDrawColor(0,0,0,200)
	surface.DrawRect(FAdmin.ScoreBoard.X, FAdmin.ScoreBoard.Y, FAdmin.ScoreBoard.Width, FAdmin.ScoreBoard.Height)
	
	surface.SetTexture(GmodLogo)
	surface.SetDrawColor(255,255,255,GmodLogoColor.a)
	surface.DrawTexturedRect(FAdmin.ScoreBoard.X - 20, FAdmin.ScoreBoard.Y, 128, 128)
end


function FAdmin.ScoreBoard.DrawScoreBoard()
	if input.IsMouseDown(MOUSE_4) or input.IsKeyDown(KEY_BACKSPACE) then
		FAdmin.ScoreBoard.ChangeView("Main")
	end
	FAdmin.ScoreBoard.Background()
end

function FAdmin.ScoreBoard.ShowScoreBoard()
	FAdmin.ScoreBoard.Visible = true
	local ScreenWidth, ScreenHeight = ScrW(), ScrH()
	
	FAdmin.ScoreBoard.Controls.Hostname = FAdmin.ScoreBoard.Controls.Hostname or vgui.Create( "Label", self )
	FAdmin.ScoreBoard.Controls.Hostname:SetText(GetHostName())
	FAdmin.ScoreBoard.Controls.Hostname:SetFont("ScoreboardHeader")
	FAdmin.ScoreBoard.Controls.Hostname:SetPos(FAdmin.ScoreBoard.X + 90, FAdmin.ScoreBoard.Y + 20)
	FAdmin.ScoreBoard.Controls.Hostname:SizeToContents()
	FAdmin.ScoreBoard.Controls.Hostname:SetVisible(true)
	
	FAdmin.ScoreBoard.Controls.Description = FAdmin.ScoreBoard.Controls.Description or vgui.Create( "Label" )
	FAdmin.ScoreBoard.Controls.Description:SetText(GAMEMODE.Name .. "\n\t"..GAMEMODE.Author)
	FAdmin.ScoreBoard.Controls.Description:SetFont("ScoreboardSubtitle")
	FAdmin.ScoreBoard.Controls.Description:SetPos(FAdmin.ScoreBoard.X + 90, FAdmin.ScoreBoard.Y + 50)
	FAdmin.ScoreBoard.Controls.Description:SizeToContents()
	if FAdmin.ScoreBoard.X + FAdmin.ScoreBoard.Width / 9.5 + FAdmin.ScoreBoard.Controls.Description:GetWide() > FAdmin.ScoreBoard.Width - 150 then
		FAdmin.ScoreBoard.Controls.Description:SetFont("Trebuchet18")
		FAdmin.ScoreBoard.Controls.Description:SetPos(FAdmin.ScoreBoard.X + 90, FAdmin.ScoreBoard.Y + 50)
	end
	FAdmin.ScoreBoard.Controls.Description:SetVisible(true)
	
	FAdmin.ScoreBoard.Controls.ServerSettingsLabel = FAdmin.ScoreBoard.Controls.ServerSettingsLabel or vgui.Create("Label")
	FAdmin.ScoreBoard.Controls.ServerSettingsLabel:SetFont("ScoreboardSubtitle")
	FAdmin.ScoreBoard.Controls.ServerSettingsLabel:SetText("Server settings")
	FAdmin.ScoreBoard.Controls.ServerSettingsLabel:SizeToContents()
	FAdmin.ScoreBoard.Controls.ServerSettingsLabel:SetPos(FAdmin.ScoreBoard.Width-150, FAdmin.ScoreBoard.Y + 68)
	FAdmin.ScoreBoard.Controls.ServerSettingsLabel:SetVisible(true)
	
	FAdmin.ScoreBoard.Controls.ServerSettings = FAdmin.ScoreBoard.Controls.ServerSettings or vgui.Create("DImageButton")
	FAdmin.ScoreBoard.Controls.ServerSettings:SetMaterial("vgui/gmod_tool")
	FAdmin.ScoreBoard.Controls.ServerSettings:SetPos(FAdmin.ScoreBoard.Width-200, FAdmin.ScoreBoard.Y - 20)
	FAdmin.ScoreBoard.Controls.ServerSettings:SizeToContents()
	FAdmin.ScoreBoard.Controls.ServerSettings:SetVisible(true)
	
	if FAdmin.ScoreBoard.CurrentView ~= "Main" then FAdmin.ScoreBoard.Controls.BackButton:SetVisible(true) end
	
	function FAdmin.ScoreBoard.Controls.ServerSettings:DoClick()
		FAdmin.ScoreBoard.ChangeView("Server")
	end
	
	FAdmin.ScoreBoard[FAdmin.ScoreBoard.CurrentView].Show()
	
	gui.EnableScreenClicker(true)
	hook.Add("HUDPaint", "FAdmin_ScoreBoard", FAdmin.ScoreBoard.DrawScoreBoard)
	return true
end
concommand.Add("+FAdmin_menu", FAdmin.ScoreBoard.ShowScoreBoard)

hook.Add("ScoreboardShow", "FAdmin_scoreboard", function()
	if GAMEMODE and tobool(GetConVarNumber("FAdmin_IsScoreboard")) and FAdmin.GlobalSetting.FAdmin then -- Don't show scoreboard when FAdmin is not installed on server 
		return FAdmin.ScoreBoard.ShowScoreBoard()
	end
end)

function FAdmin.ScoreBoard.HideScoreBoard()
	if not FAdmin.GlobalSetting.FAdmin then return end
	FAdmin.ScoreBoard.Visible = false
	CloseDermaMenus()
	
	gui.EnableScreenClicker(false)
	hook.Remove("HUDPaint", "FAdmin_ScoreBoard")
	
	for k,v in pairs(FAdmin.ScoreBoard[FAdmin.ScoreBoard.CurrentView].Controls) do
		v:SetVisible(false)
	end
	
	for k,v in pairs(FAdmin.ScoreBoard.Controls) do
		v:SetVisible(false)
	end
	return true
end
concommand.Add("-FAdmin_menu", FAdmin.ScoreBoard.HideScoreBoard)

hook.Add("ScoreboardHide", "FAdmin_scoreboard", function()
	if tobool(GetConVarNumber("FAdmin_IsScoreboard")) and FAdmin.GlobalSetting.FAdmin then -- Don't show scoreboard when FAdmin is not installed on server 
		return FAdmin.ScoreBoard.HideScoreBoard()
	end
end)