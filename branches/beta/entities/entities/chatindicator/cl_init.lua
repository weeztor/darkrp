include( "shared.lua" )

function ENT:Draw()
	
	self:SetModelScale( Vector( 0.5, 0.5, 0.5 ) )
	self:DrawModel()

end

local function ToggleChat()

	RunConsoleCommand( "_DarkRP_ToggleChat" )
	
end
hook.Add( "StartChat", "StartChatIndicator", ToggleChat )
hook.Add( "FinishChat", "EndChatIndicator", ToggleChat )
