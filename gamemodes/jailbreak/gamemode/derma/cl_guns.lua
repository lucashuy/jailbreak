surface.CreateFont("gunLargeMenu", {
	font = "Arial",
	size = 50,
	weight = 650,
	antialias = true,
})
surface.CreateFont("gunRegMenu", {
	font = "Arial",
	size = 18,
	weight = 575,
	antialias = true,
})

local gunMenu

local gunsPrimary = {
	["M4A1"] = "tfcss_m4a1_alt",
	["AK47"] = "tfcss_ak47_alt",
	["SCOUT"] = "tfcss_scout_alt",
	["MP5"] = "tfcss_mp5_alt",
	["UMP45"] = "tfcss_ump45_alt",
}

local gunsSecondary = {
	["USP"] = "tfcss_usp_alt",
	["DEAGLE"] = "tfcss_deagle_alt",
	["DUALIES"] = "tfcss_dualelites_alt",
	["FIVESEVEN"] = "tfcss_fiveseven_alt",
	["GLOCK 20"] = "tfcss_glock_alt",
}

local function initMenu()
	gunMenu = gunMenu or vgui.Create("DFrame")
	gunMenu:SetSize(500, 300)
	gunMenu:Center()
	gunMenu:SetVisible(false)
	gunMenu:SetDraggable(false)
	gunMenu:ShowCloseButton(false)
	gunMenu:MakePopup(true)
	gunMenu:SetTitle("")
	function gunMenu:Paint(w, h)
		draw.RoundedBox(0, 0, 0, w, h, Color(0, 195, 255, 180))
		draw.RoundedBox(0, 0, 0, w, gunMenu:GetTall() - 250, Color(0, 195, 255, 255))
	end
	
	local mainLabel = mainLabel or vgui.Create("DLabel", gunMenu)
	mainLabel:SetFont("gunLargeMenu")
	mainLabel:SetText("Armoury Menu")
	mainLabel:SetTextColor(Color(0, 0, 0, 255))
	mainLabel:SetPos(5, -1)
	mainLabel:SizeToContents()
	
	local lPrimary = lPrimary or vgui.Create("DListView", gunMenu)
	lPrimary:AddColumn( "Primary Weapons" )
	lPrimary:SetMultiSelect(false)
	lPrimary:SetSize(220, 110)
	lPrimary:SetPos(10, 60)
	lPrimary:AddLine("RANDOM")
	for k,v in pairs(gunsPrimary) do
		lPrimary:AddLine(k)
	end
	lPrimary:SelectFirstItem()
	function lPrimary:OnRowSelected(line)
		self.selected = self:GetLine(line):GetValue(1)
	end
	
	local lSecondary = lSecondary or vgui.Create("DListView", gunMenu)
	lSecondary:AddColumn( "Secondary Weapons" )
	lSecondary:SetMultiSelect(false)
	lSecondary:SetSize(220, 110)
	lSecondary:SetPos(10, 180)
	lSecondary:AddLine("RANDOM")
	for k,v in pairs(gunsSecondary) do
		lSecondary:AddLine(k)
	end
	lSecondary:SelectFirstItem()
	function lSecondary:OnRowSelected(line)
		self.selected = self:GetLine(line):GetValue(1)
	end
	
	local remember = remember or vgui.Create("DCheckBoxLabel", gunMenu)
	remember:SizeToContents()
	remember:SetPos(245, 60)
	remember:SetFont("gunRegMenu")
	remember:SetText("Remember selections?")
	remember:SetTextColor(Color(0, 0, 0, 255))
	
	local confirm = confirm or vgui.Create("DButton", gunMenu)
	confirm:SetPos(245, 265)
	confirm:SetSize(245, 25)
	confirm:SetFont("gunRegMenu")
	confirm:SetContentAlignment(5)
	confirm:SetTextColor(Color(0, 0, 0, 255))
	confirm:SetText("Apply Loadout")
	function confirm:Paint(w, h)
		draw.RoundedBox(0, 0, 0, w, h, Color(200, 200, 200, 255))
	end
	function confirm:OnCursorEntered()
		function self:Paint(w, h) draw.RoundedBox(0, 0, 0, w, h, Color(220, 220, 220, 255)) end
	end
	function confirm:OnCursorExited()
		function self:Paint(w, h) draw.RoundedBox(0, 0, 0, w, h, Color(200, 200, 200, 255)) end
	end
	function confirm:DoClick()
		net.Start("jb_receieveGun")
			net.WriteBool(remember:GetChecked())
			net.WriteString(table.HasValue(gunsPrimary, gunsPrimary[lPrimary.selected]) and gunsPrimary[lPrimary.selected] or "random")
			net.WriteString(table.HasValue(gunsSecondary, gunsSecondary[lSecondary.selected]) and gunsSecondary[lSecondary.selected] or "random")
		net.SendToServer()
		gunMenu:SetVisible(!gunMenu:IsVisible())
	end
end

net.Receive("jb_openGun", function(len)
	if (!gunMenu) then
		initMenu()
	end
	gunMenu:SetKeyboardInputEnabled(false)
	gunMenu:SetVisible(!gunMenu:IsVisible())
end)