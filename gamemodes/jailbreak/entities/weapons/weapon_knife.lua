--[[
	Created by Chessnut for the Chessnut's Corner community.
	http://chessnut.info
--]]

AddCSLuaFile();

SWEP.IconLetter	= "j";

if (CLIENT) then
	SWEP.Slot = 3;
	SWEP.SlotPos = 3;
	SWEP.DrawAmmo = false;
	SWEP.DrawCrosshair = true;
	SWEP.DrawWeaponInfoBox = true;

	surface.CreateFont("CSSelectIcons", {
		font = "csd",
		size = ScreenScale(60),
		weight = 500,
	} );
end;

SWEP.UseHands = true;

function SWEP:DrawWeaponSelection(x, y, wide, tall, alpha)
	draw.SimpleText(self.IconLetter, "CSSelectIcons", x + wide / 2, y + tall * 0.2, Color(255, 210, 0, alpha), TEXT_ALIGN_CENTER);
end;

SWEP.Author = "\67\104\101\115\115\110\117\116";
SWEP.Instructions = "Primary Fire: Strike.\n\nStriking from behind results in greater damage.";
SWEP.PrintName = "Knife";
SWEP.ViewModelFOV = 60;
SWEP.ViewModelFlip = false;
SWEP.Spawnable = false;
SWEP.AdminSpawnable = false;
SWEP.NextAttack = 0;
SWEP.ViewModel = Model("models/weapons/cstrike/c_knife_t.mdl");
SWEP.WorldModel = Model("models/weapons/w_knife_t.mdl");

SWEP.Primary.Delay = 0.35;
SWEP.Primary.Recoil = 0;
SWEP.Primary.Damage	= 40;
SWEP.Primary.NumShots = 1;
SWEP.Primary.Cone = 0;
SWEP.Primary.ClipSize = -1;
SWEP.Primary.DefaultClip = -1;
SWEP.Primary.NextAttack = 0;
SWEP.Primary.Automatic = false;
SWEP.Primary.Ammo = "none";

util.PrecacheSound("weapons/knife/knife_deploy1.wav");
util.PrecacheSound("weapons/knife/knife_hitwall1.wav");
util.PrecacheSound("weapons/knife/knife_hit1.wav");
util.PrecacheSound("weapons/knife/knife_hit2.wav");
util.PrecacheSound("weapons/knife/knife_hit3.wav");
util.PrecacheSound("weapons/knife/knife_hit4.wav");
util.PrecacheSound("weapons/iceaxe/iceaxe_swing1.wav");

function SWEP:Initialize()
	self:SetWeaponHoldType("knife");
	
	self.hitSound = Sound("weapons/knife/knife_hitwall1.wav");
	self.fleshSounds = {
		Sound("weapons/knife/knife_hit1.wav"),
		Sound("weapons/knife/knife_hit2.wav"),
		Sound("weapons/knife/knife_hit3.wav"),
		Sound("weapons/knife/knife_hit4.wav")
	};
end;

function SWEP:Deploy()
	self.Owner:EmitSound("weapons/knife/knife_deploy1.wav");

	return true;
end;

function SWEP:PrimaryAttack()
	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay);
	self:SetNextSecondaryFire(CurTime() + self.Primary.Delay);
	
	local trace = self.Owner:GetEyeTraceNoCursor();
	local damage = self.Primary.Damage;

	self:EmitSound("weapons/iceaxe/iceaxe_swing1.wav");
	self:SendWeaponAnim(ACT_VM_MISSCENTER);

	self.Owner:ViewPunch( Angle(1, 5, 1) );

	if (self.Owner:GetPos():Distance(trace.HitPos) <= 108) then
		local shoot = false;

		if (trace.Hit) then
			if (SERVER) then
				if ( IsValid(trace.Entity) ) then
					if ( trace.Entity:IsPlayer() ) then
						trace.Entity:EmitSound( table.Random(self.fleshSounds) );

						shoot = true;
					end;

					local class = string.lower( trace.Entity:GetClass() );

					if ( string.find(class, "breakable") ) then
						shoot = true;
					end;
				else
					self.Owner:EmitSound(self.hitSound);
				end;
			end;

			util.Decal("ManhackCut", trace.HitPos + trace.HitNormal, trace.HitPos - trace.HitNormal);
		end;

		if (SERVER) then
			if (shoot) then
				local bullet = {}
				bullet.Num = 1;
				bullet.Src = self.Owner:GetShootPos();
				bullet.Dir = self.Owner:GetAimVector();
				bullet.Spread = Vector(0, 0, 0);
				bullet.Tracer = 0;
				bullet.Force = 5;
				bullet.Damage = damage;

				self.Owner:FireBullets(bullet);
			elseif ( IsValid(trace.Entity) ) then
				if ( IsValid( trace.Entity:GetPhysicsObject() ) ) then
					trace.Entity:GetPhysicsObject():ApplyForceOffset(self.Owner:GetAimVector() * 500, trace.HitPos);
				end;
			end;
		end;
	else
		self:SendWeaponAnim(ACT_VM_MISSCENTER);
	end;

	self.Owner:SetAnimation(PLAYER_ATTACK1);
end;

function SWEP:SecondaryAttack()
	self:PrimaryAttack();
end;