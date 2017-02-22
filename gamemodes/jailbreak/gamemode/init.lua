include("shared.lua")
include("sv_warden.lua")
include("sv_rounds.lua")
include("sv_hooks.lua")
include("sv_sqlmanager.lua")

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_hooks.lua")

util.AddNetworkString("jb_showMenu")
util.AddNetworkString("jb_Notice")
util.AddNetworkString("jb_Admin")
util.AddNetworkString("jb_switchTeams")
util.AddNetworkString("jb_openGun")
util.AddNetworkString("jb_receieveGun")
util.AddNetworkString("jb_optWarden")

resource.AddFile("materials/chessnut/jailbreak/ring.png")
resource.AddFile("materials/chessnut/jailbreak/arrow.png")
resource.AddFile("models/weapons/v_fists.mdl")
resource.AddFile("models/weapons/w_fists.mdl")

//tfa's base
resource.AddWorkshop("415143062")
//tfa's css weapons
resource.AddWorkshop("481133630")

for k, v in pairs( file.Find(GM.FolderName.."/gamemode/derma/*.lua", "LUA") ) do
	AddCSLuaFile("derma/"..v)
end

for k, v in pairs( file.Find(GM.FolderName.."/gamemode/mapconfigs/*.lua", "LUA") ) do
	if (v == (game.GetMap() .. ".lua")) then
		include("mapconfigs/" .. v)
		break
	end
end

JB_SWAP_GUARD = JB_SWAP_GUARD or {}
JB_SWAP_PRISONER = JB_SWAP_PRISONER or {}