jb = jb or {}
jb.config = jb.config or {}

function GM:InitPostEntity()
	self.BaseClass:InitPostEntity()

	for k, v in pairs(ents.FindByClass("weapon_*")) do
		v:SetMoveType(MOVETYPE_NONE)
	end

	game.ConsoleCommand("sv_gravity 505\n")
end

function GM:PlayerInitialSpawn(client)
	timer.Simple(0.5, function()
		if ( !IsValid(client) ) then
			return
		end
		
		if ((self:PlayerCanBeGuard() and table.Count(JB_SWAP_GUARD) == 0) or (team.NumPlayers(TEAM_PRISONER) > 0 and team.NumPlayers(TEAM_GUARD) < 1)) then
			client:SetTeam(TEAM_GUARD)
		else
			client:SetTeam(TEAM_PRISONER)
		end

		local guardModel = table.Random(self.GuardModels)
		local prisonerModel = table.Random(self.PrisonerModels)

		if (client:Team() == TEAM_GUARD) then
			client:SetModel(guardModel)
		else
			client:SetModel(prisonerModel)
		end

		if ( self:ShouldPlayerSpectate(client) ) then
			self:SpawnAsSpectator(client)
		else
			self:PlayerLoadout(client)
		end

		self:HandleInitialRound()
	end)

	timer.Simple(5 + (client:Ping() / 250), function()
		if ( IsValid(client) ) then
			self:SendGlobalVars(client)
		end
	end)
end

function GM:PlayerHurt(victim, attacker, remaining, damage)
	if (attacker:IsPlayer() && victim:IsPlayer()) then
		self:AdminNotify("[" .. team.GetName(victim:Team()) .. "]" .. victim:Name() .. " was attacked for " .. tostring(math.floor(damage)) .. " by [" ..  team.GetName(attacker:Team()) .. "]" .. attacker:Name())
	end
end

function GM:AdminNotify(message)
	for k, v in pairs( player.GetAll() ) do
		//if ( v:IsAdmin() or ( v.CheckGroup and v:CheckGroup("moderator") ) ) then
			net.Start("jb_Admin")
				net.WriteString(message)
			net.Send(v)
		//end
	end
end

function GM:SpawnAsSpectator(client)
	client:Spectate(OBS_MODE_ROAMING)

	if (client:Team() == TEAM_GUARD) then
		client:SetTeam(TEAM_GUARD_DEAD)
	elseif (client:Team() == TEAM_PRISONER) then
		client:SetTeam(TEAM_PRISONER_DEAD)
	end
end

function GM:PlayerSpawn(client)
	self:PlayerLoadout(client)
end

function GM:PlayerSpray(client)
	if (client:Team() == TEAM_PRISONER_DEAD or client:Team() == TEAM_GUARD_DEAD) then
		return true
	end

	return false
end

local primary = {
	"weapon_ak47",
	"weapon_m4",
	"weapon_mp5",
	"weapon_m249",
	"weapon_m3",
	"weapon_xm1014",
	"weapon_mac10"
}

local secondary = {
	"weapon_deagle",
	"weapon_fiveseven",
	"weapon_glock",
	"weapon_usp"
}

function GM:PlayerLoadout(ply)
	ply:StripWeapons()
	ply:StripAmmo()
	ply:UnSpectate()
	ply:SetDSP(1)
	ply.madeTeams = nil

	if (ply:Team() == TEAM_GUARD_DEAD || ply:Team() == TEAM_GUARD) then
		ply:SetTeam(TEAM_GUARD)
		ply:SetModel(table.Random(self.GuardModels))
	elseif (ply:Team() == TEAM_PRISONER_DEAD || ply:Team() == TEAM_PRISONER) then
		ply:SetTeam(TEAM_PRISONER)
		ply:SetModel(table.Random(self.PrisonerModels))
	end

	if ( self:ShouldPlayerSpectate(ply) ) then
		self:SpawnAsSpectator(ply)

		return
	else		
		ply:Give("jb_fists")
	end
	
	ply:SetWalkSpeed(200)
	ply:SetRunSpeed(200)
	ply:SetAvoidPlayers(false)
	ply:SetNoCollideWithTeammates(true)

	local spawn = self:PlayerSelectTeamSpawn(ply:Team(), ply)

	if ( IsValid(spawn) ) then
		ply:SetPos( spawn:GetPos() + Vector(0, 0, 16) )
	end

	if (ply:Team() == TEAM_PRISONER) then
		ply:SetPlayerColor( Vector(1, 0.6, 0.05) )
	else
		ply:SetPlayerColor( Vector(0, 0.5, 2) )
	end

	player_manager.SetPlayerClass(ply, "player_jb")
	player_manager.RunClass(ply, "Spawn")
