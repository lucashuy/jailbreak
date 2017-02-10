ROUND_DEAD = 1
ROUND_SETUP = 2
ROUND_ACTIVE = 3
ROUND_END = 4

JB_ROUND_STATE = JB_ROUND_STATE or ROUND_DEAD

function GM:NewRound()
	if (JB_ROUND_STATE == ROUND_END) then
		JB_ROUND_STATE = ROUND_SETUP

		game.CleanUpMap()

		local swapMapWeapons = {
			weapon_famas = "bb_famas_alt",
			weapon_m4a1 = "bb_m4a1_alt",
			weapon_mp5navy = "bb_scout_alt",
			weapon_usp = "bb_usp_alt",
			weapon_ak47 = "bb_ak47_alt",
			weapon_deagle = "bb_deagle_alt",
			weapon_xm1014 = "bb_m3_alt"
		}
		
		for k, v in pairs(ents.FindByClass("weapon_*")) do
			//v:SetMoveType(MOVETYPE_NONE)
			if (swapMapWeapons[v:GetClass()]) then
				local gunPos, gunAngle = v:GetPos(), v:GetAngles()
				local gunSwap = swapMapWeapons[v:GetClass()]
				v:Remove()
				self:CreateGun(gunSwap, gunPos, gunAngle)
			end
		end
		
		ents.GetMapCreatedEntity(1268):Remove() //close cell button
		
		self:SetGlobalVar("killer", NULL)
		self:SetGlobalVar("victim", NULL)
		self:SetGlobalVar("kill_phrase", nil)

		for k, v in pairs( player.GetAll() ) do
			if (v:Team() == TEAM_GUARD_DEAD) then
				v:SetTeam(TEAM_GUARD)
			elseif (v:Team() == TEAM_PRISONER_DEAD) then
				v:SetTeam(TEAM_PRISONER)
			end
		end

		timer.Simple(0.01, function()
			self:BalanceTeams()
		end)

		timer.Simple(0.02, function()
			for k, v in pairs( player.GetAll() ) do			
				v:Spawn()
				v:Freeze(true)
			end
		end)

		timer.Simple(0.03, function()
			local time = 3
			local extraWait = self:StartWardenVote()

			if (extraWait) then
				time = 5.5
			end

			timer.Simple(time, function()
				for k, v in pairs( player.GetAll() ) do
					v:Freeze(false)
				end

				self:Notify("A new round has started!")
				self:SetGlobalVar("round_start", CurTime() + self.RoundTime)

				timer.Simple(1, function()
					self:Notify("Prisoners have been muted for the first thirty seconds of the round.")
				end)

				self.VoiceTime = CurTime() + 30

				timer.Stop("jb_Unmute")

				timer.Create("jb_Unmute", 29.5, 1, function()
					self:Notify("Prisoners have now been unmuted.")
				end)

				JB_ROUND_STATE = ROUND_ACTIVE
			end)
		end)
	end
end

function GM:PlayerDisconnected(client)
	for k, v in pairs(JB_SWAP_PRISONER) do
		if (v == client) then
			table.remove(JB_SWAP_PRISONER, k)
		end
	end

	for k, v in pairs(JB_SWAP_GUARD) do
		if (v == client) then
			table.remove(JB_SWAP_PRISONER, k)
		end
	end
end

