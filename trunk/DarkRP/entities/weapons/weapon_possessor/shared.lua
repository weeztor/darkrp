/*--------------------------------------------------------- 
	Swep Variables
---------------------------------------------------------*/ 
SWEP.IAmControlling = false
SWEP.SelectedPlayer = "nil"
SWEP.HisTotalAmmo = 0
SWEP.HisClip = 0
SWEP.HisToolMode = "nothing" 
SWEP.SelectedPlayerUserID = -1
SWEP.OwnerOldPos = Vector(0,0,0)
local FalcoThirdPersonVariable = CreateClientConVar("TheFalcoThirdPersonValue", 0, true, false)

/*--------------------------------------------------------- 
	Settings
---------------------------------------------------------*/ 
if ( SERVER ) then
	AddCSLuaFile( "shared.lua" )
	AddCSLuaFile( "cl_init.lua" )
end
SWEP.PrintName			= "Player possessor"			
SWEP.Author				= "FPtje"
SWEP.Instructions		= "Shoot the player you want to control"
SWEP.Slot				= 5
SWEP.SlotPos			= 6
SWEP.IconLetter			= "x"
SWEP.HoldType			= "pistol"
SWEP.Weight				= 1
SWEP.Spawnable			= false


/*--------------------------------------------------------- 
	Other settings
---------------------------------------------------------*/ 
SWEP.AdminSpawnable		= true
SWEP.ViewModel			= "models/weapons/v_hands.mdl"
SWEP.WorldModel			= "models/weapons/w_pistol.mdl"
SWEP.Weight				= 1
SWEP.AutoSwitchTo		= true
SWEP.AutoSwitchFrom		= true
SWEP.Primary.ClipSize		= 1
SWEP.Primary.DefaultClip	= 1
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "pistol"
SWEP.Secondary.Automatic 	= false

--[[ /*--------------------------------------------------------- 
	The thing when you select it.
---------------------------------------------------------*/ 
function SWEP:DrawWeaponSelection( x, y, wide, tall, alpha ) 
	surface.SetDrawColor(255,255,255,alpha)
	surface.DrawTexturedRect(x + wide/3 - math.random(0.2*wide, 0.3*wide), y + math.random(10, 15), 0.9*wide, 0.7*tall ) 
end
 ]]
/*--------------------------------------------------------- 
	The deploy of the weapon
---------------------------------------------------------*/ 
function SWEP:Deploy()
	self.SelectedPlayer = self.Owner
	self.WhoIsHolding = self.Owner
	return true
end

/*--------------------------------------------------------- 
	when you put the weapon away
---------------------------------------------------------*/ 
function SWEP:Holster()
	if self.IAmControlling then
		return false//Be not able to switch weapon when you're controlling.
	else
		return true
	end
end

/*--------------------------------------------------------- 
	Left mouse button
---------------------------------------------------------*/ 
function SWEP:PrimaryAttack()
	self.delay = self.delay or 0
	if self.delay < RealTime() then
		self.delay = RealTime() + 0.1
		local trace = self.Owner:GetEyeTrace()
		if !self.IAmControlling and trace.Hit and trace.Entity:IsValid() and trace.Entity:IsPlayer() then
			self.SelectedPlayer = trace.Entity
			if CLIENT then
				self.Owner:ConCommand("FSelectTarget " .. trace.Entity:UserID())
				self:DoControl()
			end
		elseif !self.IAmControlling and SERVER then
			self.Owner:SendLua("GAMEMODE:AddNotify(\"Shoot a player to control him\", 1, 5);surface.PlaySound( \"ambient/water/drip2.wav\")")
		end
	end
end
	
/*--------------------------------------------------------- 
	Right mouse button
---------------------------------------------------------*/ 
function SWEP:SecondaryAttack()
	self.delay = self.delay or 0
	if CLIENT and !self.IAmControlling and self.delay < RealTime() then	
		self.delay = RealTime() + 0.1
		ChoosePlayerWithoutShooting()
	end
end

/*--------------------------------------------------------- 
	Reload...
---------------------------------------------------------*/ 
function SWEP:Reload()
end

