local L = AceLibrary("AceLocale-2.1"):GetInstance("RaidOrganizer", true)

local options = {
    type = 'group',
    args = {
        show = {
            type = 'execute',
            name = 'Show/Hide Dialog',
            desc = L["SHOW_DIALOG"],
            func = function() RaidOrganizer:ShowButtons() end,
        },
        autosort = {
            type = 'toggle',
            name = 'Autosort',
            desc = L["AUTOSORT_DESC"],
            get = function() return RaidOrganizer.db.char.autosort end,
            set = function() RaidOrganizer.db.char.autosort = not RaidOrganizer.db.char.autosort end,
        },
		horizontal = {
			type = 'toggle',
			name = 'Horizontal display',
			desc = 'Show buttons horizontally or vertically',
			get = function() return RaidOrganizer.db.char.horizontal end,
            set = function() RaidOrganizer.db.char.horizontal = not RaidOrganizer.db.char.horizontal end,
		},
    }
}
-- units


-- name2unitid
local unitids = {
}
local position = {
}
local overrideSort = false
local lastAction = {
    name = {},
    position = {},
    group = {},
}

local moreThan24Display = false
local einteilung = {
    [1] = {},
    [2] = {},
    [3] = {},
    [4] = {},
    [5] = {},
    [6] = {},
    [7] = {},
    [8] = {},
    [9] = {},
	[10] = {},
}
local stats = {
    DRUID = 0,
    PRIEST = 0,
    PALADIN = 0,
    SHAMAN = 0,
	WARRIOR = 0,
	ROGUE = 0,
	MAGE = 0,
	WARLOCK = 0,
	HUNTER = 0,
}

local grouplabels = {
    Rest = "GROUP_LOCALE_REMAINS",
    [1] = "GROUP_LOCALE_1",
    [2] = "GROUP_LOCALE_2",
    [3] = "GROUP_LOCALE_3",
    [4] = "GROUP_LOCALE_4",
    [5] = "GROUP_LOCALE_5",
    [6] = "GROUP_LOCALE_6",
    [7] = "GROUP_LOCALE_7",
    [8] = "GROUP_LOCALE_8",
    [9] = "GROUP_LOCALE_9",
}
-- nil, DRUID, PRIEST, PALADIN, SHAMAN
local groupclasses = {
    [1] = {},
    [2] = {},
    [3] = {},
    [4] = {},
    [5] = {},
    [6] = {},
    [7] = {},
    [8] = {},
    [9] = {},
}

local classTab = {}

local faction = UnitFactionGroup("player")
if faction == "Alliance" then
	classTab = {{"PRIEST","DRUID","PALADIN"},
	{"WARRIOR","DRUID"},
	{"WARRIOR","ROGUE","MAGE"},
	{"MAGE","PRIEST","WARLOCK","ROGUE","HUNTER", "DRUID"},
	{"WARLOCK"},
	{"MAGE"},
	{"PRIEST"},
	{"DRUID"}}
else
	classTab = {{"PRIEST","DRUID","SHAMAN"},
	{"WARRIOR","DRUID"},
	{"WARRIOR","ROGUE","MAGE"},
	{"MAGE","PRIEST","WARLOCK","ROGUE","HUNTER", "DRUID"},
	{"WARLOCK"},
	{"MAGE"},
	{"PRIEST"},
	{"DRUID"}}
end
		
local change_id = 0

-- button level speichern
local level_of_button = -1;

-- saves the raider-setup of other templates
--[[
-- tempsetup[setname] = raider-array
--]]
local tempsetup = {}

-- key bindings
BINDING_HEADER_RaidOrganizer = "Raid Organizer"
BINDING_NAME_SHOW_RaidOrganizer = L["SHOW_DIALOG"]

RaidOrganizer = AceLibrary("AceAddon-2.0"):new("AceConsole-2.0", "AceDebug-2.0", "AceDB-2.0", "AceEvent-2.0")
RaidOrganizer:RegisterChatCommand({"/RaidOrganizer", "/raidorg", "/ro"}, options)
RaidOrganizer:RegisterDB("RaidOrganizerDB", "RaidOrganizerDBPerChar")
RaidOrganizer:RegisterDefaults('char', {
    chan = "",
    autosort = true,
	horizontal = false,
})
--[[
self.db.account.sets = {
    "Name" = {
        Name = "Name",
        Beschriftungen = {
            Rest = "Rest",
            [1] = "%MT1%",
            ...
            [8] = "%MT8%",
            [9] = "Dispellen",
        },
        Restaktion = "ffa",
        Klassengruppen = {
            [1] = {
                [1] = "PALADIN",
                [2] = "PALADIN",
                [3] = "PRIEST",
            },
            [2] = {},
            ...
            [9] = {
                [2] = "DRUID",
            },
        },        
    },
    "Name3" = {
        ...
    },
}
--]]
RaidOrganizer:RegisterDefaults('account', {
    sets = { {
        [L["SET_DEFAULT"]] = {
            Name = L["SET_DEFAULT"],
            Beschriftungen = {
                [1] = "MT1",
                [2] = "MT2",
                [3] = "MT3",
                [4] = "MT4",
                [5] = "MT5",
                [6] = "MT6",
                [7] = "MT7",
                [8] = "MT8",
                [9] = L["DISPEL"],
            },
            Restaktion = "ffa",
            Klassengruppen = {
                [1] = {},
                [2] = {},
                [3] = {},
                [4] = {},
                [5] = {},
                [6] = {},
                [7] = {},
                [8] = {},
                [9] = {},
            }
        },
    },
	{
        [L["SET_DEFAULT"]] = {
            Name = L["SET_DEFAULT"],
            Beschriftungen = {
                [1] = "SKULL",
                [2] = "CROSS",
                [3] = "SQUARE",
                [4] = "MOON",
                [5] = "TRIANGLE",
                [6] = "DIAMOND",
                [7] = "CIRCLE",
                [8] = "STAR",
				[9] = "",
            },
            Restaktion = "Nightfall",
            Klassengruppen = {
                [1] = {},
                [2] = {},
                [3] = {},
                [4] = {},
                [5] = {},
                [6] = {},
                [7] = {},
                [8] = {},
				[9] = {},
            }
        },
    },
	{
        [L["SET_DEFAULT"]] = {
            Name = L["SET_DEFAULT"],
            Beschriftungen = {
                [1] = "SKULL",
                [2] = "CROSS",
                [3] = "SQUARE",
                [4] = "MOON",
                [5] = "TRIANGLE",
                [6] = "DIAMOND",
                [7] = "CIRCLE",
                [8] = "STAR",
				[9] = "",
            },
            Restaktion = "DPS",
            Klassengruppen = {
                [1] = {},
                [2] = {},
                [3] = {},
                [4] = {},
                [5] = {},
                [6] = {},
                [7] = {},
                [8] = {},
				[9] = {},
            }
        },
    },
	{
        [L["SET_DEFAULT"]] = {
            Name = L["SET_DEFAULT"],
            Beschriftungen = {
				[1] = "SKULL",
                [2] = "CROSS",
                [3] = "SQUARE",
                [4] = "MOON",
                [5] = "TRIANGLE",
                [6] = "DIAMOND",
                [7] = "CIRCLE",
                [8] = "STAR",
				[9] = "",
            },
            Restaktion = "",
            Klassengruppen = {
                [1] = {},
                [2] = {},
                [3] = {},
                [4] = {},
                [5] = {},
                [6] = {},
                [7] = {},
                [8] = {},
				[9] = {},
            }
        },
    },
	{
        [L["SET_DEFAULT"]] = {
            Name = L["SET_DEFAULT"],
            Beschriftungen = {
                [1] = "Element",
                [2] = "Shadow",
                [3] = "Recklessness",
                [4] = "Weakness",
                [5] = "Doom",
                [6] = "Agony",
				[7] = "",
				[8] = "",
				[9] = "",
            },
            Restaktion = "None",
            Klassengruppen = {
                [1] = {"WARLOCK"},
                [2] = {"WARLOCK"},
                [3] = {"WARLOCK"},
                [4] = {},
                [5] = {},
                [6] = {},
				[7] = {},
				[8] = {},
				[9] = {},
            }
        },
    },
	{
        [L["SET_DEFAULT"]] = {
            Name = L["SET_DEFAULT"],
            Beschriftungen = {
                [1] = "Group 1",
                [2] = "Group 2",
                [3] = "Group 3",
                [4] = "Group 4",
                [5] = "Group 5",
                [6] = "Group 6",
                [7] = "Group 7",
                [8] = "Group 8",
				[9] = "",
            },
            Restaktion = "",
            Klassengruppen = {
                [1] = {"MAGE"},
                [2] = {"MAGE"},
                [3] = {"MAGE"},
                [4] = {"MAGE"},
                [5] = {"MAGE"},
                [6] = {"MAGE"},
                [7] = {"MAGE"},
                [8] = {"MAGE"},
				[9] = {"MAGE"},
            }
        },
    },
	{
        [L["SET_DEFAULT"]] = {
            Name = L["SET_DEFAULT"],
            Beschriftungen = {
                [1] = "Group 1",
                [2] = "Group 2",
                [3] = "Group 3",
                [4] = "Group 4",
                [5] = "Group 5",
                [6] = "Group 6",
                [7] = "Group 7",
                [8] = "Group 8",
				[9] = "",
            },
            Restaktion = "",
            Klassengruppen = {
                [1] = {"PRIEST"},
                [2] = {"PRIEST"},
                [3] = {"PRIEST"},
                [4] = {"PRIEST"},
                [5] = {"PRIEST"},
                [6] = {"PRIEST"},
                [7] = {"PRIEST"},
                [8] = {"PRIEST"},
				[9] = {"PRIEST"},
            }
        },
    },
	{
        [L["SET_DEFAULT"]] = {
            Name = L["SET_DEFAULT"],
            Beschriftungen = {
                [1] = "Group 1",
                [2] = "Group 2",
                [3] = "Group 3",
                [4] = "Group 4",
                [5] = "Group 5",
                [6] = "Group 6",
                [7] = "Group 7",
                [8] = "Group 8",
				[9] = "",
            },
            Restaktion = "",
            Klassengruppen = {
                [1] = {"DRUID"},
                [2] = {"DRUID"},
                [3] = {"DRUID"},
                [4] = {"DRUID"},
                [5] = {"DRUID"},
                [6] = {"DRUID"},
                [7] = {"DRUID"},
                [8] = {"DRUID"},
				[9] = {"DRUID"},
            }
        },
    },
	}
})

RaidOrganizer.CONST = {}
RaidOrganizer.CONST.NUM_GROUPS = { 6, 8, 8, 8, 6, 8, 8, 8}
RaidOrganizer.CONST.NUM_SLOTS = { 8, 3, 5, 2, 1, 1, 1, 1}