function GM:BalanceTeams()
	for k, v in ipairs(JB_SWAP_GUARD) do
		if (IsValid(v)) then
			local partner = table.GetFirstValue(JB_SWAP_PRISONER)

			if (IsValid(partner)) then
				v:SetTeam(TEAM_GUARD)
				partner:SetTeam(TEAM_PRISONER)

				table.remove(JB_SWAP_GUARD, k)

				for k, v in pairs(JB_SWAP_PRISONER) do
					if (v == partner) then
						table.remove(JB_SWAP_PRISONER, k)
					end
				end

				self:Notify("You have swapped with "..partner:Name().." to the guard team.", v)
				self:Notify("You have swapped with "..v:Name().." to the prisoners team.", partner)
			end
		else
			table.remove(JB_SWAP_PRISONER, k)
		end
	end

	for k, v in ipairs(team.GetPlayers(TEAM_GUARD)) do
		local canBeGuard, difference = self:PlayerCanBeGuard()

		if (!canBeGuard and difference > 1) then
			v:SetTeam(TEAM_PRISONER)
		end
	end

	for k, v in ipairs(JB_SWAP_GUARD) do
		if (IsValid(v)) then
			local canBeGuard = self:PlayerCanBeGuard()

			if (canBeGuard == true) then
				v:SetTeam(TEAM_GUARD)
				table.remove(JB_SWAP_GUARD, k)
				self:Notify("You have been swapped over to the guard team.", v)
			end
		else
			table.remove(JB_SWAP_GUARD, k)
		end
	end

	for k, v in pairs(team.GetPlayers(TEAM_PRISONER)) do
		if (self:PlayerCanBeGuard()) then
			v:SetTeam(TEAM_GUARD)
		end
	end
end

function GM:EndRound(winner)
	JB_ROUND_STATE = ROUND_END
		
	if (winner) then
		team.AddScore(winner, 1)

		self:Notify("The "..team.GetName(winner).." team has won!")
	else
		self:Notify("The round has resulted in a tie.")
	end


	self:Notify("A new round will begin in five seconds.")

	self:SetGlobalVar("warden", NULL)
	self:SetGlobalVar("round_start", nil)
	self:SetGlobalVar("waypoint", nil)
	
	timer.Simple(5, function()
		self:NewRound()
	end)
end

function GM:ShouldRoundEnd()
	if (JB_ROUND_STATE == ROUND_ACTIVE) then
		if (#player.GetAll() >= 2) then
			local guards = team.NumPlayers(TEAM_GUARD)
			local prisoners = team.NumPlayers(TEAM_PRISONER)

			if (guards > 0 and prisoners == 0) then
				self:EndRound(TEAM_GUARD)
			elseif (guards == 0 and prisoners > 0) then
				self:EndRound(TEAM_PRISONER)
			elseif (guards == 0 and prisoners == 0) then
				self:EndRound()
			end
		end
	end
end


function GM:ShouldPlayerSpectate()
	//fix this for ulx
	return JB_ROUND_STATE == ROUND_ACTIVE or JB_ROUND_STATE == ROUND_DEAD or JB_ROUND_STATE == ROUND_END
end


function GM:ShouldPlayerSpectate(ply)
	if ply.ForcedRespawn and JB_ROUND_STATE == ROUND_ACTIVE then return false end
	return ply:Team() == TEAM_SPECTATOR or JB_ROUND_STATE ~= ROUND_SETUP
end

function GM:HandleInitialRound()
	if (JB_ROUND_STATE == ROUND_DEAD and #player.GetAll() >= 2) then
		JB_ROUND_STATE = ROUND_END

		self:Notify("A new round will begin in five seconds.")

		timer.Simple(5, function()
			local guards = team.NumPlayers(TEAM_GUARD) + team.NumPlayers(TEAM_GUARD_DEAD)
			local prisoners = team.NumPlayers(TEAM_PRISONER) + team.NumPlayers(TEAM_PRISONER_DEAD)

			if (guards > 0 and prisoners > 0) then
				self:NewRound()
			else
				JB_ROUND_STATE = ROUND_DEAD
			end
		end)
	end
end

hook.Add("Tick", "jb_RoundTick", function()
	local start = GAMEMODE:GetGlobalVar("round_start")

	if (start and JB_ROUND_STATE == ROUND_ACTIVE) then
		GAMEMODE:ShouldRoundEnd()

		if ( start < CurTime() ) then
			GAMEMODE:EndRound()
		end
	end
end)