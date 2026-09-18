#Requires -Module @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

BeforeDiscovery {
    if ($null -eq $env:BHProjectName) {
        # Run the build in a child process -- build.ps1 calls `exit` on completion, which
        # would otherwise terminate the host process running this test file.
        & pwsh -NoProfile -File '.\build.ps1' -Task Build
        if ($LASTEXITCODE -ne 0) {
            throw 'Failed to build PSKoans before running tests.'
        }
        Set-BuildEnvironment -Force
    }
    $manifest = Import-PowerShellDataFile -Path $env:BHPSModuleManifest
    $outputDir = Join-Path -Path $env:BHProjectPath -ChildPath 'Output'
    $outputModDir = Join-Path -Path $outputDir -ChildPath $env:BHProjectName
    $outputModVerDir = Join-Path -Path $outputModDir -ChildPath $manifest.ModuleVersion
    $outputModVerManifest = Join-Path -Path $outputModVerDir -ChildPath "$($env:BHProjectName).psd1"
    $env:PSModulePath = $outputModDir + [IO.Path]::PathSeparator + $env:PSModulePath

    # Remove all versions of the module from the session. Pester can't handle multiple versions.
    Get-Module $env:BHProjectName | Remove-Module -Force -ErrorAction Ignore
    Import-Module -Name $outputModVerManifest -Verbose:$false -ErrorAction Stop
}

Describe 'ConvertFrom-WildcardPattern' {

    It 'adds start and end of string anchors to an explicit value' {
        InModuleScope 'PSKoans' { ConvertFrom-WildcardPattern 'AboutArrays' } | Should -Be '^AboutArrays$'
    }

    It 'joins multiple expressions with |' {
        InModuleScope 'PSKoans' { ConvertFrom-WildcardPattern 'AboutArrays', 'AboutComparison' } |
            Should -Be '^AboutArrays$|^AboutComparison$'
    }

    It 'replaces wildcard characters with regex equivalent' -TestCases @(
        @{ Pattern = 'About*son'; Expected = '^About.*son$' }
        @{ Pattern = 'AboutArrays*'; Expected = '^AboutArrays' }
        @{ Pattern = '*Arrays'; Expected = 'Arrays$' }
        @{ Pattern = '*Array*'; Expected = 'Array' }
    ) {
        InModuleScope 'PSKoans' -Parameters @{ Pattern = $Pattern } {
            param($Pattern)

            ConvertFrom-WildcardPattern $Pattern
        } | Should -Be $Expected
    }
}
