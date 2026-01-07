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

local lib = LibStub("Krowi_Brokers-1.0", true)
if not lib then	return end

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

local localeCache, integrationLocaleCache
local function GetLocales()
	if not localeCache or not integrationLocaleCache then
		localeCache = LibStub("AceLocale-3.0"):GetLocale("Krowi_Brokers-1.0", true)
		C_AddOns.LoadAddOn("ElvUI_Options")
		integrationLocaleCache = select(2, unpack(GetElvUI().Config))
	end
	return localeCache, integrationLocaleCache
end

local function CreateCheckbox(menuBuilder, addonName, parent, text, key, onRefresh)
	return menuBuilder:CreateCustomCheckbox(parent, text,
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

	local L, IL = GetLocales()

	menuBuilder:CreateDivider(menuObj)

	local elvUIOptions = menuBuilder:CreateSubmenuButton(menuObj, L["ElvUI Options"])
	CreateCheckbox(menuBuilder, addonName, elvUIOptions, IL["Show Icon"], 'icon', onRefresh)
	CreateCheckbox(menuBuilder, addonName, elvUIOptions, IL["Show Label"], 'label', onRefresh)
	CreateCheckbox(menuBuilder, addonName, elvUIOptions, IL["Show Text"], 'text', onRefresh)
	menuBuilder:AddChildMenu(menuObj, elvUIOptions)
end

function lib:RegisterCreateElvUIOptionsMenu(addonName, addon)
	addon.Menu.CreateElvUIOptionsMenu = function(menuBuilder, menuObj, caller, onRefresh)
		CreateOptionsMenu(menuBuilder, menuObj, addonName, caller, onRefresh or addon.Menu.RefreshBroker)
	end
end