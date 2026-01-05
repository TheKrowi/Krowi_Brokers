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

local MAJOR, MINOR = "Krowi_Brokers_ElvUIIntegration-1.0", KROWI_BROKERS_LIBRARY_MINOR
local lib = LibStub:NewLibrary(MAJOR, MINOR)
if not lib then	return end

local addonName, addon = ...;
addon.L = LibStub("AceLocale-3.0"):GetLocale(addonName);

lib.MAJOR = MAJOR
lib.MINOR = MINOR

-- Private Helper Functions

local function GetElvUI()
	return ElvUI and unpack(ElvUI)
end

local function IsElvUILoaded()
	return ElvUI ~= nil
end

local function GetElvUIDataTextsModule()
	return GetElvUI():GetModule('DataTexts')
end

local function GetElvUISettings()
	return GetElvUI().global.datatexts.settings['LDB_' .. addonName]
end

local function IsElvUIFrame(caller)
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

local function GetElvUILocalization()
    C_AddOns.LoadAddOn("ElvUI_Options")
	return select(2, unpack(GetElvUI().Config))
end

local function CreateElvUICheckbox(menuBuilder, parent, text, elvKey, onRefresh)
	return menuBuilder:CreateCustomCheckbox(parent, text,
		function()
			local settings = GetElvUISettings(addonName)
			return settings and settings[elvKey] or false
		end,
		function()
			local settings = GetElvUISettings(addonName)
			if not settings then
				return
			end

			settings[elvKey] = not settings[elvKey]
			GetElvUIDataTextsModule():ForceUpdate_DataText('LDB_' .. addonName)

			if onRefresh then
				onRefresh()
			end
		end
	)
end

-- Public API

function lib.CreateElvUIMenu(menuBuilder, menuObj, caller, onRefresh)
	if not IsElvUILoaded() or not IsElvUIFrame(caller) then
		return
	end

	local L = GetElvUILocalization()
	menuBuilder:CreateDivider(menuObj)

	local elvUIOptions = menuBuilder:CreateSubmenuButton(menuObj, addon.L['ElvUI Options'])
	CreateElvUICheckbox(menuBuilder, elvUIOptions, L["Show Icon"], 'icon', onRefresh)
	CreateElvUICheckbox(menuBuilder, elvUIOptions, L["Show Label"], 'label', onRefresh)
	CreateElvUICheckbox(menuBuilder, elvUIOptions, L["Show Text"], 'text', onRefresh)
	menuBuilder:AddChildMenu(menuObj, elvUIOptions)
end

function lib:ExtendMenuBuilder(menuBuilder)
	if not menuBuilder or menuBuilder.CreateElvUIMenu then
		return
	end

	menuBuilder.CreateElvUIMenu = lib.CreateElvUIMenu
end