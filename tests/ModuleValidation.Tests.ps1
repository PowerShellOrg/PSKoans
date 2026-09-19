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

Describe 'Static Analysis: Module & Repository Files' {

    #region Discovery
    $FileSearch = @{
        Path    = Resolve-Path "$PSScriptRoot/.."
        Include = '*.ps1', '*.psm1', '*.psd1'
        Recurse = $true
        Exclude = '*.Koans.ps1'
    }
    $Scripts = Get-ChildItem @FileSearch

    $TestCases = $Scripts | ForEach-Object { @{ File = $_ } }
    #endregion Discovery

    Context 'Repository Code' {

        It 'has no invalid syntax errors in <File>' -TestCases $TestCases {
            $File.FullName | Should -Exist

            $FileContents = Get-Content -Path $File.FullName -ErrorAction Stop
            $Errors = $null
            [System.Management.Automation.PSParser]::Tokenize($FileContents, [ref]$Errors) > $null
            $Errors.Count | Should -Be 0
        }

        It 'has exactly one line feed at EOF in <File>' -TestCases $TestCases {
            $crlf = [Regex]::Match(($File | Get-Content -Raw), '(\r?(?<lf>\n))+\Z')
            $crlf.Groups['lf'].Captures.Count | Should -Be 1
        }
    }

    Context 'Module Import' {

        BeforeAll {
            $ModuleName = 'PSKoans'
            $script:ModuleRoot = (Get-Module -Name $ModuleName).ModuleBase
        }

        It 'cleanly imports the module' {
            { Import-Module (Join-Path $ModuleRoot "$ModuleName.psm1") -Force } | Should -Not -Throw
        }

        It 'removes and re-imports the module without errors' {
            $Script = {
                Remove-Module $ModuleName
                Import-Module (Join-Path -Path $ModuleRoot -ChildPath "$ModuleName.psm1")
            }

            $Script | Should -Not -Throw
        }
    }
}
