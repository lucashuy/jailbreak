include("sh_networking.lua")
include("sh_spectate.lua")
include("player_class/player_jb.lua")

GM.Name = "Jailbreak"
GM.Author = "Chessnut"
GM.TeamBased = true
//GM.NumRounds = 999999999999

GM.RoundTime = 60 * 8
GM.GuardRatio = 0.6//default 0.5
GM.InitialStart = false

//thanks google
function GM:CreateTeams()
	TEAM_PRISONER = 1
	TEAM_GUARD = 2
	TEAM_PRISONER_DEAD = 3
	TEAM_GUARD_DEAD = 4
	
	team.SetUp( TEAM_GUARD, "Guards", Color(40, 40, 255) )
	team.SetSpawnPoint(TEAM_GUARD, "info_player_counterterrorist")
	team.SetUp( TEAM_GUARD_DEAD, "Dead Guards", Color(0, 0, 170) )
	team.SetSpawnPoint(TEAM_GUARD_DEAD, "info_player_counterterrorist")

	team.SetUp( TEAM_PRISONER, "Prisoners", Color(255, 40, 40) )
	team.SetSpawnPoint(TEAM_PRISONER, "info_player_terrorist")
	team.SetUp( TEAM_PRISONER_DEAD, "Dead Prisoners", Color(170, 0, 0) )
	team.SetSpawnPoint(TEAM_PRISONER_DEAD, "info_player_terrorist")
end

GM:CreateTeams()

function GM:PlayerCanBeGuard()
	if (#player.GetAll() == 1) then
		return true
	end
	
	local guards = team.NumPlayers(TEAM_GUARD) + team.NumPlayers(TEAM_GUARD_DEAD)
	local prisoners = team.NumPlayers(TEAM_PRISONER) + team.NumPlayers(TEAM_PRISONER_DEAD)
	local amount = math.Round(prisoners * self.GuardRatio)

	if (guards >= amount) then
		return false, guards - amount
	end

	return true
end

GM.GuardModels = {
	Model("models/player/police.mdl"),
	Model("models/player/combine_soldier.mdl"),
	Model("models/player/combine_soldier_prisonguard.mdl")
}

GM.PrisonerModels = {
	Model("models/player/Group01/male_09.mdl"),
	Model("models/player/Group01/male_08.mdl"),
	Model("models/player/Group01/male_07.mdl"),
	Model("models/player/Group01/male_06.mdl"),
	Model("models/player/Group01/male_05.mdl"),
	Model("models/player/Group01/male_04.mdl"),
	Model("models/player/Group01/male_03.mdl"),
	Model("models/player/Group01/male_02.mdl"),
	Model("models/player/Group01/male_01.mdl")
}

GM.WardenModel = Model("models/player/combine_super_soldier.mdl")