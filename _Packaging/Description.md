A lightweight library for World of Warcraft addon development that simplifies creating LibDataBroker data sources with integrated event handling, custom callbacks, automatic initialization, and built-in support for ElvUI and Titan Panel integration.

## Features

### Broker System (`Krowi_Brokers`)
- **Simple API**: Easy-to-use method for initializing LibDataBroker data objects
- **Integrated Event Handling**: Built-in event frame management for handling WoW events
- **OnUpdate Support**: Register custom OnUpdate handlers for frame updates
- **Custom Callbacks**: Support for OnEnter, OnLeave, OnClick, and OnEvent callbacks
- **Automatic Updates**: Dynamic text updates through getDisplayText callback
- **Menu Integration**: Optional menu system initialization support
- **Tooltip Integration**: Optional tooltip system initialization support
- **Multiple Handlers**: Support for multiple event handlers on the same event frame
- **KROWI_LIBMAN Support**: Modern library management through KROWI_LIBMAN system

### ElvUI Integration (`Krowi_Brokers` - ElvUI Module)
- **Automatic Detection**: Detects ElvUI presence and provides integration options
- **Automatic Registration**: ElvUI options menu is automatically registered when calling `InitBroker()`
- **Display Options**: Toggle icon, label, and text visibility for ElvUI DataTexts
- **Settings Sync**: Integrates with ElvUI's DataText settings system
- **Auto-Refresh**: Automatically refreshes display when settings change

### Titan Panel Integration (`Krowi_Brokers` - Titan Module)
- **Automatic Detection**: Detects Titan Panel presence and provides integration options
- **Automatic Registration**: Titan Panel options menu is automatically registered when calling `InitBroker()`
- **Display Options**: Toggle icon, label, text, and side positioning for Titan Panel plugins
- **Settings Sync**: Integrates with Titan Panel's plugin settings system
- **Auto-Refresh**: Automatically refreshes display when settings change

### Localization System
- **KROWI_LIBMAN Integration**: Built-in localization support through KROWI_LIBMAN
- **Multi-Language Ready**: Framework for adding multiple language translations
- **CurseForge Integration**: Designed to work with CurseForge localization system

## Usage Examples

### Basic Broker Setup

```lua
local lib = KROWI_LIBMAN:GetLibrary('Krowi_Brokers')
local addonName, addon = ...  -- Get addon namespace

-- Addon must have Metadata table with Title, Version, Icon, and GetDisplayText function
addon.Metadata = {
    Title = "My Addon",
    Version = "1.0.0",
    Icon = "Interface\\Icons\\INV_Misc_QuestionMark"
}

-- Required: GetDisplayText function
function addon:GetDisplayText()
    return "Dynamic Text: " .. time()
end

-- Initialize a simple broker
lib:InitBroker(addonName, addon,
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
local lib = KROWI_LIBMAN:GetLibrary('Krowi_Brokers')
local addonName, addon = ...

-- Setup addon metadata
addon.Metadata = {
    Title = "My Broker Addon",
    Version = "1.0.0",
    Icon = "Interface\\Icons\\Achievement_General"
}

-- Required: GetDisplayText function
function addon:GetDisplayText()
    return "Some dynamic text"
end

-- Optional: Setup menu and tooltip systems
addon.Menu = { Init = function() print("Menu initialized") end }
addon.Tooltip = { Init = function() print("Tooltip initialized") end }

-- Initialize broker with event handling
lib:InitBroker(
    addonName,
    addon,
    OnEnterHandler,
    OnLeaveHandler,
    OnClickHandler,
    OnEventHandler
)

-- Register additional events
lib:RegisterEvents("PLAYER_ENTERING_WORLD", "ZONE_CHANGED_NEW_AREA")

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
local lib = KROWI_LIBMAN:GetLibrary('Krowi_Brokers')

lib:RegisterOnEvent(function(event, ...)
    print("Handler 1:", event)
end)

lib:RegisterOnEvent(function(event, ...)
    print("Handler 2:", event)
end)

-- Register the events to listen for
lib:RegisterEvents("PLAYER_REGEN_DISABLED", "PLAYER_REGEN_ENABLED")
```

### OnUpdate Handler Implementation

```lua
local lib = KROWI_LIBMAN:GetLibrary('Krowi_Brokers')

-- Register an OnUpdate handler (no self parameter as of v1.0.3)
lib:RegisterOnUpdate(function(elapsed)
    -- Update logic that runs every frame
    -- elapsed is the time since last update in seconds
end)
```

### ElvUI Integration Example

```lua
local addonName, addon = ...
local lib = KROWI_LIBMAN:GetLibrary('Krowi_Brokers')

-- ElvUI integration is automatically set up when you call InitBroker()
-- The CreateElvUIOptionsMenu function is added to addon.Menu automatically

-- In your menu creation function
function addon.Menu.Create(menuBuilder, menuObj, caller)
    -- Your regular menu items
    menuBuilder:CreateTitle(menuObj, "My Addon Options")
    -- ... more menu items ...
    
    -- Call the ElvUI options menu creator (automatically available after InitBroker)
    -- This will add ElvUI options only if ElvUI is detected and caller is an ElvUI frame
    addon.Menu.CreateElvUIOptionsMenu(menuBuilder, menuObj, caller, function()
        -- Optional refresh callback
        print("ElvUI settings changed")
    end)
end
```

