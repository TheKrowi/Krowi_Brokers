# CLAUDE.md

Krowi's Brokers (`Krowi_Brokers_2`) is a World of Warcraft library in Lua 5.1 that turns an addon into a LibDataBroker data source: `InitBroker` builds the data object, one shared helper frame dispatches events and OnUpdate to every registered handler, and two submodules add ElvUI and Titan Panel options to the addon's menu. Addons embed it as the `Libs/Krowi_Brokers` submodule; it is also published on its own. The workspace-wide rules (tooling traps, the game loop, taint, git, release safety, how Krowi wants choices presented) load from the workspace `CLAUDE.md` two folders up, a copy of `Krowi_ClaudeKit/WowAddons.md`; this file adds only what is specific to this repo.

There is no build, lint or test step: the library is tested in game through an addon that embeds it. The `krowi` plugin (enabled in `.claude/settings.json`) syntax-checks every edited `.lua` with Lua 5.1 and guards the known tooling traps. The repo is public, but `.claude/settings.json` points at the private kit by absolute path, so the plugin loads only on Krowi's machine; that is intended.

## Clients and loading

- One TOC, `Krowi_Brokers.toc`, `## Interface: 120000, 110207, 50503, 20505, 11508` (stale, see Known debt). No saved variables, no dependencies. Embedded, the consumer's TOC decides the clients.
- Load order: `Krowi_Brokers.xml` loads `Krowi_Brokers.lua`, `Integrations\ElvUI.lua`, `Integrations\Titan.lua`, then `Localization\Files.xml` (enUS, the ten other locales, `Shared.lua`). A new `.lua` must be listed in one of those XML files or it never loads.
- The consumer must load before it: Krowi_Util (`KROWI_LIBMAN`, and the `LocalizationHelper` that `NewLibrary` calls for `InitLocalization`, Krowi_Util `LibMan.lua:37-39`) and LibDataBroker-1.1, looked up when `InitBroker` runs (`Krowi_Brokers.lua:25`). AceLocale-3.0 comes with Krowi_Util; the menu builder is Krowi_Menu's, passed in by the consumer's menu code.

## Versioning

The library registers through Krowi_Util's LibMan, whose `NewLibrary` ends in `LibStub:NewLibrary(name, minor)` (Krowi_Util `LibMan.lua:22`). Each file has its own minor:

| File | LibStub name | Minor in |
|---|---|---|
| `Krowi_Brokers.lua` | `Krowi_Brokers_2` | `Krowi_Brokers.lua:8` (`NewLibrary`) |
| `Integrations/ElvUI.lua` | `Krowi_Brokers_2_ElvUI` | `Integrations/ElvUI.lua:8` (`NewSubmodule`) |
| `Integrations/Titan.lua` | `Krowi_Brokers_2_Titan` | `Integrations/Titan.lua:8` (`NewSubmodule`) |

- A file upgrades only when its own minor is higher. A newer copy with a higher main minor still skips `ElvUI.lua` while the ElvUI minor is unchanged (`NewSubmodule` returns nothing, `LibMan.lua:71-72`). A higher ElvUI minor alone does upgrade `ElvUI.lua`: the main file's `NewLibrary` still makes the loaded `Krowi_Brokers_2` current (`LibMan.lua:23-24`), and `NewSubmodule` takes the current library as parent (`LibMan.lua:67-68`).
- `ElvUI.lua` and `Titan.lua` define `RegisterCreateElvUIOptionsMenu` and `RegisterCreateTitanOptionsMenu` on the main library table, and `InitBroker` calls them (`Krowi_Brokers.lua:17-18`): a change to that contract bumps both minors.
- The `Localization/` files register nothing and no minor reloads them. They attach to `KROWI_LIBMAN:GetCurrentLibrary(true)`, and only the first copy that loads registers strings (Known debt): a new or changed string reaches only players whose first-loaded copy has it.
- All three minors are `0` and have not changed since 2.0 moved to LibMan. The major `Krowi_Brokers_2` changes only for a breaking change; Krowi_Util hard-codes it for `SetBroker` (`LibMan.lua:111`), so a new major also needs a Krowi_Util release.

## Consumers

Krowi_Brokers_Currency, Krowi_Brokers_System and Krowi_Brokers_Time embed it as `Libs/Krowi_Brokers` (all at 2.0). A change reaches players only after a release here, then a submodule bump and a release in each of them.

