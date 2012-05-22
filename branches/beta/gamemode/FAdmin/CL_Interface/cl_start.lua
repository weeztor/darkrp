FAdmin.ScoreBoard = {}

local ScreenWidth, ScreenHeight = ScrW(), ScrH()
	
FAdmin.ScoreBoard.X = ScreenWidth * 0.05
FAdmin.ScoreBoard.Y = ScreenHeight * 0.025
FAdmin.ScoreBoard.Width = ScreenWidth * 0.9
FAdmin.ScoreBoard.Height = ScreenHeight * 0.95

FAdmin.ScoreBoard.Controls = {}
FAdmin.ScoreBoard.CurrentView = "Main"

FAdmin.ScoreBoard.Main = {}
FAdmin.ScoreBoard.Main.Controls = {}
FAdmin.ScoreBoard.Main.Logo = "gui/gmod_logo"

FAdmin.ScoreBoard.Player = {}
FAdmin.ScoreBoard.Player.Controls = {}
FAdmin.ScoreBoard.Player.Player = NULL
FAdmin.ScoreBoard.Player.Logo = "FAdmin/back"

FAdmin.ScoreBoard.Server = {}
FAdmin.ScoreBoard.Server.Controls = {}
FAdmin.ScoreBoard.Server.Logo = "FAdmin/back"

FAdmin.ScoreBoard.Help = {}
FAdmin.ScoreBoard.Help.Controls = {}
FAdmin.ScoreBoard.Help.Logo = "FAdmin/back"

-- These fonts used to exist in GMod 12 but were removed in 13.
surface.CreateFont("Trebuchet MS",18,500,true,false,"Trebuchet18")
surface.CreateFont("Trebuchet MS",19,500,true,false,"Trebuchet19")
surface.CreateFont("Trebuchet MS",20,500,true,false,"Trebuchet20")
surface.CreateFont("Trebuchet MS",22,500,true,false,"Trebuchet22")
surface.CreateFont("Trebuchet MS",24,500,true,false,"Trebuchet24")
surface.CreateFont("Trebuchet MS",17,700,true,false,"TabLarge",true)
surface.CreateFont("Default",16,800,true,false,"UiBold")
surface.CreateFont("coolvetica",32,500,true,false,"ScoreboardHeader")
surface.CreateFont("coolvetica",22,500,true,false,"ScoreboardSubtitle")
surface.CreateFont("coolvetica",19,500,true,false,"ScoreboardPlayerName")
surface.CreateFont("coolvetica",15,500,true,false,"ScoreboardPlayerName2")
surface.CreateFont("coolvetica",22,500,true,false,"ScoreboardPlayerNameBig")