end

function GM:SelectSpawn(client, tries)
	tries = (tries or 11) - 1

	if (tries <= 0) then
		return true
	end

	local info = client:Team()
	local spawns = team.GetSpawnPoints(info)

	if (spawns) then
		local spawn = table.Random(spawns)
		local position = spawn:GetPos()

		client:SetPos(position)
		client:DropToFloor()
		client:SetPos( client:GetPos() + Vector(0, 0, 16) )

		if ( client:GetPos():Distance(position) <= 8 and client:IsInWorld() ) then
			return true
		end
	end

	self:SelectSpawn(client, tries)
end

function GM:CreateGun(class, position, angle)
	local weapon = ents.Create(class)

	if (weapon) then
		weapon:SetPos(position)
		weapon:SetAngles(angle)
		weapon:Spawn()
		weapon:Activate()
		weapon:SetMoveType(MOVETYPE_VPHYSICS)
		weapon:SetCollisionGroup(COLLISION_GROUP_WEAPON)
		
		return weapon
	end
end

local PREVENT_DROP = {}
PREVENT_DROP[1] = "jb_fists"

function GM:DoPlayerDeath(victim, attacker, damageInfo)
	if (attacker:IsPlayer() && victim:IsPlayer()) then
		self:AdminNotify("[" .. team.GetName(victim:Team()) .. "]" .. victim:Name() .. " was killed by [" ..  team.GetName(attacker:Team()) .. "]" .. attacker:Name())
	end
	
	victim:AddDeaths(1)

	if ( IsValid(attacker) and attacker:IsPlayer() ) then
		if (attacker == victim) then
			attacker:AddFrags(-1)
		else
			attacker:AddFrags(1)
		end
	end

	local weapon = victim:GetActiveWeapon()
	if (IsValid(weapon) and !table.HasValue(PREVENT_DROP, weapon:GetClass())) then
		self:CreateGun(weapon:GetClass(), victim:GetShootPos(), victim:GetAngles())
	end

	if (victim:Team() == TEAM_PRISONER or victim:Team() == TEAM_PRISONER_DEAD) then
		victim:SetPlayerColor( Vector(1, 0.6, 0.05) )
	else
		victim:SetPlayerColor( Vector(0, 0.5, 2) )
	end
end

function GM:PlayerTick(client)
	local walkSpeed = client:GetWalkSpeed()

	client.approachSpeed = client.approachSpeed or walkSpeed

	local velocity = client:GetVelocity()
	local length = velocity:Length2D()
	local target = walkSpeed - 30

	if ( length > 1 and client:KeyDown(IN_SPEED) ) then
		target = walkSpeed + (client.addition or 70)
	end

	client.approachSpeed = math.Approach(client.approachSpeed, target, 3)
	client:SetRunSpeed(client.approachSpeed)
end

function GM:PlayerSwitchFlashlight(client, switchOn)
	if (client:Team() != TEAM_GUARD and client:Team() != TEAM_PRISONER) then
		return false
	end
	
	if ( (client.nextFlash or 0) < CurTime() ) then
		client.nextFlash = CurTime() + 1

		return true
	end

	return false
end

local DEATH_SOUNDS = {}
DEATH_SOUNDS[TEAM_PRISONER] = {
	Sound("vo/npc/male01/pain01.wav"),
	Sound("vo/npc/male01/pain02.wav"),
	Sound("vo/npc/male01/pain03.wav"),
	Sound("vo/npc/male01/pain04.wav"),
	Sound("vo/npc/male01/pain05.wav"),
	Sound("vo/npc/male01/pain06.wav"),
	Sound("vo/npc/male01/pain07.wav"),
	Sound("vo/npc/male01/pain08.wav"),
	Sound("vo/npc/male01/pain09.wav")
}
DEATH_SOUNDS[TEAM_GUARD] = {
	Sound("npc/metropolice/die1.wav"),
	Sound("npc/metropolice/die2.wav"),
	Sound("npc/metropolice/die3.wav"),
	Sound("npc/metropolice/die4.wav")
}

function GM:PlayerDeathSound()
	return true
end

local DEATH_PHRASES = {
	"was pwned by",
	"was terminated by",
	"was ended by",
	"was destroyed by",
	"was killed by",
	"was annihilated by",
	"was erased by",
	"was assasinated by",
	"was eradicated by",
	"was executed by",
	"was finished by",
	"was murdered by",
	"was neutralized by",
	"was obliterated by",
	"was smothered by",
	"was slaughtered by",
	"was wiped out by",
	"was pronounced dead by",
	"was eliminated by",
	"was demolished by"
}