/*--------------------------------------------------------- 
	Stop possessing
---------------------------------------------------------*/
function StopControl(ply, cmd, args)
	local self = ply:GetActiveWeapon()
	if not self.SelectedPlayer then return false end
	self.IAmControlling = false
	if CLIENT then
		self.SelectedPlayer:SetColor(255, 255, 255, 255)
	elseif SERVER then
		if not args[1] then
			for k, v in pairs(GlobalNoControlTable) do	
				if v == self.SelectedPlayer:UserID() then
					table.remove(GlobalNoControlTable, k)
				end
			end
			self.SelectedPlayer:ConCommand("-forward")
			self.SelectedPlayer:ConCommand("-back")
			self.SelectedPlayer:ConCommand("-use")
			self.SelectedPlayer:ConCommand("-jump")
			self.SelectedPlayer:ConCommand("-duck")
			self.SelectedPlayer:ConCommand("-moveleft")
			self.SelectedPlayer:ConCommand("-moveright")
			self.SelectedPlayer:ConCommand("-zoom")
			self.SelectedPlayer:ConCommand("-attack")
			self.SelectedPlayer:ConCommand("-attack2")
			self.SelectedPlayer:ConCommand("-speed")
			self.SelectedPlayer:ConCommand("-walk")
			hook.Remove("Think", "PlayerPossessorUpdatePlayerPos")
			self.Owner:SetPos(self.OwnerOldPos)
			umsg.Start("PlayerPossessorCloseTheScreen", self.SelectedPlayer)
			umsg.End()
			self.SelectedPlayer:SendLua("GAMEMODE:AddNotify(\"" .. ply:Nick() .. " has stopped controlling you\", 1, 5);surface.PlaySound( \"ambient/water/drip2.wav\")")
			ply:SendLua("GAMEMODE:AddNotify(\"You are not controlling anymore\", 1, 5);surface.PlaySound( \"ambient/water/drip2.wav\")")
		end
		for k, v in pairs(GlobalNoControlTable) do
			if v == ply:UserID() then
				table.remove(GlobalNoControlTable, k)
			end
		end
		umsg.Start("PlayerPossessorCloseTheCreationScreen", ply)
		umsg.End()
		ply:ConCommand("-forward")
		ply:ConCommand("-back")
		ply:ConCommand("-use")
		ply:ConCommand("-jump")
		ply:ConCommand("-duck")
		ply:ConCommand("-moveleft")
		ply:ConCommand("-moveright")
		ply:ConCommand("-zoom")
		ply:ConCommand("-attack")
		ply:ConCommand("-attack2")
		ply:ConCommand("-speed")
		ply:ConCommand("-walk")
		ply:SetMoveType(MOVETYPE_WALK)
		ply:SetColor(255, 255, 255, 255)
		ply:GodDisable()
		ply:SetCollisionGroup( COLLISION_GROUP_PLAYER )
		ply:DrawViewModel(true)
		ply:DrawWorldModel(true)
	end
end
if SERVER then
	concommand.Add("PlayerPossessorStopPossessingSERVER", StopControl)
elseif CLIENT then
	concommand.Add("PlayerPossessorStopPossessingCLIENT", StopControl)
end

