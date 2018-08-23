--	///////////////////////////////////////////////////////////////////////////////////////////
--
--	GoGoMount_Manager v1.0
--	Author: SLOKnightfall

--	GoGoMount_Manager: Integrates GoGoMounts Preferred and Excluded listing directly into the Mount List and adds profile support
--

--	License: You are hereby authorized to freely modify and/or distribute all files of this add-on, in whole or in part,
--		providing that this header stays intact, and that you do not claim ownership of this Add-on.
--
--		Additionally, the original owner wishes to be notified by email if you make any improvements to this add-on.
--		Any positive alterations will be added to a future release, and any contributing authors will be
--		identified in the section above.
--
--
--
--	///////////////////////////////////////////////////////////////////////////////////////////

--Mirror of the GoGoMount pref settings
local GlobalPrefs = {}
local GlobalExclude = {}
local ZoneMountList = {}
local EnableZoneEdit = false
GoGoMount_Manager = LibStub("AceAddon-3.0"):NewAddon("GoGoMount_Manager")

local L = LibStub("AceLocale-3.0"):GetLocale("GoGoMount_Manager", silent)

local options = {
    name = "GoGoMount_Manager",
    handler = GoGoMount_Manager,
    type = 'group',
    args = {
	},
}


local continentZoneList = {
	[12]  = "Kalimdor", -- Kalimdor
	[13]  = "Azeroth", -- Azeroth
	[101] = "Outlands", -- Outlands
	[113] = "Northrend", -- Northrend
	[424] = "Pandaria", -- Pandaria
	[572] = "Draenor", -- Draenor
	[619] = "Broken Isles", -- Broken Isles
	[875] = "Zandalar", -- Zandalar
	[876] = "Kul Tiras", -- Kul Tiras
}
local ZoneList = {}

local function fillContinentZoneList(continent)
if not continent then return {} end
	wipe(ZoneList)
	

	local children = C_Map.GetMapChildrenInfo(continent)
	if children then
		for _, child in ipairs(children) do
			if child.mapType == Enum.UIMapType.Zone then
			--print(child.mapID)
				--table.insert(ZoneList, child.mapID)
				ZoneList[child.mapID] = C_Map.GetMapInfo(child.mapID).name
				--print(C_Map.GetMapInfo(child.mapID).name)
			end
		end
	end
end


local selectedCont = nil
local selectedZone = nil
local selectedProfile = nil


local function copypro(value)

	--print(value)
	--local namespace = GoGoMount_Manager.db:GetNamespace(value)
		--for profileKey, data in pairs(GoGoMount_Manager.db.profiles) do

			for profileKey, data in pairs(GoGoMount_Manager.db.profiles[value]) do
			--print(profileKey)
			--print(data)
			end
			--tbl[i] = profileKey
			--if curProfile and profileKey == curProfile then curProfile = nil end
		--end
		ZoneMountList[selectedZone]={["Preferred"] = {},	["Excluded"] = {},}
	if GoGoMount_Manager.db.profiles[value]["GlobalPrefs"] then
			--ZoneMountLis[selectedZone]["Preferred"]
			for spellID, setting in pairs(GoGoMount_Manager.db.profiles[value]["GlobalPrefs"]) do
				ZoneMountList[selectedZone]["Preferred"][spellID] = setting
			end

	end
	if GoGoMount_Manager.db.profiles[value]["GlobalExclude"]  then
			for spellID, setting in pairs(GoGoMount_Manager.db.profiles[value]["GlobalExclude"]) do
				ZoneMountList[selectedZone]["Excluded"][spellID] = setting
			end

	end
	GoGoMount_Manager:UpdateCB()
	GoGoMount_Manager:UpdateGoGoMountPrefs()
end


