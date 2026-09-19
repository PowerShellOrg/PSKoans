Properties {
    # PSKoans stages files without compiling to a single PSM1
    $PSBPreference.Build.CompileModule = $false

    # Help generation
    $PSBPreference.Help.DefaultLocale = 'en-US'

    # Test configuration -- the module must be imported from the staged output before
    # Pester runs since the test suite expects `PSKoans` to already be loaded/resolvable
    $PSBPreference.Test.RootDir = Join-Path $PSScriptRoot 'tests'
    $PSBPreference.Test.ImportModule = $true
    $PSBPreference.Test.OutputFile = 'out/testResults.xml'
    $PSBPreference.Test.OutputFormat = 'JUnitXml'
    $PSBPreference.Test.ScriptAnalysis.Enabled = $true
    $PSBPreference.Test.ScriptAnalysis.SettingsPath = Join-Path $PSScriptRoot 'PSScriptAnalyzerSettings.psd1'
    $PSBPreference.Test.ScriptAnalysis.FailBuildOnSeverityLevel = 'Error'
    $PSBPreference.Test.CodeCoverage.Enabled = $false

    $PSBPreference.Publish.PSRepositoryApiKey = $env:PSGALLERY_API_KEY
}

# The module manifest's FormatsToProcess entry (PSKoans.format.ps1xml) is generated
# from ./formatting via EZOut and is gitignored -- it must exist before the module
# can be imported at all, so generate it ahead of staging.
Task GenerateFormatData -Depends Clean {
    & (Join-Path $PSBPreference.General.ProjectRoot 'PSKoans.ezformat.ps1')
} -Description 'Generates PSKoans.format.ps1xml from ./formatting'

# Koan files start with `using module PSKoans`. PSScriptAnalyzer can only resolve that if the
# staged module is discoverable on PSModulePath -- without it, every koan file surfaces a
# `ModuleNotFoundDuringParse` ParseError, and (more importantly) PSScriptAnalyzer skips every
# other rule that depends on symbol resolution (aliases, output types, etc.) for that file.
Task PrepareAnalysis -Depends Build {
    $moduleParentDir = Split-Path -Path $PSBPreference.Build.ModuleOutDir -Parent
    $currentEntries = $env:PSModulePath -split [IO.Path]::PathSeparator
    if ($moduleParentDir -notin $currentEntries) {
        $env:PSModulePath = $moduleParentDir + [IO.Path]::PathSeparator + $env:PSModulePath
    }
} -Description 'Makes the staged PSKoans module resolvable so koan files'' `using module` statements parse cleanly'

$PSBAnalyzeDependency = @('PrepareAnalysis')

$PSBStageFilesDependency = @('Clean', 'GenerateFormatData')
$PSBBuildDependency = @('StageFiles')

Task Default -Depends Test

# PowerShellBuild adds the following tasks:
# - Init
# - Clean
# - StageFiles
# - Build
# - Analyze
# - Pester
# - Test
# - BuildHelp
# - GenerateMarkdown
# - GenerateMAML
# - GenerateUpdatableHelp
# - Publish
Task Test -FromModule PowerShellBuild -MinimumVersion '0.7.3'
