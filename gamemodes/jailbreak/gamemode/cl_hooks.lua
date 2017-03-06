local math = math
local team = team
local draw = draw
local surface = surface
local halo = halo
local cam = cam

surface.CreateFont("jb_TargetFont", {
	font = "Tahoma",
	size = ScreenScale(9),
	weight = 700,
	antialias = true
} )

surface.CreateFont("jb_MedFont", {
	font = "Tahoma",
	size = ScreenScale(6),
	weight = 700,
	antialias = true
} )

surface.CreateFont("jb_BigFont", {
	font = "Tahoma",
	size = ScreenScale(9),
	weight = 700,
	antialias = true
} )

surface.CreateFont("jb_HugeFont", {
	font = "Tahoma",
	size = ScreenScale(10),
	weight = 800,
	antialias = true
} )

local DEATH_ALPHA = 0

function GM:HUDPaint()
	local trace = LocalPlayer():GetEyeTraceNoCursor()
	local entity = trace.Entity

	if ( IsValid(entity) ) then
		self:HUDPaintTarget(entity)
	end

	self:DrawHUD()

	local waypoint = self:GetGlobalVar("waypoint")

	if (waypoint and waypoint.x and waypoint.y and waypoint.z) then
		local position = ( waypoint + Vector(0, 0, 18) ):ToScreen()
		local distance = LocalPlayer():GetPos():Distance(waypoint)
		local alpha = (distance / 16) * 5
		local delta = math.cos(RealTime() * 3) * 255

		draw.SimpleText("Over Here!", "jb_HugeFont", position.x + 1, position.y + 1, Color(0, 0, 0, alpha), 1, 1)
		draw.SimpleText("Over Here!", "jb_HugeFont", position.x, position.y, Color(255, delta, delta, alpha), 1, 1)
	end

	local victim, killer = self:GetGlobalVar("victim"), self:GetGlobalVar("killer")
	local phrase = self:GetGlobalVar("kill_phrase")
	local alpha = 0

	if (IsValid(victim) and victim:IsPlayer() and IsValid(killer) and killer:IsPlayer() and phrase and phrase != "") then
		alpha = 255

		local victimName = victim:Name()
		local killerName = killer:Name()
		local ease = math.EaseInOut(DEATH_ALPHA / 255, 1, 2)

		draw.SimpleText(victimName.." "..phrase.." "..killerName, "jb_HugeFont", ScrW() / 2 + 1, (ScrH() / 3) * ease + 1, Color(1, 1, 1, DEATH_ALPHA), 1, 1)
		draw.SimpleText(victimName.." "..phrase.." "..killerName, "jb_HugeFont", ScrW() / 2, (ScrH() / 3) * ease, Color(255, 255, 255, DEATH_ALPHA), 1, 1)
	end

	DEATH_ALPHA = math.Approach(DEATH_ALPHA, alpha, FrameTime() * 150)
end

function GM:RenderScreenspaceEffects()
	self.BaseClass:RenderScreenspaceEffects()

	local slowEnd = self:GetGlobalVar("slow", 0)
	local killer = self:GetGlobalVar("killer")
	local slowStart = slowEnd - 3.8

	if ( slowEnd > CurTime() and slowStart <= CurTime() ) then
		local r, g, b = 0, 0, 0
		local fraction = math.TimeFraction( slowStart, slowEnd, CurTime() )

		if ( IsValid(killer) and killer:IsPlayer() ) then
			local color = team.GetColor( killer:Team() )

			r, g, b = color.r, color.g, color.b
		end

		if (fraction > 0) then
			local fraction2 = 1 - fraction
			local color = {}
			color["$pp_colour_addr" ] = (r * fraction2) / 275
			color["$pp_colour_addg" ] = (g * fraction2) / 275
			color["$pp_colour_addb" ] = (b * fraction2) / 275
			color["$pp_colour_brightness" ] = 0
			color["$pp_colour_contrast" ] = 1
			color["$pp_colour_colour" ] = fraction
			color["$pp_colour_mulr" ] = 0
			color["$pp_colour_mulg" ] = 0
			color["$pp_colour_mulb" ] = 0

			DrawColorModify(color)
			DrawMotionBlur((1 - fraction) / 2, 0.4, 0.01)
		end
	end