local zone_options = {
    name = "GoGoMount_Manager_Zone",
    handler = GoGoMount_Manager,
    type = 'group',
    args = {
	zoneoptions={
			name = "Options",
			type = "group",
			--hidden = true,
			args={
				Topheader = {
					order = 0,
					type = "header",
					name = "GOGOMount_Manager",
					
				},
				globalheader = {
					order = 0.5,
					type = "header",
					name = "Global Helpers",
					
				},
				clearglobalfav = {
					order = 1,
					type = "execute",
					name = "Clear All Global Favorites",
					func = function() GoGoMount_Manager:ClearGlobalFav() end,
					width = 1.6,
					
				},
				clearglobalexclude = {
					order = 2,
					type = "execute",
					name = "Clear All Global Excludes",
					func = function() GoGoMount_Manager:ClearGlobalExclude() end,
					width = "full",
					
				},
				zoneheader = {
					order = 2.5,
					type = "header",
					name = "Zone Setting",
					width = "full",
					
				},
				item = {
					order = 3,
					type = "toggle",
					name = "Enable Zone Based Mounts",
					get = function(info)  return EnableZoneEdit end, 
					set = function(info, value) EnableZoneEdit = value; GoGoMount_Manager:UpdateCB()  end,
					width = "full",

					
				},
				cont = {
					order = 4,
					type = "select",
					name = "Continent",
					get = function(info)  return selectedCont   end, 
					set = function(info, value) selectedCont = value; fillContinentZoneList(value); selectedZone=nil  end,
					values = continentZoneList,
					disabled = function() return not EnableZoneEdit end,

				},
				zone = {
					order = 5,
					type = "select",
					name = "Zone",
					get = function(info) return selectedZone   end, 
					set = function(info, value) selectedZone = value; ZoneMountList[value] = ZoneMountList[value] or{["Preferred"] = {},["Excluded"] = {},}; GoGoMount_Manager:UpdateCB() end,
					values = function() return ZoneList end,
					disabled = function() return not EnableZoneEdit end,
				},
				profile = {
					order = 6,
					type = "select",
					name = "Copy Profile Globals to Selected Zone",
					get = function(info)  return selectedProfile    end, 
					set = function(info, value) selectedProfile = GoGoMount_Manager.db:GetProfiles()[value]; copypro(selectedProfile) end,
					values = function() return GoGoMount_Manager.db:GetProfiles() end,
					disabled = function() return not EnableZoneEdit and not selectedZone end,
					width = "full",
				},
				zoneheader_2 = {
					order = 6.5,
					type = "header",
					name = "Zone Helpers",
					width = "full",
					
				},
				clearselectedzone = {
					order = 7,
					type = "execute",
					name = "Clear Selected Zone Selections",			
					func = function() GoGoMount_Manager:ClearZoneFavorites() end,
					width = "full",
				},
				clearallzone = {
					order = 8,
					type = "execute",
					name = "Clear All Zone Selections",
					func = function() GoGoMount_Manager:ClearAllZoneFavorites() end,
					width = "full",
					
				},


			},
		},
	},
}

local defaults = {
	profile = {
		GlobalPrefs = {},
		GlobalExclude = {},
		ZoneMountList = {},
		init = true,
 	}
}


--Local Functions--

---Updates our GlobalPrefs if changes are made via the GoGoMounts options
--Pram: spellID - spellID to set the table value for
local function GoGo_GlobalPrefMount_update(spellID)
	if GlobalPrefs[spellID] then
		GlobalPrefs[spellID]  = null
	else
		GlobalPrefs[spellID]  = true
	end
end


---Updates our GlobalExclude if changes are made via the GoGoMounts options
--Pram: spellID - spellID to set the table value for
local function GoGo_GlobalExcludeMount_update(spellID)
	if GlobalExclude[spellID] then
		GlobalExclude[spellID]  = null
	else
		GlobalExclude[spellID]  = true
	end
end

local function GoGo_ZoneExcludeMount_update(spellID,ZoneID)
local zone = ZoneID or GoGo_Variables.Player.MapID
	ZoneMountList[zone] = ZoneMountList[zone] or {["Preferred"] = {},	["Excluded"] = {},}

	if ZoneMountList[zone]["Excluded"][spellID] then
		ZoneMountList[zone]["Excluded"][spellID]  = null
	else
		ZoneMountList[zone]["Excluded"][spellID]  = true
	end
end

local function GoGo_ZonePrefMount_update(spellID,ZoneID)
local zone = ZoneID or GoGo_Variables.Player.MapID
	ZoneMountList[zone] = ZoneMountList[zone] or {["Preferred"] = {},	["Excluded"] = {},}
	if ZoneMountList[zone]["Preferred"][spellID] then
		ZoneMountList[zone]["Preferred"][spellID]  = null
	else
		ZoneMountList[zone]["Preferred"][spellID]  = true
	end
