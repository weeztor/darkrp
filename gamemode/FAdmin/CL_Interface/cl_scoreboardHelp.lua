function FAdmin.ScoreBoard.Help.Show()
	FAdmin.ScoreBoard.Help.Controls.Loading = FAdmin.ScoreBoard.Help.Controls.Loading or vgui.Create("DLabel")
	FAdmin.ScoreBoard.Help.Controls.Loading:SetText("Loading help panel")


	FAdmin.ScoreBoard.Help.Controls.HelpPage = FAdmin.ScoreBoard.Help.Controls.HelpPage or vgui.Create("HTML")
	FAdmin.ScoreBoard.Help.Controls.HelpPage:SetPos(FAdmin.ScoreBoard.X + 20, FAdmin.ScoreBoard.Y + 135)
	FAdmin.ScoreBoard.Help.Controls.HelpPage:SetSize(FAdmin.ScoreBoard.Width - 40, FAdmin.ScoreBoard.Height - 90 - 60)
	FAdmin.ScoreBoard.Help.Controls.HelpPage:SetVisible(true)

	FAdmin.ScoreBoard.Help.Controls.HelpPage:OpenURL("fadmin.host-ed.net")
	FAdmin.ScoreBoard.Help.Controls.HelpPage:SetKeyBoardInputEnabled(true)
	FAdmin.ScoreBoard.Help.Controls.HelpPage:SetMouseInputEnabled(true)
	FAdmin.ScoreBoard.Help.Controls.HelpPage:RequestFocus()
	FAdmin.ScoreBoard.Help.Controls.HelpPage:MakePopup()
end