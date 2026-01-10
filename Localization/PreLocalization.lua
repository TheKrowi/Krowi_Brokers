--[[
    Copyright (c) 2026 Krowi
    Licensed under the terms of the LICENSE file in this repository.
]]

---@diagnostic disable: undefined-global

local lib = LibStub(KROWI_LIB_CURRENT)
if not lib or lib.Localization then return end

lib.Localization = {}
local localization = lib.Localization

local localeIsLoaded, defaultLocale = {}, 'enUS'

function localization.NewDefaultLocale()
    if localeIsLoaded[defaultLocale] then return end

    localeIsLoaded[defaultLocale] = true
    return LibStub(KROWI_ACE_LOCALE):NewLocale(lib.Major, defaultLocale, true)
end

function localization.NewLocale(locale)
    if localeIsLoaded[locale] then return end

    localeIsLoaded[locale] = true
    return LibStub(KROWI_ACE_LOCALE):NewLocale(lib.Major, locale)
end

function localization.GetLocale()
    return LibStub(KROWI_ACE_LOCALE):GetLocale(lib.Major)
end