end


---------
local function ZonePrefMount(SpellID,ZoneID)
---------
	if SpellID == nil or ZoneID == nil then
		return
	else
		SpellID = tonumber(SpellID)
	end
	if GoGo_Variables.Debug >= 10 then 
		GoGo_DebugAddLine("GoGo_ZonePrefMount: Preference ID " .. SpellID)
	end
	GoGo_Prefs.MapIDs[ZoneID] = GoGo_Prefs.MapIDs[ZoneID] or {["Preferred"] = {},["Excluded"] = {}}
	for GoGo_CounterA = 1, table.getn(GoGo_Prefs.MapIDs[ZoneID]["Preferred"]) do
		if GoGo_Prefs.MapIDs[ZoneID]["Preferred"][GoGo_CounterA] == SpellID then
			table.remove(GoGo_Prefs.MapIDs[ZoneID]["Preferred"], GoGo_CounterA)
			GoGo_ZonePrefMount_update(SpellID,ZoneID)
			return -- mount found, removed and now returning
		end
	end
	if not GoGo_SearchTable(GoGo_Prefs.UnknownMounts, SpellID) then
		table.insert(GoGo_Prefs.MapIDs[ZoneID]["Preferred"], SpellID)
	end
	GoGo_ZonePrefMount_update(SpellID,ZoneID)

end

---------
local function ZoneExcludeMount(SpellID, ZoneID)
---------
	if SpellID == nil or ZoneID==nil then
		return
	else
		SpellID = tonumber(SpellID)
	end
	if GoGo_Variables.Debug >= 10 then 
		GoGo_DebugAddLine("GoGo_ZoneExcludedMount: Excluded ID " .. SpellID)
	end
	GoGo_Prefs.MapIDs[ZoneID] = GoGo_Prefs.MapIDs[ZoneID] or {["Preferred"] = {},["Excluded"] = {}}
	for GoGo_CounterA = 1, table.getn(GoGo_Prefs.MapIDs[ZoneID]["Excluded"]) do
		if GoGo_Prefs.MapIDs[ZoneID]["Excluded"][GoGo_CounterA] == SpellID then
			table.remove(GoGo_Prefs.MapIDs[ZoneID]["Excluded"], GoGo_CounterA)
			GoGo_ZoneExcludeMount_update(SpellID)
			return
		end
	end
	table.insert(GoGo_Prefs.MapIDs[ZoneID]["Excluded"], SpellID)
	GoGo_ZoneExcludeMount_update(SpellID,ZoneID)
end

