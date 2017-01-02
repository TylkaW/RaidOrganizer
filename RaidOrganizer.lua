local L = AceLibrary("AceLocale-2.1"):GetInstance("RaidOrganizer", true)
local dewdrop = AceLibrary("Dewdrop-2.0")

local options = {
    type = 'group',
    args = {
        showButtons = {
            type = 'execute',
            name = 'Show/Hide Buttons',
            desc = L["SHOW_DIALOG"],
            func = function() RaidOrganizer:ShowButtons() end,
        },
		showDialog = {
            type = 'execute',
            name = 'Show/Hide Dialog',
            desc = L["SHOW_DIALOG"],
            func = function() RaidOrganizer:Dialog() end,
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
            set = function() RaidOrganizer.db.char.horizontal = not RaidOrganizer.db.char.horizontal; RaidOrganizer:ShowButtons(); end,
		},
		scale = {
			type = 'range',
			name = "Button frame scale",
			desc = "Button fram scale",
			get = function() return RaidOrganizer.db.char.scale end,
			set = function(v)
				RaidOrganizer.db.char.scale = v
				RaidOrganizerButtonsHorizontal:SetScale(RaidOrganizer.db.char.scale)
				RaidOrganizerButtonsVertical:SetScale(RaidOrganizer.db.char.scale)
			end,
			min = 0.5,
			max = 2,
			step = 0.01,
			order = 2
		},
		minimap = {
			type = "group",
			name = 'Minimap Button options',
			desc = 'Minimap Button options',
			args = {
				showMinimap = {
					type = 'toggle',
					name = 'Toggle Minimap icon',
					desc = 'Show/Hide Minimap icon',
					get = function() return RaidOrganizer.db.char.showMinimap end,
					set = function() RaidOrganizer.db.char.showMinimap = not RaidOrganizer.db.char.showMinimap; if RaidOrganizer.db.char.showMinimap then RaidOrganizerMinimapButton:Show(); else RaidOrganizerMinimapButton:Hide(); end end,
				},
				lockMinimap = {
					type = 'toggle',
					name = 'Lock Minimap',
					desc = 'Lock Minimap button',
					get = function() return RaidOrganizer.db.char.lockMinimap end,
					set = function() RaidOrganizer.db.char.lockMinimap = not RaidOrganizer.db.char.lockMinimap end,
				},
			}
		},
		versionQuery = {
			type = "toggle",
			name = 'Version Query',
			desc = 'Query raid member RaidOrganizer version',
			get = function() return b_versionQuery end,
			set = function() b_versionQuery = not b_versionQuery; if b_versionQuery then if (IsRaidLeader() or IsRaidOfficer()) then RaidOrganizer:RaidOrganizer_VersionQuery() else b_versionQuery = false; DEFAULT_CHAT_FRAME:AddMessage("You have to be raid lead or assistant to query version"); end end end,
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
	{"DRUID"},
	{"MAGE","PRIEST","WARLOCK","ROGUE","HUNTER", "DRUID", "PALADIN", "WARRIOR"}}
else
	classTab = {{"PRIEST","DRUID","SHAMAN"},
	{"WARRIOR","DRUID"},
	{"WARRIOR","ROGUE","MAGE"},
	{"MAGE","PRIEST","WARLOCK","ROGUE","HUNTER", "DRUID"},
	{"WARLOCK"},
	{"MAGE"},
	{"PRIEST"},
	{"DRUID"},
	{"MAGE","PRIEST","WARLOCK","ROGUE","HUNTER", "DRUID", "SHAMAN", "WARRIOR"}}
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
	show = false,
    autosort = true,
	horizontal = false,
	minimapLock = false,
	minimapHide = false,
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
	{
        [L["SET_DEFAULT"]] = {
            Name = L["SET_DEFAULT"],
            Beschriftungen = {
                [1] = "Left",
                [2] = "Right",
                [3] = "",
                [4] = "",
                [5] = "",
                [6] = "",
                [7] = "",
                [8] = "",
				[9] = "",
            },
            Restaktion = "",
            Klassengruppen = {
                [1] = {""},
                [2] = {""},
                [3] = {""},
                [4] = {""},
                [5] = {""},
                [6] = {""},
                [7] = {""},
                [8] = {""},
				[9] = {""},
            }
        },
    },
	}
})

