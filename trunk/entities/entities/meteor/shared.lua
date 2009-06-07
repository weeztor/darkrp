ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Meteor"
ENT.Author = "Rickster"
ENT.Contact = "Rickyman35@hotmail.com"

function ENT:SetOffset(v)
	self.Offset = v
end

function ENT:GetOffset(name)
	return self.Offset or Vector(math.Rand(-3, 3), math.Rand(-3, 3), math.Rand(-3, 3))
end