/*--------------------------------------------------------- 
	This function is to start controlling
---------------------------------------------------------*/ 
function SWEP:DoControl()
	if SERVER then
		if table.HasValue(GlobalNoControlTable, self.SelectedPlayer:UserID()) or table.HasValue(GlobalNoControlTable, self.Owner:UserID()) then
			self.Owner:SendLua("GAMEMODE:AddNotify(\"You can't control him\", 1, 5);surface.PlaySound( \"ambient/water/drip2.wav\")")
			self.Owner:ConCommand("PlayerPossessorStopPossessingCLIENT")
			self.Owner:ConCommand("PlayerPossessorStopPossessingSERVER noremovefromtable")
			return false
		else
			table.insert(GlobalNoControlTable, self.SelectedPlayer:UserID())
			table.insert(GlobalNoControlTable, self.Owner:UserID())
		end
	end
	if self.IAmControlling then return false end
	if !self.IAmControlling then
		self.IAmControlling = true
		if CLIENT then
			if FalcoThirdPersonVariable:GetInt() < 15 then
				self.SelectedPlayer:SetColor(255, 255, 255, 0)
			else
				self.SelectedPlayer:SetColor(255, 255, 255, 125)
			end
			
			--camera
			function FCameraThing(ply, origin, angles, fov)
				if self.IAmControlling and self.SelectedPlayer:IsValid() then
					local view = {} 
					local shootpos = self.SelectedPlayer:GetShootPos()
					local selfaimvectorforward = LocalPlayer():GetAimVector():Angle():Forward()
					view.origin = shootpos - selfaimvectorforward  * FalcoThirdPersonVariable:GetInt()
					view.angles = LocalPlayer():EyeAngles() 
					
					return view
				end
			end
			hook.Add("CalcView", "FCameraThing", FCameraThing) 
			
		elseif SERVER then
			self.SelectedPlayer:ConCommand("FOpenVeryAnnoyingScreen")
			self.SelectedPlayer:ConCommand("cancelselect")
			self.SelectedPlayer:ConCommand("-forward")
			self.SelectedPlayer:ConCommand("-back")
			self.SelectedPlayer:ConCommand("-use")
			self.SelectedPlayer:ConCommand("-jump")
			self.SelectedPlayer:ConCommand("-duck")
			self.SelectedPlayer:ConCommand("-moveleft")
			self.SelectedPlayer:ConCommand("-moveright")
			self.SelectedPlayer:ConCommand("-zoom")
			self.SelectedPlayer:ConCommand("-attack")
			self.SelectedPlayer:ConCommand("-attack2")
			self.SelectedPlayer:ConCommand("-speed")
			self.SelectedPlayer:ConCommand("-walk")
			self.SelectedPlayer:SendLua("GAMEMODE:AddNotify(\"You are being controlled by " .. self.Owner:Nick() .. "\", 1, 5);surface.PlaySound( \"ambient/water/drip2.wav\")")
			self.OwnerOldPos = self.Owner:GetPos()
			hook.Add("Think", "PlayerPossessorUpdatePlayerPos", function() self.Owner:SetPos(self.SelectedPlayer:GetPos() - self.SelectedPlayer:GetAimVector():Angle():Forward() * 20) end)
			
			for num, weapon in pairs(self.SelectedPlayer:GetWeapons()) do 
				if weapon:GetClass() == "weapon_possessor" then
					weapon:Remove()
					self.SelectedPlayer:SendLua("GAMEMODE:AddNotify(\"Your possessor swep got removed for paradox prevention \", 1, 7);surface.PlaySound( \"ambient/water/drip2.wav\")")
				end
			end
			self.Owner:ConCommand("-forward")
			self.Owner:ConCommand("-back")
			self.Owner:ConCommand("-use")
			self.Owner:ConCommand("-jump")
			self.Owner:ConCommand("-duck")
			self.Owner:ConCommand("-moveleft")
			self.Owner:ConCommand("-moveright")
			self.Owner:ConCommand("-zoom")
			self.Owner:ConCommand("-attack")
			self.Owner:ConCommand("-attack2")
			self.Owner:ConCommand("-speed")
			self.Owner:ConCommand("-walk")
			self.Owner:SendLua("GAMEMODE:AddNotify(\"Selected " .. self.SelectedPlayer:Nick() .. "\", 1, 5);surface.PlaySound( \"ambient/water/drip2.wav\")")
			self.Owner:SetMoveType(MOVETYPE_OBSERVER)
			self.Owner:SetColor(255, 255, 255, 0)
			self.Owner:GodEnable()
			self.Owner:SetCollisionGroup( 1 )
			self.Owner:DrawViewModel(false)
			self.Owner:DrawWorldModel(false)
		end
	end	
end

