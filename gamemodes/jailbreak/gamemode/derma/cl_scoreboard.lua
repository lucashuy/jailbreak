--[[
	Created by Chessnut for the Chessnut's Corner community.
	http://chessnut.info
--]]

local PANEL = {};

local GRADIENT_UP = Material("vgui/gradient_up");
local GRADIENT_DOWN = Material("vgui/gradient_down");

surface.CreateFont("jb_ScoreboardHeader", {
	size = ScreenScale(24),
	weight = 800,
	antialias = true,
	font = "coolvetica"
} );

surface.CreateFont("jb_ScoreboardHeader2", {
	size = ScreenScale(9),
	weight = 800,
	antialias = true,
	font = "Tahoma"
} );

surface.CreateFont("jb_MediumText", {
	size = ScreenScale(9),
	weight = 700,
	antialias = true,
	font = "Tahoma"
} );

surface.CreateFont("jb_SmallText", {
	size = ScreenScale(7),
	weight = 400,
	antialias = true,
	font = "Tahoma"
} );

function PANEL:Init()
	self:SetSize(ScrW() * 0.45, ScrH() * 0.8);
	self:Center();

	self.header = self:Add("DPanel");
	self.header:DockMargin(2, 2, 2, 2);
	self.header:Dock(TOP);
	self.header:SetTall(ScrH() * 0.125);
	self.header.Paint = function(header, w, h)
		self:PaintHeader(w, h);
	end;

	self.title = self.header:Add("DLabel");
	self.title:DockPadding(5, 5, 5, 5);
	self.title:Dock(TOP);
	self.title:SetFont("jb_ScoreboardHeader");
	self.title:SetTextColor( Color(255, 255, 255, 255) );
	self.title:SetText("Jailbreak");
	self.title:SetExpensiveShadow(2, color_black);
	self.title:SetContentAlignment(5);
	self.title:SizeToContents();

	self.subTitle = self.header:Add("DLabel");
	self.subTitle:Dock(TOP);
	self.subTitle:DockMargin(5, 5, 5, 5);
	self.subTitle:SetFont("jb_ScoreboardHeader2");
	self.subTitle:SetTextColor( Color(255, 255, 255, 255) );
	self.subTitle:SetText("\66\121\32\67\104\101\115\115\110\117\116\32\45\32"..game.GetMap());
	self.subTitle:SetExpensiveShadow(2, color_black);
	self.subTitle:SetContentAlignment(5);
	self.subTitle:SizeToContents();

	self.list = self:Add("DScrollPanel");
	self.list:DockMargin(4, 1, 4, 4);
	self.list:Dock(FILL);
end;

function PANEL:Think()
	local sorted = player.GetAll();

	table.sort(sorted, function(a, b)
		return (a:Team() or 1) < (b:Team() or 2);
	end);

	for k, v in ipairs(sorted) do
		if ( !IsValid(v.jb_PlayerRow) ) then
			local row = vgui.Create("jb_PlayerRow", self);
			row:DockMargin(2, 2, 2, 2);
			row:SetPlayer(v);

			v.jb_PlayerRow = row;

			self.list:AddItem(row);
		end;
	end;
end;

function PANEL:Rebuild()
	for k, v in SortedPairs( player.GetAll() ) do
		if ( IsValid(v.jb_PlayerRow) ) then
			v.jb_PlayerRow:Remove();
		end;
	end;
end;

function PANEL:PaintHeader(w, h)
	surface.SetDrawColor(155, 155, 155, 75);
	surface.SetMaterial(GRADIENT_DOWN);
	surface.DrawTexturedRect(0, 0, w, h);

	surface.SetDrawColor(255, 255, 255, 5);
	surface.DrawRect(0, 0, w, h);
end;

function PANEL:Paint(w, h)
	surface.SetDrawColor(5, 5, 5, 250);
	surface.DrawRect(0, 0, w, h);

	surface.SetDrawColor(155, 155, 155, 25);
	surface.SetMaterial(GRADIENT_UP);
	surface.DrawTexturedRect(0, 0, w, h);

	surface.SetDrawColor(255, 255, 255, 30);
	surface.DrawOutlinedRect(0, 0, w, h);
end;

vgui.Register("jb_Scoreboard", PANEL, "DPanel");

local PANEL = {};

