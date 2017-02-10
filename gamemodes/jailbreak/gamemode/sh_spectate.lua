AddCSLuaFile()

if (SERVER) then
	local SPECTATE_MODES = {
		OBS_MODE_IN_EYE,
		OBS_MODE_CHASE,
		OBS_MODE_ROAMING
	}

	concommand.Add("jb_spec_changemode", function(client, command, arguments)
		if (JB_ROUND_STATE != ROUND_ACTIVE) then
			return
		end

		if ( !IsValid(client) ) then
			return
		end

		local isSpectating = client:Team() == TEAM_GUARD_DEAD or client:Team() == TEAM_PRISONER_DEAD

		if (isSpectating) then
			local nextIndex = (client.jb_SpectateMode or 1) + 1
			local mode = SPECTATE_MODES[nextIndex]

			if (!mode) then
				mode = SPECTATE_MODES[1]
				client.jb_SpectateMode = 1
			else
				client.jb_SpectateMode = nextIndex
			end

			client:Spectate(mode)
		end
	end)

	concommand.Add("jb_spec_next", function(client, command, arguments)
		if (JB_ROUND_STATE != ROUND_ACTIVE) then
			return
		end

		local isSpectating = client:Team() == TEAM_GUARD_DEAD or client:Team() == TEAM_PRISONER_DEAD

		if (isSpectating) then
			local players = {}

			for k, v in ipairs( player.GetAll() ) do
				if (v:Team() == TEAM_PRISONER or v:Team() == TEAM_GUARD) then
					table.insert(players, v)
				end
			end

			local nextIndex = (client.jb_SpectateID or 1) + 1

			if ( !players[nextIndex] ) then
				nextIndex = 1
			end

			local target = players[nextIndex]

			if ( IsValid(target) ) then
				client:SpectateEntity(target)
				client.jb_SpectateID = nextIndex
			end
		end
	end)

	concommand.Add("jb_spec_prev", function(client, command, arguments)
		if (JB_ROUND_STATE != ROUND_ACTIVE) then
			return
		end
		
		local isSpectating = client:Team() == TEAM_GUARD_DEAD or client:Team() == TEAM_PRISONER_DEAD

		if (isSpectating) then
			local players = {}

			for k, v in ipairs( player.GetAll() ) do
				if (v:Team() == TEAM_PRISONER or v:Team() == TEAM_GUARD) then
					table.insert(players, v)
				end
			end

			local nextIndex = (client.jb_SpectateID or 1) - 1

			if ( !players[nextIndex] ) then
				nextIndex = #players
			end

			local target = players[nextIndex]

			if ( IsValid(target) ) then
				client:SpectateEntity(target)
				client.jb_SpectateID = nextIndex
			end
		end
	end)
else
	hook.Add("HUDPaint", "jb_Spectate", function()
		local scrW, scrH = ScrW(), ScrH()

		if (LocalPlayer():Team() == TEAM_PRISONER_DEAD or LocalPlayer():Team() == TEAM_GUARD_DEAD) then
			local text = "Left Click: Cycle Previous Right Click: Cycle Next Space: Change Mode"
			local entity = LocalPlayer():GetObserverTarget()

			if ( IsValid(entity) and entity:IsPlayer() and entity:Alive() ) then
				if (entity:Team() == TEAM_PRISONER_DEAD or entity:Team() == TEAM_GUARD_DEAD) then
					if (team.NumPlayers(TEAM_GUARD) > 0 and team.NumPlayers(TEAM_PRISONER) > 0) then
						RunConsoleCommand("jb_spec_next")
					end
				end

				draw.SimpleText("Spectating "..entity:Name(), "jb_BigFont", scrW / 2 + 1, scrH * 0.1 + 1, color_black, 1, 1)
				draw.SimpleText("Spectating "..entity:Name(), "jb_BigFont", scrW / 2, scrH * 0.1, color_white, 1, 1)
			end

			draw.SimpleText(text, "jb_MedFont", scrW / 2 + 1, scrH * 0.95 + 1, color_black, 1, 1)
			draw.SimpleText(text, "jb_MedFont", scrW / 2, scrH * 0.95, color_white, 1, 1)
		end
	end)

	hook.Add("PlayerBindPress", "jb_SpectateBinds", function(client, bind, pressed)
		if (client:Team() == TEAM_PRISONER_DEAD or client:Team() == TEAM_GUARD_DEAD) then
			local lower = string.lower(bind)

			if ( pressed and string.find(lower, "+attack2") ) then
				RunConsoleCommand("jb_spec_next")

				return true
			elseif ( pressed and string.find(lower, "+attack") ) then
				RunConsoleCommand("jb_spec_prev")

				return true
			elseif ( pressed and string.find(lower, "+jump") ) then
				RunConsoleCommand("jb_spec_changemode")

				return true
			end
		end
	end)
end