### Titan Panel Integration Example

```lua
local addonName, addon = ...
local lib = KROWI_LIBMAN:GetLibrary('Krowi_Brokers')

-- Titan Panel integration is automatically set up when you call InitBroker()
-- The CreateTitanOptionsMenu function is added to addon.Menu automatically

-- In your menu creation function
function addon.Menu.Create(menuBuilder, menuObj, caller)
    -- Your regular menu items
    menuBuilder:CreateTitle(menuObj, "My Addon Options")
    -- ... more menu items ...
    
    -- Call the Titan Panel options menu creator (automatically available after InitBroker)
    -- This will add Titan Panel options only if Titan Panel is detected and caller is a Titan Panel frame
    addon.Menu.CreateTitanOptionsMenu(menuBuilder, menuObj, caller, function()
        -- Optional refresh callback
        print("Titan Panel settings changed")
    end)
end
```

## API Reference

### Krowi_Brokers

#### Getting the Broker Library Instance
```lua
local lib = KROWI_LIBMAN:GetLibrary('Krowi_Brokers')
```

#### Broker Functions

| Function | Parameters | Description |
|----------|------------|-------------|
| `InitBroker(addonName, addon, onEnter, onLeave, onClick, onEvent)` | See below | Initializes a LibDataBroker data object with callbacks and event handling |
| `GetHelperFrame()` | - | Returns the shared helper frame, creating it if it doesn't exist |
| `RegisterEvents(...)` | `...` (strings) | Registers one or more WoW events to the helper frame |
| `RegisterOnEvent(handler)` | `handler` (function) | Adds an event handler function that will be called for all registered events |
| `RegisterOnUpdate(handler)` | `handler` (function) | Adds an OnUpdate handler function that will be called every frame |
| `RegisterCreateElvUIOptionsMenu(addonName, addon)` | `addonName` (string), `addon` (table) | Registers ElvUI options menu creation (called automatically by `InitBroker`) |
| `RegisterCreateTitanOptionsMenu(addonName, addon)` | `addonName` (string), `addon` (table) | Registers Titan Panel options menu creation (called automatically by `InitBroker`) |

#### InitBroker() Parameters

**Note**: As of v2.0, `InitBroker()` requires explicit `addonName` and `addon` parameters. The addon object must have:
- `addon.Metadata.Title` - The addon title
- `addon.Metadata.Version` - The addon version
- `addon.Metadata.Icon` - Path to the icon texture file
- `addon:GetDisplayText()` - Method that returns the current display text (uses colon syntax)

It also automatically initializes `addon.Menu` and `addon.Tooltip` if they exist with an `Init()` method.

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `addonName` | string | Yes | The name of your addon |
| `addon` | table | Yes | The addon namespace table |
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

### ElvUI Integration (v1.0.4+)

ElvUI integration is now built into the main `Krowi_Brokers-1.0` library and automatically registered when calling `InitBroker()` if your addon has a Menu system.

When `InitBroker()` is called, it automatically adds a `CreateElvUIOptionsMenu` function to `addon.Menu`. You can call this function from within your menu creation code.

#### addon.Menu.CreateElvUIOptionsMenu()

This function is automatically added to your addon's Menu table by `InitBroker()`.

**Function Signature:**
```lua
addon.Menu.CreateElvUIOptionsMenu(menuBuilder, menuObj, caller, onRefresh)
```

**Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `menuBuilder` | MenuBuilder | Yes | The MenuBuilder instance |
| `menuObj` | menu | Yes | The menu object to add ElvUI options to |
| `caller` | frame | Yes | The calling frame (used to detect if ElvUI is the caller) |
| `onRefresh` | function | No | Optional callback function called when settings change |

**Note**: This method only adds menu items if ElvUI is loaded and the caller is an ElvUI frame.

### Titan Panel Integration (v1.0.4+)

Titan Panel integration is now built into the main `Krowi_Brokers-1.0` library and automatically registered when calling `InitBroker()` if your addon has a Menu system.

When `InitBroker()` is called, it automatically adds a `CreateTitanOptionsMenu` function to `addon.Menu`. You can call this function from within your menu creation code.

#### addon.Menu.CreateTitanOptionsMenu()

This function is automatically added to your addon's Menu table by `InitBroker()`.

**Function Signature:**
```lua
addon.Menu.CreateTitanOptionsMenu(menuBuilder, menuObj, caller, onRefresh)
```

**Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `menuBuilder` | MenuBuilder | Yes | The MenuBuilder instance |
| `menuObj` | menu | Yes | The menu object to add Titan Panel options to |
| `caller` | frame | Yes | The calling frame (used to detect if Titan Panel is the caller) |
| `onRefresh` | function | No | Optional callback function called when settings change |

**Note**: This method only adds menu items if Titan Panel is loaded and the caller is a Titan Panel frame.

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
- KROWI_LIBMAN (Krowi's Library Manager)
- LibDataBroker-1.1
- AceLocale-3.0 (for ElvUI/Titan Panel integration localization)
- Krowi_MenuBuilder (optional, for ElvUI/Titan Panel menu integration)