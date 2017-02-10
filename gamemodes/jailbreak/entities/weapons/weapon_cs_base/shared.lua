
if (SERVER) then

	AddCSLuaFile( "shared.lua" )
	SWEP.Weight				= 5
	SWEP.AutoSwitchTo		= false
	SWEP.AutoSwitchFrom		= false

end

SWEP.UseHands = true;

if ( CLIENT ) then

	SWEP.DrawAmmo			= true
	SWEP.DrawCrosshair		= false
	SWEP.ViewModelFOV		= 45
	--SWEP.ViewModelFlip		= true
	SWEP.CSMuzzleFlashes	= true
	
	surface.CreateFont( "CSKillIcons", {
		size = ScreenScale( 30 ),
		weight = 500, 
		antialias = true, 
		additive = true, 
		font = "csd" 
	} );

	surface.CreateFont( "CSSelectIcons", {
		size = ScreenScale( 60 ),
		weight = 500,
		antialias = true,
		additive = true, 
		font = "csd"
	} );

end

SWEP.Author			= "Counter-Strike"
SWEP.Contact		= ""
SWEP.Purpose		= ""
SWEP.Instructions	= ""
SWEP.m_WeaponDeploySpeed = 1.7;

SWEP.Spawnable			= false
SWEP.AdminSpawnable		= false

SWEP.Primary.Sound			= Sound( "Weapon_AK47.Single" )
SWEP.Primary.Recoil			= 1.5
SWEP.Primary.Damage			= 40
SWEP.Primary.NumShots		= 1
SWEP.Primary.Cone			= 0.02
SWEP.Primary.Delay			= 0.15

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "none"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

function SWEP:Precache()
	util.PrecacheModel(self.ViewModel);
	util.PrecacheModel(self.WorldModel);
end;

function SWEP:SetupDataTables()
	self:NetworkVar("Bool", 0, "Ironsights");
	self:NetworkVar("Float", 0, "Miss");
end;

function SWEP:Initialize()

	if ( SERVER ) then
		self:SetNPCMinBurst( 30 )
		self:SetNPCMaxBurst( 30 )
		self:SetNPCFireRate( 0.01 )
	end
	
	self:SetWeaponHoldType( self.HoldType )
	self:SetIronsights(false);
	self:SetDeploySpeed(self.m_WeaponDeploySpeed);
end

function SWEP:Reload()
	if ( self.ReloadTime and self.ReloadTime > CurTime() ) then
		return;
	end;

	if (self:Clip1() < self.Primary.ClipSize and self.Owner:GetAmmoCount( self.Primary.Ammo ) > 0) then
		self.Weapon:DefaultReload( ACT_VM_RELOAD );
		self:SetIronsights( false )
		self:SetMiss( math.min( (self:GetMiss() or 0) / 4, 5 ) );

		if ( IsValid(self.Owner) ) then
			if (self.oldFOV) then
				self.Owner:SetFOV(self.oldFOV, 0.1);
			end;

		    local time = self.Owner:GetViewModel():SequenceDuration();
		    
		    self.ReloadTime = CurTime() + (time + 0.5);
		    self:SetNextPrimaryFire(CurTime() + time);
		    self:SetNextSecondaryFire(CurTime() + time);
		end;
	end;
end

function SWEP:Think()
	if (SERVER) then
		if ( (self.nextReduce or 0) < CurTime() ) then
			if ( (self:GetMiss() or 0) > 0 ) then
				self:SetMiss( math.max(self:GetMiss() - math.Rand(0.75, 1.0), 0) );
			end;

			self:NextThink( CurTime() + (self.Primary.Delay + 0.1) );

			return true;
		end;
	end;
end

function SWEP:PrimaryAttack()
	if ( self.ReloadTime and self.ReloadTime > CurTime() ) then
		return;
	end;

	self.Weapon:SetNextSecondaryFire( CurTime() + self.Primary.Delay )
	self.Weapon:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
	
	if ( !self:CanPrimaryAttack() ) then return end
		if (SERVER) then
			local value = (self:GetMiss() or 0) + math.Rand(0.25, 0.5);

			self:SetMiss(value);
			self.nextReduce = CurTime() + 0.1 + math.Rand(-0.05, 0.05);
		end;

		-- Play shoot sound
		self.Weapon:EmitSound( self.Primary.Sound )
		
		-- Shoot the bullet
		self:CSShootBullet( self.Primary.Damage, self.Primary.Recoil + self:GetMiss(), self.Primary.NumShots, self.Primary.Cone )
		
		-- Remove 1 bullet from our clip
		self:TakePrimaryAmmo( 1 )
