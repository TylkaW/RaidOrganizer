local L = AceLibrary("AceLocale-2.1"):GetInstance("RaidOrganizer", true)
local dewdrop = AceLibrary("Dewdrop-2.0")

local options = {
    type = 'group',
    args = {
		barDisplay = {
			type = 'group',
			name = 'Bar options',
			desc = 'Shortcut button bar display options',
			args = {
				horizontal = {
				type = 'toggle',
				name = 'Horizontal',
				desc = 'Show buttons horizontally or vertically',
				get = function() return RaidOrganizer.db.char.horizontal end,
				set = function() RaidOrganizer.db.char.horizontal = not RaidOrganizer.db.char.horizontal; RaidOrganizer:ShowButtons(); end,
				},
				scale = {
					type = 'range',
					name = "Scale",
					desc = "Shortcut button bar scale",
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
			}
		},
        showBar = {
			type = 'toggle',
			name = 'Show bar',
			desc = 'Show/Hide shortcut button bar',
			get = function() return RaidOrganizer.db.char.showBar end,
			set = function() RaidOrganizer.db.char.showBar = not RaidOrganizer.db.char.showBar; RaidOrganizer:ShowButtons() end,
				
        },
		showDialog = {
            type = 'execute',
            name = 'Show Dialog',
            desc = L["SHOW_DIALOG"],
            func = function() RaidOrganizer:Dialog() end,
        },
		minimap = {
			type = "group",
			name = 'Minimap',
			desc = 'Minimap button options',
			args = {
				showMinimap = {
					type = 'toggle',
					name = 'Show',
					desc = 'Show/Hide minimap button',
					get = function() return RaidOrganizer.db.char.showMinimap end,
					set = function() RaidOrganizer.db.char.showMinimap = not RaidOrganizer.db.char.showMinimap; if RaidOrganizer.db.char.showMinimap then RaidOrganizerMinimapButton:Show(); else RaidOrganizerMinimapButton:Hide(); end end,
				},
				lockMinimap = {
					type = 'toggle',
					name = 'Lock',
					desc = 'Lock Minimap button',
					get = function() return RaidOrganizer.db.char.lockMinimap end,
					set = function() RaidOrganizer.db.char.lockMinimap = not RaidOrganizer.db.char.lockMinimap end,
				},
				minimapPosition = {
					type = 'group',
					name = 'Position',
					desc = 'Minimap button position',
					args = {
						minimapPositionX = {
							type = 'range',
							name = "x",
							desc = "Minimap button angle",
							get = function() return RaidOrganizer.db.char.minimapPositionX end,
							set = function(v)
								RaidOrganizer.db.char.minimapPositionX = v
								RaidOrganizer_Minimap_Position(v, RaidOrganizer.db.char.minimapPositionY)
							end,
							min = 0,
							max = 360,
							step = 0.5,
							order = 2
						},
						minimapPositionY = {
							type = 'range',
							name = "y",
							desc = "Minimap button position",
							get = function() return RaidOrganizer.db.char.minimapPositionY end,
							set = function(v)
								RaidOrganizer.db.char.minimapPositionY = v
								RaidOrganizer_Minimap_Position(RaidOrganizer.db.char.minimapPositionX, v)
							end,
							min = -30,
							max = 30,
							step = 0.5,
							order = 2
						},
					}
				},
			}
		},
		versionQuery = {
			type = "toggle",
			name = 'Check version',
			desc = 'Query raid member RaidOrganizer version',
			get = function() return RaidOrganizer.b_versionQuery end,
			set = function() RaidOrganizer.b_versionQuery = not RaidOrganizer.b_versionQuery; if RaidOrganizer.b_versionQuery then if (IsRaidLeader() or IsRaidOfficer()) then RaidOrganizer:RaidOrganizer_VersionQuery() else RaidOrganizer.b_versionQuery = false; DEFAULT_CHAT_FRAME:AddMessage("You have to be raid lead or assistant to check raid version"); end end end,
			disabled = function() return not RaidOrganizer:IsActive() end,
		},
    }
}
-- units


-- name2unitid
local unitids = {
}
local position = {
}
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

local groupByName = {}

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

local MAX_GROUP_NB = 9

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
	{"MAGE","PRIEST","WARLOCK","ROGUE","HUNTER", "DRUID", "PALADIN", "WARRIOR"},
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
	{"MAGE","PRIEST","WARLOCK","ROGUE","HUNTER", "DRUID", "SHAMAN", "WARRIOR"},
	{"MAGE","PRIEST","WARLOCK","ROGUE","HUNTER", "DRUID", "SHAMAN", "WARRIOR"}}
end

local TOTAL_TAB_NB = 10
local SYNC_TAB_NB = 9
local HEAL_TAB_INDEX = 1
local BUFF_MAGE_TAB_INDEX = 6
local BUFF_PRIEST_TAB_INDEX = 7
local BUFF_DRUID_TAB_INDEX = 8
local RAID_PLACEMENT_TAB_INDEX = 9
local RAID_FILL_TAB_INDEX = 10

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
	showBar = true,
	horizontal = false,
	minimapLock = false,
	minimapHide = false,
	minimapPositionX = 0,
	minimapPositionY = 0,
	scale = 1.0
})

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
                [6] = L["DISPEL"],
                [7] = "",
                [8] = "",
                [9] = "",
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
	}
	}
})

RaidOrganizer.CONST = {}
RaidOrganizer.CONST.NUM_GROUPS = { 6, 8, 8, 8, 6, 8, 8, 8, 2, 8}
RaidOrganizer.CONST.NUM_SLOTS = { 8, 3, 5, 2, 1, 1, 1, 1, 30, 5}

RaidOrganizer.b_versionQuery = false
RaidOrganizer.RO_version_table = {}