/*--------------------------------------------------------- 
	It does this every frame
---------------------------------------------------------*/ 
function SWEP:Think()	
	if self.IAmControlling and self.SelectedPlayer:IsValid() then	
		if CLIENT then
			if FalcoThirdPersonVariable:GetInt() <= 15 then
				self.SelectedPlayer:SetColor(255, 255, 255, 0)
			elseif FalcoThirdPersonVariable:GetInt() > 15  then
				self.SelectedPlayer:SetColor(255, 255, 255, 125)
			end
		elseif SERVER then
			self.SelectedPlayer:SetEyeAngles(self.Owner:EyeAngles( ))
			if self.SelectedPlayer:GetActiveWeapon():IsValid() then
				self.Owner:SendLua("LocalPlayer():GetActiveWeapon().HisTotalAmmo = " .. tostring(self.SelectedPlayer:GetAmmoCount(self.SelectedPlayer:GetActiveWeapon():GetPrimaryAmmoType( ))))
				self.Owner:SendLua("LocalPlayer():GetActiveWeapon().HisClip = " .. tostring(self.SelectedPlayer:GetActiveWeapon():Clip1()))
				self.HisTotalAmmo = self.SelectedPlayer:GetAmmoCount(self.SelectedPlayer:GetActiveWeapon():GetPrimaryAmmoType( ))
				self.HisClip = self.SelectedPlayer:GetActiveWeapon():Clip1()
				if self.SelectedPlayer:GetActiveWeapon():GetClass() == "gmod_tool" then
					self.Owner:SendLua("LocalPlayer():GetActiveWeapon().HisToolMode = \"" .. tostring(self.SelectedPlayer:GetActiveWeapon():GetMode()) .. "\"")
					self.HisToolMode = tostring(self.SelectedPlayer:GetActiveWeapon():GetMode())
				end
			end
		end
	elseif self.IAmControlling and (not self.SelectedPlayer:IsValid() or not self.Owner:Alive()) then
		self.IAmControlling = false
		if SERVER then
			for k, v in pairs(GlobalNoControlTable) do
				if v == self.Owner:UserID() then
					table.remove(GlobalNoControlTable, k)
				end
			end
			for k, v in pairs(GlobalNoControlTable) do	
				if v == self.SelectedPlayerUserID then
					table.remove(GlobalNoControlTable, k)
				end
			end
			umsg.Start("PlayerPossessorCloseTheCreationScreen", ply)
			umsg.End()
			self.Owner:ConCommand("-forward")
			self.Owner:ConCommand("-back")
			self.Owner:ConCommand("-use")
			self.Owner:ConCommand("-jump")
			self.Owner:ConCommand("-duck")
			self.Owner:ConCommand("-moveleft")
			self.Owner:ConCommand("-moveright")
			self.Owner:ConCommand("-zoom")
			self.Owner:ConCommand("-attack")
			self.Owner:ConCommand("-attack2")
			self.Owner:ConCommand("-speed")
			self.Owner:ConCommand("-walk")
			self.Owner:SendLua("GAMEMODE:AddNotify(\"He left\", 1, 5);surface.PlaySound( \"ambient/water/drip2.wav\")")
			self.Owner:SetMoveType(MOVETYPE_WALK)
			self.Owner:SetColor(255, 255, 255, 255)
			self.Owner:GodDisable()
			self.Owner:SetCollisionGroup( COLLISION_GROUP_PLAYER )
			self.Owner:DrawViewModel(true)
			self.Owner:DrawWorldModel(true)
		end
	end
end

