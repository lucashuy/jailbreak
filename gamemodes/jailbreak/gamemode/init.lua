include("shared.lua")
include("sv_warden.lua")
include("sv_rounds.lua")
include("sv_hooks.lua")

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_hooks.lua")

util.AddNetworkString("jb_showMenu")
util.AddNetworkString("jb_Notice")
util.AddNetworkString("jb_Admin")

resource.AddFile("materials/chessnut/jailbreak/ring.png")
resource.AddFile("materials/chessnut/jailbreak/arrow.png")
resource.AddFile("models/weapons/v_fists.mdl")
resource.AddFile("models/weapons/w_fists.mdl")

/*
resource.AddWorkshop( "108720350" )
resource.AddWorkshop( "356485444" )
resource.AddWorkshop( "552340348" )
resource.AddWorkshop( "180507408" )
resource.AddWorkshop( "181283903" )
resource.AddWorkshop( "181656972" )
*/
resource.AddWorkshop("415143062")

for k, v in pairs( file.Find(GM.FolderName.."/gamemode/derma/*.lua", "LUA") ) do
	AddCSLuaFile("derma/"..v)
end

JB_SWAP_GUARD = JB_SWAP_GUARD or {}
JB_SWAP_PRISONER = JB_SWAP_PRISONER or {}