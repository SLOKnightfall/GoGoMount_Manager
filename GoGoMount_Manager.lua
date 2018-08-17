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

GoGoMount_Manager = LibStub("AceAddon-3.0"):NewAddon("GoGoMount_Manager")

local L = LibStub("AceLocale-3.0"):GetLocale("GoGoMount_Manager", silent)

local options = {
    name = "GoGoMount_Manager",
    handler = GoGoMount_Manager,
    type = 'group',
    args = {},
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


---Initilizes the buttons and creates the appropriate on click behaviour
--Pram: frame - frame that the checkbox should be added to
--Pram: index - index used to refrence the checkbox that is created created
--Return:  checkbox - the created checkbox frame
local function init_button(frame, index)
	local checkbox = CreateFrame("CheckButton", "GGMM"..index, frame, "ChatConfigCheckButtonTemplate")
	checkbox:SetPoint("BOTTOMRIGHT")
	checkbox.SpellID = 0
	checkbox:RegisterForClicks("AnyUp")
	checkbox:SetScript("OnClick",
	function(self, button)
		if (checkbox:GetChecked()) and button == "LeftButton" then  -- Sets as Perfered Mount
			PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
			GoGo_GlobalPrefMount(checkbox.SpellID)
			checkbox:SetCheckedTexture("Interface/Buttons/UI-CheckBox-Check")
			checkbox.tooltip = L.GLOBAL_ENABLE

		elseif (checkbox:GetChecked()) and button == "RightButton" then  -- Sets as Excluded Mount
			PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
			GoGo_GlobalExcludeMount(checkbox.SpellID)
			checkbox:SetCheckedTexture("Interface/Buttons/UI-GROUPLOOT-PASS-DOWN")
			checkbox.tooltip = L.GLOBAL_EXCLUDE

		elseif not (checkbox:GetChecked())  then  -- Removes Settings from GoGoMount
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

	--if GoGo_Prefs.Zones then
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
			local _, spellID, _, _, isUsable = C_MountJournal.GetDisplayedMountInfo(index)
			if  button.GGMM then

			else
				button.GGMM = init_button(button, i)
			end

			--Dont let mounts that are not able to be used be selected.
			--if isUsable then
				button.GGMM.SpellID = spellID
				button.GGMM:SetChecked(false)
				button.GGMM.tooltip = L.GLOBAL_CLEAR

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
				button.GGMM:Show()
			--else
				--button.GGMM:Hide()
			--end

		else
			if button.GGMM then
				button.GGMM:Hide()
			end
		end
	end
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
end


---Ace based addon initilization
function GoGoMount_Manager:OnInitialize()
	self.db = LibStub("AceDB-3.0"):New("GoGoMount_ManagerDB", defaults)
	options.args.profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db)
	LibStub("AceConfig-3.0"):RegisterOptionsTable("GoGoMount_Manager", options)
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
		GoGoMount_Manager.db.profile.init = nil

	--sets GoGoMount selections to be what is stored in the profile.
	else
		UpdateGoGoMountPrefs()
	end
end