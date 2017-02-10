surface.CreateFont("navButtonFont", {
	font = "Verdana",
	size = 30,
	weight = 650,
	antialias = true,
})

//WE ARE HACKING THE MAINFRAME
local mainFrame = mainFrame or vgui.Create("DFrame")
mainFrame:SetSize(700, 500)
mainFrame:SetPos(ScrW() / 3.56, ScrH() / 5) //perfect
mainFrame:SetVisible(false)
mainFrame:SetDraggable(false)
mainFrame:ShowCloseButton(false)
mainFrame:MakePopup(true)
function mainFrame:Paint(w, h)
	draw.RoundedBox(0, 0, 0, w, h, Color( 255, 255, 255, 255 ))
end

//nav buttons
local activeTab = 0

local teamsButton = teamsButton or vgui.Create("DButton", mainFrame)
teamsButton:SetFont("navButtonFont")
teamsButton:SetText("Teams")
teamsButton:SetTextColor(Color(0, 0, 0, 255))
teamsButton:SetContentAlignment(5)
teamsButton:SetSize(mainFrame:GetWide() / 4, 50)
function teamsButton:Paint(w, h)
	draw.RoundedBox(0, 0, 0, w, h, Color(255, 255, 255, 255))
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
	function self:Paint(w, h) draw.RoundedBox(0, 0, 0, w, h, Color(255, 255, 255, 255)) end
end

//nav button2
local tab2 = tab2 or vgui.Create("DButton", mainFrame)
tab2:SetFont("navButtonFont")
tab2:SetText("text")
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
	if (!activeTab != 1) then
		function self:Paint(w, h) draw.RoundedBox(0, 0, 0, w, h, Color(0, 210, 255, 255)) end
	end
end
function tab2:DoClick()
	activeTab = 1
	function self:Paint(w, h) draw.RoundedBox(0, 0, 0, w, h, Color(255, 255, 255, 255)) end
end

//nav button3
local tab3 = tab3 or vgui.Create("DButton", mainFrame)
tab3:SetFont("navButtonFont")
tab3:SetText("text")
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
	if (!activeTab != 2) then
		function self:Paint(w, h) draw.RoundedBox(0, 0, 0, w, h, Color(0, 210, 255, 255)) end
	end
end
function tab3:DoClick()
	activeTab = 2
	function self:Paint(w, h) draw.RoundedBox(0, 0, 0, w, h, Color(255, 255, 255, 255)) end
end

//nav button4
local tab4 = tab4 or vgui.Create("DButton", mainFrame)
tab4:SetFont("navButtonFont")
tab4:SetText("text")
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
	if (!activeTab != 3) then
		function self:Paint(w, h) draw.RoundedBox(0, 0, 0, w, h, Color(0, 210, 255, 255)) end
	end
end
function tab4:DoClick()
	activeTab = 3
	function self:Paint(w, h) draw.RoundedBox(0, 0, 0, w, h, Color(255, 255, 255, 255)) end
end

net.Receive("jb_showMenu", function(len)
	mainFrame:SetKeyboardInputEnabled(false)
	mainFrame:SetVisible(!mainFrame:IsVisible())
end)