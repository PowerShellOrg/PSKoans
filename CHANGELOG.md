# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

> Releases `0.65.1`-`0.66.2` predate this project's adoption of the
> Keep a Changelog patch-release convention (only `Fixed`/`Security` entries)
> and genuinely shipped `Added`/`Changed` content in what were nominally
> patch versions; those historical entries are left as-is rather than
> recategorized to avoid misrepresenting what actually shipped. CI changelog
> validation is scoped to recent releases via `.changelog-reader.yml` (#499).

## [Unreleased]

### Changed

- Build system rewritten on top of `psake` + `PowerShellBuild`, mirroring
  PSDepend's convention (`requirements.psd1`, `build.ps1`, `psakeFile.ps1`
  at the repo root with `Init`/`Clean`/`StageFiles`/`Build`/`Analyze`/
  `Pester`/`Test`/`BuildHelp`/`Publish` tasks). Tests now build and import
  the staged module from `Output\` instead of requiring `PSKoans` to
  already be imported (#485).

### Fixed

- Restored comment-based help for all 13 exported public functions
  (previously only in generated `docs/*.md`), fixing ~90
  `ModuleHelp.Tests.ps1` failures (#493).
- ~13 test files had unscoped `Mock`s that did not intercept calls made
  from inside the module, so real cmdlets ran during tests — including
  `Start-Process` launching a real editor; mocks are now scoped with
  `-ModuleName 'PSKoans'`.
- `Reset-PSKoan.Tests.ps1` / `Update-PSKoanFile.Tests.ps1` called
  `(Get-PSKoan -Scope Module).Path` directly from test scope, bypassing
  module-scoped mocks, which let the real cmdlet run and `Set-Content`
  overwrite every staged koan file with fixture content.
- `build.ps1` now resolves `requirements.psd1` / `psakeFile.ps1` against
  `$PSScriptRoot` instead of the caller's working directory.
- Test files that bootstrap a nested `build.ps1 -Task Build` now run it
  in a child `pwsh` process instead of in-process, since `build.ps1` ends
  with `exit` and was terminating the hosting Pester process.
- `psakeFile.ps1` resolves `Test.RootDir` from `$PSScriptRoot` instead of
  `$env:BHProjectPath`, which required `Set-BuildEnvironment` to already
  have run.

## [0.67.1] - 2020-07-05

### Fixed

- `Get-Karma` / `Show-Karma` fixed for `-Module` / `-IncludeModule`
  support: missing module folders no longer error, required modules are
  explicitly imported before Pester runs, `-Module` and `-Contemplate`
  parameter sets no longer conflict, and `Update-PSKoan` now copies
  module files when module parameters are specified (#399).
- `Invoke-Koan` fixed for the case where PSKoans is not on
  `$env:PSModulePath`: the module path is now copied into the new
  runspace, and runspace errors now propagate back to the calling
  session (#399).
- `Show-Karma -Meditate` now passes `-NoNewWindow` to `Start-Process`, so
  the configured editor no longer opens in a new console window (#397,
  #395).
- Various koan typo and clarity fixes (#387, #396); branch references
  updated from `master` to `main` (`primary` in the `dbatools` koans, to
  avoid confusion with SQL Server's own `master` database).

## [0.67.0] - 2020-05-31

### Added

- `dbatools` koan module: `AboutDbaDatabase` and `AboutBackupDatabase`
  koans covering `Get-DbaDatabase`, `New-DbaDatabase`,
  `Backup-DbaDatabase`, and `Invoke-DbaQuery` (including SQL-injection
  safety), with accompanying XML-based mocks (#140).

### Changed

- `Format.ps1xml` generation moved to `EZOut`, adding a `-Detailed`
  result view and formatting for `PSKoans.CompleteResult` (#382).
- `AboutCmdletVerbs` refactored (#378).
- Pester dependency pinned in `requirements.psd1` ahead of Pester v5
  compatibility work (#392).

### Fixed

- `AboutRegularExpressions` scoping and validation issues fixed (#388).
- `AboutGetMember` tested the wrong target (#386); `AboutPSObjects` was
  missing a sort, which could fail correct answers given in the wrong
  order (#381); `AboutStringBuilder` referenced the wrong variable
  (#380); `AboutArrays` koans were missing an `$array` variable (#385).
- Various typo, parameter, and unused-code fixes across koan topics
  (#390).

## [0.66.2] - 2020-03-12

### Added

- `Show-Karma -Contemplate` can now be combined with `-Topic` to open
  the current topic's koan file directly (#376, #377).

### Changed

- CI deployment pipeline converted to a dedicated deployment job that
  also publishes artifacts to the GitHub Release, alongside the
  PowerShell Gallery.

### Fixed

- `AboutEnumeration` fixed a missing/extra brace, and enum parsing is
  now delayed (parsed from a string just before execution) to avoid
  breaking the parser on earlier PowerShell versions (#372, #373).
- `[type]::TryParse` usage adjusted to be version-appropriate across
  supported PowerShell/.NET versions (#374).

## [0.66.1] - 2020-03-05

### Added

- `Move-PSKoanLibrary` function to relocate the user's koan library
  folder (#364).

### Changed

- Introduction koans (`AboutAssertions`, `AboutBinary`, `AboutBooleans`,
  `AboutArrays`, `AboutStrings`, `AboutNumbers`) rewritten with clearer
  explanatory text (#370).
- CI pipeline refactored: PSake dropped in favor of direct pipeline
  steps, the module build moved to its own job, and tests now run
  against the built module rather than the source tree (#362, #363).

### Fixed

- Koan-runner scriptblock invocation switched from `Invoke()` to
  `InvokeReturnAsIs()`, fixing `$null` results that were expected to be
  an (empty) collection (#365).
- `AboutArrays` now properly instantiates strings/numbers before use
  (#358, #360).

## [0.66.0] - 2020-02-07

### Added

- `Show-Karma -Meditate` now opens the current koan file directly in the
  configured editor; `-Library` opens the koan library folder. `Get-Karma`
  results now include line-number info for the active koan (#346).
- Simple in-session caching of current-topic completion data: `Get-Karma`
  populates a module-scope cache that `Show-Karma -Contemplate` consumes
  and clears, avoiding a duplicate `Get-Karma` call (#355).
- `AboutXml` koan topic covering `Select-Xml`, `XmlWriter`, document
  modification, and namespace handling (#301).
- `AboutFiltering` koan topic added to the `ActiveDirectory` module
  koans (#343).

### Changed

- Uninstall/configuration docs updated (#348, resolves #336); README
  updated with logo images (#354, #345).

### Fixed

- Bitwise-operation koans fixed (#350).
- Fixes across the `AboutModules`, `AboutTeeObject`, `AboutMeasureObject`,
  `AboutSelectObject`, `AboutAssignmentAndArithmetic`, `AboutDiscovery`,
  and `AboutArrays` koan topics (#347).
- Input array order corrected to match the expected koan output (#338).

## [0.65.4] - 2019-12-16

### Fixed

- `AboutSortingCharacters` kata used a copy-pasted function name reference from another kata; corrected to reference the right function (a0bc4b0).
- `AboutSortingCharacters` kata was missing `using` statements (612106e).

## [0.65.3] - 2019-11-24

### Added

- New meditation koans (#320).

### Changed

- Koan verification script's `CheckRestrictedLanguage` was too stringent, blocking basic array indexing and member access; switched to detecting command names via the AST instead, which also allows user-defined sub-functions scoped to the test function (#328).

### Fixed

- Typo in `AboutBinaryKoans` (#327).
- `LicenseURI` in the module manifest pointed to a 404 (#324).
- An assertion in the koans was already `$true` before the user made any changes, so it showed false progress; converted to be consistent with the surrounding assertions (#323).
- Typo in a koan comment (#321).
- Incorrect number in a number-check koan; it now matches the preceding comment instead of evaluating the wrong question (#322).

## [0.65.2] - 2019-10-30

### Added

- External help is now published alongside the module during CI builds (#319).

### Changed

- Reworded and cleaned up `AboutCmdletVerbs` comments and formatting (#318).
- README restructured: header added to command table, table formatting tidied, headings reorganized for better flow, and a link to the command reference docs added.
- Changelog generation now preserves commit order (#314).

### Fixed

- CI tooling for publishing to the PowerShell Gallery (22eb24a).
- `AboutAssertions` cast `[Blank]` to `[bool]`, which always evaluates `$true`, so the koan passed without user input; `Should -BeTrue` is now used instead of the cast (#316).

## [0.65.1] - 2019-10-28

### Added

- `Reset-PSKoan` now adds a koan topic to the user's folder if it's missing instead of requiring `Update-PSKoan` first, with a `ShouldProcess` prompt for the addition (#312).
- Commit log is now published as a Markdown table during CI (#309).

### Fixed

- `Reset-PSKoan` start-position offset bug (#310).
- `Show-Karma -Meditate` failed to launch the editor when `KoanLocation` contained spaces; the path is now properly quoted (#308).
- Re-importing the module a second time failed because the `[Koan]` attribute type was already registered; it is now skipped if already present (#307).
- `Update-PSKoan #303` parameter handling (#304).

### Changed

- Spacing around progress bars tightened (#305).
- Removed an outdated compatibility note from the README now that the renamed command is live.

## [0.65.0] - 2019-10-26

### Added

- New koan topics: `AboutClasses` (#296), `AboutEnumerations` (#263), Regular Expressions (#281), bitwise operator and binary koans (#245), and CSV koans (#240).
- Ported the PowerShell Intro Training content into PSKoans as a full `Introduction`/`Foundations` koan set, including `AboutBinary`, `AboutBooleans`, `AboutCmdletVerbs`, `AboutGetMember`, `AboutNumbers`, and `AboutOOP` (#241).
- First katas: a restriction on the stock-challenge kata and a new sorting-characters kata (#237).
- `Update-PSKoan` and `Reset-PSKoan` commands to sync koan files against the installed module version or reset them to their defaults (#223).
- `Get-Karma` command; `Measure-Karma` renamed to `Show-Karma` with an alias retained for backwards compatibility (#238).
- Persistent koan settings via new `Get-PSKoanSetting`/`Set-PSKoanSetting` commands, including an `Editor` setting honored by `Show-Karma` (#248).
- Module topic support, with the `[Koan]` attribute reimplemented in C# (#251).
- `-PipelineVariable` koan, plus expansion of `AboutLoopsAndPipelines` (#291).
- Hidden parameters added to `Get-Blank` so it can stand in for any cmdlet in the middle of a pipeline (#220).
- Specific error thrown by `Show-Advice` on invalid input (#287).
- Examples added to `AboutArrays` (#257), `AboutSelectObject` (#247), `AboutStrings` (#299, OFS section #204), and `AboutStringBuilder` refactor (#225).
- Meditation prompts and additional bits of wisdom (#294, #293, #300).
- `-Detailed` parameter for `Measure-Karma`/`Show-Karma` to surface the latest file's test summary (#166).
- New alias for `Get-Blank` (#158).
- Extension recommendations added to the workspace settings (#208).
- Single-LF-at-EOF enforced via a new koan validation test (#232).
- Code coverage reporting, multi-platform (Windows/macOS) build and test jobs, and automatic external help generation via PlatyPS added to CI (#259, #236, #167).

### Changed

- Large style pass across `AboutAssertions`, `AboutNumbers`, `AboutStrings`, `AboutCmdletVerbs`, `AboutGetMember`, `AboutVariables`, `AboutAssignmentAndArithmetic`, `AboutArrays`, `AboutComparison`, `AboutStringOperators`, `AboutConditionals`, `AboutFunctionsAndScriptBlocks`, and `AboutTypeOperators` (#295).
- Koan ordering reworked: `KoanIndex` reformatted into separate tables per module, introduction segment reordered, and several Foundations koans repositioned (#277).
- Dummy type placeholder changed from `[__]` to the longer-form `[____]` for clarity (#244).
- `Update-PSKoan` now prompts for `ShouldProcess` once per run instead of once per file, so "Yes to All" behaves correctly (#292).
- All references to `$env:PATH` updated to uppercase for Unix compatibility (#239).
- `Show-Karma`/`Get-Karma` logic refactored, including fixed completion handling for already-completed topics (#250).
- CONTRIBUTING.md expanded with an Advice section, blank-format table, and comment-language notes (#279, #271).

### Fixed

- Numerous koan content bugs and clarifications across `AboutHashtables`, `AboutStringOperators`, `AboutArrays`, `AboutLists`, `AboutModules`, `AboutGroupObject`, `AboutTeeObject`, `AboutLoopsAndPipelines`, `AboutDiscovery`, `AboutRedirection`, `AboutErrorHandling`, and `AboutComparison` (#233).
- `AboutPSObjects` static array ordering and property-type comments fixed (#228); `AboutPSProviders` blank formats and assertions corrected (#235, #189).
- `AboutSplatting` regex pattern fixed and a stale `$env:PSKoan_Location` reference removed (#200, #165); `AboutCustomObjects` typos fixed (#201).
- `AboutErrorHandling`'s `ErrorRecord` describe block split in two (#199); `Out-String`/`Out-File` koan parameter fixed (#198); `Select-Object -Unique` koan no longer gives a misleading partial answer (#221).
- `AboutComparison`/`AboutStrings` had auto-passing assertions because `__` evaluated truthy; replaced with `$____` (#214). `Get-Random` example pipeline made deterministic (#219); nonexistent `Measure-Object -Count` parameter removed (#229).
- Divide-by-zero in karma calculation fixed on some systems (#192); `Show-MeditationPrompt`/`Measure-Karma` topic-progress division-by-zero fixed (#164).
- `Show-Advice` required the full basename for tab completion, and used the wrong filenames for some advice snippets (#276, #285).
- `Get-PSKoanLocation`/opening the koans folder no longer errors when the PSKoan directory doesn't yet exist (#274).
- VS Code opened an empty file under certain conditions (#289).
- `Get-Karma` errors are now properly rethrown from `Show-Karma` instead of being swallowed (#302).

### Removed

- `AboutDotNet` and stand-alone `AboutInts`/`AboutExamples` koans removed as part of the Intro Training port, superseded by `AboutOOP`/`AboutNumbers` and advice-file content (#241).

## [0.50.1] - 2019-04-28

### Changed

- `Show-MeditationPrompt` now uses better-supported Unicode characters for the progress bar and was refactored to reduce pipeline usage (#160)
- Improved casting and comparison behavior for `[Blank]` (#157)
- Refreshed the README with a new logo (including an SVG version), corrected table formatting, and a full copy pass

## [0.50.0] - 2019-04-21

### Added

- Error handling koans covering non-terminating errors and `trap{}` (#153)
- Comment-based help and external Markdown documentation for module functions (#155)
- ASCII/Char explanation koan content (#152)
- Redirection koans and `Out-*` cmdlet koans (#148)
- `-Topic` parameter for `Initialize-KoanDirectory`, and support for `-Reset -Topic` in `Measure-Karma` to reset individual koan files (#144)
- Multi-assignment koans (#143)
- `-ClearScreen` switch for `Measure-Karma` to make screen clearing optional (#142)
- PSObject koans (#120)
- Additional progress bar in `Show-MeditationPrompt` showing the farthest topic reached (#118)
- Topic selection and listing support for `Measure-Karma`, `Get-PSKoanLocation`/`Set-PSKoanLocation` cmdlets, and `New-PSKoanErrorRecord` for constructing error records (#107)
- Support for VS Code Insiders in `Measure-Karma -Contemplate` (#104)
- Platform compatibility tags to the module manifest

### Changed

- Merged the Constructs and Patterns koan topics and moved splatting into its own folder (#149)
- Clarified the difference between `Write-Output` and `return` (#136)
- Refactored `Show-MeditationPrompt` to pull strings from a data file and added color to koan quotes (#126)
- Dummy types (including `[__]`) are now imported globally so `Should -BeOfType` can see them (#122)
- Refactored `Invoke-Koan` to accept a single hashtable of parameters instead of individual arguments (#121)
- Koan test failure messages now list expected values more clearly (#115)
- Removed unnecessary `Start-Sleep` waiting periods from meditation prompts and `Invoke-Koan` (#114)

### Fixed

- Various outstanding koan content issues and README formatting (#108, #116, #124, #125, #129, #143)
- `AboutStrings` koan now works cross-platform (#137, #138)
- Added the `[Blank]` class, fixing incorrect casting/comparison (#131, #135)
- Grammar in `AboutArrays` (#133)
- `Measure-Karma` now correctly opens paths containing spaces, and VS Code detection is no longer case-sensitive on Linux (#132)
- Sporadic class import issues (#126)
- Addition array example in koans (#111, #112)

## [0.42.2] - 2018-12-10

### Changed

- Reduced the meditation prompt sleep timer
- Shortened inherited type names for clarity (#105)

### Fixed

- Koan type loading now uses the short inherited type name, resolving an issue where types failed to load correctly (#105)
- `Invoke-Koan` now uses runspaces so `using module` can be applied properly (#105)
- Koan file discovery is more reliable (#105)

## [0.42.1] - 2018-12-10

### Fixed

- Deployment and publish pipeline errors, including a case-sensitivity issue in file lookups

## [0.42.0] - 2018-12-09

### Added

- StringBuilder koans (#53)
- `AboutCustomObjects` koans covering object creation methods and `ScriptProperty` (#74)
- Ordered hashtable koans (#80)
- `Should -Fail` operator and `Assert-TestFailed` command for deliberately failing koans, plus a default-fail case in `AboutConditionals` (#82, #83)
- `Clear-Path` alias for `Measure-Karma` (#56)
- Advice/tip system via `Register-Advice` and `Get-Advice` (#54)
- Published to the PowerShell Gallery via a new Azure Pipelines-based publish process (#97)

### Changed

- Migrated CI from AppVeyor to Azure Pipelines (#89, #97)
- Replaced `#Requires -Modules` with `using module` statements throughout (#76)
- Renamed `ExpectedType` to `ExpectedMessage` and replaced `ExceptionType` with `ErrorId` in the type/error koans, which now invoke a conversion scriptblock (#64, #67)
- Rewrote the README's Getting Started section for clarity (#58)
- Refactored internal advice functions (`Get-Advice`/`Write-ConsoleLine`) into a Private functions folder with clearer naming (#55)
- Refactored `AboutArrays`, `AboutVariables`, `AboutConditionals`, and `AboutFunctionsAndScriptBlocks` koans for clarity (#51)
- Updated the switch koans' wildcard example (#73)
- Clarified using hashtable keys as property names (#94)

### Fixed

- File encoding issues (#98)
- Hashtable koans no longer imply implicit key type conversion (#93)
- Multiple koan content issues reported by users (#79, #84, #85, #86, #91)
- String operator koan example grammar and an incorrect expected result (#62)
- Missing koans directory is now created instead of erroring when absent (#61)
- Regex pattern in koan parsing no longer matched on every character due to an unescaped `.` (#60)

### Removed

- `rake` alias and references to it throughout prompts and documentation (#71)

## [0.41.0] - 2018-08-26

### Added

- New `AboutStringBuilder` koan topic covering `[System.Text.StringBuilder]` creation and manipulation methods (#52).
- Here-string koans added to `AboutStrings` (#52).

### Changed

- Renamed and revised the `AboutVariables` koans; refactored `AboutConditionals` and `AboutFunctionsAndScriptBlocks` for style consistency (single quotes, comment reformatting, indentation) (#51).
- Reworked koan-counting in `Measure-Koan` to parse test-case expressions via the PowerShell AST instead of a slow, `Invoke-Expression`-based counter (#53).

## [0.40.0] - 2018-08-11

### Added

- New `AboutModules` koan topics: `Get-Module`, `Find-Module`, `Import-Module`, and `New-Module`.
- `Measure-Koans` function to abstract the koan-counting logic out of `Measure-Karma` (renamed from `Get-Enlightenment`).
- Verbose logging and comment-based help added to module functions.

### Changed

- Renamed `Get-Enlightenment` to `Measure-Karma`; parameters renamed to singular nouns for consistency.
- Restructured the main module file and test files; shifted file imports to the main module import.
- Build process now displays the repo branch/tag name; the module manifest was updated with repository and license metadata, and `FunctionsToExport`/`AliasesToExport`.
- Removed the Coveralls integration (deleted `.coveralls.yml`).

### Fixed

- Fixed a parameter naming error in `Measure-Karma`.

## [0.39.5] - 2018-08-06

### Changed

- Total koan count is now calculated via AST parsing instead of a secondary Pester run, significantly improving module load time; koan files beyond the user's current point are no longer loaded or run.

### Fixed

- Switched the build back to PowerShell 5, since AppVeyor was not correctly surfacing test failures under PowerShell Core.

## [0.39.3] - 2018-08-06

### Added

- New koan topics for object pipeline cmdlets: `Sort-Object`, `Where-Object`, `ForEach-Object`, `Tee-Object`, `Group-Object`, `Measure-Object`, `Compare-Object`, `New-Object`, and an expanded `Select-Object`, consolidated under `AboutObjectCmdlets`.
- New koan topics for PSProviders: variable, function, alias, environment, and filesystem providers, plus `AboutHashtables` and advanced `TestingArrays`/`TestingHashtables` koans.
- New `AboutDiscovery` koan covering `Get-Command` exploration and tab-completion.
- New koans for comparison, logical, and type-conversion operators, split into `AboutComparison` and `AboutMiscOperators`.
- Added a `[Koan()]` attribute allowing koan files/tests to be sorted and identified by attribute value instead of filename numbering; koan files were renamed to drop their numeric prefixes.
- Added a `PSDepend` build dependency file.

### Changed

- Reorganized koan numbering into large per-section ID ranges so new koans can be inserted without renumbering existing ones.
- Restructured `Get-Enlightenment` with proper mocked tests, `TestDrive`-based koan-initializer tests, and null-output checks across module functions.
- Split monolithic module and test files into one file per function; build scripts (`psake.ps1`, `build.ps1`, `appveyor.yml`) were updated to import/test the module correctly and report build status and environment details.
- Koan execution now hides harmless errors while still surfacing real test failures.

### Fixed

- Fixed koan file discovery/sorting scoping issues inside Pester `TestCases`/`Context` blocks.
- Fixed logic errors and an incorrect `New-Item` parameter in `AboutPSProviders`, and named-match errors in `AboutStringOperators`.
- Fixed several `appveyor.yml` build path and file-capitalization issues that were breaking CI builds.

## [0.38.1] - 2018-07-25

### Fixed

- Fixed the `env:` provider only accepting string values, which broke meditation prompt output; minor README correction.

## [0.38] - 2018-07-25

### Changed

- Set up an AppVeyor CI/CD pipeline and restructured the repository's folders and build files to support it, excluding koan files from build tests.
- Updated `rake -Meditate` to open koan files in VS Code when available.

### Fixed

- Replaced a fragile try/catch block with a proper test assertion.

## [0.37] - 2018-07-24

### Added

- Added `AboutSplatting` koans covering both array and hashtable splatting.

### Changed

- Moved `AboutLoopsAndPipelines` into the Foundations section and reworked koan indexing/sort order.
- Switched shared variable scope from `$script:` to `$env:`.

## [0.36] - 2018-07-22

### Added

- Added `AboutHashtables` koans covering hashtable construction and usage.

### Changed

- Reorganized koan numbering to give each section a larger ID space.

### Fixed

- Fixed errors in the `AboutPSProviders` koans.

## [0.35] - 2018-07-22

### Added

- Added the `AboutPSProviders` koan section, covering the FileSystem, Function, Variable, Alias, and Environment providers, along with generic provider/variable-access cmdlets.
- Added a `[Koan()]` attribute with a sort-order value, replacing filename-number-based ordering, and updated koan discovery to filter and sort by it.

### Changed

- Renamed koan files to drop numeric ordering prefixes now that sorting is attribute-driven.
- Restructured meditation prompt text into a hashtable to reduce indentation and simplify maintenance.

## [0.30] - 2018-07-16

### Added

- Added `AboutComparison` koans covering comparison, logical, type, and miscellaneous operators, plus type-conversion-failure koans.

### Changed

- Added a PSDepend dependency file for managing build dependencies.

## [0.25] - 2018-07-15

### Added

- Added `AboutStringOperators` koans covering the format (`-f`), index, `-split`, `-join`, `-replace`, regex, and subexpression operators, plus substring koans.

## [0.2] - 2018-07-15

### Added

- Initial scaffolding of the PSKoans framework: `Invoke-PSKoans` (aliased `Get-Enlightenment`), koan file discovery and sorting, colorized meditation prompt output, and the module manifest.
- Added starter koan topics: `AboutAssertions`, `AboutStrings`, `AboutConditionals` (if/else and switch statements), `AboutOperators` (arithmetic, assignment, comparison), `AboutFunctions`, `AboutOrderOfOperations`, arrays and lists, `AboutLoopsAndPipelines`, and `Get-Help`/`Get-Member` koans.