RaidOrganizer.CONST = {}
RaidOrganizer.CONST.NUM_GROUPS = { 6, 8, 8, 8, 6, 8, 8, 8, 2}
RaidOrganizer.CONST.NUM_SLOTS = { 8, 3, 5, 2, 1, 1, 1, 1, 30}

RaidOrganizer.b_versionQuery = false
RaidOrganizer.RO_version_table = {}

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
	
	if not RO_CurrentSet then
		RO_CurrentSet = {L["SET_DEFAULT"], L["SET_DEFAULT"], L["SET_DEFAULT"], L["SET_DEFAULT"], L["SET_DEFAULT"], L["SET_DEFAULT"], L["SET_DEFAULT"], L["SET_DEFAULT"], L["SET_DEFAULT"]}
	end
	if not RO_RaiderTable then
		RO_RaiderTable = {{}, {}, {}, {}, {}, {}, {}, {}, {}}
	else
		self:RefreshRaiderTable()
	end
	for i = 1, 9 do
		if RO_RaiderTable[i] == nil then
			RO_RaiderTable[i] = {}
		end
		if self.db.account.sets[i] == nil then
			self.db.account.sets[i] = {}
		end
		if RO_CurrentSet[i] == nil then
			RO_CurrentSet[i] = L["SET_DEFAULT"]
		end
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
			{ "Placement", "Interface\\Icons\\Ability_hunter_pathfinding"}
		};
		
	for i = 1, 9, 1 do
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
		for slot = RaidOrganizer.CONST.NUM_SLOTS[1], 30 do
			getglobal("RaidOrganizerDialogEinteilungHealGroup" .. grp .. "Slot" .. slot):Hide();
		end
	end
    -- standard fuer dropdown setzen
    UIDropDownMenu_SetSelectedValue(RaidOrganizerDialogEinteilungSetsDropDown, RO_CurrentSet[RaidOrganizerDialog.selectedTab], RO_CurrentSet[RaidOrganizerDialog.selectedTab]);
	if not self.db.char.scale then self.db.char.scale = 1.0 end
	if UnitInRaid('player') and RaidOrganizer.db.char.show then
		RaidOrganizerButtonsHorizontal:SetScale(tonumber(self.db.char.scale))
		RaidOrganizerButtonsVertical:SetScale(tonumber(self.db.char.scale))
		self:ShowButtons()
	end
    self:LoadCurrentLabels()
	self:RaidOrganizer_AskSync()
	if RaidOrganizerDialog:IsShown() then
		self:UpdateDialogValues()
	end
	
	if not self.version then self.version = GetAddOnMetadata("RaidOrganizer", "Version") end
	RaidOrganizer.RO_version_table = {}
	RaidOrganizerMinimapButton_OnInitialize()

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
			if RO_RaiderTable[i] then
				for name in RO_RaiderTable[i] do
					if not listName[name] then
						RO_RaiderTable[i][name] = nil
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
					if RO_RaiderTable[RaidOrganizerDialog.selectedTab][unitname] then
						-- schon eingeteilt, nichts machen
						if not RO_RaiderTable[RaidOrganizerDialog.selectedTab][unitname][1] then
							for k=2,10 do
								if RO_RaiderTable[RaidOrganizerDialog.selectedTab][unitname][k] then
									if gruppen[k] >= self.CONST.NUM_SLOTS[RaidOrganizerDialog.selectedTab] then
								-- schon zu viele, mach ihm zum rest
										RO_RaiderTable[RaidOrganizerDialog.selectedTab][unitname][k] = nil
									else
										InGroup = 1
									end
								end
							end
							if InGroup == nil or RaidOrganizerDialogEinteilungOptionenMultipleArrangementCheckBox:GetChecked() == 1 then
								RO_RaiderTable[RaidOrganizerDialog.selectedTab][unitname][1] = 1
							end
						elseif RaidOrganizerDialogEinteilungOptionenMultipleArrangementCheckBox:GetChecked() == 1 then
							for k=2,10 do
								if RO_RaiderTable[RaidOrganizerDialog.selectedTab][unitname][k] then
									if gruppen[k] >= self.CONST.NUM_SLOTS[RaidOrganizerDialog.selectedTab] then
										RO_RaiderTable[RaidOrganizerDialog.selectedTab][unitname][k] = nil
									end
								end
							end
						end
					else
						RO_RaiderTable[RaidOrganizerDialog.selectedTab][unitname]={}
						-- nicht eingeteilt, neu, "rest"
						RO_RaiderTable[RaidOrganizerDialog.selectedTab][unitname][1] = 1
						position[unitname] = {0,0,0,0,0,0,0,0,0,0}
					end
					for k=1,10 do
						if RO_RaiderTable[RaidOrganizerDialog.selectedTab][unitname][k] then
							self:Debug("Group" ..k-1 .. " : " .. RO_RaiderTable[RaidOrganizerDialog.selectedTab][unitname][k])
							gruppen[k] = gruppen[k] + 1
						end
					end
					stats[engClass] = stats[engClass] + 1 
					isClassInTab = 1
				end
			end
            if not isClassInTab then
                -- ist kein heiler, nil
                RO_RaiderTable[RaidOrganizerDialog.selectedTab][unitname] = {}
            end
        end
    end
    self:Debug("stats generiert")
    self:Debug("RO_RaiderTabletabelle aktuallisiert")

    -- RO_RaiderTable[...] -> einteilungsarray
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
    for name, groupTable in pairs(RO_RaiderTable[RaidOrganizerDialog.selectedTab]) do
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
	for i=1,9 do
		if i ~= id then
			getglobal("RaidOrganizer_Tab" .. i):SetChecked(nil);
		end
	end

	RaidOrganizerDialog.selectedTab = id;
	RaidOrganizerDialogEinteilungTitle:SetText(RaidOrganizer_Tabs[id][1]);
	UIDropDownMenu_SetSelectedValue(RaidOrganizerDialogEinteilungSetsDropDown, RO_CurrentSet[id], RO_CurrentSet[id]);
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

		for grp = 1,  9 do
			for slot = 1, 30 do
				getglobal("RaidOrganizerDialogEinteilungHealGroup" .. grp .. "Slot" .. slot):SetWidth(size)
			end
			getglobal("RaidOrganizerDialogEinteilungHealGroup".. grp):SetWidth(size)
		end
		if moreRemain then
			RaidOrganizerDialogEinteilungRaiderpool:SetWidth(2*size)
		else
			RaidOrganizerDialogEinteilungRaiderpool:SetWidth(size)
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
		RaidOrganizerDialogEinteilungOptionen:SetPoint("BOTTOMLEFT", RaidOrganizerDialogEinteilungRaiderpool, "BOTTOMLEFT", 5 + size, 0 )
	end
	
	--if too many people in raid
	local total_remain = 0
	if einteilung[1] then 
		total_remain = table.getn(einteilung[1])
	end
	
	if RaidOrganizerDialog.selectedTab == 9 then
		resizeLayout(70, true)
		RaidOrganizerDialogEinteilungHealGroup2:SetPoint("TOPLEFT", RaidOrganizerDialogEinteilungHealGroup1, "TOPRIGHT", 10, 0 )
		for i=1, RaidOrganizer.CONST.NUM_GROUPS[9] do
			getglobal("RaidOrganizerDialogEinteilungHealGroup".. i):SetWidth(140)
		end
		moreThan24Display = true
	elseif total_remain > 24 and not moreThan24Display then
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
		for slot = 1, 30 do
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
		RaidOrganizerDialogEinteilungStats:SetHeight(37)
		for i=2, 8 do
			getglobal("RaidOrganizerDialogEinteilungStatsClass" .. i):SetText("")
		end
	else
		for i=1, 8 do
			if i <= table.getn(classes) then
				getglobal("RaidOrganizerDialogEinteilungStatsClass" .. i):SetText(L[classes[i]]..": "..stats[classes[i]])
				getglobal("RaidOrganizerDialogEinteilungStatsClass" .. i):SetTextColor(RAID_CLASS_COLORS[classes[i]].r,
															   RAID_CLASS_COLORS[classes[i]].g,
															   RAID_CLASS_COLORS[classes[i]].b)
			else
				getglobal("RaidOrganizerDialogEinteilungStatsClass" .. i):SetText("")
			end
		end
		local autoSizeStatsLUT = {37, 37, 57, 57, 75, 75, 94, 94}
		RaidOrganizerDialogEinteilungStats:SetHeight(autoSizeStatsLUT[table.getn(classTab[RaidOrganizerDialog.selectedTab])])
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
	-- for name, groupTable in pairs(RO_RaiderTable[RaidOrganizerDialog.selectedTab]) do
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
        -- RO_RaiderTable temp save
        tempsetup[RO_CurrentSet[RaidOrganizerDialog.selectedTab]] = {} -- komplett neu bzw. ueberschreiben
        for name, einteilung in pairs(RO_RaiderTable[RaidOrganizerDialog.selectedTab]) do
			tempsetup[RO_CurrentSet[RaidOrganizerDialog.selectedTab]][name]={}
            for i = 1, 10 do
				tempsetup[RO_CurrentSet[RaidOrganizerDialog.selectedTab]][name][i] = einteilung[i]
			end
        end
        RO_CurrentSet[RaidOrganizerDialog.selectedTab] = set
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
    RO_RaiderTable[RaidOrganizerDialog.selectedTab] = {}
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
    RO_RaiderTable = {{},{},{},{},{},{},{},{},}
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
	
	local pools = {"RaidOrganizerDialogEinteilungRaiderpool"}
	for group = 1, 9 do
		for slot = 1, 30 do
			table.insert(pools, "RaidOrganizerDialogEinteilungHealGroup" .. group .. "Slot" .. slot)
		end
	end

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
				--self:Debug("vorher "..RO_RaiderTable[RaidOrganizerDialog.selectedTab][this.username])
				-- den heiler da zuordnen
				if "RaidOrganizerDialogEinteilungRaiderpool" == pool then
					RO_RaiderTable[RaidOrganizerDialog.selectedTab][this.username][1] = 1
					for k=2,10 do
						RO_RaiderTable[RaidOrganizerDialog.selectedTab][this.username][k]=nil
						position[this.username][k] = 0
					end
					position[this.username][1] = 0
				else
					if group >= 1 and group <= self.CONST.NUM_GROUPS[RaidOrganizerDialog.selectedTab] then
							lastAction["group"] = RO_RaiderTable[RaidOrganizerDialog.selectedTab][this.username]
							if RaidOrganizerDialogEinteilungOptionenMultipleArrangementCheckBox:GetChecked() == nil then
								for k=1,10 do
									RO_RaiderTable[RaidOrganizerDialog.selectedTab][this.username][k] = nil
								end
							end
							RO_RaiderTable[RaidOrganizerDialog.selectedTab][this.username][group+1] = 1	
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
            RO_RaiderTable[RaidOrganizerDialog.selectedTab] = {} -- reset
            for name, einteilung in pairs(tempsetup[set]) do
                RO_RaiderTable[RaidOrganizerDialog.selectedTab][name] = einteilung
            end
        end
        return true
    end
    return nil