---Initilizes the buttons and creates the appropriate on click behaviour
--Pram: frame - frame that the checkbox should be added to
--Pram: index - index used to refrence the checkbox that is created created
--Return:  checkbox - the created checkbox frame
local function init_button(frame, index)
	local checkbox = CreateFrame("CheckButton", "GGMM"..index, frame, "ChatConfigCheckButtonTemplate")
	--checkbox:SetPoint("CENTER",-700)
	checkbox:SetPoint("BOTTOMRIGHT")
	checkbox.SpellID = 0
	--getglobal(checkbox:GetName() .. 'Text'):SetText("GG")
	checkbox:RegisterForClicks("AnyUp")
	checkbox:SetScript("OnClick",
	function(self, button)
		if (checkbox:GetChecked()) and button == "LeftButton" and EnableZoneEdit then 
		-- Sets as Perfered Mount
			PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
			ZonePrefMount(checkbox.SpellID, selectedZone )
			checkbox:SetCheckedTexture("Interface/Buttons/UI-CheckBox-Check")
			checkbox.tooltip = L.ZONE_ENABLE	
		elseif (checkbox:GetChecked()) and button == "LeftButton" and not EnableZoneEdit then  -- Sets as Perfered Mount
			PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
			GoGo_GlobalPrefMount(checkbox.SpellID)
			checkbox:SetCheckedTexture("Interface/Buttons/UI-CheckBox-Check")
			checkbox.tooltip = L.GLOBAL_ENABLE

		elseif (checkbox:GetChecked()) and button == "RightButton" and EnableZoneEdit then  -- Sets as Excluded Mount
			PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
			ZoneExcludeMount(checkbox.SpellID, selectedZone)
			checkbox:SetCheckedTexture("Interface/Buttons/UI-GROUPLOOT-PASS-DOWN")
			checkbox.tooltip = L.ZONE_EXCLUDE
		elseif (checkbox:GetChecked()) and button == "RightButton" and not EnableZoneEdit then  -- Sets as Excluded Mount
			PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
			GoGo_GlobalExcludeMount(checkbox.SpellID)
			checkbox:SetCheckedTexture("Interface/Buttons/UI-GROUPLOOT-PASS-DOWN")
			checkbox.tooltip = L.GLOBAL_EXCLUDE

		elseif not (checkbox:GetChecked()) and EnableZoneEdit  then  -- Removes Settings from GoGoMount
			PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF)
			if ZoneMountList[selectedZone]["Preferred"][checkbox.SpellID] then
				ZonePrefMount(checkbox.SpellID, selectedZone )
			end

			if ZoneMountList[selectedZone]["Excluded"][checkbox.SpellID] then
				ZoneExcludeMount(checkbox.SpellID, selectedZone)
			end
			checkbox.tooltip = L.GLOBAL_CLEAR
		elseif not (checkbox:GetChecked()) and not EnableZoneEdit then 
			PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF)
			if GlobalPrefs[checkbox.SpellID] then
				GoGo_GlobalPrefMount(checkbox.SpellID)
			end

			if GlobalExclude[checkbox.SpellID] then
				GoGo_GlobalExcludeMount(checkbox.SpellID)
			end
			checkbox.tooltip = L.GLOBAL_CLEAR
		end
	  end
	)
	return checkbox
end


---Refreshes our global lists to get any changes made from the GoGoMount options
local function RefreshFromGoGoPrefs()
	wipe(GlobalPrefs)
	wipe(GlobalExclude)
	wipe(ZoneMountList)

	if GoGo_Prefs.GlobalPrefMounts then
		for counter = 1, table.getn(GoGo_Prefs.GlobalPrefMounts) do
			GlobalPrefs[GoGo_Prefs.GlobalPrefMounts[counter]] = true
		end
	end

	if GoGo_Prefs.GlobalExclude then
		for counter = 1, table.getn(GoGo_Prefs.GlobalExclude) do
			GlobalExclude[GoGo_Prefs.GlobalExclude[counter]] = true
		end
	end

	--GoGo_Prefs.Zones[zoneName] or GoGo_Prefs.Zones[zoneID] or  GoGo_Prefs.Zones[zoneName][ZoneID] Preferred/Excluded

	if GoGo_Prefs.MapIDs then
		for zone, data in pairs(GoGo_Prefs.MapIDs) do
		ZoneMountList[zone] = {["Preferred"] = {},
					["Excluded"] = {},}
		
		for counter = 1, table.getn(GoGo_Prefs.MapIDs[zone]["Preferred"]) do
			ZoneMountList[zone]["Preferred"][GoGo_Prefs.MapIDs[zone]["Preferred"][counter]] = true
		end

		for counter = 1, table.getn(GoGo_Prefs.MapIDs[zone]["Excluded"]) do
			ZoneMountList[zone]["Excluded"][GoGo_Prefs.MapIDs[zone]["Excluded"][counter]] = true
		end

			--ZoneMountList[zone] = data
		end
	end

		
		--for counter = 1, table.getn(GoGo_Prefs.GlobalExclude) do
			--GlobalExclude[GoGo_Prefs.GlobalExclude[counter] ] = true
		--end

		--selected_zone = getcurrentzone or zone from dropdown

		--for counter = 1, table.getn(GoGo_Prefs.Zones[selected_zone]["Preferred"]) do
			--GlobalExclude[GoGo_Prefs.GlobalExclude[counter] ] = true
		--end
		--for counter = 1, table.getn(GoGo_Prefs.Zones[selected_zone]["Excluded"]) do
			--GlobalExclude[GoGo_Prefs.GlobalExclude[counter] ] = true
		--end
	--end
end


