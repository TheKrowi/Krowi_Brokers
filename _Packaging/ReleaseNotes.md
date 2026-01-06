### Changed (1.0.4)
- Moved ElvUI and Titan Panel integration files to `Integrations/` folder
- Renamed integration files from `Krowi_Brokers_ElvUIIntegration.lua` and `Krowi_Brokers_TitanIntegration.lua` to `ElvUI.lua` and `Titan.lua`
- Refactored integration modules to use local functions and register menu creation methods on the main library
- Updated `InitBroker()` to automatically register ElvUI and Titan Panel options menu creation
- Changed integration API: `ExtendMenuBuilder()` replaced with module-specific extension methods (`ExtendMenuBuilderWithElvUIOptions()` and `ExtendMenuBuilderWithTitanOptions()`)
- Integration menu creation now requires passing `addonName` parameter to support multiple addons using the library