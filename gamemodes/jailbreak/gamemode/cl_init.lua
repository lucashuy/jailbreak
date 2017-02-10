include("shared.lua")
include("cl_hooks.lua")

for k, v in pairs( file.Find(GM.FolderName.."/gamemode/derma/*.lua", "LUA") ) do
	include("derma/"..v)
end