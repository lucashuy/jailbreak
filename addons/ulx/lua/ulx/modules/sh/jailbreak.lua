local CATEGORY_NAME = "Jailbreak"

/*
	guardban/guardbanid
*/
function ulx.guardban(calling, target, time, reason)
	if (sqlCheckGuardban(target:SteamID())) then
		ULib.tsayError(calling, target:Name() .. " is already guardbanned.", true)
		return
		//im guessing i can just return nothing?
	end
	
	sqlMakeGuardban(target:SteamID(), calling, time, reason)
	
	//doesnt really matter if we set them to the dead team or not. the gm takes care of that, but why not. i might change the gm later
	if (target:Team() == 2) then
		target:KillSilent()
		target:SetTeam(3)
	elseif (target:Team() == 4) then
		target:SetTeam(3)
	end
	
	if (reason != "") then
		ulx.fancyLogAdmin(calling, "#A banned #T from playing on the guard team for #i minutes (#s)", target, time, reason)
	else
		ulx.fancyLogAdmin(calling, "#A banned #T from playing on the guard team for #i minutes", target, time)
	end
end
local guardban = ulx.command("Jailbreak", "ulx guardban", ulx.guardban, "!gb")
guardban:addParam{type=ULib.cmds.PlayerArg}
guardban:addParam{type=ULib.cmds.NumArg, min=1, hint="minutes", ULib.cmds.allowTimeString, ULib.cmds.round}
guardban:addParam{type=ULib.cmds.StringArg, hint="reason", ULib.cmds.optional, ULib.cmds.takeRestOfLine}
guardban:defaultAccess(ULib.ACCESS_ADMIN)
guardban:help("Bans the target from playing on the guard team.")

function ulx.guardbanid(calling, steamid, time, reason)
	local sid = steamid:upper()

	if (!ULib.isValidSteamID(sid)) then
		ULib.tsayError(calling, "Invalid steamid", true)
		return
	end
	
	if (sqlCheckGuardban(sid:SteamID())) then
		ULib.tsayError(calling, sid .. " is already guardbanned.", true)
		return
	end
	
	sqlMakeGuardban(sqlMakeGuardban(sid:SteamID(), calling, time, reason))
	
	//if the player is online and the staff member didnt catch that
	local fPlayer = player.GetBySteamID(steamid)
	if (fPlayer) then
		if (fPlayer:Team() == 2) then
			fPlayer:KillSilent()
			fPlayer:SetTeam(3)
		elseif (fPlayer:Team() == 4) then
			fPlayer:SetTeam(3)
		end
	end
	
	if (reason != "") then
		ulx.fancyLogAdmin(calling, "#A banned #T from playing on the guard team for #i minutes (#s)", sid, time, reason)
	else
		ulx.fancyLogAdmin(calling, "#A banned #T from playing on the guard team for #i minutes", sid, time)
	end
end
local guardban = ulx.command("Jailbreak", "ulx guardbanid", ulx.guardbanid)
guardban:addParam{type=ULib.cmds.StringArg, hint="steamid"}
guardban:addParam{type=ULib.cmds.NumArg, min=1, hint="minutes", ULib.cmds.allowTimeString, ULib.cmds.round}
guardban:addParam{type=ULib.cmds.StringArg, hint="reason", ULib.cmds.optional, ULib.cmds.takeRestOfLine}
guardban:defaultAccess(ULib.ACCESS_ADMIN)
guardban:help("Bans the steamid from playing on the guard team.")



/*
	unguardban/unguardbanid
*/
function ulx.unguardban(calling, target, reason)
	if (!sqlCheckGuardban(target:SteamID())) then
		ULib.tsayError(calling, target:Name() .. " is not currently guardbanned", true)
		return
	end
	
	sqlRemoveGuardban(target:SteamID())
	
	if (reason != "") then
		ulx.fancyLogAdmin(calling, "#A has unbanned #T from playing on the guard team (#s)", target, reason)
	else
		ulx.fancyLogAdmin(calling, "#A has unbanned #T from playing on the guard team", target)
	end
end
local unguardban = ulx.command("Jailbreak", "ulx unguardban", ulx.unguardban)
unguardban:addParam{type=ULib.cmds.PlayerArg}
unguardban:addParam{type=ULib.cmds.StringArg, hint="reason", ULib.cmds.optional, ULib.cmds.takeRestOfLine}
unguardban:defaultAccess(ULib.ACCESS_ADMIN)
unguardban:help("Unbans the target from not being able to play on the guard team.")

function ulx.unguardbanid(calling, steamid, reason)
	local sid = steamid:upper()

	if (!ULib.isValidSteamID(sid)) then
		ULib.tsayError(calling, "Invalid steamid", true)
		return
	end

	if (!sqlCheckGuardban(sid)) then
		ULib.tsayError(calling, sid .. " is not currently guardbanned", true)
		return
	end
	
	sqlRemoveGuardban(sid)
	
	if (reason != "") then
		ulx.fancyLogAdmin(calling, "#A has unbanned #T from playing on the guard team (#s)", sid, reason)
	else
		ulx.fancyLogAdmin(calling, "#A has unbanned #T from playing on the guard team", sid)
	end
end
local unguardbanid = ulx.command("Jailbreak", "ulx unguardbanid", ulx.unguardbanid)
unguardbanid:addParam{type=ULib.cmds.StringArg, hint="steamid"}
unguardbanid:addParam{type=ULib.cmds.StringArg, hint="reason", ULib.cmds.optional, ULib.cmds.takeRestOfLine}
unguardbanid:defaultAccess(ULib.ACCESS_ADMIN)
unguardbanid:help("Unbans the steamid from not being able to play on the guard team.")

/*
	endround
	
	ents.GetMapCreatedEntity( 1268 ):Fire("Use")
*/
