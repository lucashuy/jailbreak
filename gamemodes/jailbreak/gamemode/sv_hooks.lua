jb = jb or {}
jb.config = jb.config or {}

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

local gunsPrimary = {
	"tfcss_m4a1_alt",
	"tfcss_ak47_alt",
	"tfcss_scout_alt",
	"tfcss_mp5_alt",
	"tfcss_ump45_alt",
}

local gunsSecondary = {
	"tfcss_usp_alt",
	"tfcss_usp_alt",
	"tfcss_dualelites_alt",
	"tfcss_fiveseven_alt",
}

local PREVENT_DROP = {}
PREVENT_DROP[1] = "jb_fists"

local function playerInArmoury(ply)
	for k,v in pairs(ents.FindInBox(jb.config["armouryLocation"][1], jb.config["armouryLocation"][2])) do
		if (v:IsPlayer() && v == ply) then
			return true
		end
	end
	return false
end

function GM:InitPostEntity()
	self.BaseClass:InitPostEntity()

	for k, v in pairs(ents.FindByClass("weapon_*")) do
		v:SetMoveType(MOVETYPE_NONE)
	end

	game.ConsoleCommand("sv_gravity 505\n")
end

function GM:PlayerInitialSpawn(ply)
	//hey there, you loaded in too quickly for me to handle
	timer.Simple(1, function()
		if ( !IsValid(ply) ) then
			return
		end
		
		ply:SetTeam(TEAM_PRISONER)
		ply:SetModel(table.Random(self.PrisonerModels))
		
		if ( self:ShouldPlayerSpectate(ply) ) then
			self:SpawnAsSpectator(ply)
		else
			self:PlayerLoadout(ply)
		end

		self:HandleInitialRound()
	end)

	timer.Simple(5 + (ply:Ping() / 250), function()
		if ( IsValid(ply) ) then
			self:SendGlobalVars(ply)
		end
	end)
end

function GM:PlayerHurt(victim, attacker, remaining, damage)
	if (attacker:IsPlayer() && victim:IsPlayer()) then
		self:AdminNotify("[" .. team.GetName(victim:Team()) .. "]" .. victim:Name() .. " was attacked for " .. tostring(math.floor(damage)) .. " by [" ..  team.GetName(attacker:Team()) .. "]" .. attacker:Name())
	end
end

function GM:AdminNotify(message)
	print(message)
	for k, v in pairs( player.GetAll() ) do
		if ( v:IsAdmin() or ( v.CheckGroup and v:CheckGroup("moderator") ) ) then
			net.Start("jb_Admin")
				net.WriteString(message)
			net.Send(v)
		end
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

function GM:PlayerSpawn(ply)
	ply:StripWeapons()
	ply:StripAmmo()
	ply:UnSpectate()
	ply:SetDSP(1)
	ply.madeTeams = nil
	ply.hasLR = false
	ply.isLastGuard = false
	
	if (ply:Team() == TEAM_GUARD_DEAD || ply:Team() == TEAM_GUARD) then
		ply:SetTeam(TEAM_GUARD)
		ply:SetModel(table.Random(self.GuardModels))
	elseif (ply:Team() == TEAM_PRISONER_DEAD || ply:Team() == TEAM_PRISONER) then
		ply:SetTeam(TEAM_PRISONER)
		ply:SetModel(table.Random(self.PrisonerModels))
	elseif (self:GetGlobalVar("warden") == ply) then
		ply:SetModel(self.WardenModel)
	end
	
	if ( self:ShouldPlayerSpectate(ply) ) then
		self:SpawnAsSpectator(ply)
		return
	end
	
	if (ply:Team() == 2 && team.NumPlayers(TEAM_GUARD) == 1) then
		ply.isLastGuard = true
	end
	
	local spawn = self:PlayerSelectTeamSpawn(ply:Team(), ply)
	if ( IsValid(spawn) ) then
		ply:SetPos( spawn:GetPos() + Vector(0, 0, 16) )
	end

	if (ply:Team() == TEAM_PRISONER) then
		ply:SetPlayerColor( Vector(1, 0.6, 0.05) )
	else
		ply:SetPlayerColor( Vector(0, 0.5, 2) )
	end
	
	ply:SetWalkSpeed(200)
	ply:SetRunSpeed(200)
	ply:SetAvoidPlayers(false)
	ply:SetNoCollideWithTeammates(true)
	ply:SetCollisionGroup( COLLISION_GROUP_WEAPON )
		
	if (playerInArmoury(ply)) then
		if (ply:Team() != 2 || !ply.rememberSelections) then
			net.Start("jb_openGun")
			net.Send(ply)
		else
			self:PlayerLoadout(ply)
		end
	else
		ply:Give("jb_fists")
	end
	
	player_manager.SetPlayerClass(ply, "player_jb")
	player_manager.RunClass(ply, "Spawn")
end

function GM:PlayerSpray(client)
	if (client:Team() == TEAM_PRISONER_DEAD or client:Team() == TEAM_GUARD_DEAD) then
		return true
	end

	return false
end

