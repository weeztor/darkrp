ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Meteor"
ENT.Author = "Rickster"
ENT.Contact = "Rickyman35@hotmail.com"

function ENT:SetOffset(v)
	self.Offset = v
end

function ENT:GetOffset(name)
	return self.Offset
end