function RaidOrganizer:OnInitialize() -- {{{
    StaticPopupDialogs["RaidOrganizer_EDITLABEL"] = { --{{{
        text = L["EDIT_LABEL"],
        button1 = TEXT(SAVE),
        button2 = TEXT(CANCEL),
        OnAccept = function(a,b,c)
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
		RO_RaiderTable = {}
		for i = 1, TOTAL_TAB_NB do
			table.insert(RO_RaiderTable, {})
		end
	else
		self:RefreshRaiderTable()
	end
	for i = 1, TOTAL_TAB_NB do
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
    
    RaidOrganizerDialogEinteilungTitle:SetText(L["ARRANGEMENT"])
	
    for i=1, 40 do
        getglobal("RaidOrganizerDialogEinteilungRaiderpoolSlot"..i.."Label"):SetText(L["FREE"])
    end
    RaidOrganizerDialogEinteilungOptionenTitle:SetText(L["OPTIONS"])
    RaidOrganizerDialogEinteilungOptionenAutofill:SetText(L["AUTOFILL"])
	RaidOrganizerDialogEinteilungOptionenMultipleArrangementCheckBoxText:SetText(L["MULTIPLE_ARRANGEMENT"])
	RaidOrganizerDialogEinteilungOptionenDisplayGroupNbText:SetText("Display Raider Group")
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
	
	RaidOrganizer_Tabs = {
			{ "Heal", "Interface\\Icons\\Spell_Holy_GreaterHeal"},
			{ "Tank", "Interface\\Icons\\INV_Shield_03" },
			{ "Kick", "Interface\\Icons\\Ability_Kick" },
			{ "Crowd Control", "Interface\\Icons\\spell_nature_polymorph" },
			{ "Curses", "Interface\\Icons\\Spell_Shadow_ChillTouch" },
			{ "Intel Buff", "Interface\\Icons\\spell_holy_magicalsentry" },
			{ "Stam Buff", "Interface\\Icons\\spell_holy_wordfortitude" },
			{ "MOTW Buff", "Interface\\Icons\\spell_nature_regeneration" },
			{ "Placement", "Interface\\Icons\\Ability_hunter_pathfinding"},
			{ "Raid Autofill", "Interface\\Icons\\Spell_holy_prayerofhealing"}
	};
		
	for i = 1, SYNC_TAB_NB, 1 do
		getglobal("RaidOrganizer_Tab" .. i).tooltiptext = RaidOrganizer_Tabs[i][1];
		getglobal("RaidOrganizer_Tab" .. i):SetNormalTexture(RaidOrganizer_Tabs[i][2]);
		getglobal("RaidOrganizer_Tab" .. i):Show();
		
		getglobal("RaidOrganizerButtonsHorizontalTab" .. i).tooltiptext = RaidOrganizer_Tabs[i][1];
		getglobal("RaidOrganizerButtonsHorizontalTab" .. i):SetNormalTexture(RaidOrganizer_Tabs[i][2]);
		
		getglobal("RaidOrganizerButtonsVerticalTab" .. i).tooltiptext = RaidOrganizer_Tabs[i][1];
		getglobal("RaidOrganizerButtonsVerticalTab" .. i):SetNormalTexture(RaidOrganizer_Tabs[i][2]);
	end
	RaidOrganizer_Tab10.tooltiptext = RaidOrganizer_Tabs[RAID_FILL_TAB_INDEX][1];
	RaidOrganizer_Tab10:SetNormalTexture(RaidOrganizer_Tabs[RAID_FILL_TAB_INDEX][2]);
	RaidOrganizer_Tab10:Show();
		
	RaidOrganizer_SetTab(1);
	for grp = 1,  MAX_GROUP_NB do
		if grp > RaidOrganizer.CONST.NUM_GROUPS[1] then
			getglobal("RaidOrganizerDialogEinteilungHealGroup" .. grp):Hide();
		end
		for slot = RaidOrganizer.CONST.NUM_SLOTS[1], 30 do
			getglobal("RaidOrganizerDialogEinteilungHealGroup" .. grp .. "Slot" .. slot):Hide();
		end
	end
    -- standard fuer dropdown setzen
    UIDropDownMenu_SetSelectedValue(RaidOrganizerDialogEinteilungSetsDropDown, RO_CurrentSet[RaidOrganizerDialog.selectedTab], RO_CurrentSet[RaidOrganizerDialog.selectedTab]);

	RaidOrganizerButtonsHorizontal:SetScale(tonumber(self.db.char.scale))
	RaidOrganizerButtonsVertical:SetScale(tonumber(self.db.char.scale))
	self:ShowButtons()
	
    self:LoadCurrentLabels()
	
	if not self.version then self.version = GetAddOnMetadata("RaidOrganizer", "Version") end
	RaidOrganizer.RO_version_table = {}

	RaidOrganizerMinimapButton_OnInitialize()
	
	if self:IsActive() then
		self:OnEnable()
	else
		self:OnDisable()
	end

	self:RaidOrganizer_AskSync()
	if RaidOrganizerDialog:IsShown() then
		self:UpdateDialogValues()
	end
end -- }}}

function RaidOrganizer:OnEnable() -- {{{
    -- Called when the addon is enabled
	RaidOrganizerMinimapButton:GetNormalTexture():SetDesaturated(false)
	RaidOrganizerMinimapButton:GetPushedTexture():SetDesaturated(false)
	self:RegisterEvent("CHAT_MSG_WHISPER")
	self:RegisterEvent("CHAT_MSG_ADDON")
	self:RegisterEvent("RAID_ROSTER_UPDATE")
	RaidOrganizerDialogEinteilungOptionenAutofill:Enable()
	RaidOrganizerDialogBroadcastSync:Enable()
	RaidOrganizerDialogBroadcastChannel:Enable()
	RaidOrganizerDialogBroadcastRaid:Enable()
	
	self:UpdateDialogValues()
end -- }}}

function RaidOrganizer:OnDisable() -- {{{
    -- Called when the addon is disabled
	RaidOrganizerMinimapButton:GetNormalTexture():SetDesaturated(true)
	RaidOrganizerMinimapButton:GetPushedTexture():SetDesaturated(true)
	self:UnregisterAllEvents();
	self:ResetData();
	RaidOrganizerDialogEinteilungOptionenAutofill:Disable()
	RaidOrganizerDialogBroadcastSync:Disable()
	RaidOrganizerDialogBroadcastChannel:Disable()
	RaidOrganizerDialogBroadcastRaid:Disable()
end -- }}}

function RaidOrganizer:RefreshRaiderTable()
	if UnitInRaid('player') then
		for i = 1, TOTAL_TAB_NB do
			if RO_RaiderTable[i] then
				for name in RO_RaiderTable[i] do
					if not UnitExists(self:GetUnitByName(name)) then
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
	
	groupByName = {}
	
	if self:IsActive() then
		for i=1, MAX_RAID_MEMBERS do
			if UnitExists("raid"..i) then
				local class,engClass = UnitClass("raid"..i)
				local unitname, _, subgroup = GetRaidRosterInfo(i)
				if subgroup ~= nil and unitname ~= nil then
					groupByName[unitname] = subgroup
				end
				local isClassInTab = nil
				local InGroup = nil
				for j=1, table.getn(classTab[RaidOrganizerDialog.selectedTab]) do
					if engClass == classTab[RaidOrganizerDialog.selectedTab][j] then
						if RO_RaiderTable[RaidOrganizerDialog.selectedTab][unitname] then
							if not RO_RaiderTable[RaidOrganizerDialog.selectedTab][unitname][1] then
								for k=1, MAX_GROUP_NB do
									if RO_RaiderTable[RaidOrganizerDialog.selectedTab][unitname][k+1] then
										if gruppen[k+1] >= self.CONST.NUM_SLOTS[RaidOrganizerDialog.selectedTab] then
											RO_RaiderTable[RaidOrganizerDialog.selectedTab][unitname][k+1] = nil
										else
											InGroup = 1
										end
									end
								end
								if InGroup == nil or RaidOrganizerDialogEinteilungOptionenMultipleArrangementCheckBox:GetChecked() == 1 then
									RO_RaiderTable[RaidOrganizerDialog.selectedTab][unitname][1] = 1
								end
							elseif RaidOrganizerDialogEinteilungOptionenMultipleArrangementCheckBox:GetChecked() == 1 then
								for k=1, MAX_GROUP_NB do
									if RO_RaiderTable[RaidOrganizerDialog.selectedTab][unitname][k+1] then
										if gruppen[k+1] >= self.CONST.NUM_SLOTS[RaidOrganizerDialog.selectedTab] then
											RO_RaiderTable[RaidOrganizerDialog.selectedTab][unitname][k+1] = nil
										end
									end
								end
							end
						else
							RO_RaiderTable[RaidOrganizerDialog.selectedTab][unitname]={}
							RO_RaiderTable[RaidOrganizerDialog.selectedTab][unitname][1] = 1
						end
						for k=1, MAX_GROUP_NB + 1 do
							if RO_RaiderTable[RaidOrganizerDialog.selectedTab][unitname][k] then
								gruppen[k] = gruppen[k] + 1
							end
						end
						stats[engClass] = stats[engClass] + 1 
						isClassInTab = 1
					end
				end
				if not isClassInTab then
					RO_RaiderTable[RaidOrganizerDialog.selectedTab][unitname] = nil
				end
				position[unitname] = {}
				for k=1, MAX_GROUP_NB + 1 do
					table.insert(position[unitname], 0)
				end
			end
		end
	end

    einteilung = {}
	for i=1, MAX_GROUP_NB + 1 do
		table.insert(einteilung, {})
	end

    for name, groupTable in pairs(RO_RaiderTable[RaidOrganizerDialog.selectedTab]) do
		for i=1, MAX_GROUP_NB + 1 do
			if groupTable[i] then
				table.insert(einteilung[i], name)
			end
		end
    end
	
	groupIndex = 0
	
    local function SortEinteilung(a, b) --{{{
		if b == nil then return end
		if a == nil then return end
		local unitIDa = self:GetUnitByName(a)
		local unitIDb = self:GetUnitByName(b)
		local classA, engClassA = UnitClass(unitIDa)
		local classB, engClassB = UnitClass(unitIDb)
		if engClassA ~= engClassB then
				if engClassA == "WARRIOR" then -- (Warrior, *)
						return true
				end
				if engClassB == "WARRIOR" then -- (*, Warrior)
						return false
				end
				if engClassA == "ROGUE" then -- (Rogue, *)
						return true
				end
				if engClassB == "ROGUE" then -- (*, Rogue)
						return false
				end
				if engClassA == "MAGE" then -- (Mage, *)
						return true
				end
				if engClassB == "MAGE" then -- (*, Mage)
						return false
				end
				if engClassA == "WARLOCK" then -- (Warlock, *)
						return true
				end
				if engClassB == "WARLOCK" then -- (*, Warlock)
						return false
				end
				if engClassA == "HUNTER" then -- (Hunter, *)
						return true
				end
				if engClassB == "HUNTER" then -- (*, Hunter)
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
				return a<b
		end
		return true
    end --}}}
    for key, _ in pairs(einteilung) do
		groupIndex = key
        table.sort(einteilung[key], SortEinteilung)
        for index, name in pairs(einteilung[key]) do
			if not position[name] then
				for i=1, MAX_GROUP_NB + 1 do
					table.insert(position[name], 0)
				end
			end
            position[name][key] = index
        end
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
	for i=1,TOTAL_TAB_NB do
		if i ~= id then
			getglobal("RaidOrganizer_Tab" .. i):SetChecked(nil);
		end
	end

	RaidOrganizerDialog.selectedTab = id;
	RaidOrganizerDialogEinteilungTitle:SetText(RaidOrganizer_Tabs[id][1]);
	UIDropDownMenu_SetSelectedValue(RaidOrganizerDialogEinteilungSetsDropDown, RO_CurrentSet[id], RO_CurrentSet[id]);
	RaidOrganizer:LoadCurrentLabels()
	
	if RaidOrganizerDialog.selectedTab == RAID_FILL_TAB_INDEX then
		RaidOrganizerDialogBroadcastSync:SetText("Reorganize Raid")
		RaidOrganizerDialogEinteilungOptionenMultipleArrangementCheckBox:SetChecked(nil)
		RaidOrganizerDialogEinteilungOptionenDisplayGroupNb:SetChecked(1)
	elseif RaidOrganizerDialogBroadcastAutoSync:GetChecked() then
		RaidOrganizerDialogBroadcastSync:SetText("Send Sync")
	else
		RaidOrganizerDialogBroadcastSync:SetText("Ask Sync")
	end
	
	RaidOrganizer:UpdateDialogValues();
end

function RaidOrganizer:Dialog() -- {{{
    if GetNumRaidMembers() == 0 then
        self:ResetData()
    end
    self:UpdateDialogValues()
    if RaidOrganizerDialog:IsShown() then
        RaidOrganizerDialog:Hide()
    else
        RaidOrganizerDialog:Show()
    end
end -- }}}

function RaidOrganizer:UpdateDialogValues() -- {{{
    self:RefreshTables()
	local function resizeLayout(size, moreRemain)

		for group = 1,  MAX_GROUP_NB do
			for slot = 1, 30 do
				getglobal("RaidOrganizerDialogEinteilungHealGroup" .. group .. "Slot" .. slot):SetWidth(size)
			end
			getglobal("RaidOrganizerDialogEinteilungHealGroup".. group):SetWidth(size)
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
	end
	
	--if too many people in raid
	local total_remain = 0
	if einteilung[1] then 
		total_remain = table.getn(einteilung[1])
	end
	
	if RaidOrganizerDialog.selectedTab == RAID_PLACEMENT_TAB_INDEX then
		resizeLayout(70, true)
		RaidOrganizerDialogEinteilungHealGroup2:SetPoint("TOPLEFT", RaidOrganizerDialogEinteilungHealGroup1, "TOPRIGHT", 10, 0 )
		for i=1, RaidOrganizer.CONST.NUM_GROUPS[RAID_PLACEMENT_TAB_INDEX] do
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

	local classes = classTab[RaidOrganizerDialog.selectedTab]
	for group = 1,  MAX_GROUP_NB do
		if group > RaidOrganizer.CONST.NUM_GROUPS[RaidOrganizerDialog.selectedTab] then
			getglobal("RaidOrganizerDialogEinteilungHealGroup" .. group):Hide();
		else
			getglobal("RaidOrganizerDialogEinteilungHealGroup" .. group):Show();
		end
		getglobal("RaidOrganizerDialogEinteilungHealGroup" .. group):SetHeight(131-(10-RaidOrganizer.CONST.NUM_SLOTS[RaidOrganizerDialog.selectedTab])*13)
		for slot = 1, 30 do
			if slot > RaidOrganizer.CONST.NUM_SLOTS[RaidOrganizerDialog.selectedTab] then
				getglobal("RaidOrganizerDialogEinteilungHealGroup" .. group .. "Slot" .. slot):Hide();
			else
				getglobal("RaidOrganizerDialogEinteilungHealGroup" .. group .. "Slot" .. slot):Show();
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

    for j=1, self.CONST.NUM_GROUPS[RaidOrganizerDialog.selectedTab] do
        for i=1, self.CONST.NUM_SLOTS[RaidOrganizerDialog.selectedTab] do
            local slotlabel = getglobal("RaidOrganizerDialogEinteilungHealGroup"..j.."Slot"..i.."Label")
            local slotbutton = getglobal("RaidOrganizerDialogEinteilungHealGroup"..j.."Slot"..i.."Color")
            slotlabel:SetText(self:GetLabelByClass(groupclasses[j][i]))
            local color = RAID_CLASS_COLORS[groupclasses[j][i]];
            if color then
                slotbutton:SetTexture(color.r/1.5, color.g/1.5, color.b/1.5, 0.5)
            else
				local group = 1
				if groupclasses[j][i] == nil then
					slotbutton:SetTexture(0.1, 0.1, 0.1)
				else
					local _,_,group = string.find(groupclasses[j][i], "Group(%d)")
					if group then 
						slotbutton:SetTexture(1/group, 0, 0, 0.5)
					else
						slotbutton:SetTexture(0.1, 0.1, 0.1)
					end
				end
            end
        end
    end
    -- }}}
    RaidOrganizerDialogEinteilungRaiderpoolLabel:SetText(grouplabels["Rest"])
    for i=1,self.CONST.NUM_GROUPS[RaidOrganizerDialog.selectedTab] do
        getglobal("RaidOrganizerDialogEinteilungHealGroup"..i.."Label"):SetText(self:ReplaceTokens(grouplabels[i]))
    end

    RaidOrganizerDialogBroadcastChannelEditbox:SetText(self.db.char.chan)
    for i=1, 72 do
        getglobal("RaidOrganizerDialogButton"..i):ClearAllPoints()
        getglobal("RaidOrganizerDialogButton"..i):Hide()
    end
    local zaehler = 1
    -- Rest {{{
    for i=1, table.getn(einteilung[1]) do
        if zaehler > 72 then
            break
        end
        local button = getglobal("RaidOrganizerDialogButton"..zaehler)
        local buttonlabel = getglobal(button:GetName().."Label")
        local buttoncolor = getglobal(button:GetName().."Color")

		if RaidOrganizerDialogEinteilungOptionenDisplayGroupNb:GetChecked() == 1 then
			buttonlabel:SetText(einteilung[1][i] .. "(" .. groupByName[einteilung[1][i]] .. ")")
		else
			buttonlabel:SetText(einteilung[1][i])
		end
        local class, engClass = UnitClass(self:GetUnitByName(einteilung[1][i]))
        local color = RAID_CLASS_COLORS[engClass];
        if color then
            buttoncolor:SetTexture(color.r, color.g, color.b)
        end

        button:SetPoint("TOP", "RaidOrganizerDialogEinteilungRaiderpoolSlot"..i)
        button:Show()

        button.username = einteilung[1][i]
        zaehler = zaehler + 1
    end

    for j=1, self.CONST.NUM_GROUPS[RaidOrganizerDialog.selectedTab] do
        for i=1, table.getn(einteilung[j+1]) do
            if zaehler > 72 then
                break
            end
            local button = getglobal("RaidOrganizerDialogButton"..zaehler)
            local buttonlabel = getglobal(button:GetName().."Label")
            local buttoncolor = getglobal(button:GetName().."Color")
			if RaidOrganizerDialogEinteilungOptionenDisplayGroupNb:GetChecked() == 1 then
				buttonlabel:SetText(einteilung[j+1][i] .. "(" .. groupByName[einteilung[j+1][i]] .. ")")
			else
				buttonlabel:SetText(einteilung[j+1][i])
			end
            local class, engClass = UnitClass(self:GetUnitByName(einteilung[j+1][i]))
            local color = RAID_CLASS_COLORS[engClass];
            if color then
                buttoncolor:SetTexture(color.r, color.g, color.b)
            end
            button:SetPoint("TOP", "RaidOrganizerDialogEinteilungHealGroup"..j.."Slot"..i)
            button:Show()
			
            button.username = einteilung[j+1][i]
            zaehler = zaehler + 1
        end
    end
 
    local function RaidOrganizer_changeSet(set)
        UIDropDownMenu_SetSelectedValue(RaidOrganizerDialogEinteilungSetsDropDown, set, set)
        -- RO_RaiderTable temp save
        tempsetup[RO_CurrentSet[RaidOrganizerDialog.selectedTab]] = {} -- komplett neu bzw. ueberschreiben
        for name, einteilung in pairs(RO_RaiderTable[RaidOrganizerDialog.selectedTab]) do
			tempsetup[RO_CurrentSet[RaidOrganizerDialog.selectedTab]][name]={}
            for i = 1, MAX_GROUP_NB + 1 do
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

        for key, value in pairs(self.db.account.sets[RaidOrganizerDialog.selectedTab]) do
            info = {}
            info.text = key
            info.value = key
            info.func = RaidOrganizer_changeSet
            info.arg1 = key
            if ( info.value == selectedValue ) then 
                info.checked = 1; 
            end
            UIDropDownMenu_AddButton(info);
        end
    end
    -- }}} 
    UIDropDownMenu_Initialize(RaidOrganizerDialogEinteilungSetsDropDown, RaidOrganizerDropDown_Initialize); 
    UIDropDownMenu_Refresh(RaidOrganizerDialogEinteilungSetsDropDown)
    UIDropDownMenu_SetWidth(150, RaidOrganizerDialogEinteilungSetsDropDown);
	
end -- }}}

function RaidOrganizer:ResetTab() -- {{{
    RO_RaiderTable[RaidOrganizerDialog.selectedTab] = {}
	einteilung = {}
    groupclasses = {}
    for i=1, MAX_GROUP_NB do
        groupclasses[i] = {}
    end
    self:UpdateDialogValues()
end -- }}}

function RaidOrganizer:ResetData() -- {{{
	RO_RaiderTable = {}
	for i=1, TOTAL_TAB_NB do
		table.insert(RO_RaiderTable, {})
	end
	einteilung = {}
	if RaidOrganizerDialog:IsShown() then
		self:UpdateDialogValues()
	end
end -- }}}

function RaidOrganizer:BroadcastChan() --{{{
    if GetNumRaidMembers() == 0 then
        self:ErrorMessage(L["NOT_IN_RAID"])
        return;
    end
    local id, name = GetChannelName(self.db.char.chan)
    local messages = self:BuildMessages()
    for _, message in pairs(messages) do
		ChatThrottleLib:SendChatMessage("NORMAL", nil, message, "CHANNEL", nil, id)
    end
    self:SendToRaiders()
end -- }}}

function RaidOrganizer:BroadcastRaid() -- {{{
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
    self.db.char.chan = RaidOrganizerDialogBroadcastChannelEditbox:GetText()
end -- }}}

function RaidOrganizer:RaiderOnClick(arg)
end

function RaidOrganizer:RaiderOnDragStart() -- {{{
    local cursorX, cursorY = GetCursorPosition()
    this:ClearAllPoints();
    this:SetPoint("CENTER", nil, "BOTTOMLEFT", cursorX*GetScreenHeightScale(), cursorY*GetScreenHeightScale());
    this:StartMoving()
    level_of_button = this:GetFrameLevel();
    this:SetFrameLevel(this:GetFrameLevel()+30)
end -- }}}

function RaidOrganizer:RaiderOnDragStop() -- {{{
    this:SetFrameLevel(level_of_button)
    this:StopMovingOrSizing()
	
	local pools = {"RaidOrganizerDialogEinteilungRaiderpool"}
	for group = 1, MAX_GROUP_NB do
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
				if "RaidOrganizerDialogEinteilungRaiderpool" == pool then
					RO_RaiderTable[RaidOrganizerDialog.selectedTab][this.username][1] = 1
					for k=2, MAX_GROUP_NB + 1 do
						RO_RaiderTable[RaidOrganizerDialog.selectedTab][this.username][k]=nil
						position[this.username][k] = 0
					end
					position[this.username][1] = 0
				else
					if group >= 1 and group <= self.CONST.NUM_GROUPS[RaidOrganizerDialog.selectedTab] then
							lastAction["group"] = RO_RaiderTable[RaidOrganizerDialog.selectedTab][this.username]
							if RaidOrganizerDialogEinteilungOptionenMultipleArrangementCheckBox:GetChecked() == nil then
								for k=1, MAX_GROUP_NB + 1 do
									RO_RaiderTable[RaidOrganizerDialog.selectedTab][this.username][k] = nil
								end
							end
							RO_RaiderTable[RaidOrganizerDialog.selectedTab][this.username][group+1] = 1	
					end
					if slot >= 1 and slot <= self.CONST.NUM_SLOTS[RaidOrganizerDialog.selectedTab] then
							lastAction["name"] = this.username
							for k=1, MAX_GROUP_NB + 1 do
								if lastAction["group"][k] then
									lastAction["position"][k] = position[this.username][k]
								else
									lastAction["position"][k] = 0
								end
							end
							position[this.username][group+1] = slot
					end
				end
				break
			end
		end
    end
    self:UpdateDialogValues()
end -- }}}

function RaidOrganizer:RaiderOnLoad() -- {{{
    this:SetFrameLevel(this:GetFrameLevel() + 2)
    this:RegisterForDrag("LeftButton")
end -- }}}

function RaidOrganizer:EditGroupLabel(group) -- {{{
    if group:GetID() == 0 then
        return
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
            RO_RaiderTable[RaidOrganizerDialog.selectedTab] = {}
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
    if count >= 32 then
        self:ErrorMessage(L["SET_TO_MANY_SETS"])
        return
    end
    if self.db.account.sets[RaidOrganizerDialog.selectedTab][name] then
        self:ErrorMessage(string.format(L["SET_ALREADY_EXISTS"], name))
        return
    end
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
        return "raid41"
    end
    if str ~= UnitName(unitids[str]) then
        self:BuildUnitIDs()
    end
    return unitids[str]
end -- }}}

function RaidOrganizer:ReplaceTokens(str) -- {{{
    local function GetMainTankLabel(i) -- {{{
        if not i then
            return ""
        end
        if type(i) ~= "number" then
            return ""
        end
        if i < 1 or i > self.CONST.NUM_GROUPS[HEAL_TAB_INDEX] then
            return ""
        end
        local s = L["MT"]..i
        if CT_RATarget then
            if CT_RATarget.MainTanks[i] and
                UnitExists("raid"..CT_RATarget.MainTanks[i][1]) and
                UnitName("raid"..CT_RATarget.MainTanks[i][1]) == CT_RATarget.MainTanks[i][2]
                then
                s = s.."("..CT_RATarget.MainTanks[i][2]..")"      
            end
        elseif oRAOMainTank then
            if oRAOMainTank.core.maintanktable[i] and
                UnitExists(self:GetUnitByName(oRAOMainTank.core.maintanktable[i])) and
                UnitName(self:GetUnitByName(oRAOMainTank.core.maintanktable[i])) == oRAOMainTank.core.maintanktable[i]
                then
                s = s.."("..oRAOMainTank.core.maintanktable[i]..")"
            end
        end
        return s
    end -- }}}
    for i=1,self.CONST.NUM_GROUPS[HEAL_TAB_INDEX] do
        str = string.gsub(str, "MT"..i, GetMainTankLabel(i))
    end
    -- }}}
    return str
end -- }}}