- Each gets the library as `addon.Broker` (`SetBroker = true` in `KROWI_LIBMAN:NewAddon` in its `Libs/Libs.lua`) and calls `addon.Broker:InitBroker(addonName, addon, OnEnter, OnLeave, OnClick, OnEvent)` and `addon.Broker:RegisterEvents(...)` from its main file's main chunk.
- Each `Menu.lua` calls the `menu.CreateElvUIOptionsMenu` and `menu.CreateTitanOptionsMenu` that `InitBroker` adds, and defines `menu.RefreshBroker`, their default refresh.
- `Krowi_Brokers_Template` is a 1.x copy (`LibStub("Krowi_Brokers-1.0")`), not a consumer.

## Architecture

- `InitBroker` (`Krowi_Brokers.lua:14-47`) calls `addon.Menu.Init()` and registers both integration menus when `addon.Menu` exists, calls `addon.Tooltip.Init()` when `addon.Tooltip` exists, builds the LDB data object from `addon.Metadata` (Title, Version, Icon), adds `Update()`, which sets `text` from `addon:GetDisplayText()`, stores it as `addon.LDB`, and registers `onEvent`.
- One helper frame serves every consumer, the global `Krowi_Brokers_HelperFrame` (`Krowi_Brokers.lua:49-56`). Every handler from `InitBroker` or `RegisterOnEvent` gets every event any consumer registered, as `(event, ...)` without `self`, so handlers filter by event name. `RegisterOnUpdate` handlers get `(elapsed)`.
- `Integrations/ElvUI.lua` adds its submenu only when ElvUI is loaded and the menu's caller frame sits under a frame whose name contains `ElvUI`. It loads `ElvUI_Options` for ElvUI's own strings and toggles `icon`, `label` and `text` in ElvUI's `global.datatexts.settings['LDB_<addon>']`.
- `Integrations/Titan.lua` adds its submenu when `TITAN_ID` exists and the caller sits under a frame whose name contains `TitanPanel` or `TITAN_PANEL_DISPLAY_PREFIX`. It uses Titan's AceLocale strings, toggles `ShowIcon`, `ShowLabelText`, `ShowRegularText` and `DisplayOnRightSide` through Titan's functions, and adds a Hide button.

## Taint-sensitive areas

The library touches no Blizzard frame and hooks nothing. Run the `krowi:taint-reviewer` agent after changing:

- the helper frame and its dispatch, which runs every consumer's handlers;
- `C_AddOns.LoadAddOn('ElvUI_Options')` (`Integrations/ElvUI.lua:45`), which runs while a menu is being built;
- the calls into ElvUI's DataTexts module and Titan's globals (`TitanToggleVar`, `TitanPanel_RemoveButton`, `TitanUtils_AddButtonOnBar`, `TitanPanelButton_UpdateButton`, `TitanPanelRightClickMenu_Hide`) from menu clicks. Titan marks the internals these use as subject to change.

The three broker addons fill Blizzard's shared `GameTooltip` from addon code, which the baseline review (2026-10-17) found plausible but unconfirmed as a trigger of the 12.x LayoutFrame "secret number value" errors (WoWUIBugs #811). A private tooltip provided here would remove that for all three at once.

## Localization