--RaidOrganizer.CONST.NUM_GROUPS = { 9, 9, 9, 9, 9, 9, 9, 9}
--RaidOrganizer.CONST.NUM_SLOTS = { 4, 4, 4, 4, 4, 4, 4, 4}

function RaidOrganizer:OnInitialize() -- {{{
    -- Called when the addon is loaded
    --self:SetDebugging(true)
    self:RegisterEvent("CHAT_MSG_WHISPER")
	self:RegisterEvent("CHAT_MSG_ADDON")
	self:RegisterEvent("RAID_ROSTER_UPDATE")
    StaticPopupDialogs["RaidOrganizer_EDITLABEL"] = { --{{{
        text = L["EDIT_LABEL"],
        button1 = TEXT(SAVE),
        button2 = TEXT(CANCEL),
        OnAccept = function(a,b,c)
            -- button gedrueckt, auf GetName/GetParent achten
            self:Debug("accept gedrueckt")
            self:Debug("ID ist "..change_id)
            self:SaveNewLabel(change_id, getglobal(this:GetParent():GetName().."EditBox"):GetText())
        end,
        OnHide = function()
            getglobal(this:GetName().."EditBox"):SetText("")
        end,
        OnShow = function()
            if grouplabels[change_id] ~= nil then
                getglobal(this:GetName().."EditBox"):SetText(grouplabels[change_id])
            end
        end,
	EditBoxOnEnterPressed = function()
            self:SaveNewLabel(change_id, this:GetText())
            this:GetParent():Hide()
        end,
        EditBoxOnEscapePressed = function()
            this:GetParent():Hide();
        end,
        timeout = 0,
        whileDead = 1,
        hideOnEscape = 1,
        hasEditBox = 1,
    }; --}}}
    StaticPopupDialogs["RaidOrganizer_SETSAVEAS"] = { --{{{
        text = L["SET_SAVEAS"],
        button1 = TEXT(SAVE),
        button2 = TEXT(CANCEL),
        OnAccept = function()
            -- button gedrueckt, auf GetName/GetParent achten
            self:SetSaveAs(getglobal(this:GetParent():GetName().."EditBox"):GetText())
        end,
        OnHide = function()
            getglobal(this:GetName().."EditBox"):SetText("")
        end,
        OnShow = function()
        end,
	EditBoxOnEnterPressed = function()
            self:SetSaveAs(getglobal(this:GetParent():GetName().."EditBox"):GetText())
            this:GetParent():Hide()
        end,
        EditBoxOnEscapePressed = function()
            this:GetParent():Hide();
        end,
        timeout = 0,
        whileDead = 1,
        hideOnEscape = 1,
        hasEditBox = 1,
    }; --}}}

	if not current_set then
		current_set = {L["SET_DEFAULT"], L["SET_DEFAULT"], L["SET_DEFAULT"], L["SET_DEFAULT"], L["SET_DEFAULT"], L["SET_DEFAULT"], L["SET_DEFAULT"], L["SET_DEFAULT"]}
	end
	if not raider then
		raider = {{}, {}, {}, {}, {}, {}, {}, {}}
	end

    self:Debug("starte locale")
    -- dialog labels aus locale einstellen {{{
    
    RaidOrganizerDialogEinteilungTitle:SetText(L["ARRANGEMENT"])
    --
    --RaidOrganizerDialogEinteilungRaiderpoolLabel:SetText(L["REMAINS"])
    for i=1, 40 do
        getglobal("RaidOrganizerDialogEinteilungRaiderpoolSlot"..i.."Label"):SetText(L["FREE"])
    end
    RaidOrganizerDialogEinteilungOptionenTitle:SetText(L["OPTIONS"])
    RaidOrganizerDialogEinteilungOptionenAutofill:SetText(L["AUTOFILL"])
	RaidOrganizerDialogEinteilungOptionenMultipleArrangementCheckBoxText:SetText(L["MULTIPLE_ARRANGEMENT"])
    RaidOrganizerDialogEinteilungStatsTitle:SetText(L["STATS"])
    RaidOrganizerDialogEinteilungRest:SetText(L["REMAINS"])
    RaidOrganizerDialogEinteilungSetsTitle:SetText(L["LABELS"])
    RaidOrganizerDialogEinteilungSetsSave:SetText(TEXT(SAVE))
    RaidOrganizerDialogEinteilungSetsSaveAs:SetText(L["SAVEAS"])
    RaidOrganizerDialogEinteilungSetsDelete:SetText(TEXT(DELETE))
    RaidOrganizerDialogBroadcastTitle:SetText(L["BROADCAST"])
    RaidOrganizerDialogBroadcastChannel:SetText(L["CHANNEL"])
    RaidOrganizerDialogBroadcastRaid:SetText(L["RAID"])
    RaidOrganizerDialogBroadcastWhisperText:SetText(L["WHISPER"]) -- api changed?
	RaidOrganizerDialogBroadcastAutoSyncText:SetText("Sync Send")
	if (IsRaidLeader() or IsRaidOfficer()) then
		RaidOrganizerDialogBroadcastAutoSync:SetChecked(true)
		RaidOrganizerDialogBroadcastSync:SetText("Send Sync")
	else
		RaidOrganizerDialogBroadcastAutoSync:SetChecked(false)
		RaidOrganizerDialogBroadcastSync:SetText("Ask Sync")
	end
    RaidOrganizerDialogClose:SetText(L["CLOSE"])
    RaidOrganizerDialogReset:SetText(L["RESET"])
	RaidOrganizerDialogResetTab:SetText(L["RESETTAB"])
	RaidOrganizerDialogAllRemain:SetText(L["ALLREMAIN"])

    -- }}}
    self:Debug("locale zuende")
    self:Debug("channel aus der DB ist gesetzt auf: \""..self.db.char.chan.."\"")
	
	RaidOrganizer_Tabs = {
			{ "Heal", "Interface\\Icons\\Spell_Holy_GreaterHeal"},
			{ "Tank", "Interface\\Icons\\INV_Shield_03" },
			{ "Kick", "Interface\\Icons\\Ability_Kick" },
			{ "Crowd Control", "Interface\\Icons\\spell_nature_polymorph" },
			{ "Curses", "Interface\\Icons\\Spell_Shadow_ChillTouch" },
			{ "Intel Buff", "Interface\\Icons\\spell_holy_magicalsentry" },
			{ "Stam Buff", "Interface\\Icons\\spell_holy_wordfortitude" },
			{ "MOTW Buff", "Interface\\Icons\\spell_nature_regeneration" },
		};
		
	for i = 1, 8, 1 do
		getglobal("RaidOrganizer_Tab" .. i).tooltiptext = RaidOrganizer_Tabs[i][1];
		getglobal("RaidOrganizer_Tab" .. i):SetNormalTexture(RaidOrganizer_Tabs[i][2]);
		getglobal("RaidOrganizer_Tab" .. i):Show();
		
		getglobal("RaidOrganizerButtonsHorizontalTab" .. i).tooltiptext = RaidOrganizer_Tabs[i][1];
		getglobal("RaidOrganizerButtonsHorizontalTab" .. i):SetNormalTexture(RaidOrganizer_Tabs[i][2]);
		
		getglobal("RaidOrganizerButtonsVerticalTab" .. i).tooltiptext = RaidOrganizer_Tabs[i][1];
		getglobal("RaidOrganizerButtonsVerticalTab" .. i):SetNormalTexture(RaidOrganizer_Tabs[i][2]);
	end
	
	RaidOrganizer_SetTab(1);
	for grp = 1,  9 do
		if grp > RaidOrganizer.CONST.NUM_GROUPS[1] then
			getglobal("RaidOrganizerDialogEinteilungHealGroup" .. grp):Hide();
		end
		for slot = RaidOrganizer.CONST.NUM_SLOTS[1], 10 do
			getglobal("RaidOrganizerDialogEinteilungHealGroup" .. grp .. "Slot" .. slot):Hide();
		end
	end
    -- standard fuer dropdown setzen
    UIDropDownMenu_SetSelectedValue(RaidOrganizerDialogEinteilungSetsDropDown, current_set[RaidOrganizerDialog.selectedTab], current_set[RaidOrganizerDialog.selectedTab]);
	self:ShowButtons()	
    self:LoadCurrentLabels()
	self:RaidOrganizer_AskSync()
	self:RefreshRaiderTable()
	if RaidOrganizerDialog:IsShown() then
		self:UpdateDialogValues()
	end
end -- }}}

function RaidOrganizer:OnEnable() -- {{{
    -- Called when the addon is enabled
end -- }}}

function RaidOrganizer:OnDisable() -- {{{
    -- Called when the addon is disabled
end -- }}}

function RaidOrganizer:RefreshRaiderTable()
	if UnitInRaid('player') then
		local listName = {};
		for i=1, MAX_RAID_MEMBERS do
			if not UnitExists("raid"..i) then
			   
			else
				local unitname = UnitName("raid"..i)
				listName[unitname] = 1
			end
		end
		for i = 1, 9 do
			if raider[i] then
				for name in raider[i] do
					if not listName[name] then
						raider[i][name] = nil
					end
				end
			end
		end
	else
		self:ResetData()
	end
end