end -- }}}

function RaidOrganizer:LoadCurrentLabels() -- {{{
    if not self:LoadLabelsFromSet(RO_CurrentSet[RaidOrganizerDialog.selectedTab]) then
        self:LoadLabelsFromSet(L["SET_DEFAULT"])
    end
end -- }}}

function RaidOrganizer:SetSave() -- {{{
    self:Debug("set speichern")
    if RO_CurrentSet[RaidOrganizerDialog.selectedTab] == L["SET_DEFAULT"] then
        self:ErrorMessage(L["SET_CANNOT_SAVE_DEFAULT"])
        return
    end
    self.db.account.sets[RaidOrganizerDialog.selectedTab][RO_CurrentSet[RaidOrganizerDialog.selectedTab]].Beschriftungen = {}
    self.db.account.sets[RaidOrganizerDialog.selectedTab][RO_CurrentSet[RaidOrganizerDialog.selectedTab]].Klassengruppen = {}
    for i=1, self.CONST.NUM_GROUPS[RaidOrganizerDialog.selectedTab] do
        self.db.account.sets[RaidOrganizerDialog.selectedTab][RO_CurrentSet[RaidOrganizerDialog.selectedTab]].Beschriftungen[i] = grouplabels[i]
        self.db.account.sets[RaidOrganizerDialog.selectedTab][RO_CurrentSet[RaidOrganizerDialog.selectedTab]].Klassengruppen[i] = {}
        for j=1, self.CONST.NUM_SLOTS[RaidOrganizerDialog.selectedTab] do
            self.db.account.sets[RaidOrganizerDialog.selectedTab][RO_CurrentSet[RaidOrganizerDialog.selectedTab]].Klassengruppen[i][j] = groupclasses[i][j]
        end
    end
    self.db.account.sets[RaidOrganizerDialog.selectedTab][RO_CurrentSet[RaidOrganizerDialog.selectedTab]].Restaktion = RaidOrganizerDialogEinteilungRestAction:GetText()
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
    RO_CurrentSet[RaidOrganizerDialog.selectedTab] = name
    self:LoadCurrentLabels()
    UIDropDownMenu_SetSelectedValue(RaidOrganizerDialogEinteilungSetsDropDown, RO_CurrentSet[RaidOrganizerDialog.selectedTab])
    UIDropDownMenu_Refresh(RaidOrganizerDialogEinteilungSetsDropDown)
    self:UpdateDialogValues()
end -- }}}