end

local WAYPOINT_RING = Material("chessnut/jailbreak/ring.png")
local WAYPOINT_ARROW = Material("chessnut/jailbreak/arrow.png")

function GM:PostDrawTranslucentRenderables()
	local waypoint = self:GetGlobalVar("waypoint")

	if (waypoint and waypoint.x and waypoint.y and waypoint.z) then
		local data = {}
			data.start = waypoint
			data.endpos = waypoint - Vector(0, 0, 128)
			data.mask = MASK_NPCWORLDSTATIC
		local trace = util.TraceLine(data)

		local eyeAngles = LocalPlayer():EyeAngles()
		local angles = Angle(0, eyeAngles.y + 270, 90)
		local expire = self:GetGlobalVar("waypoint_expire")
		local start = expire - 30
		local alpha = 1 - math.TimeFraction( start, expire, CurTime() )
		local color = Color(255, 255, 255, 255 * alpha)

		surface.SetDrawColor(color)

		cam.Start3D2D(trace.HitPos + Vector(0, 0, 0.1), Angle(0, 0, 0), 0.15 + math.sin(RealTime()*5)*0.01)
			surface.SetMaterial(WAYPOINT_RING)
			surface.DrawTexturedRect(-256, -256, 512, 512)
		cam.End3D2D()

		cam.Start3D2D(trace.HitPos + Vector(0, 0, 10 + math.cos(RealTime()*2)*2), angles, 0.175)
			surface.SetMaterial(WAYPOINT_ARROW)
			surface.DrawTexturedRect(-64, -256, 128, 256)
		cam.End3D2D()
	end
end

local GRADIENT = Material("vgui/gradient-r")
local GRADIENT_UP = Material("vgui/gradient-u")
local GRADIENT_DOWN = Material("vgui/gradient-d")

function GM:DrawScore(teamID)
	local winning = false
	local score = team.GetScore(teamID)

	if ( teamID == TEAM_GUARD and score > team.GetScore(TEAM_PRISONER) ) then
		winning = true
	elseif ( teamID == TEAM_PRISONER and score > team.GetScore(TEAM_GUARD) ) then
		winning = true
	end

	local color = team.GetColor(teamID)
	local w, h = ScrW() * 0.125, ScrH() * 0.05
	local x, y = ScrW() - w, h*(teamID - 1) + 8*teamID

	if (winning) then
		local glow = math.cos(RealTime() * 2) * 80

		color.r = color.r + glow
		color.g = color.g + glow
		color.b = color.b + glow
	end

	surface.SetDrawColor(color.r - 50, color.g - 50, color.b - 50, 230)
	surface.SetMaterial(GRADIENT)
	surface.DrawTexturedRect(x, y, w, h)

	local number = team.NumPlayers(teamID)
	local suffix = "s"

	if (number == 1) then
		suffix = ""
	end

	local players = number.." Player"..suffix.." - "

	draw.SimpleText(players..score, "jb_HugeFont", ScrW() - 6, y + h/2 + 2, color_black, 2, 1)
	draw.SimpleText(players..score, "jb_HugeFont", ScrW() - 8, y + h/2, color_white, 2, 1)
end

local deltaPos = vector_origin
local deltaMiss = 0

function GM:DrawCrosshair()
	local trace = LocalPlayer():GetEyeTraceNoCursor().HitPos or vector_origin
	deltaPos = LerpVector(0.5, deltaPos, trace)

	local screen = deltaPos:ToScreen()
	local x, y = screen.x, screen.y - 18
	local length = LocalPlayer():GetVelocity():Length2D()
	local spacing = math.min(6 + (length / 24), 64)
	local distance = 16
	local distance2 = distance / -0.525
	local weapon = LocalPlayer():GetActiveWeapon()

	if (IsValid(weapon) and weapon.GetMiss and weapon:GetMiss() > 0) then
		deltaMiss = math.Approach(deltaMiss, weapon:GetMiss() * 18, FrameTime() * 30)

		spacing = math.min(spacing + deltaMiss, 64)
	end

	surface.SetDrawColor(255, 255, 255, 100)
	surface.DrawLine(x, (y + distance+4) - spacing, x, y - spacing - 2)
	surface.DrawLine(x - spacing, (y + distance) + spacing, (x - spacing) - distance, (y - distance2) + spacing)
	surface.DrawLine(x + spacing, (y + distance) + spacing, (x + spacing) + distance, (y - distance2) + spacing)