---Updates the checkboxes on Collection Mount List to match GoGoMount set mounts
local function UpdateMountList_Checkboxes()
	local scrollFrame = MountJournal.ListScrollFrame
	local offset = HybridScrollFrame_GetOffset(scrollFrame)
	local buttons = scrollFrame.buttons
	local numMounts = C_MountJournal.GetNumMounts()
	local showMounts = true
	if  ( numMounts < 1 ) then return end  --If there are no mounts then nothing needs to be done.

	local numDisplayedMounts = C_MountJournal.GetNumDisplayedMounts()
	for i=1, #buttons do
		local button = buttons[i]
		local displayIndex = i + offset
		if ( displayIndex <= numDisplayedMounts and showMounts ) then
			local index = displayIndex
			local _, spellID, _, _, isUsable,_, _, _, _, _, isCollected  = C_MountJournal.GetDisplayedMountInfo(index)
			if  button.GGMM then

			else
				button.GGMM = init_button(button, i)
			end

			--Dont let mounts that are not able to be used be selected.
			if isCollected then
				button.GGMM.SpellID = spellID
				button.GGMM:SetChecked(false)
				button.GGMM.tooltip = L.GLOBAL_CLEAR
				if EnableZoneEdit then
					ZoneMountList[selectedZone] = ZoneMountList[selectedZone] or {["Preferred"]={},["Excluded"]={}}
					if ZoneMountList[selectedZone]["Preferred"][spellID]then
						button.GGMM:SetCheckedTexture("Interface/Buttons/UI-CheckBox-Check")
						button.GGMM:SetChecked(true)
						button.GGMM.tooltip = L.ZONE_ENABLE
					end

					if ZoneMountList[selectedZone]["Excluded"][spellID] then
						button.GGMM:SetCheckedTexture("Interface/Buttons/UI-GROUPLOOT-PASS-DOWN")
						button.GGMM:SetChecked(true)
						button.GGMM.tooltip = L.ZONE_EXCLUDE
					end
				else

					if GlobalPrefs[spellID] then
						button.GGMM:SetCheckedTexture("Interface/Buttons/UI-CheckBox-Check")
						button.GGMM:SetChecked(true)
						button.GGMM.tooltip = L.GLOBAL_ENABLE
					end

					if GlobalExclude[spellID] then
						button.GGMM:SetCheckedTexture("Interface/Buttons/UI-GROUPLOOT-PASS-DOWN")
						button.GGMM:SetChecked(true)
						button.GGMM.tooltip = L.GLOBAL_EXCLUDE
					end
				end
				button.GGMM:Show()
			else
				button.GGMM:Hide()
			end

		else
			if button.GGMM then
				button.GGMM:Hide()
			end
		end
	end
end


function GoGoMount_Manager:UpdateCB()
	UpdateMountList_Checkboxes()
end


--- Gets current Manager profile data and updates the GoGoMount saved variables to match
local function UpdateGoGoMountPrefs()
  	if GoGo_Prefs.GlobalPrefMounts then
  		wipe(GoGo_Prefs.GlobalPrefMounts)
  		for id in pairs(GlobalPrefs) do
  			tinsert(GoGo_Prefs.GlobalPrefMounts,id)
		end
	end

	if GoGo_Prefs.GlobalExclude then
		wipe(GoGo_Prefs.GlobalExclude)
  		for id in pairs(GlobalExclude) do
  			tinsert(GoGo_Prefs.GlobalExclude,id)
		end
	end

	if GoGo_Prefs.MapIDs then
		wipe(GoGo_Prefs.MapIDs)
		for zone, data in pairs(ZoneMountList) do
			GoGo_Prefs.MapIDs[zone] = {["Preferred"] = {},
						["Excluded"] = {},}

			for id in pairs(data["Preferred"]) do
				tinsert(GoGo_Prefs.MapIDs[zone]["Preferred"],id)
			end

			for id in pairs(data["Excluded"]) do
				tinsert(GoGo_Prefs.MapIDs[zone]["Excluded"],id)
			end
		end
	end
		
end


function GoGoMount_Manager:UpdateGoGoMountPrefs()
	UpdateGoGoMountPrefs()
end


