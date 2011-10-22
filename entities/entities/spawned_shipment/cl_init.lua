include("shared.lua")

local matBallGlow = Material("models/props_combine/tpballglow")
function ENT:Draw()
	
	if not self.height then self.height = 0 end
	if not self.colr then self.colr = 1 end
	if not self.colg then self.colg = 0 end
	if not self.StartTime then self.StartTime = CurTime() end
	
	if GetConVarNumber("shipmentspawntime") > 0 and self.height < self:OBBMaxs().z then
	
		SetMaterialOverride(matBallGlow)
		
		render.SetColorModulation( self.colr, self.colg, 0 )
		
		self.Entity:DrawModel()
		
		self.colr = 1 / ( ( CurTime() - self.StartTime ) / GetConVarNumber( "shipmentspawntime" ) )
		self.colg = ( CurTime() - self.StartTime ) / GetConVarNumber( "shipmentspawntime" )
		
		render.SetColorModulation( 1, 1, 1 )
		
		SetMaterialOverride()
	
		local normal = - self:GetAngles():Up()
		local pos = self:LocalToWorld( Vector( 0, 0, self:OBBMins().z + self.height ) )
		local distance = normal:Dot( pos )
		self.height = self:OBBMaxs().z * ( ( CurTime() - self.StartTime ) / GetConVarNumber( "shipmentspawntime" ) ) 
		render.EnableClipping( true )
		render.PushCustomClipPlane( normal, distance );
		
		self.Entity:DrawModel()
		
		render.PopCustomClipPlane()
		
	else
	
		self.Entity:DrawModel()
		
	end
	
	local Pos = self:GetPos()
	local Ang = self:GetAngles()
	
	local content = self.dt.contents or ""
	local contents = CustomShipments[content]
	if not contents then return end
	contents = contents.name
	
	surface.SetFont("HUDNumber5")
	local TextWidth = surface.GetTextSize("Contents:")
	local TextWidth2 = surface.GetTextSize(contents)
	
	cam.Start3D2D(Pos + Ang:Up() * 25, Ang, 0.2)
		draw.WordBox(2, -TextWidth*0.5 + 5, -30, "Contents:", "HUDNumber5", Color(140, 0, 0, 100), Color(255,255,255,255))
		draw.WordBox(2, -TextWidth2*0.5 + 5, 18, contents, "HUDNumber5", Color(140, 0, 0, 100), Color(255,255,255,255))
	cam.End3D2D()
	
	Ang:RotateAroundAxis(Ang:Forward(), 90)
	
	TextWidth = surface.GetTextSize("Amount left:")
	TextWidth2 = surface.GetTextSize(self.dt.count)
	
	cam.Start3D2D(Pos + Ang:Up() * 17, Ang, 0.14)
		draw.WordBox(2, -TextWidth*0.5 + 5, -150, "Amount left:", "HUDNumber5", Color(140, 0, 0, 100), Color(255,255,255,255))
		draw.WordBox(2, -TextWidth2*0.5 + 0, -102, self.dt.count, "HUDNumber5", Color(140, 0, 0, 100), Color(255,255,255,255))
	cam.End3D2D()
	
end