end

function GM:HUDShouldDraw(element)
	if (element == "CHudHealth" or element == "CHudBattery" or element == "CHudCrosshair") then
		return false
	end

	return true
end

function GM:HUDPaintTarget(entity, distance)
	if ( entity:IsPlayer() ) then
		local color = team.GetColor( entity:Team() )
		local name = entity:Name()
		local worldPosition = entity:LocalToWorld( entity:OBBCenter() ) + Vector(0, 0, 48)
		local position = worldPosition:ToScreen()
		
		draw.SimpleText(name, "jb_TargetFont", position.x + 1, position.y + 1, Color(0, 0, 0, 255), 1, 1)
		draw.SimpleText(name, "jb_TargetFont", position.x, position.y, Color(color.r, color.g, color.b, 255), 1, 1)
	end
end

function GM:DrawBar(x, y, w, h, color, percentage, material, text)
	if (percentage == 0) then
		return y
	end

	if (!color) then
		color = Color(125, 125, 125)
	end

	surface.SetDrawColor(255, 255, 255, 150)
	surface.SetMaterial(GRADIENT_DOWN)
	surface.DrawTexturedRect(h + x, y, w - h, h)

	surface.SetDrawColor(0, 0, 0, 225)
	surface.DrawRect(h + x, y, w - h, h)

	surface.SetDrawColor(color.r, color.g, color.b, 255)
	surface.DrawRect(h + x, y, (w - h) * percentage, h)

	surface.SetDrawColor(25, 25, 25, 150)
	surface.SetMaterial(GRADIENT_UP)
	surface.DrawTexturedRect(h + x, y, (w - h) * percentage, h)

	surface.SetDrawColor(color.r, color.g, color.b, 255)
	surface.DrawRect(x, y, h, h)

	surface.SetMaterial(GRADIENT_DOWN)
	surface.DrawTexturedRect(x, y, h, h)

	surface.SetDrawColor(255, 255, 255, 255)
	surface.SetMaterial(material)
	surface.DrawTexturedRect(x + 5, y + 5, 16, 16)

	surface.SetDrawColor(255, 255, 255, 20)
	surface.DrawOutlinedRect(x, y, w, h)

	surface.SetDrawColor(5, 5, 5, 50)
	surface.DrawOutlinedRect(x + 1, y + 1, w - 2, h - 2)

	if (text) then
		draw.SimpleText(text, "DermaDefault", x + h + 9, y + (h / 2) + 1, color_black, 0, 1)
		draw.SimpleText(text, "DermaDefault", x + h + 8, y + (h / 2), color_white, 0, 1)
	end

	return y - h - 4
end

local HEALTH = Material("icon16/heart.png")
local ARMOR = Material("icon16/shield.png")
local TIME = Material("icon16/time.png")

local deltaHealth = 0
local deltaArmor = 0

function GM:DrawHUD()
	local width, height = ScrW() * 0.225, ScrH() * 0.03
	local client = LocalPlayer()
	local target = client:GetObserverTarget()

	if (IsValid(target) and target:IsPlayer() and target.Health and target.Armor) then
		client = target
	end

	deltaHealth = math.Approach(deltaHealth, client:Health(), FrameTime() * 100)
	deltaArmor = math.Approach(deltaArmor, client:Armor(), FrameTime() * 100)

	local start = self:GetGlobalVar("round_start")
	local y = ScrH() - (height + 4)

	y = self:DrawBar( 4, y, width, height, Color(22, 90, 255), math.Clamp(deltaArmor / 100, 0, 1), ARMOR, math.ceil(deltaArmor) )
	y = self:DrawBar( 4, y, width, height, Color(255, 80, 70), math.Clamp(deltaHealth / 100, 0, 1), HEALTH, math.ceil(deltaHealth) )

	if (start) then
		local timeFraction = ( start - CurTime() ) / self.RoundTime
		local formatted = string.FormattedTime(start - CurTime(), "%02i:%02i")

		if (timeFraction > 0) then
			y = self:DrawBar(4, y, width, height, Color(170, 200, 250), timeFraction, TIME, formatted)
		end
	end