---Ace based addon initilization
function GoGoMount_Manager:OnInitialize()
	self.db = LibStub("AceDB-3.0"):New("GoGoMount_ManagerDB", defaults)
	options.args.profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db)
	LibStub("AceConfig-3.0"):RegisterOptionsTable("GoGoMount_Manager", options)
	LibStub("AceConfig-3.0"):RegisterOptionsTable("GoGoMount_Manager_Zone", zone_options)
	
	self.optionsFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("GoGoMount_Manager", "GoGoMount_Manager")

	self.db.RegisterCallback(self, "OnProfileChanged", "ChangeProfile")
	self.db.RegisterCallback(self, "OnProfileCopied", "ChangeProfile")
	self.db.RegisterCallback(self, "OnProfileReset", "ResetProfile")

	local LibDualSpec = LibStub('LibDualSpec-1.0')
	LibDualSpec:EnhanceDatabase(self.db, "GoGoMount_Manager")
	LibDualSpec:EnhanceOptions(options.args.profiles, self.db)

	--Hooking GoGoMount funtions
	hooksecurefunc("GoGo_GlobalExcludeMount", GoGo_GlobalExcludeMount_update)
	hooksecurefunc("GoGo_GlobalPrefMount", GoGo_GlobalPrefMount_update)
	hooksecurefunc("GoGo_ZoneExcludeMount", GoGo_ZoneExcludeMount_update)
	hooksecurefunc("GoGo_ZonePrefMount", GoGo_ZonePrefMount_update)
end


function GoGoMount_Manager:OnEnable()
  	--Link local lists to profile data
	GlobalPrefs = self.db.profile.GlobalPrefs or {}
	GlobalExclude = self.db.profile.GlobalExclude or {}
	ZoneMountList = self.db.profile.ZoneMountList or {}

	GoGoMount_Manager:SyncPrefs()

	--Hooking MountJournal functions
	LoadAddOn("Blizzard_Collections")
	hooksecurefunc("MountJournal_UpdateMountList", UpdateMountList_Checkboxes)
	hooksecurefunc(MountJournal.ListScrollFrame,"update", UpdateMountList_Checkboxes)

	GoGoMount_Manager:Build()
end


---Resets current profile
function GoGoMount_Manager:ResetProfile()
	wipe(GoGoMount_Manager.db.profile)
  	for id, value in pairs(defaults.profile) do
  		GoGoMount_Manager.db.profile[id] = value
	end
end


--Updates mount list to be selected profile
function GoGoMount_Manager:ChangeProfile()
	GlobalPrefs = self.db.profile.GlobalPrefs or {}
	GlobalExclude = self.db.profile.GlobalExclude or {}
	ZoneMountList = self.db.profile.ZoneMountList or {}
	GoGoMount_Manager:SyncPrefs()
end


---Syncs mount prefrence lists between GoGoMount & GoGoMount_Manager
function GoGoMount_Manager:SyncPrefs()
	--if initial run rebuilds tables based on current GoGoMount selections
	if GoGoMount_Manager.db.profile.init then
		RefreshFromGoGoPrefs()
		GoGoMount_Manager.db.profile.init = false

	--sets GoGoMount selections to be what is stored in the profile.
	else
		UpdateGoGoMountPrefs()
	end
end


--clears all global favorites
function GoGoMount_Manager:ClearGlobalFav()
	GoGo_Prefs.GlobalPrefMounts = nil
	RefreshFromGoGoPrefs()
	UpdateMountList_Checkboxes()
end


--clears global exclusions
function GoGoMount_Manager:ClearGlobalExclude()
	GoGo_Prefs.GlobalExclude = nil
	RefreshFromGoGoPrefs()
	UpdateMountList_Checkboxes()
end


function GoGoMount_Manager:ClearZoneFavorites()
	GoGo_Prefs.MapIDs[selectedZone] = {["Preferred"] = {},["Excluded"] = {},}
	RefreshFromGoGoPrefs()
	UpdateMountList_Checkboxes()
end


--clears all zone favorites
function GoGoMount_Manager:ClearAllZoneFavorites()
	--for zone, data in pairs(GoGo_Prefs.MapIDs) do
		--data["Preferred"] = {}
		--data["Excluded"] = {}

	--end
	wipe(GoGo_Prefs.MapIDs)
	RefreshFromGoGoPrefs()
	UpdateMountList_Checkboxes()