function RaidOrganizer:CHAT_MSG_WHISPER(msg, user) -- {{{
    if GetNumRaidMembers() == 0 then
        return
    end
    if msg == "assign" then
        local reply = ""
		local noassign = true
		for i=1, SYNC_TAB_NB do
        	if RO_RaiderTable[i][user] then
            	reply = reply .. " " .. RaidOrganizer_Tabs[i][1] .. " " .. self:ReplaceTokens(grouplabels[RO_RaiderTable[i][user]])
				noassign = false
			end
		end
		if noassign then
			reply = L["REPLY_NO_ARRANGEMENT"] .. " " .. reply
		else
			reply = L["REPLY_ARRANGEMENT_FOR"] .. " " .. reply
		end
        ChatThrottleLib:SendChatMessage("NORMAL", nil, reply, "WHISPER", nil, user)
    end
end -- }}}

function RaidOrganizer:OnMouseWheel(richtung) -- {{{
    if not this then
        return
    end
    local _,_,group,slot = string.find(this:GetName(), "RaidOrganizerDialogEinteilungHealGroup(%d+)Slot(%d+)")
    group,slot = tonumber(group),tonumber(slot)
    if not group or not slot then
        return
    end
    if group < 1 or group > self.CONST.NUM_GROUPS[RaidOrganizerDialog.selectedTab] or
        slot < 1 or slot > self.CONST.NUM_SLOTS[RaidOrganizerDialog.selectedTab] then
        return
    end
	local classdirection = {}
	for k,v in pairs(classTab[RaidOrganizerDialog.selectedTab]) do
		classdirection[k] = v;
	end
	if RaidOrganizerDialog.selectedTab == RAID_PLACEMENT_TAB_INDEX then
		for i = 1, 8 do
			table.insert(classdirection, "Group" .. i);
		end
	end
	table.insert(classdirection,1,"EMPTY");
    local pos = 1
    while (pos <= table.getn(classdirection)) do
        if groupclasses[group][slot] then
            if classdirection[pos] == groupclasses[group][slot] then
                break
            end
        else
            break
        end
        pos = pos + 1
    end
    pos = pos - richtung
    if 0 == pos then
        pos = table.getn(classdirection)
    end
    if table.getn(classdirection)+1 == pos then
        pos = 1
    end
    if "EMPTY" == classdirection[pos] then
        groupclasses[group][slot] = nil
    else
        groupclasses[group][slot] = classdirection[pos]
    end
    self:UpdateDialogValues()
end -- }}}