end

function SWEP:CSShootBullet( dmg, recoil, numbul, cone )
	if ( !IsValid(self.Owner) ) then
		return;
	end;
	
	numbul 	= numbul 	or 1
	cone 	= cone 		or 0.01
	cone = cone + (self.Owner:GetVelocity():Length2D() * 0.00025) + recoil/75;

	if ( IsValid(self.Owner) and self.Owner:KeyDown(IN_DUCK) and self.Owner:IsOnGround() ) then
		cone = cone - 0.01;
	end;

	local bullet = {}
	bullet.Num 		= numbul
	bullet.Src 		= self.Owner:GetShootPos()			-- Source
	bullet.Dir 		= self.Owner:GetAimVector()			-- Dir of bullet
	bullet.Spread 	= Vector( cone, cone, 0 )			-- Aim Cone
	bullet.Tracer	= 1									-- Show a tracer on every x bullets 
	bullet.Force	= math.random(5, 7)									-- Amount of force to give to phys objects
	bullet.Damage	= dmg
	
	self.Owner:ViewPunch( Angle(math.Rand(0.8, 1.2) + cone, cone, 0) );
	self.Owner:FireBullets( bullet )
	self.Weapon:SendWeaponAnim( ACT_VM_PRIMARYATTACK ) 		-- View model animation
	self.Owner:MuzzleFlash()								-- Crappy muzzle light
	self.Owner:SetAnimation( PLAYER_ATTACK1 )				-- 3rd Person Animation
	
	if ( self.Owner:IsNPC() ) then return end
end

function SWEP:DrawWeaponSelection( x, y, wide, tall, alpha )
	draw.SimpleText( self.IconLetter, "CSSelectIcons", x + wide/2, y + tall*0.2 + ( math.sin(CurTime() * 0.125) * 4), Color( 255, 210, 0, 255 ), TEXT_ALIGN_CENTER );
end

local IRONSIGHT_TIME = 0.55

function SWEP:GetViewModelPosition( pos, ang )

	if ( !self.IronSightsPos ) then return pos, ang end

	local bIron = self:GetIronsights();
	
	if ( bIron != self.bLastIron ) then
	
		self.bLastIron = bIron 
		self.fIronTime = CurTime()
		
		if ( bIron ) then 
			self.SwayScale 	= 0.5
			self.BobScale 	= 0.1
		else 
			self.SwayScale 	= 1.65
			self.BobScale 	= 1.35
		end
	
	end
	
	local fIronTime = self.fIronTime or 0

	if ( !bIron && fIronTime < CurTime() - IRONSIGHT_TIME ) then 
		return pos, ang 
	end
	
	local Mul = 1.0
	
	if ( fIronTime > CurTime() - IRONSIGHT_TIME ) then
	
		Mul = math.Clamp( (CurTime() - fIronTime) / IRONSIGHT_TIME, 0, 1 )
		
		if (!bIron) then Mul = 1 - Mul end
	
	end

	local Offset	= self.IronSightsPos
	
	if ( self.IronSightsAng ) then
	
		ang = ang * 1
		ang:RotateAroundAxis( ang:Right(), 		self.IronSightsAng.x * Mul )
		ang:RotateAroundAxis( ang:Up(), 		self.IronSightsAng.y * Mul )
		ang:RotateAroundAxis( ang:Forward(), 	self.IronSightsAng.z * Mul )
	
	
	end
	
	local Right 	= ang:Right()
	local Up 		= ang:Up()
	local Forward 	= ang:Forward()
	
	

	pos = pos + Offset.x/2 * Right * Mul
	pos = pos + Offset.y/2 * Forward * Mul
	pos = pos + Offset.z/2 * Up * Mul;

	return pos, ang
	
end

function SWEP:Deploy()
	return true;
end;

function SWEP:SecondaryAttack()
	if ( self.ReloadTime and self.ReloadTime > CurTime() ) then
		return;
	end;

	if ( !self.IronSightsPos ) then return end
	
	self.Owner:LagCompensation(true);
		local bIronsights = !self:GetIronsights();
		
		self:SetIronsights(bIronsights);

		if (bIronsights) then
			self.oldFOV = self.oldFOV or self.Owner:GetFOV();
			self.Owner:SetFOV(self.oldFOV - 20, 0.2);
		else
			self.Owner:SetFOV(self.oldFOV, 0.2);
		end;

		self:SetNextSecondaryFire( CurTime() + (IRONSIGHT_TIME + 0.1) );
	self.Owner:LagCompensation(false);
end;