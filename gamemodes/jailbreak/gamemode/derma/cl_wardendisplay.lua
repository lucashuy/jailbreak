--[[
	Created by Chessnut for the Chessnut's Corner community.
	http://chessnut.info
--]]

local PANEL = {};

local GRADIENT_UP = Material("vgui/gradient_up");
local GRADIENT_DOWN = Material("vgui/gradient_down");
local GRADIENT_CENTER = Material("vgui/gradient-l");

function PANEL:Init()
	self:SetSize(240, 40);
	self:SetPos(4, 4);

	self.avatar = vgui.Create("AvatarImage", self);
	self.avatar:SetPos(4, 4);
	self.avatar:SetSize(32, 32);

	self.label = vgui.Create("DLabel", self);
	self.label:SetPos(40, 14);
	self.label:SetText("Currently no warden. Free day!");
	self.label:SizeToContents();
end;

function PANEL:Paint(w, h)
	surface.SetDrawColor(25, 25, 25, 250);
	surface.DrawRect(0, 0, w, h);

	surface.SetDrawColor(100, 100, 100, 120);
	surface.DrawOutlinedRect(0, 0, w, h);

	surface.SetMaterial(GRADIENT_DOWN);
	surface.DrawTexturedRect(0, 0, w, h);

	surface.SetDrawColor(10, 10, 10, 80);
	surface.DrawOutlinedRect(1, 1, w - 2, h - 2);
end;

function PANEL:Think()
	local warden = GAMEMODE:GetGlobalVar("warden");

	if ( IsValid(warden) ) then
		if (warden:Team() == TEAM_GUARD) then
			if (self.warden != warden) then
				self.avatar:SetPlayer(warden, 32);
				self.warden = warden;
			end;

			self.label:SetText( warden:Name().." is the warden" );
			self.label:SizeToContents();
		elseif (warden:Team() == TEAM_GUARD_DEAD) then
			self.label:SetText("Free day! The warden has died");
			self.label:SizeToContents();
		end;
	else
		self.label:SetText("Currently no warden. Free day!");
		self.label:SizeToContents();
	end;

	surface.SetFont("DermaDefault");

	local w = surface.GetTextSize( self.label:GetText() ) + 44;

	self:SetWide( math.max(w, 180) );
end;

vgui.Register("jb_WardenDisplay", PANEL, "DPanel");

if ( IsValid(JB_WARDEN_DISPLAY) ) then
	JB_WARDEN_DISPLAY:Remove();
end;

JB_WARDEN_DISPLAY = vgui.Create("jb_WardenDisplay");