if SERVER then
	AddCSLuaFile()
	return
end

local padding = TFA.AttachmentUIPadding
local PANEL = {}

PANEL.Wep = nil
PANEL.Att = nil
PANEL.Header = nil
PANEL.TextTable = {}
PANEL.DefaultWidth = 0
PANEL.DefaultHeight = 0

function PANEL:SetWidthNeue( val )
	self.DefaultWidth = val
end

function PANEL:SetHeightNeue( val )
	self.DefaultHeight = val
end

function PANEL:Init()
	self.Wep = nil
	self.Att = nil
	self.Header = nil
	self.TextTable = {}
	self.DefaultHeight = 0
	self.DefaultWidth = 0
	self:SetMouseInputEnabled(false)
	self:SetZPos(0)
	self.SetWidthOld = self.SetWidthOld or self.SetWidth
	self.SetWidth = self.SetWidthNeue
	self.SetHeightOld = self.SetHeightOld or self.SetHeight
	self.SetHeight = self.SetHeightNeue
end

function PANEL:SetWeapon( wepv )
	if IsValid(wepv) then
		self.Wep = wepv
	end
end

function PANEL:SetAttachment( att )
	if att ~= nil then
		self.Att = att
		self:SetZPos( 200 - att )
	end
end

function PANEL:SetHeader( h )
	self.Header = h
end

function PANEL:SetTextTable( t )
	self.TextTable = t or {}
end


surface.CreateFont("TFAAttachmentTTHeader", {
	font = "Roboto Condensed", -- Use the font-name which is shown to you by your operating system Font Viewer, not the file name
	size = 20,
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false
})

surface.CreateFont("TFAAttachmentTTBody", {
	font = "Roboto Lt", -- Use the font-name which is shown to you by your operating system Font Viewer, not the file name
	size = 14,
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false
})

local headerfont = "TFAAttachmentTTHeader"
local bodyfont = "TFAAttachmentTTBody"

function PANEL:GetHeaderHeight( )
	if not IsValid(self.Wep) then return 0 end
	if not self.Header then return 0 end
	surface.SetFont(headerfont)
	local _, th = surface.GetTextSize( self.Header )
	return th + padding * 2
end

function PANEL:GetHeaderSize( )
	if not IsValid(self.Wep) then return 0, 0 end
	if not self.Header then return 0, 0 end
	surface.SetFont(headerfont)
	local tw, th = surface.GetTextSize( self.Header )
	return tw + padding * 2, th + padding * 2
end

function PANEL:GetTextTableHeight( )
	if not self.TextTable or #self.TextTable <= 0 then return 0 end
	local hv = padding
	surface.SetFont(bodyfont)
	for k,v in pairs(self.TextTable) do
		if type(v) == "string" then
			local _, th = surface.GetTextSize( v )
			hv = hv + th
		end
	end
	hv = hv + padding
	return hv
end

function PANEL:GetTextTableSize(  )
	if not self.TextTable or #self.TextTable <= 0 then return 0, 0 end
	local mw = 0
	local hv = padding
	surface.SetFont(bodyfont)
	for k,v in pairs(self.TextTable) do
		if type(v) == "string" then
			local tw, th = surface.GetTextSize( v )
			hv = hv + th
			mw = math.max( mw, tw )
		end
	end
	hv = hv + padding
	return mw + padding * 2, hv
end

