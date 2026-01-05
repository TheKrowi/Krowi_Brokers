--[[
    Copyright (c) 2026 Krowi

    All Rights Reserved unless otherwise explicitly stated.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
    SOFTWARE.
]]

---@diagnostic disable: undefined-global

local MAJOR, MINOR = "Krowi_Brokers_TitanIntegration-1.0", KROWI_BROKERS_LIBRARY_MINOR
local lib = LibStub:NewLibrary(MAJOR, MINOR)
if not lib then	return end

local addonName, addon = ...;
addon.L = LibStub("AceLocale-3.0"):GetLocale(addonName);

lib.MAJOR = MAJOR
lib.MINOR = MINOR

-- Private Helper Functions

local function IsTitanLoaded()
	return TITAN_ID ~= nil
end

local function IsTitanFrame(caller)
	if not caller then
		return false
	end

	while caller do
		local name = caller:GetName()
        print(name)
		if name and (name:find('TitanPanel') or name:find(TITAN_PANEL_DISPLAY_PREFIX)) then
			return true
		end
		caller = caller:GetParent()
	end

	return false
end

local function GetTitanLocalization()
	return LibStub("AceLocale-3.0"):GetLocale(TITAN_ID, true)
end

local function CreateTitanCheckbox(menuBuilder, parent, text, titanKey, onRefresh)
	return menuBuilder:CreateCustomCheckbox(parent, text,
		function()
			local value = TitanGetVar(addonName, titanKey)
			return value == 1 or value == true
		end,
		function()
            TitanToggleVar(addonName, titanKey)

            if titanKey == "DisplayOnRightSide" then
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

-- Public API

function lib.CreateTitanMenu(menuBuilder, menuObj, caller, onRefresh)
	if not IsTitanLoaded() or not IsTitanFrame(caller) then
		return
	end

	local L = GetTitanLocalization()

	menuBuilder:CreateDivider(menuObj)

	local titanOptions = menuBuilder:CreateSubmenuButton(menuObj, addon.L['Titan Panel Options'])
	CreateTitanCheckbox(menuBuilder, titanOptions, L["TITAN_PANEL_MENU_SHOW_ICON"], 'ShowIcon', onRefresh)
	CreateTitanCheckbox(menuBuilder, titanOptions, L["TITAN_PANEL_MENU_SHOW_LABEL_TEXT"], 'ShowLabelText', onRefresh)
	CreateTitanCheckbox(menuBuilder, titanOptions, L["TITAN_PANEL_MENU_SHOW_PLUGIN_TEXT"], 'ShowRegularText', onRefresh)
	CreateTitanCheckbox(menuBuilder, titanOptions, L["TITAN_CLOCK_MENU_DISPLAY_ON_RIGHT_SIDE"], 'DisplayOnRightSide', onRefresh)
	menuBuilder:AddChildMenu(menuObj, titanOptions)
end

function lib:ExtendMenuBuilder(menuBuilder)
	if not menuBuilder or menuBuilder.CreateTitanMenu then
		return
	end

	menuBuilder.CreateTitanMenu = lib.CreateTitanMenu
end