--[[
    Copyright (c) 2026 Krowi
    Licensed under the terms of the LICENSE file in this repository.
]]

---@diagnostic disable: undefined-global

local sub, parent = KROWI_LIBMAN:NewSubmodule('ElvUI', 0)
if not sub or not parent then return end

local function GetElvUI()
	return ElvUI and unpack(ElvUI)
end

local function IsLoaded()
	return ElvUI ~= nil
end

local function GetDataTextsModule()
	return GetElvUI():GetModule('DataTexts')
end

local function GetSettings(addonName)
	return GetElvUI().global.datatexts.settings['LDB_' .. addonName]
end

local function IsFrame(caller)
	if not caller then
		return false
	end

	while caller do
		local name = caller:GetName()
		if name and name:find('ElvUI') then
			return true
		end
		caller = caller:GetParent()
	end

	return false
end

local function LoadIntegrationLocale()
	if not sub.IL then
		C_AddOns.LoadAddOn('ElvUI_Options')
		sub.IL = select(2, unpack(GetElvUI().Config))
	end
end

local function CreateCheckbox(menuBuilder, addonName, _parent, text, key, onRefresh)
	return menuBuilder:CreateCustomCheckbox(_parent, text,
		function()
			local settings = GetSettings(addonName)
			return settings and settings[key] or false
		end,
		function()
			local settings = GetSettings(addonName)
			if not settings then
				return
			end

			settings[key] = not settings[key]
			GetDataTextsModule():ForceUpdate_DataText('LDB_' .. addonName)

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

	local elvUIOptions = menuBuilder:CreateSubmenuButton(menuObj, parent.L['ElvUI Options'])
	CreateCheckbox(menuBuilder, addonName, elvUIOptions, sub.IL['Show Icon'], 'icon', onRefresh)
	CreateCheckbox(menuBuilder, addonName, elvUIOptions, sub.IL['Show Label'], 'label', onRefresh)
	CreateCheckbox(menuBuilder, addonName, elvUIOptions, sub.IL['Show Text'], 'text', onRefresh)
	menuBuilder:AddChildMenu(menuObj, elvUIOptions)
end

function parent:RegisterCreateElvUIOptionsMenu(addonName, addon)
	addon.Menu.CreateElvUIOptionsMenu = function(menuBuilder, menuObj, caller, onRefresh)
		CreateOptionsMenu(menuBuilder, menuObj, addonName, caller, onRefresh or addon.Menu.RefreshBroker)
	end
end