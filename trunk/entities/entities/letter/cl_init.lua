include("shared.lua")

local SignButton

function ENT:Draw()
	self.Entity:DrawModel()
end

local function KillLetter(msg) 
	hook.Remove("HUDPaint", "ShowLetter")
end
usermessage.Hook("KillLetter", KillLetter)

local function ShowLetter(msg)
	local LetterMsg = ""
	local Letter = msg:ReadEntity()
	local LetterType = msg:ReadShort()
	local LetterPos = msg:ReadVector()
	local sectionCount = msg:ReadShort()
	local LetterY = ScrH() / 2 - 300
	local LetterAlpha = 255

	for k=1, sectionCount do
		LetterMsg = LetterMsg .. msg:ReadString()
	end

	SignButton = vgui.Create("DButton")
	SignButton:SetText("Sign this letter")
	SignButton:SetPos(ScrW()-256, ScrH()-256)
	SignButton:SetSize(256,256)
	SignButton:SetSkin("DarkRP")
	gui.EnableScreenClicker(true)

	function SignButton:DoClick()
		RunConsoleCommand("_DarkRP_SignLetter", Letter:EntIndex())
	end
	SignButton:SetDisabled(ValidEntity(Letter.dt.signed))

	hook.Add("HUDPaint", "ShowLetter", function()
		if not Letter.dt then KillLetter() return end
		if LetterAlpha < 255 then
			LetterAlpha = math.Clamp(LetterAlpha + 400 * FrameTime(), 0, 255)
		end

		local font = (LetterType == 1 and "AckBarWriting") or "Default"

		draw.RoundedBox(2, ScrW() * .2, LetterY, ScrW() * .8 - (ScrW() * .2), ScrH(), Color(255, 255, 255, math.Clamp(LetterAlpha, 0, 200)))
		draw.DrawText(LetterMsg.."\n\n\nSigned by "..(ValidEntity(Letter.dt.signed) and Letter.dt.signed:Nick() or "no one"), font, ScrW() * .25 + 20, LetterY + 80, Color(0, 0, 0, LetterAlpha), 0)

		if LocalPlayer():GetPos():Distance(LetterPos) > 100 then
			LetterY = Lerp(0.1, LetterY, ScrH())
			LetterAlpha = Lerp(0.1, LetterAlpha, 0)

			SignButton:Remove()
			gui.EnableScreenClicker(false)
			if math.Round(LetterAlpha) <= 10 then
				KillLetter()
			end
		end
	end)
end
usermessage.Hook("ShowLetter", ShowLetter)

