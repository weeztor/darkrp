include("shared.lua")

function ENT:Draw()
	self.Entity:DrawModel()
	
	local Pos = self:GetPos()
	local Ang = self:GetAngles()
	
	surface.SetFont("ChatFont")
	local TextWidth = surface.GetTextSize("$"..tostring(self.dt.amount))
	
	cam.Start3D2D(Pos + Ang:Up(), Ang, 0.1)
		surface.SetDrawColor(230, 255, 230, 255)
		surface.SetTextPos(-TextWidth*0.5, -10)
		surface.SetFont("ChatFont")
		surface.DrawText("$"..tostring(self.dt.amount))
	cam.End3D2D()
end