function RaidOrganizer:SetDelete() -- {{{
    if RO_CurrentSet[RaidOrganizerDialog.selectedTab] == L["SET_DEFAULT"] then
        self:ErrorMessage(L["SET_CANNOT_DELETE_DEFAULT"])
        return
    end
    self:Debug("set loeschen")
    if not self.db.account.sets[RaidOrganizerDialog.selectedTab][RO_CurrentSet[RaidOrganizerDialog.selectedTab]] then
        return
    end
    self.db.account.sets[RaidOrganizerDialog.selectedTab][RO_CurrentSet[RaidOrganizerDialog.selectedTab]] = nil
    RO_CurrentSet[RaidOrganizerDialog.selectedTab] = L["SET_DEFAULT"]
    UIDropDownMenu_SetSelectedValue(RaidOrganizerDialogEinteilungSetsDropDown, RO_CurrentSet[RaidOrganizerDialog.selectedTab])
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
    if msg == "assign" then
        self:Debug("healanfrage")
        local reply = L["REPLY_NO_ARRANGEMENT"]
        if RO_RaiderTable[RaidOrganizerDialog.selectedTab][user] then
            -- labels holen
            reply = string.format(L["REPLY_ARRANGEMENT_FOR"], self:ReplaceTokens(grouplabels[RO_RaiderTable[RaidOrganizerDialog.selectedTab][user]]))
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
    if (not class) or class == "" then
        return L["FREE"]
    end
    self:Debug("Klasse ist "..class)
    self:Debug("GetLabel: "..class.."-"..L[class])
    return L[class]
end -- }}}

