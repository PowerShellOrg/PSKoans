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

$PSBStageFilesDependency = @('Clean', 'GenerateFormatData')
$PSBBuildDependency = @('StageFiles')
$PSBTestDependency = @('Pester5', 'Analyze')

Task Pester5 -Depends $PSBBuildDependency {
    $moduleManifest = Join-Path $PSBPreference.Build.ModuleOutDir "$($PSBPreference.General.ModuleName).psd1"

    Import-Module -Name $moduleManifest -Force
    Push-Location -LiteralPath $PSBPreference.Test.RootDir
    try {
        $configuration = [PesterConfiguration]::Default
        $configuration.Output.Verbosity = 'Detailed'
        $configuration.Run.PassThru = $true
        $configuration.TestResult.Enabled = $true
        $configuration.TestResult.OutputPath = $PSBPreference.Test.OutputFile
        $configuration.TestResult.OutputFormat = $PSBPreference.Test.OutputFormat

        $testResult = Invoke-Pester -Configuration $configuration
        if ($testResult.Result -eq 'Failed') {
            throw 'One or more Pester tests failed.'
        }
    }
    finally {
        Pop-Location
        Remove-Module -Name $PSBPreference.General.ModuleName -ErrorAction SilentlyContinue
    }
} -Description 'Executes Pester 5 tests'


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