function RaidOrganizer:RefreshTables() --{{{
    self:Debug("aktuallisiere tabellen")
    stats = {
        DRUID = 0,
        PRIEST = 0,
        PALADIN = 0,
        SHAMAN = 0,
		WARRIOR = 0,
		ROGUE = 0,
		MAGE = 0,
		WARLOCK = 0,
		HUNTER = 0,
    }
    local gruppen = {
        [1] = 0,
        [2] = 0,
        [3] = 0,
        [4] = 0,
        [5] = 0,
        [6] = 0,
        [7] = 0,
        [8] = 0,
        [9] = 0,
		[10] = 0,
    }
    -- heiler suchen
    for i=1, MAX_RAID_MEMBERS do
        if not UnitExists("raid"..i) then
            -- kein mitglied, also auch kein heiler
        else
            -- prüfen ob er ein heiler ist
            local class,engClass = UnitClass("raid"..i)
            local unitname = UnitName("raid"..i)
			local isClassInTab = nil
			local InGroup = nil
			for j=1, table.getn(classTab[RaidOrganizerDialog.selectedTab]) do
				if engClass == classTab[RaidOrganizerDialog.selectedTab][j] then
					
                -- ist ein heiler, aber schon eingeteilt?
					if raider[RaidOrganizerDialog.selectedTab][unitname] then
						-- schon eingeteilt, nichts machen
						if not raider[RaidOrganizerDialog.selectedTab][unitname][1] then
							for k=2,10 do
								if raider[RaidOrganizerDialog.selectedTab][unitname][k] then
									if gruppen[k] >= self.CONST.NUM_SLOTS[RaidOrganizerDialog.selectedTab] then
								-- schon zu viele, mach ihm zum rest
										raider[RaidOrganizerDialog.selectedTab][unitname][k] = nil
									else
										InGroup = 1
									end
								end
							end
							if InGroup == nil or RaidOrganizerDialogEinteilungOptionenMultipleArrangementCheckBox:GetChecked() == 1 then
								raider[RaidOrganizerDialog.selectedTab][unitname][1] = 1
							end
						elseif RaidOrganizerDialogEinteilungOptionenMultipleArrangementCheckBox:GetChecked() == 1 then
							for k=2,10 do
								if raider[RaidOrganizerDialog.selectedTab][unitname][k] then
									if gruppen[k] >= self.CONST.NUM_SLOTS[RaidOrganizerDialog.selectedTab] then
										raider[RaidOrganizerDialog.selectedTab][unitname][k] = nil
									end
								end
							end
						end
					else
						raider[RaidOrganizerDialog.selectedTab][unitname]={}
						-- nicht eingeteilt, neu, "rest"
						raider[RaidOrganizerDialog.selectedTab][unitname][1] = 1
						position[unitname] = {0,0,0,0,0,0,0,0,0,0}
					end
					for k=1,10 do
						if raider[RaidOrganizerDialog.selectedTab][unitname][k] then
							self:Debug("Group" ..k-1 .. " : " .. raider[RaidOrganizerDialog.selectedTab][unitname][k])
							gruppen[k] = gruppen[k] + 1
						end
					end
					stats[engClass] = stats[engClass] + 1 
					isClassInTab = 1
				end
			end
            if not isClassInTab then
                -- ist kein heiler, nil
                raider[RaidOrganizerDialog.selectedTab][unitname] = {}
            end
        end
    end
    self:Debug("stats generiert")
    self:Debug("raidertabelle aktuallisiert")

    -- raider[...] -> einteilungsarray
    -- einteilung resetten
    einteilung = {
        [1] = {},
        [2] = {},
        [3] = {},
        [4] = {},
        [5] = {},
        [6] = {},
        [7] = {},
        [8] = {},
        [9] = {},
		[10] = {},
    }
    for name, groupTable in pairs(raider[RaidOrganizerDialog.selectedTab]) do
		for i=1,10 do
			if groupTable[i] then
				--DEFAULT_CHAT_FRAME:AddMessage(i .. " " .. name)
				
				table.insert(einteilung[i], name)
			end
		end
    end
    self:Debug("einteilungstabelle aktuallisiert")
    -- einteilungstabelle sortieren (Klasse, Name)
	
	groupIndex = 0
	
    local function SortEinteilung(a, b) --{{{
		if b == nil then return end
		if a == nil then return end
        if (self.db.char.autosort or overrideSort) then
            --[[
            -- Priester,
            -- Druiden,
            -- Paladine,
            -- Schamanen,
            --    NameA,
            --    NameZ
            --]]
            local unitIDa = self:GetUnitByName(a)
            local unitIDb = self:GetUnitByName(b)
            local classA, engClassA = UnitClass(unitIDa)
            local classB, engClassB = UnitClass(unitIDb)
            if engClassA ~= engClassB then
                    -- unterscheidung an der Klasse
                    -- ecken abfangen
					if engClassA == "WARRIOR" then -- (Priest, *)
                            return true
                    end
                    if engClassB == "WARRIOR" then -- (*, Priest)
                            return false
                    end
					if engClassA == "ROGUE" then -- (Priest, *)
                            return true
                    end
                    if engClassB == "ROGUE" then -- (*, Priest)
                            return false
                    end
					if engClassA == "MAGE" then -- (Priest, *)
                            return true
                    end
                    if engClassB == "MAGE" then -- (*, Priest)
                            return false
                    end
					if engClassA == "WARLOCK" then -- (Priest, *)
                            return true
                    end
                    if engClassB == "WARLOCK" then -- (*, Priest)
                            return false
                    end
					if engClassA == "HUNTER" then -- (Priest, *)
                            return true
                    end
                    if engClassB == "HUNTER" then -- (*, Priest)
                            return false
                    end
                    if engClassA == "PRIEST" then -- (Priest, *)
                            return true
                    end
                    if engClassB == "PRIEST" then -- (*, Priest)
                            return false
                    end
                    if engClassA == "SHAMAN" then -- (*, Shaman)
                            return true
                    end
                    if engClassB == "SHAMAN" then -- (Shaman, *)
                            return false
                    end
                    -- inneren zwei
                    if engClassA == "DRUID" then -- (Druid, *)
                            return true
                    end
                    if engClassB == "DRUID" then -- (*, Druid)
                            return false
                    end
                    if engClassA == "PALADIN" then -- (*, Paladin)
                            return true
                    end
                    if engClassB == "PALADIN" then -- (Paladin, *)
                            return false
                    end
            else
                    -- klassen sind gleich, nach namen sortieren
                    return a<b
            end
            return true
		else 
            if (position[a][groupIndex] and position[b][groupIndex]) then
                self:Debug("sortdebug: ("..a..")"..position[a][groupIndex].." < ("..b..")"..position[b][groupIndex])
                if position[a][groupIndex] == position[b][groupIndex] and lastAction["position"][groupIndex] then
                    if lastAction["position"][groupIndex] == 0 then
                        if a == lastAction["name"] then -- Spieler a wurde verschoben
                            self:Debug("sortdebug: a aus anderer grp - nach unten verschieben")
                            return true
                        elseif b == lastAction["name"] then -- Spieler b wurde verschoben
                            self:Debug("sortdebug: b aus anderer grp - nach unten verschieben")
                            return false
                        end
                        return true
                    end
                    --Sonderfall - kann nur eintreten wenn ein Spieler AUF einen anderen gezogen wurde - also hier in die Richtung verschieben aus der der alte Spieler kommt
                    --lastAction ist die letzte Aktion die ausgefuehrt wurde + Position von der bewegt wurde
                    if a == lastAction["name"] then -- Spieler a wurde verschoben
                        if lastAction["position"][groupIndex] > position[a][groupIndex] then-- kommt von Unten
                            self:Debug("sortdebug: a, von unten")
                            return true
                        else
                            self:Debug("sortdebug: a, von oben")
                            return false
                        end
                    elseif b == lastAction["name"] then -- Spieler b wurde verschoben
                        if lastAction["position"][groupIndex] > position[b][groupIndex] then-- kommt von Unten
                            self:Debug("sortdebug: b, von unten")
                            return false
                        else
                            self:Debug("sortdebug: b, von oben")
                            return true
                        end
                    end
                end
                return position[a][groupIndex] < position[b][groupIndex]
            end
            return true
        end
    end --}}}
    for key, _ in pairs(einteilung) do
        if key == 1 then --Nicht zugeordnete Heiler werden immer sortiert
                overrideSort = true
        end
		groupIndex = key
        table.sort(einteilung[key], SortEinteilung)
        --Positionen entsprechend dem Index updaten 
        for index, name in pairs(einteilung[key]) do
			if not position[name] then
				position[name] = {0,0,0,0,0,0,0,0,0,0}
			end
            position[name][key] = index
        end
        overrideSort = false
    end
end -- }}}

function RaidOrganizer_Tab_OnClick(id)
	if ( not id ) then
		id = this:GetID();
	end
	RaidOrganizer_SetTab(id);
end

function RaidOrganizer_SetTab(id)
	getglobal("RaidOrganizer_Tab" .. id):SetChecked(1);
	for i=1,8 do
		if i ~= id then
			getglobal("RaidOrganizer_Tab" .. i):SetChecked(nil);
		end
	end

	RaidOrganizerDialog.selectedTab = id;
	RaidOrganizerDialogEinteilungTitle:SetText(RaidOrganizer_Tabs[id][1]);
	UIDropDownMenu_SetSelectedValue(RaidOrganizerDialogEinteilungSetsDropDown, current_set[RaidOrganizerDialog.selectedTab], current_set[RaidOrganizerDialog.selectedTab]);
	RaidOrganizer:LoadCurrentLabels()
	RaidOrganizer:UpdateDialogValues();
end

function RaidOrganizer:Dialog() -- {{{
    -- bei einem leeren raid die heilerzuteilung loeschen
    if GetNumRaidMembers() == 0 then
        self:ResetData()
    end
    self:UpdateDialogValues()
    if RaidOrganizerDialog:IsShown() then
        self:Debug("schliessen")
        RaidOrganizerDialog:Hide()
    else
        self:Debug("Zeige dialog")
        RaidOrganizerDialog:Show()
    end
end -- }}}

