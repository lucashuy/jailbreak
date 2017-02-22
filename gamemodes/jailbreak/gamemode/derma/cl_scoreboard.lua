surface.CreateFont("scoreLargeFont", {
	font = "Arial",
	size = 68,
	weight = 700,
	antialias = true,
})
surface.CreateFont("scoreMedFont", {
	font = "Arial",
	size = 30,
	weight = 600,
	antialias = true,
})
surface.CreateFont("scoreRegFont", {
	font = "Arial",
	size = 22,
	weight = 550,
	antialias = true,
})

local scoreB, titleLabel, guardPanel, prisonerPanel, sortedPlayers, guardList, prisonerList, menu

local function initScoreB()
	scoreB = vgui.Create("DFrame")
	scoreB:SetSize(ScrW() / 1.5, ScrH() * .7)
	scoreB:ShowCloseButton(false)
	scoreB:MakePopup()
	scoreB:SetKeyboardInputEnabled(false)
	scoreB:Center()
	scoreB:SetDraggable()
	scoreB:Center()
	scoreB:IsVisible(false)
	scoreB:SetTitle("")
	function scoreB:Paint(w, h)
		draw.RoundedBox(0, 0, 0, w, h, Color(255, 255, 255, 255 ))
		draw.RoundedBox(0, 0, 0, w, scoreB:GetTall() / 5, Color(0, 210, 255, 255))
	end
	function scoreB:Think()
		if (!self.update || self.update < CurTime()) then
			self.update = CurTime() + 2
			plySort()
			for k,v in pairs(guardList:GetCanvas():GetChildren()) do
				if (v.team == 3) then
					local swap = v
					prisonerList:AddItem(v)
				end
			end
			for a,d in pairs(guardList:GetCanvas():GetChildren()) do
				if (d.timeout != CurTime()) then
					d:Remove()
				end
			end
			for z,x in pairs(prisonerList:GetCanvas():GetChildren()) do
				if (x.timeout != CurTime()) then
					x:Remove()
				end
			end
		end
	end
	
	titleLabel = vgui.Create("DLabel", scoreB)
	titleLabel:SetPos(10, 2)
	titleLabel:SetFont("scoreLargeFont")
	titleLabel:SetText("Open Mint [Jailbreak]")
	titleLabel:SetTextColor(Color(0, 0, 0, 255))
	titleLabel:SizeToContents()
	
	/*
	mapLabel = vgui.Create("DLabel", scoreB)
	mapLabel:SetPos(5, scoreB:GetTall() / 6.8)
	mapLabel:SetFont("scoreMedFont")
	mapLabel:SetText("")
	mapLabel:SetText("We are playing on " .. game.GetMap() .. "!")
	mapLabel:SetTextColor(Color(0, 0, 0, 255))
	mapLabel:SizeToContents()
	*/
	
	guardPanel = vgui.Create("DPanel", scoreB)
	guardPanel:SetSize(scoreB:GetWide() / 2.07 , scoreB:GetTall() / 1.31)
	guardPanel:SetPos(12, scoreB:GetTall() / 4.6)
	function guardPanel:Paint(w, h)
		draw.RoundedBox(0, 0, 0, w, h, Color(200, 200, 200, 255))
	end
	guardList = vgui.Create("DScrollPanel", guardPanel)
	guardList:Dock(FILL)
	
	prisonerPanel = vgui.Create("DPanel", scoreB)
	prisonerPanel:SetSize(scoreB:GetWide() / 2.07, scoreB:GetTall() / 1.31)
	prisonerPanel:SetPos(scoreB:GetWide() / 1.96 - 4, scoreB:GetTall() / 4.6)
	function prisonerPanel:Paint(w, h)
		draw.RoundedBox(0, 0, 0, w, h, Color(200, 200, 200, 255))
	end
	prisonerList = vgui.Create("DScrollPanel", prisonerPanel)
	prisonerList:Dock(FILL)
end

//pls rework me
//i look terrible
//mostly stuff i can put into a function. too much using similar blocks of code

//this menu flickers at random moments, seems to start if they look at it for too long. lets hope they dont do that
function plySort()
	local tempPly = player.GetAll()

	local buttonFound = false	
	for k,v in pairs(tempPly) do
		if (v:Team() == 1 || v:Team() == 3) then
			for q,w in pairs(prisonerList:GetCanvas():GetChildren()) do
				if (w.ply == v && w.plyTeam == v:Team()) then
					buttonFound = true
					break
				end
			end
		elseif (v:Team() == 2 || v:Team() == 4) then
			for i,o in pairs(guardList:GetCanvas():GetChildren()) do
				if (o.ply == v && o.plyTeam == v:Team()) then
					buttonFound = true
					break
				end
			end
		end
		
		
		if (!buttonFound) then
			createButton(v)
		end
		
		buttonFound = false
	end