function PANEL:Init()
	self:Dock(TOP);
	self:SetTall(36);

	self.avatar = vgui.Create("AvatarImage", self);
	self.avatar:SetPos(2, 2);
	self.avatar:SetSize(32, 32);

	self.label = self:Add("DLabel");
	self.label:DockMargin(40, 4, 4, 4);
	self.label:SetFont("jb_MediumText");
	self.label:Dock(LEFT);
	self.label:SetContentAlignment(4);
	self.label:SetText("Loading");

	self.ping = self:Add("DLabel");
	self.ping:Dock(RIGHT);
	self.ping:DockMargin(0, 0, 8, 0);
	self.ping:SetFont("jb_SmallText");
	self.ping:SetContentAlignment(6);
	self.ping:SetWidth(72);

	self.deaths = self:Add("DLabel");
	self.deaths:Dock(RIGHT);
	self.deaths:SetText("0");
	self.deaths:DockMargin(0, 0, 8, 0);
	self.deaths:SetFont("jb_SmallText");
	self.deaths:SetContentAlignment(6);
	self.deaths:SetWidth(72);

	self.frags = self:Add("DLabel");
	self.frags:Dock(RIGHT);
	self.frags:SetText("0");
	self.frags:DockMargin(0, 0, 8, 0);
	self.frags:SetFont("jb_SmallText");
	self.frags:SetContentAlignment(6);
	self.frags:SetWidth(72);

	self.button = self.avatar:Add("DButton");
	self.button:Dock(FILL);
	self.button:SetText("");
	self.button:SetToolTip("Click to open a set of options.");
	self.button.Paint = function(button)
	end;

	self.button.DoClick = function(button)
		if ( IsValid(self.player) ) then
			local menu = DermaMenu();
			local steamID = menu:AddOption("Copy SteamID", function()
				if ( !IsValid(self.player) ) then
					return;
				end;

				local steamID = self.player:SteamID();

				chat.AddText(Color(20, 255, 5), "You have copied ", Color(145, 255, 130), steamID, Color(20, 255, 5), " to your clipboard.");

				SetClipboardText(steamID);
			end);
			steamID:SetImage("icon16/vcard.png")
			local name = menu:AddOption("Copy Name", function()
				if ( !IsValid(self.player) ) then
					return;
				end;
				
				local name = self.player:Name();

				chat.AddText(Color(20, 255, 5), "You have copied ", Color(145, 255, 130), name, Color(20, 255, 5), " to your clipboard.");

				SetClipboardText(name);
			end);
			name:SetImage("icon16/textfield_rename.png");
			local profile = menu:AddOption("Open Profile", function()
				if ( !IsValid(self.player) ) then
					return;
				end;
				
				self.player:ShowProfile();
			end);
			profile:SetImage("icon16/world_go.png");

			if (LocalPlayer() != self.player) then
				local icon = "icon16/sound_mute.png";
				local text = "Mute Voice";

				if (self.player.jb_Muted) then
					icon = "icon16/sound_none.png";
					text = "Unmute Voice";
				end;

				local voice = menu:AddOption(text, function()
					if ( !IsValid(self.player) ) then
						return;
					end;
					
					self.player.jb_Muted = !self.player.jb_Muted;
					self.player:SetMuted(self.player.jb_Muted);
				end);

				voice:SetImage(icon);
			end;

			menu:Open(nil, nil, false, self);
		end;
	end;
end;

function PANEL:Think()
	if (self.setup) then
		if ( IsValid(self.player) ) then
			self.label:SetText( self.player:Name() );
			self.label:SizeToContents();

			local fraction = math.Clamp(self.player:Ping() / 300, 0, 1);

			self.ping:SetText( self.player:Ping() );
			self.ping:SetTextColor( Color(255 * fraction, 255 - (fraction * 255), 0) );

			self.deaths:SetText( self.player:Deaths() );
			self.frags:SetText( self.player:Frags() );
		else
			GAMEMODE.scoreboard:Rebuild();

			self:Remove();
		end;
	end;
end;

function PANEL:Paint(w, h)
	surface.SetDrawColor(30, 30, 30, 250);
	surface.DrawRect(0, 0, w, h);

	local color = Color(155, 155, 155, 50);

	if ( IsValid(self.player) ) then
		color = team.GetColor( self.player:Team() );
		color.a = 95;

		if (LocalPlayer() == self.player) then
			surface.SetDrawColor(255, 255, 255, math.cos(RealTime() * 2) * 5);
			surface.DrawRect(0, 0, w, h);
		end;
	end;

	surface.SetDrawColor(color);
	surface.SetMaterial(GRADIENT_DOWN);
	surface.DrawTexturedRect(0, 0, w, h);

	surface.SetDrawColor(255, 255, 255, 10);
	surface.DrawOutlinedRect(0, 0, w, h);
end;

function PANEL:SetPlayer(client)
	self.player = client;

	self.label:SetText( client:Name() );
	self.label:SizeToContents();

	self.avatar:SetPlayer(client);

	self.setup = true;
end;

vgui.Register("jb_PlayerRow", PANEL, "DPanel");

function GM:ScoreboardShow()
	if ( !IsValid(self.scoreboard) ) then
		self.scoreboard = vgui.Create("jb_Scoreboard");
		self.scoreboard:MakePopup();
	else
		self.scoreboard:Show();
	end;
end;

function GM:ScoreboardHide()
	if ( IsValid(self.scoreboard) ) then
		self.scoreboard:Hide();
	end;
end;	