function GM:EntityTakeDamage(victim, dmg)
	if(IsValid(victim) && IsValid(dmg:GetAttacker())) then
		if(victim == ents.GetMapCreatedEntity(jb.config["opencellsButton"]) && ents.GetMapCreatedEntity(jb.config["opencellsButton"]):GetSaveTable()["m_vecFinalDest"] == Vector(0,0,0)) then //lol, googled for a solution to this and found jake's solution
			self:Notify(dmg:GetAttacker():Name() .. " has shot open the cells!")
		end
	end
end

function GM:PlayerDeath(victim, weapon, killer)
	--self.BaseClass:PlayerDeath(victim, weapon, killer)
	
	if ( DEATH_SOUNDS[ victim:Team()] ) then
		victim:EmitSound( table.Random( DEATH_SOUNDS[ victim:Team() ] ), 130 )
	end

	if (victim:Team() == TEAM_GUARD) then
		victim:SetTeam(TEAM_GUARD_DEAD)
	elseif (victim:Team() == TEAM_PRISONER) then
		victim:SetTeam(TEAM_PRISONER_DEAD)
	end

	if (team.NumPlayers(TEAM_PRISONER) == 1 and team.NumPlayers(TEAM_GUARD) > 0) then
		local client = team.GetPlayers(TEAM_PRISONER)[1]

		if (!client.jb_LastRequest) then
			if ( IsValid(client) ) then
				self:Notify(client:Name().." has the last request.")
			end

			client.jb_LastRequest = true
		end
	end

	local entity = ents.Create("prop_ragdoll")
	entity:SetModel( victim:GetModel() )
	entity:SetPos( victim:GetPos() )
	entity:SetAngles( victim:GetAngles() )
	entity:Spawn()
	entity:Activate()
	entity:SetCollisionGroup(COLLISION_GROUP_WEAPON)

	victim:Spectate(OBS_MODE_DEATHCAM)
	victim.deathTime = CurTime() + 5

	if (IsValid(killer) and killer != victim) then
		victim:SpectateEntity(killer)
	else
		victim:SpectateEntity(entity)
	end

	local physicsObject = entity:GetPhysicsObject()

	if ( IsValid(physicsObject) ) then
		physicsObject:SetMass(15)
		physicsObject:ApplyForceCenter(victim:GetVelocity() * 16)
	end

	if (team.NumPlayers(TEAM_PRISONER) == 0 or team.NumPlayers(TEAM_GUARD) == 0) then
		--[[
		local entity = victim:GetRagdollEntity()

		if ( !IsValid(entity) and IsValid(victim) ) then
			entity = victim
		end
		--]]

		if ( IsValid(physicsObject) and IsValid(killer) and killer:IsPlayer() ) then
			physicsObject:ApplyForceCenter( killer:GetAimVector()*8600 + Vector(0, 0, 9600) )
		end

		for k, v in pairs( player.GetAll() ) do
			if (v != killer) then
				v:StripWeapons()
				v:Spectate(OBS_MODE_CHASE)
				v:SpectateEntity(entity)
				v:SetDSP(7)
			end
		end

		timer.Simple(0.25, function()
			self:SetGlobalVar("slow", CurTime() + 3.8)
			self:SetGlobalVar("killer", killer)
			self:SetGlobalVar("victim", victim)
			self:SetGlobalVar( "kill_phrase", table.Random(DEATH_PHRASES) )

			BroadcastLua("surface.PlaySound(\"music/stingers/HL1_stinger_song28.mp3\")")
		end)
	elseif ( IsValid(entity) ) then
		victim.jb_DeathPos = entity:GetPos() + Vector(0, 0, 24)
		entity:SetRenderMode(4)

		timer.Simple(8, function()
			if ( !IsValid(entity) ) then
				return
			end

			local timerID = "Body Fade:"..entity:EntIndex()

			timer.Create(timerID, 0.005, 255, function()
				if ( IsValid(entity) ) then
					entity.jb_Alpha = (entity.jb_Alpha or 255) - 1
					entity:SetColor( Color(255, 255, 255, entity.jb_Alpha) )

					if (entity.jb_Alpha <= 0) then
						entity:Remove()
					end
				else
					timer.Destroy(timerID)
				end
			end)
		end)
	end
end

