### Added (1.0.3)
- `ExtendMenuBuilder()` method for both ElvUI and Titan Panel integration libraries
- ElvUI integration module (`Krowi_Brokers_ElvUIIntegration-1.0`) with menu options
- Titan Panel integration module (`Krowi_Brokers_TitanIntegration-1.0`) with menu options
- Localization system with AceLocale-3.0 support
- `CreateElvUIMenu()` helper function for ElvUI-specific menu options
- `CreateTitanMenu()` helper function for Titan Panel-specific menu options
- Shared `KROWI_BROKERS_LIBRARY_MINOR` global for version consistency across modules

### Changed (1.0.3)
- Event handlers no longer receive `self` parameter - signatures changed to `(event, ...)` instead of `(self, event, ...)`
- Update handlers no longer receive `self` parameter - signatures changed to `(elapsed)` instead of `(self, elapsed)`
- `InitBroker()` now uses global `addonName` and `addon` variables from the addon namespace