/*--------------------------------------------------------- 
	When the swep gets deleted(when you die)
---------------------------------------------------------*/ 
function SWEP:OnRemove()
	if self.IAmControlling then
		self.IAmControlling = false
		if self.SelectedPlayer:IsValid() then
			if SERVER then
				for k, v in pairs(GlobalNoControlTable) do
					if v == self.Owner:UserID() then
						table.remove(GlobalNoControlTable, k)
					end
				end
				for k, v in pairs(GlobalNoControlTable) do	
					if v == self.SelectedPlayer:UserID() then
						table.remove(GlobalNoControlTable, k)
					end
				end
				self.SelectedPlayer:ConCommand("-forward")
				self.SelectedPlayer:ConCommand("-back")
				self.SelectedPlayer:ConCommand("-use")
				self.SelectedPlayer:ConCommand("-jump")
				self.SelectedPlayer:ConCommand("-duck")
				self.SelectedPlayer:ConCommand("-moveleft")
				self.SelectedPlayer:ConCommand("-moveright")
				self.SelectedPlayer:ConCommand("-zoom")
				self.SelectedPlayer:ConCommand("-attack")
				self.SelectedPlayer:ConCommand("-attack2")
				self.SelectedPlayer:ConCommand("-speed")
				self.SelectedPlayer:ConCommand("-walk")
				umsg.Start("PlayerPossessorCloseTheScreen", self.SelectedPlayer)
				umsg.End()
				self.SelectedPlayer:SendLua("GAMEMODE:AddNotify(\"" .. self.Owner:Nick() .. " has stopped controlling you\", 1, 5);surface.PlaySound( \"ambient/water/drip2.wav\")")
				self.Owner:SetMoveType(MOVETYPE_WALK)
				self.Owner:SetColor(255, 255, 255, 255)
				self.Owner:GodDisable()
				self.Owner:SetCollisionGroup( COLLISION_GROUP_PLAYER )
				self.Owner:DrawViewModel(true)
				self.Owner:DrawWorldModel(true)
			elseif CLIENT then
				self.SelectedPlayer:SetColor(255, 255, 255, 255)
			end
		end
	end
end

/*--------------------------------------------------------- 
	Keybinds
---------------------------------------------------------*/ 
if CLIENT then
	local function ButtonPresses( ply, bnd, pressed )
		if ply:GetActiveWeapon().IAmControlling then
			for Keys = 0, 16, 1 do
				if (bnd == "+gm_special " .. Keys or bnd == "-gm_special " .. Keys) and pressed then 
					ply:ConCommand("FDoHimAnotherCommand +gm_special " .. tostring(Keys))
					return true 
				elseif (bnd == "+gm_special " .. Keys or bnd == "-gm_special " .. Keys) and not pressed  then
					ply:ConCommand("FDoHimAnotherCommand -gm_special " .. tostring(Keys))
					return true 
				end
			end
			
			for i = 1, 6, 1 do 
				if string.find( bnd, "slot" .. i ) and pressed then
					ply:ConCommand("FDoHimAnotherCommand slot" .. i)
					return true
				end
			end
			if string.find( bnd, "noclip" ) and pressed then
				ply:ConCommand("FDoHimAnotherCommand noclip")
				return true 
			elseif string.find( bnd, "menu" ) and not string.find( bnd, "context" ) and pressed then
				ply:ConCommand("+fcontrolsmenu")
				return true 
			elseif string.find(bnd, "impulse 100") and pressed then
				ply:ConCommand("FDoHimAnotherCommand impulse 100")
				return true 
			elseif string.find(bnd, "impulse 201") and pressed then 
				ply:ConCommand("FDoHimAnotherCommand impulse 201")
				return true 
			elseif string.find(bnd, "invprev") and pressed then 
				ply:ConCommand("FDoHimAnotherCommand invprev")
				return true
			elseif string.find(bnd, "invnext") and pressed then
				ply:ConCommand("FDoHimAnotherCommand invnext")
				return true
			elseif string.find(bnd, "undo") and pressed then
				ply:ConCommand("FDoHimAnotherCommand gmod_undo")
				return true
			elseif string.find(bnd, "messagemode") and pressed then
				ply:ConCommand("FOpenOverrideChatThingey")
				return true
			end 
		end
	end
	hook.Add("PlayerBindPress", "ButtonPresses", ButtonPresses)
	
	local function CloseContextMenuSendData() 
		if LocalPlayer():GetActiveWeapon().IAmControlling then
			FDoSendVarsToServer()
		end
	end
	hook.Add("OnContextMenuClose", "CloseContextMenuSendData", CloseContextMenuSendData)
end