function RaidOrganizer:GetLabelByClass(class) -- {{{
    if (not class) or class == "" then
        return L["FREE"]
    end
    return L[class]
end -- }}}

function RaidOrganizer:MultipleArrangementCheckBox_OnClick()
	if RaidOrganizerDialog.selectedTab == RAID_FILL_TAB_INDEX then
		RaidOrganizerDialogEinteilungOptionenMultipleArrangementCheckBox:SetChecked(nil)
	end
	if RaidOrganizerDialogEinteilungOptionenMultipleArrangementCheckBox:GetChecked() == nil then
		for name, groupTable in pairs(RO_RaiderTable[RaidOrganizerDialog.selectedTab]) do
			local count = 0
			for i=2, MAX_GROUP_NB + 1 do
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

function RaidOrganizer:DisplayGroupNbCheckBox_OnClick()
	self:UpdateDialogValues()
end


function RaidOrganizer:SortGroupClass()
	local function SortEinteilung(a, b) --{{{
		if b == nil then return true end
		if a == nil then return false end
		if a ~= b then
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
			if a == "Group1" then -- (Paladin, *)
					return true
			end
			if b == "Group1" then -- (Paladin, *)
					return false
			end
			if a == "Group2" then -- (Paladin, *)
					return true
			end
			if b == "Group2" then -- (Paladin, *)
					return false
			end
			if a == "Group3" then -- (Paladin, *)
					return true
			end
			if b == "Group3" then -- (Paladin, *)
					return false
			end
			if a == "Group4" then -- (Paladin, *)
					return true
			end
			if b == "Group4" then -- (Paladin, *)
					return false
			end
			if a == "Group5" then -- (Paladin, *)
					return true
			end
			if b == "Group5" then -- (Paladin, *)
					return false
			end
			if a == "Group6" then -- (Paladin, *)
					return true
			end
			if b == "Group6" then -- (Paladin, *)
					return false
			end
			if a == "Group7" then -- (Paladin, *)
					return true
			end
			if b == "Group7" then -- (Paladin, *)
					return false
			end
			if a == "Group8" then -- (Paladin, *)
					return true
			end
			if b == "Group8" then -- (Paladin, *)
					return false
			end
			if a == "EMPTY" then -- (Paladin, *)
					return true
			end
			if b == "EMPTY" then -- (Paladin, *)
					return false
			end
		else
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
	if ((RaidOrganizerDialog.selectedTab == BUFF_MAGE_TAB_INDEX or RaidOrganizerDialog.selectedTab == BUFF_PRIEST_TAB_INDEX or RaidOrganizerDialog.selectedTab == BUFF_DRUID_TAB_INDEX)) then
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
			end
			progress = progress + table.getn(tableGroup)/nbBuffer
		end
		self:UpdateDialogValues()
	elseif (RaidOrganizerDialogEinteilungOptionenMultipleArrangementCheckBox:GetChecked() == nil) then
		for group=1, self.CONST.NUM_GROUPS[RaidOrganizerDialog.selectedTab] do
			for slot=1, self.CONST.NUM_SLOTS[RaidOrganizerDialog.selectedTab] do
				if groupclasses[group][slot] then
					if not einteilung[group+1][slot] then
						for _, name in pairs(einteilung[1]) do
							if RO_RaiderTable[RaidOrganizerDialog.selectedTab][name][group+1] == nil then
								local class, engClass = UnitClass(self:GetUnitByName(name))
								if engClass == groupclasses[group][slot] then
									RO_RaiderTable[RaidOrganizerDialog.selectedTab][name][group+1] = 1
									RO_RaiderTable[RaidOrganizerDialog.selectedTab][name][1] = nil
									self:UpdateDialogValues()
									break;
								elseif string.find(groupclasses[group][slot], "Group") then
									local _,_, grpIdx = string.find(groupclasses[group][slot], "Group(%d)")
									if tonumber(grpIdx) == groupByName[name] then
										RO_RaiderTable[RaidOrganizerDialog.selectedTab][name][group+1] = 1
										RO_RaiderTable[RaidOrganizerDialog.selectedTab][name][1] = nil
										self:UpdateDialogValues()
										break;
									end
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
								elseif string.find(groupclasses[group][slot], "Group") then
									local _,_, grpIdx = string.find(groupclasses[group][slot], "Group(%d)")
									if tonumber(grpIdx) == groupByName[name] then
										RO_RaiderTable[RaidOrganizerDialog.selectedTab][name][group+1] = 1
										self:UpdateDialogValues()
										boolCheck = false
										break;
									end
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
		if not RaidOrganizer.db.char.showBar then
			RaidOrganizerButtonsHorizontal:Hide()
		else
			RaidOrganizerButtonsHorizontal:Show()
		end
	else
		RaidOrganizerButtonsHorizontal:Hide()
		if not RaidOrganizer.db.char.showBar then
			RaidOrganizerButtonsVertical:Hide()
		else
			RaidOrganizerButtonsVertical:Show()
		end
	end
end

function RaidOrganizer:WriteTooltipText(id)
	if not RaidOrganizer:IsActive() then return end
	
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
	if RaidOrganizerDialog:IsShown() then
		self:UpdateDialogValues()
	end
	if (RaidOrganizerDialogBroadcastAutoSync:GetChecked() and (IsRaidLeader() or IsRaidOfficer())) then
		for tab = 1, SYNC_TAB_NB do
			RaidOrganizer:RaidOrganizer_SendSync(tab);
		end
	elseif not UnitInRaid('player') then
		self:ResetData()
	end
end

function RaidOrganizer:CHAT_MSG_ADDON(prefix, message, type, sender)
	
	if (prefix == "ROVersion") then 
		if self.b_versionQuery then
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
				for tab = 1, SYNC_TAB_NB do
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
		
		if tab_id > SYNC_TAB_NB then
			return
		end
		
		if length == 0 then
			RO_RaiderTable[tab_id] = {}; -- message to reset tab
			return
		end
		
		for i = 1, length do
			pattern = pattern .. '%s+(%a+)%s+(%d+)';
		end
		local sync_raider_table  = {string.find(message, pattern)};
		
		local charName;
		local charGroup;
		local value;
		for i = 1, length do
			charName = sync_raider_table[3 + i * 2];
			if not RO_RaiderTable[tab_id][charName] then
				RO_RaiderTable[tab_id][charName] = {};
			end
			
			for j = 1, string.len(sync_raider_table[4 + i * 2]) do
				charGroup = tonumber(string.sub(sync_raider_table[4 + i * 2], j, j));
				if charGroup > 1 and charGroup <= self.CONST.GROUPS[tab_id] then
					RO_RaiderTable[tab_id][charName][charGroup + 1] = 1;
					RO_RaiderTable[tab_id][charName][1] = nil;
				end
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
function RaidOrganizer:DisplayRaiderTable()
	for key,value in RO_RaiderTable do
		for key1, value1 in value do
			for key2, value2 in value1 do
				self:Debug("(tab : " .. key .. ") (" .. key1 .. ") (group " .. key2 .. ") (value : " .. value2 .. ")")
			end
		end
	end
end
		
function RaidOrganizer:ReorganizeRaid()
	self:RefreshRaiderTable()
	self:UpdateDialogValues()
	raidIDPerGroup = {{},{},{},{},{},{},{},{}}
	for i=1, self.CONST.NUM_GROUPS[RAID_FILL_TAB_INDEX] do
		raidIDPerGroup[i] = {0, 0, 0, 0, 0}
	end
	local count = 0
	local group_count = {0, 0, 0, 0, 0, 0, 0, 0}
	for i=1, MAX_RAID_MEMBERS do
		if UnitExists("raid"..i) then
			local unitname,_,subgroup = GetRaidRosterInfo(i)
			for j=1,5 do
				if raidIDPerGroup[subgroup][j] == 0 then
					raidIDPerGroup[subgroup][j] = i
					group_count[subgroup] = group_count[subgroup] + 1
					break
				end
			end
		end
	end
	local backup_group = 0
	for key, value in pairs(group_count) do
		if value < 5 then
			backup_group = key
		end
	end
		
	if backup_group == 0 then DEFAULT_CHAT_FRAME:AddMessage("RaidOrganizer : Reorganize Raid can't be performed if raid is full. Remove a raider and try again.") 	return end

	for i=1, MAX_RAID_MEMBERS do
		if UnitExists("raid"..i) then
			unitname = UnitName("raid"..i)
			local group = 0
			if RO_RaiderTable[RAID_FILL_TAB_INDEX][unitname] then
				for j = 1, self.CONST.NUM_GROUPS[RAID_FILL_TAB_INDEX] do
					if RO_RaiderTable[RAID_FILL_TAB_INDEX][unitname][j+1] == 1 then
						group = j
						break
					end
				end
				if group > 0 then
					if not (groupByName[unitname] == group) then
						local currentID = i
						local currentGroup = groupByName[unitname]
						local currentTableIndex = 0
						local targetID = 0
						local targetGroup = group
						local targetTableIndex = 0
						for k = 1, 5 do
							if raidIDPerGroup[currentGroup][k] == currentID then
								currentTableIndex = k
								break
							end
						end
						
						if group_count[targetGroup] == 5 then
							for targetTableIndex = 1, 5 do
								targetID = raidIDPerGroup[targetGroup][targetTableIndex]
								if (not (RO_RaiderTable[RAID_FILL_TAB_INDEX][UnitName("raid"..targetID)][targetGroup+1] == 1)) then
									SetRaidSubgroup(targetID, backup_group)
									SetRaidSubgroup(currentID, targetGroup)
									SetRaidSubgroup(targetID, currentGroup)
									groupByName[UnitName("raid"..targetID)] = currentGroup
									groupByName[unitname] = targetGroup
									raidIDPerGroup[targetGroup][targetTableIndex] = i
									raidIDPerGroup[currentGroup][currentTableIndex] = targetID
									break
								end
							end
						else
							for targetTableIndex = 1, 5 do
								if raidIDPerGroup[targetGroup][targetTableIndex] == 0 then
									SetRaidSubgroup(currentID, targetGroup)
									groupByName[unitname] = targetGroup
									raidIDPerGroup[currentGroup][currentTableIndex] = 0
									group_count[currentGroup] = group_count[currentGroup] - 1
									raidIDPerGroup[targetGroup][targetTableIndex] = currentID
									group_count[targetGroup] = group_count[targetGroup] + 1
									break
								end
							end
						end
					end
				end
			end
		end
	end
end

function RaidOrganizer:RaidOrganizer_SyncOnClick()
	if RaidOrganizerDialog.selectedTab == RAID_FILL_TAB_INDEX then
		if IsRaidLeader() then
			self:ReorganizeRaid()
		end
		return
	end
	
	-- other tab, sync
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
	if (IsRaidLeader() or IsRaidOfficer()) and RaidORganizer.b_versionQuery then
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
		if ( x ) then if ( x < 0 ) then x = x + 360; end RaidOrganizer.db.char.minimapPositionX = x; end
		if ( y ) then RaidOrganizer.db.char.minimapPositionY = y; end
	end
	x, y = RaidOrganizer.db.char.minimapPositionX, RaidOrganizer.db.char.minimapPositionY

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
		RaidOrganizer.db.char.showBar = not RaidOrganizer.db.char.showBar
		RaidOrganizer:ShowButtons()
	else
		dewdrop:Open(RaidOrganizerMinimapButton)
	end
end

function RaidOrganizerMinimapButton_OnInitialize()
	dewdrop:Register(RaidOrganizerMinimapButton, 'children', function() dewdrop:FeedAceOptionsTable(options) end)

	RaidOrganizerMinimapButton:SetNormalTexture("Interface\\Icons\\Inv_misc_head_dragon_black")
	RaidOrganizerMinimapButton:SetPushedTexture("Interface\\Icons\\Inv_misc_head_dragon_black")

	RaidOrganizer_Minimap_Position(nil, nil)
	
	if RaidOrganizer.db.char.showMinimap then
		RaidOrganizerMinimapButton:Show()
	end
end