function RaidOrganizer:UpdateDialogValues() -- {{{
    self:RefreshTables()
	
	local function resizeLayout(size, moreRemain)
		getglobal("RaidOrganizerDialogEinteilungRaiderpool"):SetWidth(size)
		for grp = 1,  9 do
			for slot = 1, 10 do
				getglobal("RaidOrganizerDialogEinteilungHealGroup" .. grp .. "Slot" .. slot):SetWidth(size)
			end
			getglobal("RaidOrganizerDialogEinteilungHealGroup".. grp):SetWidth(size)
		end
		if moreRemain then
			getglobal("RaidOrganizerDialogEinteilungHealGroup".. 1):SetPoint("TOPLEFT", RaidOrganizerDialogEinteilungRaiderpool, "TOPRIGHT", size + 10, 0 )
		else
			getglobal("RaidOrganizerDialogEinteilungHealGroup".. 1):SetPoint("TOPLEFT", RaidOrganizerDialogEinteilungRaiderpool, "TOPRIGHT", 10, 0 )
		end
		for i=1, 72 do	
			if i < 41 then
				getglobal("RaidOrganizerDialogEinteilungRaiderpoolSlot"..i):SetWidth(size)
				if i > 24 then
					if moreRemain then
						getglobal("RaidOrganizerDialogEinteilungRaiderpoolSlot"..i):Show()
					else
						getglobal("RaidOrganizerDialogEinteilungRaiderpoolSlot"..i):Hide()
					end
				end
			end
			getglobal("RaidOrganizerDialogButton"..i):SetWidth(size)
		end

	end
	
	--if too many people in raid
	local total_remain = 0
	if einteilung[1] then 
		total_remain = table.getn(einteilung[1])
	end
	
	if total_remain > 24 and not moreThan24Display then
		resizeLayout(80, true)
		moreThan24Display = true
	elseif total_remain <= 24 and moreThan24Display then
		resizeLayout(98, false)
		moreThan24Display = false
	end
		
    -- stats aktuallisieren {{{
	local classes = classTab[RaidOrganizerDialog.selectedTab]
	for grp = 1,  9 do
		if grp > RaidOrganizer.CONST.NUM_GROUPS[RaidOrganizerDialog.selectedTab] then
			getglobal("RaidOrganizerDialogEinteilungHealGroup" .. grp):Hide();
		else
			getglobal("RaidOrganizerDialogEinteilungHealGroup" .. grp):Show();
		end
		getglobal("RaidOrganizerDialogEinteilungHealGroup" .. grp):SetHeight(131-(10-RaidOrganizer.CONST.NUM_SLOTS[RaidOrganizerDialog.selectedTab])*13)
		for slot = 1, 10 do
			if slot > RaidOrganizer.CONST.NUM_SLOTS[RaidOrganizerDialog.selectedTab] then
				getglobal("RaidOrganizerDialogEinteilungHealGroup" .. grp .. "Slot" .. slot):Hide();
			else
				getglobal("RaidOrganizerDialogEinteilungHealGroup" .. grp .. "Slot" .. slot):Show();
			end
		end
	end
	if(GetNumRaidMembers() == 0) then
		getglobal("RaidOrganizerDialogEinteilungStatsClass" .. 1):SetText("NOT IN RAID")
		getglobal("RaidOrganizerDialogEinteilungStatsClass" .. 1):SetTextColor(1,0,0)
		RaidOrganizerDialogEinteilungStats:SetHeight(38)
		for i=2, 6 do
			getglobal("RaidOrganizerDialogEinteilungStatsClass" .. i):SetText("")
		end
	else
		for i=1, 6 do
			if i <= table.getn(classes) then
				getglobal("RaidOrganizerDialogEinteilungStatsClass" .. i):SetText(L[classes[i]]..": "..stats[classes[i]])
				getglobal("RaidOrganizerDialogEinteilungStatsClass" .. i):SetTextColor(RAID_CLASS_COLORS[classes[i]].r,
															   RAID_CLASS_COLORS[classes[i]].g,
															   RAID_CLASS_COLORS[classes[i]].b)
			else
				getglobal("RaidOrganizerDialogEinteilungStatsClass" .. i):SetText("")
			end
		end
		RaidOrganizerDialogEinteilungStats:SetHeight(table.getn(classes)*23+15/table.getn(classes))
	end

    -- slot-lables aktuallisieren {{{
    for j=1, self.CONST.NUM_GROUPS[RaidOrganizerDialog.selectedTab] do
        for i=1, self.CONST.NUM_SLOTS[RaidOrganizerDialog.selectedTab] do
            local slotlabel = getglobal("RaidOrganizerDialogEinteilungHealGroup"..j.."Slot"..i.."Label")
            local slotbutton = getglobal("RaidOrganizerDialogEinteilungHealGroup"..j.."Slot"..i.."Color")
            slotlabel:SetText(self:GetLabelByClass(groupclasses[j][i]))
			-- DEFAULT_CHAT_FRAME:AddMessage(j .. " " .. i .. " " .. self:GetLabelByClass(groupclasses[j][i]))
            local color = RAID_CLASS_COLORS[groupclasses[j][i]];
            if color then
                slotbutton:SetTexture(color.r/1.5, color.g/1.5, color.b/1.5, 0.5)
            else
                slotbutton:SetTexture(0.1, 0.1, 0.1) 
            end
        end
    end
    -- }}}
    -- {{{ gruppen-labels aktuallisieren
    RaidOrganizerDialogEinteilungRaiderpoolLabel:SetText(grouplabels["Rest"])
    for i=1,self.CONST.NUM_GROUPS[RaidOrganizerDialog.selectedTab] do
        getglobal("RaidOrganizerDialogEinteilungHealGroup"..i.."Label"):SetText(self:ReplaceTokens(grouplabels[i]))
    end
    -- }}}
    -- gruppen-klassen aktuallisieren {{{
    -- for i=1, self.CONST.NUM_GROUPS[RaidOrganizerDialog.selectedTab] do
        -- for j=1, self.CONST.NUM_GROUPS[RaidOrganizerDialog.selectedTab] do
        -- end
    -- end
    -- }}}
    RaidOrganizerDialogBroadcastChannelEditbox:SetText(self.db.char.chan)
    -- einteilungen aktuallisieren -- {{{
    -- alle buttons verstecken
    for i=1, 72 do
        getglobal("RaidOrganizerDialogButton"..i):ClearAllPoints()
        getglobal("RaidOrganizerDialogButton"..i):Hide()
    end
    local zaehler = 1
    -- Rest {{{
    for i=1, table.getn(einteilung[1]) do
        -- max 20 durchläufe
        if zaehler > 72 then
            -- zu viel, abbrechen
            break
        end
        local button = getglobal("RaidOrganizerDialogButton"..zaehler)
        local buttonlabel = getglobal(button:GetName().."Label")
        local buttoncolor = getglobal(button:GetName().."Color")
        -- habe den Button an sich, das Label und die Farbe, einstellen
        buttonlabel:SetText(einteilung[1][i])
        local class, engClass = UnitClass(self:GetUnitByName(einteilung[1][i]))
        local color = RAID_CLASS_COLORS[engClass];
        if color then
            buttoncolor:SetTexture(color.r, color.g, color.b)
        end
        -- ancher und position einstellen
        button:SetPoint("TOP", "RaidOrganizerDialogEinteilungRaiderpoolSlot"..i)
        button:Show()
        -- username im button speichern
        button.username = einteilung[1][i]
        zaehler = zaehler + 1
    end
    -- }}}
    -- MTs {{{
	-- for name, groupTable in pairs(raider[RaidOrganizerDialog.selectedTab]) do
		-- for i=1,10 do
			-- if groupTable[i] then
				-- DEFAULT_CHAT_FRAME:AddMessage(i .. " " .. name)
				
				-- --table.insert(einteilung[i], name)
			-- end
		-- end
    -- end
    for j=1, self.CONST.NUM_GROUPS[RaidOrganizerDialog.selectedTab] do
		--DEFAULT_CHAT_FRAME:AddMessage(table.getn(einteilung[j+1]))
        for i=1, table.getn(einteilung[j+1]) do
            -- max 20 durchläufe
            if zaehler > 72 then
                -- zu viel, abbrechen
                break
            end
			--DEFAULT_CHAT_FRAME:AddMessage(j .. " " .. einteilung[j+1][i])
            local button = getglobal("RaidOrganizerDialogButton"..zaehler)
            local buttonlabel = getglobal(button:GetName().."Label")
            local buttoncolor = getglobal(button:GetName().."Color")
            -- habe den Button an sich, das Label und die Farbe, einstellen
            buttonlabel:SetText(einteilung[j+1][i])
            local class, engClass = UnitClass(self:GetUnitByName(einteilung[j+1][i]))
            local color = RAID_CLASS_COLORS[engClass];
            if color then
                buttoncolor:SetTexture(color.r, color.g, color.b)
            end
            -- ancher und position einstellen
            button:SetPoint("TOP", "RaidOrganizerDialogEinteilungHealGroup"..j.."Slot"..i)
            button:Show()
            -- username im button speichern
			
            button.username = einteilung[j+1][i]
            zaehler = zaehler + 1
        end
    end
    -- }}}
    -- }}}
    -- {{{ Sets aktuallisieren 
    local function RaidOrganizer_changeSet(set)
        self:Debug("aendern auf :"..set)
        UIDropDownMenu_SetSelectedValue(RaidOrganizerDialogEinteilungSetsDropDown, set, set)
        -- raider temp save
        tempsetup[current_set[RaidOrganizerDialog.selectedTab]] = {} -- komplett neu bzw. ueberschreiben
        for name, einteilung in pairs(raider[RaidOrganizerDialog.selectedTab]) do
			tempsetup[current_set[RaidOrganizerDialog.selectedTab]][name]={}
            for i = 1, 10 do
				tempsetup[current_set[RaidOrganizerDialog.selectedTab]][name][i] = einteilung[i]
			end
        end
        current_set[RaidOrganizerDialog.selectedTab] = set
        self:LoadCurrentLabels()
        self:UpdateDialogValues()
    end
    local function RaidOrganizerDropDown_Initialize()
        local selectedValue = UIDropDownMenu_GetSelectedValue(RaidOrganizerDialogEinteilungSetsDropDown)  
        local info

        -- aus DB fuellen
        for key, value in pairs(self.db.account.sets[RaidOrganizerDialog.selectedTab]) do
            info = {}
            info.text = key
            info.value = key
            info.func = RaidOrganizer_changeSet
            info.arg1 = key
            self:Debug("value ist :"..info.value)
            self:Debug(selectedValue)
            if ( info.value == selectedValue ) then 
                info.checked = 1; 
            end
            UIDropDownMenu_AddButton(info);
        end
    end
    -- }}} 
    -- dropdown initialisieren
    UIDropDownMenu_Initialize(RaidOrganizerDialogEinteilungSetsDropDown, RaidOrganizerDropDown_Initialize); 
    UIDropDownMenu_Refresh(RaidOrganizerDialogEinteilungSetsDropDown)
    UIDropDownMenu_SetWidth(150, RaidOrganizerDialogEinteilungSetsDropDown); 
end -- }}}

function RaidOrganizer:ResetTab() -- {{{
    -- einfach alle heiler löschen und neu bauen
    self:Debug("einteilung resetten") 
    raider[RaidOrganizerDialog.selectedTab] = {}
	einteilung = {}
    self:Debug("slotlabels resetten")
    groupclasses = {}
    for i=1, 9 do
        groupclasses[i] = {}
    end
    self:UpdateDialogValues()
end -- }}}

function RaidOrganizer:ResetData() -- {{{
    -- einfach alle heiler löschen und neu bauen
    self:Debug("einteilung resetten") 
    raider = {{},{},{},{},{},{},{},{},}
	einteilung = {}
    self:Debug("slotlabels resetten")
    groupclasses = {}
    for i=1, 9 do
        groupclasses[i] = {}
    end
	if RaidOrganizerDialog:IsShown() then
		self:UpdateDialogValues()
	end
end -- }}}

function RaidOrganizer:BroadcastChan() --{{{
    self:Debug("broadcast to chan")
    -- bin ich im chan?
    if GetNumRaidMembers() == 0 then
        self:ErrorMessage(L["NOT_IN_RAID"])
        return;
    end
    local id, name = GetChannelName(self.db.char.chan)
    local messages = self:BuildMessages()
    self:Debug("sende nachrichten in den chan "..self.db.char.chan)
    for _, message in pairs(messages) do
		ChatThrottleLib:SendChatMessage("NORMAL", nil, message, "CHANNEL", nil, id)
    end
    self:SendToRaiders()
end -- }}}

function RaidOrganizer:BroadcastRaid() -- {{{
    self:Debug("broadcast to raid")
    if GetNumRaidMembers() == 0 then
        self:CustomPrint(1, 0.2, 0.2, self.printFrame, nil, " ", L["NOT_IN_RAID"])
        return;
    end
    local messages = self:BuildMessages()
    for _, message in pairs(messages) do
        ChatThrottleLib:SendChatMessage("NORMAL", nil, message, "RAID")
    end
    self:SendToRaiders()
end -- }}}

function RaidOrganizer:BuildMessages() -- {{{
    local messages = {}
    table.insert(messages, L["HEALARRANGEMENT" .. tostring(RaidOrganizerDialog.selectedTab)]..":")
    -- 1-5, rest
    -- {{{ gruppen
    for i=1, self.CONST.NUM_GROUPS[RaidOrganizerDialog.selectedTab] do
        local header = getglobal("RaidOrganizerDialogEinteilungHealGroup"..i.."Label"):GetText()
        if getn(einteilung[i+1]) ~= 0 then
            local names={}
            for _, name in pairs(einteilung[i+1]) do
                if UnitExists(self:GetUnitByName(name)) then
                    table.insert(names, name)
                end
            end
            table.insert(messages, getglobal("RaidOrganizerDialogEinteilungHealGroup".. tostring(i) .."Label"):GetText()..": "..table.concat(names, ", "))
        end
    end
    -- }}}
    -- {{{ Rest
    local action = RaidOrganizerDialogEinteilungRestAction:GetText()
    if "" == action then
        action = L["FFA"]
    end
    table.insert(messages, L["REMAINS"]..": "..action)
    -- }}}
    table.insert(messages, L["MSG_HEAL_FOR_ARRANGEMENT"])
    return messages
end -- }}}

function RaidOrganizer:SendToRaiders() -- {{{
    -- {{{ gruppen
    local whisper = RaidOrganizerDialogBroadcastWhisper:GetChecked()
    if whisper then
        for i=1, self.CONST.NUM_GROUPS[RaidOrganizerDialog.selectedTab] do
            local header = getglobal("RaidOrganizerDialogEinteilungHealGroup"..i.."Label"):GetText()
            if getn(einteilung[i+1]) ~= 0 then
                for _, name in pairs(einteilung[i+1]) do
                    if UnitExists(self:GetUnitByName(name)) then
                        ChatThrottleLib:SendChatMessage("NORMAL", nil, string.format(L["ARRANGEMENT_FOR"], header), "WHISPER", nil, name)
                    end
                end
            end
        end
    end
    -- }}}
end -- }}}

function RaidOrganizer:ChangeChan() -- {{{
    self:Debug("speicher channel")
    self.db.char.chan = RaidOrganizerDialogBroadcastChannelEditbox:GetText()
end -- }}}

function RaidOrganizer:RaiderOnClick(a) -- {{{
    self:Debug("Raider OnClick")
    self:Debug(a)
end -- }}}

function RaidOrganizer:RaiderOnDragStart() -- {{{
    self:Debug("Raider OnDragStart")
    local cursorX, cursorY = GetCursorPosition()
    this:ClearAllPoints();
    this:SetPoint("CENTER", nil, "BOTTOMLEFT", cursorX*GetScreenHeightScale(), cursorY*GetScreenHeightScale());
    this:StartMoving()
    level_of_button = this:GetFrameLevel();
    this:SetFrameLevel(this:GetFrameLevel()+30) -- sehr hoch
end -- }}}

function RaidOrganizer:RaiderOnDragStop() -- {{{
    self:Debug("Raider OnDragStop")
    this:SetFrameLevel(level_of_button)
    this:StopMovingOrSizing()
    -- gucken wo ich bin?
    local pools = {
        "RaidOrganizerDialogEinteilungRaiderpool",
        "RaidOrganizerDialogEinteilungHealGroup1Slot1",
        "RaidOrganizerDialogEinteilungHealGroup1Slot2",
        "RaidOrganizerDialogEinteilungHealGroup1Slot3",
        "RaidOrganizerDialogEinteilungHealGroup1Slot4",
		"RaidOrganizerDialogEinteilungHealGroup1Slot5",
        "RaidOrganizerDialogEinteilungHealGroup1Slot6",
        "RaidOrganizerDialogEinteilungHealGroup1Slot7",
		"RaidOrganizerDialogEinteilungHealGroup1Slot8",
        "RaidOrganizerDialogEinteilungHealGroup1Slot9",
        "RaidOrganizerDialogEinteilungHealGroup1Slot10",
        "RaidOrganizerDialogEinteilungHealGroup2Slot1",
        "RaidOrganizerDialogEinteilungHealGroup2Slot2",
        "RaidOrganizerDialogEinteilungHealGroup2Slot3",
        "RaidOrganizerDialogEinteilungHealGroup2Slot4",
		"RaidOrganizerDialogEinteilungHealGroup2Slot5",
        "RaidOrganizerDialogEinteilungHealGroup2Slot6",
        "RaidOrganizerDialogEinteilungHealGroup2Slot7",
		"RaidOrganizerDialogEinteilungHealGroup2Slot8",
        "RaidOrganizerDialogEinteilungHealGroup2Slot9",
        "RaidOrganizerDialogEinteilungHealGroup2Slot10",
        "RaidOrganizerDialogEinteilungHealGroup3Slot1",
        "RaidOrganizerDialogEinteilungHealGroup3Slot2",
        "RaidOrganizerDialogEinteilungHealGroup3Slot3",
        "RaidOrganizerDialogEinteilungHealGroup3Slot4",
		"RaidOrganizerDialogEinteilungHealGroup3Slot5",
        "RaidOrganizerDialogEinteilungHealGroup3Slot6",
        "RaidOrganizerDialogEinteilungHealGroup3Slot7",
		"RaidOrganizerDialogEinteilungHealGroup3Slot8",
        "RaidOrganizerDialogEinteilungHealGroup3Slot9",
        "RaidOrganizerDialogEinteilungHealGroup3Slot10",
        "RaidOrganizerDialogEinteilungHealGroup4Slot1",
        "RaidOrganizerDialogEinteilungHealGroup4Slot2",
        "RaidOrganizerDialogEinteilungHealGroup4Slot3",
        "RaidOrganizerDialogEinteilungHealGroup4Slot4",
		"RaidOrganizerDialogEinteilungHealGroup4Slot5",
        "RaidOrganizerDialogEinteilungHealGroup4Slot6",
        "RaidOrganizerDialogEinteilungHealGroup4Slot7",
		"RaidOrganizerDialogEinteilungHealGroup4Slot8",
        "RaidOrganizerDialogEinteilungHealGroup4Slot9",
        "RaidOrganizerDialogEinteilungHealGroup4Slot10",
        "RaidOrganizerDialogEinteilungHealGroup5Slot1",
        "RaidOrganizerDialogEinteilungHealGroup5Slot2",
        "RaidOrganizerDialogEinteilungHealGroup5Slot3",
        "RaidOrganizerDialogEinteilungHealGroup5Slot4",
		"RaidOrganizerDialogEinteilungHealGroup5Slot5",
        "RaidOrganizerDialogEinteilungHealGroup5Slot6",
        "RaidOrganizerDialogEinteilungHealGroup5Slot7",
		"RaidOrganizerDialogEinteilungHealGroup5Slot8",
        "RaidOrganizerDialogEinteilungHealGroup5Slot9",
        "RaidOrganizerDialogEinteilungHealGroup5Slot10",
        "RaidOrganizerDialogEinteilungHealGroup6Slot1",
        "RaidOrganizerDialogEinteilungHealGroup6Slot2",
        "RaidOrganizerDialogEinteilungHealGroup6Slot3",
        "RaidOrganizerDialogEinteilungHealGroup6Slot4",
		"RaidOrganizerDialogEinteilungHealGroup6Slot5",
        "RaidOrganizerDialogEinteilungHealGroup6Slot6",
        "RaidOrganizerDialogEinteilungHealGroup6Slot7",
		"RaidOrganizerDialogEinteilungHealGroup6Slot8",
        "RaidOrganizerDialogEinteilungHealGroup6Slot9",
        "RaidOrganizerDialogEinteilungHealGroup6Slot10",
        "RaidOrganizerDialogEinteilungHealGroup7Slot1",
        "RaidOrganizerDialogEinteilungHealGroup7Slot2",
        "RaidOrganizerDialogEinteilungHealGroup7Slot3",
        "RaidOrganizerDialogEinteilungHealGroup7Slot4",
		"RaidOrganizerDialogEinteilungHealGroup7Slot5",
        "RaidOrganizerDialogEinteilungHealGroup7Slot6",
        "RaidOrganizerDialogEinteilungHealGroup7Slot7",
		"RaidOrganizerDialogEinteilungHealGroup7Slot8",
        "RaidOrganizerDialogEinteilungHealGroup7Slot9",
        "RaidOrganizerDialogEinteilungHealGroup7Slot10",
        "RaidOrganizerDialogEinteilungHealGroup8Slot1",
        "RaidOrganizerDialogEinteilungHealGroup8Slot2",
        "RaidOrganizerDialogEinteilungHealGroup8Slot3",
        "RaidOrganizerDialogEinteilungHealGroup8Slot4",
		"RaidOrganizerDialogEinteilungHealGroup8Slot5",
        "RaidOrganizerDialogEinteilungHealGroup8Slot6",
        "RaidOrganizerDialogEinteilungHealGroup8Slot7",
		"RaidOrganizerDialogEinteilungHealGroup8Slot8",
        "RaidOrganizerDialogEinteilungHealGroup8Slot9",
        "RaidOrganizerDialogEinteilungHealGroup8Slot10",
        "RaidOrganizerDialogEinteilungHealGroup9Slot1",
        "RaidOrganizerDialogEinteilungHealGroup9Slot2",
        "RaidOrganizerDialogEinteilungHealGroup9Slot3",
        "RaidOrganizerDialogEinteilungHealGroup9Slot4",
		"RaidOrganizerDialogEinteilungHealGroup9Slot5",
        "RaidOrganizerDialogEinteilungHealGroup9Slot6",
        "RaidOrganizerDialogEinteilungHealGroup9Slot7",
		"RaidOrganizerDialogEinteilungHealGroup9Slot8",
        "RaidOrganizerDialogEinteilungHealGroup9Slot9",
        "RaidOrganizerDialogEinteilungHealGroup9Slot10",
    }
    for _, pool in pairs(pools) do
		local _,_,group,slot = string.find(pool, "RaidOrganizerDialogEinteilungHealGroup(%d+)Slot(%d+)");
		group,slot = tonumber(group),tonumber(slot)
		if ( (group == nil) or ((group <= self.CONST.NUM_GROUPS[RaidOrganizerDialog.selectedTab]) and (slot <= self.CONST.NUM_SLOTS[RaidOrganizerDialog.selectedTab]))) then
			poolframe = getglobal(pool)
			if MouseIsOver(poolframe) then
				self:Debug("Bin ueber "..poolframe:GetName())
				if (slot and group) then
						self:Debug("Parent RaidOrganizerDialogEinteilungHealGroup"..group.." und slot: "..slot)
				end
				self:Debug("ich habe "..this:GetName())
				--self:Debug("vorher "..raider[RaidOrganizerDialog.selectedTab][this.username])
				-- den heiler da zuordnen
				if "RaidOrganizerDialogEinteilungRaiderpool" == pool then
					raider[RaidOrganizerDialog.selectedTab][this.username][1] = 1
					for k=2,10 do
						raider[RaidOrganizerDialog.selectedTab][this.username][k]=nil
						position[this.username][k] = 0
					end
					position[this.username][1] = 0
				else
					if group >= 1 and group <= self.CONST.NUM_GROUPS[RaidOrganizerDialog.selectedTab] then
							lastAction["group"] = raider[RaidOrganizerDialog.selectedTab][this.username]
							if RaidOrganizerDialogEinteilungOptionenMultipleArrangementCheckBox:GetChecked() == nil then
								for k=1,10 do
									raider[RaidOrganizerDialog.selectedTab][this.username][k] = nil
								end
							end
							raider[RaidOrganizerDialog.selectedTab][this.username][group+1] = 1	
					end
					if slot >= 1 and slot <= self.CONST.NUM_SLOTS[RaidOrganizerDialog.selectedTab] then
							lastAction["name"] = this.username
							--Nur setzen wenn innerhalb einer Gruppe verschoben wird, 0 = Kommt von ausserhalb und wird an der position eingefuegt und Gruppe nach unten verschoben
							for k=1,10 do
								if lastAction["group"][k] then
									lastAction["position"][k] = position[this.username][k]
								else
									lastAction["position"][k] = 0
								end
							end
							--neue Position
							position[this.username][group+1] = slot
					end
				end
				break
			end
		end
    end
    -- positionen aktuallisieren
    self:UpdateDialogValues()
end -- }}}

function RaidOrganizer:RaiderOnLoad() -- {{{
    self:Debug("OnLoad")
    -- 0 = pool, MT1-M5
    -- 1 = slots
    -- 2 = passt ;)
    this:SetFrameLevel(this:GetFrameLevel() + 2)
    this:RegisterForDrag("LeftButton")
	--if not raider or (not table.getn(raider) == 8) then
		-- raider = {{},{},{},{},{},{},{},{},}
	--end
	--if not current_set or (not table.getn(current_set) == 8) then
	--	current_set = {L["SET_DEFAULT"], L["SET_DEFAULT"], L["SET_DEFAULT"], L["SET_DEFAULT"], L["SET_DEFAULT"], L["SET_DEFAULT"], L["SET_DEFAULT"], L["SET_DEFAULT"]}
		-- raider = {{},{},{},{},{},{},{},{},}
	--end
	-- RaidOrganizer:RefreshRaiderTable()
end -- }}}

function RaidOrganizer:EditGroupLabel(group) -- {{{
    self:Debug(group:GetName())
    self:Debug(group:GetID())
    if group:GetID() == 0 then
        return -- Rest nicht bearbeiten
    end
    change_id = group:GetID()
    StaticPopup_Show("RaidOrganizer_EDITLABEL", group:GetID())    
end -- }}}

function RaidOrganizer:SaveNewLabel(id, text) -- {{{
    if id == 0 then
        return
    end
    if text == "" then
        return
    end
    if grouplabels[id] ~= nil then
        grouplabels[id] = text
        self:UpdateDialogValues()
    end
end -- }}}

function RaidOrganizer:LoadLabelsFromSet(set) -- {{{
    if not set then
        return nil
    end
    if self.db.account.sets[RaidOrganizerDialog.selectedTab][set] then
        grouplabels.Rest = L["REMAINS"]
        groupclasses = {}
        for i=1, self.CONST.NUM_GROUPS[RaidOrganizerDialog.selectedTab] do
            grouplabels[i] = self.db.account.sets[RaidOrganizerDialog.selectedTab][set].Beschriftungen[i]
            groupclasses[i] = {}
            for j=1, self.CONST.NUM_SLOTS[RaidOrganizerDialog.selectedTab] do
                groupclasses[i][j] = self.db.account.sets[RaidOrganizerDialog.selectedTab][set].Klassengruppen[i][j]
            end
        end
        RaidOrganizerDialogEinteilungRestAction:SetText(self.db.account.sets[RaidOrganizerDialog.selectedTab][set].Restaktion)
        if tempsetup[set] then
            -- laden
            raider = {{},{},{},{},{},{},{},{},} -- reset
            for name, einteilung in pairs(tempsetup[set]) do
                raider[RaidOrganizerDialog.selectedTab][name] = einteilung
            end
        end
        return true
    end
    return nil
end -- }}}

function RaidOrganizer:LoadCurrentLabels() -- {{{
    if not self:LoadLabelsFromSet(current_set[RaidOrganizerDialog.selectedTab]) then
        self:LoadLabelsFromSet(L["SET_DEFAULT"])
    end
end -- }}}

function RaidOrganizer:SetSave() -- {{{
    self:Debug("set speichern")
    if current_set[RaidOrganizerDialog.selectedTab] == L["SET_DEFAULT"] then
        self:ErrorMessage(L["SET_CANNOT_SAVE_DEFAULT"])
        return
    end
    self.db.account.sets[RaidOrganizerDialog.selectedTab][current_set[RaidOrganizerDialog.selectedTab]].Beschriftungen = {}
    self.db.account.sets[RaidOrganizerDialog.selectedTab][current_set[RaidOrganizerDialog.selectedTab]].Klassengruppen = {}
    for i=1, self.CONST.NUM_GROUPS[RaidOrganizerDialog.selectedTab] do
        self.db.account.sets[RaidOrganizerDialog.selectedTab][current_set[RaidOrganizerDialog.selectedTab]].Beschriftungen[i] = grouplabels[i]
        self.db.account.sets[RaidOrganizerDialog.selectedTab][current_set[RaidOrganizerDialog.selectedTab]].Klassengruppen[i] = {}
        for j=1, self.CONST.NUM_SLOTS[RaidOrganizerDialog.selectedTab] do
            self.db.account.sets[RaidOrganizerDialog.selectedTab][current_set[RaidOrganizerDialog.selectedTab]].Klassengruppen[i][j] = groupclasses[i][j]
        end
    end
    self.db.account.sets[RaidOrganizerDialog.selectedTab][current_set[RaidOrganizerDialog.selectedTab]].Restaktion = RaidOrganizerDialogEinteilungRestAction:GetText()
end -- }}}

function RaidOrganizer:SetSaveAs(name) -- {{{
    if not name then
        return
    end
    if name == "" then
        return
    end
    if name == L["SET_DEFAULT"] then
        self:ErrorMessage(L["SET_CANNOT_SAVE_DEFAULT"])
        return
    end
    local count = 0
    for a,b in pairs(self.db.account.sets[RaidOrganizerDialog.selectedTab]) do
        count = count+1
    end
    self:Debug("anzahl sets:" ..count)
    if count >= 32 then
        self:ErrorMessage(L["SET_TO_MANY_SETS"])
        return
    end
    self:Debug("set speichern als :"..name)
    if self.db.account.sets[RaidOrganizerDialog.selectedTab][name] then
        self:ErrorMessage(string.format(L["SET_ALREADY_EXISTS"], name))
        return
    end
    -- anlegen
    self.db.account.sets[RaidOrganizerDialog.selectedTab][name] = {}
    self.db.account.sets[RaidOrganizerDialog.selectedTab][name].Name = name
    self.db.account.sets[RaidOrganizerDialog.selectedTab][name].Beschriftungen = {}
    self.db.account.sets[RaidOrganizerDialog.selectedTab][name].Klassengruppen = {}
    for i=1, self.CONST.NUM_GROUPS[RaidOrganizerDialog.selectedTab] do
        self.db.account.sets[RaidOrganizerDialog.selectedTab][name].Beschriftungen[i] = grouplabels[i]
        self.db.account.sets[RaidOrganizerDialog.selectedTab][name].Klassengruppen[i] = {}
        for j=1, self.CONST.NUM_SLOTS[RaidOrganizerDialog.selectedTab] do
            self.db.account.sets[RaidOrganizerDialog.selectedTab][name].Klassengruppen[i][j] = groupclasses[i][j]
        end
    end
    self.db.account.sets[RaidOrganizerDialog.selectedTab][name].Restaktion = RaidOrganizerDialogEinteilungRestAction:GetText()
    current_set[RaidOrganizerDialog.selectedTab] = name
    self:LoadCurrentLabels()
    UIDropDownMenu_SetSelectedValue(RaidOrganizerDialogEinteilungSetsDropDown, current_set[RaidOrganizerDialog.selectedTab])
    UIDropDownMenu_Refresh(RaidOrganizerDialogEinteilungSetsDropDown)
    self:UpdateDialogValues()
end -- }}}

function RaidOrganizer:SetDelete() -- {{{
    if current_set[RaidOrganizerDialog.selectedTab] == L["SET_DEFAULT"] then
        self:ErrorMessage(L["SET_CANNOT_DELETE_DEFAULT"])
        return
    end
    self:Debug("set loeschen")
    if not self.db.account.sets[RaidOrganizerDialog.selectedTab][current_set[RaidOrganizerDialog.selectedTab]] then
        return
    end
    self.db.account.sets[RaidOrganizerDialog.selectedTab][current_set[RaidOrganizerDialog.selectedTab]] = nil
    current_set[RaidOrganizerDialog.selectedTab] = L["SET_DEFAULT"]
    UIDropDownMenu_SetSelectedValue(RaidOrganizerDialogEinteilungSetsDropDown, current_set[RaidOrganizerDialog.selectedTab])
    self:LoadCurrentLabels()
    self:UpdateDialogValues()
end -- }}}

function RaidOrganizer:ErrorMessage(str) -- {{{
    if not str then
        return
    end
    if str == "" then
        return
    end
    self:CustomPrint(1, 0.2, 0.2, self.printFrame, nil, " ", str)
end -- }}}

function RaidOrganizer:BuildUnitIDs() -- {{{
    unitids = {}
    for i=1, MAX_RAID_MEMBERS do
        if UnitExists("raid"..i) then
            unitids[UnitName("raid"..i)] = "raid"..i
        end
    end
end -- }}}

function RaidOrganizer:GetUnitByName(str) -- {{{
    if not str then
        return nil
    end
    if not unitids[str] then
        self:BuildUnitIDs()
    end
    if not unitids[str] then
        -- alter Name, raid schon laengst verlassen.
        return "raid41"
    end
    if str ~= UnitName(unitids[str]) then
        self:BuildUnitIDs()
    end
    return unitids[str]
end -- }}}

function RaidOrganizer:ReplaceTokens(str) -- {{{
    -- {{{MTs ersetzen: %MT1% -> MT1(Name) bzw. MT1
    local function GetMainTankLabel(i) -- {{{
        -- MTi(Name) bzw. MTi
        -- CTRaid
        if not i then
            return ""
        end
        if type(i) ~= "number" then
            return ""
        end
        if i < 1 or i > 10 then
            return ""
        end
        local s = L["MT"]..i
        if CT_RATarget then
            self:Debug("CTRAID found, i="..i)
            if CT_RATarget.MainTanks[i] and
                UnitExists("raid"..CT_RATarget.MainTanks[i][1]) and
                UnitName("raid"..CT_RATarget.MainTanks[i][1]) == CT_RATarget.MainTanks[i][2]
                then
                -- MTi vorhanden
                self:Debug("MT"..i.." vorhanden")
                s = s.."("..CT_RATarget.MainTanks[i][2]..")"      
            end
        elseif oRAOMainTank then
            --self:Debug("oRA MT found, i="..i)
            if oRAOMainTank.core.maintanktable[i] and
                UnitExists(self:GetUnitByName(oRAOMainTank.core.maintanktable[i])) and
                UnitName(self:GetUnitByName(oRAOMainTank.core.maintanktable[i])) == oRAOMainTank.core.maintanktable[i]
                then
                self:Debug("oRA MT"..i.." vorhanden")
                s = s.."("..oRAOMainTank.core.maintanktable[i]..")"
            end
        end
        return s
    end -- }}}
    for i=1,10 do
        str = string.gsub(str, "MT"..i, GetMainTankLabel(i))
    end
    -- }}}
    return str
end -- }}}

function RaidOrganizer:CHAT_MSG_WHISPER(msg, user) -- {{{
    if GetNumRaidMembers() == 0 then
        -- bin nicht im raid, also auch keine zuteilung
        return
    end
    self:Debug("Der Spieler "..user.." schrieb: "..msg)
    if msg == "heal" then
        self:Debug("healanfrage")
        local reply = L["REPLY_NO_ARRANGEMENT"]
        if raider[RaidOrganizerDialog.selectedTab][user] then
            -- labels holen
            reply = string.format(L["REPLY_ARRANGEMENT_FOR"], self:ReplaceTokens(grouplabels[raider[RaidOrganizerDialog.selectedTab][user]]))
        end
        self:Debug("Sende Spieler %s den Text %q", user, reply)
        ChatThrottleLib:SendChatMessage("NORMAL", nil, reply, "WHISPER", nil, user)
    end
end -- }}}

function RaidOrganizer:OnMouseWheel(richtung) -- {{{
    if not this then
        return
    end
    self:Debug("Mausrad:")
    self:Debug(this)
    self:Debug(this and this:GetName())
    self:Debug(richtung)
    local _,_,group,slot = string.find(this:GetName(), "RaidOrganizerDialogEinteilungHealGroup(%d+)Slot(%d+)")
    group,slot = tonumber(group),tonumber(slot)
    if not group or not slot then
        self:Debug("kein match o_O")
        self:Debug(group)
        self:Debug(slot)
        return
    end
    self:Debug("group "..group..", slot "..slot)
    if group < 1 or group > self.CONST.NUM_GROUPS[RaidOrganizerDialog.selectedTab] or
        slot < 1 or slot > self.CONST.NUM_SLOTS[RaidOrganizerDialog.selectedTab] then
        self:Debug("out of index...")
        return
    end
	local classdirection = {}
	for k,v in pairs(classTab[RaidOrganizerDialog.selectedTab]) do
		classdirection[k] = v;
	end
	table.insert(classdirection,1,"EMPTY");
	
    -- position im array suchen
    local pos = 1
    while (pos <= table.getn(classdirection)) do
        -- nil abfangen
        if groupclasses[group][slot] then
            if classdirection[pos] == groupclasses[group][slot] then
                break
            end
            -- naechster durchlauf
        else
            -- ist 1/nil/EMPTY
            break
        end
        pos = pos + 1
    end
    -- habe die position
    self:Debug("Label ist "..classdirection[pos])
    -- modulo, % klappte bei mir local nicht o_O
    pos = pos - richtung -- nach unten: PRIEST -> DRUID -> PALADIN -> nil -> PRIEST
    if 0 == pos then
        pos = table.getn(classdirection)
    end
    if table.getn(classdirection)+1 == pos then
        pos = 1
    end
    self:Debug("Neuer label ist "..classdirection[pos])
    if "EMPTY" == classdirection[pos] then
        self:Debug("ist EMPTY")
        groupclasses[group][slot] = nil
    else
        self:Debug("gueltig")
        groupclasses[group][slot] = classdirection[pos]
    end
    self:UpdateDialogValues()
end -- }}}

function RaidOrganizer:GetLabelByClass(class) -- {{{
    if not class then
        return L["FREE"]
    end
    self:Debug("Klasse ist "..class)
    self:Debug("GetLabel: "..class.."-"..L[class])
    return L[class]
end -- }}}

function RaidOrganizer:MultipleArrangementCheckBox_OnClick()
	if RaidOrganizerDialogEinteilungOptionenMultipleArrangementCheckBox:GetChecked() == nil then
		for name, groupTable in pairs(raider[RaidOrganizerDialog.selectedTab]) do
			local count = 0
			for i=2,10 do
				if groupTable[i] then
					count = count + 1
					if (count > 1) then
						groupTable[i] = nil
					end
				end
			end
		end
	end
	self:UpdateDialogValues()
end

function RaidOrganizer:SortGroupClass()
	local function SortEinteilung(a, b) --{{{
		if b == nil then return true end
		if a == nil then return false end
		if a ~= b then
			-- unterscheidung an der Klasse
			-- ecken abfangen
			if a == "WARRIOR" then -- (Priest, *)
					return true
			end
			if b == "WARRIOR" then -- (*, Priest)
					return false
			end
			if a == "ROGUE" then -- (Priest, *)
					return true
			end
			if b == "ROGUE" then -- (*, Priest)
					return false
			end
			if a == "MAGE" then -- (Priest, *)
					return true
			end
			if b == "MAGE" then -- (*, Priest)
					return false
			end
			if a == "WARLOCK" then -- (Priest, *)
					return true
			end
			if b == "WARLOCK" then -- (*, Priest)
					return false
			end
			if a == "HUNTER" then -- (Priest, *)
					return true
			end
			if b == "HUNTER" then -- (*, Priest)
					return false
			end
			if a == "PRIEST" then -- (Priest, *)
					return true
			end
			if b == "PRIEST" then -- (*, Priest)
					return false
			end
			if a == "SHAMAN" then -- (*, Shaman)
					return true
			end
			if b == "SHAMAN" then -- (Shaman, *)
					return false
			end
			-- inneren zwei
			if a == "DRUID" then -- (Druid, *)
					return true
			end
			if b == "DRUID" then -- (*, Druid)
					return false
			end
			if a == "PALADIN" then -- (*, Paladin)
					return true
			end
			if b == "PALADIN" then -- (Paladin, *)
					return false
			end
			if a == "EMPTY" then -- (Paladin, *)
					return true
			end
			if b == "EMPTY" then -- (Paladin, *)
					return false
			end
		else
			-- klassen sind gleich, nach namen sortieren
			return a<b
		end
		return true
    end --}}}
	for i=1, self.CONST.NUM_GROUPS[RaidOrganizerDialog.selectedTab] do
		for j=1, self.CONST.NUM_SLOTS[RaidOrganizerDialog.selectedTab] do
			if groupclasses[i][j] == nil then groupclasses[i][j] = "EMPTY" end
		end
	end
    for i=1, self.CONST.NUM_GROUPS[RaidOrganizerDialog.selectedTab] do
        table.sort(groupclasses[i], SortEinteilung)
	end
	for i=1, self.CONST.NUM_GROUPS[RaidOrganizerDialog.selectedTab] do
		for j=1, self.CONST.NUM_SLOTS[RaidOrganizerDialog.selectedTab] do
			if groupclasses[i][j] == "EMPTY" then groupclasses[i][j] = nil end
		end
	end
end

function RaidOrganizer:SetAllRemain()
	raider[RaidOrganizerDialog.selectedTab] = {}
	einteilung = {}
	self:UpdateDialogValues()
end

function RaidOrganizer:AutoFill() -- {{{
	self:SortGroupClass()
    self:Debug("autofill start")
	if ((RaidOrganizerDialog.selectedTab == 6 or RaidOrganizerDialog.selectedTab == 7 or RaidOrganizerDialog.selectedTab == 8)) then
		self:SetAllRemain()
		local nbBuffer = table.getn(einteilung[1])
		local tableGroup = {}
		for group=1, self.CONST.NUM_GROUPS[RaidOrganizerDialog.selectedTab] do
			for slot=1, self.CONST.NUM_SLOTS[RaidOrganizerDialog.selectedTab] do
				if groupclasses[group][slot] then
					table.insert(tableGroup, group)
					break
				end
			end
		end
		local tableIndex = 1
		local progress = table.getn(tableGroup)/nbBuffer
		for _, name in pairs(einteilung[1]) do
			if tableIndex > table.getn(tableGroup) then break end
			while tableIndex <= progress do
				raider[RaidOrganizerDialog.selectedTab][name][tableGroup[tableIndex]+1] = 1
				tableIndex = tableIndex + 1
				DEFAULT_CHAT_FRAME:AddMessage(tableIndex .. " " .. progress .. " " .. name)
			end
			progress = progress + table.getn(tableGroup)/nbBuffer
		end
		self:UpdateDialogValues()
	elseif (RaidOrganizerDialogEinteilungOptionenMultipleArrangementCheckBox:GetChecked() == nil) then
		for group=1, self.CONST.NUM_GROUPS[RaidOrganizerDialog.selectedTab] do
			for slot=1, self.CONST.NUM_SLOTS[RaidOrganizerDialog.selectedTab] do
				self:Debug("group"..group.."slot"..slot)
				-- gucken ob was auf den slot soll
				if groupclasses[group][slot] then
					-- gucken ob schon was drauf ist
					if not einteilung[group+1][slot] then
						-- ist platz, also draufpacken
						self:Debug("ist platz")
						-- Rest durchlaufen
						for _, name in pairs(einteilung[1]) do
							if raider[RaidOrganizerDialog.selectedTab][name][group+1] == nil then
								-- klasse abfragen
								local class, engClass = UnitClass(self:GetUnitByName(name))
								if engClass == groupclasses[group][slot] then
									-- der spieler passt, einteilen
									raider[RaidOrganizerDialog.selectedTab][name][group+1] = 1
									raider[RaidOrganizerDialog.selectedTab][name][1] = nil
									-- neu aufbauen (impliziert refresh-tables)
									self:UpdateDialogValues()
									break; -- naechster durchlauf
								else
									-- der spieler passt nicht, naechster
								end
							end
						end
					end
				end
			end
		end
	else
		local boolCheck
		for _, name in pairs(einteilung[1]) do
			boolCheck = true
			for group=1, self.CONST.NUM_GROUPS[RaidOrganizerDialog.selectedTab] do
				for slot=1, self.CONST.NUM_SLOTS[RaidOrganizerDialog.selectedTab] do
					if raider[RaidOrganizerDialog.selectedTab][name][group+1] == nil and boolCheck then
						if groupclasses[group][slot] then
							if not einteilung[group+1][slot] then
								local class, engClass = UnitClass(self:GetUnitByName(name))
								if engClass == groupclasses[group][slot] then
									raider[RaidOrganizerDialog.selectedTab][name][group+1] = 1
									self:UpdateDialogValues()
									boolCheck = false
								end
							end
						end
					end
				end
			end
		end
	end
end -- }}}

function RaidOrganizer:TabButton_OnClick(id)
	if ( not id ) then
		id = this:GetID();
	end
	RaidOrganizer_SetTab(id);
	UIDropDownMenu_SetSelectedValue(RaidOrganizerDialogEinteilungSetsDropDown, current_set[RaidOrganizerDialog.selectedTab], current_set[RaidOrganizerDialog.selectedTab]); 
	RaidOrganizer:LoadCurrentLabels()
	RaidOrganizer:Dialog()
end

function RaidOrganizer:ShowButtons()
	if RaidOrganizer.db.char.horizontal then
		RaidOrganizerButtonsVertical:Hide()
		if RaidOrganizerButtonsHorizontal:IsShown() then
			RaidOrganizerButtonsHorizontal:Hide()
		else
			RaidOrganizerButtonsHorizontal:Show()
		end
	else
		RaidOrganizerButtonsHorizontal:Hide()
		if RaidOrganizerButtonsVertical:IsShown() then
			RaidOrganizerButtonsVertical:Hide()
		else
			RaidOrganizerButtonsVertical:Show()
		end
	end
end

function RaidOrganizer:WriteTooltipText(id) 
	GameTooltip:SetText(this.tooltiptext);
	if ( not id ) then
		id = this:GetID();
	end
	local color = {1, 1, 1};
	GameTooltip:AddDoubleLine( "________", "____________", 1, 1, 1, 1, 1, 1);
	local playerNameTable = {}
	for group=1, self.CONST.NUM_GROUPS[id] do
		local groupName = self.db.account.sets[id][current_set[RaidOrganizerDialog.selectedTab]].Beschriftungen[group]
		if groupName == "CROSS" then
			color = {1, 0, 0};
		elseif groupName == "SQUARE" then
			color = {0, 0, 1};
		elseif groupName == "MOON" then
			color = {0.76, 0.92, 0.89};
		elseif groupName == "TRIANGLE" then
			color = {0, 1, 0};
		elseif groupName == "DIAMOND" then
			color = {1, 0, 1};
		elseif groupName == "CIRCLE" then
			color = {1, 0.5, 0};
		elseif groupName == "STAR" then
			color = {1, 1, 0};
		end
		
		playerNameTable = {}
		for nameChar in raider[id] do
			if raider[id][nameChar][group + 1] then
				local _, engClass = UnitClass(self:GetUnitByName(nameChar))
				if playerNameTable[engClass] == nil then
					playerNameTable[engClass] = nameChar
				else
					playerNameTable[engClass] = playerNameTable[engClass] .. ", " .. nameChar
				end
				if UnitName('player') == nameChar then
					playerNameTable[engClass] = "---> " .. playerNameTable[engClass]
				end
			end
		end
		local firstLine = true
		for _,engClassIt in pairs (classTab[id]) do
			if not (playerNameTable[engClassIt] == nil) then
				if (firstLine == true) then
					GameTooltip:AddDoubleLine( groupName .. " : ", playerNameTable[engClassIt], color[1], color[2], color[3], RAID_CLASS_COLORS[engClassIt].r, RAID_CLASS_COLORS[engClassIt].g, RAID_CLASS_COLORS[engClassIt].b);
					firstLine = false
				else
					GameTooltip:AddDoubleLine( "  ", playerNameTable[engClassIt], 0, 0, 0, RAID_CLASS_COLORS[engClassIt].r, RAID_CLASS_COLORS[engClassIt].g, RAID_CLASS_COLORS[engClassIt].b);
				end
			end
		end
		if (firstLine == true) then 
			GameTooltip:AddDoubleLine( groupName .. " : ", "", color[1], color[2], color[3], 1, 1, 1);
		end
		GameTooltip:AddDoubleLine( "________", "____________", 1, 1, 1, 1, 1, 1);
	end
	GameTooltip:Show()
end

------------------------------
--      Event Handlers      --
------------------------------
function RaidOrganizer:RAID_ROSTER_UPDATE()
	self:RefreshRaiderTable()
	if (RaidOrganizerDialogBroadcastAutoSync:GetChecked()) then
		if RaidOrganizerDialog:IsShown() then
			self:UpdateDialogValues()
		end
		for tab = 1, 8 do
			RaidOrganizer:RaidOrganizer_SendSync(tab);
		end
	elseif not UnitInRaid('player') then
		self:ResetData()
	end
end

function RaidOrganizer:CHAT_MSG_ADDON(prefix, message, type, sender)
	ChatFrame6:AddMessage(sender .. " : " .. prefix .. " -- " .. message)
	if (prefix ~= "RaidOrganizer" or type ~= "RAID") then return end

	if UnitInRaid('player') then
		local _, _, askPattern, tab_id = string.find(message, '(%a+)%s(%d+)');
		if (askPattern == "ONLOAD") then
			if sender == UnitName('player') then
				return
			elseif (RaidOrganizerDialogBroadcastAutoSync:GetChecked()) then
				for tab = 1, 8 do
					RaidOrganizer:RaidOrganizer_SendSync(tab);
				end
			end
			return
		end
		for i = 1, GetNumRaidMembers() do
			local name, rank = GetRaidRosterInfo(i)
			if name == sender then
				if rank == 0 then	
					return
				else
					break
				end
			end
		end
		if askPattern == "MANUAL" then
			DEFAULT_CHAT_FRAME:AddMessage("RaidOrganizer : Syncing " .. RaidOrganizer_Tabs[tonumber(tab_id)][1] .. " assignment from " .. sender);
			return
		end
		local pattern = '(%d+)%s(%d+)';
		local _, _, tab_id, length  = string.find(message, pattern);
		tab_id = tonumber(tab_id);
		length = tonumber(length);
		
		if length == 0 then
			raider[tab_id] = {}; -- message to reset tab
			return
		end
		
		for i = 1, length do
			pattern = pattern .. '%s(%a+)%s(%d+)';
		end
		local raider_table  = {string.find(message, pattern)};
		
		local charName;
		local charGroup;
		local value;
		for i = 1, length do
			charName = raider_table[3 + i * 2];
			if not raider[tab_id][charName] then
				raider[tab_id][charName] = {};
			end
			
			for j = 1, string.len(raider_table[4 + i * 2]) do
				charGroup = tonumber(string.sub(raider_table[4 + i * 2], j, j));
				raider[tab_id][charName][charGroup + 1] = 1;
			end
		end
		if RaidOrganizerDialog:IsShown() then
			self:UpdateDialogValues()
		end
	else
		self:ResetData()
	end
end

function RaidOrganizer:AutoSync_OnClick()
	if RaidOrganizerDialogBroadcastAutoSync:GetChecked() then
		if not ((IsRaidLeader() or IsRaidOfficer())) then
			RaidOrganizerDialogBroadcastAutoSync:SetChecked(false)
			RaidOrganizerDialogBroadcastSync:SetText("Ask Sync")
			DEFAULT_CHAT_FRAME:AddMessage("RaidOrganizer : Can't set Send Sync checkbox if not raid lead or assistant")
		else
			RaidOrganizerDialogBroadcastSync:SetText("Send Sync")
		end
	else
		RaidOrganizerDialogBroadcastSync:SetText("Ask Sync")
	end
end

function RaidOrganizer:RaidOrganizer_SyncOnClick()
	if (RaidOrganizerDialogBroadcastAutoSync:GetChecked()) then
		if not (IsRaidLeader() or IsRaidOfficer()) then
			RaidOrganizerDialogBroadcastAutoSync:SetChecked(false)
			RaidOrganizerDialogBroadcastSync:SetText("Ask Sync")
			DEFAULT_CHAT_FRAME:AddMessage("Try to send sync while not being raid lead or assistant : click again to ask sync or ask promotion before checking send sync checkbox")
		else
			self:RaidOrganizer_SendSync(0)
		end
	else
		self:RaidOrganizer_AskSync()
	end
end

function RaidOrganizer:RaidOrganizer_AskSync()
	SendAddonMessage("RaidOrganizer", "ONLOAD 0", "RAID")
end

function RaidOrganizer:RaidOrganizer_SendSync(id)
	local msg = "";
	local tmp_msg = "";
	local length = 0;
	local nbPlayers = 0
	local first = true;
	local tab_id = 0;
	if id == 0 then
		tab_id = RaidOrganizerDialog.selectedTab;
		SendAddonMessage("RaidOrganizer", "MANUAL " .. tostring(tab_id), "RAID")
	else
		tab_id = id;
	end
	
	--Reset tab for destination
	SendAddonMessage("RaidOrganizer", tab_id .. " 0", "RAID")
	
	for nameChar in raider[tab_id] do
		tmp_msg = "";
		first = true;
		for group=1, self.CONST.NUM_GROUPS[tab_id] do
			if raider[tab_id][nameChar][group + 1] == 1 then
				if first then
					nbPlayers = nbPlayers + 1;
					tmp_msg = nameChar .. " " .. tostring(group);
					first = false;
				else
					tmp_msg = tmp_msg .. tostring(group);
				end
			end
		end
		length = length + string.len(tmp_msg);

		if length > 200 then
			msg = tostring(tab_id) .. " " .. tostring(nbPlayers - 1) .. " " .. msg;
			SendAddonMessage("RaidOrganizer", msg, "RAID")
			msg = tmp_msg;
			length = string.len(tmp_msg);
			nbPlayers = 1;
		else
			if not (tmp_msg == "") then
				msg = msg .. tmp_msg .. " ";
				length = length + string.len(tmp_msg);
			end
		end
	end
	if not (msg == "") then
		msg = tostring(tab_id) .. " " .. nbPlayers .. " " .. msg;
		SendAddonMessage("RaidOrganizer", msg, "RAID")
	end
end
