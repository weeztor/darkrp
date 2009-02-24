-- copied from serverside
FoodItems = { }
function AddFoodItem(name, mdl, amount)
	FoodItems[name] = { model = mdl, amount = amount }
end

AddFoodItem("banana", "models/props/cs_italy/bananna.mdl", 10)
AddFoodItem("bananabunch", "models/props/cs_italy/bananna_bunch.mdl", 20)
AddFoodItem("melon", "models/props_junk/watermelon01.mdl", 20)
AddFoodItem("glassbottle", "models/props_junk/GlassBottle01a.mdl", 20)
AddFoodItem("popcan", "models/props_junk/PopCan01a.mdl", 5)
AddFoodItem("plasticbottle", "models/props_junk/garbage_plasticbottle003a.mdl", 15)
AddFoodItem("milk", "models/props_junk/garbage_milkcarton002a.mdl", 20)
AddFoodItem("bottle1", "models/props_junk/garbage_glassbottle001a.mdl", 10)
AddFoodItem("bottle2", "models/props_junk/garbage_glassbottle002a.mdl", 10)
AddFoodItem("bottle3", "models/props_junk/garbage_glassbottle003a.mdl", 10)
AddFoodItem("orange", "models/props/cs_italy/orange.mdl", 20)


local HM = { }

FoodAteAlpha = -1
FoodAteY = 0

surface.CreateFont("ChatFont", 22, 500, true, false, "HungerPlus")

function HM.HUDPaint()
	if GetGlobalInt("hungermod") == 0 and LocalPlayer():GetNWInt("LocalHungerMod") ~= 1 then return end

	local x = 7
	local y = ScrH() - 9

	draw.RoundedBox(4, x - 1, y - 1, GetConVarNumber("HudWidth") , 9, Color(0, 0, 0, 255))

	if LocalPlayer():GetNWInt("Energy") > 0 then
		draw.RoundedBox(4, x, y, GetConVarNumber("HudWidth") * (math.Clamp(LocalPlayer():GetNWInt("Energy"), 0, 100) / 100), 7, Color(30, 30, 120, 255))
		draw.DrawText(math.ceil(LocalPlayer():GetNWInt("Energy")) .. "%", "DefaultSmall", GetConVarNumber("HudWidth") / 2, y - 2, Color(255, 255, 255, 255), 1)
	else
		draw.DrawText("Starving!", "ChatFont", GetConVarNumber("HudWidth") / 2, y - 4, Color(200, 0, 0, 255), 1)
	end

	if FoodAteAlpha > -1 then
		local mul = 1
		if FoodAteY <= ScrH() - 30 then
			mul = -.5
		end

		draw.DrawText("++", "HungerPlus", 208, FoodAteY + 1, Color(0, 0, 0, FoodAteAlpha), 0)
		draw.DrawText("++", "HungerPlus", 207, FoodAteY, Color(20, 100, 20, FoodAteAlpha), 0)

		FoodAteAlpha = math.Clamp(FoodAteAlpha + 1000 * FrameTime() * mul, -1, 255)
		FoodAteY = FoodAteY - 150 * FrameTime()
	end
end
hook.Add("HUDPaint", "HM.HUDPaint", HM.HUDPaint)

function AteFoodIcon(msg)
	FoodAteAlpha = 1
	FoodAteY = ScrH() - 8
end
usermessage.Hook("AteFoodIcon", AteFoodIcon)