function GM:PlayerDeathThink(client)
	if ( (client.spawnTime or 0) < CurTime() and JB_ROUND_STATE != ROUND_END ) then
		client:Spawn()

		if (client.jb_DeathPos) then
			client:SetPos(client.jb_DeathPos)
			client.jb_DeathPos = nil
		end
	end

	return false
end

function GM:Tick()
	local slowEnd = self:GetGlobalVar("slow", 0)
	local slowStart = slowEnd - 3.8

	if ( slowStart <= CurTime() and slowEnd > CurTime() ) then
		local slow = math.TimeFraction( slowStart, slowEnd, CurTime() )

		if (slow == 1) then
			self:SetGlobalVar("slow", nil)

			for k, v in pairs( player.GetAll() ) do
				v:SetDSP(1)
				v:UnSpectate()
			end
		end

		game.SetTimeScale( math.Clamp(slow, 0.13, 1) )
	end
end

function GM:CanPlayerSuicide(client)
	return true
end

function GM:PlayerShouldTakeDamage(victim, attacker)
	if (JB_ROUND_STATE != ROUND_ACTIVE) then
		return false
	end
	
	if ( victim:IsPlayer() and attacker:IsPlayer() and victim:Team() == attacker:Team() ) then
		return false
	end

	return true
end

function GM:GetFallDamage(client, fallSpeed)
	//return 1
	//return math.max( 0, math.ceil( 0.2418*fallSpeed - 141.75 ) )
	//return ( fallSpeed / 8 )
	return (( fallSpeed - 526.5 ) * (100 / 396))
end

function GM:OnPlayerHitGround(client)
	client:ViewPunch( Angle(math.Rand(2.0, 2.25), 0.1, 0) )
end

function GM:PlayerButtonDown(ply, key)
	if (key == IN_USE) then
		print("hi")
		for k,v in pairs(ents.FindInSphere(ply:GetPos(), 30)) do
			if (string.match(tostring(v), "weapon_")) then
				ply:Give(swapMapWeapons[v:GetClass()])
				v:Remove()
				break
			end
		end
	end
end

function GM:PlayerUse(ply, entity)
	if (IsValid(ply) && IsValid(entity)) then
		if (ply:Team() == TEAM_PRISONER_DEAD or ply:Team() == TEAM_GUARD_DEAD) then
			return false
		end

		if(entity == ents.GetMapCreatedEntity(jb.config["opencellsButton"]) && ents.GetMapCreatedEntity(jb.config["opencellsButton"]):GetSaveTable()["m_vecFinalDest"] == Vector(0,0,0)) then
			self:Notify(ply:Name() .. " has opened the cells!")
		end
		
		if ( string.find(entity:GetClass(), "button") ) then			
			if ( (ply.nextPress or 0) < CurTime() ) then
				self:AdminNotify(ply:Name().." has pressed "..tostring(entity).." ("..tostring( entity:GetName() )..").")
	
				ply.nextPress = CurTime() + 1.5
			end
		end

		return true
	end
end

function GM:PlayerCanPickupWeapon(ply, wep)
	if (wep:GetClass() == "jb_fists") then return true end

	if (ply:KeyDown(IN_USE)) then
		local numPrimary, numSecondary = 0, 0
		for k,v in pairs(ply:GetWeapons()) do
			if (v.Slot == 0) then
				numPrimary = numPrimary + 1
			elseif (v.Slot == 1) then
				numSecondary = numSecondary + 1
			end
		end
		
		local wepClass = wep:GetClass()
		
		if (wep.OwnerPickup and wep.OwnerPickup >= CurTime()) then return false end
		
		if (ply:HasWeapon(wepClass)) then
			return false
		else
			if (wep.Slot == 0 && numPrimary > 0) then
				return false
			elseif  (wep.Slot == 1 && numSecondary > 0) then
				return false
			end
		end
		
		return true
	end
end

function GM:PlayerCanHearPlayersVoice(listener, speaker)
	if (JB_ROUND_STATE == ROUND_ACTIVE) then
		if ( speaker:Team() != TEAM_GUARD and (self.VoiceTime or 0) >= CurTime() ) then
			return false
		end

		if (speaker:Team() == TEAM_GUARD_DEAD or speaker:Team() == TEAM_PRISONER_DEAD) then
			if (listener:Team() != TEAM_GUARD_DEAD and listener:Team() != TEAM_PRISONER_DEAD) then
				return false
			end
		end
	end

	return true
end

function GM:ShowSpare1(client)
	net.Start("jb_showMenu")
	net.Send(client)
end