function PANEL:DrawHeader( w, h )
	if not self.Header then return 0 end
	surface.SetFont(headerfont)
	local _, th = surface.GetTextSize( self.Header )
	draw.RoundedBox( 0, 0, 0, w, th + padding * 2, ColorAlpha( TFA.AttachmentColors["background"], self.Wep.InspectingProgress * 192 ) )
	if self.AnchoredH then
		draw.SimpleText( self.Header, headerfont, self:GetWide() / 2 , padding, ColorAlpha( TFA.AttachmentColors["primary"], self.Wep.InspectingProgress * 225 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP )
		--draw.RoundedBox( 0, w / 2 - tw / 2, padding + th + padding / 4, tw, padding / 2, ColorAlpha( TFA.AttachmentColors["primary"], self.Wep.InspectingProgress * 225 ) )

		--draw.SimpleText( self.Header, headerfont, self:GetWide() - padding, padding, ColorAlpha( TFA.AttachmentColors["primary"], self.Wep.InspectingProgress * 225 ), TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP )
		--draw.RoundedBox( 0, w - padding - tw, padding + th + padding / 4, tw, padding / 2, ColorAlpha( TFA.AttachmentColors["primary"], self.Wep.InspectingProgress * 225 ) )
	else
		draw.SimpleText( self.Header, headerfont, padding, padding, ColorAlpha( TFA.AttachmentColors["primary"], self.Wep.InspectingProgress * 225 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
		--draw.RoundedBox( 0, padding, padding + th + padding / 4, tw, padding / 2, ColorAlpha( TFA.AttachmentColors["primary"], self.Wep.InspectingProgress * 225 ) )
	end
	return th + padding * 2
end

function PANEL:DrawTextTable( x, y )
	if not self.TextTable then return 0 end
	--y = y + padding
	local hv = padding
	local acol = TFA.AttachmentColors["primary"]
	surface.SetFont(bodyfont)
	for k,v in pairs(self.TextTable) do
		if type(v) == "table" or type(v) == "vector" then
			if v.r then
				acol = Color( v.r or 0, v.g or 0, v.b or 0, v.a or 255 )
			elseif v.x then
				acol = Color( v.x or 0, v.y or 0, v.z or 0, v.a or 255 )
			end
		end
		if type(v) == "string" then
			local _, th = surface.GetTextSize( v )
			if self.AnchoredH then
				--draw.SimpleText( v, bodyfont, x + self:GetWide() - padding, y + hv, ColorAlpha( acol, self.Wep.InspectingProgress * 225 ), TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP )
				draw.SimpleText( v, bodyfont, x + padding * 2, y + hv, ColorAlpha( acol, self.Wep.InspectingProgress * 225 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
			else
				draw.SimpleText( v, bodyfont, x + padding * 2, y + hv, ColorAlpha( acol, self.Wep.InspectingProgress * 225 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
			end
			hv = hv + th
		end
	end
	hv = hv + padding
	return hv
end

function PANEL:CalcSize( )
	local header_w, header_h = self:GetHeaderSize()
	local text_w, text_h = self:GetTextTableSize()
	self:SetWidthOld( math.max( self.DefaultWidth, math.max( header_w, text_w ) + padding * 2 ))
	local h = header_h + text_h
	if text_h > 0 then
		h = h + padding * 2
	end
	self:SetHeightOld( h )
end

function PANEL:CalcPos()
	if IsValid(self.Anchor) then
		local x,y = self.Anchor:GetPos()
		y = y
		if self.Anchor:GetAnchoredH() then
			self.AnchoredH = true
			self:SetPos( x + self.Anchor:GetWide() - self:GetWide(), y + self.Anchor:GetTall() )
		else
			self.AnchoredH = false
			self:SetPos( x, y + self.Anchor:GetTall() )
		end
	end
end

function PANEL:Think()
	self:CalcSize()
	self:CalcPos()
end

function PANEL:Paint( w, h )
	if not IsValid(self.Wep) then return end
	if self.Att == nil then return end
	if ( self.Wep.InspectingProgress or 0 ) < 0.01 then self:Remove() end
	draw.RoundedBox( 0, 0, 0, w, h, ColorAlpha( TFA.AttachmentColors["background"], self.Wep.InspectingProgress * 192 ) )
	local hh = self:DrawHeader( w, h )
	self:DrawTextTable( 0, hh )
end

vgui.Register( "TFAAttachmentTip", PANEL, "Panel" )