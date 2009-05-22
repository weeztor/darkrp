-- ========================
-- =          Crate SENT by Mahalis
-- ========================

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	self.Entity:SetModel("models/props/cs_office/microwave.mdl")
	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
	self.Entity:SetSolid(SOLID_VPHYSICS)
	local phys = self.Entity:GetPhysicsObject()
	if phys and phys:IsValid() then phys:Wake() end
	self.Entity:SetNWBool("sparking",false)
	self.Entity:SetNWInt("damage",100)
	local ply = self.Entity:GetNWEntity("owning_ent")
	ply:SetNWInt("maxMicrowaves", ply:GetNWInt("maxMicrowaves") + 1)
end

function ENT:OnTakeDamage(dmg)
	self.Entity:SetNWInt("damage",self.Entity:GetNWInt("damage") - dmg:GetDamage())
	if (self.Entity:GetNWInt("damage") <= 0) then
		self.Entity:Destruct()
		self.Entity:Remove()
	end
end

function ENT:Destruct()
	local vPoint = self.Entity:GetPos()
	local effectdata = EffectData()
	effectdata:SetStart(vPoint)
	effectdata:SetOrigin(vPoint)
	effectdata:SetScale(1)
	util.Effect("Explosion", effectdata)
end

function ENT:SalePrice(activator)
	local owner = self.Entity:GetNWEntity("owning_ent")
	local discounted = math.ceil(GetGlobalInt("microwavefoodcost") * 0.82)

	if activator == owner then
		-- If they are still a cook, sell them the food at the discounted rate
		if activator:Team() == TEAM_COOK then
			return discounted
		else -- Otherwise, sell it to them at full price
			return math.floor(GetGlobalInt("microwavefoodcost"))
		end
	else
		return self:GetNWInt("price")
	end
end
ENT.Once = false
function ENT:Use(activator,caller)
	local owner = self.Entity:GetNWEntity("owning_ent")
	self.Entity:SetNWEntity("user", activator)
	if not activator:CanAfford(self:SalePrice(activator)) then
		Notify(activator, 1, 3, "You do not have enough money to purchase food!")
		return ""
	end
	local diff = (self:SalePrice(activator) - self:SalePrice(owner))
	if diff < 0 and not owner:CanAfford(math.abs(diff)) then
		Notify(activator, 1, 3, "Microwave owner is too poor to subsidize this sale!")
		return ""
	end
	if (activator:GetNWInt("maxFoods") >= CfgVars["maxfoods"]) then
		Notify(activator, 1, 3, "You have reached the food limit.")
	elseif not self.Once then
		self.Once = true
		self.Entity:SetNWBool("sparking", true)
		
		local discounted = math.ceil(GetGlobalInt("microwavefoodcost") * 0.82)
		local cash = self:SalePrice(activator)

		activator:AddMoney(cash * -1)
		Notify(activator, 1, 3, "You have purchased food for " .. CUR .. tostring(cash) .. "!")

		if activator ~= owner then
			local gain = 0
			if owner:Team() == TEAM_COOK then
				gain = math.floor(self:GetNWInt("price") - discounted)
			else
				gain = math.floor(self:GetNWInt("price") - GetGlobalInt("microwavefoodcost"))
			end
			if gain == 0 then
				Notify(owner, 1, 3, "You sold some food but made no profit!")
			else
				owner:AddMoney(gain)
				local word = "profit"
				if gain < 0 then word = "loss" end
				Notify(owner, 1, 3, "You made a " .. word .. " of " .. CUR .. tostring(math.abs(gain)) .. " by selling food!")
			end
		end
		timer.Create(self.Entity:EntIndex() .. "food", 1, 1, self.createFood, self)
	end
end

function ENT:createFood()
	activator = self.Entity:GetNWEntity("user")
	self.Once = false
	local foodPos = self.Entity:GetPos()
	food = ents.Create("food")
	food:SetPos(Vector(foodPos.x,foodPos.y,foodPos.z + 23))
	food:SetNWEntity("owning_ent", activator)
	food:SetNetworkedString("Owner", "Shared")
	food.nodupe = true
	food:Spawn()
	activator:SetNWInt("maxFoods",activator:GetNWInt("maxFoods") + 1)
	self.Entity:SetNWBool("sparking", false)
end

function ENT:Think()
	if (self.Entity:GetNWBool("sparking") == true) then
		local effectdata = EffectData()
		effectdata:SetOrigin(self.Entity:GetPos())
		effectdata:SetMagnitude(1)
		effectdata:SetScale(1)
		effectdata:SetRadius(2)
		util.Effect("Sparks", effectdata)
	end
end

function ENT:OnRemove()
	timer.Destroy(self.Entity:EntIndex())
	local ply = self.Entity:GetNWEntity("owning_ent")
	ply:SetNWInt("maxMicrowaves",ply:GetNWInt("maxMicrowaves") - 1)
end