surface.CreateFont("navButtonFont", {
	font = "Arial",
	size = 30,
	weight = 750,
	antialias = true,
})
surface.CreateFont("regTextFont", {
	font = "Arial",
	size = 25,
	weight = 550,
	antialias = true,
})

local mainFrame
local activeTab = 0

local function initializeMenu()
	//WE ARE HACKING THE MAINFRAME
	mainFrame = mainFrame or vgui.Create("DFrame")
	mainFrame:SetSize(700, 500)
	mainFrame:Center()
	mainFrame:SetVisible(false)
	mainFrame:SetDraggable(false)
	mainFrame:ShowCloseButton(false)
	mainFrame:MakePopup(true)
	mainFrame:SetTitle("")
	function mainFrame:Paint(w, h)
		draw.RoundedBox(0, 0, 0, w, h, Color(255, 255, 255, 50))
	end
	
	//panels
	local teamsPanel = vgui.Create("DPanel", mainFrame)
	teamsPanel:SetPos(0, 50)
	teamsPanel:SetSize(mainFrame:GetWide(), mainFrame:GetTall() - 50)
	teamsPanel:SetVisible(true)
	function teamsPanel:Paint(w, h)
		draw.RoundedBox(0, 0, 0, w, h, Color(0, 195, 255, 180))
	end
	local teamsLabelMain = vgui.Create("DLabel", teamsPanel)
	teamsLabelMain:SetFont("regTextFont")
	teamsLabelMain:SetTextColor(Color(0, 0, 0, 255))
	teamsLabelMain:SetPos(teamsPanel:GetWide() / 5.31, 0)
	teamsLabelMain:SetSize(teamsPanel:GetWide() / 1.5, teamsPanel:GetTall() / 2)
	teamsLabelMain:SetWrap(true)
	teamsLabelMain:SetText("This some placeholder text in place for the soon to be coming, guard quiz.")
	local teamsJoinButton = vgui.Create("DButton", teamsPanel)
	teamsJoinButton:SetFont("regTextFont")
	teamsJoinButton:SetText("Swap Teams")
	teamsJoinButton:SetTextColor(Color(0, 0, 0, 255))
	teamsJoinButton:SetContentAlignment(5)
	teamsJoinButton:SetSize(teamsPanel:GetWide() / 4, 50)
	teamsJoinButton:SetPos(teamsPanel:GetWide() / 2.655, teamsPanel:GetTall() / 1.9)
	function teamsJoinButton:Paint(w, h)
		draw.RoundedBox(0, 0, 0, w, h, Color(200, 200, 200, 255))
	end
	function teamsJoinButton:OnCursorEntered()
		if (activeTab != 1) then
			function self:Paint(w, h) draw.RoundedBox(0, 0, 0, w, h, Color(220, 220, 220, 255)) end
		end
	end
	function teamsJoinButton:OnCursorExited()
		if (activeTab != 1) then
			function self:Paint(w, h) draw.RoundedBox(0, 0, 0, w, h, Color(0, 195, 255, 180)) end
		end
	end
	function teamsJoinButton:DoClick()
		net.Start("jb_switchTeams")
			net.WriteBit(true)
		net.SendToServer()
	end
	local teamsWardenButton = vgui.Create("DButton", teamsPanel)
	teamsWardenButton:SetFont("regTextFont")
	teamsWardenButton:SetText("Opt In")
	teamsWardenButton:SetTextColor(Color(0, 0, 0, 255))
	teamsWardenButton:SetContentAlignment(5)
	teamsWardenButton:SetSize(teamsPanel:GetWide() / 4, 50)
	teamsWardenButton:SetPos(teamsPanel:GetWide() / 2.655, teamsPanel:GetTall() / 1.5)
	teamsWardenButton:SetVisible(false)
	function teamsWardenButton:Paint(w, h)
		draw.RoundedBox(0, 0, 0, w, h, Color(200, 200, 200, 255))
	end
	function teamsWardenButton:DoClick()
		self.opt = !self.opt
		net.Start("jb_optWarden")
		net.SendToServer()
	end
	
	function teamsPanel:Think()
		if (LocalPlayer():Team() == 2 || LocalPlayer():Team() == 4) then
			if (!teamsWardenButton:IsVisible()) then teamsWardenButton:SetVisible(true) end
			if (teamsWardenButton.opt) then teamsWardenButton:SetText("Opt Out") else teamsWardenButton:SetText("Opt In") end
		end
	end
	
	//panel2
	local panel2 = vgui.Create("DPanel", mainFrame)
	panel2:SetPos(0, 50)
	panel2:SetSize(mainFrame:GetWide(), mainFrame:GetTall() - 50)
	panel2:SetVisible(false)
	function panel2:Paint(w, h)
		draw.RoundedBox(0, 0, 0, w, h, Color(0, 195, 255, 180))
	end
	local label2 = vgui.Create("DLabel", panel2)
	label2:SetFont("regTextFont")
	label2:SetTextColor(Color(0, 0, 0, 255))
	label2:SetPos(panel2:GetWide() / 2.45, 0)
	label2:SetSize(panel2:GetWide() / 1.5, panel2:GetTall() / 2)
	label2:SetWrap(true)
	label2:SetText("Coming soon.")
	
	//panel3
	local panel3 = vgui.Create("DPanel", mainFrame)
	panel3:SetPos(0, 50)
	panel3:SetSize(mainFrame:GetWide(), mainFrame:GetTall() - 50)
	panel3:SetVisible(false)
	function panel3:Paint(w, h)
		draw.RoundedBox(0, 0, 0, w, h, Color(0, 195, 255, 180))
	end
	local label3 = vgui.Create("DLabel", panel3)
	label3:SetFont("regTextFont")
	label3:SetTextColor(Color(0, 0, 0, 255))
	label3:SetPos(panel3:GetWide() / 2.45, 0)
	label3:SetSize(panel3:GetWide() / 1.5, panel3:GetTall() / 2)
	label3:SetWrap(true)
	label3:SetText("Coming soon.")
	
	//panel4
	local panel4 = vgui.Create("DPanel", mainFrame)
	panel4:SetPos(0, 50)
	panel4:SetSize(mainFrame:GetWide(), mainFrame:GetTall() - 50)
	panel4:SetVisible(false)
	function panel4:Paint(w, h)
		draw.RoundedBox(0, 0, 0, w, h, Color(0, 195, 255, 180))
	end
	local label4 = vgui.Create("DLabel", panel4)
	label4:SetFont("regTextFont")
	label4:SetTextColor(Color(0, 0, 0, 255))
	label4:SetPos(panel4:GetWide() / 2.45, 0)
	label4:SetSize(panel4:GetWide() / 1.5, panel4:GetTall() / 2)
	label4:SetWrap(true)
	label4:SetText("Coming soon.")
	
	//nav buttons
	local teamsButton = vgui.Create("DButton", mainFrame)
	teamsButton:SetFont("navButtonFont")
	teamsButton:SetText("Teams")
	teamsButton:SetTextColor(Color(0, 0, 0, 255))
	teamsButton:SetContentAlignment(5)
	teamsButton:SetSize(mainFrame:GetWide() / 4, 50)
	function teamsButton:Paint(w, h)
		draw.RoundedBox(0, 0, 0, w, h, Color(0, 195, 255, 180))
	end
	function teamsButton:OnCursorEntered()
		if (activeTab != 0) then
			function self:Paint(w, h) draw.RoundedBox(0, 0, 0, w, h, Color(0, 230, 255, 255)) end
		end
	end
	function teamsButton:OnCursorExited()
		if (activeTab != 0) then
			function self:Paint(w, h) draw.RoundedBox(0, 0, 0, w, h, Color(255, 255, 255, 255)) end
		end
	end
	function teamsButton:DoClick()
		activeTab = 0
		paintTabsStock()
		function self:Paint(w, h) draw.RoundedBox(0, 0, 0, w, h, Color(0, 195, 255, 180)) end
		
		unloadPanels()
		teamsPanel:SetVisible(true)
	end
	
	//nav button2
	local tab2 = vgui.Create("DButton", mainFrame)
	tab2:SetFont("navButtonFont")
	tab2:SetText("Tab")
	tab2:SetTextColor(Color(0, 0, 0, 255))
	tab2:SetContentAlignment(5)
	tab2:SetSize(mainFrame:GetWide() / 4, 50)
	tab2:SetPos(teamsButton:GetWide(), 0)
	function tab2:Paint(w, h)
		draw.RoundedBox(0, 0, 0, w, h, Color(0, 210, 255, 255))
	end
	function tab2:OnCursorEntered()
		if (activeTab != 1) then
			function self:Paint(w, h) draw.RoundedBox(0, 0, 0, w, h, Color(0, 230, 255, 255)) end
		end
	end
	function tab2:OnCursorExited()
		if (activeTab != 1) then
			function self:Paint(w, h) draw.RoundedBox(0, 0, 0, w, h, Color(0, 210, 255, 255)) end
		end
	end
	function tab2:DoClick()
		activeTab = 1
		paintTabsStock()
		function self:Paint(w, h) draw.RoundedBox(0, 0, 0, w, h, Color(0, 195, 255, 180)) end
		
		unloadPanels()
		panel2:SetVisible(true)
	end
	
	//nav button3
	local tab3 = vgui.Create("DButton", mainFrame)
	tab3:SetFont("navButtonFont")
	tab3:SetText("Tab")
	tab3:SetTextColor(Color(0, 0, 0, 255))
	tab3:SetContentAlignment(5)
	tab3:SetSize(mainFrame:GetWide() / 4, 50)
	tab3:SetPos(teamsButton:GetWide() * 2, 0)
	function tab3:Paint(w, h)
		draw.RoundedBox(0, 0, 0, w, h, Color(0, 210, 255, 255))
	end
	function tab3:OnCursorEntered()
		if (activeTab != 2) then
			function self:Paint(w, h) draw.RoundedBox(0, 0, 0, w, h, Color(0, 230, 255, 255)) end
		end
	end
	function tab3:OnCursorExited()
		if (activeTab != 2) then
			function self:Paint(w, h) draw.RoundedBox(0, 0, 0, w, h, Color(0, 210, 255, 255)) end
		end
	end
	function tab3:DoClick()
		activeTab = 2
		paintTabsStock()
		function self:Paint(w, h) draw.RoundedBox(0, 0, 0, w, h, Color(0, 195, 255, 180)) end
		
		unloadPanels()
		panel3:SetVisible(true)
	end
	
	//nav button4
	local tab4 = vgui.Create("DButton", mainFrame)
	tab4:SetFont("navButtonFont")
	tab4:SetText("Tab")
	tab4:SetTextColor(Color(0, 0, 0, 255))
	tab4:SetContentAlignment(5)
	tab4:SetSize(mainFrame:GetWide() / 4, 50)
	tab4:SetPos(teamsButton:GetWide() * 3, 0)
	function tab4:Paint(w, h)
		draw.RoundedBox(0, 0, 0, w, h, Color(0, 210, 255, 255))
	end
	function tab4:OnCursorEntered()
		if (activeTab != 3) then
			function self:Paint(w, h) draw.RoundedBox(0, 0, 0, w, h, Color(0, 230, 255, 255)) end
		end
	end
	function tab4:OnCursorExited()
			if (activeTab != 3) then
			function self:Paint(w, h) draw.RoundedBox(0, 0, 0, w, h, Color(0, 210, 255, 255)) end
		end
	end
	function tab4:DoClick()
		activeTab = 3
		paintTabsStock()
		function self:Paint(w, h) draw.RoundedBox(0, 0, 0, w, h, Color(0, 195, 255, 180)) end
		
		unloadPanels()
		panel4:SetVisible(true)
	end
	
	//begone tabs
	function unloadPanels()
		teamsPanel:SetVisible(false)
		panel2:SetVisible(false)
		panel3:SetVisible(false)
		panel4:SetVisible(false)
	end
	
	//refresh the tabs
	function paintTabsStock()
		function teamsButton:Paint(w, h) draw.RoundedBox(0, 0, 0, w, h, Color(0, 210, 255, 255)) end
		function tab2:Paint(w, h) draw.RoundedBox(0, 0, 0, w, h, Color(0, 210, 255, 255)) end
		function tab3:Paint(w, h) draw.RoundedBox(0, 0, 0, w, h, Color(0, 210, 255, 255)) end
		function tab4:Paint(w, h) draw.RoundedBox(0, 0, 0, w, h, Color(0, 210, 255, 255)) end
	end
end

net.Receive("jb_showMenu", function(len)
	if (!mainFrame) then
		initializeMenu()
	end
	mainFrame:SetKeyboardInputEnabled(false)
	mainFrame:SetVisible(!mainFrame:IsVisible())
end)