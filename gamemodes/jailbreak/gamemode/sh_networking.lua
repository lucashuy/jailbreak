AddCSLuaFile()

local entityMeta = FindMetaTable("Entity")

if (SERVER) then
	GM.globalVars = GM.globalVars or {}
	GM.netEntities = GM.netEntities or {}

	util.AddNetworkString("td_PrivateData")
	util.AddNetworkString("td_PublicData")
	util.AddNetworkString("td_GlobalVar")

	function entityMeta:SetPrivateData(key, value)
		if ( self:IsPlayer() ) then
			if (!self.td_PrivateData) then
				self.td_PrivateData = {}
			end

			self.td_PrivateData[key] = value

			net.Start("td_PrivateData")
				net.WriteString(key)
				net.WriteType(value)
			net.Send(self)
		end
	end

	function entityMeta:SetPublicData(key, value)
		if ( !GAMEMODE.netEntities[self] ) then
			GAMEMODE.netEntities[self] = {}
		end

		GAMEMODE.netEntities[self][key] = value
		
		net.Start("td_PublicData")
			net.WriteUInt(self:EntIndex(), 16)
			net.WriteString(key)
			net.WriteType(value)
		net.Broadcast()
	end

	function GM:SetGlobalVar(key, value)
		self.globalVars[key] = value

		net.Start("td_GlobalVar")
			net.WriteString(key)
			net.WriteType(value)
		net.Broadcast()
	end

	function GM:SendGlobalVars(client)
		for key, value in pairs(self.globalVars) do
			net.Start("td_GlobalVar")
				net.WriteString(key)
				net.WriteType(value)
			net.Send(client)
		end

		for k, v in pairs(self.netEntities) do
			if ( IsValid(k) ) then
				for key, value in pairs(v) do
					net.Start("td_PublicData")
						net.WriteUInt(k:EntIndex(), 16)
						net.WriteString(key)
						net.WriteType(value)
					net.Send(client)
				end
			end
		end
	end
else
	GM.networking = GM.networking or {}
	GM.networking.public = GM.networking.public or {}
	GM.networking.private = GM.networking.private or {}
	GM.globalVars = GM.globalVars or {}

	net.Receive("td_PrivateData", function(length)
		local key = net.ReadString()
		local info = net.ReadUInt(8)
		local value = net.ReadType(info)

		GAMEMODE.networking.private[key] = value
	end)

	net.Receive("td_PublicData", function(length)
		local index = net.ReadUInt(16)
		local key = net.ReadString()
		local info = net.ReadUInt(8)
		local value = net.ReadType(info)

		if ( !GAMEMODE.networking.public[index] ) then
			GAMEMODE.networking.public[index] = {}
		end

		GAMEMODE.networking.public[index][key] = value
	end)

	net.Receive("td_GlobalVar", function(length)
		local key = net.ReadString()
		local info = net.ReadUInt(8)
		local value = net.ReadType(info)

		GAMEMODE.globalVars[key] = value
	end)
end

function entityMeta:GetPrivateData(key, default)
	if ( self:IsPlayer() ) then
		if (SERVER) then
			if (self.td_PrivateData) then
				return self.td_PrivateData[key] or default
			end
		else
			return GAMEMODE.networking.private[key] or default
		end

		return default
	end
end

function entityMeta:GetPublicData(key, default)
	if (SERVER) then
		local entityTable = GAMEMODE.netEntities[self]

		if (entityTable) then
			return entityTable[key] or default
		end
	else
		local index = self:EntIndex()

		if ( !GAMEMODE.networking.public[index] ) then
			GAMEMODE.networking.public[index] = {}
		end

		return GAMEMODE.networking.public[index][key] or default
	end

	return default
end

function GM:GetGlobalVar(key, default)
	return self.globalVars[key] or default
end