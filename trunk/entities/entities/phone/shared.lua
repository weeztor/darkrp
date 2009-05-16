

ENT.Type = "anim"
ENT.Base = "base_gmodentity"

ENT.PrintName		= "Banana phone"
ENT.Author			= "FPtje"
ENT.Contact			= ""
ENT.Purpose			= "Ring ding ding ding ding ding ding"
ENT.Instructions	= "USE ME!"

ENT.Spawnable = false
ENT.AdminSpawnable = false



function ENT:SetLabel(  )
	local text = "TELEPHONE FOR YOU SIR!"
	self:SetOverlayText( text )
end