/*--------------------------------------------------------- 
	KeyPressed hook
---------------------------------------------------------*/ 
function FKeyPressed (ply, key) 
	if ply == ply:GetActiveWeapon().Owner and ply:GetActiveWeapon().IAmControlling and SERVER then	
		if( ply:GetActiveWeapon().Owner:KeyPressed( IN_FORWARD ) ) then
			ply:GetActiveWeapon().SelectedPlayer:ConCommand("+forward")
		elseif( ply:GetActiveWeapon().Owner:KeyPressed( IN_BACK ) ) then
			ply:GetActiveWeapon().SelectedPlayer:ConCommand("+back")
		elseif( ply:GetActiveWeapon().Owner:KeyPressed( IN_MOVELEFT ) ) then
			ply:GetActiveWeapon().SelectedPlayer:ConCommand("+moveleft")
		elseif( ply:GetActiveWeapon().Owner:KeyPressed( IN_MOVERIGHT ) ) then
			ply:GetActiveWeapon().SelectedPlayer:ConCommand("+moveright")
		elseif( ply:GetActiveWeapon().Owner:KeyPressed( IN_ATTACK ) ) then
			ply:GetActiveWeapon().SelectedPlayer:ConCommand("+attack")
		elseif( ply:GetActiveWeapon().Owner:KeyPressed( IN_ATTACK2 ) ) then
			ply:GetActiveWeapon().SelectedPlayer:ConCommand("+attack2")
		elseif( ply:GetActiveWeapon().Owner:KeyPressed( IN_DUCK ) ) then
			ply:GetActiveWeapon().SelectedPlayer:ConCommand("+duck")
		elseif( ply:GetActiveWeapon().Owner:KeyPressed( IN_JUMP ) ) then
			ply:GetActiveWeapon().SelectedPlayer:ConCommand("+jump")
		elseif( ply:GetActiveWeapon().Owner:KeyPressed( IN_SPEED ) ) then
			ply:GetActiveWeapon().SelectedPlayer:ConCommand("+speed")
		elseif( ply:GetActiveWeapon().Owner:KeyPressed( IN_WALK ) ) then
			ply:GetActiveWeapon().SelectedPlayer:ConCommand("+walk")
		elseif( ply:GetActiveWeapon().Owner:KeyPressed( IN_ZOOM ) ) then
			ply:GetActiveWeapon().SelectedPlayer:ConCommand("+zoom")
		elseif( ply:GetActiveWeapon().Owner:KeyPressed( IN_USE ) ) then
			ply:GetActiveWeapon().SelectedPlayer:ConCommand("+use")
		elseif( ply:GetActiveWeapon().Owner:KeyPressed( IN_SCORE ) ) then
			ply:GetActiveWeapon().SelectedPlayer:ConCommand("+showscores")
		elseif( ply:GetActiveWeapon().Owner:KeyPressed( IN_RELOAD ) ) then
			ply:GetActiveWeapon().SelectedPlayer:ConCommand("+reload")
		end
	end
end
hook.Add( "KeyPress", "FKeyPressedHook", FKeyPressed )  

/*--------------------------------------------------------- 
	KeyReleased hook
---------------------------------------------------------*/ 
function FKeyRelease(ply, key) 
	if ply == ply:GetActiveWeapon().Owner and ply:GetActiveWeapon().IAmControlling and SERVER then
		if( ply:KeyReleased( IN_FORWARD ) ) then
			ply:GetActiveWeapon().SelectedPlayer:ConCommand("-forward")
		elseif( ply:KeyReleased( IN_BACK ) ) then
			ply:GetActiveWeapon().SelectedPlayer:ConCommand("-back")
		elseif( ply:KeyReleased( IN_MOVELEFT ) ) then
			ply:GetActiveWeapon().SelectedPlayer:ConCommand("-moveleft")
		elseif( ply:KeyReleased( IN_MOVERIGHT ) ) then
			ply:GetActiveWeapon().SelectedPlayer:ConCommand("-moveright")
		elseif( ply:KeyReleased( IN_ATTACK ) ) then
			ply:GetActiveWeapon().SelectedPlayer:ConCommand("-attack")
		elseif( ply:KeyReleased( IN_ATTACK2 ) ) then
			ply:GetActiveWeapon().SelectedPlayer:ConCommand("-attack2")
		elseif( ply:KeyReleased( IN_DUCK ) ) then
			ply:GetActiveWeapon().SelectedPlayer:ConCommand("-duck")
		elseif( ply:KeyReleased( IN_JUMP ) ) then
			ply:GetActiveWeapon().SelectedPlayer:ConCommand("-jump")
		elseif( ply:KeyReleased( IN_SPEED ) ) then
			ply:GetActiveWeapon().SelectedPlayer:ConCommand("-speed")
		elseif( ply:KeyReleased( IN_WALK ) ) then
			ply:GetActiveWeapon().SelectedPlayer:ConCommand("-walk")
		elseif( ply:KeyReleased( IN_ZOOM ) ) then
			ply:GetActiveWeapon().SelectedPlayer:ConCommand("-zoom")
		elseif( ply:KeyReleased( IN_USE ) ) then
			ply:GetActiveWeapon().SelectedPlayer:ConCommand("-use")
		elseif( ply:KeyReleased( IN_SCORE ) ) then
			ply:GetActiveWeapon().SelectedPlayer:ConCommand("-showscores")
		elseif( ply:KeyReleased( IN_RELOAD ) ) then
			ply:GetActiveWeapon().SelectedPlayer:ConCommand("-reload")
		end
	end
