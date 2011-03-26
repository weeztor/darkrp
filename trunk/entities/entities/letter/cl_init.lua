include("shared.lua")

function ENT:Draw()
	self.Entity:DrawModel()
end

local function ShowLetter(msg)
	local LetterMsg = ""
	local LetterType = msg:ReadShort()
	local LetterPos = msg:ReadVector()
	local sectionCount = msg:ReadShort()
	local LetterY = ScrH() / 2 - 300
	local LetterAlpha = 255

	for k=1, sectionCount do
		LetterMsg = LetterMsg .. msg:ReadString()
	end

	hook.Add("HUDPaint", "ShowLetter", function()
		if LetterAlpha < 255 then
			LetterAlpha = math.Clamp(LetterAlpha + 400 * FrameTime(), 0, 255)
		end

		local font = (LetterType == 1 and "AckBarWriting") or "Default"

		draw.RoundedBox(2, ScrW() * .2, LetterY, ScrW() * .8 - (ScrW() * .2), ScrH(), Color(255, 255, 255, math.Clamp(LetterAlpha, 0, 200)))
		draw.DrawText(LetterMsg, font, ScrW() * .25 + 20, LetterY + 80, Color(0, 0, 0, LetterAlpha), 0)

		if LocalPlayer():GetPos():Distance(LetterPos) > 100 then
			LetterY = Lerp(0.1, LetterY, ScrH())
			LetterAlpha = Lerp(0.1, LetterAlpha, 0)
			if math.Round(LetterY) == 0 then
				hook.Remove("HUDPaint", "ShowLetter")
			end
		end
	end)
end
usermessage.Hook("ShowLetter", ShowLetter)

function KillLetter(msg) 
	hook.Remove("HUDPaint", "ShowLetter")
end
usermessage.Hook("KillLetter", KillLetter)