end

function createButton(ply)
	local pPlayer = vgui.Create("DPanel", ply:Team() == 1 and prisonerList or guardList)
	pPlayer:SetTall(50)
	pPlayer:Dock(TOP)
	pPlayer:DockMargin(0, 0, 0, 3)
	pPlayer.ply = ply
	pPlayer.team = ply:Team()
	pPlayer.timeout = CurTime()
	function pPlayer:Paint(w, h)
		//fine, ill take your stupid surface.Draw
		surface.SetDrawColor(team.GetColor(ply:Team()))
		surface.DrawRect(0, 0, w, h)
		//draw.RoundedBox(0, 0, 0, w, h, Color(team.GetColor(ply:Team())))
	end

	local aPlayer = vgui.Create("AvatarImage", pPlayer)
	aPlayer:SetPlayer(ply)
	aPlayer:SetSize(50, 50)
	function aPlayer:Paint(w, h)
		surface.SetDrawColor(team.GetColor(ply:Team()))
		surface.DrawRect(0, 0, w, h)
	end
	
	local bCheekyButton = aPlayer:Add("DButton")
	bCheekyButton:SetText("")
	bCheekyButton:Dock(FILL)
	function bCheekyButton:Paint(w, h) end
	function bCheekyButton:DoClick()
		if ( IsValid(pPlayer.ply) ) then //why did chessnut have so many IsValid checks. just use this one
			menu = DermaMenu()
			local steamID = menu:AddOption("Copy SteamID")
			steamID:SetImage("icon16/vcard.png")
			function steamID:DoClick()
				 local steamID = pPlayer.ply:SteamID()
				 chat.AddText(Color(20, 255, 5), "You have copied ", Color(145, 255, 130), steamID, Color(20, 255, 5), " to your clipboard.")
				 SetClipboardText(steamID)
			end
			
			local name = menu:AddOption("Copy Name", function()
				local name = pPlayer.ply:Name()
				chat.AddText(Color(20, 255, 5), "You have copied ", Color(145, 255, 130), name, Color(20, 255, 5), " to your clipboard.")
				SetClipboardText(name)
			end)
			name:SetImage("icon16/textfield_rename.png")
			
			local profile = menu:AddOption("Open Profile", function()
				pPlayer.ply:ShowProfile()
			end)
			profile:SetImage("icon16/world_go.png")

			if (pPlayer.ply != LocalPlayer()) then
				local icon = "icon16/sound_mute.png"
				local text = "Mute Voice"
				if (pPlayer.ply.jb_Muted) then
					icon = "icon16/sound_none.png"
					text = "Unmute Voice"
				end

				local voice = menu:AddOption(text, function()
					pPlayer.ply.jb_Muted = !pPlayer.ply.jb_Muted
					pPlayer.ply:SetMuted(pPlayer.ply.jb_Muted)
				end)

				voice:SetImage(icon)
			end

			menu:Open()
		end
	end
	
	local lName = vgui.Create("DLabel", pPlayer)
	lName:SetFont("scoreRegFont")
	lName:SetText(ply:Name())
	lName:SetTextColor(Color(0, 0, 0, 255))
	lName:SetPos(pPlayer:GetWide() - 12, pPlayer:GetTall() - 25)
	lName:SizeToContents()
	
	local lScore = vgui.Create("DLabel", pPlayer)
	lScore:SetFont("scoreRegFont")
	lScore:SetText(ply:Frags() .. " / " .. ply:Deaths())
	lScore:SetTextColor(Color(0, 0, 0, 255))
	lScore:SetPos(pPlayer:GetWide() - 12, 0)
	lScore:SizeToContents()
	
	if (team == 1) || (team == 3) then
		prisonerList:AddItem(pPlayer)
	elseif (team == 2) || (team == 4) then
		guardList:AddItem(pPlayer)
	end
end

function GM:ScoreboardShow()
	if (!IsValid(scoreB)) then
		initScoreB()
	else
		scoreB:Show()
	end
end

function GM:ScoreboardHide()
	if (IsValid(scoreB)) then
		if (IsValid(menu) && menu:IsVisible()) then
			menu:IsVisible(false)
		end
		scoreB:Hide()
	end
end