--[[
    Copyright (c) 2026 Krowi
    Licensed under the terms of the LICENSE file in this repository.
]]

---@diagnostic disable: undefined-global

KROWI_BROKERS_MAJOR, KROWI_BROKERS_MINOR = "Krowi_Brokers-1.0", 6
KROWI_LIB_CURRENT = KROWI_BROKERS_MAJOR

local lib = LibStub:NewLibrary(KROWI_LIB_CURRENT, KROWI_BROKERS_MINOR)
if not lib then	return end
lib.Major = KROWI_LIB_CURRENT

function lib:InitBroker(addonName, addon, onEnter, onLeave, onClick, onEvent)
    if addon.Menu then
        addon.Menu.Init()
		self:RegisterCreateElvUIOptionsMenu(addonName, addon)
		self:RegisterCreateTitanOptionsMenu(addonName, addon)
    end

    if addon.Tooltip then
        addon.Tooltip.Init()
    end

    local dataObject = LibStub("LibDataBroker-1.1"):NewDataObject(addonName, {
		type = "data source",
		tocname = addonName,
		icon = addon.Metadata.Icon,
		text = addon.Metadata.Title .. " " .. addon.Metadata.Version,
		category = "Information",
		OnEnter = onEnter,
		OnLeave = onLeave,
		OnClick = onClick,
	})

	function dataObject:Update()
		self.text = addon.GetDisplayText()
	end

	dataObject:Update()

	addon.LDB = dataObject

    if onEvent then
        self:RegisterOnEvent(onEvent)
    end
end

function lib:GetHelperFrame()
	if self.HelperFrame then
		return self.HelperFrame
	end

	self.HelperFrame = CreateFrame("Frame", "Krowi_Brokers_HelperFrame")
	return self.HelperFrame
end

local eventFrameOnEventHandlers = {}
local function HelperFrameOnEvent(_, event, ...)
	for _, handler in next, eventFrameOnEventHandlers do
		handler(event, ...)
	end
end

function lib:RegisterEvents(...)
	local helperFrame = self:GetHelperFrame()
	for i = 1, select("#", ...) do
		local event = select(i, ...)
		helperFrame:RegisterEvent(event)
	end
end

function lib:RegisterOnEvent(handler)
	tinsert(eventFrameOnEventHandlers, handler)
	local helperFrame = self:GetHelperFrame()
	if not helperFrame:GetScript("OnEvent") then
		helperFrame:SetScript("OnEvent", HelperFrameOnEvent)
	end
end

local onUpdateHandlers = {}
local function HelperFrameOnUpdate(_, elapsed)
	for _, handler in next, onUpdateHandlers do
		handler(elapsed)
	end
end

function lib:RegisterOnUpdate(handler)
	tinsert(onUpdateHandlers, handler)
	local helperFrame = self:GetHelperFrame()
	if not helperFrame:GetScript("OnUpdate") then
		helperFrame:SetScript("OnUpdate", HelperFrameOnUpdate)
	end
end