end

function GM:PreDrawHalos()
	self.BaseClass:PreDrawHalos()

	if (team.NumPlayers(TEAM_GUARD) > 0 and team.NumPlayers(TEAM_PRISONER) > 0) then
		local teamID = LocalPlayer():Team()

		if (teamID == TEAM_PRISONER_DEAD or teamID == TEAM_GUARD_DEAD) then
			local prisoners = team.GetPlayers(TEAM_PRISONER)
			local guards = team.GetPlayers(TEAM_GUARD)
			local prisonerColor = team.GetColor(TEAM_PRISONER)
			local guardColor = team.GetColor(TEAM_GUARD)

			halo.Add(prisoners, prisonerColor, 1, 1, 1, true, true)
			halo.Add(guards, guardColor, 1, 1, 1, true, true)
		end
	end
end

local DELTA_SPEED = 0

function GM:CalcView(client, origin, angles, fov)
	local view = self.BaseClass:CalcView(client, origin, angles, fov)

	if (client:GetObserverMode() != OBS_MODE_NONE) then
		return view
	end

	local velocity = client:GetVelocity()
	local eyeAngles = client:EyeAngles()
	local speed = eyeAngles:Forward():DotProduct(velocity) * 0.01
	local strafe = eyeAngles:Right():DotProduct(velocity) * 0.01

	DELTA_SPEED = math.Approach(DELTA_SPEED, speed, 0.005)

	view.angles = view.angles + Angle(speed * 0.6, strafe * -1.2, strafe*0.7)*0.5
	view.fov = view.fov + speed

	if (view.vm_angles) then
		local length = velocity:Length2D()
		local speed = 2
		local value = 0.08

		if (length >= client:GetWalkSpeed() - 5) then
			speed = 11.5
			value = 1.4
		end
		
		local translation = -1.8
		local weapon = LocalPlayer():GetActiveWeapon()

		if (IsValid(weapon) and weapon.ViewTranslation) then
			translation = weapon.ViewTranslation
		end

		view.vm_angles = view.vm_angles + Angle(math.cos(RealTime() * speed) * value + translation, strafe * -3, strafe * 2)*scale + Angle(-2 + scale*2, 0, 0)
	end

	return view
end

function GM:OnSpawnMenuOpen()
	RunConsoleCommand("jb_dropweapon")
end

function GM:Notify(message)
	chat.AddText(Color(40, 155, 255), "[Open Mint] ", Color(255, 255, 255), message)
	
	surface.PlaySound("buttons/button16.wav")
end

local TEAM_DISTANCE = 64


function GM:Think()
	local teamID = LocalPlayer():Team()
	local players = team.GetPlayers(teamID)

	if (teamID == TEAM_GUARD_DEAD or teamID == TEAM_PRISONER_DEAD || teamID == TEAM_SPECTATOR) then
		players = player.GetAll()
	end

	for k, v in pairs(players) do
		local distance = LocalPlayer():GetPos():Distance( v:GetPos() )
		local fraction = distance / TEAM_DISTANCE
		local color = v:GetColor()
		local alpha = math.max(fraction * 255, 25)

		v:SetRenderMode(4)
		v:SetColor( Color(color.r, color.g, color.b, alpha) )
	end
end


net.Receive("jb_Notice", function(length)
	local message = net.ReadString()

	GAMEMODE:Notify(message)
end)

net.Receive("jb_Admin", function(length)
	local message = net.ReadString()

	MsgC(Color(255, 125, 50), message.."\n")
end)