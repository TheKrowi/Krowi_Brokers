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

-- Define shared minor version for all Krowi_Brokers libraries
KROWI_BROKERS_LIBRARY_MINOR = 3

local MAJOR, MINOR = "Krowi_Brokers-1.0", KROWI_BROKERS_LIBRARY_MINOR
local lib = LibStub:NewLibrary(MAJOR, MINOR)
if not lib then	return end

local addonName, addon = ...;

lib.MAJOR = MAJOR
lib.MINOR = MINOR

-- Init handling

function lib:InitBroker(onEnter, onLeave, onClick, onEvent)
    if addon.Menu then
        addon.Menu.Init()
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

-- OnEvent handling

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

-- OnUpdate handling

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