net.Receive("jb_receieveGun", function(length, ply)
	ply.rememberSelections = net.ReadBool()
	ply.selectedPrimary = net.ReadString()
	ply.selectedSecondary = net.ReadString()
	
	GAMEMODE:PlayerLoadout(ply)
end)

function GM:PlayerLoadout(ply)
	ply:StripWeapons()
	ply:StripAmmo()
	ply:Give("jb_fists")
	
	if (playerInArmoury(ply)) then //check again just in case if they somehow made it out of the armoury
		ply.forceGive = true
		if (ply.selectedPrimary == "random") then
			ply:Give(table.Random(gunsPrimary))
		else
			ply:Give(ply.selectedPrimary)
		end
		
		ply.forceGive = true
		if (ply.selectedSecondary == "random") then
			ply:Give(table.Random(gunsSecondary))
		else
			ply:Give(ply.selectedSecondary)
		end
	end
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

function GM:PlayerDeathSound()
	return true
end

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

	if (team.NumPlayers(TEAM_PRISONER) == 1 && team.NumPlayers(TEAM_GUARD) > 0) then
		team.GetPlayers(TEAM_PRISONER)[1].hasLR = true
		self:Notify(team.GetPlayers(TEAM_PRISONER)[1]:Name() .. " is the last prisoner alive.")
	elseif (team.NumPlayers(TEAM_PRISONER) > 1 && team.NumPlayers(TEAM_GUARD) == 1) then
		if (IsValid(team.GetPlayers(TEAM_GUARD)[1]) && !team.GetPlayers(TEAM_GUARD)[1].isLastGuard ) then //must be here for endround nuke on summer
			team.GetPlayers(TEAM_GUARD)[1].isLastGuard = true
			self:Notify(team.GetPlayers(TEAM_GUARD)[1]:Name() .. " is the last guard alive.")
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
	return (( fallSpeed - 526.5 ) * (100 / 396))
end

function GM:OnPlayerHitGround(client)
	client:ViewPunch( Angle(math.Rand(2.0, 2.25), 0.1, 0) )
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
	if (wep:GetClass() == "jb_fists" || ply.forceGive) then
		ply.forceGive = false
		return true
	end
	
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
			
			//so sloppy
			if (string.match(tostring(wepClass), "weapon_") && !ply:HasWeapon(swapMapWeapons[wepClass])) then
				ply:Give(swapMapWeapons[wepClass])
				if (ply:HasWeapon(swapMapWeapons[wepClass])) then
					wep:Remove()
				end
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

function GM:DropWeapon(ply)
	local weapon = ply:GetActiveWeapon()

	if (IsValid(weapon)) then
		local class = weapon:GetClass()

		if (IsValid(weapon) && !table.HasValue(PREVENT_DROP, class)) then
			if (!playerInArmoury(ply)) then
				local weapon = self:CreateGun( class, ply:GetPos() + Vector(0, 0, 48) + ply:GetAimVector()*64, ply:GetAngles() )

				if (IsValid(weapon)) then
					weapon.RealOwner = ply
					weapon.OwnerPickup = CurTime() + 1

					local physicsObject = weapon:GetPhysicsObject()

					if (IsValid(physicsObject)) then
						physicsObject:ApplyForceCenter(ply:GetVelocity() + ply:GetAimVector() * 10)
					end
				end

				self:AdminNotify("[" .. team.GetName(ply:Team()) .. "]" .. ply:Name() .. " has dropped " .. class)
			else
				self:AdminNotify("[" .. team.GetName(ply:Team()) .. "]" .. ply:Name() .. " has dropped " .. class .. " while in the armoury")
			end
			ply:StripWeapon(class)
		end
	end
end

concommand.Add("jb_dropweapon", function(client, command, arguments)
	if ( (client.jb_LastDrop or 0) < CurTime() ) then
		GAMEMODE:DropWeapon(client)

		client.jb_LastDrop = CurTime() + 0.5
	end
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

function GM:PlayerSay(ply, txt, public)
	//REMEMBER THIS SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSs
	//only ooc text can be seen
	
	//this overrides dangerous
	return txt
end

function GM:PlayerEnterSwaplist(ply)	
	local currentPlyTeam = ply:Team()

	if (sqlCheckGuardban(ply:SteamID())) && (currentPlyTeam == TEAM_PRISONER || currentPlyTeam == TEAM_PRISONER_DEAD) then
		self:Notify("You are guardbanned! You cannot join the guards team.", ply)
		return
	end
	
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
		if (currentPlyTeam == TEAM_PRISONER || currentPlyTeam == TEAM_PRISONER_DEAD && !table.HasValue(JB_SWAP_GUARD, ply)) then
			table.insert(JB_SWAP_GUARD, ply)
			self:Notify("You have entered the swaplist for guards.", ply)
		elseif (currentPlyTeam == TEAM_GUARD || currentPlyTeam == TEAM_GUARD_DEAD && !table.HasValue(JB_SWAP_PRISONER, ply)) then
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

function GM:ShowHelp(ply)
	if (playerInArmoury(ply)) then
		net.Start("jb_openGun")
		net.Send(ply)
	end
end

function GM:ShowSpare1(ply)
	net.Start("jb_showMenu")
	net.Send(ply)
end


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