function RaidOrganizer:MultipleArrangementCheckBox_OnClick()
	if RaidOrganizerDialogEinteilungOptionenMultipleArrangementCheckBox:GetChecked() == nil then
		for name, groupTable in pairs(RO_RaiderTable[RaidOrganizerDialog.selectedTab]) do
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
	RO_RaiderTable[RaidOrganizerDialog.selectedTab] = {}
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
				RO_RaiderTable[RaidOrganizerDialog.selectedTab][name][tableGroup[tableIndex]+1] = 1
				tableIndex = tableIndex + 1
				--DEFAULT_CHAT_FRAME:AddMessage(tableIndex .. " " .. progress .. " " .. name)
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
							if RO_RaiderTable[RaidOrganizerDialog.selectedTab][name][group+1] == nil then
								-- klasse abfragen
								local class, engClass = UnitClass(self:GetUnitByName(name))
								if engClass == groupclasses[group][slot] then
									-- der spieler passt, einteilen
									RO_RaiderTable[RaidOrganizerDialog.selectedTab][name][group+1] = 1
									if not RaidOrganizerDialogEinteilungOptionenMultipleArrangementCheckBox:GetChecked() then 
										RO_RaiderTable[RaidOrganizerDialog.selectedTab][name][1] = nil
									end
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
					if RO_RaiderTable[RaidOrganizerDialog.selectedTab][name][group+1] == nil and boolCheck then
						if groupclasses[group][slot] then
							if not einteilung[group+1][slot] then
								local class, engClass = UnitClass(self:GetUnitByName(name))
								if engClass == groupclasses[group][slot] then
									RO_RaiderTable[RaidOrganizerDialog.selectedTab][name][group+1] = 1
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
	RaidOrganizer:Dialog()
end