`Localization/enUS.lua` and the ten other locale files are the CurseForge export (the project's localization page is linked in `Localization/Shared.lua:6`): code above the `AUTOGENTOKEN` marker (line 14), strings below the `Exported at` line (line 16), at the same place in every file. The library has two strings, `ElvUI Options` and `Titan Panel Options`, translated in every locale; the checkbox labels come from ElvUI's and Titan's own locales. `Shared.lua` sets `lib.L` last. A missing key is not silent: AceLocale reports it to the error handler (BugSack) and shows the key.

## Code style

Match the file you are editing; this style is not Krowi_AchievementFilter's:

- Tabs, except the space-indented lines in `Krowi_Brokers.lua` (the options table and parts of `InitBroker`) and in the toggle callback of `Integrations/Titan.lua`. XML attributes are single-quoted; `Localization/Files.xml` indents with spaces.
- No semicolons. Single quotes in code; double quotes only in the CurseForge export lines.
- Lua files open with the `--[[ Copyright (c) 2026 Krowi ... ]]` block, a blank line, `---@diagnostic disable: undefined-global`, a blank line, then the `KROWI_LIBMAN` call and its early `return`. The TOC and XML files carry the same notice as `#` and `<!-- -->` comments.
- Functions PascalCase, locals camelCase.
- CRLF on disk (LF in git, `core.autocrlf=true`), no BOM, no final newline. There is no `.editorconfig` and no `.vscode/`.
- Do not restyle lines you are not otherwise changing.

## Testing in game

Test through a consumer. The kit's `Deploy.ps1` run here installs a standalone `Interface\AddOns\Krowi_Brokers`: it errors on `KROWI_LIBMAN` unless an addon that embeds Krowi_Util loads before it, and otherwise wins over every consumer's copy with the same minor. Do not leave one installed.

- Point the consumer's `Libs/Krowi_Brokers` at the change (in a consumer worktree, check this branch out in the submodule) and deploy the consumer. Or deploy this checkout into an installed consumer with `Deploy.ps1 -Destination "<client>\Interface\AddOns\Krowi_Brokers_Currency\Libs\Krowi_Brokers"`; the consumer's next deploy overwrites it.
- With equal minors the copy in the first addon to load wins, and Krowi_Brokers_Currency loads before Krowi_Brokers_System and Krowi_Brokers_Time. Put the change in Krowi_Brokers_Currency, disable the other two, or bump the minor.
- Titan Panel is installed on Retail, ElvUI on Classic and Era. Their submenus appear only when a broker's menu is opened from their bars.

## Git and release

- `main` is the only branch and the integration branch: branch from it and open PRs against it. Releases are `Release x.y` commits and tags on `main` (tags 1.0.1 to 2.0).
- Release only with the plugin's `krowi:release`, from `Krowi_Libraries\Krowi_Brokers` (the addon manager lists it in `LIBRARY_NAMES`). Every upload is a full release: `--stability stable`.
- After a release, bump `Libs/Krowi_Brokers` in each consumer.
- The changelog entries up to 2.0 are written for addon developers who embed the library: they name the API, files and behaviour that changed.

## Known debt (verified 2026-10-17)

- Right-clicking a broker on an ElvUI datatext errors when `ElvUI_Options` is disabled: `C_AddOns.LoadAddOn('ElvUI_Options')` fails, `GetElvUI().Config` is nil and `unpack(nil)` throws (`Integrations/ElvUI.lua:45-46`). It also loads `ElvUI_Options` in combat, which ElvUI's own `ToggleOptions` refuses. Check the load result and `Config`, and skip the submenu in combat.
- **Handlers do not survive an upgrade.** The handler lists are file locals (`Krowi_Brokers.lua:58`, `:81`), but the helper frame lives on `lib` and gets its scripts only once (`:76-78`, `:91-93`). Every consumer calls `InitBroker` while loading, so after the first bump of `Krowi_Brokers_2`, a newer copy that loads after an older one puts its consumer's handlers in a list nothing reads, and that broker never gets an event. Fix it with that bump: keep the lists on `lib`, and chain the old copy's script, whose list cannot be reached.
- **A newer copy's strings are never registered when an older copy loaded first.** The upgrade reuses `lib`, and `InitLocalization` returns early because `lib.Localization` exists (Krowi_Util `LocalizationHelper.lua:37`). The old `localeIsLoaded` stays, so `NewDefaultLocale` and `NewLocale` return nothing (`:15`, `:24`) and the locale files stop at `if not L then return end`. Passing `addMore` (`NewDefaultLocale(true)`, `NewLocale('<code>', true)`) lets new keys in, but AceLocale never overwrites an existing enUS value (`AceLocale-3.0.lua:62-69`). Every LibMan library with `InitLocalization` has this.
- The dispatchers call handlers unprotected (`Krowi_Brokers.lua:59-63`, `:82-86`): one consumer's error skips the remaining consumers' handlers for that event or frame.
- `Localization/Shared.lua:11` reads `if not lib and not lib.L then return end`: it indexes nil when `lib` is nil and never returns otherwise. Harmless today, because `Krowi_Brokers.lua:8` always sets the current library (`LibMan.lua:24`, `:31`).
- The TOC's `## Interface` is stale: the live clients are 120105, 50504, 20506 and 11509, and 11.2.7 no longer exists. It sets the standalone upload's game versions and the README badges.
- `_Packaging/Description.md`, and so `README.md`, gets the library with `KROWI_LIBMAN:GetLibrary('Krowi_Brokers')`, a name that does not exist (it is `Krowi_Brokers_2`; consumers use `SetBroker`), still calls it `Krowi_Brokers-1.0` in the integration sections, and lists `Krowi_MenuBuilder` instead of Krowi_Menu.