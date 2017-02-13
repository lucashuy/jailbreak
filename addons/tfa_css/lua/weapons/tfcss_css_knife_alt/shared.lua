-- Variables that are used on both client and server
SWEP.Gun = ("tfcss_css_knife_alt") -- must be the name of your swep but NO CAPITALS!
if (GetConVar(SWEP.Gun.."_allowed")) != nil then
	if not (GetConVar(SWEP.Gun.."_allowed"):GetBool()) then SWEP.Base = "tfa_blacklisted" SWEP.PrintName = SWEP.Gun return end
end
SWEP.Category				= "TFA CS:S Alternates"
SWEP.Author				= ""
SWEP.Contact				= ""
SWEP.Purpose				= ""
SWEP.Instructions				= ""
SWEP.PrintName				= "Alt Knife"		-- Weapon name (Shown on HUD)	
SWEP.Slot				= 2				-- Slot in the weapon selection menu
SWEP.SlotPos				= 28			-- Position in the slot
SWEP.DrawAmmo				= true		-- Should draw the default HL2 ammo counter
SWEP.DrawWeaponInfoBox			= false		-- Should draw the weapon info box
SWEP.BounceWeaponIcon   		= 	false	-- Should the weapon icon bounce?
SWEP.DrawCrosshair			= false		-- set false if you want no crosshair
SWEP.Weight				= 30			-- rank relative ot other weapons. bigger is better
SWEP.AutoSwitchTo			= true		-- Auto switch to if we pick it up
SWEP.AutoSwitchFrom			= true		-- Auto switch from if you pick up a better weapon
SWEP.HoldType 				= "knife"		-- how others view you carrying the weapon
-- normal melee melee2 fist knife smg ar2 pistol rpg physgun grenade shotgun crossbow slam passive 
-- you're mostly going to use ar2, smg, shotgun or pistol. rpg and crossbow make for good sniper rifles

SWEP.ViewModelFOV			= 70
SWEP.ViewModelFlip			= false
SWEP.ViewModel				= "models/weapons/2_knife_t.mdl"	-- Weapon view model
SWEP.WorldModel				= "models/weapons/3_knife_t.mdl"	-- Weapon world model
SWEP.ShowWorldModel			= true
SWEP.Base				= "tfa_gun_base"
SWEP.Spawnable				= true
SWEP.AdminSpawnable			= true
SWEP.FiresUnderwater = false

SWEP.Primary.RPM			= 250			-- This is in Rounds Per Minute
SWEP.Primary.ClipSize			= 30		-- Size of a clip
SWEP.Primary.DefaultClip		= 60		-- Bullets you start with
SWEP.Primary.KickUp				= 0.4		-- Maximum up recoil (rise)
SWEP.Primary.KickDown			= 0.3		-- Maximum down recoil (skeet)
SWEP.Primary.KickHorizontal		= 0.3		-- Maximum up recoil (stock)
SWEP.Primary.Automatic			= false		-- Automatic = true; Semi Auto = false
SWEP.Primary.Ammo			= ""			-- pistol, 357, smg1, ar2, buckshot, slam, SniperPenetratedRound, AirboatGun
-- Pistol, buckshot, and slam always ricochet. Use AirboatGun for a light metal peircing shotgun pellets

SWEP.Secondary.IronFOV			= 55		-- How much you 'zoom' in. Less is more! 	

SWEP.data 				= {}				--The starting firemode
SWEP.data.ironsights			= 0

SWEP.Primary.Damage		= 30	-- Base damage per bullet
SWEP.Primary.Spread		= .02	-- Define from-the-hip accuracy 1 is terrible, .0001 is exact)
SWEP.Primary.IronAccuracy = .01 -- Ironsight accuracy, should be the same for shotguns

//Enter iron sight info and bone mod info below
-- SWEP.IronSightsPos = Vector(-2.652, 0.187, -0.003)
-- SWEP.IronSightsAng = Vector(2.565, 0.034, 0) 		//not for the knife
-- SWEP.SightsPos = Vector(-2.652, 0.187, -0.003)		//just lower it when running
-- SWEP.SightsAng = Vector(2.565, 0.034, 0)
SWEP.RunSightsPos = Vector(0, 0, 0)
SWEP.RunSightsAng = Vector(-25.577, 0, 0)