function RaidOrganizer:ShowButtons()
	if RaidOrganizer.db.char.horizontal then
		RaidOrganizerButtonsVertical:Hide()
		if RaidOrganizerButtonsHorizontal:IsShown() then
			RaidOrganizerButtonsHorizontal:Hide()
			RaidOrganizer.db.char.show = false
		else
			RaidOrganizerButtonsHorizontal:Show()
			RaidOrganizer.db.char.show = true
		end
	else
		RaidOrganizerButtonsHorizontal:Hide()
		if RaidOrganizerButtonsVertical:IsShown() then
			RaidOrganizerButtonsVertical:Hide()
			RaidOrganizer.db.char.show = false
		else
			RaidOrganizerButtonsVertical:Show()
			RaidOrganizer.db.char.show = true
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
		local groupName = self.db.account.sets[id][RO_CurrentSet[id]].Beschriftungen[group]
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
		for nameChar in RO_RaiderTable[id] do
			if RO_RaiderTable[id][nameChar][group + 1] then
				local _, engClass = UnitClass(self:GetUnitByName(nameChar))
				if not (engClass == nil or engClass == "") then
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
		for tab = 1, 9 do
			RaidOrganizer:RaidOrganizer_SendSync(tab);
		end
	elseif not UnitInRaid('player') then
		self:ResetData()
	end
end

function RaidOrganizer:CHAT_MSG_ADDON(prefix, message, type, sender)
	--ChatFrame6:AddMessage(sender .. " : " .. prefix .. " -- " .. message)
	
	if (prefix == "ROVersion") then 
		if b_versionQuery then
			self.RO_version_table[sender] = message
		end
	end
	
	if (prefix ~= "RaidOrganizer") then return end

	if (type ~= "RAID") then return end
	if UnitInRaid('player') then
		local _, _, askPattern, tab_id = string.find(message, '(%a+)%s+(%d+)');
		if (askPattern == "ONLOAD") then
			if sender == UnitName('player') then
				return
			elseif (RaidOrganizerDialogBroadcastAutoSync:GetChecked() and (IsRaidLeader() or IsRaidOfficer())) then
				for tab = 1, 9 do
					RaidOrganizer:RaidOrganizer_SendSync(tab);
				end
			end
			return
		elseif (askPattern == "VQUERY") then
			SendAddonMessage("ROVersion", tostring(self.version), 'RAID', sender)
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
		local pattern = '(%d+)%s+(%d+)';
		local _, _, tab_id, length  = string.find(message, pattern);
		tab_id = tonumber(tab_id);
		length = tonumber(length);
		
		if length == 0 then
			RO_RaiderTable[tab_id] = {}; -- message to reset tab
			return
		end
		
		for i = 1, length do
			pattern = pattern .. '%s+(%a+)%s+(%d+)';
		end
		local RO_RaiderTable_table  = {string.find(message, pattern)};
		
		local charName;
		local charGroup;
		local value;
		for i = 1, length do
			charName = RO_RaiderTable_table[3 + i * 2];
			if not RO_RaiderTable[tab_id][charName] then
				RO_RaiderTable[tab_id][charName] = {};
			end
			
			for j = 1, string.len(RO_RaiderTable_table[4 + i * 2]) do
				charGroup = tonumber(string.sub(RO_RaiderTable_table[4 + i * 2], j, j));
				RO_RaiderTable[tab_id][charName][charGroup + 1] = 1;
				RO_RaiderTable[tab_id][charName][1] = nil;
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

function RaidOrganizer:RaidOrganizer_VersionQuery()
	self.RO_version_table = {}
	SendAddonMessage("RaidOrganizer", "VQUERY 0", "RAID")
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
	
	for nameChar in RO_RaiderTable[tab_id] do
		tmp_msg = "";
		first = true;
		for group=1, self.CONST.NUM_GROUPS[tab_id] do
			if RO_RaiderTable[tab_id][nameChar][group + 1] == 1 then
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
			msg = tmp_msg .. " ";
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

