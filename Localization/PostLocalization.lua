--[[
    Copyright (c) 2026 Krowi
    Licensed under the terms of the LICENSE file in this repository.
]]

---@diagnostic disable: undefined-global

local lib = LibStub(KROWI_LIB_CURRENT, true)
if not lib and not lib.L then return end

-- local l = lib.Localization.GetLocale()
-- lib.L["Requires a reload"] = l["Requires a reload"]:SetColorOrange()

lib.L = lib.Localization.GetLocale()