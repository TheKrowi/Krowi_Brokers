# Changelog
All notable changes to this project will be documented in this file.

## 1.0.3 - 2026-01-05
### Added
- `ExtendMenuBuilder()` method for both ElvUI and Titan Panel integration libraries
- ElvUI integration module (`Krowi_Brokers_ElvUIIntegration-1.0`) with menu options
- Titan Panel integration module (`Krowi_Brokers_TitanIntegration-1.0`) with menu options
- Localization system with AceLocale-3.0 support
- `CreateElvUIMenu()` helper function for ElvUI-specific menu options
- `CreateTitanMenu()` helper function for Titan Panel-specific menu options
- Shared `KROWI_BROKERS_LIBRARY_MINOR` global for version consistency across modules

### Changed
- Event handlers no longer receive `self` parameter - signatures changed to `(event, ...)` instead of `(self, event, ...)`
- Update handlers no longer receive `self` parameter - signatures changed to `(elapsed)` instead of `(self, elapsed)`
- `InitBroker()` now uses global `addonName` and `addon` variables from the addon namespace

## 1.0.2 - 2026-01-03
### Added
- `RegisterOnUpdate()` function for handling OnUpdate events
- `GetHelperFrame()` function for accessing the shared helper frame

### Changed
- Renamed internal event frame to helper frame for better clarity
- Event frame is now created on-demand when first handler is registered
- Improved initialization order for event and update handlers

## 1.0.1 - 2026-01-03
### Added
- Initial release of Krowi_Brokers library
- `InitBroker()` function for simplified LibDataBroker data object initialization
- Integrated event handling system with shared event frame
- Support for multiple event handlers on the same event frame
- `RegisterEvents()` and `RegisterOnEvent()` for event management
- Custom callback support (OnEnter, OnLeave, OnClick, OnEvent)
- Automatic text updates via getDisplayText callback
- Optional menu and tooltip system integration
- LibStub-based library structure