function RaidOrganizer_Minimap_OnEnter()
	GameTooltip:SetOwner(this, "ANCHOR_BOTTOMLEFT");
	GameTooltip:AddLine("Raid Organizer " .. RaidOrganizer.version);
	GameTooltip:AddLine("Left click to show/hide bar", 0,1,0);
	GameTooltip:AddLine("Right click to show options", 0,1,0);
	GameTooltip:AddLine("Left click and drag to move", 0,1,0);
	local str1, str2 = "", "";
	local color1, color2 = {1,1,1}, {1,1,1};
	local tmpstr = "";
	local tmpcolor = {1,1,1}
	if (IsRaidLeader() or IsRaidOfficer()) and b_versionQuery then
		GameTooltip:AddLine(" ", 0,0,0);
		GameTooltip:AddLine("Version Query :");
		local charName = ""
		local charVersion = ""
		for i=1, MAX_RAID_MEMBERS do
			charName = ""
			charVersion = ""
			if UnitExists("raid"..i) then
				for key,value in pairs(RaidOrganizer.RO_version_table) do
					if key == UnitName("raid"..i) then
						charName = key
						charVersion = value
						break
					end
				end
				if charName ~= "" then
					tmpstr = charName .. " " .. charVersion;
					if charVersion == RaidOrganizer.version then
						tmpcolor = {1,1,1}
					elseif charVersion < RaidOrganizer.version then
						tmpcolor = {1,0.5,0}
					else
						tmpcolor = {0,1,0}
					end
				else
					if UnitIsConnected("raid"..i) then
						tmpstr = UnitName("raid"..i) .. " N/A";
						tmpcolor = {1,0,0}
					else
						tmpstr = UnitName("raid"..i) .. " offline";
						tmpcolor = {0.5,0.5,0.5}
					end
				end
				if str1 == "" then str1 = tmpstr; color1 = tmpcolor; else str2 = tmpstr; color2 = tmpcolor end
				if str2 ~= "" then GameTooltip:AddDoubleLine(str1, str2, color1[1], color1[2], color1[3], color2[1], color2[2], color2[3]); str1 = ""; str2 = ""; end
			end
		end
		if str1 ~= "" then GameTooltip:AddDoubleLine(str1, "", color1[1], color1[2], color1[3], color2[1], color2[2], color2[3]); str1 = ""; str2 = ""; end
	end
	GameTooltip:Show();
end

function RaidOrganizer_Minimap_Position(x,y)
	if ( x or y ) then
		if ( x ) then if ( x < 0 ) then x = x + 360; end MinimapPosition.x = x; end
		if ( y ) then MinimapPosition.y = y; end
	end
	x, y = MinimapPosition.x, MinimapPosition.y

	RaidOrganizerMinimapButton:SetPoint("TOPLEFT","Minimap","TOPLEFT",53-((80+(y))*cos(x)),((80+(y))*sin(x))-55);
end

function RaidOrganizer_Minimap_DragStart()
	if RaidOrganizer.db.char.lockMinimap then 
		return 
	end
	this:SetScript("OnUpdate", RaidOrganizer_Minimap_DragUpdate);
end
function RaidOrganizer_Minimap_DragStop()
	RaidOrganizerMinimapButton:UnlockHighlight()
	this:SetScript("OnUpdate", nil);
end
function RaidOrganizer_Minimap_DragUpdate()
	-- Thanks to Gello for making this a ton shorter
	RaidOrganizerMinimapButton:LockHighlight();
	local curX, curY = GetCursorPosition();
	local mapX, mapY = Minimap:GetCenter();
	local x, y;
	if ( IsShiftKeyDown() ) then
		y = math.pow( math.pow(curY - mapY * Minimap:GetEffectiveScale(), 2) + math.pow(mapX * Minimap:GetEffectiveScale() - curX, 2), 0.5) - 70;
		y = min( max( y, -30 ), 30 );
	end
	x = math.deg(math.atan2( curY - mapY * Minimap:GetEffectiveScale(), mapX * Minimap:GetEffectiveScale() - curX ));

	RaidOrganizer_Minimap_Position(x,y);
end

function RaidOrganizer_Minimap_Update()
	if ( RaidOrganizer.db.char.showMinimap ) then
		RaidOrganizerMinimapButton:Hide();
	else
		RaidOrganizerMinimapButton:Show();
		RaidOrganizer_Minimap_Position();
	end
end

function RaidOrganizer_Minimap_OnClick(arg1)
	if arg1 == "LeftButton" then
		RaidOrganizer:ShowButtons()
	else
		dewdrop:Open(RaidOrganizerMinimapButton)
	end
end

