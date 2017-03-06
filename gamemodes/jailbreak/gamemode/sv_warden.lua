util.AddNetworkString("jb_WardenVote")
util.AddNetworkString("jb_WardenChoice")

JB_WARDEN_QUEUE = JB_WARDEN_QUEUE or {}
JB_WARDEN_NOVOTE = JB_WARDEN_NOVOTE or false

function GM:PickWarden()
	if (table.Count(JB_WARDEN_QUEUE) > 0) then
		local highest = 0
		local highestPlayer

		for k, v in pairs(JB_WARDEN_QUEUE) do
			if (v > highest) then
				highest = v
				highestPlayer = k
			end
		end

		if ( IsValid(highestPlayer) ) then
			return highestPlayer
		else
			return table.Random( team.GetPlayers(TEAM_GUARD) )
		end
	else
		return table.Random( team.GetPlayers(TEAM_GUARD) )
	end

	JB_WARDEN_QUEUE = {}
end

function GM:ShowSpare2(client)
	local warden = self:GetGlobalVar("warden")

	if (client:Team() == TEAM_GUARD and IsValid(warden) and warden == client) then
		if ( timer.Exists("jb_Waypoint") ) then
			timer.Destroy("jb_Waypoint")
		end
		
		self:SetGlobalVar( "waypoint", client:GetEyeTrace().HitPos + Vector(0, 0, 48) )
		self:SetGlobalVar("waypoint_expire", CurTime() + 30)
		
		timer.Create("jb_Waypoint", 30, 1, function()
			self:SetGlobalVar("waypoint", nil)
			self:SetGlobalVar("waypoint_expire", nil)
		end)
	end
end

function GM:StartWardenVote()
	for k, v in pairs(JB_WARDEN_QUEUE) do
		if (!IsValid(k) or k:Team() == TEAM_PRISONER) then
			JB_WARDEN_QUEUE[k] = nil
		else
			JB_WARDEN_QUEUE[k] = 0
		end
	end

	if (table.Count(JB_WARDEN_QUEUE) > 0) then
		JB_WARDEN_NOVOTE = true

		net.Start("jb_WardenVote")
			net.WriteTable(JB_WARDEN_QUEUE)
		net.Send( team.GetPlayers(TEAM_GUARD) )

		timer.Simple(10, function()
			local warden = self:PickWarden()

			if ( IsValid(warden) ) then
				self:Notify(warden:Name().." is the new warden!")
				self:SetGlobalVar("warden", warden)
				warden:SetArmor(25)
				warden:SetModel(self.WardenModel)

				JB_WARDEN_NOVOTE = false
			end
		end)

		return true
	else
		local warden = table.Random( team.GetPlayers(TEAM_GUARD) )

		if ( IsValid(warden) ) then
			self:Notify(warden:Name().." has randomly been chosen as the warden!")
			self:SetGlobalVar("warden", warden)
			warden:SetArmor(25)
			warden:SetModel(self.WardenModel)
		end
	end
	/*
	else
		local warden = table.Random( team.GetPlayers(TEAM_GUARD) )

		if ( IsValid(warden) ) then
			self:Notify(warden:Name().." has randomly been chosen as the warden!")
			self:SetGlobalVar("warden", warden)
			warden:SetArmor(25)
		end
	end
	*/
	return false
end

net.Receive("jb_optWarden", function(length, ply)
	if (IsValid(ply)) then
		if (ply:Team() == 2 || ply:Team() == 4) then
			if ( JB_WARDEN_QUEUE[ply] ) then
				JB_WARDEN_QUEUE[ply] = nil

				GAMEMODE:Notify("You have opt-out of being a warden.", ply)
			elseif (!JB_WARDEN_NOVOTE) then
				JB_WARDEN_QUEUE[ply] = 0
	
				GAMEMODE:Notify("You have opt-in of being a warden.", ply)
			end
		end
	end
end)

/*
function GM:ShowSpare1(client)
	if (client:Team() == TEAM_GUARD or client:Team() == TEAM_GUARD_DEAD) then
		if ( JB_WARDEN_QUEUE[client] ) then
			JB_WARDEN_QUEUE[client] = nil

			self:Notify("You have opt-out of being a warden.", client)
		elseif (!JB_WARDEN_NOVOTE) then
			JB_WARDEN_QUEUE[client] = 0

			self:Notify("You have opt-in of being a warden.", client)
		end
	end
end
*/

net.Receive("jb_WardenChoice", function(length, client)
	local index = net.ReadUInt(8)
	local choice = player.GetByID(index)

	if ( IsValid(choice) and JB_WARDEN_QUEUE[choice] ) then
		JB_WARDEN_QUEUE[choice] = JB_WARDEN_QUEUE[choice] + 1
	end
end)

