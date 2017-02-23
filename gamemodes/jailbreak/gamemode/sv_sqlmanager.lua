function GM:Initialize()
	if (!sql.TableExists( "guardbans" )) then
		sql.Query("CREATE TABLE IF NOT EXISTS guardbans (name text, steamid varchar(32) not null, admin text, asteamid varchar(32) not null, reason text, time int not null, unban int not null);")
		print("[SQL Manager] Created table 'guardbans'")
	end
end

function sqlCheckGuardban(steamid)
	return sql.Query("SELECT steamid FROM guardbans WHERE steamid = '" .. steamid .. "';")
end
function sqlMakeGuardban(steamid, admin, time, reason)	
	local pname, psid = SQLStr(player.GetBySteamID(steamid) and player.GetBySteamID(steamid):Name() or "", true), steamid
	local breason = SQLStr(reason, true)
	local btime, bunban = time, os.time() + time * 60
	
	local aname, asid
	if (admin:IsPlayer()) then
		aname, asid = SQLStr(admin:Name(), true), admin:SteamID()
	else
		aname, asid = "(CONSOLE)", ""
	end
	
	sql.Query("INSERT INTO guardbans (name, steamid, admin, asteamid, reason, time, unban) VALUES ('" .. pname .. "', '" .. psid .. "', '" .. aname .. "', '" .. asid .. "', '" .. breason .. "', '" .. btime .. "', '" .. bunban .. "');")
	//GAMEMODE:Notify("You have banned " .. pname .. " from playing on the guard team for " .. btime .. " minutes (" .. breason .. ")")
end
function sqlRemoveGuardban(steamid)
	sql.Query("DELETE FROM guardbans WHERE steamid = '" .. steamid .. "';")
end