SWEP.Slash = 1

SWEP.Primary.Sound	= Sound("weapons/blades/woosh.mp3") //woosh
SWEP.KnifeShink = Sound("weapons/blades/hitwall.mp3")
SWEP.KnifeSlash = Sound("weapons/blades/slash.mp3")
SWEP.KnifeStab = Sound("weapons/blades/nastystab.mp3")

SWEP.DisableIdleAnimations = false

function SWEP:PrimaryAttack()
	vm = self.Owner:GetViewModel()
	if SERVER and self:CanPrimaryAttack() and self.Owner:IsPlayer() then
	self.Weapon:SendWeaponAnim( ACT_VM_IDLE )
		if !self.Owner:KeyDown(IN_SPEED) and !self.Owner:KeyDown(IN_RELOAD) then
			if self.Slash == 1 then
				vm:SetSequence(vm:LookupSequence("midslash1"))
				self.Slash = 2
			else
				vm:SetSequence(vm:LookupSequence("midslash2"))
				self.Slash = 1
			end --if it looks stupid but works, it aint stupid!
			self.Weapon:EmitSound(self.Primary.Sound)//slash in the wind sound here
			timer.Create("cssslash", .15, 1, function() if not IsValid(self) then return end
				if IsValid(self.Owner) and IsValid(self.Weapon) then 
					self:PrimarySlash() 
				end
			end)

			self.Owner:SetAnimation( PLAYER_ATTACK1 )
			self.Weapon:SetNextPrimaryFire(CurTime()+1/(self.Primary.RPM/60))
			self:SetShooting(true)
			self:SetShootingEnd(CurTime()+1/(self.Primary.RPM/60)*3)
		end
	end
end

function SWEP:PrimarySlash()

	pos = self.Owner:GetShootPos()
	ang = self.Owner:GetAimVector()
	damagedice = math.Rand(.85,1.25)
	pain = self.Primary.Damage * damagedice
	self.Owner:LagCompensation(true)
	if IsValid(self.Owner) and IsValid(self.Weapon) then
		if self.Owner:Alive() and self.Owner:GetActiveWeapon():GetClass() == self.Gun then
			local slash = {}
			slash.start = pos
			slash.endpos = pos + (ang * 32)
			slash.filter = self.Owner
			slash.mins = Vector(-10, -5, 0)
			slash.maxs = Vector(10, 5, 5)
			local slashtrace = util.TraceHull(slash)
			if slashtrace.Hit then
				if slashtrace.Entity == nil then return end
					self.Owner:FireBullets({
						Attacker = self.Owner,
						Inflictor = self,
						Damage = pain,
						Force = pain*0.1,
						Distance = 32,
						HullSize = 10,
						Tracer = 0,
						Src = self.Owner:GetShootPos(),
						Dir = slashtrace.Normal
					})
				targ = slashtrace.Entity
				if !(slashtrace.MatType != MAT_FLESH and slashtrace.MatType != MAT_ALIENFLESH ) then
					//find a way to splash a little blood
					self.Weapon:EmitSound(self.KnifeSlash)//stab noise
				else
					self.Weapon:EmitSound(self.KnifeShink)//SHINK!
				end
			end
		end
	end
	self.Owner:LagCompensation(false)
end


