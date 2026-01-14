--[[
    Copyright (c) 2026 Krowi
    Licensed under the terms of the LICENSE file in this repository.
]]

---@diagnostic disable: undefined-global

local sub, parent = KROWI_LIBMAN:NewSubmodule('Titan', 0)
if not sub or not parent then return end

local function IsLoaded()
	return TITAN_ID ~= nil
end

local function IsFrame(caller)
	if not caller then
		return false
	end

	while caller do
		local name = caller:GetName()
		if name and (name:find('TitanPanel') or name:find(TITAN_PANEL_DISPLAY_PREFIX)) then
			return true
		end
		caller = caller:GetParent()
	end

	return false
end

local function LoadIntegrationLocale()
	if not sub.IL then
		sub.IL = LibStub('AceLocale-3.0'):GetLocale(TITAN_ID, true)
	end
end

local function CreateCheckbox(menuBuilder, addonName, _parent, text, key, onRefresh)
	return menuBuilder:CreateCustomCheckbox(_parent, text,
		function()
			local value = TitanGetVar(addonName, key)
			return value == 1 or value == true
		end,
		function()
            TitanToggleVar(addonName, key)

            if key == 'DisplayOnRightSide' then
                local bar = TitanUtils_GetWhichBar(addonName)
                if bar then
                    TitanPanel_RemoveButton(addonName)
                    TitanUtils_AddButtonOnBar(bar, addonName)
                end
            else
                TitanPanelButton_UpdateButton(addonName)
            end

			if onRefresh then
				onRefresh()
			end
		end
	)
end

local function CreateOptionsMenu(menuBuilder, menuObj, addonName, caller, onRefresh)
	if not IsLoaded() or not IsFrame(caller) then
		return
	end

	LoadIntegrationLocale()

	menuBuilder:CreateDivider(menuObj)

	local titanOptions = menuBuilder:CreateSubmenuButton(menuObj, parent.L['Titan Panel Options'])
	CreateCheckbox(menuBuilder, addonName, titanOptions, sub.IL['TITAN_PANEL_MENU_SHOW_ICON'], 'ShowIcon', onRefresh)
	CreateCheckbox(menuBuilder, addonName, titanOptions, sub.IL['TITAN_PANEL_MENU_SHOW_LABEL_TEXT'], 'ShowLabelText', onRefresh)
	CreateCheckbox(menuBuilder, addonName, titanOptions, sub.IL['TITAN_PANEL_MENU_SHOW_PLUGIN_TEXT'], 'ShowRegularText', onRefresh)
	CreateCheckbox(menuBuilder, addonName, titanOptions, sub.IL['TITAN_CLOCK_MENU_DISPLAY_ON_RIGHT_SIDE'], 'DisplayOnRightSide', onRefresh)
	menuBuilder:CreateDivider(titanOptions)
	menuBuilder:CreateButton(titanOptions, sub.IL['TITAN_PANEL_MENU_HIDE'], function()
		TitanPanelRightClickMenu_Hide(addonName)
	end)
	menuBuilder:AddChildMenu(menuObj, titanOptions)
end

function parent:RegisterCreateTitanOptionsMenu(addonName, addon)
	addon.Menu.CreateTitanOptionsMenu = function(menuBuilder, menuObj, caller, onRefresh)
		CreateOptionsMenu(menuBuilder, menuObj, addonName, caller, onRefresh or addon.Menu.RefreshBroker)
	end
end