function GM:DropWeapon(client)
	local weapon = client:GetActiveWeapon()

	if ( IsValid(weapon) ) then
		local class = weapon:GetClass()

		if ( IsValid(weapon) and !table.HasValue(PREVENT_DROP, class) ) then
			local weapon = self:CreateGun( class, client:GetPos() + Vector(0, 0, 48) + client:GetAimVector()*64, client:GetAngles() )

			if ( IsValid(weapon) ) then
				weapon.RealOwner = client
				weapon.OwnerPickup = CurTime() + 1

				local physicsObject = weapon:GetPhysicsObject()

				if ( IsValid(physicsObject) ) then
					physicsObject:ApplyForceCenter(client:GetVelocity() + client:GetAimVector() * 1000)
				end
			end

			self:AdminNotify("Player "..tostring(client).." has dropped "..class)

			client:StripWeapon(class)
		end
	end
end

concommand.Add("jb_dropweapon", function(client, command, arguments)
	if ( (client.jb_LastDrop or 0) < CurTime() ) then
		GAMEMODE:DropWeapon(client)

		client.jb_LastDrop = CurTime() + 0.5
	end
end)

concommand.Add("jb_returnEntity", function(ply, command, args)
	print(ply:GetEyeTrace().Entity:MapCreationID())
end)

function GM:Notify(message, receivers)
	net.Start("jb_Notice")
		net.WriteString(message)

	if (!receivers) then
		net.Broadcast()
	else
		net.Send(receivers)
	end
end

function GM:PlayerSay(client, text, public)
	//REMEMBER THIS SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSs
	//only ooc text can be seen
	
	//this overrides dangerous
	return text
end

function GM:PlayerEnterSwaplist(ply)
	local currentPlyTeam = ply:Team()

	if ((currentPlyTeam == TEAM_GUARD || currentPlyTeam == TEAM_GUARD_DEAD) && table.HasValue(JB_SWAP_PRISONER, ply)) || ((currentPlyTeam == TEAM_PRISONER || currentPlyTeam == TEAM_PRISONER_DEAD && table.HasValue(JB_SWAP_GUARD, ply))) then
		self:Notify("You have removed yourself from the swaplist to " .. ((currentPlyTeam == TEAM_GUARD || currentPlyTeam == TEAM_GUARD_DEAD) and "prisoners." or "guards."), ply)
		
		if (currentPlyTeam == TEAM_PRISONER || currentPlyTeam == TEAM_PRISONER_DEAD) then
			for k,v in pairs(JB_SWAP_GUARD) do
				if (v == ply) then
					table.remove(JB_SWAP_GUARD, k)
					break
				end
			end
		else
			for k,v in pairs(JB_SWAP_PRISONER) do
				if (v == ply) then
					table.remove(JB_SWAP_PRISONER, k)
					break
				end
			end
		end
	else
		if (!table.HasValue(JB_SWAP_GUARD, ply)) then
			table.insert(JB_SWAP_GUARD, ply)
			self:Notify("You have entered the swaplist for guards.", ply)
		elseif (!table.HasValue(JB_SWAP_PRISONER, ply)) then
			table.insert(JB_SWAP_PRISONER, ply)
			self:Notify("You have entered the swaplist for prisoners.", ply)
		end
	end
end

net.Receive("jb_switchTeams", function(length, ply)
	if (IsValid(ply)) then
		GAMEMODE:PlayerEnterSwaplist(ply)
	end
end)

function GM:ShowTeam(client)
	local warden = self:GetGlobalVar("warden")

	if (IsValid(warden) and IsValid(client) and client == warden) then
		if ((client.nextDivide or 0) < CurTime()) then
			client.nextDivide = CurTime() + 3
		else
			return
		end

		if (client:Team() != TEAM_GUARD) then
			return
		end

		if (!client.madeTeams) then
			self:Notify(client:Name().." has divided the prisoners into teams.")

			local players = team.GetPlayers(TEAM_PRISONER)
			local half = math.Round(#players / 2)

			for k, v in RandomPairs(players) do
				if (k > half) then
					v:SetPlayerColor( Vector(1, 0.3, 0.3) )

					self:Notify("You have been placed on red team.", v)
				else
					v:SetPlayerColor( Vector(0.3, 0.4, 1) )

					self:Notify("You have been placed on blue team.", v)
				end
			end

			client.madeTeams = true
		else
			self:Notify(client:Name().." has removed the teams.")

			for k, v in pairs( team.GetPlayers(TEAM_PRISONER) ) do
				v:SetPlayerColor( Vector(1, 0.6, 0.05) )
			end

			client.madeTeams = false
		end
	else
		self:Notify("You are not the warden!", client)
	end
end