function SWEP:SecondaryAttack()
	pos = self.Owner:GetShootPos()
	ang = self.Owner:GetAimVector()
	vm = self.Owner:GetViewModel()
	if self:CanPrimaryAttack() and self.Owner:IsPlayer() then
	self.Weapon:SendWeaponAnim( ACT_VM_IDLE )
		if !self.Owner:KeyDown(IN_SPEED) and !self.Owner:KeyDown(IN_RELOAD) then
			self.Weapon:EmitSound(self.Primary.Sound)//stab noise
			local stab = {}
			stab.start = pos
			stab.endpos = pos + (ang * 24)
			stab.filter = self.Owner
			stab.mins = Vector(-10,-5, 0)
			stab.maxs = Vector(10, 5, 5)
			local stabtrace = util.TraceHull(stab)
			if stabtrace.Hit then
				vm:SetSequence(vm:LookupSequence("stab"))
			else
				vm:SetSequence(vm:LookupSequence("stab_miss"))
			end
			
			
			
			timer.Create("cssstab"..self:EntIndex(), .33, 1 , function() if not IsValid(self) then return end
			if self.Owner and self.Weapon then 
				if IsValid(self.Owner) and IsValid(self.Weapon) then 
					if self.Owner:Alive() and self.Owner:GetActiveWeapon():GetClass() == self.Gun then 
						self:Stab() 
					end
				end
			end	
			end)

			self.Owner:SetAnimation( PLAYER_ATTACK1 )
			self.Weapon:SetNextPrimaryFire(CurTime()+1/(self.Primary.RPM/60))
			self.Weapon:SetNextSecondaryFire(CurTime()+1.25)
			self:SetShooting(true)
			self:SetShootingEnd(CurTime()+1.24)
		end
	end
end

function SWEP:Stab()

	pos2 = self.Owner:GetShootPos()
	ang2 = self.Owner:GetAimVector()
	damagedice = math.Rand(.85,1.25)
	pain = 100 * damagedice
	self.Owner:LagCompensation(true)
	local stab2 = {}
	stab2.start = pos2
	stab2.endpos = pos2 + (ang2 * 24)
	stab2.filter = self.Owner
	stab2.mins = Vector(-10,-5, 0)
	stab2.maxs = Vector(10, 5, 5)
	local stabtrace2 =  util.TraceHull(stab2)

	if IsValid(self.Owner) and IsValid(self.Weapon) then
		if self.Owner:Alive() then if self.Owner:GetActiveWeapon():GetClass() == self.Gun then
			if stabtrace2.Hit then
				if stabtrace2.Entity == nil then return end
					self.Owner:FireBullets({
						Attacker = self.Owner,
						Inflictor = self,
						Damage = pain,
						Force = pain*0.1,
						Distance = 24,
						HullSize = 10,
						Tracer = 0,
						Src = self.Owner:GetShootPos(),
						Dir = stabtrace2.Normal
					})
				targ = stabtrace2.Entity
				if !(stabtrace2.MatType != MAT_FLESH and stabtrace2.MatType != MAT_ALIENFLESH ) then
					//find a way to splash a little blood
					self.Weapon:EmitSound(self.KnifeSlash)//stab noise
				else
					self.Weapon:EmitSound(self.KnifeShink)//SHINK!
				end
			end
		end
	end end
	self.Owner:LagCompensation(false)
end

function SWEP:ThrowKnife()
	if !IsFirstTimePredicted() and CLIENT then return end
	
		self.Weapon:EmitSound(self.Primary.Sound)
		if (SERVER) then
			local knife = ents.Create("tfa_css_thrown_knife")
			if IsValid(knife) then
				knife:SetAngles(self.Owner:EyeAngles())
				knife:SetPos(self.Owner:GetShootPos())
				knife:SetOwner(self.Owner)
				knife:SetPhysicsAttacker(self.Owner)
				knife:Spawn()
				knife:Activate()
				knife:SetNWString("WeaponToGive", self.Gun)
				self.Owner:SetAnimation(PLAYER_ATTACK1)
				local phys = knife:GetPhysicsObject()
				phys:SetVelocity(self.Owner:GetAimVector() * 1500)
				phys:AddAngleVelocity(Vector(0, 500, 0))
				self.Owner:StripWeapon(self.Gun)
				
			end
		end
end

function SWEP:Reload()
	self:ThrowKnife()
end

if GetConVar("tfaUniqueSlots") != nil then
	if not (GetConVar("tfaUniqueSlots"):GetBool()) then 
		SWEP.SlotPos = 2
	end
end

function SWEP:DoImpactEffect( tr, damageType)
	if tr.MatType != MAT_FLESH and tr.MatType != MAT_ALIENFLESH then
		util.Decal("ManhackCut", tr.HitPos + tr.HitNormal, tr.HitPos - tr.HitNormal )
		return true
	end
end