![Retail](https://img.shields.io/badge/Retail-11.2.7-008833?style=for-the-badge) ![Mists](https://img.shields.io/badge/Mists-5.5.3-28ae7e?style=for-the-badge) ![Classic](https://img.shields.io/badge/Classic-1.15.8-c39361?style=for-the-badge)<br>
[![CurseForge](https://img.shields.io/badge/curseforge-download-F16436?style=for-the-badge&logo=curseforge&logoColor=white)](https://www.curseforge.com/wow/addons/krowi-brokers) [![Wago](https://img.shields.io/badge/Wago-Download-c1272d?style=for-the-badge)](https://addons.wago.io/addons/krowi-brokers)<br>
[![Discord](https://img.shields.io/badge/discord-join-5865F2?style=for-the-badge&logo=discord&logoColor=white)](https://discord.gg/mdBFQJYeQZ) [![PayPal](https://img.shields.io/badge/paypal-donate-002991.svg?style=for-the-badge&logo=paypal&logoColor=white)](https://www.paypal.com/donate/?hosted_button_id=9QEDV37APQ6YJ)

A lightweight library for World of Warcraft addon development that simplifies creating LibDataBroker data sources with integrated event handling, custom callbacks, automatic initialization, and built-in support for ElvUI and Titan Panel integration.

## Features

### Broker System (`Krowi_Brokers-1.0`)
- **Simple API**: Easy-to-use method for initializing LibDataBroker data objects
- **Integrated Event Handling**: Built-in event frame management for handling WoW events
- **OnUpdate Support**: Register custom OnUpdate handlers for frame updates
- **Custom Callbacks**: Support for OnEnter, OnLeave, OnClick, and OnEvent callbacks
- **Automatic Updates**: Dynamic text updates through getDisplayText callback
- **Menu Integration**: Optional menu system initialization support
- **Tooltip Integration**: Optional tooltip system initialization support
- **Multiple Handlers**: Support for multiple event handlers on the same event frame
- **LibStub Support**: Standard LibStub library structure for dependency management

### ElvUI Integration (`Krowi_Brokers_ElvUIIntegration-1.0`)
- **Automatic Detection**: Detects ElvUI presence and provides integration options
- **Menu Builder Extension**: Extends MenuBuilder with `CreateElvUIMenu()` method
- **Display Options**: Toggle icon, label, and text visibility for ElvUI DataTexts
- **Settings Sync**: Integrates with ElvUI's DataText settings system
- **Auto-Refresh**: Automatically refreshes display when settings change

### Titan Panel Integration (`Krowi_Brokers_TitanIntegration-1.0`)
- **Automatic Detection**: Detects Titan Panel presence and provides integration options
- **Menu Builder Extension**: Extends MenuBuilder with `CreateTitanMenu()` method
- **Display Options**: Toggle icon, label, text, and side positioning for Titan Panel plugins
- **Settings Sync**: Integrates with Titan Panel's plugin settings system
- **Auto-Refresh**: Automatically refreshes display when settings change

### Localization System
- **AceLocale-3.0 Integration**: Built-in localization support
- **Multi-Language Ready**: Framework for adding multiple language translations
- **CurseForge Integration**: Designed to work with CurseForge localization system

## Usage Examples

### Basic Broker Setup

```lua
local broker = LibStub("Krowi_Brokers-1.0")
local addonName, addon = ...  -- Get addon namespace

-- Addon must have Metadata table with Title, Version, Icon, and GetDisplayText function
addon.Metadata = {
    Title = "My Addon",
    Version = "1.0.0",
    Icon = "Interface\\Icons\\INV_Misc_QuestionMark"
}

-- Required: GetDisplayText function
function addon.GetDisplayText()
    return "Dynamic Text: " .. time()
end

-- Initialize a simple broker (uses global addon variables as of v1.0.3)
broker:InitBroker(
    function(frame)                -- OnEnter
        GameTooltip:SetOwner(frame, "ANCHOR_LEFT")
        GameTooltip:AddLine("My Addon")
        GameTooltip:Show()
    end,
    function(frame)                -- OnLeave
        GameTooltip:Hide()
    end,
    function(frame, button)        -- OnClick
        print("Broker clicked with " .. button)
    end,
    function(event, ...)           -- OnEvent (no self parameter as of v1.0.3)
        print("Event received:", event)
    end
)
```

### Advanced Example with Event Handling

```lua
local broker = LibStub("Krowi_Brokers-1.0")
local addonName, addon = ...

-- Setup addon metadata
addon.Metadata = {
    Title = "My Broker Addon",
    Version = "1.0.0",
    Icon = "Interface\\Icons\\Achievement_General"
}

-- Required: GetDisplayText function
function addon.GetDisplayText()
    return "Some dynamic text"
end

-- Optional: Setup menu and tooltip systems
addon.Menu = { Init = function() print("Menu initialized") end }
addon.Tooltip = { Init = function() print("Tooltip initialized") end }

-- Initialize broker with event handling
broker:InitBroker(
    OnEnterHandler,
    OnLeaveHandler,
    OnClickHandler,
    OnEventHandler
)

-- Register additional events
broker:RegisterEvents("PLAYER_ENTERING_WORLD", "ZONE_CHANGED_NEW_AREA")

-- The broker data object is now available at addon.LDB
-- Update display text manually
addon.LDB:Update()
```

### Event Handler Implementation

```lua
-- Example event handler function (no self parameter as of v1.0.3)
local function OnEventHandler(event, ...)
    if event == "PLAYER_ENTERING_WORLD" then
        print("Player entered world")
    elseif event == "ZONE_CHANGED_NEW_AREA" then
        local zoneName = GetZoneText()
        print("Zone changed to:", zoneName)
    end
end

-- Register multiple event handlers for the same events
local broker = LibStub("Krowi_Brokers-1.0")

broker:RegisterOnEvent(function(event, ...)
    print("Handler 1:", event)
end)

broker:RegisterOnEvent(function(event, ...)
    print("Handler 2:", event)
end)

-- Register the events to listen for
broker:RegisterEvents("PLAYER_REGEN_DISABLED", "PLAYER_REGEN_ENABLED")
```

### OnUpdate Handler Implementation

```lua
local broker = LibStub("Krowi_Brokers-1.0")

-- Register an OnUpdate handler (no self parameter as of v1.0.3)
broker:RegisterOnUpdate(function(elapsed)
    -- Update logic that runs every frame
    -- elapsed is the time since last update in seconds
end)
```

### ElvUI Integration Example

```lua
local broker = LibStub("Krowi_Brokers-1.0")
local elvUIIntegration = LibStub("Krowi_Brokers_ElvUIIntegration-1.0")
local menuBuilder = LibStub("Krowi_MenuBuilder-1.0"):New(config)

-- Extend MenuBuilder with ElvUI support
elvUIIntegration:ExtendMenuBuilder(menuBuilder)

-- In your menu creation function
function menuBuilder:CreateMenu()
    local menu = self:GetMenu()
    
    -- Your regular menu items
    self:CreateTitle(menu, "My Addon Options")
    -- ... more menu items ...
    
    -- Add ElvUI options if ElvUI is detected
    self:CreateElvUIMenu(menu, caller, function()
        -- Optional refresh callback
        print("ElvUI settings changed")
    end)
end
```

### Titan Panel Integration Example

```lua
local broker = LibStub("Krowi_Brokers-1.0")
local titanIntegration = LibStub("Krowi_Brokers_TitanIntegration-1.0")
local menuBuilder = LibStub("Krowi_MenuBuilder-1.0"):New(config)

-- Extend MenuBuilder with Titan Panel support
titanIntegration:ExtendMenuBuilder(menuBuilder)

-- In your menu creation function
function menuBuilder:CreateMenu()
    local menu = self:GetMenu()
    
    -- Your regular menu items
    self:CreateTitle(menu, "My Addon Options")
    -- ... more menu items ...
    
    -- Add Titan Panel options if Titan Panel is detected
    self:CreateTitanMenu(menu, caller, function()
        -- Optional refresh callback
        print("Titan Panel settings changed")
    end)
end
```

## API Reference

### Krowi_Brokers-1.0

#### Creating a Broker Library Instance
```lua
local broker = LibStub("Krowi_Brokers-1.0")
```

#### Broker Functions

| Function | Parameters | Description |
|----------|------------|-------------|
| `InitBroker(onEnter, onLeave, onClick, onEvent)` | See below | Initializes a LibDataBroker data object with callbacks and event handling |
| `GetHelperFrame()` | - | Returns the shared helper frame, creating it if it doesn't exist |
| `RegisterEvents(...)` | `...` (strings) | Registers one or more WoW events to the helper frame |
| `RegisterOnEvent(handler)` | `handler` (function) | Adds an event handler function that will be called for all registered events |
| `RegisterOnUpdate(handler)` | `handler` (function) | Adds an OnUpdate handler function that will be called every frame |

#### InitBroker() Parameters

**Note**: As of v1.0.3, `InitBroker()` uses the global `addonName` and `addon` variables from the addon namespace (defined as `local addonName, addon = ...`). The addon object must have:
- `addon.Metadata.Title` - The addon title
- `addon.Metadata.Version` - The addon version
- `addon.Metadata.Icon` - Path to the icon texture file
- `addon.GetDisplayText()` - Function that returns the current display text

It also automatically initializes `addon.Menu` and `addon.Tooltip` if they exist with an `Init()` method.

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `onEnter` | function | No | Callback when mouse enters the broker frame. Parameters: `(frame)` |
| `onLeave` | function | No | Callback when mouse leaves the broker frame. Parameters: `(frame)` |
| `onClick` | function | No | Callback when broker is clicked. Parameters: `(frame, button)` |
| `onEvent` | function | No | Callback for registered events. Parameters: `(event, ...)` (no self in v1.0.3+) |

#### Event Handler Function Signature

Event handlers registered via `RegisterOnEvent` or passed to `InitBroker` should follow this signature (changed in v1.0.3):

```lua
function(event, ...)
    -- event: string name of the WoW event
    -- ...: event-specific arguments
end
```

**Note**: As of v1.0.3, event handlers no longer receive the `self` parameter.

#### Update Handler Function Signature

Update handlers registered via `RegisterOnUpdate` should follow this signature:

```lua
function(elapsed)
    -- elapsed: time in seconds since the last update
end
```

#### Broker Data Object

After calling `InitBroker`, the LibDataBroker data object is stored at `addon.LDB` with the following properties and methods:

| Property/Method | Type | Description |
|-----------------|------|-------------|
| `type` | string | Always set to "data source" |
| `tocname` | string | The addon name |
| `icon` | string | Path to the icon texture |
| `text` | string | Current display text |
| `category` | string | Always set to "Information" |
| `OnEnter` | function | Mouse enter callback |
| `OnLeave` | function | Mouse leave callback |
| `OnClick` | function | Click callback |
| `Update()` | method | Call this to update the display text using `getDisplayText()` |

### Krowi_Brokers_ElvUIIntegration-1.0

#### ElvUI Integration Functions

| Function | Parameters | Description |
|----------|------------|-------------|
| `ExtendMenuBuilder(menuBuilder)` | `menuBuilder` (MenuBuilder) | Adds `CreateElvUIMenu` method to the MenuBuilder instance |
| `CreateElvUIMenu(menuBuilder, menuObj, caller, onRefresh)` | See below | Creates ElvUI-specific menu options (added to menuBuilder) |

#### CreateElvUIMenu() Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `menuBuilder` | MenuBuilder | Yes | The MenuBuilder instance |
| `menuObj` | menu | Yes | The menu object to add ElvUI options to |
| `caller` | frame | Yes | The calling frame (used to detect if ElvUI is the caller) |
| `onRefresh` | function | No | Optional callback function called when settings change |

**Note**: This function only adds menu items if ElvUI is loaded and the caller is an ElvUI frame.

### Krowi_Brokers_TitanIntegration-1.0

#### Titan Panel Integration Functions

| Function | Parameters | Description |
|----------|------------|-------------|
| `ExtendMenuBuilder(menuBuilder)` | `menuBuilder` (MenuBuilder) | Adds `CreateTitanMenu` method to the MenuBuilder instance |
| `CreateTitanMenu(menuBuilder, menuObj, caller, onRefresh)` | See below | Creates Titan Panel-specific menu options (added to menuBuilder) |

#### CreateTitanMenu() Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `menuBuilder` | MenuBuilder | Yes | The MenuBuilder instance |
| `menuObj` | menu | Yes | The menu object to add Titan Panel options to |
| `caller` | frame | Yes | The calling frame (used to detect if Titan Panel is the caller) |
| `onRefresh` | function | No | Optional callback function called when settings change |

**Note**: This function only adds menu items if Titan Panel is loaded and the caller is a Titan Panel frame.

## Use Cases
- Creating LibDataBroker plugins for broker addons like Bazooka, ChocolateBar, ElvUI, Titan Panel
- Displaying dynamic information in the broker display
- Handling WoW events in broker addons
- Creating lightweight information displays with ElvUI and Titan Panel integration
- Building data source plugins with minimal boilerplate code
- Managing event-driven broker updates
- Providing consistent menu options across different broker display addons
- Frame-based updates with OnUpdate handlers

## Requirements
- LibStub
- LibDataBroker-1.1
- AceLocale-3.0 (for localization)
- Krowi_MenuBuilder-1.0 (optional, for ElvUI/Titan Panel menu integration)