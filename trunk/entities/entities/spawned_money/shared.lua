ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Spawned Money"
ENT.Author = "FPtje"
ENT.Spawnable = false
ENT.AdminSpawnable = false

local ENTITY = FindMetaTable("Entity")
function ENTITY:IsMoneyBag()
	return self:GetClass() == "spawned_money"
end