end
hook.Add( "KeyRelease", "FKeyReleasedHook", FKeyRelease )

/*--------------------------------------------------------- 
	Draw stuff
---------------------------------------------------------*/ 
if CLIENT then surface.CreateFont( "coolvetica", 35, 300, true, false, "PlayerWeaponShow" ) end
function SWEP:DrawHUD()
	if self.IAmControlling and self.SelectedPlayer:IsValid() then
		if self.SelectedPlayer:Health() >=0 then
			draw.WordBox(20, 20, ScrH()- 80 , self.SelectedPlayer:Health(), "PlayerWeaponShow", Color(0,0,0,100), Color(255, 0, 0, 255))
		elseif self.SelectedPlayer:Health()<0 then
			draw.WordBox(20, 20, ScrH()- 80 , "0", "PlayerWeaponShow", Color(0,0,0,100), Color(255, 0, 0, 255))
		end
		if self.SelectedPlayer:GetActiveWeapon():IsValid() then
			if self.SelectedPlayer:GetActiveWeapon():GetPrimaryAmmoType( ) >=  0 and self.SelectedPlayer:GetActiveWeapon():GetClass() != "gmod_tool"  then//if he's not holding a gun that doesn't have ammo then
				draw.WordBox(20, ScrW() - 120, ScrH()- 80 , self.HisClip .. "  " .. self.HisTotalAmmo , "PlayerWeaponShow", Color(0,0,0,100), Color(255, 0, 0, 255))
			elseif self.SelectedPlayer:GetActiveWeapon():GetClass() == "gmod_tool" then
				draw.SimpleText(self.HisToolMode .. " tool", "PlayerWeaponShow", ScrW() * 0.5, ScrH() * 0.97, Color(255, 0, 0, 255), 1, 1)
			end
			if self.SelectedPlayer:GetActiveWeapon():GetClass() != "gmod_tool" then
				draw.SimpleText("Current weapon: " .. self.SelectedPlayer:GetActiveWeapon():GetPrintName(), "PlayerWeaponShow", ScrW() * 0.5, ScrH() * 0.97, Color(255, 0, 0, 255), 1, 1)
			end				
		end
	end
	
	local x = ScrW() / 2.0
	local y = ScrH() / 2.0
	local scale = 0.1
	
	surface.SetDrawColor( 255, 255, 255, 255 )
	local length = 60 * scale
	surface.DrawLine( x - length, y, x, y)
	surface.DrawLine( x + length, y, x, y)
	surface.DrawLine( x, y - length, x, y )
	surface.DrawLine( x, y + length, x, y )
end

/*--------------------------------------------------------- 
	Remove stuff like your own health, armor and ammo display
---------------------------------------------------------*/ 
function SWEP:HUDShouldDraw( element )
	if element == "CHudAmmo" or (self.IAmControlling and element == "CHudHealth") or (self.IAmControlling and element == "CHudBattery") then
		return false
	else
		return true
	end
end 
