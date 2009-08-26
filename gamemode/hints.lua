local hints = rp_languages[GetConVarString("rp_language")]

local function GiveHint()
	if CfgVars["advertisements"] ~= 1 then return end
	local text = hints[math.random(1, #hints)]

	for k,v in pairs(player.GetAll()) do
		TalkToPerson(v, Color(150,150,150,150), text)
	end
end

timer.Create("hints", 60, 0, GiveHint)