end

	
function GoGoMount_Manager:Build()
	local f = CreateFrame('Frame', "GoGoMountManager_ZoneMenu", MountJournal)
	f:SetClampedToScreen(true)
	f:SetSize(250, 160)
	f:SetPoint("TOPLEFT",MountJournal,"TOPRIGHT")
	f:SetPoint("BOTTOMLEFT",MountJournal,"BOTTOMRIGHT")
	f:Hide()
	f:EnableMouse(true)
	f:SetFrameStrata('HIGH')
	f:SetMovable(true)
	f:SetToplevel(true)
	
	f.border = f:CreateTexture()
	f.border:SetAllPoints()
	f.border:SetColorTexture(0,0,0,1)
	f.border:SetTexture([[Interface\Tooltips\UI-Tooltip-Background]])
	f.border:SetDrawLayer('BORDER')

	f.background = f:CreateTexture()
	f.background:SetPoint('TOPLEFT', f, 'TOPLEFT', 1, -1)
	f.background:SetPoint('BOTTOMRIGHT', f, 'BOTTOMRIGHT', 65, 1)
	--f.background:SetColorTexture(0.1,0.1,0.1,1)
	f.background:SetTexture("Interface\\PetBattles\\MountJournal-BG")
	f.background:SetDrawLayer('ARTWORK')
	
	f:RegisterForDrag("LeftButton")
	f:SetScript("OnDragStart", function(self)
		self:StartMoving() end)
	f:SetScript("OnDragStop", function(self)
		self:StopMovingOrSizing() 
	end)
	
	local close_ = CreateFrame("Button", nil, f)
	close_:SetNormalTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Up")
	close_:SetPushedTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Down")
	close_:SetHighlightTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Highlight", "ADD")
	close_:SetSize(32, 32)
	close_:SetPoint("TOPRIGHT", f, "TOPRIGHT", 0, 0)
	close_:SetScript("OnClick", function(self)
		self:GetParent():Hide()
		self:GetParent().free = true
	end)
	
	f.close = close_

	local content = CreateFrame("Frame",nil, f)
	content:SetPoint("TOPLEFT",15,-15)
	content:SetPoint("BOTTOMRIGHT",-15,15)
	--This creats a cusomt AceGUI container which lets us imbed a AceGUI menu into our frame.
	local widget = {
		frame     = f,
		content   = content,
		type      = "GGMMContainer"
	}
	widget["OnRelease"] = function(self)
		self.status = nil
		wipe(self.localstatus)
	end

	f:SetScript("OnShow", function(self) LibStub("AceConfigDialog-3.0"):Open("GoGoMount_Manager_Zone", widget, "zoneoptions"); 
		selectedZone =C_Map.GetBestMapForUnit("player");
		ZoneList = {[C_Map.GetBestMapForUnit("player")]=C_Map.GetMapInfo(C_Map.GetBestMapForUnit("player")).name};
		selectedCont = nil;
		EnableZoneEdit = false;
		end)

	LibStub("AceGUI-3.0"):RegisterAsContainer(widget)
	--f:Show()

	local mountButton = CreateFrame("Button", nil , MountJournal);
	mountButton:SetNormalTexture("Interface\\Buttons\\UI-MicroButton-Spellbook-Up")
	mountButton:SetPoint("BOTTOMRIGHT", MountJournal, "BOTTOMRIGHT", 0, 0);
	mountButton:SetWidth(30)
	mountButton:SetHeight(45)
	mountButton:SetScript("OnClick", function(self, button, down) 
		
		if f:IsShown() then
			f:Hide()
		else
			f:Show()
		end
	end);
	mountButton:SetScript("OnEnter",
		function(self)
			GameTooltip:SetOwner (self, "ANCHOR_RIGHT");
			GameTooltip:SetText(L.GOGOMOUNT_BUTTON_TOOLTIP, 1, 1, 1);
			--GameTooltip:AddLine(L.AUTO_CAGE_TOOLTIP_2, nil, nil, nil, true);
			--GameTooltip:AddLine(L.AUTO_CAGE_TOOLTIP_3, nil, nil, nil, true);
			GameTooltip:Show();
		end
	);
	mountButton:SetScript("OnLeave",
		function()
			GameTooltip:Hide();
		end
	);

end