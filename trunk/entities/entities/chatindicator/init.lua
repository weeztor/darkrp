AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "cl_init.lua" )

include( "cl_init.lua" )

function ENT:Initialize()
	
	self:SetModel( "models/extras/info_speech.mdl" )
	
--	self:PhysicsInit( SOLID_NONE )
	self:SetMoveType( MOVETYPE_NOCLIP )
	self:SetSolid( SOLID_NONE )
	
	local phys = self:GetPhysicsObject()
	if phys and phys:IsValid() then phys:Wake() end
	
end

function ENT:Think()
	
	local angles = self:GetAngles()
	self:SetAngles( Angle( angles.p + 5, angles.y + 5, angles.r + 5 ) )
	
	if not ValidEntity( self.ply ) then -- just in case
	
		self:Remove()
		
		return
	end
	
	self:SetPos( self.ply:GetPos() + Vector( 0, 0, 85 ) )
	
end

local function ToggleChatIndicator( ply )
	
	if not ValidEntity( ply.ChatIndicator ) then
	
		ply.ChatIndicator = ents.Create( "chatindicator" )
		ply.ChatIndicator.ply = ply -- plyception
		ply.ChatIndicator:SetPos( ply:GetPos() + Vector( 0, 0, 85 ) )
		ply.ChatIndicator:Spawn()
		ply.ChatIndicator:Activate()
	
	else
	
		ply.ChatIndicator:Remove()
		
	end
	
end
concommand.Add( "_DarkRP_ToggleChat", ToggleChatIndicator )

local function RemoveChatIndicator( ply )
	
	if ValidEntity( ply.ChatIndicator ) then
	
		ply.ChatIndicator:Remove()
		
	end

end
hook.Add( "PlayerDisconnected", "Disc_RemoveIndicator", RemoveChatIndicator )
hook.Add( "KeyPress", "Move_RemoveIndicator", RemoveChatIndicator ) -- so people can't abuse the command.
hook.Add( "PlayerDeath", "Die_RemoveIndicator", RemoveChatIndicator )