function RaidOrganizerMinimapButton_OnInitialize()
	--dewdrop:Register(RaidOrganizerMinimapButton, 'children', RaidOrganizer.options)
	dewdrop:Register(RaidOrganizerMinimapButton, 'dontHook', true, 'children', function(level, value) CreateDewDropMenu(level, value) end)
	
	RaidOrganizerMinimapButton:SetNormalTexture("Interface\\Icons\\Spell_Nature_Polymorph_Cow")
	RaidOrganizerMinimapButton:SetPushedTexture("Interface\\Icons\\Spell_Nature_Polymorph_Cow")
	
	if MinimapPosition == nil then
		MinimapPosition = {x=0, y=0}
	end
	RaidOrganizer_Minimap_Position(nil, nil)
	
	if RaidOrganizer.db.char.lockMinimap == nil then
		RaidOrganizer.db.char.lockMinimap = false
	end
	
	if RaidOrganizer.db.char.showMinimap == nil then
		RaidOrganizer.db.char.showMinimap = true
	end
	
	if RaidOrganizer.db.char.showMinimap then
		RaidOrganizerMinimapButton:Show()
	end
end

function CreateDewDropMenu(level, value)
	-- Create drewdrop menu
    if level == 1 then
        dewdrop:AddLine( 'text', "RaidOrganizer", 'isTitle', true )
        dewdrop:AddLine( 'text', 'Show Buttons',
						 'func', function() RaidOrganizer:ShowButtons(); end,
            			 'tooltipTitle', 'Show Buttons',
            			 'tooltipText', 'Click to show buttons'
            		     )
        dewdrop:AddLine( 'text', 'Show Dialog',
						 'func', function() RaidOrganizer:Dialog(); end,
            			 'tooltipTitle', 'Show Dialog',
            			 'tooltipText', 'Click to show dialog'
            		     )
		dewdrop:AddLine( 'text', 'Scale',
						 'hasArrow', true,
						 'hasSlider', true,
						 'sliderMin', 0.5,
						 'sliderMax', 2,
						 'sliderStep', 0.01,
						 'sliderValue', RaidOrganizer.db.char.scale,
						 'sliderFunc', function(value)
								RaidOrganizer.db.char.scale = value
								RaidOrganizerButtonsHorizontal:SetScale(value)
								RaidOrganizerButtonsVertical:SetScale(value)
							end,
            			 'tooltipTitle', 'Bar Scale',
            			 'tooltipText', 'Set Bar Scale'
            		     )
        dewdrop:AddLine( 'text', 'Horizontal Display',
						 'checked', RaidOrganizer.db.char.horizontal,
                         'func', function()
                            RaidOrganizer.db.char.horizontal = not RaidOrganizer.db.char.horizontal; RaidOrganizer:ShowButtons();
                         end,
                         'tooltipTitle', 'Horizontal Display',
            			 'tooltipText', 'Check to display button horizontally, uncheck otherwise'
                         )
		dewdrop:AddLine( 'text', 'Minimap Button options',
						 'hasArrow', true,
            			 'value', "minimapOptions",
                         'tooltipTitle', 'Minimap Button options',
            			 'tooltipText', 'Show/hide and lock/unlock minimap button'
                         )
		dewdrop:AddLine( 'text', 'Version Query',
						 'checked', b_versionQuery,
						 'func', function() b_versionQuery = not b_versionQuery; if b_versionQuery then if (IsRaidLeader() or IsRaidOfficer()) then RaidOrganizer:RaidOrganizer_VersionQuery() else b_versionQuery = false; DEFAULT_CHAT_FRAME:AddMessage("You have to be raid lead or assistant to query version"); end end end,
						 'tooltipTitle', 'Version Query',
						 'tooltipText', 'Ask raid member for their RaidOrganizer version'
						 )
	elseif level == 2 then    
        if value == "minimapOptions" then
			dewdrop:AddLine( 'text', 'Lock minimap button',
						 'checked', RaidOrganizer.db.char.lockMinimap,
                         'func', function()
                            RaidOrganizer.db.char.lockMinimap = not RaidOrganizer.db.char.lockMinimap;
                         end,
                         'tooltipTitle', 'Lock minimap button',
            			 'tooltipText', 'Check to lock minimap button'
                         )
			dewdrop:AddLine( 'text', 'Hide minimap button',
						 'checked', not RaidOrganizer.db.char.showMinimap,
                         'func', function()
                            RaidOrganizer.db.char.showMinimap = not RaidOrganizer.db.char.showMinimap; if not RaidOrganizer.db.char.showMinimap then RaidOrganizerMinimapButton:Hide(); else RaidOrganizerMinimapButton:Show(); end
                         end,
                         'tooltipTitle', 'Hide minimap button',
            			 'tooltipText', 'Check to hide minimap button'
                         )
		end
	end
end