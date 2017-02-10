--[[
	Created by Chessnut for the Chessnut's Corner community.
	http://chessnut.info
--]]

local PANEL = {};

JB_VOTE_DATA = JB_VOTE_DATA or {};

function PANEL:Init()
	self:SetSize(ScrW() * 0.15, ScrH() * 0.225);
	self:SetTitle("Vote");
	self:ShowCloseButton(false);

	self.scroll = self:Add("DScrollPanel");
	self.scroll:Dock(FILL);

	self:Center();
	self:MakePopup();
end;

vgui.Register("jb_Vote", PANEL, "DFrame");

function GM:AddVote(time, question, answers, Callback, layout)
	local vote = vgui.Create("jb_Vote");
	vote:SetTitle("Vote - "..question);

	timer.Simple(time, function()
		if ( IsValid(vote) ) then
			vote:Remove();
		end;
	end);

	for k, v in RandomPairs(answers) do
		local choice = vote.scroll:Add("DButton");
		choice:Dock(TOP);
		choice:DockPadding(2, 2, 2, 2);
		choice:SetText(v);
		choice.index = k;

		if (layout) then
			layout(vote, choice);
		end;

		choice.DoClick = function(button)
			if (Callback) then
				Callback(vote, choice, k);
			end;

			vote:Remove();
		end;
	end;
end;

net.Receive("jb_WardenVote", function(length)
	local data = net.ReadTable();
	local answers = {};

	for k, v in RandomPairs(data) do
		answers[ k:EntIndex() ] = k:Name();
	end;

	GAMEMODE:AddVote(10, "Select a warden", answers, function(vote, choice, index)
		net.Start("jb_WardenChoice");
			net.WriteUInt(index, 8);
		net.SendToServer();
	end, function(vote, choice)
		choice:SetTall(20);

		local client = player.GetByID(choice.index);

		if ( IsValid(client) ) then
			local avatar = vgui.Create("AvatarImage", choice);
			avatar:SetSize(16, 16);
			avatar:SetPos(2, 2);
			avatar:SetPlayer(client, 16);
		end;
	end);
end);