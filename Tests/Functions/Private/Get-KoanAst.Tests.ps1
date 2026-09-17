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

Describe 'Get-KoanAst' {

    BeforeAll {
        $path = Join-Path $TestDrive 'AboutSomething.Koans.ps1'

        Set-Content -Path $path -Value @'
            using module PSKoans
            [Koan(Position = 1)]
            param()
            <#
                About Something
            #>
            Describe 'Something' {
                It 'Has some examples' {
                    $true | Should -BeTrue
                }
            }
'@
    }

    It 'excludes the "using module PSKoans" statement from the AST' {
        $ast = InModuleScope 'PSKoans' -Parameters @{ Path = $path } {
            param($Path)
            Get-KoanAst -Path $Path
        }

        $ast.UsingStatements | Should -BeNullOrEmpty
    }

    It 'maintains consistency of position data when reading and modifying the source' {
        $tokens = $errors = $null
        $originalAst = [System.Management.Automation.Language.Parser]::ParseFile(
            $path,
            [Ref]$tokens,
            [Ref]$errors
        )

        $originalItBlock = $originalAst.Find(
            {
                $args[0] -is [System.Management.Automation.Language.CommandAst] -and
                $args[0].GetCommandName() -eq 'It'
            },
            $true
        )

        $modifiedAst = InModuleScope 'PSKoans' -Parameters @{ Path = $path } {
            param($Path)
            Get-KoanAst -Path $Path
        }

        $modifiedItBlock = $modifiedAst.Find(
            {
                $args[0] -is [System.Management.Automation.Language.CommandAst] -and
                $args[0].GetCommandName() -eq 'It'
            },
            $true
        )

        $modifiedItBlock.Extent.StartOffset |
            Should -Be $originalItBlock.Extent.StartOffset -Because 'the start offsets should match'
        $modifiedItBlock.Extent.EndOffset |
            Should -Be $originalItBlock.Extent.EndOffset -Because 'the end offsets should match'
    }
}
